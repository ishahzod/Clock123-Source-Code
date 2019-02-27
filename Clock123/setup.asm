.org 0x0000
rjmp initialize

.org 0x0014
initialize:

// setup portb	
	ldi scr,0xff			;Load 0xff to scratch register
	out portb,scr			; Output to PortB
	ldi scr,0b11000111      ;Load b'11000111' to scratch register
	out ddrb,scr			; Out to Data direction port, b0,1,2,6,7 output rest input 

// setup portc
	ldi scr,0b01001111		;enable pullups, set speaker and led off
	out portc,scr           ; Load b'01001111' to scratch register, then output to portc
	ldi scr,0b00110000		; Load 0011000 to scratch register
	out ddrc,scr			; Output to data direction port c4,5 output

// setup portd
	ser scr					;set all pins as output and initialize high
	out portd,scr			
	out ddrd,scr

// set timer0 prescaler to 64
	ldi scr,0b00000011
	out tccr0a,scr

// power down unused peripherals
	ldi scr, 0b1000101		;shudown twi, timer1, and adc
	sts prr,scr				; move scratch register to prr SFR

// initialize registers
	clr hrs
	clr mins
	clr secs
	clr ticks				;Clear registers
	ldi scr,1				;Load 1d to scratch
	mov state,scr		 	;Move scratch to state, we are working in the first state
	clr clk_stat				
	clr alarm_mins
	clr alarm_hrs			;Clear Registers

// speaker test
	clr temp	
go_hi:
	sbi portc,sp			;toggle speaker
	rcall kill2000			;delay
	cbi portc,sp			;toggle speaker
	rcall kill2000			;delay
	inc temp				;Increment temp
	brne go_hi				;go back to begginning

// individual LED test
	cbi portb,dig0			;enable individual LEDs
	ldi scr,4				;four times around
	mov do_count,scr		;Move scr to do_count
loopy:
	ldi scr,0b11111110		; Load scratch register 
	out portd,scr			;turn on one LED in each digit
flicker:
	rcall long_delay		;wait a while
	rcall long_delay
	in scr,portd			;read portd 
	sec						;set carry flog
	rol scr					;rotate bits
	brcc done				;done when the zero rotates into carry
	out portd,scr			;turn on next LED
	rjmp flicker			
done:
	dec do_count			;wanna see it again?
	brne loopy				;Branch when dec hits 0

// seven segment led test
	sbi portb,dig0			;disable individual LEDs
	cbi portb,dig1			;enable all 7seg digits
	cbi portb,dig2	
	cbi portb,dig3		
	cbi portb,dig4
	ldi scr,4				;four times around
	mov do_count,scr
loopy7:
	ldi scr,0b11111110
	out portd,scr			;turn on one LED in each digit
flicker7:
	rcall long_delay		;wait a while
	rcall long_delay
	in scr,portd			;read portd 
	sec						;set carry flog
	rol scr					;rotate bits
	brcc done7				;done when the zero rotates into carry
	out portd,scr			;turn on next LED
	rjmp flicker7
done7:
	dec do_count			;wanna see it again?
	brne loopy7
	sbi portb,dig1			;disable all LEDs
	sbi portb,dig2	
	sbi portb,dig3		
	sbi portb,dig4

// digit driver test
	ldi scr,4				;four times around
	mov do_count,scr
	clr scr
	out portd,scr			;all segments on
driver_loop:
	cbi portb,dig0			;digit zero on
	rcall long_delay
	rcall long_delay
	sbi portb,dig0	
	cbi portb,dig1			;digit one on
	rcall long_delay
	rcall long_delay
	sbi portb,dig1			;	and off
	cbi portb,dig2			;digit two on
	rcall long_delay
	rcall long_delay
	sbi portb,dig2			;	and off
	cbi portb,dig3			;digit three on
	rcall long_delay
	rcall long_delay
	sbi portb,dig3			;	and off
	cbi portb,dig4			;digit four on
	rcall long_delay
	rcall long_delay
	sbi portb,dig4			;	and off
	dec do_count
	brne driver_loop

// alarm light test
	sbi portc,al_lite
	rcall long_delay
	rcall long_delay
	cbi portc,al_lite
	rcall long_delay
	rcall long_delay
	sbi portc,al_lite
	rcall long_delay
	rcall long_delay
	cbi portc,al_lite
	rcall long_delay
	rcall long_delay
	sbi portc,al_lite
	rcall long_delay
	rcall long_delay
	cbi portc,al_lite
	rcall long_delay
	rcall long_delay
	sbi portc,al_lite
	rcall long_delay
	rcall long_delay
	cbi portc,al_lite
	rcall long_delay
	rcall long_delay

//splash screen
	ldi zh,disp_table_h		;load top of table address in z
	ldi zl,disp_table_l		
	ldi scr,0b11111111		;display off
	st z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	ldi zl,disp_table_l		
	ldi scr,0b11111111		;display off
	st z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b00010101		;E
	st -z,scr
	rcall disp_chars
	ldi zl,disp_table_l		
	ldi scr,0b11111111		;display off
	st z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b00010101		;E
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	rcall disp_chars
	ldi zl,disp_table_l		
	ldi scr,0b11111111		;display off
	st z,scr
	ldi scr,0b00010101		;E
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	rcall disp_chars
	ldi zl,disp_table_l		
	ldi scr,0b00010101		;E
	st z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	rcall disp_chars
	ldi zl,disp_table_l		
	ldi scr,0b00010101		;E
	st z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b01010001		;S
	st -z,scr
	rcall disp_chars
	ldi zl,disp_table_l		
	ldi scr,0b00010101		;E
	st z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b01010001		;S
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	rcall disp_chars
	ldi zl,disp_table_l		
	ldi scr,0b00010101		;E
	st z,scr
	ldi scr,0b01010001		;S
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	rcall disp_chars
	ldi zl,disp_table_l		
	ldi scr,0b00010101		;E
	st z,scr
	ldi scr,0b01010001		;S
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b00010101		;E
	st -z,scr
	rcall disp_chars
	ldi zl,disp_table_l		
	ldi scr,0b00010101		;E
	st z,scr
	ldi scr,0b01010001		;S
	st -z,scr
	ldi scr,0b00010101		;E
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	ldi zl,disp_table_l		
	ldi scr,0b11111111		;display off
	st z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	rcall disp_chars
	ldi zl,disp_table_l		
	ldi scr,0b11000001		;3
	st z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	rcall disp_chars
	ldi zl,disp_table_l	
	ldi scr,0b11111111		;display off	
	st z,scr
	ldi scr,0b11000001		;3
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	rcall disp_chars
	ldi zl,disp_table_l	
	ldi scr,0b11111111		;display off	
	st z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11000001		;3
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	rcall disp_chars
	ldi zl,disp_table_l	
	ldi scr,0b11111111		;display off	
	st z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11000001		;3
	st -z,scr
	rcall disp_chars
	ldi zl,disp_table_l	
	ldi scr,0b10000101		;2
	st z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11000001		;3
	st -z,scr
	rcall disp_chars
	ldi zl,disp_table_l	
	ldi scr,0b11111111		;display off	
	st z,scr
	ldi scr,0b10000101		;2
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11000001		;3
	st -z,scr
	rcall disp_chars
	ldi zl,disp_table_l	
	ldi scr,0b11111111		;display off	
	st z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b10000101		;2
	st -z,scr
	ldi scr,0b11000001		;3
	st -z,scr
	rcall disp_chars
	ldi zl,disp_table_l	
	ldi scr,0b11101011		;1
	st z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b10000101		;2
	st -z,scr
	ldi scr,0b11000001		;3
	st -z,scr
	rcall disp_chars
	ldi zl,disp_table_l	
	ldi scr,0b11111111		;display off	
	st z,scr
	ldi scr,0b11101011		;1
	st -z,scr
	ldi scr,0b10000101		;2
	st -z,scr
	ldi scr,0b11000001		;3
	st -z,scr
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	ldi zl,disp_table_l	
	ldi scr,0b11111111		;display off	
	st z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	rcall disp_chars
	rcall disp_chars
	ldi zl,disp_table_l	
	ldi scr,0b01010001		;S
	st z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b01101011		;'1
	st -z,scr
	ldi scr,0b00001001		;0
	st -z,scr
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	ldi zl,disp_table_l	
	ldi scr,0b11111111		;display off	
	st z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars
	rcall disp_chars

// initialize LED segment table
	ldi zh,ram_table_h		;load top of table address in z
	ldi zl,ram_table_l
	ldi scr,0b00001001		;zero
	st z,scr
	ldi scr,0b11101011		;one
	st -z,scr
	ldi scr,0b10000101		;two
	st -z,scr
	ldi scr,0b11000001		;three
	st -z,scr
	ldi scr,0b01100011		;four
	st -z,scr
	ldi scr,0b01010001		;five
	st -z,scr
	ldi scr,0b00010001		;six
	st -z,scr
	ldi scr,0b11001011		;seven
	st -z,scr
	ldi scr,0b00000001		;eight
	st -z,scr
	ldi scr,0b01000001		;nine
	st -z,scr
	ldi scr,0b11111111		;display off
	st -z,scr
    rjmp state_13           ;set the clock




