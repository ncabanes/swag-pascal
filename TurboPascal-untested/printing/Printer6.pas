(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0012.PAS
  Description: PRINTER6.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:55
*)

{
I am writing a Program that Uses the Printer to (whatelse?) print
out a report.  Now, the problem that I am having is that the Printer
Function in TP 6.0 (ie Writeln (lst,'BLA BLA BLA');) Dosn't
check For errors (if the Printer is not on, or is not online)

 You can determine the Various states of the Printer With Intr 17H -
 Function 02H.  The value returned in AH will be:

         bit   if set
           0 - Printer timed out
           1 - unused
           2 - unused
           3 - i/o error
           4 - Printer selected
           5 - out of paper
           6 - Printer acknowledge
           7 - Printer not busy

 For example:
}
Function PrinterReady : Boolean;
Var
  reg : Registers;
  Status : Byte;

begin
  reg.AH := $02;
  reg.DX := $00;  {..0=LPT1, 1=LPT2, etc }
  intr($17,reg);

  Status := reg.AH and $41;  {..isolate bits 0,3,5 }
  if Status <> 0 then
    PrinterReady := False
  else
    PrinterReady := True;
end;

{
basicaly I need something that weill check and give out the
NB>famous line ('Printer not Ready (A)bort (R)etry')

The way I've handled this in the past is to check PrinterReady beFore
each Write/WriteLn statement (not very eloquant).  A better way to do
this might be to hook it to an interrupt, checking the status every few
seconds.
}
