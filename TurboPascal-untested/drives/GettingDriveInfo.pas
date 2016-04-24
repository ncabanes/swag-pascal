(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0052.PAS
  Description: Getting Drive INFO
  Author: ERIC GIVLER
  Date: 11-02-93  05:34
*)

{
ERIC GIVLER

> about, evidentally), are two different things.  The serial
> number is only accessible in Dos v4.0+, and (I think), you
> have to use the FCBs to get it.

No, no FCBs, see:
}

Uses
  Dos,
  Crt;

Type
  MIDRecord = Record
    InfoLevel : Word;
    SerialNum : LongInt;   {This is the serial number...}
    VolLabel  : Array [1..11] of Char;
    FatType   : Array [1..8] of Char;
  end;

Function Label_Fat(Var Mid : MidRecord; Drive : Word) : Boolean;
Var
  Result : Word;
  Regs   : Registers;
begin
  FillChar(Mid,SizeOf(Mid),0);
  FillChar(Regs,SizeOf(Regs),0);
  With Regs DO
  begin
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
      else
        Label_Fat := True;
    end;
  end;
end;

Var
  Mid : MidRecord;
begin
  ClrScr;
  if Label_Fat(Mid,0) Then
  With Mid DO
  begin
    Writeln(SerialNum);
    Writeln(VolLabel);
    Writeln(FatType);
  end
  else
    Writeln('Error Occured');
end.


