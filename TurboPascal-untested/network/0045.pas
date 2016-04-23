{
! Name            : NetBios.Pas
! Ver             : 0.10
! (C) Copyright   :
! Author          : Nicolai Wadstr&ouml;m
! Type of code    : Turbo Pascal 5.0 Unit
! Date            : 1989-10-xx
!
!----------------------------------------------------------------------------
!
! Description:
! ------------
! NetBios interface routines for Turbo Pascal 4.x, 5.x.
!
!
!
! History:
! --------
!
!
!
!
!============================================================================
}
{$A+ Align data + = Word, - = Byte}
{$B- Boolean evaluation + = complete, - = short-circuit}
{$D+ Debug info + = On, - = Off}
{$E- 8087 emulator + = On, - = Off}
{$F- Force far calls + = On, - = Off}
{$I+ IO check + = On, - = Off}
{$L+ Local symbol info + = On, - = Off}
{$N- 8087 code generation + = On, - = Off}
{$O+ Overlay code generation + = On, - = Off}
{$R- Range checking + = On, - = Off}
{$S+ Stack checking + = On, - = Off}
{$V- Var-String checking + = On, - = Off}

Unit NetBios;
interface

Uses Dos;

Const
 {
 ! NetBios commands:
 }
 NetBiosCmd_Call           = $10;
 NetBiosCmd_Listen         = $11;
 NetBiosCmd_HangUp         = $12;

 NetBiosCmd_Send           = $14;
 NetBiosCmd_Rec            = $15;
 NetBiosCmd_RecAny         = $16;
 NetBiosCmd_SendChain      = $17;

 NetBiosCmd_SendDatagram   = $20;
 NetBiosCmd_RecDatagram    = $21;
 NetBiosCmd_SendBroadcast  = $22;
 NetBiosCmd_RecBroadcast   = $23;

 NetBiosCmd_AddName        = $30;
 NetBiosCmd_DeleteName     = $31;
 NetBiosCmd_Reset          = $32;
 NetBiosCmd_AdapterStat    = $33;
 NetBiosCmd_SessionStat    = $34;
 NetBiosCmd_Cancel         = $35;
 NetBiosCmd_AddGroupName   = $36;


 NetBiosCmd_Unlink         = $70;
 NetBiosCmd_SendNoAck      = $71;
 NetBiosCmd_SendChainNoAck = $72;
 NetBiosCmd_FindName       = $78;
 NetBiosCmd_TokenRingTrace = $79;






 NetBiosCmdNoWait         = $80;

 {
 ! NetBios error codes:
 }

 NetBios_Ok               = $00;
 NetBios_IllegalBufLen    = $01;
 NetBios_InvalidCmd       = $03;
 NetBios_Timeout          = $05;
 NetBios_MsgIncomplete    = $06;
 NetBios_InvalidSessionNr = $08;
 NetBios_OutofResources   = $09;
 NetBios_SessionClosed    = $0A;
 NetBios_CmdCanceled      = $0B;
 NetBios_DupLocalName     = $0D;
 NetBios_NameTableFull    = $0E;
 NetBios_Name_Deleted     = $0F;
 NetBios_SessionTableFull = $11;
 NetBios_RemNotListning   = $12;
 NetBios_IvalidNameNr     = $13;
 NetBios_NameNotFound     = $14;
 NetBios_InvalidNameFormat= $15;
 NetBios_NameExists       = $16;
 NetBios_NameDeleted      = $17;
 NetBios_ConnectionLost   = $18;
 NetBios_DupNetworkName   = $19;
 NetBios_BadPacket        = $1A;
 NetBios_InterfaceBusy    = $21;
 NetBios_TooManyCmds      = $22;
 NetBios_InvalidAdapNr    = $23;
 NetBios_CmdNotCanceled   = $24;
 NetBios_InvalidCancelCmd = $26;
 NetBios_AlreadyDefName   = $30; { Name already defined by another envoirment }
 NetBios_EnvNotDef        = $34; { Envoirment not defined, RESET must be issued}
 NetBios_OutOfSysResource = $35; { Required os resources exhausted, retry later}
 NetBios_MaxAPPLExceeded  = $36; { Max. nr of applications eceeded }
 NetBios_OutOfSAPs        = $37; { There is no SAPs available for NetBIOS}
 NetBios_ResourceNotAvail = $38; { Requested resource(s) not available }
 NetBios_InvalidNCB       = $39; { Invalid NCB address or len don' fit in seg}
 NetBios_Illegal_RESET    = $3A; { Reset May not be issued from a NetBios adapter appendage}
 NetBios_InvalidNCB_DD_ID = $3B; { Invalid DeviceDriver ID, OS/2 only }
 NetBios_LockFailed       = $3C; { NetBios attempted to lock user storage but lock failed }
 NetBios_DDOpenErr        = $3F; { Device driver open error, OS/2 only }
 NetBios_OS2error         = $40; { OS/2 error detected, OS/2 only }
 NetBios_HardwareError    = $FE;
 NetBios_NotCompleted     = $FF;




 NrOfNCBs                 = 2;
 CurrentNCB               : Byte = 1;
 MaxSessions              = 20;
 NrOfNames                = 254;
 NetBiosNoWait            : Boolean = False;

Type
   Str16                  = String[16];
   NameType               = Array[1..16] of Char;
   NodeAddressType        = Array[1..6] of Byte;
   VersionType            = record
                             Major          : Byte;
                             Minor          : Byte;
                            end;

   NameEntryType          = record
                             Name           : NameType;
                             NameNumber     : Byte;
                             NameStatus     : Byte;
                             {
                             !                |                         |
                             ! NameStatus     | Meaning                 |
                             !  Bin     | Dec |                         |
                             ! -----421----------------------------------
                             ! 00000000   (0) | Name add in progress.   |
                             ! 00000100   (4) | Active name.            |
                             ! 00000101   (5) | Delete pending.         |
                             ! 00000110   (6) | Improper duplicate name.|
                             ! 00000111   (7) | Duplicate name, delete  |
                             !                | pending.                |
                             ! ------------------------------------------
                             }
                            end;


   OneSessionStatusType   = record
                             LocSessionNr   : Byte;
                             SessionState   : Byte;
                             {
                             !              |                         |
                             ! SessionState | Meaning                 |
                             ! ----------------------------------------
                             !            1 | Session LISTEN pending. |
                             !            2 | Session CALL pending.   |
                             !            3 | Session active.         |
                             !            4 | HANG UP pending.        |
                             !            5 | HANG UP complete.       |
                             !            6 | Session aborted.        |
                             ! ----------------------------------------
                             }

                             LocName        : NameType;
                             RemName        : NameType;
                             RecCmdsOut     : Byte;
                             SendCmdsOut    : Byte;
                            end;

   SessionStatusType      = record
                             SessionNr      : Byte;
                             NrOfSessions   : Byte;
                             MessCmdsOut    : Byte;
                             RecAnyCmdsOut  : Byte;
                             SessionTable   : Array[1..MaxSessions] of OneSessionStatusType;
                            end;

   SessionStatusPtr       = ^SessionStatusType;




   ExtStatusType          = record
                             DIR_INIT_ErrCode       : Word;
                             DIR_OPEN_ADAPErrCode   : Word;
                             LatestNetworkStatus    : Word;
                             LatestPCError          : Word; {Contents of AX reg}
                             LatestOperCommandCode  : Byte;
                             LatestCCBRetCode       : Byte;

                             LineErrors             : Word;
                             InternalErrors         : Word;
                             BurstErrors            : Word;
                             ARI_FCI_delimiter      : Word;
                             Abort_delimiter        : Word;
                             LostFrameErrors        : Word;
                             RecCongestion          : Word;
                             FrameCopiedErrors      : Word;
                             FreqErrors             : Word;
                             TokenErrors            : Word;
                             Reserved               : Word;
                             DMABusErrors           : Word;
                             DMAParityErrors        : Word;
                            end;

   AdapterStatusType      = record
                             NodeAddress    : NodeAddressType;
                             MajorVersion   : Byte;
                             {
                             ! $00 = Version 1.xx
                             ! $02 = Version 2.xx
                             ! $03 = Version 3.xx
                             !
                             }

                             PowerOnResult  : Byte;
                             {
                             ! Always zero in current versions.
                             }

                             AdapterType    : Byte;
                             {
                             ! $FF = Token-Ring Network Adapter
                             ! $FE = PC Network Adapter
                             !
                             }
                             MinorVersion   : Byte;

                             MinSincePowerUp: Word;
                             {
                             ! Minutes since system was powered up.
                             ! Rolls over to zero when it reaches $FFFF.
                             }

                             NrOfCRCErrors  : Word;
                             {
                             ! Number of CRC error on received packets.
                             ! Rolls over to zero when it reaches $FFFF.
                             }

                             NrOfAlignErrors:Word;
                             {
                             ! Number of alignment errors.
                             ! Rolls over to zero when it reaches $FFFF.
                             }

                             NrOfCollisions : Word;
                             {
                             ! Number of transmit collision errors.
                             ! Rolls over to zero when it reaches $FFFF.
                             }

                             NrOfAborted    : Word;
                             {
                             ! Number of aborted transmissions.
                             ! Rolls over to zero when it reaches $FFFF.
                             }

                             NrOfTxDPackets : LongInt;
                             {
                             ! Number of packets trasmitted.
                             ! Rolls over to zero when it reaches $FFFFFFFF.
                             }

                             NrOfRxDPackets : LongInt;
                             {
                             ! Number of packets received.
                             ! Rolls over to zero when it reaches $FFFFFFFF.
                             }

                             NrOfReTxDs     : Word;
                             {
                             ! Number of retransmissions.
                             ! Rolls over to zero when it reaches $FFFF.
                             }

                             NrOfEoBufErrs  : Word;
                             {
                             ! Number of times receiver was out of buffers.
                             ! Rolls over to zero when it reaches $FFFF.
                             }

                             DLCT1_Timeouts : Word;

                             DLCTi_Timeouts : Word;

                             ExtStatusPtr   : ^ExtStatusType;
                             NrOfNCBsFree   : Word;
                             NrOfNCBsReseted: Word;
                             MaxResNCBs     : Word;
                             {
                             ! Maximum number of NCBs that can be specified
                             ! by the RESET command.
                             }

                             NrOfTxOutOfBuf : Word;
                             MaxDatagramSize: Word;
                             ActSessions    : Word;
                             {
                             ! Number of active or pending sessions.
                             }

                             NrOfResSessions: Word;
                             {
                             ! Number of possible sessions specified in
                             ! last RESET command.
                             }

                             MaxResSessions : Word;
                             {
                             ! Maximum number of sessions that can be specified
                             ! by the RESET command.
                             }

                             NetPacketSize  : Word;
                             {
                             ! Maximum packet size supported by the network
                             }

                             NrOfNames             : Word;
                             PermanentName         : NameEntryType;
                             NameTable             : Array[1..NrOfNames] of NameEntryType;
                            end;


   NCB_Type               = record
                             Command               : Byte;
                             RetCode               : Byte;
                             LocSessionNr          : Byte;
                             NameNr                : Byte;
                             BufferPtr             : Pointer;
                             BufferLen             : Word;
                             Callname              : NameType;
                             Name                  : NameType;
                             Rec_TimeOut           : Byte;
                             Send_TimeOut          : Byte;
                             User_Int              : Pointer;
                             Adapter_Num           : Byte;
                             CmdDone               : Byte;
                             Reserved              : Array[1..14] of Byte;
                            end;

   NCB_TypePtr            = ^NCB_TypePtr;

   TraceHeaderType        = record
                             TraceBufferPtr         : Pointer;
                             TraceBufferLen         : Word;
                             TraceEntryStart        : Word;
                             CodeChangeLvl          : Array[8..15] of Byte;
                             TraceEntryCounterLo    : Word;
                             TraceEntryCounterHi    : Word;
                             InternBuffersExhaust   : Word;
                             InternTxdBufferExhaust : Word;
                             Reserved               : Array[24..27] of byte;
                             LastTraceEntry         : Word;
                             NextTraceEntry         : Word;
                            end;

   TraceEntry             = record
                             AdapterNum             : Byte;
                             XMA3270BankID          : Byte;
                             EntryType              : Byte;
                             Modifier               : Byte;
                             TicksSinceLastEntry    : Word;
                             Data                   : Array[6..31] of Byte;
                            end;


   NetBIOSHardwareHeader  = record
                             HeaderLength           : Byte;
                             Delimiter              : Word;
                             Command                : Byte;
                             Data1                  : Byte;
                             Data2                  : Word;
                             TxCorrelator           : Word;
                             RespCorrelator         : Word;
                             DestSessionNr          : Byte;
                             SrcSessionNr           : Byte;
                            end;

Var
   LocalAdapterStatus     : AdapterStatusType;
   LocalName              : String[16];


function Call_NetBios(Var NCB:NCB_Type) : Word;
{
! Calls netbios with a NCB.
!
}


function NetBIOSErrorStr ( ErrorCode : Word ) : String;
{
! NetBIOSErrorStr
! ---------------
!
! Returns the error code as a explaining strig.
!
!
}

function NetBIOSAvailable : Boolean;
{
! NetBIOSAvailable
! ----------------
! Returns true if NetBIOS interface routines can be found otherwise false.
!
}




procedure Name2Str(Name:NameType; Var Strng:String);

procedure Str2Name(Strng:String; Var Name:NameType);

function Reset(Var NCB : NCB_Type) : Word;

function Cancel(Var NCB : NCB_Type) : Word;

function GetAdapterStat(
                        Var NCB           : NCB_Type;
                        Var Status        : AdapterStatusType
                       ) : Word;

function Unlink(Var NCB : NCB_Type) : Word;

function AddName(Var NCB : NCB_Type) : Word;

function SendBlock(
                   Var NCB         : NCB_Type;
                   Var Buffer
                  ) : Word;


implementation

Var
   NetBiosStatus          : Word;


function Call_NetBios(Var NCB:NCB_Type) : Word;
{
! Calls netbios with a NCB.
!
}
Var
  Regs        : Registers;
begin
 Regs.ES:=Seg(NCB);
 Regs.BX:=Ofs(NCB);
  Intr($5C,Regs);

{$IFDEF DEBUGING}
   WriteLn(' NetBIOS Msg(',NCB.RetCode ,' dec): ',NetBIOSErrorStr(NCB.RetCode) );
{$ENDIF}

 Call_NetBios:=Regs.AX;
end;

function NetBIOSErrorStr ( ErrorCode : Word ) : String;
{
! NetBIOSErrorStr
! ---------------
!
! Returns the error code as a explaining strig.
!
!
}
begin
  Case ErrorCode of
   NetBios_Ok               : NetBIOSErrorStr := 'Ok';
   NetBios_IllegalBufLen    : NetBIOSErrorStr := 'Illegal buffer length';
   NetBios_InvalidCmd       : NetBIOSErrorStr := 'Invalid command';
   NetBios_Timeout          : NetBIOSErrorStr := 'Timeout';
   NetBios_MsgIncomplete    : NetBIOSErrorStr := 'Message incomplete';
   NetBios_InvalidSessionNr : NetBIOSErrorStr := 'Invalid session nr';
   NetBios_OutofResources   : NetBIOSErrorStr := 'Out of resources';
   NetBios_SessionClosed    : NetBIOSErrorStr := 'Session closed';
   NetBios_CmdCanceled      : NetBIOSErrorStr := 'Command canceled';
   NetBios_DupLocalName     : NetBIOSErrorStr := 'Duplicate of Localname';
   NetBios_NameTableFull    : NetBIOSErrorStr := 'Nametable full';
   NetBios_Name_Deleted     : NetBIOSErrorStr := 'Name deleted';
   NetBios_SessionTableFull : NetBIOSErrorStr := 'Session table full';
   NetBios_RemNotListning   : NetBIOSErrorStr := 'Remote not listning';
   NetBios_IvalidNameNr     : NetBIOSErrorStr := 'Ivalid name nr';
   NetBios_NameNotFound     : NetBIOSErrorStr := 'Name not found';
   NetBios_InvalidNameFormat: NetBIOSErrorStr := 'Invalid name format';
   NetBios_NameExists       : NetBIOSErrorStr := 'Name exists';
   NetBios_NameDeleted      : NetBIOSErrorStr := 'Name deleted';
   NetBios_ConnectionLost   : NetBIOSErrorStr := 'Connection lost';
   NetBios_DupNetworkName   : NetBIOSErrorStr := 'Dupliacte network name';
   NetBios_BadPacket        : NetBIOSErrorStr := 'Bad packet';
   NetBios_InterfaceBusy    : NetBIOSErrorStr := 'Busy (Try again)';
   NetBios_TooManyCmds      : NetBIOSErrorStr := 'Too Many Commands';
   NetBios_InvalidAdapNr    : NetBIOSErrorStr := 'Invalid adapter nr';
   NetBios_CmdNotCanceled   : NetBIOSErrorStr := 'Command not canceled';
   NetBios_InvalidCancelCmd : NetBIOSErrorStr := 'Invalid cancel command';
   NetBios_HardwareError    : NetBIOSErrorStr := 'Hardware error';
   NetBios_NotCompleted     : NetBIOSErrorStr := 'Not completed';
  end;
end;


procedure Name2Str(Name:NameType; Var Strng:String);
Var B,B1:Byte;
begin
 B1:=16;
  Strng:=Name;

 B1 := 16;

 for B:= 16 downto 1 do
  if Name[B]=#0 then B1:=B;

 Strng[0]:=Chr(B1);
end;

procedure Str2Name(Strng:String; Var Name:NameType);
Var
   B,
   StrLen     : Byte;
begin

  for B:= 1 to 16 do Name[B] := #0;

   StrLen   := Length(Strng);

   if StrLen > 16 then StrLen := 16;

  For B := 1 to StrLen do
   Name[B] := Strng[B];

end;



function NetBIOSAvailable : Boolean;
{
! NetBIOSAvailable
! ----------------
! Returns true if NetBIOS interface routines can be found otherwise false.
!
}
Var
  Regs               : Registers;
  NCB                : NCB_Type;
  VectorTable        : Array[0..255] of LongInt absolute $0000:$0000;

begin

  if VectorTable[$5C] = 0 then
   begin
    NetBIOSAvailable     := False;
    Exit;
   end;



   FillChar(NCB, SizeOf(NCB), #0 );

  NCB.Command      := $FF;       { Invalid command }

  Regs.ES          := Seg(NCB);
  Regs.BX          := Ofs(NCB);

   Intr($5C,Regs);

 NetBiosAvailable := (NCB.RetCode = NetBios_InvalidCmd);
end;

{
!=============================================================================
!                          NetBios function calls.
!
!-----------------------------------------------------------------------------
}

function Reset(Var NCB : NCB_Type) : Word;
begin
 NCB.Command:=NetBiosCmd_Reset;
 Reset := Call_NetBios(NCB);
end;


function Cancel(Var NCB : NCB_Type) : Word;
begin
 NCB.Command:=NetBiosCmd_Cancel;
 Cancel := Call_NetBios(NCB);
end;


function GetAdapterStat(
                        Var NCB           : NCB_Type;
                        Var Status        : AdapterStatusType
                       ) : Word;
begin
 NCB.Command:=NetBiosCmd_AdapterStat;
  NCB.BufferPtr:= Addr(Status);
  NCB.BufferLen:= SizeOf(Status);
 GetAdapterStat:= Call_NetBios(NCB);
end;


function Unlink(Var NCB : NCB_Type) : Word;
begin
 NCB.Command  := NetBiosCmd_Unlink;
 Unlink       := Call_NetBios(NCB);
end;


function AddName(Var NCB : NCB_Type) : Word;
begin
 NCB.Command:=NetBiosCmd_AddName;
 AddName := Call_NetBios(NCB);
end;


function SendBlock(
                   Var NCB         : NCB_Type;
                   Var Buffer
                  ) : Word;
begin
  NCB.Command     := NetBiosCmd_Send;
  NCB.BufferPtr   := Addr(Buffer);
  SendBlock       := Call_NetBios(NCB);
end;
end.
