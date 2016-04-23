{
> Does anyone know how to create a popup window and have a program
> running in the background? I've seen this done in such bbs programs

Multitasking.  /[:)  I suppose you guessed that part, though.  Here's the
assembly portion of a _working_ multi-tasker I did in 2nd year:

NAME ProcSwitch
; Written by Dave Jarvis

DOSSEG
.MODEL SMALL

.CODE

PUBLIC _new_clock 
EXTRN _new_process : NEAR 
 
NUM_TICKS    EQU      45               ; 45 clock ticks = 2.5 seconds 
 
_new_clock   PROC    NEAR 
 
             CMP _tick_count, NUM_TICKS 
             JE GetNewProc             ; Get a new process 
 
             INC _tick_count           ; Resume counting interrupts 
             JMP DoneInt               ; End of interrupt. 
 
GetNewProc:  MOV _tick_count, 0  ; Reset the interrupt counter 
 
             PUSH DS             ; Save all registers on "stack" 
             PUSH ES 
             PUSH AX 
             PUSH BX 
             PUSH CX 
             PUSH DX 
             PUSH SI 
             PUSH DI 
             PUSH BP 
 
             MOV AX, SS         ; Point _S_ss and _S_sp to current 
             MOV _S_ss, AX      ; SS and SP values. 
             MOV AX, SP 
             MOV _S_sp, AX 
 
             CALL _new_process  ; Get new process' stack registers 
 
             MOV AX, _S_ss      ; Point SS:SP to process stack segment 
             MOV SS, AX         ;   registers found in call to _new_process 
             MOV AX, _S_sp 
             MOV SP, AX 
 
             POP BP             ; Restore interrupted process' registers
             POP DI             ;   from "stack" 
             POP SI 
             POP DX 
             POP CX

             POP BX 
             POP AX
             POP ES
             POP DS

DoneInt:     PUSH AX
             MOV AL, 20h        ; Load EOI into AL
             OUT 20h, AL        ; Send PIC chip EOI signal
             POP AX
             IRET               ; Return to interrupted process

_new_clock   ENDP

.DATA?
       EXTRN _tick_count:WORD
       EXTRN _S_ss:WORD, _S_sp:WORD

END

{
You take over the $1C interrupt, count the ticks, and restore the state
of all the registers when the ticks hits a certain value.

What you have to do is set up a procedure (called New_Process) which
changes the stack pointer to an array in memory which contains the values
of the registers (all listed + IP, CS, & FLAGS) prior to the process
being interrupted.
}