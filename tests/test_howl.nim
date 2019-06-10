import howl, bitvector

let encryptCode = generateRule[uint8]()
assert encryptCode == 30 # Rule 30 automata
let encryptRule = wolfCode[uint8](encryptCode)

var 
  message = toBitVector[uint8]([1, 0, 0, 0, 1, 0, 0, 1]) # message to encrypt
  temp = newBitVector[uint8](8) # temp holder
  previous = toBitVector[uint8]([0, 1, 0, 1, 1, 0, 0, 1]) # random initial
  original = message # We will use this to later assert our decryption

echo "Random initialization: ", print(previous)
echo "encryption code: ", print(encryptRule)
echo "Original message: ", print(message)

let iterations = 100 # we will iterate 100 times
for i in 0 ..< iterations:
  # Encrypting...
  encrypt(message, temp, previous)
  previous = message # update conatiners to prepair for next iteration
  message = temp
echo "Encrypted message is: ", print(message)

for i in 0 ..< iterations: # we will iterate the same amount as above
  # Decrypting...
  decrypt(message, temp, previous)
  message = previous # update containers to prepair for next iteration
  previous = temp
echo "Decrypted message is: ", print(message)

assert message == original # Yay it works!
