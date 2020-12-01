#include <xc.inc>

; import extenral routines
global  UART_Setup, UART_Transmit_Message

psect    udata_acs	; reserve data space in access ram
UART_counter: ds    1   ; reserve 1 byte for variable UART_counter

psect    uart_code,class=CODE
UART_Setup:
    bsf         SPEN	    ; enable
    bcf         SYNC	    ; synchronous
    bcf         BRGH	    ; slow speed
    bsf         TXEN	    ; enable transmit
    bcf         BRG16	    ; 8-bit generator only
    movlw       103	    ; gives 9600 Baud rate (actually 9615)
    movwf	SPBRG1, A   ; set baud rate
    bsf		TRISC, PORTC_TX1_POSN, A    ; TX1 pin is output on RC6 pin
    
    return

UART_Transmit_Message:        ; Message stored at FSR2, length stored in W
    movwf   UART_counter, A   ; Move current character

UART_Loop_message:
    movf    POSTINC1, W, A        ; loop FSR1 through each character
    call    UART_Transmit_Byte    ; transmit current character
    decfsz  UART_counter, A	  ; decrement counter (size of text)
    bra     UART_Loop_message     ; repeat loop
    return

UART_Transmit_Byte:		
    btfss   TX1IF		; TX1IF is set when TXREG1 is empty
    bra     UART_Transmit_Byte  ; transmits byte stored in W
    movwf   TXREG1, A		
    return
