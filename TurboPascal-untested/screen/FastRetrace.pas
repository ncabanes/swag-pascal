(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0052.PAS
  Description: Fast Retrace
  Author: ANDRE GROSSE BLEY
  Date: 01-27-94  12:00
*)

{
> repeat until (port[$3da] and $08) = 0;
> repeat until (port[$3da] and $08) <> 0;
> The above code is some I've abducted from this echo. It waits for a
> 'retrace' (sp).
> Does anyone have faster code to wait for a retrace? This code seems to
> greatly slow down my programs on certain (slower) computers.

I think TP is fast enough for that, because your video card needs much time
to display the screen. Perhaps this is a little bit faster on REALLY slow
machines:
}

Asm
  MOV DX,$03DA
@@1:
  IN  DX,AX
  TEST AX,$08
  JZ @@1
@@2:
  IN  DX,AX
  TEST AX,$08
  JNZ @@2
End;


