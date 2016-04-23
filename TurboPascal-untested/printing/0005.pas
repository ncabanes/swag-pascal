{ The following Program, LPRINT, illustrates how to do control a    }
{ Printer directly without using the BIOS (Printers connected to    }
{ the parallel port, not serial Printers connected to an RS-232     }
{ port).                                                            }
{ LPRINT checks to see if you want to print a line from the command }
{ prompt, as in:                                                    }
{        LPRINT Hello, World!                                       }
{ If there's no command input, LPRINT checks For Characters at the  }
{ "standard input," so you can print Files or directories using     }
{ redirection or piping:    LPRINT < myFile.pas                     }
{                           DIR | LPRINT                            }
{ LPT1 is used. You can modify LPRINT to use another, or be able to }
{ specify which Printer via the command line (eg. /2 For LPT2,etc.) }
{ This source code is a bit cramped, to fit into one message.       }
{                                                                   }

Program LPRINT;
Uses
  Dos;
Const
  BusyB   =$80;                   { status port 'busy' bit    }
  AckB    =$40;                   { status port 'ack' bit     }
Var
  DataP,
  Strobe,
  Status,                         { assigned lpt i/o ports    }
  MaxWait : Word;                 { seconds before timing out }
  Done    : Boolean;              { sanity clause             }
  Reg     : Registers;            { For Dos i/o               }
  txtptr  : Byte;                 { counter Byte              }

Procedure VerifyPrinter( Var Printer, Status, Strobe : Word );
{ check For presence of specified Printer - returning ports         }
begin
  if Printer in [1..3] then         { must be known     }
  begin
    DEC( Printer );                 { For 0..2          }
    Printer := MemW[$40 : (Printer + 8 + Printer * 2)];
    if ((Port[Printer + 1] and AckB) = 0) then
      Printer := 0           { to say it's not there }
    else
    begin
      Status := Printer + 1;
      Strobe := Printer + 2;
    end
  end
end; {VerifyPrinter}

Procedure Print( DataP : Word; chout : Byte; Var Done : Boolean);
{ send Character to Printer port, With busy timeout and feedback    }
Var
  WaitTime : LongInt;
  Timer    : LongInt Absolute 0:$046c;
  BusyWait : Word;
begin
  BusyWait := 0;
  WaitTime := Timer;
  While ((Port[Status] and BusyB) = 0) and (BusyWait < MaxWait * 19) do
  { wait up to MaxWait seconds For non-busy state             }
    BusyWait := Word( Timer - WaitTime );
  if BusyWait >= (MaxWait * 19) then { Printer "busy" For too long? }
    Done := False              { failed            }
  else
  begin
    Port[DataP]  := chout;     { send the Char data}
    Port[Strobe] := $0c;       { strobe it in      }
    Port[Strobe] := $0d;       { reset strobe      }
    Done := True;              { success           }
  end {else}
end; {Print}

begin   {LPRINT}
  WriteLn(#10, 'LPRINT v1.0 G.S.Vigneault', #10);
  DataP := 1;     { LPT1 }
  VerifyPrinter( DataP, Status, Strobe );
  { DataP will be 0 now if requested Printer didn't respond   }
  if DataP = 0 then
  begin
    WriteLn('Printer not detected!',#10,#7);
    Halt(1);
  end;
  MaxWait := 10;  { max wait 10sec before timing out lpt      }
  if ParamCount = 0 then  { no command-line input?            }
  { handle redirected and piped }
  Repeat
    Reg.AH := $b;   { to see if a Char is available     }
    MsDos( Reg );
    if Reg.AL <> 0 then
    begin
      Reg.AH := 8;            { get the Char      }
      MsDos( Reg );           { via Dos           }
      Print( DataP, Reg.AL, Done );{ lprint it    }
    end; {if}
  Until (Reg.AL = 0) or not Done
  else    { print the command line Text }
  begin
    txtptr := $82;
    Repeat
      Print( DataP, Mem[PrefixSeg:txtptr], Done );
      INC( txtptr );
    Until (Mem[PrefixSeg:txtptr] = 13) or not Done;
  if Done then
    Print( DataP, 10, Done);       { lf    }
  end;
end {LPRINT}.
(********************************************************************)
