(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0095.PAS
  Description: Minimal BBS System
  Author: JOHN BALESHISKI
  Date: 02-21-96  21:04
*)

{
3 Files:

PROTCOMM.PAS
IO.PAS
BBS.PAS

[-----------protcomm.pas begins----------------------------------------]
{ Origin - Mark Dignam of Omen Technologies  This unit has been highly modified }

Unit ProtComm;

Interface

Procedure SetBaud (NewRate : LongInt);
Function  GetBaud : LongInt;
Function  Comm_Init (Baud : LongInt;  ThePort : Byte) : Boolean;
Procedure ModemDeInit;
Procedure SetDTR (OnOff : Boolean);
Function  SendReady: Boolean;
Function  Carrier : Boolean;
Function  DataAvailable : Boolean;
Function  GetChar : Byte;
Procedure HangUp;
Function  Ringing : Boolean;
Procedure SendByte (Ch : Char);
Procedure AsyncFlushOutput;
Procedure AsyncPurgeOutput;
Procedure AsyncPurgeInput;
Procedure SendBreak;
Procedure CTS_RTS (OnOff : Boolean);
Procedure AWrite (S : String);
Procedure AWriteLn (S : String);

Var CanUseFossil : Boolean;
    UsedPort     : Byte;

Implementation

Uses Crt, { Borland CRT Routines      }
     Dos; { Borland Disk I/O Routines }

Const MaxPhysPort    = 7;
      BufferSize     = 8196;
      BufferMax      = 8195;
      CommInterrupt  = $14 ;
      I8088_IMR      = $21 ; { port address of the Interrupt Mask Register }
      IBM_UART_THR         = $00 ;
      IBM_UART_RBR         = $00 ;
      IBM_UART_IER         = $01 ;
      IBM_UART_IIR         = $02 ;
      IBM_UART_LCR         = $03 ;
      IBM_UART_MCR         = $04 ;
      IBM_UART_LSR         = $05 ;
      IBM_UART_MSR         = $06 ;
      PortTable  : Array [0..MaxPhysPort] Of Record
        Base : Word;
        IRQ  : Byte
      End = ( (Base : $3F8;  IRQ : 4),
              (Base : $2F8;  IRQ : 3),
              (Base : $3E8;  IRQ : 4),
              (Base : $2E8;  IRQ : 3),
              (Base : 0;  IRQ : 0),
              (Base : 0;  IRQ : 0),
              (Base : 0;  IRQ : 0),
              (Base : 0;  IRQ : 0));

Var BIOS_Ports, IRQ                             : Byte;
    Old_IER, Old_IIR, Old_LCR, Old_MCR, Old_IMR : Byte;
    ExitSave, OriginalVector                    : Pointer;
    IsOpen, OverFlow, UseFossil, CTS_RTS_On     : Boolean;
    Base, BufferHead, BufferTail, BufferNewTail : Word;
    Status, RxWord, CtsTimer                    : Word;
    Buffer                                      : Array [0..BufferMax] Of
Byte;    Regs                                        : Registers;

Procedure Comm_SetBios (NewRate : LongInt);
Var BaudRate    : Byte;
    Temp0       : Integer;
Begin
  {$IFNDEF TEST}
  Temp0 := NewRate Div 10;
  Case Temp0 of
      30 : BaudRate := $43;
      60 : BaudRate := $63;
     120 : BaudRate := $83;
     240 : BaudRate := $A3;
     480 : BaudRate := $C3;
     960 : BaudRate := $E3;
    1920 : BaudRate := $03;
    3840 : BaudRate := $23;
    5760 : BaudRate := $23;
  End;
  Regs.AH := 0;
  Regs.AL := BaudRate;
  Regs.DX := UsedPort;
  Intr ($14, Regs);
  {$ENDIF}
End;

Procedure Comm_SetDirect (NewRate : LongInt);
Var I, J, K : Word;
    Temp    : LongInt;
Begin
  {$IFNDEF TEST}
  Temp := 115200;
  Temp := Temp DIV Newrate;
  Move (Temp, J, 2);
  K := Port [IBM_UART_LCR + Base];
  port [IBM_UART_LCR + Base] := $80;
  Port [IBM_UART_THR + Base] := Lo (J);
  Port [IBM_UART_IER + Base] := Hi (J);
  Port [IBM_UART_LCR + Base] := 3;
  {$ENDIF}
End;

Procedure SetBaud (NewRate : LongInt);
Begin
  {$IFNDEF TEST}
  If UseFossil Then Comm_SetBios (NewRate) Else Comm_SetDirect (NewRate);
  {$ENDIF}
End;

Function Getbaud : LongInt;
Var I, J, K : Word;
    Temp    : LongInt;
begin
  {$IFNDEF TEST}
  K := Port [ibm_UART_LCR + Base];
  Port [IBM_UART_LCR + Base] := K OR $80;
  i := Port [IBM_UART_THR + Base];
  J := Port [IBM_UART_IER + Base];
  J := J * $100;
  J := J + I;
  Port [IBM_UART_LCR + base] := k;
  Temp := 115200;
  Temp := Temp DIV J;
  GetBaud := Temp;
  {$ELSE}
  GetBaud := 4800;
  {$ENDIF}
End;

Function Carrier : Boolean;
Begin
  {$IFNDEF TEST}
  Carrier := Port [IBM_UART_MSR + Base] AND $80 = $80;
  {$ELSE}
  Carrier := False;
  {$ENDIF}
End;

Procedure DisableInterrupts;  Inline ($FA);
Procedure EnableInterrupts;   Inline ($FB);

Procedure ISR;  Interrupt;
Begin
  {$IFNDEF TEST}
  Inline(
    $FB/                                { sti                           }
    {Start:                                                             }
    { get the incoming character                                        }
    { Buffer[BufferHead] := chr(port[base + ibm_uart_rbr]);             }
    $8B/$16/Base/                       { mov dx,Base                   }
    $EC/                                { in al,dx                      }
    $8B/$1E/BufferHead/                 { mov bx,BufferHead             }
    $88/$87/Buffer/                     { mov Buffer[bx],al             }
    { BufferNewHead := Succ (BufferHead);                               }
    $43/                                { inc bx                        }
    { if BufferNewHead > BufferMax then BufferNewHead := 0 ;            }
    $81/$FB/BufferMax/                  { cmp bx,BufferMax              }
    $7E/$02/                            { jle l001                      }
    $33/$DB/                            { xor bx,bx                     }
    { if BufferNewHead = BufferTail then Overflow := true               }
    {L001:                                                              }
    $3B/$1E/BufferTail/                 { cmp bx,BufferTail             }
    $75/$07/                            { jne L002                      }
    $C6/$06/Overflow/$01/               { mov overflow,1                }
    $EB/$0E/                            { jmp short L003                }
    { ELSE BEGIN                                                        }
    {   BufferHead := BufferNewHead;                                    }
    {   Async_BufferUsed := succ(Async_BufferUsed);                     }
    {   IF Async_BufferUsed > Async_MaxBufferUsed then                  }
    {     Async_MaxBufferUsed := Async_BufferUsed                       }
    {   END ;                                                           }
    {L002:                                                              }
    $89/$1E/BufferHead/                 { mov BufferHead,bx             }
    $83/$C2/$05/                        { Add dx,5                      }
    { Check FIFO - And process if more bytes.                           }
    $EC/                                { In al,dx                      }
    $24/$01/                            { And al,$01                    }
    $3C/$01/                            { cmp al,$01                    }
    $74/$CF/                            { je start:                     }
    {L003:                                                              }
    $FA/                                { cli                           }
    { issue non-specific EOI                                            }
    { port[$20] := $20 ;                                                }
    $B0/$20/                            { mov al,20h                    }
    $E6/$20);                           { out 20h,al                    }
  {$ENDIF}
End;

Procedure Async_Close;
Begin
  {$IFNDEF TEST}
  If IsOpen Then
  Begin
    DisableInterrupts;
    Port [I8088_IMR] := (Port[I8088_IMR] OR (1 SHL IRQ));
    Port [IBM_UART_IER + Base] := Old_IER;
    EnableInterrupts;
    Port [IBM_UART_MCR + Base] := Old_MCR;
    Port [IBM_UART_LCR + Base] := Old_lCR;
    SetIntVec (IRQ + 8, OriginalVector);
    IsOpen := False;
  End;
  {$ENDIF}
End;

Function Init_fossil (Baud : LongInt;  ThePort : Byte) : Boolean;
Begin
  {$IFNDEF TEST}
  UsedPort := ThePort - 1;
  Regs.AH := 4;
  Regs.DX := UsedPort;
  Intr ($14, Regs);
  If Regs.AX <> $1954 Then Init_Fossil := False Else
  Begin
    Init_Fossil := True;
    UseFossil := True;
    SetBaud (Baud);
  End;
  {$ELSE}
  Init_Fossil := True;
  {$ENDIF}
End;

Function Async_Open(Baud : Longint; LogicalPortNum: byte): boolean;
Var I, OldIIR        : Byte;
    Fifos, PortThere : Boolean;
Begin
  {$IFNDEF TEST}
  If Not IsOpen Then
  Begin
    BufferHead := 0;
    BufferTail := 0;
    Overflow := False;
    UsedPort := Pred (LogicalPortNum);
    Fifos := False;
    IsOpen := False;
    If PortTable [UsedPort].Base <> 0 Then
    Begin
      Base := PortTable [UsedPort].Base;
      IRQ := PortTable [UsedPort].IRQ;
      Old_IER := Port [IBM_UART_IER + Base];
      Old_MCR := Port [IBM_UART_MCR + Base];
      Old_LCR := Port [IBM_UART_LCR + Base];
      Port [IBM_UART_LCR + Base] := $75;
      PortThere := (Port [IBM_UART_LCR + Base] = $75);
      Port [IBM_UART_LCR + Base] := $3;
      If PortThere Then
      Begin
        Comm_SetDirect (Baud);
        Port [IBM_UART_MCR + Base] := $0B;
        OldIIR := Port [IBM_UART_IIR + Base];
        Port [IBM_UART_IIR + Base] := 1;
        Fifos := (Port [IBM_UART_IIR + Base] AND $C0 = $C0);
        If Not Fifos Then Port [IBM_UART_IIR + Base] := OldIIR;
        GetIntVec (IRQ + 8, OriginalVector);
        SetIntVec (IRQ + 8, @ISR);
        DisableInterrupts;
        Port [I8088_IMR] := (Port [I8088_IMR] AND ((1 SHL IRQ) XOR $FF));
        Port [IBM_UART_IER + Base] := 1;
        EnableInterrupts;
        IsOpen := True;
      End;
    End;
  End;
  Async_Open := IsOpen
  {$ELSE}
  Async_Open := True;
  {$ENDIF}
End;

{$F+}
Procedure TerminateUnit;
{$F-}

Begin
  Async_Close;
  ExitProc := ExitSave
End;

Function Comm_init (Baud : Longint; ThePort : Byte) : Boolean;
Begin
  {$IFNDEF TEST}
  UseFossil := False;
  If Not IsOpen Then
  Begin
    If (CanUseFossil) AND (Init_Fossil (Baud, ThePort)) Then
    Begin
      Comm_Init := True;
      IsOpen := True;
      Base := PortTable [UsedPort].Base;
    End Else
    Begin
      If Async_Open (Baud, ThePort) Then
      Begin
        Comm_Init := true;
        IsOpen := True;
      End Else Comm_Init := False;
    End;
  End;
  UsedPort := ThePort;
  {$ELSE}
  Comm_Init := True;
  {$ENDIF}
End;

Function DataAvailable : Boolean;
Var AHigh : Byte;
Begin
  {$IFNDEF TEST}
  If UseFossil Then
  Begin
    Inline ($B4/$03/            { MOV AH, 3        }
            $8b/$16/UsedPort/   { MOV DX, Usedport }
            $cd/$14/            { INT 14h          }
            $a3/Status);        { MOV [Status], AL }
    DataAvailable := ((Status AND $100) <> 0);
  End Else DataAvailable := (Bufferhead <> BufferTail);
  {$ELSE}
  DataAvailable := False;
  {$ENDIF}
End;

Procedure ModemDeInit;
Begin
  {$IFNDEF TEST}
  If IsOpen Then
  Begin
    If UseFossil Then
    Begin
      Regs.AH := 5;
      Regs.DX := UsedPort;
      Intr ($14, Regs);
    End Else Async_Close;
    IsOpen := False;
  End;
  {$ENDIF}
End;

Function GetChar : byte;
Begin
  {$IFNDEF TEST}
  If UseFossil Then
  Begin
    Inline ($B4/$02/            { MOV AH, 3        }
            $8b/$16/UsedPort/   { MOV Dx, Usedport }
            $CD/$14/            { INT 14h          }
            $A3/RXWord);        { Mov [Status], AL }
    GetChar := Lo (RXWord);
  End Else
  Begin
    GetChar := Buffer [BufferTail] ;
    BufferTail := (Succ (BufferTail) MOD BufferSize) ;
  End;
  {$ENDIF}
End;

Function SendReady : boolean;
Var Ahigh          : Byte;
    Carr, CTS, THR : boolean;
Begin
  {$IFNDEF TEST}
  If UseFossil Then
  Begin
    Inline ($B4/$03/            { MOV AH, 3        }
            $8B/$16/UsedPort/   { MOV DX, Usedport }
            $CD/$14/            { INT 14h          }
            $A3/Status);        { MOV Status, AX   }
    THR  := (Status AND $2000) <> 0;
    Carr := (Status AND $0080) <> 0;
    SendReady := THR OR (Not Carr);

  End Else
  Begin
    THR := ((Port [IBM_UART_LSR + Base] AND $20) <> 0);
    CTS :=  (Port [IBM_UART_MSR + Base] AND $10 = $10);
    If CTS_RTS_On AND Carrier Then SendReady := THR AND Cts Else SendReady :=
THR;  End;
  {$ELSE}
  SendReady := False;
  {$ENDIF}
End;

Procedure SendByte (Ch : Char);
Begin
  {$IFNDEF TEST}
  Repeat Until SendReady;
  If UseFossil then
  Begin
    Regs.AH := 1;
    Regs.AL := Ord (Ch);
    Regs.DX := UsedPort;
    intr($14,regs);
  End Else Port [IBM_UART_THR + Base] := Ord (Ch);
  {$ENDIF}
End;

Procedure AsyncFlushOutput;
Begin
  {$IFNDEF TEST}
  If Usefossil Then
  Begin
    Regs.AH := 8;
    Regs.DX := UsedPort;
    Intr ($14, Regs);
  End;
  {$ENDIF}
End;


Procedure AsyncPurgeOutput;
Begin
  {$IFNDEF TEST}
  If UseFossil Then
  Begin
    Regs.AH := 9;
    Regs.DX := UsedPort;
    Intr ($14, Regs);
  End;
  {$ENDIF}
End;

Procedure AsyncPurgeInput;
Begin
  {$IFNDEF TEST}
  If UseFossil then
  Begin
    Regs.AH := $0A;
    Regs.DX := UsedPort;
    Intr ($14, Regs);
  End Else
  Begin
    BufferHead := 0;
    BufferTail := 0;
    OverFlow   := False;
  End;
  {$ENDIF}
End;

Procedure SendBreak;
Var I, J : Byte;
Begin
  {$IFNDEF TEST}
  If UseFossil then
  Begin
    Regs.AX := $1A01;
    Regs.DX := UsedPort;
    Intr ($14, Regs);
    Delay (100);
    Regs.AX := $1A00;
    Regs.DX := UsedPort;
    Intr ($14, Regs);
  End Else
  Begin
    I := Port [IBM_UART_LCR + Base];
    J := I;
    I := I AND $7F;
    I := I OR $40;
    Port [IBM_UART_LCR + Base] := I;
    delay (100);
    Port [IBM_UART_LCR + Base] := J;
  End;
  {$ENDIF}
End;

Procedure SetDTR (OnOff : Boolean);
Var I : Byte;
Begin
  {$IFNDEF TEST}
  If UseFossil then
  Begin
    Regs.AH := $06;
    If OnOff Then Regs.AL := 1 Else Regs.AL := 0;
    Regs.DX := UsedPort;
    Intr ($14, Regs);
  End Else
  Begin
    If OnOff Then Port [IBM_UART_MCR + Base] := $0B Else Port [IBM_Uart_MCR +
Base] := $0A;  End;
  {$ENDIF}
End;

Procedure CTS_RTS (OnOff : Boolean);
Begin
  {$IFNDEF TEST}
  If UseFossil Then
  Begin
    Regs.DX := UsedPort;
    If OnOff Then Regs.AL := 2 Else Regs.AL := 0;
    Regs.AH := $0F;
    Intr ($14, Regs);
  End Else CTS_RTS_On := OnOff;
  {$ENDIF}
End;

Procedure AWrite (S : String);
Var I : Integer;
Begin
  {$IFNDEF TEST}
  For I := 1 To Length (S) Do SendByte ((S[I]));
  {$ENDIF}
End;

Procedure AWriteLn (S : String);
Begin
  {$IFNDEF TEST}
  AWrite (S + #10#13);
  {$ENDIF}
End;

Function Ringing : Boolean;
Begin
  {$IFNDEF TEST}
  Case UsedPort of
    1 : Ringing := Boolean (Port[$3FE] And 64);
    2 : Ringing := Boolean (Port[$2FE] And 64);
    3 : Ringing := Boolean (Port[$3EE] And 64);
    4 : Ringing := Boolean (Port[$2EE] And 64);
    Else Ringing := False;
  End;
  {$ELSE}
  Ringing := False;
  {$ENDIF}
End;

Procedure Hangup;
Begin
  {$IFNDEF TEST}
  SetDTR (False);
  Delay (250);
  SetDTR (True);
  {$ENDIF}
End;

Begin
  {$IFNDEF TEST}
  ExitSave := ExitProc;
  ExitProc := @TerminateUnit;
  IsOpen   := FALSE;
  Overflow := FALSE;
  CanUseFossil := False;
  CTS_RTS_On := True;
  Bios_Ports := 4;
  {$ENDIF}
End.

[-----------protcomm.pas ends -------------------------------------------------]
[-----------io.pas begins-----------------------------------------------------]
Unit IO;

Interface

Procedure SWrite         (S : String);
Procedure SWriteLn       (S : String);
Procedure SReadLn        (Var S : String);
Procedure SClrScr;

Var Local : Boolean;

Implementation

Uses Crt, ProtComm;

Procedure SWrite (S : String);
Begin
  Write (S);
  If Not Local Then AWrite (S);
End;

Procedure SWriteLn (S : String);
Begin
  WriteLn (S);
  If Not Local Then AWriteLn (S);
End;

Function SReadKey : Char;
Var Done : Boolean;
    Ch   : Char;
Begin
  Done := False;
  Repeat
    If (Not Local) and (Not Carrier) Then Done := True;
    If Not Local Then
    If DataAvailable Then
    Begin
      Ch := Chr (GetChar);
      Done := True;
    End;
    If KeyPressed Then
    Begin
      Ch := ReadKey;
      Done := True;
    End;
  Until Done;
  SReadKey := Ch;
End;

Function SKeyPressed : Boolean;
Begin
  SKeyPressed := False;
  If DataAvailable Then SKeyPressed := True;
  If KeyPressed Then SKeyPressed := True;
End;

Procedure SReadLn (Var S : String);
Var Ch : Char;
Begin
  S := '';
  Repeat
    Ch := SReadKey;
    If Ord (Ch) in [32..122] Then
    Begin
      S := S + Ch;
      SWrite (Ch);
    End;
    If Ord (Ch) = Ord (8) Then
    Begin
      If Length (S) > 0 Then
      Begin
        SWrite (#8' '#8);
        Delete (S, Length (S), 1);
      End;
    End;
  Until (Ord (Ch) = 13) OR ((Not Carrier) AND (Not Local));
  SWrite (#13#10);
End;

Procedure SClrScr;
Begin
  SWriteLn (#12);
  ClrScr;
End;

End.
[-----------io.pas ends-------------------------------------------------]
[-----------bbs.pas begins ---------------------------------------------]
{ Minimal BBS - part of the Communications Package of HTCPACK #7
  For more information or for information on where to obtain complete
HTCPACK's  email havoc.the.chaos@iirg.com }

Uses Crt, IO, ProtComm;

Var TestPad : String;
    OutChar : Char;

Procedure RunBBS;
Var Answer : String;
Begin
  SWriteLn ('Welcome to the minimal BBS!');
  SWrite ('Type somethin: ');
  SReadLn (Answer);
  SWriteLn ('You typed "' + Answer + '"');
  Delay (5000);
  SWriteLn ('Goodbye!');
  AsyncFlushOutput;
  Hangup;
End;

Procedure FrontEnd;
Var EscPressed : Boolean;
    ModemString : String;
    Timer : Integer;
    Ch : Char;
Begin
  If Not Local Then AWriteLn ('ATA');
  ClrScr;
  WriteLn ('*** RING ***'#7);
  ModemString := '';
  EscPressed := False;
  If Not Local Then
  Begin
    AsyncPurgeInput;
    Timer := 0;
    EscPressed := False;
    Repeat
      ModemString := '';
      While DataAvailable Do ModemString := ModemString + Chr (GetChar);
      Delay (1);
      Inc (Timer);
      If KeyPressed Then
      Begin
        Ch := ReadKey;
        If Ord (Ch) = Ord (27) Then EscPressed := True;
      End;
    Until (Carrier) or (Timer = 60000) or (Local) or (EscPressed);
  End;
  If EscPressed OR (Timer = 60000) Then
  Begin
    ClrScr;
    AWriteLn ('');
    Write ('Connection not established due to ');
    If EscPressed Then WriteLn ('local escape.');
    If Timer = 60000 Then WriteLn ('a 60 time elapse with no connection.');
    Delay (2000);
    Exit;
  End;
  If Carrier OR Local Then
  Begin
    While KeyPressed Do Write (ReadKey, #8);
    AsyncPurgeInput;
    RunBBS;
  End;
End;

Procedure Initialize;
Begin
  Comm_Init (57600, 2);
  ClrScr;
  Local := False;
  AsyncPurgeInput;
  While DataAvailable Do Write (Chr (GetChar));
  If Not Carrier Then AWriteLn ('ATZ');
End;

Begin
  Initialize;
  Repeat
    TestPad := '';
    While DataAvailable Do
    Begin
      TestPad := TestPad + Chr (GetChar);
    End;
    TestPad := '';
    If Ringing Then
    Begin
      Local := False;
      FrontEnd;
    End;
    If KeyPressed Then
    Begin
      OutChar := ReadKey;
      Case Ord (OutChar) of
         0 : Begin
               OutChar := ReadKey;
               Case Ord (OutChar) of
{F1}             59 : Begin
                        Local := True;
                        FrontEnd;
                      End;
{ALT-X}          45 : Begin
                        ModemDeInit;
                        Halt;
                      End;
               End;
             End;
      End;
    End;
  Until 1 = 2;
End.

[-----------bbs.pas ends-------------------------------------------------]

