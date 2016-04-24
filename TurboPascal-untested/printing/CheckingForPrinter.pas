(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0019.PAS
  Description: Checking For Printer
  Author: SWAG SUPPORT TEAM
  Date: 08-17-93  08:40
*)

program chkprinter;

uses dos,crt;

var
  lprn: integer;
  st : string;


function printerok(lprn : integer) : boolean;

var ok   : boolean;
    regs : registers;
    st   : string;
    code : byte;

begin                 {printerok}
  ok := false;
  dec(lprn);
  if ((lprn >= 0) and (lprn <= 2)) then
    repeat
      regs.ah := 2;
      regs.dx := lprn;
      intr($17, regs);
      code := regs.ah;
      if code <> $90
        then
          begin
            case code of
     $02, $4A : st := '        Printer is not connected        ';
     $00, $10,
     $18, $58 : st := '           Printer is offline           ';
     $28, $38 : st := '         Printer is out of paper        ';
     $88, $C8 : st := '          Printer is turned off         ';
           else st := '       Output device is not ready       ';
           end;      {case}
           GoToXY(1,1);
           WriteLn(st);
           WriteLn(' ');
           WriteLn('Please correct the error');
           WriteLn('or press a key to continue')
          end
        else
          ok := true;
    until ok or keypressed;
  if ok then printerok := ok
end;                  {printerok}
{**********************************************************************}

  begin

  ClrScr;

  if paramcount <> 0
    then begin
           st := copy(paramstr(1), 1, 1);
           lprn := ord(st[1]) - 48
         end
    else lprn := 1;

  if printerok(lprn) then
     writeln('Printer OK')
  else
     writeln('Printer not ok')
end.

