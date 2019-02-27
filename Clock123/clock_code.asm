// definitions

.include "tn48def.inc"         ;Generic includes file
.include "header.h"            ;header file has all definitions

// setup microcontroller
.include "setup.asm"           ;Includes setup routine

// main code starts here

tick_tock:
	sbis pinc,tap			;check the rectifier voltage
	rjmp tick_tock			;go back to tick_tock if voltage is low

// check for button press
.include "buttons.asm"      ;Checks for button press and sets the state of the system

// increment time
count_t:
	inc ticks			;increment ticks counter
	cpi ticks,60		;compare ticks to 60
	brne check_state	;branch to show_time if ticks is not 60

//increment seconds
	clr ticks			;reset tick counter
	inc secs			;increment seconds counter
	cpi secs,60			;compare seconds to 60
	brne check_state	;branch to show_time if seconds is not 60

//increment minutes					
	clr secs			;reset seconds counter
	inc mins			;increment minutes counter
	cpi mins,60			;compare minutes to 60
	brne check_alarm	;branch if minutes is not 60
				
//increment hours
	clr mins			;reset minutes counter
	inc hrs				;increment hours counter
	cpi hrs,24			;compare hours to 24
	brne check_alarm	;branch if hours is not 24

//increment days				
	clr hrs				;reset hours counter

// check to see if the alarm should go off
check_alarm:
	mov scr,state			;check current state
	cpi scr,4				;is alarm currently sounding?
	brne not_now			;jump, alarm is not on now
	ldi scr,0
	mov state,scr			;alarm has been sounding for a minute, turn it off
	sbi portc,al_lite	    ;turn on the alarm light (it had been flashing)
not_now:
	cp hrs,alarm_hrs	
	brne show_time
	cp mins,alarm_mins
	brne check_state
	tst state				;state 0 is 'running/alarm on'
	brne check_state		;branch if alarm is not set
	ldi scr,4
	mov state,scr			;enter alarm-on state

// display time
check_state:

// check state register to see if time or alarm setting is to be displayed
    mov scr,state
    cpi scr, 0  
    breq show_time
    cpi scr,1
    breq show_time
    cpi scr,2
    breq show_alarm
    cpi scr,3
    breq show_alarm
    cpi scr,4
    breq show_time
    cpi scr,5
    breq show_time
    cpi scr,6
    breq show_time
    rjmp show_alarm

show_alarm:    
    rcall disp_alarm
    rjmp wait_zero
show_time:
	ldi scr,5			;five times around
	mov do_count,scr	;move to count register
time_warp:
	mov scr,secs		;put seconds in scratch register
	com scr				;invert
	andi scr,0b00111111	;set bits for colon 
	out portd,scr		;show seconds
	cbi portb,dig0		;enable seconds display
	rcall take4000		;wait and sound buzzer	
	sbi portb,dig0		;turn off seconds display
	mov scr,hrs			;get hours to scr

	rcall get_segs_h	;convert to segments
	out portd,segs_h	;show first digit
	cbi portb,dig1		;turn on first digit
	rcall take4000		;wait and sound buzzer
	sbi portb,dig1		;turn off first digit

	out portd,segs_l
	cbi portb,dig2
	rcall take4000		;wait and sound buzzer
	sbi portb,dig2
	
	mov scr,mins		;get minutes to scr
	rcall get_segs_m	;convert to segments
	out portd,segs_h	;show first digit
	cbi portb,dig3		;turn on third digit
	rcall take4000		;wait and sound buzzer
	sbi portb,dig3		;turn off third digit

	out portd,segs_l
	cbi portb,dig4
	rcall take4000		;wait and sound buzzer
	sbi portb,dig4
	dec do_count		;decrement loop counter
	brne time_warp		;do it again?
wait_zero:
	sbic pinc,tap
	rjmp wait_zero		;done, wait for the next low phase
	rjmp tick_tock

.include "subroutines.asm"  ;Holds common subroutines

