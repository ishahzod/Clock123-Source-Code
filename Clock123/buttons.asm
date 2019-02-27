/* states:
			0: running, disp time, alarm mode on
			1: running, disp time, alarm mode off
			2: running, disp time, alarm off, inhibit
			3: running, disp time, alarm on, inhibit
			4: running, disp time, alarm sounding
			5: running, disp time, set delay
			6: running, disp time, alarm set delay
			7: running, alarm set hours
			8: running, alarm set hours delay
			9: running, alarm set mins
			10: running, alarm set mins delay
			11: show 24
			12: show 24 inhibit
			13: show 24 inhibit
			14: show 12
			15: set hours inhibit
			16: set hours
			17: set hours delay
			18: set mins inhibit
			19: set mins
			20: set mins delay
*/
	
//read switches	
	in scr,pinb					;get switch states
	andi scr,0b00111000			;ignore all other bits 
	mov temp,scr				;put in temporary register
	mov scr,state
	cpi scr,0
	brne try_1
	rjmp state_0
try_1:
	cpi scr,1
	brne try_2
	rjmp state_1
try_2:
	cpi scr,2
	brne try_3
	rjmp state_2
try_3:
	cpi scr,3
	brne try_4
	rjmp state_3
try_4:
	cpi scr,4
	brne try_5
	rjmp state_4
try_5:
	cpi scr,5
	brne try_6
	rjmp state_5
try_6:
	cpi scr,6
	brne try_7
	rjmp state_6
try_7:
	cpi scr,7
	brne try_8
	rjmp state_7
try_8:
	cpi scr,8
	brne try_9
	rjmp state_8
try_9:
	cpi scr,9
    brne try_10
    rjmp state_9
try_10:
	cpi scr,10
    brne try_21
    rjmp state_10
try_21:
    cpi scr,21
    breq state_21

state_22:
    mov scr,temp
    cpi scr,null
    breq go_s9
    rjmp go_home

go_s22:
    ldi scr,22
    rjmp cs

state_21:
    mov scr,temp
    cpi scr,null
    breq go_s7
    rjmp go_home

go_s21:
    ldi scr,21
    rjmp cs

state_10:
	mov scr,temp	
	cpi scr,null
	breq go_s9		
	cpi scr,incd
	brne i_wanna
	inc b_cnt			
	mov scr,b_cnt 		
	cpi scr,b_delay	
	breq go_s9		
	rjmp go_home

go_s10:
	clr b_cnt
    inc alarm_mins
    mov scr,alarm_mins
    cpi scr,60
    brne no_wrap_m
    subi scr,60
    mov alarm_mins,scr
no_wrap_m:
	ldi scr,10
	rjmp cs

state_9:
	mov scr,temp
	cpi scr,incd
	breq go_s10
	cpi scr,setd
	breq long_way
	rjmp go_home
long_way:
	rjmp go_s0

go_s9:
	ldi scr,9
	rjmp cs	

state_8:
	mov scr,temp	
	cpi scr,null
	breq go_s7		
	cpi scr,incd
	brne i_wanna
	inc b_cnt			
	mov scr,b_cnt 		
	cpi scr,b_delay	
	breq go_s7		
	rjmp go_home

i_wanna:            // this is provided to avoid 'out of range' branches
    rjmp go_home

go_s8:
	clr b_cnt
    inc alarm_hrs
    mov scr,alarm_hrs
    cpi scr,24
    brne no_wrap
    subi scr,24
    mov alarm_hrs,scr
no_wrap:
    ldi scr,8
	rjmp cs

state_7:
	mov scr,temp
	cpi scr,incd
	breq go_s8
	cpi scr,setd
	breq go_s22
	rjmp go_home

go_s7:
	ldi scr,7
	rjmp cs

state_6:
	mov scr,temp
	cpi scr,setd
	brne go_s0
	inc b_cnt
	mov scr,b_cnt
	cpi scr,b_long
	brne go_home
	rjmp go_s21

go_s6:
	ldi scr,6
	clr b_cnt
	rjmp cs

state_5:
	mov scr,temp
	cpi scr,setd
	brne go_s1
	inc b_cnt
	mov scr,b_cnt
	cpi scr,b_long
	breq state_13
	rjmp go_home

go_s5:
	ldi scr,5
	clr b_cnt
	rjmp cs

state_4:
	mov scr,temp
	cpi scr,null
	brne go_s3
	rjmp go_home

state_3:
	mov scr,temp
	cpi scr,null
	breq go_s0
	rjmp go_home

go_s3:
	sbi portc,al_lite	;turn on the alarm light
	ldi scr,3
	rjmp cs

state_2:
	mov scr,temp
	cpi scr,null
	breq go_s1
	rjmp go_home

go_s2:
	cbi portc,al_lite	;turn off the alarm light
	ldi scr,2
	rjmp cs

state_1:
	mov scr,temp
	cpi scr,setd
	breq go_s5
	cpi scr,alrmd
	breq go_s3
	rjmp go_home

go_s1:
	ldi scr,1
	rjmp cs

state_0:
	mov scr,temp
	cpi scr,setd
	breq go_s6
	cpi scr,alrmd
	breq go_s2
	rjmp go_home 

go_s0:
	clr scr
	
cs:
	mov state,scr	;store new state

go_home:
    rjmp buttons_done


state_13:
	ldi zh,disp_table_h
	ldi zl,disp_table_l	
	ldi scr,0b10000101		;2
	st z,scr
	ldi scr,0b01100011		;4
	st -z,scr
	ldi scr,0b00110011		;h
	st -z,scr
	ldi scr,0b10110110		;r
	st -z,scr
	cbr clk_stat,0x01   	;clear 12 hour mode
hold_up_0:
	rcall q_disp_chars
	in scr,pinb				;get switch states
	andi scr,0b00111000		;mask out other stuff
	cpi scr,null			;wait for all buttons up
	brne hold_up_0			;keep waiting
	rcall q_disp_chars		;wait a little longer for debounce
	rcall q_disp_chars
	rcall q_disp_chars
state_11:
	rcall q_disp_chars
	in scr,pinb				;get switch states
	andi scr,0b00110000		;ignore all but inc and set
	cpi scr,0b00110000		;neither button set
	breq state_11			;keep waiting
	cpi scr,0b00100000		;inc down?
	breq state_12
	rjmp state_15
state_12:
	ldi zh,disp_table_h
	ldi zl,disp_table_l	
	ldi scr,0b11101011		;1
	st z,scr
	ldi scr,0b10000101		;2
	st -z,scr
	ldi scr,0b00110011		;h
	st -z,scr
	ldi scr,0b10110110		;r
	st -z,scr
	sbr clk_stat,0x01	    ;set 12 hour mode
hold_up_1:
	rcall q_disp_chars
	in scr,pinb
	andi scr, 0b00111000
	cpi scr, null			;are all buttons up
	brne hold_up_1			;wait for buttons to be up
	rcall q_disp_chars		;wait a little longer for debounce
	rcall q_disp_chars
	rcall q_disp_chars
state_14:
	rcall q_disp_chars
	in scr,pinb				;get switch states
	andi scr,0b00110000		;ignore all but inc and set
	cpi scr,0b00110000		;neither button set
	breq state_14			;keep waiting
	cpi scr,0b00100000		;inc down?
	breq state_13

state_15:
	rcall s_disp_hr
	in scr,pinb
	andi scr, 0b00111000
	cpi scr, null			;are all buttons up
	brne state_15	    	;wait for buttons to be up

state_16:
    rcall s_disp_hr         ;display hours
    in scr,pinb             ;get buttons
    andi scr,0b00111000     ;ignore all but buttons
	cpi scr,setd    		;set down?
	breq state_18			
    cpi scr,incd            ;inc down?
    breq s_16_inc
    rjmp state_16
s_16_inc:
    clr b_cnt               ;clear button timer
    inc hrs                 ;increment hours
    cpi hrs,24              ;overflow?
    brne state_17
    clr hrs                 ;reset on overflow
    rjmp state_17

state_17:
    rcall s_disp_hr         ;display hours
    in scr,pinb
    andi scr,0b00111000     ;ignore all but buttons
	cpi scr,incd    		;inc down?
	brne state_16           ;no, go back to state_16			
//inc is down
    cpi scr,incd            ;inc down?
    inc b_cnt               ;increment button count
    mov scr,b_cnt
    cpi scr,b_delay       
    breq state_16           ;button has been down awhile, return to state 16
    rjmp state_17

state_18:
	rcall s_disp_min
	in scr,pinb
	andi scr,0b00111000
	cpi scr,null			;are all buttons up
	brne state_18	    	;wait for buttons to be up

state_19:
    rcall s_disp_min        ;display minutes
    in scr,pinb             ;get buttons
    andi scr,0b00111000     ;ignore all but buttons
	cpi scr,setd    		;set down?
	breq go_s1_local
    cpi scr,incd            ;inc down?
    breq s_19_inc
    rjmp state_19
s_19_inc:
    clr b_cnt               ;clear button timer
    inc mins                 ;increment minutes
    cpi mins,60              ;overflow?
    brne state_20
    clr mins                 ;reset on overflow
    rjmp state_20

state_20:
    rcall s_disp_min        ;display minutes
    in scr,pinb
    andi scr,0b00111000     ;ignore all but buttons
	cpi scr,incd    		;inc down?
	brne state_19           ;no, go back to state_19			
//inc is down
    cpi scr,incd            ;inc down?
    inc b_cnt               ;increment button count
    mov scr,b_cnt
    cpi scr,b_delay       
    breq state_19           ;button has been down awhile, return to state 19
    rjmp state_20
go_s1_local:                ;go to state 1
    ldi scr,1
    mov state,scr       	;store new state
    clr secs
    clr ticks

buttons_done:
