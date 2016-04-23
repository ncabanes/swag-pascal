
              (* Insert a '.' before the statment '$DEFINE' to        *)
              (* compile without debugging information.               *)
{.$DEFINE DebugMode}

{$IFDEF DebugMode}
  {$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,P-,R+,S+,V+,X-}
{$ELSE}
  {$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,R-,S-,V-,X-}
{$ENDIF}

(**********************************************************************)
(* PRINTIT.PAS - Public-domain TP printer unit by Guy McLoughlin.     *)
(* version 1.10 (July, 1993)                                          *)
(* Min TP version: 4+                                                 *)
(**********************************************************************)

unit PrintIt;

(* BIT-MAP OF THE PRINTER "STATUS-BYTE"                               *)
(* ------------------------------------                               *)
(*                                                                    *)
(* BIT NUMBER  7  6  5  4  3  2  1  0                                 *)
(*             |  |  |  |  |  |  |  +-- Printer "timed-out"           *)
(*             |  |  |  |  |  +--+----- These bits are NOT used       *)
(*             |  |  |  |  +----------- Printer I/O error             *)
(*             |  |  |  +-------------- Printer "selected"            *)
(*             |  |  +----------------- Printer is out of paper       *)
(*             |  +-------------------- Acknowlegment from printer    *)
(*             +----------------------- Printer NOT busy              *)

interface

type
  st_8 = string[8];


  (***** Initialize printer port.                                     *)
  (*                                                                  *)
  function InitPrinterPort({ input} wo_PrinterNum : word) : {output} byte;


  (***** Check the status of the printer.                             *)
  (*                                                                  *)
  function CheckPrinter({ input} wo_PrinterNum : word) : {output} byte;


  (***** Initialize PrintIt variables, and check printer status.      *)
  (*                                                                  *)
  function InitPrintIt({ input}     st_PrinterID  : st_8;
                                    by_PrinterNum : byte;
                                    bo_InitPort   : boolean;
                       {update} var fi_Printer    : text;
                                var by_Status     : byte)
                       {output}   : boolean;


  (***** Position printer "head" to X columns across, Y rows down.    *)
  (*                                                                  *)
  procedure P2xy({ input} var fi_Printer : text;
                              by_Xaxis,
                              by_Yaxis   : byte);


  (***** Print string at position X columns across, Y rows down.      *)
  (*                                                                  *)
  procedure Pwrite({ input} var fi_Printer : text;
                                st_Data    : string;
                                by_Xaxis,
                                by_Yaxis   : byte);


implementation

const         (* Line-feed, Carriage-return, Space character constant *)
  co_Lf    = #10;
  co_Cr    = #13;
  co_Space = #32;

var           (* "space" character, and line-feed string variables.   *)
  st_Spaces,
  st_LineFeeds : string;


  (***** Initialize printer port.                                     *)
  (*                                                                  *)
  function InitPrinterPort({ input} wo_PrinterNum : word) :
                           {output} byte; assembler;
  asm
    mov ax, 0100h
    mov dx, wo_PrinterNum
    int 17h
    mov al, ah
  end;        (* InitPrinterPort.                                     *)


  (***** Check the staus of the printer.                              *)
  (*                                                                  *)
  function CheckPrinter({ input} wo_PrinterNum : word) :
                        {output} byte; assembler;
  asm
    mov ax, 0200h
    mov dx, wo_PrinterNum
    int 17h
    mov al, ah
  end;        (* CheckPrinter.                                        *)


  (***** Initialize PrintIt variables, and check printer status.      *)
  (*                                                                  *)
  function InitPrintIt({ input}     st_PrinterID  : st_8;
                                    by_PrinterNum : byte;
                                    bo_InitPort   : boolean;
                       {update} var fi_Printer    : text;
                                var by_Status     : byte)
                       {output}   : boolean;
  begin
              (* Initialize "PrintIt" variables.                      *)
    fillchar(st_Spaces, sizeof(st_Spaces), co_Space);
    fillchar(st_LineFeeds, sizeof(st_LineFeeds), co_Lf);

              (* Try to open text-device printer variable.            *)
    assign(fi_Printer, st_PrinterID);
    {$I-}
    rewrite(fi_Printer);
    {$I+}
    if (ioresult <> 0) then
      begin
        by_Status := $FF;
        InitPrintIt := false
      end
    else
      begin
              (* Initialize printer-port if required.                 *)
        if bo_InitPort then
          by_Status := InitPrinterPort(by_PrinterNum)
        else
              (* Else, check the status of the printer.               *)
          by_Status := CheckPrinter(by_PrinterNum);

              (* Check for error-flags in the printer status byte.    *)
        if ((by_Status AND $29) = 0) then
          InitPrintIt := true
        else
          InitPrintIt := false
      end
  end;        (* InitPrinter.                                         *)


  (***** Position printer "head" to X columns across, Y rows down.    *)
  (*                                                                  *)
  procedure P2xy({ input} var fi_Printer : text;
                              by_Xaxis,
                              by_Yaxis   : byte);
  begin
    if (by_Yaxis > 0) then
      begin
        st_LineFeeds[0] := chr(by_Yaxis);
        write(fi_Printer, st_LineFeeds)
      end;
    if (by_Xaxis > 0) then
      begin
        st_Spaces[0] := chr(pred(by_Xaxis));
        write(fi_Printer, co_Cr + st_Spaces)
      end
  end;        (* P2xy.                                                *)


  (***** Print string at position X columns across, Y rows down.      *)
  (*                                                                  *)
  procedure Pwrite({ input} var fi_Printer : text;
                                st_Data    : string;
                                by_Xaxis,
                                by_Yaxis   : byte);
  begin
    P2xy(fi_Printer, by_Xaxis, by_Yaxis);
    write(fi_Printer, st_Data)
  end;        (* Pwrite.                                              *)

END.

{--------------------------------   CUT HERE -----------------------------}
(* Program to demo "PrintIt" unit.                    *)

program DemoPrintIt;
uses
  PrintIt;

const         (* Form-feed character.                               *)
  co_FF = #12;

var           (* Printer "status" byte. Check "bit-map" in PrintIt  *)
              (* unit for table of bit-flags.                       *)
  by_PrinterStatus : byte;

              (* Our text-device interface variable.                *)
  fi_Printer : text;

              (* Main program block.                                *)
BEGIN
              (* Initialize "PrintIt" variables, and check the      *)
              (* status of the printer.                             *)
  if NOT InitPrintIt('PRN', 0, false, fi_Printer, by_PrinterStatus) then

              (* InitPrintIt failed. Inform user of this, and halt. *)
    begin
      writeln('Error accessing printer!');
      writeln('Printer error = ', by_PrinterStatus);
      halt
    end;
              (* Print "SECRET" meaning of life symbol!!! <g>       *)
              (* Position printer head to column 45, 5 rows down.   *)
  P2xy(fi_Printer, 45, 5);

              (* Write some text to the printer.                    *)
  write(fi_Printer, '_)');

  P2xy(fi_Printer, 43, 0);
  write(fi_Printer, '(_');
  P2xy(fi_Printer, 45, 1);
  write(fi_Printer, '@)');
  P2xy(fi_Printer, 43, 0);
  write(fi_Printer, '(@');
  P2xy(fi_Printer, 41, 1);
  write(fi_Printer, '---\/');
  P2xy(fi_Printer, 36, 0);
  write(fi_Printer, '/----');
  P2xy(fi_Printer, 35, 1);
  write(fi_Printer, '/ |     ||');
  P2xy(fi_Printer, 40, 1);
  write(fi_Printer, '---||');
  P2xy(fi_Printer, 34, 0);
  write(fi_Printer, '*  ||-');
  P2xy(fi_Printer, 37, 1);
  write(fi_Printer, '^^    ^^');

              (* Print "SECRET" number code, using "Pwrite" routine.*)
  Pwrite(fi_Printer, '10', 45, 5);
  Pwrite(fi_Printer, '2', 37, 0);
  Pwrite(fi_Printer, '8', 43, 0);
  Pwrite(fi_Printer, '7', 42, 0);
  Pwrite(fi_Printer, '1', 36, 0);
  Pwrite(fi_Printer, '6', 41, 0);
  Pwrite(fi_Printer, '3', 38, 0);
  Pwrite(fi_Printer, '9', 44, 0);
  Pwrite(fi_Printer, '5', 40, 0);
  Pwrite(fi_Printer, '0', 35, 0);
  Pwrite(fi_Printer, '4', 39, 0);

              (* Say good-bye, Guy.                                 *)
  Pwrite(fi_Printer, '...Thats All Folks!!!', 30, 2);

              (* Send form-feed to printer.                         *)
  write(fi_Printer, co_FF)
END.

