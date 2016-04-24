(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0048.PAS
  Description: DISK SERIAL
  Author: JON JASIUNAS
  Date: 10-28-93  11:37
*)

{===========================================================================
Date: 08-22-93 (01:50)             Number: 35568
From: JON JASIUNAS                 Refer#: NONE
Subj: SERIAL # OF DISK               Conf: (1221) F-PASCAL
--------------------------------------------------------------------------- }

  Uses DOS, CRT;
  Type MIDRecord = Record
     InfoLevel : Word;
     SerialNum : LongInt;   {This is the serial number...}
     VolLabel  : Array[1..11] of Char;
     FatType   : Array[1..8] of Char;
     End;
Function Label_Fat(Var Mid : MidRecord; Drive : Word) : Boolean;
Var Result : Word;
Var Regs   : Registers;
Begin
     FillChar(Mid,SizeOf(Mid),0);
     FillChar(Regs,SizeOf(Regs),0);
     With Regs DO
     Begin
          AX := $440D;
          BX := Drive;
          CX := $0866;
          DS := Seg(Mid);
          DX := Ofs(Mid);
          Intr($21,Regs);
          Case AX of
               $01 : Label_Fat := False;
               $02 : Label_Fat := False;
               $05 : Label_Fat := False;
               Else Label_Fat := True;
          End;
     End;
End;

Var Mid : MidRecord;
Begin
     ClrScr;
     If Label_Fat(Mid,0) Then
     With Mid DO
     Begin
          Writeln(SerialNum);
          Writeln(VolLabel);
          Writeln(FatType);
     End
     Else Writeln('Error Occured');
End.


