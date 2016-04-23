
(*    ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
      █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█
      █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█
      █░░░░░░░█████████████████████████████████████████████░░░░░░░░░░░░░█
      █░░░░░░░██                                         ██ ░░░░░░░░░░░░█
      █░░░░░░░██ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██ ░░░░░░░░░░░░█
      █░░░░░░░██ ░░░░░░░██████░░░░███████░░░███████░░██░░██ ░░░░░░░░░░░░█
      █░░░░░░░███████░░█      █░░░█       ░░█       ░██ ░██ ░░░░░░░░░░░░█
      █░░░░░░░██      ░█ ░░░░░█ ░░███████ ░░███████ ░██ ░██ ░░░░░░░░░░░░█
      █░░░░░░░██ ░░░░░░█ ░░░░░█ ░░░     █ ░░░     █ ░██ ░██ ░░░░░░░░░░░░█
      █░░░░░░░██ ░░░░░░░██████  ░░███████ ░░███████ ░██ ░████████░░░░░░░█
      █░░░░░░░░  ░░░░░░░░      ░░░░       ░░░       ░░  ░         ░░░░░░█
      █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█
      █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█
      ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
   ■  FIDO/OPUS/SEADOG/Standard Interface Layer  ■           Version 1.02

      Interface for X00 and BNU Fossil Driver(s)

      Written by: Mike Whitaker  *)

{$R-,S-,I-,D-,F+,V-,B-,N-}

Unit Fossil;

Interface

Uses Dos, Crt;

Const  CTS_RTS  = 2;    { To Control Flow Control }
       XON_XOFF = 9;

Type Fossil_Struct = Record
       StructSize : Word;
       MajorVer   : Byte;
       MinVer     : Byte;
       FOS_ID     : Array [1..2] of Word;
       Inp_Buffer : Word;
       Recv_Bytes : Word;
       Out_Buffer : Word;
       Send_Bytes : Word;
       SWidth     : Byte;
       SHeight    : Byte;
       BaudRate   : Byte
     End;

Var FosPort  : Byte;


Function  Install_Fossil (ComPort:Byte):Boolean;
Procedure Close_Fossil (ComPort:Byte);
Procedure Set_Fossil (ComPort:Byte; BaudRate:LongInt; DataBits:Byte;
                     Parity:Char; StopBits:Byte);
Procedure SendChar (K:Char);
Procedure SendString (S:String);
Function  GetChar:Char;
Function  Fossil_Chars:Boolean;
Function  Fossil_Carrier:Boolean;
Procedure Fossil_DTR (ComPort:Byte; State:Boolean);
Procedure Hangup;
Procedure Fossil_Timer (Var Tick_Int, Ints_Sec:Byte; MS_Tics:Integer);
Procedure Fossil_OutPut_FLUSH (ComPort:Byte);
Procedure Fossil_Nuke_Input   (ComPort:Byte);
Procedure Fossil_Nuke_OutPut  (ComPort:Byte);
Function  NoWait_Send (K:Char):Boolean;
Function  Fossil_Peek:Char;
{Function  Fossil_GetChar:Char;}
Function  Fossil_Wait:Char;
Procedure Fossil_FLOW (State:Byte);
Procedure Set_CtrlC (ComPort, State:Byte);
Function  CtrlC_Check (ComPort:Byte):Boolean;
Procedure Fossil_GotoXY (X,Y:Byte);
Procedure Fossil_Position (Var X,Y:Byte);
Function  Fossil_WhereX:Byte;
Function  Fossil_WhereY:Byte;
Procedure ANSI_Write (K:Char);
Procedure WatchDog (Status:Boolean);
Procedure BIOS_Write (K:Char);
Function  Add_Fossil_Proc    (Var P):Boolean;
Function  Delete_Fossil_Proc (Var P):Boolean;
Procedure WarmBoot;
Procedure ColdBoot;
Function  Fossil_BlockRead  (Bytes:Word; Var Buffer):Integer;
Function  Fossil_BlockWrite (Bytes:Word; Var Buffer):Integer;
Function  Fossil_Descrip (ComPort:Byte):String;
Function  Fos_Ringing: Boolean;
Implementation



Var R:Registers;

Procedure Delay (I:Integer);
Begin
  R.Ah := $86;
  Move (I,R.Cx,2);
  Intr ($15,R)
End;

Function Install_Fossil (ComPort:Byte):Boolean;
Begin                                   { Initializes the Specified  }
  R.Ah := $04;                          { Communications Port        }
  R.Dx := ComPort - 1;                  { Sets FOSPORT to COMPORT    }
  R.Bx := $4F50;
  Intr ($14,R);
  Install_Fossil := R.Ax = $1954;
  FosPort := ComPort - 1
End;

Procedure Close_Fossil (ComPort:Byte);  { Closes the Initialized     }
Begin                                   { Communications Port        }
  R.Ah := $05;
  R.Dx := ComPort - 1;
  Intr ($14,R);
  FosPort := 255
End;


Procedure Set_Fossil (ComPort:Byte; BaudRate:LongInt; DataBits:Byte;
                      Parity:Char; StopBits:Byte);
Var Baud,Code:Byte;                     { Sets the to the COMPORT    }
Begin                                   { The BaudRate, DataBits,    }
  Case BaudRate of                      { The Parity, And StopBits   }
   1200  : Baud := 128;                 { Sets FOSPORT to COMPORT    }
   2400  : Baud := 160;
   4800  : Baud := 192;
   9600  : Baud := 224;
   19200 : Baud := 0
   Else If BaudRate = 38400 Then Baud := 32
  End;
  Case DataBits of
 { 5 : Baud := Baud + 0; }
   6 : Baud := Baud + 1;
   7 : Baud := Baud + 2;
   8 : Baud := Baud + 3
  End;
  Case Parity of
 { 'N' : Baud := Baud + 0; }
   'O' : Baud := Baud + 8;
   'E' : Baud := Baud + 24
  End;
  Case StopBits of
   1 : Baud := Baud + 0;
   2 : Baud := Baud + 4
  End;
  R.Ah := 0;
  R.Al := Baud;
  R.Dx := ComPort - 1;
  Intr ($14,R);
  FosPort := ComPort - 1
End;

Function Fos_Ringing: Boolean;
var
  CC : Char;
begin
  Fos_Ringing := False;
  R.Ah := $0C;
  R.Dx := fosport;
  Intr($14, R);
  if r.ax = $FFFF then
    Fos_ringing := false
  else
  begin
    cc := chr(r.al);
    if cc = #13 then
      Fos_ringing := true;
  end;
end;



Procedure SendChar (K:Char);            { Transmitts a Character     }
Begin                                   { through FOSPORT Comm Port  }
  R.Ah := $01;                          { and then Waits.            }
  R.Al := Ord(K);
  R.Dx := FosPort;
  Intr ($14,R)
End;


Procedure SendString (S:String);        { Sends a String through the }
Var I:Integer;
Begin
  I:=Fossil_BlockWrite (Length(S),S)
End;


Function GetChar:Char;                  { Gets a Character from the  }
Begin                                   { FOSPORT Communications Port}
  R.Ah := $02;
  R.Dx := FosPort;
  Intr ($14,R);
  GetChar := Chr(R.Al)
End;

Function Fossil_Chars:Boolean;
Begin
  R.Ah := $03;
  R.Dx := FosPort;
  Intr ($14,R);
  Fossil_Chars := (R.Ah And 1) = 1
End;

Function Fossil_Carrier:Boolean;        { Detects whether a Carrier  }
Begin                                   { is on FOSPORT Port         }
  R.Ah := $03;
  R.Dx := FosPort;
  Intr ($14,R);
  Fossil_Carrier := (R.Al And 128) = 128
End;

Procedure Fossil_DTR (ComPort:Byte; State:Boolean);
Begin                                   { Lowers/Raises the DTR on   }
  R.Ah := $06;                          { COMPORT                    }
  R.Al := Byte(State);
  R.Dx := ComPort - 1;
  Intr ($14,R)
End;


Procedure Hangup;
Begin
  If Not Fossil_Carrier Then Exit;
  Fossil_DTR (FosPort + 1,False);
  Delay (700);
  Fossil_DTR (FosPort + 1,True);
  If Fossil_Carrier Then SendString ('+++')
End;

Procedure Fossil_Timer (Var Tick_Int, Ints_Sec:Byte; MS_Tics:Integer);
Begin
  R.Ah := $07;
  Intr ($14,R);
  Tick_Int := R.Al;
  Ints_Sec := R.Ah;
  MS_Tics  := R.Dx
End;


Procedure Fossil_OutPut_FLUSH (ComPort:Byte);
Begin                                   { Forecs the OutPut Chars    }
  R.Ah := $08;                          { out of the Buffer          }
  R.Dx := ComPort - 1;
  Intr ($14,R)
End;

Procedure Fossil_Nuke_OutPut (ComPort:Byte);
Begin                                   { Purges the OutPut Buffer   }
  R.Ah := $09;
  R.Dx := ComPort - 1;
  Intr ($14,R)
End;

Procedure Fossil_Nuke_Input (ComPort:Byte);
Begin                                   { Purges the Input Buffer    }
  R.Ah := $0A;
  R.Dx := ComPort - 1;
  Intr ($14,R)
End;

Function NoWait_Send (K:Char):Boolean;
Begin
  R.Ah := $0B;
  R.Al := Ord(K);
  R.Dx := FosPort;
  Intr ($14,R);
  NoWait_Send := Boolean(R.Ax)
End;

Function Fossil_Peek:Char;              { Checks out what the Next   }
Begin                                   { Character is in FOSPORT    }
  R.Ah := $0C;                          { Without Taking it out of   }
  R.Dx := FosPort;                      { the Bufffer                }
  Intr ($14,R);
  Fossil_Peek := Chr(R.Al)
End;

Function Fossil_GetChar:Char;         { Gets Character from Input Buffer }
Begin                                 { $FFFF if none: HIGH Byte is Scan }
  R.Ah := $0D;                        { code                             }
  R.Dx := FosPort;
  Intr ($14,R);
  Fossil_GetChar := Chr(R.Al)
End;

Function Fossil_Wait:Char;            { Waits until a Character has been }
Begin                                 { Receieved                        }
  R.Ah := $0E;
  R.Dx := FosPort;
  Intr ($14,R);
  Fossil_Wait := Chr(R.Al)
End;

Procedure Fossil_FLOW (State:Byte);   { Sets Flow Control    }
Begin                                 { 0 = Disabled         }
  R.Ah := $0F;                        { Bit 0 & 3 = XON/XOFF } { Chars }
  R.Al := State;                      { Bit 1     = CTS/RTS  } { Signals * }
  R.Dx := FosPort;                    { Call using the defined Constants }
  Intr ($14,R)
End;


Procedure Set_CtrlC (ComPort,State:Byte);
Begin
  R.Ah := $10;
  R.Al := State;
  R.Dx := ComPort - 1;
  Intr ($14,R)
End;

Function CtrlC_Check (ComPort:Byte):Boolean;
Begin
  R.Ah := $10;
  R.Al := 2;
  R.Dx := ComPort - 1;
  Intr ($14,R);
  CtrlC_Check := Boolean(R.Ax)
End;

Procedure Fossil_GotoXY (X,Y:Byte);
Begin
  R.Ah := $11;
  R.Dh := Y - 1;
  R.Dl := X - 1;
  Intr ($14,R)
End;

Procedure Fossil_Position (Var X,Y:Byte);
Begin
  R.Ah := $12;
  Intr ($14,R);
  X := R.Dl + 1;
  Y := R.Dh + 1
End;

Function Fossil_WhereX:Byte;
Begin
  R.Ah := $12;
  Intr ($14,R);
  Fossil_WhereX := R.Dl + 1
End;

Function Fossil_WhereY:Byte;
Begin
  R.Ah := $12;
  Intr ($14,R);
  Fossil_WhereY := R.Dh + 1
End;

Procedure ANSI_Write (K:Char);        { Projects Character to Screen   }
Begin                                 { through ANSI.SYS               }
  R.Ah := $13;
  R.Al := Ord(K);
  R.Dx := FosPort;
  Intr ($14,R)
End;

Procedure WatchDog (Status:Boolean);  { Sets WatchDOG = ON/OFF        }
Begin                                 { If ON then Reboots on Carrier }
  R.Ah := $14;                        { Loss!                         }
  R.Al := Byte(Status);
  R.Dx := FosPort;
  Intr ($14,R)
End;

Procedure BIOS_Write (K:Char);        { Writes a Character to the     }
Begin                                 { Screen Using BIOS Screen Write}
  R.Ah := $15;
  R.Al := Ord(K);
  R.Dx := FosPort;
  Intr ($14,R)
End;

Function Add_Fossil_Proc (Var P):Boolean;
Begin
  R.Ah := $16;
  R.Al := $01;
  R.ES := Seg (P);
  R.DX := Ofs (P);
  Intr ($14,R);
  Add_Fossil_Proc := R.Ax = 0
End;

Function Delete_Fossil_Proc (Var P):Boolean;
Begin
  R.Ah := $16;
  R.Al := $00;
  R.ES := Seg (P);
  R.DX := Ofs (P);
  Intr ($14,R);
  Delete_Fossil_Proc := R.Ax = 0
End;

Procedure ColdBoot;                   { Does a Cold Reboot            }
Begin
  R.Ah := $17;
  R.Al := $00;
  Intr ($14,R)
End;

Procedure WarmBoot;                   { Does a Warm Reboot            }
Begin
  R.Ah := $17;
  R.Al := $01;
  Intr ($14,R)
End;

Function Fossil_BlockRead (Bytes:Word; Var Buffer):Integer;
Begin                                 { BUFFER is an Array, and BYTES is  }
  R.Ah := $18;                        { the size of the Array.            }
  R.Dx := FosPort;                    { It Returns the number of recieved }
  R.Cx := Bytes;                      { Characters.                       }
  R.ES := Seg (Buffer);
  R.DI := Ofs (Buffer);
  Intr ($14,R);
  Fossil_BlockRead := R.Ax
End;

Function Fossil_BlockWrite (Bytes:Word; Var Buffer):Integer;
Begin                                 { Writes an Array of BYTES Chars    }
  R.Ah := $19;                        { to the FOSPORT from BUFFER        }
  R.Dx := FosPort;                    { Returns the number of characters  }
  R.Cx := Bytes;                      { sent.                             }
  R.ES := Seg (Buffer);
  R.DI := Ofs (Buffer);
  Intr ($14,R);
  Fossil_BlockWrite := R.Ax
End;


Function Fossil_Descrip (ComPort:Byte):String;
Var Cnt:Integer;                      { Returns the Communications FOSSIL }
    Fos_Arry:Fossil_Struct;           { Driver Utilizing the COMPORT      }
    First,Second:Word;                { Communications Port               }
    Kar:Char;                         { Returns the FOSSIL Driver         }
    S:String;                         { Description.                      }
Begin
  R.Ah := $1B;
  R.Dx := ComPort - 1;
  R.ES := Seg (Fos_Arry);
  R.DI := Ofs (Fos_Arry);
  R.CX := SizeOf (Fos_Arry);
  Intr ($14,R);
  First  := Fos_Arry.FOS_ID[2];
  Second := Fos_Arry.FOS_ID[1];
  S   := '';
  Kar := #26;
  While Kar <> #0 Do Begin
    Kar:=Chr (Mem[First:Second]);
    S := S + Kar;
    Second:=Second + 1
  End;
  Fossil_Descrip:=S
End;

Begin
End.
