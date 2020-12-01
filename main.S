#include <xc.inc>
    
;importing external subroutines 
extrn   encrypt_me, decrypt_me
extrn	UART_Setup, UART_Transmit_Message  
extrn	LCD_Setup, LCD_Write_Message, LCD_clear
extrn   keypad_setup, keypad_start
extrn   Storage_setup, Storage_read

	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
	; ******* Text to be encrypted stored in the table *****
myTable:
	    db   'L', 'A', 'B' , ' ','P', 'R', 'O', 'J', 'E', 'C', 'T', '!', '!'  
    myword	EQU 0x200	; Address in RAM for data
    counter_hi	EQU 0x8		; Address of counter variable
    cipherkey	EQU 0x9		; Address of cipher key
    xorkey	EQU 0x10	; Address of XOR key
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	
	bcf	CFGS		; point to Flash program memory  
	bsf	EEPGD		; access Flash program memory
	call    keypad_setup	; obtain the cipher key
	movff   LATH, cipherkey	; store key temporarily at address
	movlw   0 
	movwf   LATH		; clear traces of key
	call    keypad_setup	; obtain XOR key
	movff   LATH, xorkey	; store key temporarily at address
	movlw   0 
	movwf   LATH		; clear traces of key
	call    Storage_setup	; store keys in external memory
	call	UART_Setup 	; setup UART
	call	LCD_Setup	; setup LCD
	goto	start
	
	; ******* Main programme ****************************************
start: 	    
	lfsr     0, myword		    ; Load FSR0 with address in RAM
	lfsr     1, 0x300
	movlw    low highword(myTable)	    ; address of data in PM
	movwf    TBLPTRU, A		    ; load upper bits to TBLPTRU
	movlw    high(myTable)		    ; address of data in PM
	movwf    TBLPTRH, A		    ; load high byte to TBLPTRH
	movlw    low(myTable)		    ; address of data in PM
	movwf    TBLPTRL, A		    ; load low byte to TBLPTRL
	movlw    12			    ; size of the string 
	movwf    counter_hi, A		    ; our counter register
loop1: 	
	tblrd*+		   ; move one byte from PM to TABLAT, increment TBLPRT
	movff    TABLAT, 0x52
	call     encrypt_me		; call the encryption module
	movff    0x53, POSTINC1
	call     decrypt_me		; call the decryption moduele
	movff    0x53, POSTINC0	;move data from TABLAT to,FSR0, increment FSR0
	decfsz   counter, A		; count down to zero
	bra      loop1 
	
	movlw	12			; number of characters
	lfsr	1, 0x300		; point FSR1 to begining of text
	call	UART_Transmit_Message	; output encrypt char to Terminal
	
	movlw    12
	lfsr     0  , 0x200		; point FSR0 to begining of text
	call	LCD_Write_Message	; output decrypt char to LCD
	goto     $
	
	end	rst
