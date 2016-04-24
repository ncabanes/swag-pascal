(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0051.PAS
  Description: Clear Keyboard QUICK
  Author: MARC BIR
  Date: 10-28-93  11:28
*)

(*==========================================================================
Date: 08-25-93 (00:32)
From: MARC BIR
Subj: CLEAR KEYBOARD

  Here's a quick way to clear keyboard buffer:
*)

Procedure ClearKeyBoard;
Begin
 ASM CLI End;
 MemW[$40:$1A] := MemW[$40:$1C];
 ASM STI End;
End;

(*
MemW[$40:$1A] = ptr to next char in cyclical kbd buffer
MemW[$40:$1C] = ptr to last char ""

  Incase you haven't had data structures, when the next ptr equals the
last ptr in a cyclical buufer, the buffer is empty.
  Hope that helps  ( doesn't need CRT )


