(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0032.PAS
  Description: More Timing Functions
  Author: MIKE WAROT
  Date: 05-26-95  23:30
*)

{
From: ka9dgx@interaccess.com (Mike Warot)

Here is the companion code for TIMER2.PAS which is required as well.
(My news grazed choked on the file size... go figure)
}

Unit Timer2;
{
  Author  : Michael Warot
  Date    : December, 1987
  Purpose : Provide timing functions.
  Notes   : Does not provide midnight protection.

  05/29/92 MAW - Add protection against midnight in DT()
  06/18/93 MAW - Remove ExactRealTime - Too much fuss
}
Interface
Uses
  DOS;

Const
  OneDay   = $1800AF;        { Number of Seconds in one Day }

Procedure StartTime(Var X : LongInt);
{ Resets the tick counter }

Function DT(Var X : LongInt) : LongInt;
{ Returns the time since the last Starttime, IN TICKS }

Function TimeStamp : String;
{ Returns YYMMDD:HHMMSS }

Function REALtime:LongInt;
{ Returns time from BIOS in SECONDS }

Function Ticks:Longint; { Current time of day, in TICKS }

Implementation

Var
  BiosTick : LongInt ABSOLUTE $40:$6c;
  LastTime : LongInt;

(*
Function Ticks : Longint; Assembler;
Asm
  Cli
  Mov ax,0040h
  mov es,ax
  mov ax,es:[6ch]
  mov dx,es:[6eh]
  Sti
End;
*)
Function Ticks : Longint;
Var
  X : Longint;
Begin
  Repeat
    X := BiosTick;
  Until X = BiosTick;
  Ticks := X;
End;

Procedure StartTime(Var X : LongInt);
Begin
  X := Ticks;
End;

(*
Function DT(Var X : LongInt) : LongInt; Assembler;
Asm
  les  bx,X
  mov  cx,es:[bx]
  mov  bx,es:[bx+2]     { X is now in BX:CX   }
  CLI
  mov  ax,0040h
  mov  es,ax
  mov  ax,es:[6ch]
  mov  dx,es:[6eh]      { Current is in DX:AX }
  STI
  sub  ax,cx
  sbb  dx,bx
  jnc  @ok              { delta t is DX:AX, without midnight }
  add  ax,00afh         { handle midnight! }
  adc  dx,0018h
@ok:
End;
*)

Function DT(Var X : Longint):Longint;
Var
  Y : Longint;
Begin
  Y := Ticks;
  Y := Y - X;
  If Y < 0 then Inc(Y,OneDay);
  DT := Y;
End;

Function TimeStamp:String;
Var
  Year,Month,Date,Day,
  Hour,Min,Sec,Sec100   : Word;
  Tmp,Tmp2 : String;
  I        : Byte;
Begin
  GetDate(Year,Month,Date,Day);
  GetTime(Hour,Min,Sec,Sec100);
  Year := Year MOD 100;

  Str(Year:2  ,Tmp2); Tmp := Tmp2;
  Str(Month:2 ,Tmp2); Tmp := Tmp + Tmp2;
  Str(Date:2  ,Tmp2); Tmp := Tmp + Tmp2 + ':';
  Str(Hour:2  ,Tmp2); Tmp := Tmp + Tmp2;
  Str(Min:2   ,Tmp2); Tmp := Tmp + Tmp2;
  Str(Sec:2   ,Tmp2); Tmp := Tmp + Tmp2;
  For i := 1 to Length(Tmp) DO
    If Tmp[i] = ' ' Then
      Tmp[i] := '0';
  TimeStamp := Tmp;
End; { TimeStamp }

Function REALtime:Longint;
Var
  Hour,Min,Sec,Sec100 : Word;
  h,m,s : longint;
Begin
  GetTime(Hour,Min,Sec,Sec100);
  H := Hour;
  M := Min;
  S := Sec;
  REALtime := H*3600 + M*60 + S;
End;

End.


