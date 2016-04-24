(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0024.PAS
  Description: Object printer
  Author: JACK WILSON
  Date: 08-27-93  21:46
*)

{
Jack Wilson

The Objective is to intercept when the Printer is off-line, and give the
user a reminder to turn the Printer on-line, and press any key to resume
printing.

I Realize this is most certainly an FAQ, and I have found some source
code on Timo's site For TP 5.5 that I have modified (see below), but
there is not much talk anymore about TP 3.0.

Anyway, to avoid making a lot of changes to my source code, I thought I
would reWrite the LstOut Procedure (which according to the manual, is
called by routines accessing the LST: device) as shown at the end of
the following listing.  This is inefficient, since it is being called
for each Character that is output to the Printer.  Does anybody have a
better suggestion?  I might add the way it is now, if an off-line
signal is detected, the LstOut will only print the first Character
('t') in the Write(lst,'test') in the main Program, With the 'est'
going to the screen.  if I remove the statements in the While loop of
LstOut, then all of 'test' goes to the Printer, but it defeats my
purpose of giving the user a message.
}

{by David R. Conrad, For Turbo Pascal 5.5

   This code is not copyrighted, you may use it freely.
   There are no guarantees, either expressed or implied,
   as to either merchantability or fitness For a particular
   purpose.  The author's liability is limited to the amount
   you paid For it.
   David R. Conrad, 17 Nov 92
   David_Conrad@mts.cc.wayne.edu
   dave@michigan.com
}

Const
  { For use With the Printer Functions }
  PrnNotBusy = $80;
  PrnAck     = $40;
  PrnNoPaper = $20;
  PrnSelect  = $10;
  PrnIOError = $08;
  PrnTimeout = $01;

Type
  Word   = Integer;
  AnyStr = String[255];

Var
  PrinterNumber : Byte;

{ all routines are documented in the Implementation section }

Procedure InitRegisters(Var Reg : Registers);
{ initialize Variable of Type Registers: slightly anal-retentive }
begin
  fillChar (Reg, sizeof(Reg), 0);
  Reg.DS := DSeg;
  Reg.ES := DSeg;
end;

Function PrnOnline(Printernumber : Byte) : Boolean;
{ Is LPT(Printernumber) online? }
Var
  Reg : Registers;
begin
  InitRegisters(Reg);
  Reg.AH := 2;
  Reg.DX := Pred(Printernumber);
  Intr($17, Reg);
  PrnOnline := (Reg.AH and PrnSelect) = PrnSelect;
end;

Procedure pause;
Var
  c : Char;

begin
  c := #127;
  Repeat
    if KeyPressed then
      c := ReadKey;
   Until c in [#0..#126];
end;


{**************************************************************************}
{THIS IS THE ROUTINE in QUESTION}

Procedure LstOut(ch : Char);

Var
  Reg : Registers;

begin
  While not (PrnOnline(PrinterNumber)) do
  begin
    {if I TAKE OUT THESE NEXT THREE LINES, then OUTPUT PaUses Until Printer
     IS ON-LINE, and then ALL CharS PRINT to Printer}
    GotoXY(1, 23);
    ClrEol;
    Write('Please check Printer, and press any key when ready...');
    pause;
  end;
  initRegisters(Reg);
  Reg.AH := 0;
  Reg.DX := Pred(PrinterNumber);
  Reg.AL := Byte(ch);
  Intr($17, Reg);

end;

{**************************************************************************}

begin
  PrinterNumber := 1;
  LstOutPtr     := ofs(LstOut);
  Writeln(lst, 'test');
end.


