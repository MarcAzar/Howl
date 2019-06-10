## Copyright (C) Marc Azar. All rights reserved.
# MIT License. Look at LICENSE.txt for more info
##
## Second Order Cellular Automaton for Cryptography.
##
## Usage
## --------------
##  ::
##    import howl
##
##    let encryptCode = generateRule[uint8]()
##    assert encryptCode == 30 # Rule 30 automata
##    let encryptRule = wolfCode[uint8](encryptCode)
## 
##    var 
##      message = toBitVector[uint8]([1, 0, 0, 0, 1, 0, 0, 1]) # our message
##      temp = newBitVector[uint8](8) # temp holder
##      previous = toBitVector[uint8]([0, 1, 0, 1, 1, 0, 0, 1]) # random initial
##      original = message # We will use this to later assert our decryption
## 
##    echo "Random initialization: ", print(previous)
##    echo "encryption code: ", print(encryptRule)
##    echo "Original message: ", print(message)
## 
##    let iterations = 100 # we will iterate 100 times
##    for i in 0 ..< iterations:
##      # Encrypting...
##      encrypt(message, temp, previous)
##      previous = message # update conatiners to prepair for next iteration
##      message = temp
##    echo "Encrypted message is: ", print(message)
## 
##    for i in 0 ..< iterations: # we will iterate the same amount as above
##      # Decrypting...
##      decrypt(message, temp, previous)
##      message = previous # update containers to prepair for next iteration
##      previous = temp
##    echo "Decrypted message is: ", print(message)
## 
##     assert message == original # Yay it works!
## 
import bitvector

func print*(input: BitVector): string =
  ## Lets provide a function to print out our bitVector in an array like
  ## fashion. The printout is in little endian format (the natural way we write
  ## binary :)
  ##
  let higher = input.cap - 1
  result.add("[" & $input[higher] & ", ")
  for i in countdown(higher - 1, 0):
    result.add($input[i] & ", ")
  result[^2] = ']'

func incMod(x, y, N: int): int {.inline.} =
  ## A faster modular additon
  ##
  let 
    tmp = y + x
    delta = tmp - N
  if delta >= 0:
    result = delta
  else: result = tmp

func generateRule*[T](): T =
  ## We can use this template to generate any mapping (injective or not) to
  ## calculate the next state A(t+1) from the three neighbouring states at
  ## t. You can add more states, more neighbours, and rely on any mapping,
  ## since we will turn this into a second order automata to ensure it will be
  ## reversible. This below represents WolfCode number 30. This will be run
  ## only once at compile time or during initialization, and results in a bitVector
  ## that contains all possible permutations for a speedy random access lookup.
  ##
  let
    states = [0, 1]
  var
    tmp = newBitVector[T](3) # will produce 8 bits, smallest container is uint8
    index: int
    encryptCode = newBitVector[T](8) # capacity 2^3 = 8
  for centralCell in states:
    tmp[0] = centralCell
    for rightCell in states:
      tmp[1] = rightCell
      for leftCell in states:
        tmp[2] = leftCell
        index = tmp[0 .. 7].int
        encryptCode[index] = leftCell xor (centralCell or rightCell)
  result = encryptCode[0 .. 7]

func wolfCode*[T](x: Natural): BitVector[T] =
  ## If you already know the code number of your rule, you can use it here to
  ## transform it into a bitVector.
  ##
  result = toBitVector[T](x)

proc encrypt*(message, temp, previous: var BitVector) {.inline.} =
  ## This encrypts our message relying on previous state and places it in
  ## temp to be used as the new input message in the next iteration.
  ## The last and first states are not padded, and rely on their right only,
  ## and left only neighbours respectively. If you add more states, you should
  ## increase the Mod accordingly. The loop can be run in parallel using ||
  ## instead of .. if you do not want to compile with -d:openmp option, you
  ## can also use spawn instead, or go concurrent with async.
  ##
  let length = message.cap - 1
  temp[0] = incMod(encryptRule[message[0 .. 2].int], previous[0], 2)
  for i in 1 .. (length - 1):
    temp[i] = incMod(encryptRule[message[i-1 .. i+1].int], previous[i], 2)
  temp[length] = incMod(encryptRule[message[(length - 2) .. length].int],
                  previous[length], 2)

proc decrypt*(message, temp, previous: var BitVector) {.inline.} =
  ## This decrypts our message provided the previous state is also available,
  ## the result is placed in `temp` to be used as our new input message to
  ## decrypt in the next iteration. If you add more states, you should increase
  ## the mod accordingly. The first and last states have their own special
  ## rules, see above. The loop can be run in parallel using || instead of
  ## .. if you do not want to compile with -d:openmp option, you
  ## can also use spawn instead, or go concurrent with async.
  ##
  let length = message.cap - 1
  temp[0] = incMod(encryptRule[previous[0 .. 2].int], message[0], 2)
  for i in 1 .. (length - 1):
    temp[i] = incMod(encryptRule[previous[i-1 .. i+1].int], message[i], 2)
  temp[length] = incMod(encryptRule[previous[(length - 2) .. length].int],
                  message[length], 2)
