# Cellular Automaton
A second order cellular automaton for cryptography. This creates a reversible <a class="external reference" href="https://en.wikipedia.org/wiki/Second-order_cellular_automaton">Second-order cellular automaton</a> based on any elementary cellular automaton following Edward Fredkin's method. The cellular automaton is used for encrypting and decrypting bit chunks as demonstrated by Zhenchuan Chai in <a class="external reference" href="http://dx.doi.org/10.1007/11576259_39">Encryption Based on Reversible Second-Order Cellular Automata</a>.
The merits of this method in cryptography is that it can be a very low energy
way of encrypting/decrypting data, since the process is reversible making it a
great candidate for ultra-low-power computing. Moreover, automatons can
generate sequences that in the words of Collatz Lothar "Mathematics may not be
ready for such problems".
## Example Usage                                                        
```
    import howl

    let encryptCode = generateRule[uint8]() # this will generate Rule 30 of WolfCode, check src for details
    assert encryptCode == 30 # Rule 30 automata
    let encryptRule = wolfCode[uint8](encryptCode)
 
    var 
      message = toBitVector[uint8]([1, 0, 0, 0, 1, 0, 0, 1]) # our message
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
```
## The Idea Behind Using the Automata for Cryptography
One can easily pick up any elementary cellular automaton set of rules for any
number of states and then assign to each a unique identifier. After both
parties share the list of rules, one could proceed to select different rules
with different iterations. This can look something like (2,10,3,4) signifying
that the encryption used Rule 2 for 10 iterations then Rule 3 for another 4
iterations and so on ... This information is okay to be public as the Rules are
only known by the two participating members, and this string is the only
information along with the enrypted message needed for the decryption
algorithm.

## Documentation
Documentation can be found <a class="external reference" href="https://marcazar.github.io/Howl/docs/howl.html">Howl</a>
