.def tens = r0
.def set_count = r1
.def alarm_mins = r2
.def alarm_hrs = r3
.def state = r4
.def temp = r5
.def do_count = r6
.def b_cnt = r7

.def ticks = r16
.def secs = r17
.def mins = r18
.def hrs = r19
.def scr = r20
.def segs_h = r21
.def segs_l = r22
.def clk_stat = r23

//clk_stat register
.equ civ_mode = 0x0

//portb digit drivers
.equ dig0 = 0x0
.equ dig1 = 0x1
.equ dig2 = 0x2
.equ dig3 = 0x6
.equ dig4 = 0x7

//portb buttons
.equ alrmd = 0x30	;alarm button down, others up
.equ incd = 0x28	;inc button down, others up
.equ setd = 0x18	;set button down, others up
.equ null = 0x38	;all buttons up

//portc 
.equ al_lite = 0x4	;alarm button light
.equ sp = 0x5
.equ tap = 0x7

//ramtables
.equ ram_table_h = 0x01
.equ ram_table_l = 0x0f
.equ disp_table_h = 0x01
.equ disp_table_l = 0x1f

//general
.equ b_delay = 15	;button delay, measured in 60Hz cycles
.equ b_long	= 60	;long button delay