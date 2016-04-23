{
Your SWAG Collection is really good and should help programmers
enourmously. I myself have learned much from SWAG. Thanks to All!

Here is Attached one FOSSIL unit that implements almost all FOSSIL rev 5
functions in both real and protected mode. I have used it almost a year
now and the real mode operation should be free from bugs, but I added
DPMI support lately so there might be some errors. If someone finds an
error or would like to have some more information then I can be
contacted by e-mail at the following address : raul@reveko.estnet.ee
I have program which uses turbo vision and currently works with four com
ports active at the same time. I use BOCA Research Inc. multiport card
and X00 fossil driver because it supports IRQ Sharing. If I complete the
testing of my own async routines then I hope I will post it too If You
don't mind. Sorry for no documentation but all functions should easy to
understand.
  Thanks again.
  Raul Rebane.
}

UNIT COMFOSS;

{$C FIXED PRELOAD PERMANENT}

{$IFDEF WINDOWS}
  This Unit Cannot be compiled to windows
{$ENDIF}

INTERFACE

CONST
     CTS_RTS          = 2;   {FOSSIL RTS/CTS Flow control value }
     RECV_XON_XOFF    = 1;   {FOSSIL XOn/XOff on receive        }
     SEND_XON_XOFF    = 8;   {FOSSIL XOn/XOff on transmit       }
     XON_XOFF	      = 9;   {FOSSIL Full XOn/XOff flow Control }
     Flow_NONE        = 1;   {No Flow control CheckBox value    }
     Flow_XONXOFF     = 2;   {XOn/XOff Flow Control CheckBox    }
     Flow_RTSCTS      = 4;   {RTS/CTS Flow Control CheckBox     }
     Flow_All	      = 6;   {Both Flow Controls Checked        }

TYPE
{$IFDEF DPMI}
    RealModeRegs  = Record
     Case Integer Of
      0: ( EDI, ESI, EBP, EXX, EBX, EDX, ECX, EAX: Longint;
           Flags, ES, DS, FS, GS, IP, CS, SP, SS: Word) ;
      1: ( DI,DIH, SI, SIH, BP, BPH, XX, XXH: Word;
       Case Integer of
        0: (BX, BXH, DX, DXH, CX, CXH, AX, AXH: Word);
        1: (BL, BH, BLH, BHH, DL, DH, DLH, DHH,
            CL, CH, CLH, CHH, AL, AH, ALH, AHH: Byte));
     end;
{$ENDIF}

    HandTypes = (TERM, CDRM, MODM);

    ComSetupRec = record     {ComPort Setup dialog datarec which has next radiobuttons }
      Baud_Rate   : Word;    {Baud Rate index radiobutton value  }
      Data_Bits   : Word;    {Number Of DataBits radiobutton     }
      Stop_Bits   : Word;    {Number Of StopBits radiobutton     }
      Parity      : Word;    {Parity setting radiobutton         }
      FlowControl : Word;    {FlowControl CheckBox group         }
    end;

   PFOS_Record = ^FOS_Record;
   FOS_Record = Record
     StructSize : Word;         {FOSSIL information structure size in bytes }
     MajorVer   : Byte;         {Active FOSSIL's Major Version number       }
     MinVer     : Byte;         {Active FOSSIL's Minor Version number       }
     ID_String  : Pointer;      {Pointer to FOSSIL's ID String (PChar)      }
     InBufSize  : Word;         {Incoming Buffer Size in Bytes              }
     Rcvd_Free  : Word;         {Free Bytes in Incoming Buffer              }
     OutBufSize : Word;         {Outgoing Buffer Size in Bytes              }
     Send_Free  : Word;         {Free Bytes in Outgoing Buffer              }
     SWidth     : Byte;         {Screen Width in Characters                 }
     SHeight    : Byte;         {Screen Height in Characters                }
     BaudRate   : Byte          {Active BaudRate (Computer to Modem)        }
   End;

   PortInfo = Record
     Active    : Boolean;       {Is Port active                            }
     Carrier   : Boolean;       {Do we Have a Carrier                      }
     Handler   : Pointer;       {Port Handler (In My App points to Object) }
     HandType  : HandTypes;     {Handler Type                              }
     Baud      : LongInt;       {Current Port Settings                     }
     ComParams : ComSetupRec;   {Com Parameter record see above            }
     InfoRec   : FOS_Record;    {FOSSIL information record see above       }
   end;

Var
  ActivePorts : Array[1..4] of PortInfo;

Function  FOS_Install    (ComPort : Byte) : Boolean;
Procedure FOS_Close      (ComPort : Byte);
Procedure FOS_SetPort    (ComPort : Byte; COMSET : ComSetupRec);
Procedure FOS_GetPort	 (Comport : Byte);
Function  FOS_TxChar     (ComPort : Byte; Ch : Char) : Boolean;
Procedure FOS_TxStr      (ComPort : Byte; Str : String);
Function  FOS_RxChar     (ComPort : Byte) : Char;
Procedure FOS_RxStr      (ComPort : Byte; Var S : String);
Function  FOS_CharAvail  (ComPort : Byte) : Boolean;
Function  FOS_Carrier    (ComPort : Byte) : Boolean;
Procedure FOS_DTR        (ComPort : Byte; State : Boolean);
Function  Hangup         (Comport : Byte) : Boolean;
Procedure FOS_Timer      (Var Timer_Int, Ints_PerSec : Byte; VAR ms_PerTick : Integer);
Procedure FOS_Flush      (ComPort : Byte);
Procedure FOS_KillInBuf  (ComPort : Byte);
Procedure FOS_KillOutBuf (ComPort : Byte);
Function  FOS_TxNoWait   (ComPort : Byte; Ch : Char) : Boolean;
Function  FOS_Peek       (ComPort : Byte) : Char;
Function  FOS_PeekKey    : Word;
Function  FOS_KeyPressed : Boolean;
Function  FOS_WaitKey    : Word;
Procedure FOS_FLOW       (ComPort, State : Byte);
Procedure Set_CtrlC      (ComPort, State : Byte);
Function  CtrlC_Check    (ComPort : Byte) : Boolean;
Procedure FOS_GotoXY     (X,Y : Byte);
Procedure FOS_Position   (Var X,Y : Byte);
Function  FOS_WhereX     : Byte;
Function  FOS_WhereY     : Byte;
Procedure ANSI_Write     (Ch : Char);
Procedure WatchDog       (ComPort : Byte; Status : Boolean);
Procedure BIOS_Write     (Ch : Char);
{$IFDEF DPMI}
{$ELSE}

{These functions can be implemented too under DPMI using realmode callback
 services. DPMI function 0303h

  AX = 0303H
  DS:SI = Selector:Offset Of Your procedure/Function to call
  ES:DI = Selector:Offset Of real mode call structure

 This function returns

  Carry Flag clear if successful
  CX:DX = Segment:Offset Of realmode call address

 Now You Have the realmode address for realmode app to link with Your code

 When Your code gets called You Have the following:

  DS:SI = Selector:Offset Of real mode SS:SP
  ES:DI = Selector:Offset of real mode Call structure
  SS:SP = Locked protected mode API stack
  other registers undefined

 On return from Your code:

  Set ES:DI = Selector:Offset of real mode call structure to restore
  Execute an IRET instruction
}

Function  FOS_AddProc    (Var P) : Boolean;
Function  FOS_DelProc    (Var P) : Boolean;
{$ENDIF}

Procedure Boot		 (Method : Boolean);
Function  FOS_BlockRead  (ComPort : Byte; Bytes : Word; Var Buffer) : Word;
Function  FOS_BlockWrite (ComPort : Byte; Bytes : Word; Var Buffer) : Word;
Function  FOS_Info	 (ComPort : Byte) : Boolean;
Function  FOS_InFree     (ComPort : Byte; Free : Word) : Boolean;
Function  FOS_OutFree	 (ComPort : Byte; Free : Word) : Boolean;
Function  FOS_Ringing    (ComPort : Byte) : Boolean;

{This Function returns for You pointer to COMPORT Parameters DIALOG

Usage example:

Function SetPortParameters(ComPort) : Boolean;
Var
  P : PDIALOG
  Ch : Char;
  DlgResult : Word;
begin
 Ch := Char(ComPort + 48);
 IF ActivePorts[ComPort].Active then
  begin
    ParamDlg := CommSettings('COM' + Ch + ' Parameters');
    IF ValidView(ParamDlg) <> NIL then
     begin
       ParamDlg^.SetData(ActivePorts[ComPort].ComParams);
       DlgResult := DeskTop^.ExecView(ParamDlg);
       IF DlgResult = cmOk then
	begin
	  IF LogAct then
           begin
	     Writeln(LOGFILE, Clock^.DateStr + ' ' + CLock^.TimeStr + ' COM',
                              Char(ComPort + 48), ' parameters changed');
             Flush(LOGFILE);
           end;
	  ParamDlg^.GetData(ActivePorts[ComPort].ComParams);
	  FOS_SetPort(ComPort, ActivePorts[ComPort].ComParams);
	  Case ActivePorts[ComPort].ComParams.FlowControl of
	    Flow_None : FOS_Flow(ComPort, 0);
	    Flow_XONXOFF : FOS_Flow(ComPort, RECV_XON_XOFF OR SEND_XON_XOFF);
	    Flow_RTSCTS : FOS_Flow(ComPort, CTS_RTS);
	    Flow_All : FOS_Flow(ComPort, 11);
	  else
	   FOS_Flow(ComPort, 0); If user selected all or none CheckBoxes
	  end;
         FOS_TxStr(ComPort, 'AT'); Send AT for framing modem
	end;
       Dispose(ParamDlg, Done);
     end;
   end
  else
   MessageBox(^C'Port not active.' + #13#13 + ^C'Unable to change parameters', NIL, mfError or mfOkButton);
  SetPortParameters := DlgResult = cmOk;
end;

{Function CommSettings   (Str : String) : PDIALOG;}

IMPLEMENTATION

{$IFDEF DPMI}
USES OBJECTS, CRT, WINAPI;
{$ELSE}
USES OBJECTS, CRT, DOS;
{$ENDIF}

VAR
{$IFDEF DPMI}
  REGS : RealModeRegs;
  BuffSeg  : Word;
  PMBuffer : Pointer;
  Temp_Selector : Word;
{$ELSE}
  REGS : Registers;
{$ENDIF}
  SavedExitProc : Pointer;

{$IFDEF DPMI}
Function RealModeInt(IntNo : Byte; Var RealRegs : RealModeRegs) : Boolean;assembler;
asm
  MOV AX, 0300h
  MOV BL, [IntNo]
  XOR BH, BH
  XOR CX, CX
  LES DI, [RealRegs]
  INT 31h
  JC  @Error
  MOV AX, 1
  JMP @Exit
@Error:
  MOV AX, 0
@Exit:
end;

Function SetSelector(Var Selector : Word; Base, Limit : LongInt) : Boolean;
begin
  If (Selector <> 0) AND (SetSelectorBase( Selector, Base) = Selector) AND
     (SetSelectorLimit(Selector, Limit) = 0) then
   SetSelector:= True
  else
   SetSelector := False;
end;

Function AllocateLowMem(Size : Word; var PMPointer : Pointer ) : Word;
Var
 TempAddr : LongInt;
begin
  TempAddr := GlobalDOSAlloc(Size) ;
  If TempAddr = 0 then RunError(0);
  PMPointer := Ptr(LongRec(TempAddr).Lo, 0);
  AllocateLowMem := LongRec(TempAddr).Hi;
end ;

Procedure FreeLowMem(Var PMPointer : Pointer ) ;
begin
  GlobalDOSFree( Seg(PMPointer^));
  PMPointer := nil;
end;
{$ENDIF}

Function FOS_Install (ComPort:Byte) : Boolean;
Begin
  REGS.AH := $04;
  REGS.CX := 0;
  REGS.DX := ComPort - 1;
  REGS.BX := $4F50;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS);
{$ENDIF}
  FOS_Install := REGS.AX = $1954;
  ActivePorts[Comport].Active := REGS.AX = $1954;
End;

Procedure FOS_Close(ComPort : Byte);
Begin
  REGS.AH := $05;
  REGS.DX := ComPort - 1;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS);
{$ENDIF}
  ActivePorts[ComPort].Active := False;
End;

Procedure FOS_SetPort(ComPort : Byte; COMSET : ComSetupRec);
Var
   Setting : Byte;   { 1 1 1 1 1 1 1 1 }
Begin
  With COMSET do
   begin
     Case COMSET.Baud_Rate of
       0 : Setting := 224; 		{Default speed 9600}
       1 : Setting := 128; 		{1200		   }
       2 : Setting := 160; 		{2400		   }
       3 : Setting := 192; 		{4800		   }
       4 : Setting := 224; 		{9600		   }
       5 : Setting := 0;    		{19200  	   }
       6 : Setting := 32;     		{S38400		   }
     End;
     Case Data_Bits of
{       0 : Setting := Setting + 1; 	{6 Data}
       0 : Setting := Setting + 2; 	{7 Data}
       1 : Setting := Setting + 3  	{8 Data}
     End;
     Case Parity of
       0 : Setting := Setting + 0;      {No Parity}
       1 : Setting := Setting + 8;      {Odd Parity}
       2 : Setting := Setting + 24      {Even Parity}
     End;
     Case Stop_Bits of
       0 : Setting := Setting + 0;	{1 Stop}
       1 : Setting := Setting + 4	{2 Stop}
     End;
   End;
  REGS.AH := 0;
  REGS.AL := Setting;
  REGS.DX := ComPort - 1;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS);
{$ENDIF}
End;

Procedure FOS_GetPort(ComPort : Byte);
Var
 Setting : Byte;
begin
  Setting := ActivePorts[ComPort].InfoRec.BaudRate;
  With ActivePorts[ComPort].ComParams do
   begin
     Case Setting AND $E0 Of
       224 : Baud_Rate := 0; 		{Default speed 9600}
       128 : Baud_Rate := 1; 		{1200		   }
       160 : Baud_Rate := 2; 		{2400		   }
       192 : Baud_Rate := 3; 		{4800		   }
	 0 : Baud_Rate := 5;    	{19200  	   }
	32 : Baud_Rate := 6;     	{S38400		   }
     end;
     Case Setting AND $3 of
       0 : Data_Bits := 2;	 	{6 Data}
       2 : Data_Bits := 0; 		{7 Data}
       3 : Data_Bits := 1;	  	{8 Data}
     End;
     Case Setting AND $18 of
       0 : Parity := 0;      		{No Parity}
       8 : Parity := 1;      		{Odd Parity}
      24 : Parity := 2;      		{Even Parity}
     End;
     Case Setting AND $4 of
       0 : Stop_Bits := 0;		{1 Stop}
       4 : Stop_Bits := 1;		{2 Stop}
     End;
   end;
end;

Function FOS_Ringing(ComPort : Byte) : Boolean;
var
  TempCh : Char;
begin
  FOS_Ringing := False;
  REGS.AH := $0C;
  REGS.DX := ComPort - 1;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS);
{$ENDIF}
  If REGS.AX = $FFFF Then
   FOS_Ringing := False
  else
   begin
     TempCh := Chr(REGS.AL);
     if TempCh = #13 then
      FOS_Ringing := true;
   end;
end;

Function FOS_TxChar(ComPort : Byte; Ch : Char) : Boolean;
Begin
  REGS.AH := $01;
  REGS.AL := Ord(Ch);
  REGS.DX := ComPort - 1;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS);
{$ENDIF}
  FOS_TxChar := (REGS.AH AND $80) = $80;
End;

Procedure FOS_TxStr(ComPort : Byte; Str : String);
Var
 I:Integer;
 S : String;

Begin
  S:= Str + #13#10;
  If FOS_OutFree(ComPort, Length(S)) then
  I:=FOS_BlockWrite(ComPort, Length(S), S[1])
End;

Function FOS_RxChar(ComPort : Byte) : Char;
Begin
  REGS.AH := $02;
  REGS.DX := ComPort - 1;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS);
{$ENDIF}
  If (REGS.AH AND $80) = $80 then
   FOS_RxChar := #0
  else
   FOS_RxChar := Chr(REGS.AL)
End;

Procedure FOS_RxStr(ComPort : Byte; Var S : String);
Var
  Ch : Char;
  Count : Byte;
begin
  Count := 1;                             {Current_Pos = 1                }
  While FOS_CharAvail(ComPort) do         {While Chars available do       }
   begin
     If FOS_Peek(ComPort) <> #10 then     {If NextChar = LineFeed then    }
      begin
        S[Count] := FOS_RxChar(ComPort);  {String[Current_Pos] = NextChar }
        IF S[Count] <> #00 then           {Ignore NULL Chars              }
         Inc(Count);                      {Increment Current_Pos          }
        IF Count = 255 then               {If Current_Pos = Maxlen(String)}
         begin
           S[0] := #255;                  {Return MaxLen String           }
           Break;
         end;
      end;
   end;
end;

Function FOS_CharAvail(ComPort : Byte) : Boolean;
Begin
  REGS.AH := $03;
  REGS.DX := ComPort - 1;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS);
{$ENDIF}
  FOS_CharAvail := (REGS.AH And 1) = 1
End;

Function FOS_Carrier(ComPort : Byte) : Boolean;
Begin
  REGS.AH := $03;
  REGS.DX := ComPort - 1;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS);
{$ENDIF}
  FOS_Carrier := (REGS.AL And 128) = 128
End;

Procedure FOS_DTR (ComPort : Byte; State : Boolean);
Begin
  REGS.AH := $06;
  REGS.AL := Byte(State);
  REGS.DX := ComPort - 1;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS)
{$ENDIF}
End;

Function Hangup(ComPort : Byte) : Boolean;
Begin
  HangUp := False;
  If Not FOS_Carrier(ComPort) Then
   HangUp := True
  else
   begin
     FOS_DTR (ComPort,False);
     Delay (1000);
     FOS_DTR (ComPort,True);
     If FOS_Carrier(ComPort) Then
      Begin
	FOS_TxStr(ComPort, '+++');
	Delay (1000);
	FOS_TxStr(ComPort, 'ATH0'+ #10#13);
	Delay(1000);
      end
     else
      HangUp := True;
   end;
  If Not FOS_Carrier(ComPort) Then
   HangUp := True
End;

Procedure FOS_Timer(Var Timer_Int, Ints_PerSec : Byte; VAR ms_PerTick : Integer);
Begin
  REGS.AH := $07;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS);
{$ENDIF}
  Timer_Int := REGS.AL;
  Ints_PerSec := REGS.AH;
  ms_PerTick  := REGS.DX
End;

Procedure FOS_Flush(ComPort:Byte);
Begin
  REGS.AH := $08;
  REGS.DX := ComPort - 1;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS)
{$ENDIF}
End;

Procedure FOS_KillOutBuf(ComPort:Byte);
Begin                                   { Purges the OutPut Buffer   }
  REGS.AH := $09;
  REGS.DX := ComPort - 1;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS)
{$ENDIF}
End;

Procedure FOS_KillInBuf(ComPort:Byte);
Begin                                   { Purges the Input Buffer    }
  REGS.AH := $0A;
  REGS.DX := ComPort - 1;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS)
{$ENDIF}
End;

Function FOS_TxNoWait(ComPort : Byte; Ch : Char) : Boolean;
Begin
  REGS.AH := $0B;
  REGS.AL := Ord(Ch);
  REGS.DX := ComPort - 1;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS);
{$ENDIF}
  FOS_TxNoWait := (REGS.AH AND $80) = $80;
End;

Function FOS_Peek(ComPort : Byte) : Char;
Begin
  REGS.AH := $0C;
  REGS.DX := ComPort - 1;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS);
{$ENDIF}
  FOS_Peek := Chr(REGS.AL)
End;

Function FOS_PeekKey : Word;
Begin
  REGS.AH := $0D;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS);
{$ENDIF}
  FOS_PeekKey := REGS.AX
End;

Function FOS_KeyPressed : Boolean;
Begin
  REGS.AH := $0D;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS);
{$ENDIF}
  FOS_KeyPressed := (REGS.AX <> $FFFF);
End;

Function FOS_WaitKey : Word;
Begin
  REGS.AH := $0E;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS);
{$ENDIF}
  FOS_WaitKey := REGS.AX
End;

Procedure FOS_FLOW(ComPort, State : Byte);
Begin
  REGS.AH := $0F;
  REGS.AL := State + $F0;
  REGS.DX := ComPort - 1;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS)
{$ENDIF}
End;

Procedure Set_CtrlC (ComPort, State : Byte);
Begin
  REGS.AH := $10;
  REGS.AL := State;
  REGS.DX := ComPort - 1;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS)
{$ENDIF}
End;

Function CtrlC_Check(ComPort : Byte) : Boolean;
Begin
  REGS.AH := $10;
  REGS.AL := 2;
  REGS.DX := ComPort - 1;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS);
{$ENDIF}
  CtrlC_Check := Boolean(REGS.AX)
End;

Procedure FOS_GotoXY(X, Y : Byte);
Begin
  REGS.AH := $11;
  REGS.DH := Y - 1;
  REGS.DL := X - 1;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS)
{$ENDIF}
End;

Procedure FOS_Position (Var X,Y:Byte);
Begin
  REGS.AH := $12;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS);
{$ENDIF}
  X := REGS.DL + 1;
  Y := REGS.DH + 1
End;

Function FOS_WhereX : Byte;
Begin
  REGS.AH := $12;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS);
{$ENDIF}
  FOS_WhereX := REGS.DL + 1
End;

Function FOS_WhereY : Byte;
Begin
  REGS.AH := $12;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS);
{$ENDIF}
  FOS_WhereY := REGS.DH + 1
End;

Procedure ANSI_Write(Ch : Char);
Begin
  REGS.AH := $13;
  REGS.AL := Ord(Ch);
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS)
{$ENDIF}
End;

Procedure WatchDog(ComPort : Byte; Status : Boolean);
Begin
  REGS.AH := $14;
  REGS.AL := Byte(Status);
  REGS.DX := ComPort - 1;
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS)
{$ENDIF}
End;

Procedure BIOS_Write(Ch : Char);
Begin
  REGS.AH := $15;
  REGS.AL := Ord(Ch);
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS)
{$ENDIF}
End;

{$IFDEF DPMI}
{$ELSE}
Function FOS_AddProc(Var P) : Boolean;
Begin
  REGS.AH := $16;
  REGS.AL := $01;
  REGS.ES := Seg(P);
  REGS.DX := Ofs(P);
  Intr($14, REGS);
  FOS_AddProc := REGS.AX = 0
End;
{$ENDIF}

{$IFDEF DPMI}
{$ELSE}
Function FOS_DelProc(Var P) : Boolean;
Begin
  REGS.AH := $16;
  REGS.AL := $00;
  REGS.ES := Seg (P);
  REGS.DX := Ofs (P);
  Intr($14, REGS);
  FOS_DelProc := REGS.AX = 0
End;
{$ENDIF}

Procedure Boot(Method : Boolean);
Begin
  REGS.AH := $17;
  REGS.AL := Byte(Method); 		{Cold, Warm}
{$IFDEF DPMI}
  RealModeInt($14, REGS);
{$ELSE}
  Intr($14, REGS)
{$ENDIF}
End;

Function FOS_BlockRead(ComPort : Byte; Bytes : Word; Var Buffer) : Word;
Begin
  REGS.AH := $18;
  REGS.DX := ComPort - 1;
  REGS.CX := Bytes;
{$IFDEF DPMI}
  REGS.DI := 0;
  REGS.ES := BuffSeg;
  RealModeInt($14, REGS);
  Move(PMBuffer^, Buffer, REGS.AX);
{$ELSE}
  REGS.ES := Seg(Buffer);
  REGS.DI := Ofs(Buffer);
  Intr($14, REGS);
{$ENDIF}
  FOS_BlockRead := REGS.AX
End;

Function FOS_BlockWrite(ComPort : Byte; Bytes : Word; Var Buffer) : Word;
Begin
  REGS.AH := $19;
  REGS.DX := ComPort - 1;
  REGS.CX := Bytes;
{$IFDEF DPMI}
  Move(Buffer, PMBuffer^, Bytes);
  REGS.DI := 0;
  REGS.ES := BuffSeg;
  RealModeInt($14, REGS);
{$ELSE}
  REGS.ES := Seg (Buffer);
  REGS.DI := Ofs (Buffer);
  Intr($14, REGS);
{$ENDIF}
  FOS_BlockWrite := REGS.AX
End;

Function FOS_Info(ComPort : Byte) : Boolean;
begin
  REGS.AH := $1B;
  REGS.DX := ComPort - 1;
  REGS.CX := SizeOf(ActivePorts[ComPort].InfoRec);
{$IFDEF DPMI}
  REGS.DI := 0;
  REGS.ES := BuffSeg;
  RealModeInt($14, REGS);
  If NOT SetSelector(Temp_Selector, PtrRec(PFOS_Record(PMBuffer)^.ID_String).Seg*LongInt(16),
                           PtrRec(PFOS_Record(PMBuffer)^.ID_String).Ofs + 256) then
   PFOS_Record(PMBuffer)^.ID_String := Nil
  else
   PtrRec(PFOS_Record(PMBuffer)^.ID_String).Seg := Temp_Selector;
  Move(PMBuffer^, ActivePorts[ComPort].InfoRec, SizeOf(FOS_Record));
{$ELSE}
  REGS.ES := Seg(ActivePorts[ComPort].InfoRec);
  REGS.DI := Ofs(ActivePorts[ComPort].InfoRec);
  Intr($14, REGS);
{$ENDIF}
  If (ActivePorts[ComPort].InfoRec.Rcvd_Free) <=
     (ActivePorts[ComPort].InfoRec.InBufSize) then
   FOS_Info := True
  else
   FOS_Info := False;
end;

Function FOS_InFree(ComPort : Byte; Free : Word) : Boolean;
begin
  REGS.AH := $1B;
  REGS.DX := ComPort - 1;
  REGS.CX := SizeOf(ActivePorts[ComPort].InfoRec);
{$IFDEF DPMI}
  REGS.DI := 0;
  REGS.ES := BuffSeg;
  RealModeInt($14, REGS);
  If PFOS_Record(PMBuffer)^.Rcvd_Free > Free then
   FOS_InFree := True
  else
   FOS_InFree := False;
{$ELSE}
  REGS.ES := Seg(ActivePorts[ComPort].InfoRec);
  REGS.DI := Ofs(ActivePorts[ComPort].InfoRec);
  Intr($14, REGS);
  If (ActivePorts[ComPort].InfoRec.Rcvd_Free) > Free then
   FOS_InFree := True
  else
   FOS_InFree := False;
{$ENDIF}
end;

Function FOS_OutFree(ComPort : Byte; Free : Word) : Boolean;
begin
  REGS.AH := $1B;
  REGS.DX := ComPort - 1;
  REGS.CX := SizeOf(ActivePorts[ComPort].InfoRec);
{$IFDEF DPMI}
  REGS.DI := 0;
  REGS.ES := BuffSeg;
  RealModeInt($14, REGS);
  If PFOS_Record(PMBuffer)^.Send_Free > Free then
   FOS_OutFree := True
  else
   FOS_OutFree := False;
{$ELSE}
  REGS.ES := Seg(ActivePorts[ComPort].InfoRec);
  REGS.DI := Ofs(ActivePorts[ComPort].InfoRec);
  Intr($14, REGS);
  If (ActivePorts[ComPort].InfoRec.Send_Free) >= Free then
   FOS_OutFree := True
  else
   FOS_OutFree := False;
{$ENDIF}
end;

procedure CustomExit; FAR;
Var
 Counter : Byte;
begin
  ExitProc := SavedExitProc;
  For Counter := 1 to 4 do
   If ActivePorts[Counter].Active then
    FOS_Close(Counter);
{$IFDEF DPMI}
  FreeLowMem(PMBuffer);
{$ENDIF}
end;

{FUNCTION CommSettings(Str : String) : PDialog;
var
  DlgWin : PDialog;
  R : TRect;
  Control, Labl, Histry : PView;
Begin
R.Assign(18,2,58,18);
New(DlgWin, Init(R, Str));

R.Assign(3,2,17,9);
Control := New(PRadioButtons, Init(R,
  NewSItem('~H~ardware',
  NewSItem('~1~200',
  NewSItem('~2~400',
  NewSItem('~4~800',
  NewSItem('9~6~00',
  NewSItem('1~9~200',
  NewSItem('3~8~400',Nil)))))))));
Control^.HelpCtx := hcSelBaudRate;
DlgWin^.Insert(Control);

  R.Assign(3,1,14,2);
  Labl := New(PLabel, Init(R, '~B~aud Rate ', Control));
  DlgWin^.Insert(Labl);

R.Assign(20,2,27,4);
Control := New(PRadioButtons, Init(R,
  NewSItem('7',
  NewSItem('8',Nil))));
Control^.HelpCtx := hcSelDataBits;
DlgWin^.Insert(Control);

  R.Assign(20,1,26,2);
  Labl := New(PLabel, Init(R, '~D~ata ', Control));
  DlgWin^.Insert(Labl);

R.Assign(30,2,37,4);
Control := New(PRadioButtons, Init(R,
  NewSItem('1',
  NewSItem('2',Nil))));
Control^.HelpCtx := hcSelStopBits;
DlgWin^.Insert(Control);

  R.Assign(30,1,36,2);
  Labl := New(PLabel, Init(R, '~S~top ', Control));
  DlgWin^.Insert(Labl);

R.Assign(20,6,30,9);
Control := New(PRadioButtons, Init(R,
  NewSItem('~N~one',
  NewSItem('~O~dd',
  NewSItem('~E~ven',Nil)))));
Control^.HelpCtx := hcSelParity;
DlgWin^.Insert(Control);

  R.Assign(20,5,28,6);
  Labl := New(PLabel, Init(R, '~P~arity ', Control));
  DlgWin^.Insert(Labl);

R.Assign(3,11,21,14);
Control := New(PCheckboxes, Init(R,
  NewSItem('None',
  NewSItem('~X~ON/XOFF',
  NewSItem('~R~TS/CTS',Nil)))));
Control^.HelpCtx := hcSelFlowControl;
DlgWin^.Insert(Control);

  R.Assign(3,10,17,11);
  Labl := New(PLabel, Init(R, '~F~low Control ', Control));
  DlgWin^.Insert(Labl);

R.Assign(23,11,37,13);
Control := New(PButton, Init(R, 'Ok', cmOK, bfDefault));
DlgWin^.Insert(Control);

R.Assign(23,13,37,15);
Control := New(PButton, Init(R, 'Cancel', cmCancel, bfNormal));
DlgWin^.Insert(Control);

R.Assign(2,1,3,9);
Control := New(PStaticText, Init(R, '┌│││││││'));
DlgWin^.Insert(Control);

R.Assign(2,9,18,10);
Control := New(PStaticText, Init(R, '└──────────────┘'));
DlgWin^.Insert(Control);

R.Assign(17,2,18,9);
Control := New(PStaticText, Init(R, '│││││││'));
DlgWin^.Insert(Control);

R.Assign(19,4,28,5);
Control := New(PStaticText, Init(R, '└───────┘'));
DlgWin^.Insert(Control);

R.Assign(29,4,38,5);
Control := New(PStaticText, Init(R, '└───────┘'));
DlgWin^.Insert(Control);

R.Assign(27,2,28,4);
Control := New(PStaticText, Init(R, '││'));
DlgWin^.Insert(Control);

R.Assign(37,2,38,4);
Control := New(PStaticText, Init(R, '││'));
DlgWin^.Insert(Control);

R.Assign(19,1,20,4);
Control := New(PStaticText, Init(R, '┌││'));
DlgWin^.Insert(Control);

R.Assign(29,1,30,4);
Control := New(PStaticText, Init(R, '┌││'));
DlgWin^.Insert(Control);

R.Assign(19,9,31,10);
Control := New(PStaticText, Init(R, '└──────────┘'));
DlgWin^.Insert(Control);

R.Assign(19,5,20,9);
Control := New(PStaticText, Init(R, '┌│││'));
DlgWin^.Insert(Control);

R.Assign(30,6,31,9);
Control := New(PStaticText, Init(R, '│││'));
DlgWin^.Insert(Control);

R.Assign(2,14,22,15);
Control := New(PStaticText, Init(R, '└──────────────────┘'));
DlgWin^.Insert(Control);

R.Assign(21,11,22,14);
Control := New(PStaticText, Init(R, '│││'));
DlgWin^.Insert(Control);

R.Assign(2,10,3,14);
Control := New(PStaticText, Init(R, '┌│││'));
DlgWin^.Insert(Control);

R.Assign(14,1,18,2);
Control := New(PStaticText, Init(R, '───┐'));
DlgWin^.Insert(Control);

R.Assign(26,1,28,2);
Control := New(PStaticText, Init(R, '─┐'));
DlgWin^.Insert(Control);

R.Assign(36,1,38,2);
Control := New(PStaticText, Init(R, '─┐'));
DlgWin^.Insert(Control);

R.Assign(17,10,22,11);
Control := New(PStaticText, Init(R, '────┐'));
DlgWin^.Insert(Control);

R.Assign(28,5,31,6);
Control := New(PStaticText, Init(R, '──┐'));
DlgWin^.Insert(Control);

DlgWin^.SelectNext(False);
CommSettings := DlgWin;
end;}


Begin
  {$IFDEF DPMI}
     BuffSeg := AllocateLowMem(1024, PMBuffer);
     Temp_Selector := AllocSelector(0);
     FillChar(ActivePorts, SizeOf(ActivePorts), #00);
  {$ELSE}
     FillChar(ActivePorts, SizeOf(ActivePorts), #00);
  {$ENDIF}
  SavedExitProc := ExitProc;
  ExitProc := @CustomExit;
end.


