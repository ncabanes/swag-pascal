(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0030.PAS
  Description: New Timer Unit
  Author: THOMAS HONORE NIELSEN
  Date: 05-26-95  23:22
*)

{
>Hi, I'm looking for a timer program that will be able to calculate
>consistently and accurately the processing time of a certain procedure.
>The one program I've seen simply takes the times reported by Dos at the
>beginning and end, and subtracts them. This program seems to report
>different processing times each time I run it. Sometimes the program changes
>by up to 7/10th of a second (even after the procedure being timed is run
>several times and loaded into the buffer). Strangly enough, if my clock is
>set to 5:00:00 before the timer prog is run, the time reported is less than
>when the clock is set to 6:00:00; this happens consistently!
>
>Is there some other more accurate way to time my procedure?

This ought to work.
From: thn.cls@login.dknet.dk (Thomas Honore Nielsen)
}

UNIT Profiler;

INTERFACE

PROCEDURE Start;
FUNCTION Stop: Real;

IMPLEMENTATION

VAR
   StartW : Word;
   StartM : LongInt;
   StopW  : Word;
   StopM  : LongInt;

PROCEDURE Start;

ASSEMBLER;

ASM
   IN     AL, 40h
   MOV    AH, AL
   IN     AL, 40h
   XCHG   AH, AL
   MOV    Word PTR StartW , AX
   MOV    BX, 40h
   MOV    ES, BX
   MOV    BX, 6Ch
   MOV    AX, ES:[BX]
   MOV    Word PTR StartM, AX
   MOV    AX, ES:[BX+2]
   MOV    Word PTR StartM+2, AX
END;

FUNCTION Stop: Real;

BEGIN
     ASM
        IN      AL, 40h
        MOV     AH, AL
        IN      AL, 40h
        XCHG    AH, AL
        MOV     Word PTR StopW, AX
        MOV     BX, 40h
        MOV     ES, BX
        MOV     BX, 6Ch
        MOV     AX, ES:[BX]
        MOV     Word PTR StopM, AX
        MOV     AX, ES:[BX+2]
        MOV     Word PTR StopM+2, AX
     END;
     IF StartM <= StopM THEN
       StopM:=StopM-StartM
     ELSE
       StopM:=1572480-StartM+StopM;
     IF StartW <= StopW THEN
       StopW:=StopW-StartW
     ELSE
       StopW:=65535-StartW+StopW;
     Stop:=(Stopm*65535+StopW)/1193181.667;
END;
END.

