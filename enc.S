#include <xc.inc>

global  encrypt_me, decrypt_me  ; allow to import these from other files
extrn    Storage_read		; import external routines


psect    enc_code,class=CODE

main:
    org    0x0
    org    0x100
 
encrypt_me:
    call     Storage_read     ; retreive the Caesar Cipher and XOR Keys
    movf     0x50, W 
    addwf    0x52, W          ; add the cipher key to binary of Unicode char
    xorwf    0x51, W          ; XOR(result, XOR_Key)
    movwf    0x53
    return

decrypt_me:
    call     Storage_read     ; retreive the Caesar Cipher and XOR Keys
    movf     0X53, W
    xorwf    0x51, W          ; XOR(result, XOR_Key)
    movwf    0x99             
    movf     0x50 ,W          
    subwf    0x99, W          ; add the cipher key to binary of Unicode char
    movwf    0x53
    return
