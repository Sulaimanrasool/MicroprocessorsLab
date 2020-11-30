Encryption Device Project
-------------------------
Authors: Sulaiman Rasool & Georgios Alevras
Date: 01/12/2020

This is a simple 2-stage hardware-based encryption device, using Caesar Cipher and XOR binary operation to encrypt a stored message.
The program transmits the encrypted message on the terminal of the computer, and the decrypted message on the LCD display of the PIC board.

There are 6 files:
  main.S         -runs code
  keypad.S       -obtains keys for encryption / decryption input with a keypad
  Storage.S      -stores and retrieves the keys from the external memory
  LCD.S          -displayes decrypted text on LCD display
  UART.S         -transmits encrypted message to PC terminal
  enc.S          -encrypts / decrypts text
as well as the configuration file.

