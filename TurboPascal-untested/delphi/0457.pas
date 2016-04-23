Unit MKMsgJam32;       {JAM Msg Object Unit}

///////////////////////////////////////////////////////////////////////////////
// MKMsgJam32 Coded in Part by G.E. Ozz Nixon Jr. of www.warpgroup.com       //
// ========================================================================= //
// Original Source for DOS by Mythical Kindom's Mark May (mmay@dnaco.net)    //
// Re-written and distributed with permission!                               //
// See Original Copyright Notice before using any of this code!              //
///////////////////////////////////////////////////////////////////////////////

Interface

Uses
   MKFidoAddr32,
   Classes,
   SysUtils;

Const
   Version='9.19.97';
   {idx buffer removed, 95 and NT buffer already!}
   JamSubBufSize = 4000;
   JamTxtBufSize = 32000;           {new msg text in-ram buffer}
   TxtSubBufSize = 2000;            {Note actual size is one greater}

Type
{on status only generated during errors!}
   TOnStatus=procedure(Sender:TComponent;fatal:boolean;status:string) of Object;

   JamHdrType=Packed Record
      Signature:Array[1..4] of Char;
      Created:LongInt;
      ModCounter:LongInt; {if different from last time, then check msgbase!}
      ActiveMsgs:LongInt;
      PwdCRC:LongInt;
      BaseMsgNum:LongInt;
      Extra:Array[1..1000] of Char;
   End;

   JamMsgHdrType = Packed Record
      Signature: Array[1..4] of Char;
      Rev: Word;
      Resvd: Word;
      SubFieldLen: LongInt;
      TimesRead: LongInt;
      MsgIdCrc: LongInt;
      ReplyCrc: LongInt;
      ReplyTo: LongInt;
      ReplyFirst: LongInt;
      ReplyNext: LongInt;
      DateWritten: LongInt;
      DateRcvd: LongInt;
      DateArrived: LongInt;
      MsgNum: LongInt;
      Attr1: LongInt;
      Attr2: LongInt;
      TextOfs: LongInt;
      TextLen: LongInt;
      PwdCrc: LongInt;
      Cost: LongInt;
   End;

   JamIdxType = packed Record
      MsgToCrc: LongInt;
      HdrLoc: LongInt;
   End;

   JamLastType = Packed Record
      NameCrc: LongInt;
      UserNum: LongInt;
      LastRead: LongInt;
      HighRead: LongInt;
   End;

   JamSubBuffer = Array[1..JamSubBufSize] of Char;

   JamTxtBufType = Array[0..JamTxtBufSize] Of Char;

   HdrType = Packed Record
      JamHdr: JamMsgHdrType;
      SubBuf: JamSubBuffer;
   End;

   MsgMailType = (mtNormal, mtEchoMail, mtNetMail);

   TJamMsgBase = Class(TComponent)
   private
      LastSoft:Boolean;
      HdrFile: File;
      TxtFile: File;
      IdxFile: File;
      MsgPath: String;
      BaseHdr: JamHdrType;
      Dest: AddrType;
      Orig: AddrType;
      MKMsgFrom: String;
      MKMsgTo: String;
      MKMsgSubj: String;
      MKMsgDate: String;
      MKMsgTime: String;
      CurrMsgNum: LongInt;
      YourName: String[35];
      YourHdl: String[35];
      NameCrc: LongInt;
      HdlCrc: LongInt;
      TxtPos: LongInt; {TxtPos < 0 means get from sub text}
      TxtEnd: LongInt;
      TxtBufStart: LongInt;
      TxtRead: Integer;
      MailType: MsgMailType;
      BufFile: File;
      LockCount: LongInt;
      TxtSubBuf: Array[0..TxtSubBufSize-1] of Char; {temp storage for text on subfields}
      TxtSubChars: Integer;
      MsgHdr: ^HdrType;
      JamIdx: JamIdxType;
      TxtBuf: ^JamTxtBufType;
      Error: Word;
      FActive:Boolean;
      FOnStatus: TOnStatus;
      MKGetHighMsgNumber:Longint;
      {Internal to JAM}
      Procedure SetAttr1(Mask: LongInt; St: Boolean);
      Procedure AddSubField(id: Word; Data: String);
      Procedure AddTxtSub(St: String);
      Function  WriteIdx: Word;
      Function  ReadIdx:Word;
      Function  FindLastRead(Var LastFile: File; UNum: LongInt): LongInt;
      {end of internal}
      Procedure SetCost(Value:Word); Virtual;
      Function  GetCost:Word; Virtual;
      Procedure SetRefer(Value: LongInt); Virtual;
      Procedure SetSeeAlso(Value: LongInt); Virtual;
      Function  GetSeeAlso:LongInt; Virtual;
      Function  GetNextSeeAlso:LongInt; Virtual;
      Procedure SetNextSeeAlso(Value:LongInt); Virtual;
      Procedure SetLocal(Value:Boolean); Virtual;
      Procedure SetRcvd(Value:Boolean); Virtual;
      Procedure SetPriv(Value:Boolean); Virtual;
      Procedure SetCrash(Value:Boolean); Virtual;
      Procedure SetKillSent(Value:Boolean); Virtual;
      Procedure SetSent(Value:Boolean); Virtual;
      Procedure SetFAttach(Value:Boolean); Virtual;
      Procedure SetReqRct(Value:Boolean); Virtual;
      Procedure SetReqAud(Value:Boolean); Virtual;
      Procedure SetRetRct(Value:Boolean); Virtual;
      Procedure SetFileReq(Value:Boolean); Virtual;
      Function  EOM: Boolean; Virtual;
      Function  GetRefer: LongInt; Virtual;
      Function  GetMsgNum: LongInt; Virtual;
      Function  IsLocal: Boolean; Virtual;
      Function  IsCrash: Boolean; Virtual;
      Function  IsKillSent: Boolean; Virtual;
      Function  IsSent: Boolean; Virtual;
      Function  IsFAttach: Boolean; Virtual;
      Function  IsReqRct: Boolean; Virtual;
      Function  IsReqAud: Boolean; Virtual;
      Function  IsRetRct: Boolean; Virtual;
      Function  IsFileReq: Boolean; Virtual;
      Function  IsRcvd: Boolean; Virtual;
      Function  IsPriv: Boolean; Virtual;
      Function  IsDeleted: Boolean; Virtual;
      Function  IsEchoed: Boolean; Virtual;
      Procedure SetMailType(Value: MsgMailType); Virtual;
      Procedure SetActive(Value:Boolean); Virtual;
      Function  MKMsgBaseExists: Boolean; Virtual;
      Function  MKSeekFound:Boolean; Virtual;
      Function  MKYoursFound:Boolean; Virtual;
      Function  MKNumberOfMsgs: LongInt; Virtual;

   public
      Constructor Create(AOwner:TComponent); Override;
      Destructor Destroy; Override;
      Function  LockMsgBase:Boolean; Virtual;
      Function  UnLockMsgBase:Boolean; Virtual;
      Procedure DoString(Str: String); Virtual;
      Procedure DoChar(Ch: Char); Virtual;
      Procedure DoStringLn(Str: String); Virtual;
      Procedure DoKludgeLn(Str: String); Virtual;
      Function  WriteMsg: Word; Virtual;
      Function  GetChar: Char; Virtual;
      Procedure MsgStartUp; Virtual;
      Function  GetString(MaxLen: Word): String; Virtual;
      Procedure SeekFirst(MsgNum: LongInt); Virtual;
      Procedure SeekNext; Virtual;
      Procedure SeekPrior; Virtual;
      Function  GetMsgLoc: LongInt; Virtual;
      Procedure SetMsgLoc(ML: LongInt); Virtual;
      Procedure YoursFirst(Name: String; Handle: String); Virtual;
      Procedure YoursNext; Virtual;
      Procedure StartNewMsg; Virtual;
      Function  OpenMsgBase: Word; Virtual;
      Function  CloseMsgBase: Word; Virtual;
      Function  CreateMsgBase(MaxMsg: Word; MaxDays: Word): Word; Virtual;
      Procedure ReWriteHdr; Virtual;
      Procedure DeleteMsg; Virtual;
      Function  GetLastRead(UNum: LongInt): LongInt; Virtual;
      Procedure SetLastRead(UNum: LongInt; LR: LongInt); Virtual;
      Procedure MsgTxtStartUp; Virtual;
      Function  GetTxtPos: LongInt; Virtual;
      Procedure SetTxtPos(TP: LongInt); Virtual;
      Function  GetSubArea: Word; Virtual;
      Procedure SetEcho(Value:Boolean); Virtual;

   Published
      property  Active: Boolean read FActive write SetActive;
      property  MsgPathFileName: String read MsgPath write MsgPath;
      property  GetHighMsgNum: LongInt read MKGetHighMsgNumber;
      property  HdrDest: AddrType read Dest write Dest;
      property  HdrOrig: AddrType read Orig write Orig;
      property  HdrFrom: String read MKMsgFrom write MKMsgFrom;
      property  HdrTo: String read MKMsgTo write MKMsgTo;
      property  HdrSubj: String read MKMsgSubj write MKMsgSubj;
      property  HdrCost: Word read GetCost write SetCost;
      property  HdrRefer: LongInt read GetRefer write SetRefer;
      property  HdrSeeAlso: LongInt read GetSeeAlso write SetSeeAlso;
      property  HdrNextSeeAlso: LongInt read GetNextSeeAlso write SetNextSeeAlso;
      property  HdrDate: String read MKMsgDate write MKMsgDate;
      property  HdrTime: String read MKMsgTime write MKMsgTime;
      property  HdrAttrLocal:Boolean read IsLocal write SetLocal;
      property  HdrAttrReceived:Boolean read IsRcvd write SetRcvd;
      property  HdrAttrCrash:Boolean read IsCrash write SetCrash;
      property  HdrAttrKillSend:Boolean read IsKillSent write SetKillSent;
      property  HdrAttrSent:Boolean read IsSent write SetSent;
      property  HdrAttrFileAttach:Boolean read IsFAttach write SetFAttach;
      property  HdrAttrRequestReceipt:Boolean read isReqRct write SetReqRct;
      property  HdrAttrRequestAudit:Boolean read isReqAud write SetReqAud;
      property  HdrAttrReturnReceipt:Boolean read isRetRct write SetRetRct;
      property  HdrAttrFileRequest:Boolean read isFileReq write SetFileReq;
      property  HdrAttrDelete:Boolean read isDeleted;
      property  HdrAttrEchoed:Boolean read isEchoed write SetEcho;
      {propogate private to fido32!}
      property  HdrAttrPrivate:Boolean read isPriv write SetPriv;
      property  EndOfMsgText:Boolean read EOM;
      Property  WasWrap: Boolean read LastSoft;
      Property  MsgBaseExists: Boolean read MKMsgBaseExists;
      Property  SeekFound: Boolean read MKSeekFound;
      Property  YoursFound: Boolean read MKyoursFound;
      Property  HdrMailType:MsgMailType read MailType write SetMailType;
      Property  MsgNumber:Longint read GetMsgNum;
      property  NumberOfMsgs: LongInt read MkNumberofMsgs;
      property  OnErrorStatus:TOnStatus read FOnstatus write FOnStatus;
   End;

Procedure Register;

Implementation

Uses
   MKFile32,
   MKString32,
   Crc32;

Const
   Jam_Local =        $00000001;
   Jam_InTransit =    $00000002;
   Jam_Priv =         $00000004;
   Jam_Rcvd =         $00000008;
   Jam_Sent =         $00000010;
   Jam_KillSent =     $00000020;
   Jam_AchvSent =     $00000040;
   Jam_Hold =         $00000080;
   Jam_Crash =        $00000100;
   Jam_Imm =          $00000200;
   Jam_Direct =       $00000400;
   Jam_Gate =         $00000800;
   Jam_Freq =         $00001000;
   Jam_FAttch =       $00002000;
   Jam_TruncFile =    $00004000;
   Jam_KillFile =     $00008000;
   Jam_RcptReq =      $00010000;
   Jam_ConfmReq =     $00020000;
   Jam_Orphan =       $00040000;
   Jam_Encrypt =      $00080000;
   Jam_Compress =     $00100000;
   Jam_Escaped =      $00200000;
   Jam_FPU =          $00400000;
   Jam_TypeLocal =    $00800000;
   Jam_TypeEcho =     $01000000;
   Jam_TypeNet =      $02000000;
   Jam_NoDisp =       $20000000;
   Jam_Locked =       $40000000;
   Jam_Deleted =      $80000000;

Type
   SubFieldType=Record {this is defined twice, why?}
      LoId:Word;
      HiId:Word;
      DataLen:LongInt;
      Data:Array[1..1000] of Char;
   End;

Constructor TJamMsgBase.Create(AOwner:TComponent);
Begin
   Inherited Create(AOwner);
   New(MsgHdr);
   New(TxtBuf);
   If ((MsgHdr=Nil) or (TxtBuf=Nil)) Then Begin
      If MsgHdr<>Nil Then Dispose(MsgHdr);
      If TxtBuf<>Nil Then Dispose(TxtBuf);
      if assigned(FOnStatus) then
         FOnStatus(self,True,'Error Initializing buffers - JAM Object not accessible!');
      Exit;
   End
   Else Begin
      MsgPath:='';
      Error:=0;
      FillChar(Dest,Sizeof(Dest),0);
      Orig:=Dest;
      MKMsgFrom:='Noone';
      MKMsgTo:='Noone';
      MKMsgSubj:='MsgBase Not Active yet';
      MKMsgDate:='mm-dd-yy';
      MKMsgTime:='hh:mm';
      FillChar(MsgHdr^,Sizeof(MsgHdr^),#0);
      FActive:=False;
   End;
End;

Destructor TJamMsgBase.Destroy;
Begin
   If MsgHdr<>Nil Then Dispose(MsgHdr);
   If TxtBuf<>Nil Then Dispose(TxtBuf);
End;

Function JamStrCrc(St:String):LongInt;
Var
   i: Word;
   crc: LongInt;

Begin
   Crc := -1;
   For i := 1 to Length(St) Do Crc := Updc32(Ord(LoCase(St[i])), Crc);
   JamStrCrc := Crc;
End;

Procedure TJamMsgBase.SetCost(Value:Word); {actual routine}
Begin
   MsgHdr^.JamHdr.Cost:=Value;
End;

Function TJamMsgBase.GetCost: Word; {actual routine}
Begin
   GetCost:=MsgHdr^.JamHdr.Cost;
End;

Procedure TJamMsgBase.SetRefer(Value:LongInt); {actual routine}
Begin
   MsgHdr^.JamHdr.ReplyTo:=Value;
End;

Function TJamMsgBase.GetRefer:LongInt; {actual routine}
Begin
   GetRefer:=MsgHdr^.JamHdr.ReplyTo;
End;

Procedure TJamMsgBase.SetSeeAlso(Value:LongInt); {actual routine}
Begin
   MsgHdr^.JamHdr.ReplyFirst:=Value;
End;

Function TJamMsgBase.GetSeeAlso: LongInt; {actual routine}
Begin
   GetSeeAlso:=MsgHdr^.JamHdr.ReplyFirst;
End;

Procedure TJamMsgBase.SetAttr1(Mask:LongInt;St:Boolean); {internal to JAM}
Begin
   If St Then MsgHdr^.JamHdr.Attr1:=MsgHdr^.JamHdr.Attr1 Or Mask
   Else MsgHdr^.JamHdr.Attr1:=MsgHdr^.JamHdr.Attr1 And (Not Mask);
End;

Procedure TJamMsgBase.SetLocal(Value:Boolean); {actual routine}
Begin
   SetAttr1(Jam_Local,Value);
End;

Procedure TJamMsgBase.SetRcvd(Value:Boolean); {actual routine}
Begin
   SetAttr1(Jam_Rcvd,Value);
End;

Procedure TJamMsgBase.SetPriv(Value:Boolean); {actual routine}
Begin
   SetAttr1(Jam_Priv,Value);
End;

Procedure TJamMsgBase.SetCrash(Value:Boolean); {actual routine}
Begin
   SetAttr1(Jam_Crash,Value);
End;

Procedure TJamMsgBase.SetKillSent(Value:Boolean); {actual routine}
Begin
   SetAttr1(Jam_KillSent,Value);
End;

Procedure TJamMsgBase.SetSent(Value:Boolean); {actual routine}
Begin
   SetAttr1(Jam_Sent,Value);
End;

Procedure TJamMsgBase.SetFAttach(Value:Boolean); {actual routine}
Begin
   SetAttr1(Jam_FAttch,Value);
End;

Procedure TJamMsgBase.SetReqRct(Value:Boolean); {actual routine}
Begin
   SetAttr1(Jam_RcptReq,Value);
End;

Procedure TJamMsgBase.SetReqAud(Value:Boolean); {actual routine}
Begin
   SetAttr1(Jam_ConfmReq,Value); {actual routine}
End;

Procedure TJamMsgBase.SetRetRct(Value:Boolean); {actual routine}
Begin
   {unused}
   if assigned(FOnStatus) then
      FOnStatus(self,False,'Return Receipt not supported by JAM Object!');
End;

Procedure TJamMsgBase.SetFileReq(Value:Boolean); {actual routine}
Begin
   SetAttr1(Jam_Freq,Value); {actual routine}
End;

{rewritten 7-23-97 by warpgroup}
Procedure TJamMsgBase.DoString(Str:String); {actual routine}
Begin
   While Length(Str)>0 Do Begin
      DoChar(Str[1]);
      Delete(Str,1,1);
   End;
End;

Procedure TJamMsgBase.DoChar(Ch: Char); {actual routine}
Var
   TmpStr: String;
   NumWrite: Integer;
   I:Integer;

Begin
   Case ch of
     #13: LastSoft := False;
     #10: {absorb};
     Else LastSoft := True;
   End;
   If (TxtPos-TxtBufStart)>=JamTxtBufSize Then Begin {flush to disk for virtual memory!}
      If TxtBufStart=0 Then Begin
         i:=PosLastChar('\',MsgPath);
         If i>0 Then TmpStr:=Copy(MsgPath,1,i)
         Else Begin
            GetDir(0,TmpStr);
            AddBackSlash(TmpStr);
         End;
         shMakeFile(BufFile,GetTempName(TmpStr));
      End;
      NumWrite:=TxtPos-TxtBufStart;
      {$I-} shWrite(BufFile,TxtBuf^,NumWrite); {$I+}
      If MKFileError<>0 then Begin
      if assigned(FOnStatus) then
         FOnStatus(self,True,'Write Failed [dochar] Error ('+IntToStr(MKFileError)+')');
      End;
      TxtBufStart:=FileSize(BufFile);
   End;
   TxtBuf^[TxtPos-TxtBufStart]:=Ch;
   Inc(TxtPos);
End;

Procedure TJamMsgBase.DoStringLn(Str:String); {actual routine}
Begin
   DoString(Str);
   DoChar(#13);
End;

Procedure TJamMsgBase.DoKludgeLn(Str:String); {actual routine}
Var
   TmpStr: String;

Begin
   If Str[1]=#1 Then Delete(Str,1,1); {drop 1st char!}
   If Copy(Str,1,3)='PID' Then Begin
      TmpStr:=StripLead(Copy(Str,4,255),':');
      TmpStr:=Copy(StripBoth(TmpStr, ' '),1,40);
      AddSubField(7,TmpStr);
   End
   Else If Copy(Str,1,5) = 'MSGID' Then Begin
      TmpStr := StripLead(Copy(Str,6,255),':');
      TmpStr := Copy(StripBoth(TmpStr,' '),1,100);
      AddSubField(4, TmpStr);
      MsgHdr^.JamHdr.MsgIdCrc := JamStrCrc(TmpStr);
   End
   Else If Copy(Str,1,4) = 'INTL' Then Begin {ignored!}
   End
   Else If Copy(Str,1,4) = 'TOPT' Then Begin {ignored!}
   End
   Else If Copy(Str,1,4) = 'FMPT' Then Begin {ignored!}
   End
   Else If (Copy(Str,1,6) = 'REPLY ') or(Copy(Str,1,6) = 'REPLY:') Then Begin
      TmpStr := StripLead(Copy(Str,8,255),':');
      TmpStr := Copy(StripBoth(TmpStr,' '),1,100);
      AddSubField(5, TmpStr);
      MsgHdr^.JamHdr.ReplyCrc := JamStrCrc(TmpStr);
   End
   Else If Copy(Str,1,4) = 'PATH' Then Begin
      TmpStr := StripLead(Copy(Str,5,255),':');
      TmpStr := StripBoth(TmpStr,' ');
      AddSubField(2002, TmpStr);
   End
   Else Begin
      AddSubField(2000, StripBoth(Str,' ')); {Unknown but saved}
   End;
End;

Procedure TJamMsgBase.AddSubField(id: Word; Data: String); {Internal to JAM}
Type
   SubFieldType=Record {why is this here too?!}
      LoId: Word;
      HiId: Word;
      DataLen: LongInt;
      Data: Array[1..256] of Char;
   End;

Var
   SubField: ^SubFieldType;

Begin
   SubField:=@MsgHdr^.SubBuf[MsgHdr^.JamHdr.SubFieldLen+1];
   If (MsgHdr^.JamHdr.SubFieldLen+8+Length(Data)<JamSubBufSize) Then Begin
      Inc(MsgHdr^.JamHdr.SubFieldLen,8+Length(Data));
      SubField^.LoId:=Id;
      SubField^.HiId:=0;
      SubField^.DataLen:=Length(Data);
      Move(Data[1],SubField^.Data[1],Length(Data));
   End;
End;

Function  TJamMsgBase.WriteMsg:Word; {actual routine}
Var
   DT:DateTime;
   WriteError:Word;
   i:Integer;
   TmpIdx:JamIdxType;

Begin
   If LastSoft Then Begin
      DoChar(#13);
      DoChar(#10);
   End;
   Move('JAM'#0,MsgHdr^.JamHdr.Signature[1],4);{Set signature}
   Case MailType of
      mtNormal: SetAttr1(Jam_TypeLocal, True);
      mtEchoMail: SetAttr1(Jam_TypeEcho, True);
      mtNetMail: SetAttr1(Jam_TypeNet, True);
   End;
   MsgHdr^.JamHdr.Rev:=1;
   MsgHdr^.JamHdr.DateArrived:=ToUnixDate(GetDosDate); {Get date processed}
   DT.Year := Str2Long(Copy(MKMsgDate, 7, 2)); {Convert date written}
   DT.Month := Str2Long(Copy(MKMsgDate, 1, 2));
   DT.Day := Str2Long(Copy(MKMsgDate, 4, 2));
   If DT.Year < 80 Then Inc(DT.Year, 2000)
   Else Inc(DT.Year, 1900);
   DT.Sec := 0;
   DT.Hour := Str2Long(Copy(MKMsgTime, 1, 2));
   DT.Min := Str2Long(Copy(MKMsgTime, 4, 2));
   MsgHdr^.JamHdr.DateWritten := DTToUnixDate(DT);
   If Not LockMsgBase Then WriteError := 5
   Else Begin
      MsgHdr^.JamHdr.TextOfs := FileSize(TxtFile);
      MsgHdr^.JamHdr.MsgNum := GetHighMsgNum + 1;
      MsgHdr^.Jamhdr.TextLen := TxtPos;
      If TxtBufStart>0 Then Begin        {Write text using buffer file}
         i:=TxtPos-TxtBufStart;
         {$I-} shWrite(BufFile,TxtBuf^,i); {$I+} {write buffer to file}
         WriteError:=MKFileError;
         If WriteError=0 Then Begin          {seek start of buffer file}
            {$I-} shSeekFile(BufFile,0); {$I+}
            WriteError:=MKFileError;
            If WriteError=0 Then Begin          {seek end of text file}
               {$I-} shSeekFile(TxtFile, FileSize(TxtFile)); {$I+}
               WriteError:=MKFileError;
               If MKFileError<>0 then Begin
               if assigned(FOnStatus) then
                  FOnStatus(self,True,'Write Failed [writemsg] Error ('+IntToStr(MKFileError+3000)+')');
               End;
            End
            Else Begin
            if assigned(FOnStatus) then
               FOnStatus(self,True,'Write Failed [writemsg] Error ('+IntToStr(MKFileError+2000)+')');
            End;
         End
         Else Begin
         if assigned(FOnStatus) then
            FOnStatus(self,True,'Write Failed [writemsg] Error ('+IntToStr(MKFileError+1000)+')');
         End;
         {copy buffer file to text file}
         While ((Not Eof(BufFile)) and (WriteError = 0)) Do Begin
            {$I-} shRead(BufFile,TxtBuf^,SizeOf(TxtBuf^),i); {$I+}
            WriteError:=MKFileError;
            {check if eof error}
            If WriteError=0 Then Begin
               TxtBufStart:=FilePos(TxtFile);
               TxtRead:=i;
               {$I-} shWrite(TxtFile,TxtBuf^,i); {$I+}
               WriteError:=MkFileError;
               If MKFileError<>0 then Begin
               if assigned(FOnStatus) then
                  FOnStatus(self,True,'Write Failed [writemsg] Error ('+IntToStr(MKFileError+4000)+')');
               End;
            End;
         End;
         shCloseFile(BufFile);
         shEraseFile(BufFile);
         WriteError:=IoResult;
         If WriteError<>0 then Begin
            if assigned(FOnStatus) then
               FOnStatus(self,True,'Write Failed [writemsg] Error ('+IntToStr(MKFileError+5000)+')');
         End;
      End
      Else Begin                            {Write text using TxtBuf only}
         {$I-} shSeekFile(Txtfile,FileSize(TxtFile)); {$I+}
         WriteError:=MKFileError;
         If WriteError=0 Then Begin
            {$I-} shWrite(TxtFile, TxtBuf^, TxtPos); {$I+}
            WriteError:=MKFileError;
            TxtRead:=TxtPos;
            If MKFileError<>0 then Begin
            if assigned(FOnStatus) then
               FOnStatus(self,True,'Write Failed [writemsg] Error ('+IntToStr(MKFileError+7000)+')');
            End;
         End
         Else Begin
            if assigned(FOnStatus) then
               FOnStatus(self,True,'Write Failed [writemsg] Error ('+IntToStr(MKFileError+6000)+')');
         End;
      End;
      If WriteError=0 Then Begin            {Add index record}
         TmpIdx.HdrLoc:=FileSize(HdrFile);
         TmpIdx.MsgToCrc:=JamStrCrc(MKMsgTo);
         {$I-} shSeekFile(IdxFile,FileSize(IdxFile)); {$I+}
         WriteError:=MKFileError;
         If WriteError=0 Then Begin            {write index record}
            {$I-} shWrite(IdxFile,TmpIdx,Sizeof(TmpIdx)); {$I+}
            WriteError:=MKFileError;
            If WriteError=0 Then Begin            {Add subfields as needed}
               If Length(MKMsgTo)>0 Then AddSubField(3,MKMsgTo);
               If Length(MKMsgFrom)>0 Then AddSubField(2,MKMsgFrom);
               If Length(MKMsgSubj)>0 Then Begin
                  If IsFileReq Then AddSubField(11,MKMsgSubj)
                  Else AddSubField(6,MKMsgSubj);
               End;
               If ((Dest.Zone <> 0) or (Dest.Net <> 0) or
                  (Dest.Node <> 0) or (Dest.Point <> 0)) Then
                  AddSubField(1, AddrStr(Dest));
               If ((Orig.Zone <> 0) or (Orig.Net <> 0) or
                  (Orig.Node <> 0) or (Orig.Point <> 0)) Then
                  AddSubField(0, AddrStr(Orig));
               {Seek to end of .jhr file}
               {$I-} shSeekFile(HdrFile,FileSize(HdrFile)); {$I+}
               WriteError := mkFileError;
               If WriteError = 0 Then Begin            {write msg header}
                  {$I-} shWrite(HdrFile,MsgHdr^,
                      SizeOf(MsgHdr^.JamHdr)+MsgHdr^.JamHdr.SubFieldLen); {$I+}
                  WriteError := MKFileError;
                  If WriteError = 0 Then Begin         {update msg base header}
                     Inc(BaseHdr.ActiveMsgs);
                     Inc(BaseHdr.ModCounter);
                  End
                  Else Begin
                  if assigned(FOnStatus) then
                  FOnStatus(self,True,'Write Failed [writemsg] Error ('+IntToStr(MKFileError+12000)+')');
                  End;
               End
               Else Begin
               if assigned(FOnStatus) then
               FOnStatus(self,True,'Write Failed [writemsg] Error ('+IntToStr(MKFileError+11000)+')');
               End;
            End
            Else Begin
            if assigned(FOnStatus) then
               FOnStatus(self,True,'Write Failed [writemsg] Error ('+IntToStr(MKFileError+10000)+')');
            End;
         End
         Else Begin
         if assigned(FOnStatus) then
            FOnStatus(self,True,'Write Failed [writemsg] Error ('+IntToStr(MKFileError+9000)+')');
         End;
      End
      Else Begin
         if assigned(FOnStatus) then
            FOnStatus(self,True,'Write Failed [writemsg] Error ('+IntToStr(MKFileError+8000)+')');
      End;
      UnLockMsgBase;                                   {unlock msg base}
      MKGetHighMsgNumber:=BaseHdr.BaseMsgNum+(FileSize(IdxFile) div Sizeof(JamIdx))-1;
   End;
   WriteMsg:=WriteError;                               {return result}
End;

Function TJamMsgBase.GetChar: Char; {actual routine}
Begin
   If TxtPos < 0 Then Begin
      GetChar := TxtSubBuf[TxtSubChars + TxtPos];
      Inc(TxtPos);
      If TxtPos >= 0 Then TxtPos := MsgHdr^.JamHdr.TextOfs;
   End
   Else Begin
      If ((TxtPos < TxtBufStart) Or
         (TxtPos >= TxtBufStart + TxtRead)) Then Begin
         TxtBufStart := TxtPos - 80;
         If TxtBufStart < 0 Then TxtBufStart := 0;
         {$I-} shSeekFile(TxtFile, TxtBufStart); {$I+}
         Error := MKFileError;
         If Error = 0 Then Begin
            {$I-} shRead(TxtFile, TxtBuf^, SizeOf(TxtBuf^), TxtRead); {$I+}
            Error := MKFileError;
            If Error<>0 then
            if assigned(FOnStatus) then
               FOnStatus(self,True,'JAM Object [GetChar] Error ('+IntToStr(MKFileError+1000)+')');
         End
         Else Begin
         if assigned(FOnStatus) then
            FOnStatus(self,True,'JAM Object [GetChar] Error ('+IntToStr(MKFileError)+')');
         End;
      End;
      GetChar := TxtBuf^[TxtPos - TxtBufStart];
      Inc(TxtPos);
   End;
End;

Procedure TJamMsgBase.AddTxtSub(St: String); {Internal to JAM}
Var
   I:Word;

Begin
   For I:=1 to Length(St) Do Begin
       If TxtSubChars<=TxtSubBufSize-1 Then Begin
          TxtSubBuf[TxtSubChars]:=St[i];
          Inc(TxtSubChars);
       End;
   End;
   If TxtSubChars<=TxtSubBufSize-1 Then Begin
      TxtSubBuf[TxtSubChars]:=#13;
      Inc(TxtSubChars);
   End;
End;

Procedure TJamMsgBase.MsgStartUp; {actual routine}
Var
   SubCtr:LongInt;
   SubPtr:^SubFieldType;
   NumRead:Integer;
   DT:DateTime;
   TmpAddr:AddrType;

Function MoveData(MaxByte:Byte):String;
Var
   LengthSetting:Byte;
   TmpStr: String;

Begin
   LengthSetting:=Min(SubPtr^.DataLen and $ff,MaxByte);
   Setlength(TmpStr,LengthSetting);
   Move(SubPtr^.Data,TmpStr[1],LengthSetting);
   MoveData:=TmpStr;
End;

Begin
   LastSoft:=False;
   MKMsgFrom:='';
   MKMsgTo:='';
   MKMsgSubj:='';
   TxtSubChars:=0;
   FillChar(Dest,SizeOf(Dest),#0); {added 2/25/95}
   FillChar(Orig,SizeOf(Orig),#0); {added 2/25/95}
   If SeekFound Then Begin
{      Error:=ReadIdx;
      If Error=0 Then Begin}
         {$I-} shSeekFile(HdrFile,JamIdx.HdrLoc); {$I+}
         Error:=MKFileError;
         If Error=0 Then Begin
            {$I-} shRead(HdrFile,MsgHdr^,SizeOf(MsgHdr^),NumRead); {$I+}
            Error:=MKFileError;
            If Error = 0 Then Begin
               UnixToDt(MsgHdr^.JamHdr.DateWritten,DT);
               MKMsgDate:=FormattedDate(Dt,'MM-DD-YY',False);
               MKMsgTime:=FormattedDate(Dt,'HH:II',False);
               SubCtr:=1;
               While ((SubCtr<=MsgHdr^.JamHdr.SubFieldLen) and
                  (SubCtr<JamSubBufSize)) Do Begin
                  SubPtr:=@MsgHdr^.SubBuf[SubCtr];
                  Inc(SubCtr,SubPtr^.DataLen+8);
                  Case(SubPtr^.LoId) Of
                     0: Begin {Orig}
                        FillChar(TmpAddr, SizeOf(TmpAddr), #0);
                        FillChar(Orig, SizeOf(Orig), #0);
                        ParseAddr(MoveData(128),TmpAddr,Orig);
                     End;
                     1: Begin {Dest}
                        FillChar(TmpAddr, SizeOf(TmpAddr), #0);
                        FillChar(Dest, SizeOf(Dest), #0);
                        ParseAddr(MoveData(128),TmpAddr,Dest);
                     End;
                     2: {MsgFrom}
                        MKMsgFrom:=MoveData(65);
                     3: {MsgTo}
                        MKMsgTo:=MoveData(65);
                     4: {MsgId}
                        AddTxtSub(#1'MSGID: ' + MoveData(240));
                     5: {Reply}
                        AddTxtSub(#1'REPLY: ' + MoveData(240));
                     6: {MsgSubj}
                        MKMsgSubj:=MoveData(100);
                     7: {PID}
                        AddTxtSub(#1'PID: ' + MoveData(240));
                     8: {VIA}
                        AddTxtSub(#1'Via ' + MoveData(240));
                     9: {File attached}
                        If IsFAttach Then MKMsgSubj:=MoveData(100);
                    11: {File request}
                        If IsFileReq Then MKMsgSubj:=MoveData(100);
                  2000:  {Unknown kludge}
                         AddTxtSub(#1 + MoveData(240));
                  2001: {SEEN-BY}
                        AddTxtSub(#1'SEEN-BY: ' + MoveData(240));
                  2002: {PATH}
                        AddTxtSub(#1'PATH: ' + MoveData(240));
                  2003: {FLAGS}
                        AddTxtSub(#1'FLAGS: ' + MoveData(240));
                  End;
               End;
            End
            Else Begin
            if assigned(FOnStatus) then
            FOnStatus(self,True,'JAM Object [MsgStartup] Error ('+IntToStr(MKFileError+2000)+')');
            End;
         End
         Else Begin
         if assigned(FOnStatus) then
            FOnStatus(self,True,'JAM Object [MsgStartup] Error ('+IntToStr(MKFileError+1000)+')');
         End;
{      End
      Else Begin
         if assigned(FOnStatus) then
            FOnStatus(self,True,'JAM Object [MsgStartup] Error ('+IntToStr(MKFileError)+')');
      End;}
   End;
End;

Procedure TJamMsgBase.MsgTxtStartUp; {actual routine}
Begin
   LastSoft:=False;
   TxtEnd:=MsgHdr^.JamHdr.TextOfs+MsgHdr^.JamHdr.TextLen-1;
   If TxtSubChars>0 Then TxtPos:=-TxtSubChars
   Else TxtPos:=MsgHdr^.JamHdr.TextOfs;
End;

Function TJamMsgBase.GetString(MaxLen: Word): String; {actual routine}
  Var
    WPos: LongInt;
    WLen: Byte;
    StrDone: Boolean;
    StartSoft: Boolean;
    CurrLen: Word;
    TmpCh: Char;
    TmpGetString:String;

  Begin
  StrDone := False;
  CurrLen := 0;
  WPos := 0;
  WLen := 0;
  StartSoft := LastSoft;
  LastSoft := True;
  TmpCh := GetChar;
  TmpGetString:='';
  While ((Not StrDone) And (CurrLen < MaxLen) And (Not EOM)) Do
    Begin
    Case TmpCh of
      #$00:;
      #$0d: Begin
            StrDone := True;
            LastSoft := False;
            End;
      #$8d:;
      #$0a:;
      #$20: Begin
            If ((CurrLen <> 0) or (Not StartSoft)) Then
              Begin
              Inc(CurrLen);
              WLen := CurrLen;
              TmpGetString := TmpGetString + TmpCh;
              WPos := TxtPos;
              End
            Else
              StartSoft := False;
            End;
      Else
        Begin
        Inc(CurrLen);
        TmpGetString := TmpGetString + TmpCh;
        End;
      End;
    If Not StrDone Then
      TmpCh := GetChar;
    End;
  If StrDone Then SetLength(TmpGetString,CurrLen)
  Else If EOM Then Begin
          SetLength(TmpGetString,CurrLen);
       End
       Else Begin
          If WLen = 0 Then Begin
             SetLength(TmpGetString,CurrLen);
             Dec(TxtPos);
          End
          Else Begin
             SetLength(TmpGetString,WLen);
             TxtPos := WPos;
          End;
       End;
   GetSTring:=TmpGetString;
End;

Function TJamMsgBase.EOM: Boolean; {actual routine}
  Begin
  EOM := (((TxtPos < MsgHdr^.JamHdr.TextOfs) Or
    (TxtPos > TxtEnd)) And (TxtPos >= 0));
  End;

Function TJamMsgBase.GetMsgNum: LongInt; {Get message number}
  Begin
  GetMsgNum := MsgHdr^.JamHdr.MsgNum;
  End;


Function TJamMsgBase.IsLocal: Boolean; {Is current msg local}
  Begin
  IsLocal := (MsgHdr^.JamHdr.Attr1 and Jam_Local) <> 0;
  End;

Function TJamMsgBase.IsCrash: Boolean; {Is current msg crash}
  Begin
  IsCrash := (MsgHdr^.JamHdr.Attr1 and Jam_Crash) <> 0;
  End;

Function TJamMsgBase.IsKillSent: Boolean; {Is current msg kill sent}
  Begin
  IsKillSent := (MsgHdr^.JamHdr.Attr1 and Jam_KillSent) <> 0;
  End;

Function TJamMsgBase.IsSent: Boolean; {Is current msg sent}
  Begin
  IsSent := (MsgHdr^.JamHdr.Attr1 and Jam_Sent) <> 0;
  End;

Function TJamMsgBase.IsFAttach: Boolean; {Is current msg file attach}
  Begin
  IsFAttach := (MsgHdr^.JamHdr.Attr1 and Jam_FAttch) <> 0;
  End;

Function TJamMsgBase.IsReqRct: Boolean; {Is current msg request receipt}
  Begin
  IsReqRct := (MsgHdr^.JamHdr.Attr1 and Jam_RcptReq) <> 0;
  End;

Function TJamMsgBase.IsReqAud: Boolean; {Is current msg request audit}
  Begin
  IsReqAud := (MsgHdr^.JamHdr.Attr1 and Jam_ConfmReq) <> 0;
  End;

Function TJamMsgBase.IsRetRct: Boolean; {Is current msg a return receipt}
  Begin
  IsRetRct := False;
  End;

Function TJamMsgBase.IsFileReq: Boolean; {Is current msg a file request}
  Begin
  IsFileReq := (MsgHdr^.JamHdr.Attr1 and Jam_Freq) <> 0;
  End;

Function TJamMsgBase.IsRcvd: Boolean; {Is current msg received}
  Begin
  IsRcvd := (MsgHdr^.JamHdr.Attr1 and Jam_Rcvd) <> 0;
  End;

Function TJamMsgBase.IsPriv: Boolean; {Is current msg priviledged/private}
  Begin
  IsPriv := (MsgHdr^.JamHdr.Attr1 and Jam_Priv) <> 0;
  End;

Function TJamMsgBase.IsDeleted: Boolean; {Is current msg deleted}
Begin
   IsDeleted:=(MsgHdr^.JamHdr.Attr1 and Jam_Deleted)<>0;
End;

Function TJamMsgBase.IsEchoed: Boolean; {Is current msg echoed}
  Begin
  IsEchoed := True;
  End;

Procedure TJamMsgBase.SeekFirst(MsgNum: LongInt); {Start msg seek}
Begin
   CurrMsgNum:=MsgNum-1;
   If CurrMsgNum<BaseHdr.BaseMsgNum-1 Then CurrMsgNum:=BaseHdr.BaseMsgNum-1;
   SeekNext;
End;

Procedure TJamMsgBase.SeekNext; {Find next matching msg}
Begin
   If CurrMsgNum<=GetHighMsgNum Then Inc(CurrMsgNum);
   Error:=ReadIdx;
   While (((JamIdx.HdrLoc<0) or (JamIdx.MsgToCrc=-1)) And
     (Error=0)) Do Begin
     Inc(CurrMsgNum);
     If (CurrMsgNum<=GetHighMsgNum) then Begin
     Error:=ReadIdx;
     If Error<>0 then
       if assigned(FOnStatus) then
          FOnStatus(self,True,'JAM Object [SeekNext] Error ('+IntToStr(Error)+')');
     End
     Else Begin
        JamIdx.HdrLoc:=-1;
        JamIdx.MsgToCrc:=-1;
        Error:=1;
     End;
   End;
End;

Procedure TJamMsgBase.SeekPrior;
Begin
   If CurrMsgNum>=BaseHdr.BaseMsgNum Then Dec(CurrMsgNum);
   Error:=ReadIdx;
   If Error<>0 then
      if assigned(FOnStatus) then
      FOnStatus(self,True,'JAM Object [SeekPrior] Error ('+IntToStr(Error)+')');
   If CurrMsgNum>=BaseHdr.BaseMsgNum Then Begin
      While (((JamIdx.HdrLoc<0) or (JamIdx.MsgToCrc=-1)) And
         (CurrMsgNum>=BaseHdr.BaseMsgNum)) Do Begin
         Dec(CurrMsgNum);
         If (CurrMsgNum>=BaseHdr.BaseMsgNum) then Begin
         Error:=ReadIdx;
         If Error<>0 then
           if assigned(FOnStatus) then
         FOnStatus(self,True,'JAM Object [SeekPrior] Error ('+IntToStr(Error+1000)+')');
         End;
      End;
   End;
End;

Function TJamMsgBase.MKSeekFound: Boolean;
Begin
   MKSeekFound:=((CurrMsgNum>=BaseHdr.BaseMsgNum) and
      (CurrMsgNum<=GetHighMsgNum) and (JamIdx.HdrLoc>-1) and (JamIdx.MsgToCrc<>-1));
End;

Function TJamMsgBase.GetMsgLoc: LongInt; {Msg location}
  Begin
  GetMsgLoc := GetMsgNum;
  End;

Procedure TJamMsgBase.SetMsgLoc(ML: LongInt); {Msg location}
Begin
   CurrMsgNum:=ML;
End;

Procedure TJamMsgBase.YoursFirst(Name:String;Handle:String);
Begin
   YourName:=UpperCase(Name);
   YourHdl:=UpperCase(Handle);
   NameCrc:=JamStrCrc(Name);
   HdlCrc:=JamStrCrc(Handle);
   CurrMsgNum:=BaseHdr.BaseMsgNum-1;
   YoursNext;
End;

Procedure TJamMsgBase.YoursNext;
Var
   Found:Boolean;
   NumRead:Integer;
   SubCtr:LongInt;
   SubPtr:^SubFieldType;

Begin
   Error := 0;
   Found := False;
   Inc(CurrMsgNum);
   While ((Not Found) and (CurrMsgNum<=GetHighMsgNum) And (Error=0)) Do Begin
      Error:=ReadIdx;
      If Error=0 Then Begin                            {Check CRC values}
         If ((JamIdx.MsgToCrc=NameCrc) or
            (JamIdx.MsgToCrc=HdlCrc)) Then Begin
            {$I-} shSeekFile(HdrFile,JamIdx.HdrLoc); {$I+}
            Error:=MKFileError;
            If Error=0 Then Begin                        {Read message header}
               {$I-} shRead(HdrFile,MsgHdr^,SizeOf(MsgHdr^),NumRead); {$I+}
               Error:=MKFileError;
               If Error<>0 then
                  if assigned(FOnStatus) then
                  FOnStatus(self,True,'JAM Object [YoursNext] Error ('+IntToStr(Error+2000)+')');
            End
            Else Begin
            if assigned(FOnStatus) then
            FOnStatus(self,True,'JAM Object [YoursNext] Error ('+IntToStr(Error+1000)+')');
            End;
            If ((Error=0) and (Not IsRcvd)) Then Begin
               SubCtr:=1;
               While ((SubCtr<=MsgHdr^.JamHdr.SubFieldLen) and
                  (SubCtr<JamSubBufSize)) Do Begin
                  SubPtr:=@MsgHdr^.SubBuf[SubCtr];
                  Inc(SubCtr,SubPtr^.DataLen+8);
                  Case(SubPtr^.LoId) Of
                     3:Begin {MsgTo}
                          If SubPtr^.DataLen and $ff>65 then SetLength(MKMsgTo,65)
                          Else SetLength(MKMsgTo,SubPtr^.DataLen and $ff);
                          Move(SubPtr^.Data, MKMsgTo[1], Length(MKMsgTo));
                          If ((UpperCase(MKMsgTo)=YourName) Or
                             (UpperCase(MKMsgTo)=YourHdl)) Then
                          Found:=True;
                     End;
                  End;
               End;
            End;
         End;
      End
      Else Begin
      if assigned(FOnStatus) then
        FOnStatus(self,True,'JAM Object [YoursNext] Error ('+IntToStr(Error)+')');
      End;
      If (Not Found) Then Inc(CurrMsgNum);
   End;
End;

Function TJamMsgBase.MKYoursFound:Boolean;
Begin
   MKYoursFound:=((CurrMsgNum>=BaseHdr.BaseMsgNum) and
      (CurrMsgNum<=GetHighMsgNum) and (JamIdx.HdrLoc>-1) and (JamIdx.MsgToCrc<>-1));
End;

Procedure TJamMsgBase.StartNewMsg;
Begin
   TxtBufStart:=0;
   TxtPos:=0;
   FillChar(MsgHdr^,SizeOf(MsgHdr^),#0);
   MsgHdr^.JamHdr.SubFieldLen:=0;
   MsgHdr^.JamHdr.MsgIdCrc:=-1;
   MsgHdr^.JamHdr.ReplyCrc:=-1;
   MsgHdr^.JamHdr.PwdCrc:=-1;
   MKMsgTo:='';
   MKMsgFrom:='';
   MKMsgSubj:='';
   FillChar(Orig,SizeOf(Orig),#0);
   FillChar(Dest,SizeOf(Dest),#0);
   MKMsgDate:=DateStr(GetDosDate);
   MKMsgTime:=TimeStr(GetDosDate);
End;

Function TJamMsgBase.MKMsgBaseExists: Boolean;
Begin
   MKMsgBaseExists:=FileExist(MsgPath+'.JHR');
End;

Function TJamMsgBase.OpenMsgBase: Word;
Var
   NumRead:Integer;

Begin
   LockCount := 0;
   MKGetHighMsgNumber:=0;
   shOpenFile(HdrFile,MsgPath+'.JHR');
   If MKFileError=0 Then Begin
      shSeekFile(HdrFile,0);
      shRead(HdrFile,BaseHdr,SizeOf(BaseHdr),NumRead);
      MKGetHighMsgNumber:=BaseHdr.BaseMsgNum;
      If MKFileError<>0 then
         if assigned(FOnStatus) then
            FOnStatus(self,True,'JAM Object [OpenMsgBase] Error ('+IntToStr(MKFileError+1000)+')');
   End
   Else Begin
      if assigned(FOnStatus) then
         FOnStatus(self,True,'JAM Object [OpenMsgBase] Error ('+IntToStr(MKFileError)+')');
   End;
   shOpenFile(TxtFile,MsgPath+'.JDT');
   If MKFileError<>0 Then Begin
      if assigned(FOnStatus) then
         FOnStatus(self,True,'JAM Object [OpenMsgBase] Error ('+IntToStr(MKFileError+2000)+')');
   End;
   shOpenFile(IdxFile,MsgPath+'.JDX');
   If MKFileError<>0 Then Begin
      if assigned(FOnStatus) then
         FOnStatus(self,True,'JAM Object [OpenMsgBase] Error ('+IntToStr(MKFileError+3000)+')');
   End
   Else MKGetHighMsgNumber:=BaseHdr.BaseMsgNum+(FileSize(IdxFile) div Sizeof(JamIdx))-1;
   TxtBufStart:=-10;
   TxtRead:=0;
   OpenMsgBase:=MKFileError;
   FActive:=MKFileError=0;
End;

Procedure TJamMsgBase.SetActive(Value:Boolean);
Begin
   If Value=FActive then Exit
   Else Begin
      If Value then OpenMsgBase
      Else CloseMsgBase;
   End;
End;

Function TJamMsgBase.CloseMsgBase: Word;
Begin
   shCloseFile(HdrFile);
   If MKFileError<>0 then Begin
      if assigned(FOnStatus) then
         FOnStatus(self,True,'JAM Object [CloseMsgBase] Error ('+IntToStr(MKFileError)+')');
   End
   Else Begin
      shCloseFile(TxtFile);
      If MKFileError<>0 then Begin
         if assigned(FOnStatus) then
            FOnStatus(self,True,'JAM Object [CloseMsgBase] Error ('+IntToStr(MKFileError+1000)+')');
      End
      Else Begin
         shCloseFile(IdxFile);
         If MKFileError<>0 then Begin
            if assigned(FOnStatus) then
               FOnStatus(self,True,'JAM Object [CloseMsgBase] Error ('+IntToStr(MKFileError+2000)+')');
         End;
      End;
   End;
   CloseMsgBase:=MKFileError;
   FActive:=Not (MKFileError=0);
End;

Function TJamMsgBase.CreateMsgBase(MaxMsg: Word; MaxDays: Word): Word;
Var
   TmpHdr: ^JamHdrType;
   CreateError: Word;
   i:Integer;

Begin
   CreateError:=0;
   i:=PosLastChar('\',MsgPath);
   If (I=3) and (MsgPath[2]=':') then I:=0;
   If (i>0) Then Begin
      MakePath(Copy(MsgPath,1,i));
      If Not DirExist(Copy(MsgPath,1,i)) Then Begin
         CreateError:=100;
         CreateMsgBase:=CreateError;
{         ShowMessage('DirExist Failed on '+Copy(MsgPath,1,i));}
         Exit;
      End;
   End;
   New(TmpHdr);
   If TmpHdr=Nil Then CreateError := 500
   Else Begin
      FillChar(TmpHdr^,SizeOf(TmpHdr^),#0);
      TmpHdr^.Signature[1]:='J';
      TmpHdr^.Signature[2]:='A';
      TmpHdr^.Signature[3]:='M';
      TmpHdr^.BaseMsgNum:=1;
      TmpHdr^.Created:=ToUnixDate(GetDosDate);
      TmpHdr^.PwdCrc:=-1;
      CreateError:=SaveFile(MsgPath+'.JHR',TmpHdr^,SizeOf(TmpHdr^));
      If CreateError<>0 then
      if assigned(FOnStatus) then
      FOnStatus(self,True,'JAM Object [CreateMsgBase] Error ('+IntToStr(CreateError)+')');
      Dispose(TmpHdr);
      If CreateError=0 Then CreateError:=SaveFile(MsgPath+'.JLR',CreateError,0);
      If CreateError<>0 then
      if assigned(FOnStatus) then
      FOnStatus(self,True,'JAM Object [CreateMsgBase] Error ('+IntToStr(CreateError+1000)+')');
      If CreateError=0 Then CreateError:=SaveFile(MsgPath+'.JDT',CreateError,0);
      If CreateError<>0 then
      if assigned(FOnStatus) then
      FOnStatus(self,True,'JAM Object [CreateMsgBase] Error ('+IntToStr(CreateError+2000)+')');
      If CreateError=0 Then CreateError:=SaveFile(MsgPath+'.JDX',CreateError,0);
      If CreateError<>0 then
      if assigned(FOnStatus) then
      FOnStatus(self,True,'JAM Object [CreateMsgBase] Error ('+IntToStr(CreateError+3000)+')');
      If IoResult<>0 Then;
   End;
   CreateMsgBase:=CreateError;
End;

Procedure TJamMsgBase.SetMailType(Value: MsgMailType);
  Begin
  MailType := Value;
  End;

Function TJamMsgBase.GetSubArea: Word;
  Begin
  GetSubArea := 0;
  End;

Procedure TJamMsgBase.ReWriteHdr;
Begin
  If LockMsgBase Then Begin
     Error:=ReadIdx;
     If Error<>0 then
        if assigned(FOnStatus) then
        FOnStatus(self,True,'JAM Object [ReWriteHDr] Error ('+IntToStr(Error)+')');
  End
  Else Error := 5;
  If (Error=0) and (JamIdx.HdrLoc>=0) Then Begin
     {$I-} shSeekFile(HdrFile,JamIdx.HdrLoc); {$I+}
     Error := MKFileError;
     If Error = 0 Then Begin
        {$I-} shWrite(HdrFile, MsgHdr^.JamHdr, SizeOf(MsgHdr^.JamHdr)); {$I+}
        Error := MKFileError;
        If Error<>0 then
        if assigned(FOnStatus) then
        FOnStatus(self,True,'JAM Object [ReWriteHDr] Error ('+IntToStr(Error+1000)+')');
     End
     Else
        if assigned(FOnStatus) then
        FOnStatus(self,True,'JAM Object [ReWriteHDr] Error ('+IntToStr(Error+2000)+')');

     If UnLockMsgBase Then;
  End
  Else Begin
     If JamIdx.HdrLoc<0 then
        if assigned(FOnStatus) then
        FOnStatus(self,True,'JAM Object [ReWriteHDr] Error (Bad HdrLoc)');
  End;
End;

Procedure TJamMsgBase.DeleteMsg;
Begin
   If Not IsDeleted Then Begin
      If LockMsgBase Then Begin
         SetAttr1(Jam_Deleted,True);
         Dec(BaseHdr.ActiveMsgs);
         If ReadIdx<>0 then Begin
            if assigned(FOnStatus) then
            FOnStatus(self,True,'JAM Object [DeleteMsg] Error ('+IntToStr(MkFileError)+')');
         End
         Else Begin
            {$I-} shSeekFile(HdrFile,JamIdx.HdrLoc); {$I+}
            If MKFileError=0 then Begin
            {$I-} shWrite(HdrFile, MsgHdr^.JamHdr, SizeOf(MsgHdr^.JamHdr)); {$I+}
            If MKFileError<>0 then
            if assigned(FOnStatus) then
            FOnStatus(self,True,'JAM Object [DeleteMsg] Error ('+IntToStr(MkFileError+2000)+')');
            End
            Else Begin
            if assigned(FOnStatus) then
            FOnStatus(self,True,'JAM Object [DeleteMsg] Error ('+IntToStr(MkFileError+1000)+')');
            End;
            Inc(BaseHdr.ModCounter);
            JamIdx.MsgToCrc:=-1;
            JamIdx.HdrLoc:=-1;
            If WriteIdx<>0 then
            if assigned(FOnStatus) then
            FOnStatus(self,True,'JAM Object [DeleteMsg] Error ('+IntToStr(MkFileError+3000)+')');
         End;
         MKGetHighMsgNumber:=BaseHdr.BaseMsgNum+(FileSize(IdxFile) div Sizeof(JamIdx))-1;
         If UnLockMsgBase Then;
      End;
   End;
End;

Function TJamMsgBase.MKNumberOfMsgs:LongInt;
Begin
   MKNumberOfMsgs:=BaseHdr.ActiveMsgs;
End;

Function TJamMsgBase.FindLastRead(Var LastFile: File; UNum: LongInt): LongInt;
  Const
    LastSize = 100;

  Type LastArray = Array[1..LastSize] of JamLastType;

  Var
    LastBuf: ^LastArray;
    LastError: Word;
    NumRead: Integer;
    Found: Boolean;
    i: Word;
    LastStart: LongInt;

  Begin
  FindLastRead := -1;
  Found := False;
  New(LastBuf);
{$I-}  shSeekFile(LastFile, 0); {$I+}
  LastError := MKFILEERROR;
  While ((Not Eof(LastFile)) and (LastError = 0) And (Not Found)) Do
    Begin
    LastStart := FilePos(LastFile);
    {$I-} shRead(LastFile, LastBuf^, LastSize, NumRead); {$I+}
    LastError := MKFileError;
    For i := 1 to NumRead Do
      Begin
      If LastBuf^[i].UserNum = UNum Then
        Begin
        Found := True;
        FindLastRead := LastStart + i - 1;
        End;
      End;
    End;
  Dispose(LastBuf);
  End;

Function TJamMsgBase.GetLastRead(UNum: LongInt): LongInt;
  Var
    RecNum: LongInt;
    LastFile: File;
    TmpLast: JamLastType;
    NumRead:Integer;

Begin
   shAssign(LastFile,MsgPath+'.JLR');
   FileMode:=fmReadWrite+fmDenyNone;
   shReset(LastFile,SizeOf(JamLastType));
   RecNum:=FindLastRead(LastFile, UNum);
   GetLastRead:=0;
   If RecNum>=0 Then Begin
      shSeekFile(LastFile, RecNum);
      If MKFileError=0 Then Begin
         shRead(LastFile,TmpLast,1,NumRead);
         GetLastRead := TmpLast.HighRead;
      End;
   End;
   shCloseFile(LastFile);
End;

Procedure TJamMsgBase.SetLastRead(UNum: LongInt; LR: LongInt);
  Var
    RecNum: LongInt;
    LastFile: File;
    TmpLast: JamLastType;
    NumRead:Integer;

Begin
   shAssign(LastFile,MsgPath+'.JLR');
   FileMode:=fmReadWrite+fmDenyNone;
   shReset(LastFile, SizeOf(JamLastType));
   RecNum := FindLastRead(LastFile, UNum);
   If RecNum >= 0 Then Begin
      shSeekFile(LastFile, RecNum);
      If MKFileError = 0 Then Begin
         shRead(LastFile, TmpLast, 1, NumRead);
         TmpLast.HighRead := LR;
         TmpLast.LastRead := LR;
         If MKFileError=0 Then shSeekFile(LastFile, RecNum);
         If MKFileError=0 Then shWrite(LastFile,TmpLast,1);
      End;
   End
   Else Begin
      TmpLast.UserNum := UNum;
      TmpLast.HighRead := Lr;
      TmpLast.NameCrc := UNum;
      TmpLast.LastRead := Lr;
       shSeekFile(LastFile,FileSize(LastFile));
      If MKFileError=0 Then shWrite(LastFile,TmpLast,1);
    End;
    shCloseFile(LastFile);
End;

Function TJamMsgBase.GetTxtPos: LongInt;
Begin
   GetTxtPos:=TxtPos;
End;

Procedure TJamMsgBase.SetTxtPos(TP: LongInt);
Begin
   TxtPos:=TP;
End;

Function TJamMsgBase.LockMsgBase: Boolean;
  Var
    LockError: Boolean;
    NumRead:Integer;

  Begin
  LockError := False;
      {LockError := shLock(HdrFile, 0, 1);}
{      LockError:=LockFile(TFileRec(HdrFile).Handle, 0,0, 1,0);
      If LockError then ShowMessage('Lock Failed!');}
      If Not LockError Then Begin
      {$I-} shSeekFile(HdrFile,0); {$I+}
      LockError := MKFileError<>0;
      If MKFileError<>0 then
            if assigned(FOnStatus) then
            FOnStatus(self,True,'JAM Object [Lock] Error ('+IntToStr(MkFileError)+')');
      End;
      If Not LockError Then Begin
      {$I-} shRead(HdrFile,BaseHdr,SizeOf(BaseHdr),NumRead); {$I+}
      LockError:=MKFileError<>0;
      If MKFileError<>0 then
            if assigned(FOnStatus) then
            FOnStatus(self,True,'JAM Object [Lock] Error ('+IntToStr(MkFileError+1000)+')');
      End;
  Inc(LockCount);
  LockMsgBase := {LockError;} True;
  End;

Function TJamMsgBase.UnLockMsgBase: Boolean;
  Var
    LockError: Boolean;

  Begin
  LockError := False;
  If LockCount > 0 Then Dec(LockCount);
  If LockCount = 0 Then Begin
    If Not LockError Then  Begin
{      LockError := UnLockFile(TFileRec(HdrFile).Handle, 0,0, 1,0);
      If LockError then ShowMessage('UN-Lock Failed!');}
    End;
    If Not LockError Then  Begin
      {$I-} shSeekFile(HdrFile, 0); {$I+}
      LockError := MKFileError<>0;
      If MKFileError<>0 then
            if assigned(FOnStatus) then
            FOnStatus(self,True,'JAM Object [UNLock] Error ('+IntToStr(MkFileError)+')');
    End;
    If Not LockError Then Begin
      {$I-} shWrite(HdrFile, BaseHdr, SizeOf(BaseHdr)); {$I+}
      LockError := MKFileError<>0;
      If MKFileError<>0 then
            if assigned(FOnStatus) then
            FOnStatus(self,True,'JAM Object [UNLock] Error ('+IntToStr(MkFileError+1000)+')');
      End;
    End;
  UnLockMsgBase := {LockError;} True;
  End;

{SetSeeAlso/GetSeeAlso provided by 2:201/623@FidoNet Jonas@iis.bbs.bad.se}
Procedure TJamMsgBase.SetNextSeeAlso(Value: LongInt);
  Begin
  MsgHdr^.JamHdr.ReplyNext := Value;
  End;

Function TJamMsgBase.GetNextSeeAlso: LongInt; {Get next see also of current msg}
Begin
   GetNextSeeAlso:=MsgHdr^.JamHdr.ReplyNext;
End;

Function TJamMsgBase.ReadIdx:Word;
Var
   I:Integer;

Begin
   {check idxfile - see if open!}
   I:=CurrMsgNum-BaseHdr.BaseMsgNum;
   {$I-} shSeekFile(IdxFile,(I*SizeOf(JamIdx)));
   shRead(IdxFile,JamIdx,SizeOf(JamIdx),I); {$I+}
   ReadIdx:=MKFileError;
End;

Function TJamMsgBase.WriteIdx:Word;
Var
   I:Integer;

Begin
   I:=CurrMsgNum-BaseHdr.BaseMsgNum;
   {$I-} shSeekFile(IdxFile,(I*SizeOf(JamIdx)));
   shWrite(IdxFile,JamIdx,SizeOf(JamIdx)); {$I+}
   WriteIdx:=MKFileError;
End;

Procedure TJamMsgBase.SetEcho(Value:Boolean);
Begin
   {blah}
End;

Procedure Register;
Begin
   RegisterComponents('Warpgroup',[TJamMsgBase]);
End;

End.
