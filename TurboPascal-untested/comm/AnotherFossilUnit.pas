(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0024.PAS
  Description: Another Fossil Unit
  Author: STEVE GABRILOWIZ
  Date: 08-27-93  21:25
*)

{
STEVE GABRILOWITZ

> I was wondering if anyone had any routines they could send me or tell
> me where to find some routines that show you have to use the
> fossil I have a file on my BBS called TPIO_100.ZIP,
}

Unit IO;


              { FOSSIL communications I/O routines }
              { Turbo Pascal Version by Tony Hsieh }

  {}{}{}{ Copyright (c) 1989 by Tony Hsieh, All Rights Reserved. }{}{}{}


{ The following routines are basic input/output routines, using a }
{ fossil driver.  These are NOT all the routines that a fossil    }
{ driver can do!  These are just a portion of the functions that  }
{ fossil drivers can do.  However, these are the only ones most   }
{ people will need.  I highly recommend for those that use this   }
{ to download an arced copy of the X00.SYS driver.  In the arc    }
{ is a file called "FOSSIL.DOC", which is where I derived my      }
{ routines from.  If there are any routines that you see are not  }
{ implemented here, use FOSSIL.DOC to add/make your own!  I've    }
{ listed enough examples here for you to figure out how to do it  }
{ yourself.                                                       }
{ This file was written as a unit for Turbo Pascal v4.0.  You     }
{ should compile it to DISK, and then in your own program type    }
{ this right after your program heading (before Vars and Types)   }
{ this: "uses IO;"                                                }
{ EXAMPLE: }
{

Program Communications;

uses IO;

begin
  InitializeDriver;
  Writeln ('Driver is initalized!');
  ModemSettings (1200,8,'N',1); Baud := 1200;
  DTR (0); Delay (1000); DTR (1);
  Writeln ('DTR is now true!');
  CloseDriver;
  Writeln ('Driver is closed!');
end.

}

{ Feel free to use these routines in your programs; copy this  }
{ file freely, but PLEASE DO NOT MODIFY IT.  If you do use     }
{ these routines in your program, please give proper credit to }
{ the author.                                                  }
{                                                              }
{ Thanks, and enjoy!                                           }
{                                                              }
{ Tony Hsieh                                                   }




INTERFACE

uses
  DOS;

  { These are communications routines }
  { that utilize a FOSSIL driver.  A  }
  { FOSSIL driver MUST be installed,  }
  { such as X00.SYS and OPUS!COM...   }

type
  String255 = String [255];

var
  Port : Integer;                { I decided to make 'Port' a global    }
                                 { variable to make life easier.        }

  Baud : Word;                   { Same with Baud                       }

  RegistersRecord: Registers;    { DOS registers AX, BX, CX, DX, and Flags }


procedure BlankRegisters;
procedure ModemSettings(Baud, DataBits : Integer; Parity : Char;
                         Stopbits : Integer);
procedure InitializeDriver;
procedure CloseDriver;
procedure ReadKeyAhead (var First, Second : Char);
function  ReceiveAhead (var Character : CHAR) : Boolean;
function  Online : boolean;
procedure DTR(DTRState : Integer);
procedure Reboot;
procedure BiosScreenWrite(Character: CHAR);
procedure WatchDog(INPUT : Boolean);
procedure WhereCursor(var Row : Integer; var Column : Integer);
procedure MoveCursor(Row : Integer; Column : Integer);
procedure KillInputBuffer;
procedure KillOutputBuffer;
procedure FlushOutput;
function  InputAvailable : Boolean;
function  OutputOkay : Boolean;
procedure ReceiveCharacter(var Character : CHAR);
procedure TransmitCharacter(Character : CHAR; var Status : Integer);
procedure FlowControl(Control : Boolean);
procedure CharacterOut(Character : CHAR);
procedure StringOut(Message : String255);
procedure LineOut(Message : String255);
procedure CrOut;


IMPLEMENTATION

procedure BlankRegisters;
begin
  Fillchar(RegistersRecord, SizeOf(RegistersRecord), 0);
end;

procedure ModemSettings (Baud, DataBits : Integer; Parity : Char;
                         StopBits : Integer);
                                               { Do this after initializing }
                                               { the FOSSIL driver and also }
                                               { when somebody logs on      }
var
  GoingOut: Integer;
begin
  GoingOut := 0;
  Case Baud of
      0 : Exit;
    100 : GoingOut := GoingOut + 000 + 00 + 00;
    150 : GoingOut := GoingOut + 000 + 00 + 32;
    300 : GoingOut := GoingOut + 000 + 64 + 00;
    600 : GoingOut := GoingOut + 000 + 64 + 32;
    1200: GoingOut := GoingOut + 128 + 00 + 00;
    2400: GoingOut := GoingOut + 128 + 00 + 32;
    4800: GoingOut := GoingOut + 128 + 64 + 00;
    9600: GoingOut := GoingOut + 128 + 64 + 32;
  end;
  Case DataBits of
    5: GoingOut := GoingOut + 0 + 0;
    6: GoingOut := GoingOut + 0 + 1;
    7: GoingOut := GoingOut + 2 + 0;
    8: GoingOut := GoingOut + 2 + 1;
  end;
  Case Parity of
    'N'    : GoingOut := GoingOut + 00 + 0;
    'O','o': GoingOut := GoingOut + 00 + 8;
    'n'    : GoingOut := GoingOut + 16 + 0;
    'E','e': GoingOut := GoingOut + 16 + 8;
  end;
  Case StopBits of
    1: GoingOut := GoingOut + 0;
    2: GoingOut := GoingOut + 4;
  end;
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 0;
    AL := GoingOut;
    DX := (Port);
    Intr($14, RegistersRecord);
  end;
end;

procedure InitializeDriver;                         { Do this before doing }
begin                                               { any IO routines!!!   }
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 4;
    DX := (Port);
    Intr($14, RegistersRecord);
    If AX <> $1954 then
    begin
      Writeln('* FOSSIL DRIVER NOT RESPONDING!  OPERATION HALTED!');
      halt(1);
    end;
  end;
end;

procedure CloseDriver;  { Run this after all I/O routines are done with }
begin
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 5;
    DX := (Port);
    Intr($14, RegistersRecord);
  end;
  BlankRegisters;
end;

procedure ReadKeyAhead (var First, Second: Char); { This procedure is via  }
                                                  { the FOSSIL driver, not }
                                                  { DOS!                   }
begin
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := $0D;
    Intr($14,RegistersRecord);
    First := chr(lo(AX));
    Second := chr(hi(AX));
  end;
end;

function ReceiveAhead (var Character: CHAR): Boolean;  { Non-destructive }
begin
  If Baud=0 then exit;
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := $0C;
    DX := Port;
    Intr ($14,RegistersRecord);
    Character := CHR (AL);
    ReceiveAhead := AX <> $FFFF;
  end;
end;

function OnLine: Boolean;
begin
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 3;
    DX := (Port);
    Intr ($14, RegistersRecord);
    OnLine := ((AL AND 128) = 128);
  end;
end;

procedure DTR (DTRState: Integer);    { 1=ON, 0=OFF }
                                      { Be sure that the modem dip switches }
                                      { are set properly... when DTR is off }
                                      { it usually drops carrier if online  }
begin
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 6;
    DX := (Port);
    AL := DTRState;
    Intr ($14, RegistersRecord);
  end;
end;

procedure Reboot;                  { For EXTREME emergencies... Hmmm... }
begin
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 23;
    AL := 1;
    Intr ($14, RegistersRecord);
  end;
end;

{       This is ANSI Screen Write via Fossil Driver }
{
procedure ANSIScreenWrite (Character: CHAR);
begin
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 19;
(100 min left), (H)elp, More?     AL := ORD (Character);
    Intr ($14, RegistersRecord);
  end;
end;
}

{ This is ANSI Screen Write via DOS! }

procedure ANSIScreenWrite (Character: CHAR);
begin
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 2;
    DL := ORD (Character);
    Intr ($21, RegistersRecord);
  end;
end;


procedure BIOSScreenWrite (Character: CHAR); { Through the FOSSIL driver }
begin
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 21;
    AL := ORD (Character);
    Intr ($14, RegistersRecord);
  end;
end;

procedure WatchDog (INPUT: Boolean);
begin
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 20;
    DX := Port;
    Case INPUT of
      TRUE:  AL := 1;
      FALSE: AL := 0;
    end;
    Intr ($14, RegistersRecord);
  end;
end;

procedure WhereCursor (var Row: Integer; var Column: Integer);
begin
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 18;
    Intr ($14, RegistersRecord);
    Row := DH;
    Column := DL;
  end;
end;

procedure MoveCursor (Row: Integer; Column: Integer);
begin
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 17;
    DH := Row;
    DL := Column;
    Intr ($14, RegistersRecord);
  end;
end;

procedure KillInputBuffer;   { Kills all remaining input that has not been }
                             { read in yet }
begin
  If Baud=0 then exit;
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 10;
    DX := Port;
    Intr ($14, RegistersRecord);
  end;
end;

procedure KillOutputBuffer;  { Kills all pending output that has not been }
                             { send yet }
begin
  If Baud=0 then exit;
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 9;
    DX := Port;
    Intr ($14, RegistersRecord);
  end;
end;

procedure FlushOutput;       { Flushes the output buffer }
begin
  If Baud=0 then exit;
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 8;
    DX := Port;
    Intr ($14, RegistersRecord);
  end;
end;

function InputAvailable: Boolean;   { Returns true if there's input }
                                    { from the modem.               }
begin
  InputAvailable := False;
  If Baud=0 then exit;
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 3;
    DX := Port;
    Intr ($14, RegistersRecord);
    InputAvailable := ((AH AND 1) = 1);
  end;
end;

function OutputOkay: Boolean;     { Returns true if output buffer isn't full }
begin
  OutputOkay := True;
  If Baud=0 then exit;
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 3;
    DX := Port;
    Intr ($14, RegistersRecord);
    OutputOkay := ((AH AND 32) = 32);
  end;
end;

procedure ReceiveCharacter (var Character: CHAR);   { Takes a character }
                                                    { out of the input  }
                                                    { buffer }
begin
  Character := #0;
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 2;
    DX := Port;
    Intr ($14, RegistersRecord);
    Character := CHR (AL);
  end;
end;

procedure TransmitCharacter (Character: CHAR; var Status: Integer);
begin
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 1;
    DX := Port;
    AL := ORD (Character);
    Intr ($14, RegistersRecord);
    Status := AX;        { Refer to FOSSIL.DOC about the STATUS var }
  end;
end;

procedure FlowControl (Control: Boolean);
begin
  BlankRegisters;
  With RegistersRecord do
  begin
    AH := 15;
    DX := Port;
    Case Control of
         TRUE:  AL := 255;
         FALSE: AL := 0;
    end;
    Intr ($14, RegistersRecord);
  end;
end;

procedure CharacterOut (Character: CHAR);
var
  Status: INTEGER;
begin
  { If SNOOP is on then }
    ANSIScreenWrite (Character);
  TransmitCharacter (Character, Status);
end;

procedure StringOut (Message: String255);
var
  CharPos: Byte;
begin
  CharPos := 0;
  If Length(Message) <> 0 then
  begin
    Repeat
      If NOT Online then exit;
      CharPos := CharPos + 1;
      CharacterOut (Message [CharPos]);
    Until CharPos = Length (Message);
  end;
end;

procedure LineOut (Message: String255);
begin
  StringOut (Message);
  CharacterOut (#13);
  CharacterOut (#10);
end;

procedure CrOut; { Outputs a carriage return and a line feed }
begin
  CharacterOut (#13);
  CharacterOut (#10);
end;

end.

