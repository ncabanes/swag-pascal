 {
 Program Name : Tentools.Pas
 Written By   : Anonymous
 E-Mail       : nothing
 Web Page     : nothing
 Program
 Compilation  : Turbo Pascal 5.0 or later

 Program Description :

 Usefulness for BBS'S and general communications.
 For a detailed description of this code source, please,
 read the file TENTOOLS.DOC. Thank you
 }

{$F+}
Unit TenTools;  { SEE TENTOOLS.DOC for more information !! }

Interface

Uses DOS,CRT;

CONST
   TNTI : Boolean = False; {Initialized False, this Boolean tells whether the
                     the initialization procedure has been run successfully.}
   HPointer : Integer =1;
  TPointer : Integer =1;
   CPointer : Integer =1;

{ The next three parameters can be set dynamically using the
  TenConfig Function}
                                          MaxSendBufferSize : Word = 0;  {Size of largest record to TBsend}
   MaxRecBufferSize : Word = 0;  {Size of largest record to TBreceive}
   MaxReceives : Integer = 0;   {Number of TBReceives to buffer}

{This parameter will change if TenConfig is called with new MAXRECBUFFERSIZE}

{   MaxRecvSets = MaxRecBufferSize div 457 + 1; }

   MAXRCVWAIT : Integer = 30; {Can be changed through SetWait function}

   SCLim : Array[0..6] of Integer = (1,99,12,28,24,60,60);
   SCMon : Array[1..12] of Integer= (31,28,31,30,31,30,31,31,30,31,30,31);
   SCMin : Array[0..6] of Integer = (0,0,1,1,0,0,0);

TYPE

   PW8 = Array[1..8] of Char;              {Used for 8 character password  }
   SID = Array[1..12] of Char;             {Used for 12 character serverID }
   S8 = String[8];
   String80 = String[80];
   S12 = String[12];
   S15 = String[15];
   TID = Real;
   TStamp = Real;
   RcvBlock = Array[1..457] of Char;
   MAXBytes = Array[1..65521] of Byte;
   ChatBytes = Array[1..100] of Byte;
   PathString = String[128];
   NotifyTypes = (Start,Reply,Completion,ExplQueue,NoFF,IDPage,QueueTop);
   NotifySet = Set of NotifyTypes;

{The Pre-Configuration Table and the Configuration Table are the Internal
 Structures within 10Net's Data Segment. These Tables provide information
 that is necessary for some of the functions in this toolbox. They are
 already allocated by 10Net when it is loaded and add no extra memory usage
 to the toolbox. }
   PreConfigurationTable =
   Record
      {First variable located at CTAB-51 bytes or PreCTAB }
      PCT_PhyAddr : Array[1..6] of Byte;   {Physical Adapter Address       }
      PCT_NPID    : Word;               {NPID Table Address             }
      PCT_NCBFST  : Word;               {First NCB in Pool              }
      PCT_LDEVTAB : Word;               {Local Dev Table Addr(FOXCOM)   }
      PCT_EXT_MAP : Word;               {Extended Network Err Table Addr}
      PCT_SDEVTAB : Word;               {SDEV Address                   }
      PCT_RESV1   : Integer;
      PCT_RBUFCNT : Byte;                  {Receive Buffer Counter         }
      PCT_CBUF_CNT: Byte;                  {Collect Buffer Counter         }
      PCT_TUF     : Word;               {TUF Address                    }
      PCT_ENABLE  : Byte;                  {Enable Flag                    }
      PCT_KEEP    : Byte;                  {FCB Keep Flag                  }
      PCT_RESV2   : Integer;
      PCT_DS6F    : Integer;               {Dropped Send 6F Count          }
      PCT_BFRST   : Integer;               {Buffer Chain                   }
      PCT_RESV3   : Integer;
      PCT_RTY     : Integer;               {Broadcast Retry Count          }
      PCT_TOVAL   : Byte;                  {#FFFF Loops before retry       }
      PCT_UFH     : Word;               {UFH Address                    }
      PCT_NETH    : Word;               {NetH Address                   }
      PCT_LTAB    : Word;               {LTab Address                   }
      PCT_SFH     : Word;               {SFH Address                    }
      PCT_FTAB    : Word;               {FTAB Address                   }
      PCT_RLTAB   : Word;               {RLTAB Address                  }
      PCT_SMI     : Word;               {Semaphore Address              }
      PCT_NTAB    : Word;               {NTAB Address                   }
     End;

     ConfigurationTable =
      Record
      CT_REDIR    : Word;               {Redirection Table Address      }
                                           {sometimes called CT_ADDR       }
      CT_NUM      : Byte;               {RDR_TAB Entries- 5(LPT1-3 & AUX-2)}
      CT_LNAME    : PW8;                   {Login Name                     }
      CT_NID      : Array[1..15] of Char;  {Node ID                        }
      CT_UNODE    : Array[1..3] of Char;   {Unique portion of Node Address }
      CT_FLG      : Byte;                  {Flag (DPC - Bit 6)             }
      CT_CFLG     : Byte;                  {Chat permit flag               }
      CT_PSFLG    : Byte;                  {Print and Submit Flag          }
      CT_NETFLGS  : Array[1..2] of Byte;   {10Net System Status Flag       }
      CT_L_INT    : Byte;                  {Last Interrupt                 }
      CT_L21      : Byte;                  {Last Interrupt 21              }
      CT_L6F      : Byte;                  {Last Interrupt 6F              }
      CT_L60      : Byte;                  {Last Interrupt 60              }
      CT_BFLG     : Byte;                  {Break Flag                     }
      CT_BTYP     : Integer;               {Break Type                     }
      CT_TALY     : Array[1..6] of Integer;{Send Tallies                   }

      CT_PENDF    : Byte;                  {DO_COND Pending COMMAND MAP    }
      CT_CERRF    : Byte;                  {Reserved                       }

      CT_RESV2    : Array[1..5] of Byte;   {Reserved                       }

      CT_CB       : Byte;                  {CB Channel                     }
      CT_CBCNT    : Byte;                  {Send6F on Que                  }
      CT_CBCHL    : Array[1..9] of Byte;   {Chnls 1-9 Activity             }
      CT_GATE     : Byte;                  {Bits: 1-RS232Gate, 2-Send6FGate}
      CT_RGATE    : Array[1..2] of Integer;{Dbl word ptr into Gate         }
      CT_SGATE    : Array[1..2] of Integer;{Dbl word ptr into 10Net Send   }
      CT_TIMR     : Integer;               {Address of Timer Blocks        }

      {Those variables below are only implemented in 10Net 4.1 and above}
      CT_CTSTO    : Integer;               {Datagram send time out value   }
      CT_DGRETRY  : Byte;                  {Datagram retry count           }
      CT_NCBMSES  : Byte;                  {Max Netbios sessions           }
      CT_NCBMCOMM : Byte;                  {Max Netbios command blocks     }
      CT_BUFFNUM  : Byte;                  {Number of total buffers        }
      CT_CLCTNUM  : Byte;                  {Number of Collect buffers      }
      CT_CLCTFST  : Integer;               {Offs of 1st coll. buffer chain }
      CT_DEVMASK  : Word;                  {Shared disk drives bit mask    }
      CT_DEVPRN   : Byte;                  {Shared LPT bit mask            }
      CT_DEVCOM   : Byte;                  {Shared COM bit mask            }
      CT_RESV3    : LongInt;               {Reserved}
      CT_DOSVER   : Integer;               {Dos Version(Int21/30)          }
      CT_PHYSDRVS : Byte;                  {Number of physical drives      }
      CT_RESV4    : Array[1..13] of Byte;  {Reserved}
      CT_SRVNUM   : Byte;                  {Server NCB Name Number         }
      CT_RDRNUM   : Byte;                  {Redirector NCB Name Number     }
      CT_MSGNUM   : Byte;                  {Messenger NCB Name Number      }
      CT_RESV5    : LongInt;               {Reserved}
      CT_CHATCALL : Integer;               {Chat Call Key                  }
      CT_CHATIME  : Integer;               {Chat Time Out                  }
      CT_AUTOSP1  : Byte;                  {AutoSP Flag (0=No AutoSp)      }
      CT_AUTOSP2  : Byte;                  {TMR_TIC=CT_AutoSP1*Ct_AutoSP2  }
   End;

{ What follows are structures used in function calls}

   TenNetTableRec = Record
       Alloc : Integer;
        Free : Integer;
    Reserved : Integer;
     end;

   GetTableDataRec = Record
           NodeID : SID;
           RES1   : Byte;
       ServerFlag : Byte;                  { 0=Worker, 1=Server           }
       BufferSize : Integer;               { Size of Receive Buffers      }
      TotalMemory : Integer;               { Total RAM memory in K        }
      TenNetMemory : LongInt;               { Memory alloc. to 10Net (bytes}
      AvailMemory : LongInt;               { Available Memory in Bytes    }
      TenNetTables : Array[1..22] of
                    TenNetTableRec;
       DeviceList : Array[1..64] of Char;
       SecurityFN : Array[1..64] of Char;
          AuditFN : Array[1..64] of Char;
     PrimaryDrive : Array[1..2] of Char;
        OtherJunk : Array[1..48] of Char;
    end;

   LogRec = Record
      UserName : PW8;
      PassWord : PW8;
      NodeName : SID;
   end;

   SendFormat = Record
      RNode : SID;
      DataBytes : Integer;
   End;

   PRec = Record
      TransID : TID;     {6 bytes}
       Packet : Byte;    {1}
     TPackets : Byte;    {1}
        TType : Integer; {2}
      TLength : Integer; {2}
     RespType : Byte;    {1}
   end;

   RecSet = set of 1..144;

   DateTimeRec = Record
           Year,Month,Day,Hour,Minute,Second : Integer;
    End;

   RecvRec = Record
       Sender : S12;
      TransID : TID;
    TrackRecv : RecSet;
        TType : Integer;
      TLength : Integer;
     RespType : Byte;
        RTime : Real;
           CB : Boolean;
   end;

   RecvData = Array[1..143] of RcvBlock;


   HeapRecBlock = Array[1..1310] of RecvRec;
   HeapDataBlock = Array[1..2040] of ^RecvData;

   ChRec = Record
        MsgLength : Integer;
        ChatText : Array[1..101] of Char;
   end;

   NodeRec = Record
        NID : SID;
        NT : Byte;
        UID : Array[1..8] of Char;
        Ver : Array[1..3] of Char;
   end;
   NARec = S12;
   NWRec = Record
        NID : SID;
        Ver : Array[1..4] of Byte;
   end;
   NBuffer = Array[1..140] of NodeRec;
   NABuffer = Array[1..140] of NARec;
   NWBuffer = Array[1..140] of NWRec;

   SDRec = Record             {MountList/NetUse List Record Structure}
         ServerID : S12;
          RPath : PathString;
     end;

   DriveArray = Array['A'..'Z'] of SDRec;

   PrintArray = Array['1'..'3'] of SDRec;

   LogArray = Array[0..19] of S12;
   DeviceArray = Array[0..24] of S8;
   SDev = Record         {used in Get/Set/Delete/Get User Shared Device}
        Alias : PW8;
        Path : Array[1..64] of Char;
        PassWord : PW8;
        Access : Byte;
        Mask : Array[1..4] of Char;
     end;


  StatusBlock = Record
      S_Name : Array[1..8] of Char;  {User Name}
      S_Flag : Byte;                 {0-user node,1-superstation,2-gate,
                                      3-gateactive,4-on more than 2 superstns,
                                      5-Reserved}
      S_Srvr : Array[1..24] of Byte; {Superstation Nodes logged into (reserved)}
      S_NID : SID;                   {NodeID}
      Reserved0 : Array[1..2] of Byte;

      {From Superstations:}

      S_SDRV : Array[1..2] of Byte;  {Drives avail: Bits 0-15/A-P}
      S_UFlag : Byte;                {User Service Flag:
                                      0-Mail for you     1-News for you
                                      2-Calendar for you 3-Mail for Node
                                      4-Submit ON        6-Print Permit ON
                                      6-Gate                               }
      S_SPRTRT : Byte;               {Bit 0-7 set for Printers 1-3    }
      Reserved1 : Array[1..3] of Byte;
      S_PRIU   : Byte;               {Primary Unit (0=A,1=B,etc) }
      Reserved2 : Byte;
      LoggedNodes : Array[1..444] of Char; {Logged on NodeIDS}
      S_Time : Array[1..3] of Byte;  {Time: SEC/MIN/HR}
      S_Date : Array[1..3] of Byte;  {Date: DAY/MON/YR-1980}
      Reserved3 : Array[1..6] of Byte;
  end;

   SpoolBlock = Record
    UCode : Integer;
    UFile : Array[1..11] of Char;
    UNote : Byte;
    UDays : Byte;
    UDVC : Byte;
    ULen : Integer;
    UArea : Byte;
   end;

{These variable declarations allocate approximately 1660 bytes of memory
 to the Tentools Unit}

VAR
   I10 : Integer;
   TenTest : Word;
   TenRegs : Registers;
   SendSet : SendFormat;
   SendBuffer : Array[1..470] of Char;
   ReceiveBuffer : Array[1..484] of Byte;
   LogData : LogRec;
   PreConfig : ^PreConfigurationTable;
   ConfigTable : ^ConfigurationTable;
   UserName : String[8];
   DataBuffer : Array[1..470] of Byte;
   PacketRec : PRec;
   ChatRec : ChRec;
   TBR : ^HeapRecBlock;
   TBD : ^HeapDataBlock;
   MaxRecvSets : Integer;
   NodeArray : ^NBuffer;
   NAArray : ^NABuffer;
   NWArray : ^NWBuffer;
   SpoolSettings : SpoolBlock;
   Spooling : Boolean;

{ The Procedures/Functions }

Function TimeStamp : Real;

Function StampAge(StartTime : Real): LongInt;

Function Loaded : Boolean;

Function Chat(NodeID : S12; VAR DBuffer {:String[n]} ) : Word;

Function Status(NodeName : S15; VAR SBlock : StatusBlock): Word;

Function NODEName : S12;

Function Login(ServerID : S12;PW10Net : S8): Word;

Function Logoff(ServerID : S12): Word;

Function Mount(ServerID : S12; LocalDevice,RemoteDevice : Char) : Word;

Function UnMount(LocalDrive : Char) : Word;

Function Send(NodeID : S12; VAR DBuffer; DLength :Integer): Word;

Function Receive(VAR DBuffer; Secs : Word; VAR Available : Integer; VAR CBMessage : Boolean): Word;

Function GetRemoteMemory(NodeID : S12; VAR DBuffer; VAR DLength : Integer;
                         RemSeg,RemOfs : Word) : Word;

Procedure SetCBChannel(CBChannel : Byte);

Function TBSend(NodeID : S12;VAR DBuffer;DLength : Integer;TransactionID : TID;
                TransType : Integer;ResponseType : Byte) : Word;

Function TBReceive(VAR SenderID: S12;VAR DBuffer;VAR DLength : Integer;
                   VAR TransactionID : TID;VAR TransType : Integer;
                   VAR Available : Integer;VAR CB : Boolean): Word;

Function Nodes(VAR NodeBuffer;VAR MaxNodes : Integer;SuperstationsOnly : Boolean) : Word;

Function MountList(VAR MountTable : DriveArray;VAR PrintTable : PrintArray;VAR TableEntries : Integer): Word;

Function LogList(VAR Logins : LogArray;VAR TableEntries : Integer): Word;

Function GetTableData(VAR TableBuffer : GetTableDataRec): Word;

Function MountsAvail : Integer;

Function TenConfig(MaxSendRec,MaxRecvRec : Integer;MaxRecs : Integer) : Word;

Function SetWait(WaitLimit : Integer): Word;

Procedure SetUserName(UName : S8);

Function Get10Time(NodeName : S15 ;VAR TenTime : DateTimeRec) : Word;

Function GetDevices(ServerID : S12;VAR Device : DeviceArray;VAR DeviceCount : Integer): Word;

Function NetUse(ServerID : S12; LocalDrive : Char; RemoteDevice : String;NetUsePassWord : S8) : Word;

Function UnUse(LocalDrive : Char) : Word;

Function Submit(ServerID : S12; CommandLine : String): Word;

Function SetSpool(Printer : Byte; SpoolName : S12; Notification : NotifySet; RDays : Byte): Word;

Function OpenSpool(NewSpoolName : S12) : Word;

Function CloseSpool : Word;

Function UpCase8(Str_8 : S8): S8;

Function UpCase12(Str_12 : S12): S12;

{******************************************************************************}


Implementation

Function UpCase12(Str_12 : S12): S12;
{Expands and "Upcases" a 12 character string}
VAR I : Integer;
Begin
   For I:=1 to Length(Str_12) do Str_12[I]:=Upcase(Str_12[I]);
   While Length(Str_12)<12 do Str_12:=Str_12+' ';
   UpCase12:=Str_12;
End;

Function UpCase8(Str_8 : S8): S8;
{Expands and "Upcases" an 8 character string}
VAR I : Integer;
Begin
   For I:=1 to Length(Str_8) do Str_8[I]:=Upcase(Str_8[I]);
   While Length(Str_8)<8 do Str_8:=Str_8+' ';
   UpCase8:=Str_8;
End;


Function TimeStamp : Real;
{Returns a timestamp of 6 bytes ordered, Year,Month,Day,Hour(24),Minute,
 Second }
VAR
   TS : Array[1..6] of Byte;
   TStmp : Real absolute TS;
   Year,Month,Day,DOW,Hour,Minute,Sec,Hund : Word;
Begin
   GetTime(Hour,Minute,Sec,Hund);
   GetDate(Year,Month,Day,DOW);
   Year:=Year mod 100;
   TS[1]:=Byte(Year);
   TS[2]:=Byte(Month);
   TS[3]:=Byte(Day);
   TS[4]:=Byte(Hour);
   TS[5]:=Byte(Minute);
   TS[6]:=Byte(Sec);
   TimeStamp:=TStmp;
End;


Function StampAge(StartTime : Real): LongInt;
{ Returns the difference in seconds between the currenttime and the
"Starttime" timestamp.}
VAR
   TS1 : Array[1..6] of Byte absolute StartTime;
   TStamp2 : Real;
   TS2 : Array[1..6] of Byte absolute TStamp2;
   IArray : Array[1..6] of Integer;
   SA : Longint;
   I : Integer;
   Leaps : Integer;

 {==========}
   procedure TDec(Pos : Integer);
   begin
      if Pos>0
      then
       begin
          If (TS2[Pos]=SCMin[Pos])
          then
           begin
              TDec(Pos-1);
              If (Pos=3) then TS2[Pos]:=SCMon[TS2[2]]
              else
               begin
                  If Pos>3 then TS2[Pos]:=SCLim[Pos]-1
                  else TS2[Pos]:=SCLim[Pos];
               end;
           end
          else
          TS2[Pos]:=TS2[Pos]-1;
       end;
   end;
 {==========}

Begin
   FillChar(IArray,12,0);
   TStamp2:=TimeStamp;
   {Count leaps if necessary}
   Leaps:=0;
   If TS2[1]>(TS1[1]+1) then for I:=TS1[1]+1 to TS2[1]-1 do
    if (I mod 4 = 0) then Leaps:=Leaps+1;
   If TS2[1]=TS1[1]+1 then if (((TS1[1] mod 4 = 0) and (TS1[2]<=2)) or
   ((TS2[1] mod 4 =0) and (TS2[2]>2))) then Leaps:=Leaps+1;
   If (((TS1[1]=TS2[1]) and (TS1[1] mod 4 = 0)) and ((TS1[2]<=2)and (TS2[2]>2)))
    then Leaps:=Leaps+1;
   For I:=6 downto 1 do
    begin
       If (TS2[I]<TS1[I])
       then
        begin
           TS2[I]:=TS2[I]+SCLim[I];
           TDec(I-1);
        end;
       IArray[I]:=TS2[I]-TS1[I];
    end;
   IArray[3]:=IArray[3]+Leaps;
   {Using leaps now to count days}
   Leaps:=0;
   I:=TS2[2];
   While I<>TS1[2] do
    begin
       Leaps:=Leaps+SCMon[I];
       I:=I+1;
       If I>12 then I:=1;
    end;
   If IArray[1]>0 then Leaps:=Leaps+IArray[1]*365;
   Leaps:=Leaps+IArray[3];
   SA:=Leaps;
   SA:=SA*24+IArray[4];
   SA:=SA*60+IArray[5];
   StampAge:=SA*60+IArray[6];
End;


Function Loaded : Boolean;
{ Is 10Net Loaded? }
TYPE
  LoadCheck = Array[1..4] of Char;
VAR
  LPtr : ^LoadCheck;
Begin
   With TenRegs do
    begin
       AX:=$356F;
       MSDos(TenRegs);
       LPtr:=Ptr(ES,BX-4);
       If (LPtr^[4]+Lptr^[3]+LPtr^[2]+LPtr^[1]='1XOF')
       then Loaded:=True
       else Loaded:=False;
    end;
 end;

Function NODEName : S12;
{Returns the current nodename }
VAR
 I : Integer;
 NN : S12;
Begin
   NN:='';
   If TNTI then for I:=1 to 12 do NN:=NN+ConfigTable^.CT_NID;
   NodeName:=NN;
End;



Function Chat(NodeID : S12; VAR DBuffer {:String[n]} ) : Word;
{ The DBuffer should be a Turbo Pascal String (length indicator in byte 0)
  The string should be no more than 100 bytes long. This function sends a
  10Net Chat message to the NodeID specified. }
VAR
   I : Integer;
   LI : ^Byte;
   PBuffer : ^ChatBytes;
Begin
   With TenRegs do if TNTI then
    begin
       For I:=1 to Length(NodeID) do LogData.NodeName[I]:=NodeID[I];
       If (Length(NodeID)<12) then for I:=Length(NodeID)+1 to 12 do
        LogData.NodeName[I]:=#32;
       For I:=1 to 8 do LogData.Password[I]:=#32;
       For I:=1 to 8 do LogData.UserName[I]:=ConfigTable^.CT_LName[I];
       PBuffer:=@DBuffer;
       LI:=@DBuffer;
       ChatRec.MsgLength:=Integer(LI^)+2;
       If ChatRec.MsgLength>102
       then
        begin
           ChatRec.MsgLength:=102;
           LI^:=100;
        end;
{@#@}       Move(PBuffer^[2],ChatRec.ChatText,ChatRec.MsgLength-1);
       AX:=$0A00;
       DS:=Seg(LogData);
       BX:=Ofs(LogData);
       DX:=Ofs(ChatRec);
       Intr($6F,TenRegs);
       If Not ((Flags and $01)=0)
       then Chat:=AX
       else Chat:=0;
    end
  else
    begin
       Writeln('TENTOOLS Not Initialized');
       Halt;
    end;
end;

Function Status(NodeName : S15; VAR SBlock : StatusBlock): Word;
{ Returns a Block of Status information from the Nodename requested if
  that node is on the network.}
TYPE
   A20 = Array[1..23] of Char;
VAR
   SBP : ^A20;
   I : Integer;
Begin
   If TNTI then with TenRegs do
    begin
       NodeName:=Upcase12(NodeName);
       FillChar(SBlock,Sizeof(StatusBlock),0);
       While Length(NodeName)<15 do NodeName:=NodeName+' ';
       Move(NodeName[1],SBlock,15);
       SBP:=@SBlock;
       Move(ConfigTable^.CT_LName,SBP^[16],8);
       AX:=$0200;
       DS:=Seg(SBlock);
       DX:=Ofs(SBlock);
       Intr($6F,TenRegs);
       If Not ((Flags and $01)=0)
       then Status:=AX
       else Status:=0;
    end
   else
    begin
       Writeln('TENTOOLS Not Initialized');
       Halt;
    end;
end;
Function Get10Time(NodeName : S15 ;VAR TenTime : DateTimeRec) : Word;
{Returns the Date and Time in a DateTimeRec Record from the Node Requested.}

VAR
   TempStatus : ^StatusBlock;
Begin
   GetMem(TempStatus,512);
   TenTest:=Status(NodeName,TempStatus^);
   If (TenTest=0)
   then with TempStatus^ do
    begin
       with TenTime do
        begin
           Year:=S_Date[3]+1980;
           Month:=S_Date[2];
           Day:=S_Date[1];
           Hour:=S_Time[3];
           Minute:=S_Time[2];
           Second:=S_Time[1];
           Get10Time:=0;
        end;
    end
   else Get10Time:=TenTest;
   FreeMem(TempStatus,512);
End;

Function Login(ServerID : S12;PW10Net : S8): Word;
{ Logs into the requested server. }
VAR
  I : Integer;
Begin
   With TenRegs do if TNTI then
    begin
       Move(ConfigTable^.CT_LName,LogData.UserName,8);
       PW10Net:=Upcase8(PW10Net);
       For I:=1 to 8 do LogData.Password[I]:=PW10Net[I];
       ServerID:=Upcase12(ServerID);
       Move(ServerID[1],LogData.NodeName,12);
{       Writeln(LogData.UserName,'<');
       Writeln(LogData.PassWord,'<');
       Writeln(LogData.NodeName,'<');
}      AX:=$0000;
       DS:=Seg(LogData);
       DX:=Ofs(LogData);
       Intr($6F,TenRegs);
       If Not ((Flags and $01)=0)
       then Login:=AX
       else Login:=0;
(*       Case AX of
            $0000 : Write('Good Login');
            $01FF : Write('No response from Superstation');
            $02FF : Write('Network Error');
            $03FF : Write('Invalid password');
            $04FF : Write('No Local Buffer available');
            $05FF : Write('Superstation device is not available');
            $06FF : Write('Node Already logged in under different name.');
            $07FF : Write('Login not valid from this node ID.');
            $09FF : Write('Node is not a superstation');
            $0AFF : Write('Node-ID already in use by another station!');
            else Write('ErrorCode ',AX);
           end; {Case}
 *)
    end
  else
   begin
      Writeln('TENTOOLS Not Initialized');
      Halt;
   end;
end;

Function Logoff(ServerID : S12): Word;
{ Logs off the requested server. }
Begin
   While Length(ServerID)<12 do ServerID:=ServerID+' ';
   With TenRegs do if Loaded then
    begin
       AX:=$0100;
       DS:=Seg(ServerID);
       DX:=Ofs(ServerID)+1;
       Intr($6F,TenRegs);
       If Not ((Flags and $01)=0)
       then Logoff:=AX
       else Logoff:=0;
    end
   else Logoff:=$FFFF;
End;

Function Mount(ServerID : S12; LocalDevice,RemoteDevice : Char) : Word;
{ For Drive mounting, mounts drive REMOTEDRIVE at SERVERID as LOCALDRIVE
 locally; for printer mounting, use "1" for LPT1, etc. }
VAR
 LDrive : Integer;
Begin
   With TenRegs do if Loaded then
    begin
       If LocalDevice in ['A'..'Z'] then LDrive:=Ord(LocalDevice)-65
       else if LocalDevice in ['1'..'3'] then LDrive:=Ord(LocalDevice)-49;
       While Length(ServerID)<12 do ServerID:=ServerID+' ';
       AX:=$1700+LDrive;
       DX:=Ofs(ServerID)+1;
       DS:=Seg(ServerID);
       BL:=Ord(RemoteDevice);
       Intr($6F,TenRegs);
       If ((Flags AND 1)<>0)
       then
        begin
           Mount:=AX;
{           TextColor(White+Blink);
           Writeln('Error: ',AX);}
        end
       else Mount:=0;
    end
   else Mount:=$FFFF;
end;


Function UnMount(LocalDrive : Char) : Word;
{ Unmounts previously mounted drive or printer }
VAR
 LDrive : Integer;
 LPrint : Integer absolute LDrive;
Begin
   If Loaded then
   With TenRegs do
    begin
       If (LocalDrive in ['A'..'Z'])
       then
        begin
           LDrive:=Ord(LocalDrive)-65;
           AX:=$1800+LDrive;
           BL:=0;
        end
       else if (LocalDrive in ['1'..'3'])
       then
        begin
           LPrint:=Ord(LocalDrive)-49;
           AX:=$1800+LPrint;
           BL:=1;
        end;
       Intr($6F,TenRegs);
       If ((Flags AND 1)<>0)
       then UnMount:=AX
       else UnMount:=0;
    end
   else UnMount:=$FFFF;
end;

Function NetUse(ServerID : S12; LocalDrive : Char; RemoteDevice : String;NetUsePassWord : S8) : Word;
{ Attaches to a Device at a Remote Server. The RemoteDevice can be an ALIAS }
VAR
   I : Integer;
   DriveString : S8;
   SERVERZ : S12;
   RemoteString : String;
Begin
   If Loaded
   then with TenRegs do
    begin
       SERVERZ:=ServerID;
       For I:=1 to Length(SERVERZ) do SERVERZ[I]:=Upcase(SERVERZ[I]);
       While ServerZ[Length(ServerZ)]=' ' do Dec(ServerZ[0]);
       For I:=1 to Length(NetUsePassword) do NetUsePassword[I]:=Upcase(NetUsePassword[I]);
       BL:=4;
       CX:=0;
       DriveString:=Upcase(LocalDrive)+':'+#0;
       DS:=Seg(DriveString);
       SI:=Ofs(DriveString)+1;
       For I:=1 to Length(RemoteDevice) do RemoteDevice[I]:=Upcase(RemoteDevice[I]);
       RemoteString:='\\'+SERVERZ+'\'+RemoteDevice+#0+NetUsePassWord;
       While RemoteString[Length(RemoteString)]=' ' do Dec(RemoteString[0]);
       RemoteString:=RemoteString+#0;
       ES:=Seg(RemoteString);
       DI:=Ofs(RemoteString)+1;
       AX:=$5F03;  {uses the Dos function call "Redirect Device"}
       MSDOS(TenRegs);
       If ((Flags AND 1)<>0)
       then
        NetUse:=AX
       else
        NetUse:=0;
    end
   else NetUse:=$FFFF;
End;


Function UnUse(LocalDrive : Char) : Word;
{ Detaches from a shared device at a remote server. The attachment was made
through a Net Use (or NetUse), and the local drive letter is all that is
needed to detach}
VAR
   DriveString : S8;

Begin
   If Loaded
   then with TenRegs do
    begin
       DriveString:=Upcase(LocalDrive)+':'+#0;
       DS:=Seg(DriveString);
       SI:=Ofs(DriveString)+1;
       AX:=$5F04;
       MSDos(TenRegs);
       If ((Flags AND 1)<>0)
       then
        UnUse:=AX
       else
        UnUse:=0;
    end
   else UnUse:=$FFFF;
End;


Function Send(NodeID : S12; VAR DBuffer; DLength :Integer): Word;
{Send a data packet on the network to NODEID ( or on a CB Channel if
NODEID is CB##, limited to 470 byte packets. Used within the Toolbox to
accomplish TBSend, which allows large records to be sent.}

VAR
 I,SR : Integer;
 CBL : String[2];
Begin
   If DLength<=470
   then
    begin
      NodeID:=Upcase12(NodeId);
      Move(NodeID[1],SendSet.RNode,12);
      SendSet.DataBytes:=DLength;
      Move(DBuffer,SendBuffer,DLength);
      If ((NodeID[1]='C') and (NodeID[2]='B'))
      then
       begin
          CBL:=Copy(NodeID,3,2);
          If CBL[2]=' ' then CBL[0]:=#1;
          VAL(CBL,I,SR);
          If SR=0
          then
           begin
              SendSet.RNode[2]:=#0;
              SendSet.RNode[1]:=Char(I);
           end;
       end;
      With TenRegs do
       begin
          DS:=Seg(SendSet);
          BX:=Ofs(SendSet);
          DX:=Ofs(SendBuffer);
          AX:=$0400;
          Intr($6F,TenRegs);
          If Flags and 1 <> 0 then
          Send:=AX
          else Send:=0;
       end;
    end
   else Send:=$FFFF;
End;

Function Receive(VAR DBuffer; Secs : Word; VAR Available : Integer; VAR CBMessage : Boolean): Word;
{Receive a data packet on the network in the structure below:
         data           bytes
         =====================
         SenderNodeID : 12
         Len          : 2
         Data         : (Len)
  Available is set to the number of packets available INCLUDING the
  current message. Receives data sent through the SEND function, which is
  limited to data structures of length 470 or less. TBSend and TBReceive
  (which use Send and Receive) can be used for larger structures.
}
VAR
 TestString : ^String80;
Begin
   TestString:=@DBuffer;
   CBMessage:=False;
   With TenRegs do
    begin
       DX:=Ofs(DBuffer);
       DS:=Seg(DBuffer);
       CX:=Secs;
       AX:=$0500;
       Intr($6F,TenRegs);
       If (Flags and 1 <> 0) then
       Receive:=AX
       else
        begin
           Receive:=0;
           If AL=$FE then CBMessage:=True;
           Available:=ConfigTable^.CT_CBCNT+1;
        end;
    end;
End;




Function GetRemoteMemory(NodeID : S12; VAR DBuffer; VAR DLength : Integer; RemSeg,RemOfs : Word) : Word;
{Copy a section of memory from a remote node to DBuffer (maximum of 470 bytes) }
VAR
 I : Integer;

Begin
   With TenRegs do
    begin
       AX:=$1400;
       BX:=RemSeg;
       CX:=DLength;
       SI:=RemOfs;
       DS:=Seg(DBuffer);
       DX:=Ofs(NodeID)+1;
       NodeID:=Upcase12(NodeID);
       DI:=Ofs(DBuffer);
       Intr($6F,TenRegs);
       If (Flags and 1)>0
       then GetRemoteMemory:=AX
       else
        begin
           DLength:=CX;
           GetRemoteMemory:=0;
        end;
    end;
End;

Procedure SetCBChannel(CBChannel : Byte);
{      This procedure will set your "Listening" Channel to the CBCHANNEL (1
 through 40 are available) specified. TBSends to this CBChannel from other
 nodes will be available here through TBReceive. TBSends to other CBChannels
 will not be seen here. TBSends directed specifically to this node will also
 be seen here, of course.
       The advantages of CB messaging are that many nodes can be setup to
 receive messages on a particular channel, and the sender will not be held
 up waiting for a network handshake to tell him that his Send was Received.
}
Begin
   If TNTI
   then
    begin
       ConfigTable^.CT_CB:=CBChannel;
    end;
End;

Function TBSend(NodeID : S12;            {Node to send to                 }
           VAR DBuffer;                   {The data record                 }
                DLength : Integer;        {Length (bytes) of data          }
          TransactionID : TID;            {Tag to identify record (4 bytes)}
              TransType : Integer;        {Transaction Type - (external to
                                          this toolbox) an integer type used
                                          to maintain that one is receiving
                                          only the correct type of records.}
           ResponseType : Byte            {Not implemented}


              ) : Word;
{ TBSend will send a large interapplication message (DBuffer) of length
DLENGTH across the network. The TransactionID is user defineable and can be
used to acknowledge the receipt or processing of a record to the originator.
TransType, optional, can be used to identify the type of processing required
of a record. The data in DBuffer can be of any structure.
     The message is effectively broken into packets, and sent with a
"packet marker" to assist in its reconstruction when received. Unique
Transaction IDs is essential for records larger than 457 bytes to maintain
unique record identity. Packet Data consists of a PRec (see data Type
definitions) and 457 bytes of the DataRec.
     The network provides handshaking with Sends and Receives if they are
directed to a particular node. If CB# is used instead, there is no
handshaking provided. If a node is specified, and it is not currently
available or its 10Net SBuffers buffering is full, the sending node will
be stuck waiting for a timeout or until the receiver or buffer space appears.
For this reason, in some applications which can't be held up waiting, it is
wise to use CB channel communication. (See the "SetCBChannel" function for a
discussion of its usage.)

}
VAR
RetCode : Word;
PBuffer : ^MaxBytes;
ILength : Integer;
Begin
   If TNTI
   then
    begin
       If DLength<MaxSendBufferSize
       then
        begin
           NodeID:=Upcase12(NodeID);
           With PacketRec do
            begin
               PBuffer:=@DBuffer;
               TransID:=TransactionID;
               TPackets:=DLength div 457;
               If (DLength mod 457>0) then TPackets:=TPackets+1;
               TType:=TransType;
               TLength:=DLength;
               RespType:=ResponseType;
               For Packet:=1 to TPackets do
                begin
                   If Packet=TPackets then ILength:=DLength mod 457
                   else ILength:=457;
                   Move(PacketRec,SendBuffer,13);
                   Move(PBuffer^[(Packet-1)*457+1],SendBuffer[14],ILength);
                   RetCode:=Send(NodeID,SendBuffer,ILength+13);
                   If RetCode<>0
                   then Packet:=TPackets;
                end;
               If RetCode<>0 then TBSend:=RetCode else TBSend:=0;
            end;
        end
       else
        begin
           Writeln('');
           Writeln('Record Size too large for TenTools Configuration.');
           Writeln('MaxSendBufferSize=',MaxSendBufferSize);
           Writeln('Record not Sent!');
           Delay(1000);
        end;
     end
    else
     begin
        Writeln('TENTOOLS Not Initialized');
        Halt;
     end;
End;

Function TBReceive( VAR SenderID: S12;      {Sending NodeID : String12       }
                    VAR DBuffer;           {Variable (record) to receive    }
                    VAR DLength : Integer; {Maximum length record to receive}
              VAR TransactionID : TID;     {See description of TBSend       }
                  VAR TransType : Integer; {See description of TBSend       }
                  VAR Available : Integer; {Number of records available
                                            including the one passed back   }
                         VAR CB : Boolean) {Was this a CB transmission?     }
                         : Word;  {Return code indicates a 10Net error($XXFF)
                                   or an error in a passed parameter ($FFXX)}
VAR
   LLRs,LLRet,I : Integer;
   SenderNode : SID absolute ReceiveBuffer;
   RLength : ^Integer;
   RPack : ^PRec;
   RcvData : ^Byte;
   CBM : Boolean;
Begin
   If TNTI
   then
    begin
      RLength:=@ReceiveBuffer[13];
      RPack:=@ReceiveBuffer[15];
      RcvData:=@ReceiveBuffer[15+Sizeof(RPack^)];
      Repeat {process 10net receives}
         LLRet:=Receive(ReceiveBuffer,0,LLRs,CBM);
         If LLRet=0
         then
          begin
             CPointer:=TPointer;
             If RPack^.Packet=1
             then CPointer:=HPointer
             else while ((TBR^[CPointer].TransID <> RPack^.TransID)
             and (CPointer<>HPointer)) do
              begin
                 CPointer:=CPointer+1;
                 If CPointer>MaxReceives then CPointer:=1;
              end;
             If CPointer=HPointer
             then
              begin
                 {beginning a new record}
                 HPointer:=HPointer+1;
                 If HPointer>MaxReceives then HPointer:=1;
                 If TPointer=HPointer
                 then
                  begin
                     TPointer:=TPointer+1;
                     If TPointer>MaxReceives then TPointer:=1;
                  end;
                 TBR^[CPointer].Sender:='';
                 For I:=1 to 12 do
                 TBR^[CPointer].Sender:=TBR^[CPointer].Sender+SenderNode[I];
                 TBR^[CPointer].TransID:=RPack^.TransID;
                 TBR^[CPointer].TType:=RPack^.TType;
                 TBR^[CPointer].RTime:=TimeStamp;
                 TBR^[CPointer].TrackRecv:=[];
                 For I:=1 to RPack^.TPackets do
                 TBR^[CPointer].TrackRecv:=TBR^[CPointer].TrackRecv+[I];
                 TBR^[CPointer].Resptype:=RPack^.RespType;
                 TBR^[CPointer].TLength:=RPack^.TLength;
                 TBR^[CPointer].CB:=CBM;
              end;
             Move(RcvData^,TBD^[CPointer]^[RPack^.Packet],RLength^-Sizeof(RPack^));
             TBR^[CPointer].TrackRecv:=TBR^[CPointer].TrackRecv-[RPack^.Packet];
          end;
      Until LLRet<>0;
      {Count number of records ready, keeping track of the first.}
      Available:=0;
      CPointer:=TPointer;
      While CPointer<>HPointer do
       begin
          If TBR^[CPointer].TrackRecv=[]
          then
           begin
              Available:=Available+1;
              If Available=1
              then
               begin
                  SenderID:=TBR^[CPointer].Sender;
                  DLength:=TBR^[CPointer].TLength;
                  If TBR^[CPointer].TLength>MaxRecBufferSize
                  then DLength:=MaxRecBufferSize;
                  TransactionID:=TBR^[CPointer].TransID;
                  TransType:=TBR^[CPointer].TType;
                  CB:=TBR^[CPointer].CB;
                  Move(TBD^[CPointer]^,DBuffer,DLength);
                  If CPointer<>TPointer
                  then Move(TBR^[TPointer],TBR^[CPointer],Sizeof(TBR^[1]));
                  TPointer:=TPointer+1;
                  If TPointer>MaxReceives then TPointer:=1;
               end;
           end
          else if ((CPointer=TPointer) and (StampAge(TBR^[CPointer].RTime)>MAXRCVWAIT))
          then
           begin
              TPointer:=TPointer+1;
              If TPointer>MaxReceives then TPointer:=1;
           end;
          CPointer:=CPointer+1;
          If CPointer>MaxReceives then CPointer:=1;
       End;
      If Available>0 then TBReceive:=0
      else if LLRet<>$01FF then TBReceive:=LLRet
      else TBReceive:=0;
   end
  else
   begin
      Writeln('TENTOOLS Not Initialized');
      Halt;
   end;
End;

Function Nodes(VAR NodeBuffer;VAR MaxNodes : Integer;
                  SuperstationsOnly : Boolean) : Word;
{ A call to this function should be made with NODEBUFFER being an
 Array[1..MaxNodes] of S12. MaxNodes being the largest number of nodes you
 expect to see on the network. If the Returncode of NODES is 0, MaxNodes will
 have the actual number of nodenames returned and the array will be filled
 with their names. SuperstationsOnly is a boolean which allows nodes to be
 called to list only superstations. }

VAR
   LIAV : LongInt;
   Av : Word;
   I,J,K,MaxRecs : Integer;
   Adjust : S12;
Begin
   If MaxNodes>1024 then MaxNodes:=0;
   If (TNTI and (MaxNodes>0))
   then with TenRegs do
    begin
       LIAV:=MaxAvail;
       If (LIAV>=$FFFF)
       then AV:=$FFFF
       else AV:=LIAV;
       MaxRecs:=Av div 24;
       If MaxNodes<MaxRecs
       then
        begin
           MaxRecs:=MaxNodes;
           AV:=MaxRecs*24;
        end;
       GetMem(NodeArray,AV);
       AX:=$0D02;
       If SuperstationsOnly then AX:=$0D01;
       CX:=AV;
       DS:=Seg(NodeArray^);
       DX:=Ofs(NodeArray^);
       Intr($6F,TenRegs);
       NAArray:=@NodeBuffer;
       NWArray:=@NodeArray^;
       MaxNodes:=CX;
       K:=1;
       For J:=1 to MaxNodes do
        begin
           Adjust:='            ';
           for I:=1 to 12 do Case SuperStationsOnly of
           False : Adjust[I]:=NodeArray^[J].NID[I];
           True : Adjust[I]:=NWArray^[J].NID[I];
           end;
           If SuperStationsOnly
           then
            begin
               if (NWArray^[J].Ver[1]and 1=0)
               then
                begin
                   NAArray^[K]:=Adjust;
                   Inc(K);
                end
            end
           else NAArray^[J]:=Adjust;
        end;
       If (Flags and 1)>0
       then Nodes:=AX
       else Nodes:=0;
       If SuperStationsOnly then MaxNodes:=K-1;
       FreeMem(NodeArray,AV);
    end
    else if (MaxNodes<=0) then Nodes:=$FFFF;
End;

Function GetDevices(ServerID : S12;
             VAR Device : DeviceArray;
             VAR DeviceCount : Integer): Word;
{ Returns a list of devices through the Variable parameter Devices (which is
  defined as Array[1..25] of S8). Uses the Get/Set/Delete/Get User Shared
  Device (Int-$6F,Service-$15) function call.
  }
VAR
   DCount : Integer;
   DeviceTable : SDev;
   SERVERZ : S12;
   I : Integer;
Begin
   FillChar(Device,Sizeof(Device),0);  {initialize to all nullstrings}
   If Loaded
   then with TenRegs do
    begin
       SERVERZ:=Upcase12(ServerID);
       DCount:=0;
       Repeat
          AX:=$1501;
          BX:=DCount;
          DS:=Seg(ServerZ);
          SI:=Ofs(ServerZ)+1;
          ES:=Seg(DeviceTable);
          DI:=Ofs(DeviceTable);
          Intr($6F,TenRegs);
          If not ((Flags and 1)>0)
          then
           begin
              Device[DCount]:=DeviceTable.Alias;
              Inc(DCount);
           end
          else GetDevices:=AX;
       Until ((Flags and 1)>0);
       DeviceCount:=DCount;
       If DeviceCount=0 then GetDevices:=AX else GetDevices:=0;
    end
   else GetDevices:=$FFFF;
End;

Function GetTableData(VAR TableBuffer : GetTableDataRec): Word;
VAR
 I : Integer;
Begin
   If Loaded then
   With TenRegs do
    begin
       For I:=1 to 12 do TableBuffer.NodeID[I]:=ConfigTable^.CT_NID[I];
       TableBuffer.Res1:=0;
       AX:=$1D00;
       DS:=Seg(TableBuffer);
       DX:=Ofs(TableBuffer);
       Intr($6F,TenRegs);
       If not ((Flags and 1)>0)
        then GetTableData:=0
        else GetTableData:=AX;
    end
   else GetTableData:=$FFFF;
End;

Function MountsAvail : Integer;
 VAR
    TempTable : ^GetTableDataRec;
Begin
   GetMem(TempTable,Sizeof(GetTableDataRec));
   If (GetTableData(TempTable^)=0) then
   MountsAvail:=TempTable^.TenNetTables[1].Free+TempTable^.TenNetTables[1].Alloc
   else MountsAvail:=0;
   FreeMem(TempTable,Sizeof(GetTableDataRec));
End;


Function MountList(VAR MountTable : DriveArray;VAR PrintTable : PrintArray;VAR TableEntries : Integer): Word;
{Returns a mountlist of type DriveTable (with TableEntries as a count of
actual table entries returned), and PrintTable of Printer reassignments.
The caller must specify a maximum tablesize by setting table entries before
calling. Returns with a value of 0 if it worked without any hitches, and the
value of a 10net error if there is any problem. Will return with a value of
$FFFF if not loaded. Will return names of Devices if any are currently
"NetUsed".}
VAR
  I,IB,IM : Integer;
  SA : Word;
  SR : SearchRec;
  MChar : Char;
  Highest : Integer;
  LD : ^Byte;
  HighestLocal : Integer;
  LDevBuffer : Array[1..128] of Char;
  RDevBuffer : Array[1..128] of Char;
Begin
   If TableEntries<0 then TableEntries:=26;
   Highest:=0;
   If not Loaded
   then MountList:=$FFFF
   else with TenRegs do
    begin
       HighestLocal:=ConfigTable^.CT_PHYSDRVS;
       MountList:=0;
       Highest:=MountsAvail;
       If TableEntries>Highest then TableEntries:=Highest;
       For MChar:='A' to Char(TableEntries+64) do with MountTable[MChar] do
        begin
           If Ord(MChar)-64<=HighestLocal then ServerID:='Local       '
           else ServerID:='            ';
           RPath:=MChar;
        end;
       For MChar:='1' to '3' do with PrintTable[MChar] do
        begin
           ServerID:='            ';
           RPath:='';
        end;
       IB:=0;
       Flags:=0;
       while not ((Flags and 1)>0) do
        begin
           AX:=$1C00;
           BX:=IB;
           DS:=Seg(SendSet);
           DI:=Ofs(SendSet);
           Intr($6F,TenRegs);
           If not ((Flags and 1)>0)
           then
            begin
               IM:=0;
               While not ((Flags and 1)>0) do
                begin
                   AX:=$1B00;
                   BX:=IM;
                   DS:=Seg(SendSet);
                   DX:=Ofs(SendSet);
                   Intr($6F,TenRegs);
                   If not ((Flags and 1)>0)
                   then
                    begin
                       If (AH in [65..90])
                       then
                        begin
                           MChar:=Char(AH);
                           If AH<=(TableEntries+64)
                           then
                            begin
                               MountTable[MChar].ServerID[0]:=#12;
                               Move(SendSet.RNode,MountTable[MChar].ServerID[1],12);
                               MountTable[MChar].RPath:=Char(AL);
                            end;
                        end
                       else if (AH in [49..51])
                       then
                        begin
                           MChar:=Char(AH);
                           PrintTable[MChar].ServerID[0]:=#12;
                           Move(SendSet.RNode,PrintTable[MChar].ServerID[1],12);
                           PrintTable[MChar].RPath:=Char(AL);
                        end;
                    end
                   else if not (AX=$25FF)
                   then
                    begin
                       MountList:=AX;
                       TableEntries:=Highest;
                       Exit;
                    end;
                   Inc(IM);
                end;
              Flags:=0;
            end
           else if not (AX=$08FF) then MountList:=AX;
           Inc(IB);
        end;
       IB:=0;
        Repeat
           AX:=$5F02;
           BX:=IB;
           DS:=Seg(LDevBuffer);
           SI:=Ofs(LDevBuffer);
           ES:=Seg(RDevBuffer);
           DI:=Ofs(RDevBuffer);
           MSDOS(TenRegs);
           If not ((Flags and 1)>0)
           then with MountTable[LDevBuffer[1]] do
            begin
               I:=3;
               RPath:='';
               ServerID:='';
               While not (RDevBuffer[I]='\') do
                begin
                   ServerID:=ServerID+RDevBuffer[I];
                   Inc(I);
                end;
               Inc(I);
               While not(RDevBuffer[I]=#0) do
                begin
                   RPath:=RPath+RDevBuffer[I];
                   Inc(I);
                end;
            end;
           Inc(IB);
        Until ((Flags and 1)>0);
    end;
End;

Function LogList(VAR Logins : LogArray;VAR TableEntries : Integer): Word;
{Returns a list of nodes that the local station is logged into. LogArray
 is a TYPE defined as Array[0..19] of String[12] and can be used in the
 calling program. }
VAR
  IB : Integer;

Begin
   If not Loaded
   then LogList:=$FFFF
   else with TenRegs do
    begin
       IB:=0;
       Flags:=0;
       while not ((Flags and 1)>0) do
        begin
           AX:=$1C00;
           BX:=IB;
           DS:=Seg(Sendset);
           DI:=Ofs(SendSet);
           Intr($6F,TenRegs);
           If not ((Flags and 1)>0)
           then
            begin
               Logins[IB][0]:=#12;
               Move(SendSet.RNode,Logins[IB][1],12);
               Inc(IB);
            end;
           LogList:=0;
        end;
       TableEntries:=IB;
    end;
End;

Function Submit(ServerID : S12; CommandLine : String): Word;
{ If the local User is LOGGED INTO the node SERVERID, and the submit permit
 is ON at ServerID, and ServerID is currently at a DOS prompt, then the
 Commandline will be SUBMITTED to ServerID. If it is not currently at a DOS
 prompt, it will be SUBMITTED when it reaches a DOS prompt. }

TYPE
   SubmitRec = Record
      Nodeid : Array[1..12] of Char;
      CLen   : Integer;
      CLine : Array[1..100] of Char;
   end;
VAR
   ServerZ : S12;
   I : Integer;
   SRec : SubmitRec;
Begin
   If Loaded
   then with TenRegs do
    begin
       SERVERZ:=Upcase12(ServerID);
       Move(ServerZ[1],SRec.Nodeid,12);
       If Pos(#13,Commandline)>0 then SRec.CLen:=Pos(#13,Commandline)-1
       else SRec.CLen:=Length(Commandline);
       CommandLine:=CommandLine+#13+#10;
       Inc(SRec.CLen,2);
       Move(Commandline[1],SRec.CLine,SRec.CLen);
       AX:=$0900;
       DS:=Seg(SRec);
       BX:=Ofs(SRec);
       Intr($6F,TenRegs);
       If ((Flags and 1)>0)
       then
        begin
           Submit:=AX;
        end
       else Submit:=0;
    end
   else Submit:=$FFFF;
End;

Function SetSpool(Printer : Byte; SpoolName : S12; Notification : NotifySet; RDays : Byte): Word;
{ When SetSpool is first called, it merely sets up a "Template" for
  subsequent calls to OpenSpool and CloseSpool. You must be logged into the
  Superstation where you want to spool and be mounted to a printer and a
  drive on that Superstation. SetSpool will determine where the Printer
  (1,2, or 3 for your local LPT1:,LPT2:, or LPT3:) is mounted and a drive
  letter that you are mounted to. }

VAR
  NT : NotifyTypes;
  DriveTable : DriveArray;
  PrintTable : PrintArray;
  MaxDrive : Integer;
  SSC : Char;
  Pr : String[5];
  SplServer : S12;

Begin
   If Loaded then with SpoolSettings do
    begin
{ Look at which server printer is mounted on and find out which drives it is
  also mounted to. }
       MaxDrive:=26;
       TenTest:=MountList(DriveTable,PrintTable,MaxDrive);
       If (TenTest=0)
       then
        begin
           SplServer:=PrintTable[Char(Printer+48)].ServerID;
           If ((SplServer='            ')or(SplServer='Local       '))
           then SplServer:=''
           else
            begin
               Pr:='LPT'+Char(Printer+48)+':';
               SSC:='A';
               While not ((SSC>Char(MaxDrive+64))or(DriveTable[SSC].ServerID=SplServer)) do Inc(SSC);
               If not (DriveTable[SSC].ServerID=SplServer) then SSC:=#0;
            end;
           If ((SSC<>#0)and(SplServer<>''))
           then
            begin
               UDVC:=Printer;
               UDVC:=UDVC+(Ord(SSC)-64)shl 4;
               UCode:=00;
               If Spoolname<>''
               then
                begin
                   While (Pos(' ',Spoolname)>0) do Delete(Spoolname,Pos(' ',Spoolname),1);
                   If (Pos('.',Spoolname)>0) then Delete(Spoolname,Pos('.',Spoolname),1);
                end;
               While Length(Spoolname)<11 do Spoolname:=Spoolname+' ';
               Move(Spoolname[1],SpoolSettings.UFile,11);
               UNote:=0;
               If (Start in Notification) then UNote:=UNote or 1;
               If (Reply in Notification) then UNote:=UNote or 2;
               If (Completion in Notification) then UNote:=UNote or 4;
               If (ExplQueue in Notification) then UNote:=UNote or 8;
               If (NoFF in Notification) then UNote:=UNote or 32;
               If (IDPage in Notification) then UNote:=UNote or 64;
               If (QueueTop in Notification) then UNote:=UNote or 2;
               UDays:=RDays;
               ULen:=0;
               UArea:=0;
               SetSpool:=0;
               Spooling:=True;
            end
           else SetSpool:=$23FF;
        end
       else SetSpool:=$25FF;
    end
  else SetSpool:=$FFFF;
End;


Function OpenSpool(NewSpoolname : S12) : Word;
 {Once SetSpool has "configured" your spool, calls to OpenSpool will
  create a new spoolfile with the optional Newspoolname, or with a name
  automatically set by 10Net if NewSpoolName=''. }

VAR
   OpenSpoolSet : SpoolBlock;

Begin
   If Spooling
   then with TenRegs do
    begin
       If NewSpoolname<>''
       then
        begin
           While (Pos(' ',NewSpoolname)>0) do Delete(NewSpoolname,Pos(' ',NewSpoolname),1);
           If (Pos('.',NewSpoolname)>0) then Delete(NewSpoolname,Pos('.',NewSpoolname),1);
        end;
       While Length(NewSpoolname)<11 do NewSpoolname:=NewSpoolname+' ';
       Move(NewSpoolname[1],SpoolSettings.UFile,11);
       Move(SpoolSettings,OpenSpoolSet,Sizeof(SpoolSettings));
       DS:=Seg(OpenSpoolSet);
       DX:=Ofs(OpenSpoolSet);
       AX:=$0E00;
       OpenSpoolSet.UCode:=0;
       Intr($6F,TenRegs);
       If ((Flags and 1)>0)
       then
        begin
           OpenSpool:=AX;
        end
       else OpenSpool:=0;
    end
   else OpenSpool:=$FFFF;
End;

Function CloseSpool : Word;
{ Calls to CloseSpool, after a spool has been started through OpenSpool and
  some print has been "sent to the printer", will cause the Spoolfile to
  close and printing to begin if the Print Permit is ON at the location
  where the printer is mounted.
     "Sending print to the printer" is done in the usual manner, from within
  programs, by "Typing and Piping" (TYPE>LPT1 <filename>), by Copying from a
  file to the printer, etc.}

VAR
   CloseSpoolSet : SpoolBlock;
Begin
   If Spooling
   then with TenRegs do
    begin
       Move(SpoolSettings,CloseSpoolSet,Sizeof(SpoolSettings));
       DS:=Seg(CloseSpoolSet);
       DX:=Ofs(CloseSpoolSet);
       AX:=$0E00;
       CloseSpoolSet.UCode:=2;
       Intr($6F,TenRegs);
       If ((Flags and 1)>0)
       then
        begin
           CloseSpool:=AX;
        end
       else CloseSpool:=0;
    end
   else CloseSpool:=$FFFF;
End;


Function TenConfig(MaxSendRec,MaxRecvRec : Integer; {Size of largest records
                                                     to send/receive}
                   MaxRecs : Integer)   {Maximum number of Records to recv}
                          : Word;
VAR
   I : Integer;
   RetCode : Word;
{ This function allows the user to dynamically change the size of the
buffers being used by TBSend and TBReceive to optimize usage.
MaxSendRec is the size of the largest TBSEND record
MaxRecvRec is the size of the largest TBRECEIVE record
MaxRecs is the number of TBReceive records to buffer
}
Begin
   If TNTI
   then
    begin
       For I:=1 to MaxReceives do
        begin
           FreeMem(TBD^[I],Sizeof(RcvBlock)*MaxRecvSets);
        end;
       FreeMem(TBD,MaxReceives*4);
       FreeMem(TBR,MaxReceives*Sizeof(RecvRec));
    end;
   RetCode:=0;
   If MaxRecs<1310 then MaxReceives:=MaxRecs
   else RetCode:=RetCode+1;
   If MaxSendRec<=65521 then MaxSendBufferSize:=MaxSendRec
   else RetCode:=RetCode+2;
   If MaxRecvRec<=65521 then MaxRecBuffersize:=MaxRecvRec
   else RetCode:=RetCode+4;
   If MaxRecs>0
   then
    begin
       MaxRecvSets:= MaxRecBufferSize div 457 + 1;
       GetMem(TBR,MaxReceives*Sizeof(RecvRec));
       GetMem(TBD,MaxReceives*4);
       For I:=1 to MaxReceives do
       GetMem(TBD^[I],Sizeof(RcvBlock)*MaxRecvSets);
    end;
   TenConfig:=RetCode;
End;

Function SetWait(WaitLimit : Integer): Word;
{ Changes the maximum seconds to wait for receive packets in the same record,
  Defaults to 30 }
Begin
   If ((WaitLimit>0) and (WaitLimit<3000))
   then
    begin
       MaxRcvWait:=WaitLimit;
       SetWait:=0;
    end
   else SetWait:=$FFFF;
End;


Procedure SetUserName(UName : S8);
{Changes the Username in the Network Table and in the Global variable
  USERNAME}
VAR
   I : Integer;
Begin
   If Loaded
   then
    begin
       UserName:=Upcase8(UName);
       Move(UserName[1],ConfigTable^.CT_LName,8);
    end
   else UserName:=Upcase8(UName);
end;

{ The Unit Initialization Code below locates the Configuration Table Address
and establishes the buffers necessary to make 10Net function calls. It will
be called at the beginning of a program to make the tools available
throughout the program. }


Begin
   If Loaded
   then with TenRegs do
    begin
(*      Initially, no space is allocated for Sends and Receives; These
       buffers can be established dynamically with a call to TenConfig.
       TenTest:=TenConfig(MaxSendBufferSize,MaxRecBufferSize,MaxReceives);
       If TenTest<>0 then Writeln('TenConfig Error: ',TenTest);
*)       AX:=$0300;
       Intr($6F,TenRegs);
       ConfigTable:=Ptr(ES,BX);
       PreConfig:=Ptr(ES,BX-51);
       UserName:='';
       For I10:=1 to 8 do UserName:=UserName+ConfigTable^.CT_LName[I10];
       TNTI:=True;
       Spooling:=False;
    end
   else
    begin
       Writeln('TenTools inititalization Error!');
       Writeln('Netword not Loaded!');
       Spooling:=False;
    end;
End. { Of TenTools Unit }
