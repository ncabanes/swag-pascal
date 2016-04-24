(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0456.PAS
  Description: Fido Mail Unit for D2
  Author: OZZ NIXON JR
  Date: 01-02-98  07:35
*)

Unit MKMsgFido32;       {Fido Object *.Msg Unit}

///////////////////////////////////////////////////////////////////////////////
// MKMsgFIDO32 Coded in Part by G.E. Ozz Nixon Jr. of www.warpgroup.com      //
// ========================================================================= //
// Original Source for DOS by Mythical Kindom's Mark May (mmay@dnaco.net)    //
// Re-written and distributed with permission!                               //
// See Original Copyright Notice before using any of this code!              //
///////////////////////////////////////////////////////////////////////////////

Interface

Uses
   MkFidoAddr32,
   Classes;

Const
   Version='9.19.97';
   MaxFidMsgArray=4000;
   MaxFidMsgNum=(MaxFidMsgArray*8)-1;

Type
   MsgMailType = (mtNormal, mtEchoMail, mtNetMail);

   TFidoMsgBase = Class(TComponent)
   private
      LastSoft:Boolean;
      FActive:Boolean;
      TextCtr:LongInt;
      MsgPath:String;
      MsgPathExists:Boolean;
      LastPath:String;
      MKMsgFrom:String;
      MKMsgTo:String;
      MKMsgSubj:String;
      MKMsgDate:String;
      MKMsgTime:String;
      TmpName:String;  {now is the msg text in ram!}
      TmpOpen:Boolean;
      MsgFile:File;
      Error:Word;
{      NetMailPath:String;}
      Dest:AddrType;
      Orig:AddrType;
      MsgStart:LongInt;
      MsgEnd:LongInt;
      MsgDone:Boolean;
      CurrMsg:LongInt;
      SeekOver:Boolean;
      YoursName:String;
      YoursHandle:String;
      MailType:MsgMailType;
      MsgPresent:Array[0..MaxFidMsgArray] of Byte;
      MKMsgReplyTo:Longint;
      MkMsgFlagLow:Byte;
      MkMsgFlagHigh:Byte;
      MkMsgNextReply:Longint;
      MkMsgCost:Word;
      MsgOpen:Boolean;
      Function  MsgExists(MsgNum:LongInt):Boolean;
      Procedure CheckLine(TStr: String);
      Procedure Rescan(S:String);
      Function  MKGetHighMsgNumber:Longint; Virtual;
      Procedure SetCost(Value:Word); Virtual;
      Function  GetCost:Word; Virtual;
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
      property  MsgPathFileName: String read MsgPath write Rescan;
      property  GetHighMsgNum: LongInt read MKGetHighMsgNumber;
      property  HdrDest: AddrType read Dest write Dest;
      property  HdrOrig: AddrType read Orig write Orig;
      property  HdrFrom: String read MKMsgFrom write MKMsgFrom;
      property  HdrTo: String read MKMsgTo write MKMsgTo;
      property  HdrSubj: String read MKMsgSubj write MKMsgSubj;
      property  HdrCost: Word read GetCost write SetCost;
      property  HdrRefer: LongInt read MkMsgReplyTo write MkMsgReplyTo;
      property  HdrSeeAlso: LongInt read MkMsgNextReply write MkMsgNextReply;
      property  HdrNextSeeAlso: LongInt read GetNextSeeAlso write SetNextSeeAlso;
      property  HdrDate: String read MKMsgDate write MKMsgDate;
      property  HdrTime: String read MKMsgTime write MKMsgTime;
      property  HdrAttrLocal:Boolean read IsLocal write SetLocal;
      property  HdrAttrReceived:Boolean read IsRcvd write SetRcvd;
      property  HdrAttrPrivate:Boolean read IsRcvd write SetPriv;
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
      property  EndOfMsgText:Boolean read MsgDone;
      Property  WasWrap: Boolean read LastSoft;
      Property  MsgBaseExists: Boolean read MKMsgBaseExists;
      Property  SeekFound: Boolean read MKSeekFound;
      Property  YoursFound: Boolean read MKyoursFound;
      Property  HdrMailType:MsgMailType read MailType write SetMailType;
      Property  MsgNumber:Longint read CurrMsg;
      property  NumberOfMsgs: LongInt read MkNumberofMsgs;
  End;

Procedure Register;

Implementation

Uses
   SysUtils,
   MKFile32,
   MKString32;

Const
   PosArray: Array[0..7] of Byte = (1, 2, 4, 8, 16, 32, 64, 128);

Type
   NetMsg=RECORD
      FromUser  : ARRAY[1..36] OF Char;
      ToUser    : ARRAY[1..36] OF Char;
      subj      : ARRAY[1..72] OF Char;
      dateTime  : ARRAY[1..20] OF Char; { 01 Jan 86  02:34:56 }
      timesRead : Word;
      destNode  : Word;
      origNode  : Word;
      cost      : Word;
      origNet   : Word;
      destNet   : Word;
      destZone  : Word; { optional; was sentTime }
      origZone  : Word; { optional; was sentTime }
      destPoint : Word; { optional; was readTime }
      origPoint : Word; { optional; was readTime }
      replyTo   : Word;
      flag1     : Byte;
      flag2     : Byte;
      nextReply : Word;
   End;

Constructor TFidoMsgBase.Create(AOwner:TComponent);
Begin
   Inherited Create(AOwner);
   MsgPathFileName:='';
   TextCtr:=0;
   FillChar(Dest,Sizeof(Dest),#0);
   FillChar(Orig,Sizeof(Orig),#0);
   SeekOver:=False;
   TmpOpen:=False;
   TmpName:='';
   LastPath:='';
   MsgPath:='';
   LastSoft:=False;
   FActive:=False;
   MKMsgFrom:='Noone';
   MKMsgTo:='Noone';
   MKMsgSubj:='MsgBase Not Active yet';
   MKMsgDate:='mm-dd-yy';
   MKMsgTime:='hh:mm';
End;

Destructor TFidoMsgBase.Destroy;
Begin
   If TmpOpen Then TmpName:='';
End;

{Procedure TFidoMsgBase.PutLong(L: LongInt; Position: LongInt);
  Var
    i: Integer;

  Begin
  If FM^.MsgFile.SeekFile(Position) Then
    If FM^.MsgFile.BlkWrite(L, SizeOf(LongInt)) Then;
  End;


Procedure TFidoMsgBase.PutWord(W: Word; Position: LongInt);
  Begin
  If FM^.MsgFile.SeekFile(Position) Then
    If FM^.MsgFile.BlkWrite(W, SizeOf(Word)) Then;
  End;


Procedure TFidoMsgBase.PutByte(B: Byte; Position: LongInt);
  Begin
  If FM^.MsgFile.SeekFile(Position) Then
    If FM^.MsgFile.BlkWrite(B, SizeOf(Byte)) Then;
  End;


Function TFidoMsgBase.GetByte(Position: LongInt): Byte;
  Var
    B: Byte;
    NumRead: Word;

  Begin
  If FM^.MsgFile.SeekFile(Position) Then
    If FM^.MsgFile.BlkRead(B, SizeOf(Byte), NumRead) Then;
  GetByte := b;
  End;


Procedure TFidoMsgBase.PutNullStr(St: String; Position: LongInt);
  Var
    i: Byte;

  Begin
  i := 0;
  If FM^.MsgFile.SeekFile(Position) Then
    Begin
    If FM^.MsgFile.BlkWrite(St[1], Length(St)) Then;
    If FM^.MsgFile.BlkWrite(i, 1) Then;
    End;
  End; }

Function TFidoMsgBase.MKGetHighMsgNumber: LongInt;
  Var
  Highest: LongInt;
  Cnt: LongInt;

Begin
   Cnt:=MaxFidMsgArray;
   While (Cnt>0) and (MsgPresent[Cnt]=0) Do Dec(Cnt);
   If Cnt<0 Then Highest:=0
   Else Begin
      Highest:=Cnt*8;
      If (MsgPresent[Cnt] and $80)<>0 Then Inc(Highest,7)
      Else If (MsgPresent[Cnt] and $40)<>0 Then Inc(Highest,6)
      Else If (MsgPresent[Cnt] and $20)<>0 Then Inc(Highest,5)
      Else If (MsgPresent[Cnt] and $10)<>0 Then Inc(Highest,4)
      Else If (MsgPresent[Cnt] and $08)<>0 Then Inc(Highest,3)
      Else If (MsgPresent[Cnt] and $04)<>0 Then Inc(Highest,2)
      Else If (MsgPresent[Cnt] and $02)<>0 Then Inc(Highest,1)
   End;
   MkGetHighMsgNumber:=Highest;
End;


Function MonthStr(MoNo: Byte): String;
  Begin
  Case MoNo of
    01: MonthStr := 'Jan';
    02: MonthStr := 'Feb';
    03: MonthStr := 'Mar';
    04: MonthStr := 'Apr';
    05: MonthStr := 'May';
    06: MonthStr := 'Jun';
    07: MonthStr := 'Jul';
    08: MonthStr := 'Aug';
    09: MonthStr := 'Sep';
    10: MonthStr := 'Oct';
    11: MonthStr := 'Nov';
    12: MonthStr := 'Dec';
    Else
      MonthStr := '???';
    End;
  End;

Procedure TFidoMsgBase.SetLocal(Value:Boolean);
Begin
   If Value then MKMsgFlagHigh:=MKMsgFlagHigh or 1
   Else MKMsgFlagHigh:=MKMsgFlagHigh and (Not 1);
End;

Procedure TFidoMsgBase.SetRcvd(Value:Boolean);
Begin
   If Value Then MKMsgFlagLow:=MKMsgFlagLow or 4
   Else MKMsgFlagLow:=MKMsgFlagLow and (Not 4);
End;

Procedure TFidoMsgBase.SetPriv(Value:Boolean);
Begin
   If Value Then MKMsgFlagLow:=MKMsgFlagLow or 1
   Else MKMsgFlagLow:=MKMsgFlagLow and (Not 1);
End;

Procedure TFidoMsgBase.SetCrash(Value:Boolean);
Begin
   If Value Then MKMsgFlagLow:=MKMsgFlagLow or 2
   Else MKMsgFlagLow:=MKMsgFlagLow and (Not 2);
End;

Procedure TFidoMsgBase.SetKillSent(Value:Boolean);
Begin
   If Value Then MKMsgFlagLow:=MKMsgFlagLow or 128
   Else MKMsgFlagLow:=MKMsgFlagLow and (Not 128);
End;

Procedure TFidoMsgBase.SetSent(Value:Boolean);
Begin
   If Value then MKMsgFlagLow:=MKMsgFlagLow or 8
   Else  MKMsgFlagLow:=MKMsgFlagLow and (Not 8);
End;

Procedure TFidoMsgBase.SetFAttach(Value:Boolean);
Begin
   If Value Then MKMsgFlagLow:=MKMsgFlagLow or 16
   Else  MKMsgFlagLow:=MKMsgFlagLow and (Not 16);
End;

Procedure TFidoMsgBase.SetReqRct(Value:Boolean);
Begin
   If Value Then MKMsgFlagHigh:=MKMsgFlagHigh or 16
   Else MKMsgFlagHigh:=MKMsgFlagHigh and (Not 16);
End;

Procedure TFidoMsgBase.SetReqAud(Value:Boolean);
Begin
   If Value Then MKMsgFlagHigh:=MKMsgFlagHigh or 64
   Else MKMsgFlagHigh:=MKMsgFlagHigh and (Not 64);
End;

Procedure TFidoMsgBase.SetRetRct(Value:Boolean);
Begin
   If Value Then MKMsgFlagHigh:=MKMsgFlagHigh or 32
   Else MKMsgFlagHigh:=MKMsgFlagHigh and (Not 32);
End;

Procedure TFidoMsgBase.SetFileReq(Value:Boolean);
Begin
   If Value Then MKMsgFlagHigh:=MKMsgFlagHigh or 8
   Else MKMsgFlagHigh:=MKMsgFlagHigh and (Not 8);
End;

Procedure TFidoMsgBase.DoString(Str:String);
Begin
   TmpName:=TmpName+Str;
   If TextCtr<>Length(TmpName) then TextCtr:=Length(TmpName);
End;

Procedure TFidoMsgBase.DoChar(Ch:Char);
Begin
   TmpName:=TmpName+Ch;
   If TextCtr<>Length(TmpName) then TextCtr:=Length(TmpName);
End;

Procedure TFidoMsgBase.DoStringLn(Str:String);
Begin
   DoString(Str);
   DoChar(#13);
End;

Function  TFidoMsgBase.WriteMsg:Word;
Var
   NetNum:Word;

Begin
   DoChar(#0);
   NetNum:=GetHighMsgNum+1;
   While FileExist(MsgPath+Long2Str(NetNum)+'.Msg') do Begin {loop jic!}
      LastPath:='';
      Rescan(MsgPath);
      NetNum:=GetHighMsgNum+1;
   End;
   MsgPresent[NetNum shr 3]:=MsgPresent[NetNum shr 3] or PosArray[NetNum and 7];
   If ((Dest.Point<>0) and (MailType=mtNetmail)) Then
      TmpName:=#1+'TOPT '+Long2Str(Dest.Point)+#13+TmpName;
   If ((Orig.Zone<>0) and (MailType=mtNetMail)) Then
      TmpName:=#1+'INTL '+PointlessAddrStr(Dest)+' '+PointlessAddrStr(Orig)+
         #13+TmpName;
   If ((Orig.Point<>0) and (MailType=mtNetmail)) Then
      TmpName:=#1+'FMPT '+Long2Str(Dest.Point)+#13+TmpName;
   If ((Dest.Zone<>0) and (MailType=mtNetmail)) Then
      TmpName:=#1+'INTL '+PointlessAddrStr(Dest)+' '+
         PointlessAddrStr(Orig)+#13+TmpName;
   AssignFile(MsgFile,MsgPath+Long2Str(NetNum)+'.Msg');
   {$I-} Rewrite(MsgFile,1);
   MsgOpen:=True;
   RewriteHdr;
   Seek(MsgFile,190);
   BlockWrite(MsgFile,TmpName[1],Length(TmpName));
   CloseFile(MsgFile);
   {$I+}
   MsgOpen:=False;
   Error:=IOResult;
   TmpName:='';
   TmpOpen:=False;
   WriteMsg:=Error;
   CurrMsg:=NetNum;
End;

Function TFidoMsgBase.GetChar:Char;
Var
   Ch:Char;

Begin
   If TextCtr<1 then TextCtr:=1;
   If (TextCtr>Length(TmpName)) then Ch:=#0
   Else Begin
      Ch:=TmpName[TextCtr];
      Inc(TextCtr);
   End;
   MsgDone:=Ch=#0;
   GetChar:=Ch;
End;

Function MonthNum(St: String):Word;
  Begin
  ST := Upper(St);
  MonthNum := 0;
  If St = 'JAN' Then MonthNum := 01;
  If St = 'FEB' Then MonthNum := 02;
  If St = 'MAR' Then MonthNum := 03;
  If St = 'APR' Then MonthNum := 04;
  If St = 'MAY' Then MonthNum := 05;
  If St = 'JUN' Then MonthNum := 06;
  If St = 'JUL' Then MonthNum := 07;
  If St = 'AUG' Then MonthNum := 08;
  If St = 'SEP' Then MonthNum := 09;
  If St = 'OCT' Then MonthNum := 10;
  If St = 'NOV' Then MonthNum := 11;
  If St = 'DEC' Then MonthNum := 12;
  End;

{
Function TFidoMsgBase.BufferWord(i: Word):Word;
  Begin
  BufferWord := BufferByte(i) + (BufferByte(i + 1) shl 8);
  End;


Function TFidoMsgBase.BufferByte(i: Word):Byte;
  Begin
  BufferByte := GetByte(i);
  End;


Function TFidoMsgBase.BufferNullString(i: Word; Max: Word): String;
Var
   Ctr: Word;
   CurrPos: Word;

Begin
   BufferNullString := '';
   Ctr := i;
   CurrPos := 0;
   While ((CurrPos<Max) and (GetByte(Ctr)<>0)) Do Begin
    Inc(CurrPos);
    BufferNullString[CurrPos] := Chr(GetByte(Ctr));
    Inc(Ctr);
    End;
   BufferNullString[0] := Chr(CurrPos);
End;
}

Procedure TFidoMsgBase.CheckLine(TStr:String);
Var
   TmpStr:String;
Begin
   If TStr[1]=#10 Then Delete(TStr,1,1);
   If TStr[1]=#01 Then Delete(TStr,1,1);
   If (Upper(Copy(TStr,1,4))='INTL') Then Begin
      TmpStr:=StripBoth(ExtractWord(TStr,2),' ');
      Dest.Zone:=Str2Long(Copy(TmpStr,1,Pos(':',TmpStr)-1));
      TmpStr:=StripBoth(ExtractWord(TStr,3),' ');
      Orig.Zone:=Str2Long(Copy(TmpStr,1,Pos(':',TmpStr)-1));
   End;
   If (Upper(Copy(TStr,1,4))='TOPT') Then
      Dest.Point:=Str2Long(StripBoth(ExtractWord(TStr,2),' '));
   If (Upper(Copy(TStr,1,4))='FMPT') Then
      Orig.Point:=Str2Long(StripBoth(ExtractWord(TStr,2),' '));
End;

Procedure TFidoMsgBase.MsgStartUp;
Var
   TStr:String;
   NumRead:Integer;
   NetRec:NetMsg;

Function Az2Str(Str: String; MaxLen: Byte): String; {Convert asciiz to string}
Var
   i: Word;
   TmpStr: String;

Begin
   SetLength(TmpStr,MaxLen);
   Move(Str[1], TmpStr[1], MaxLen);
   i := Pos(#0, TmpStr);
   If i > 0 Then TmpStr:=Copy(TmpStr,1,i-1);
   Az2Str := TmpStr;
End;


Function CvtDate:Boolean;
Var
   TmpStr:String;
   i:Word;

Begin
   MKMsgtime:='';
   If MKMsgDate[3]=' ' Then Begin {Fido or Opus}
      If MKMsgDate[11]=' ' Then Begin {Fido DD MON YY  HH:MM:SSZ}
         MKMsgTime:=Copy(MKMsgDate,12,5);
         TmpStr:=Long2Str(MonthNum(Copy(MKMsgDate,4,3)));
      End
      Else Begin {Opus DD MON YY HH:MM:SS}
         MKMsgTime:=Copy(MKMsgDaTe,11,5);
         TmpStr:=Long2Str(MonthNum(Copy(MKMsgDate,4,3)));
      End;
      If Length(TmpStr)=1 Then TmpStr:='0'+TmpStr;
     MKMsgDate:=TmpStr+'-'+Copy(MKMsgDaTe,1,2)+'-'+Copy(MKMsgDate,8,2);
   End
   Else Begin
      If MKMsgDaTe[4]=' ' Then Begin {SeaDog format DOW DD MON YY HH:MM}
         MKMsgTime:=Copy(MKMsgDaTe,15,5);
         TmpStr:=Long2Str(MonthNum(Copy(MKMsgDaTe,8,3)));
         If Length(TmpStr)=1 Then TmpStr:='0'+TmpStr;
         MKMsgDate:=TmpStr+'-'+Copy(MKMsgDaTe,5,2)+'-'+Copy(MKMsgDate,12,2);
      End
      Else Begin
         If MKMsgDaTe[3]='-' Then Begin {Wierd format DD-MM-YYYY HH:MM:SS}
            MKMsgTime:=Copy(MKMsgDate,12,5);
            MKMsgDate:=Copy(MKMsgDate,4,3)+Copy(MKMsgDate,1,3)+Copy(MKMsgDate,9,2);
         End;
      End;
   End;
   CvtDate:=MKMsgTime<>'';
   If MKMsgTime<>'' then Begin
      For i:=1 to 5 Do
         If MKMsgTime[i]=' ' Then MKMsgTime[i]:='0';
      For i:=1 to 8 Do
         If MKMsgDate[i]=' ' Then MKMsgDate[i]:='0';
      If Length(MKMsgDate)<>8 Then CvtDate:=False;
      If Length(MKMsgTime)<>5 Then CvtDate:=False;
   End;
End;

Begin
   MsgDone:=True;
   If TmpOpen Then TmpName:='';
   LastSoft:=False;
   MsgEnd:=0;
   TextCtr:=1;
   If FileExist(MsgPath+Long2Str(CurrMsg)+'.MSG') Then Begin
      AssignFile(MsgFile,MsgPath+Long2Str(CurrMsg)+'.MSG');
      {$I-} Reset(MsgFile,1); {$I+}
      Error:=IOResult;
      FillChar(NetRec,Sizeof(NetRec),#0);
      If Error=0 then Begin
         MsgDone:=False;
         {$I-} BlockRead(MsgFile,NetRec,Sizeof(NetRec),NumRead); {$I+}
         Error:=IOResult;
         TextCtr:=0;
         SetLength(TStr,35);
         Move(NetRec.FromUser,TStr[1],35);
         MKMsgFrom:=Az2Str(TStr,35);
         Move(NetRec.ToUser,TStr[1],35);
         MKMsgTo:=Az2Str(TStr,35);
         SetLength(TStr,72);
         Move(NetRec.Subj,TStr[1],71);
         MKMsgSubj:=Az2Str(TStr,72);
         SetLength(TStr,20);
         Move(NetRec.DateTime,TStr[1],20);
         MKMsgDate:=PadRight(Az2Str(TStr,20),' ',20);
         {timesRead : Word; (unused!)}
         Dest.Node:=NetRec.destNode;
         Orig.Node:=NetRec.origNode;
         MKMsgcost:=NetRec.Cost;
         Orig.Net:=NetRec.origNet;
         Dest.Net:=NetRec.destNet;
         Dest.Zone:=NetRec.destZone;
         Orig.Zone:=NetRec.origZone;
         Dest.Point:=NetRec.destPoint;
         Orig.Point:=NetRec.origPoint;
         MkMsgReplyTo:=NetRec.replyTo;
         MkMsgFlagLow:=NetRec.flag1;
         MKMsgFlagHigh:=NetRec.flag2;
         MKMsgNextReply:=NetRec.nextReply;
         If Error=0 then Begin
            If Not CvtDate then Begin
               MKMsgDate:='05-29-97';
               MKMsgTime:='19:21'
            End;
            While Not Eof(MsgFile) do Begin
               SetLength(TmpName,FileSize(MsgFile)-190);
               {$I-} BlockRead(MsgFile,TmpName[1],Length(TmpName),NumRead); {$I+}
               Error:=IOResult;
            End;
            TextCtr:=1;
            While not MsgDone do CheckLine(GetString(128));
         End;
         MsgEnd:=Length(TmpName);
         CloseFile(MsgFile);
         MsgTxtStartUp;
      End;
   End
   Else Error:=200;
   If Error<>0 then CurrMsg:=0;
End;

Procedure TFidoMsgBase.MsgTxtStartUp;
Begin
   MsgStart:=1;
   TextCtr:=MsgStart;
   MsgDone:=False;
   LastSoft:=False;
End;

Function TFidoMsgBase.GetString(MaxLen:Word):String;
Var
   StrCtr:Integer;
   TmpStr:String;
   Junk:String;

Begin
   If TextCtr<1 then TextCtr:=1;
   If (TextCtr>MsgEnd) Then Begin
      TmpStr:=#0;
      MsgDone:=True;
   End
   Else Begin
      SetLength(TmpStr,Min(MaxLen,(Length(TmpName)-TextCtr)+1));
      Move(TmpName[TextCtr],TmpStr[1],Length(TmpStr));
      StrCtr:=Pos(#13,TmpStr);
      If (StrCtr=0) then TmpStr:=WWrap(TmpStr,MaxLen,Junk)
      Else TmpStr:=Copy(TmpStr,1,StrCtr-1);
      LastSoft:=StrCtr=0;
      If Pos(#$8D,TmpStr)>0 then Begin {soft return detected!}
         StrCtr:=Pos(#$8D,TmpStr);
         TmpStr:=Copy(TmpStr,1,StrCtr-1);
         LastSoft:=True;
      End;
      TextCtr:=TextCtr+Length(TmpStr)+1;
      StrCtr:=0;
      While StrCtr<Length(TmpStr) do Begin
         Inc(StrCtr);
         If TmpStr[StrCtr]=#10 then Delete(TmpStr,StrCtr,1);
      End;
   End;
   GetString:=TmpStr;
End;

Function TFidoMsgBase.IsLocal:Boolean; {Is current msg local}
Begin
   IsLocal:=((MKMsgFlagHigh and 001)<>0);
End;

Function TFidoMsgBase.IsCrash:Boolean; {Is current msg crash}
Begin
   IsCrash:=((MKMsgFlagLow and 002)<>0);
End;

Function TFidoMsgBase.IsKillSent:Boolean; {Is current msg kill sent}
Begin
   IsKillSent:=((MKMsgFlagLow and 128)<>0);
End;

Function TFidoMsgBase.IsSent:Boolean; {Is current msg sent}
Begin
   IsSent:=((MKMsgFlagLow and 008)<>0);
End;

Function TFidoMsgBase.IsFAttach:Boolean; {Is current msg file attach}
Begin
   IsFAttach:=((MKMsgFlagLow and 016)<>0);
End;

Function TFidoMsgBase.IsReqRct:Boolean; {Is current msg request receipt}
Begin
   IsReqRct:=((MKMsgFlagHigh and 016)<>0);
End;

Function TFidoMsgBase.IsReqAud:Boolean; {Is current msg request audit}
Begin
   IsReqAud:=((MKMsgFlagHigh and 064)<>0);
End;

Function TFidoMsgBase.IsRetRct:Boolean; {Is current msg a return receipt}
Begin
   IsRetRct:=((MKMsgFlagHigh and 032)<>0);
End;

Function TFidoMsgBase.IsFileReq:Boolean; {Is current msg a file request}
Begin
   IsFileReq:=((MKMsgFlagHigh and 008)<>0);
End;

Function TFidoMsgBase.IsRcvd:Boolean; {Is current msg received}
Begin
   IsRcvd:=((MKMsgFlagLow and 004)<>0);
End;

Function TFidoMsgBase.IsPriv:Boolean; {Is current msg priviledged/private}
Begin
   IsPriv:=((MKMsgFlagLow and 001)<>0);
End;

Function TFidoMsgBase.IsDeleted:Boolean; {Is current msg deleted}
Begin
   IsDeleted:=Not FileExist(MsgPath+Long2Str(CurrMsg)+'.MSG');
End;

Function TFidoMsgBase.IsEchoed:Boolean; {Is current msg echoed}
Begin
   IsEchoed:=True;
End;

Procedure TFidoMsgBase.SeekFirst(MsgNum:LongInt); {Start msg seek}
Begin
   CurrMsg:=MsgNum-1;
   If CurrMsg<0 then CurrMsg:=0;
   SeekNext;
End;

Procedure TFidoMsgBase.SeekNext; {Find next matching msg}
Begin
   Inc(CurrMsg);
   While ((Not MsgExists(CurrMsg)) and (CurrMsg<=MaxFidMsgNum)) Do Inc(CurrMsg);
   If Not MsgExists(CurrMsg) Then CurrMsg:=0;
End;

Procedure TFidoMsgBase.SeekPrior;
Begin
   Dec(CurrMsg);
   While ((Not MsgExists(CurrMsg)) and (CurrMsg > 0)) Do Dec(CurrMsg);
End;

Function TFidoMsgBase.GetMsgLoc: LongInt; {Msg location}
Begin
   GetMsgLoc:=CurrMsg;
End;

Procedure TFidoMsgBase.SetMsgLoc(ML: LongInt); {Msg location}
Begin
   CurrMsg:=ML;
End;

Function TFidoMsgBase.MKSeekFound:Boolean;
Begin
   MKSeekFound:=CurrMsg<>0;
End;

Procedure TFidoMsgBase.YoursFirst(Name: String; Handle: String);
Begin
   YoursName:=Upper(Name);
   YoursHandle:=Upper(Handle);
   CurrMsg:=0;
   YoursNext;
End;

Procedure TFidoMsgBase.YoursNext;
Var
   FoundDone:Boolean;

Begin
   FoundDone := False;
   SeekFirst(CurrMsg+1);
   While ((CurrMsg<>0) And (Not FoundDone)) Do Begin
      MsgStartUp;
      FoundDone:=((Upper(HdrTo)=YoursName) Or (Upper(HdrTo)=YoursHandle));
      If IsRcvd Then FoundDone:=False;
      If Not FoundDone Then SeekNext;
      If Not SeekFound Then FoundDone:=True;
   End;
End;

Function TFidoMsgBase.MKYoursFound:Boolean;
Begin
   MKYoursFound:=SeekFound;
End;

Procedure TFidoMsgBase.StartNewMsg;
Begin
   Error:=0;
   TextCtr:=0;
   FillChar(Dest,Sizeof(Dest),#0);
   FillChar(Dest,Sizeof(Orig),#0);
   TmpOpen:=True;
   TmpName:='';
   MKMsgDate := DateStr(GetDosDate);
   MKMsgTime := TimeStr(GetDosDate);
End;

Function TFidoMsgBase.OpenMsgBase:Word;
Begin
   Rescan(MsgPath);
   FActive:=MsgBaseExists;
   If FActive then OpenMsgBase:=0
   Else OpenMsgBase:=500;
End;

Procedure TFidoMsgBase.SetActive(Value:Boolean);
Begin
   If Factive=Value then Exit
   Else If Value then OpenMsgBase
   Else CloseMsgBase;
End;

Function TFidoMsgBase.CloseMsgBase: Word;
Begin
   CloseMsgBase:=0;
   FActive:=False;
End;

Function TFidoMsgBase.CreateMsgBase(MaxMsg: Word; MaxDays: Word): Word;
Begin
   If MakePath(MsgPathFileName) Then CreateMsgBase:=0
   Else CreateMsgBase:=1;
End;

Procedure TFidoMsgBase.SetMailType(Value:MsgMailType);
Begin
   MailType:=Value;
End;

Function TFidoMsgBase.GetSubArea:Word;
Begin
   GetSubArea:=0;
End;

Procedure TFidoMsgBase.ReWriteHdr;
Var
   NetRec:NetMsg;
   TmpNum:Byte;
   TmpStr:String;
{   OldSeek:Longint;}

Begin
   FillChar(NetRec,Sizeof(NetRec),#0);
   TmpNum:=Str2Long(Copy(MKMsgDate,1,2));
   TmpStr:=Copy(MKMsgDate,4,2)+' '+MonthStr(TmpNum)+' '+Copy(MKMsgDate,7,2)+'  ';
   With NetRec do Begin
      Move(MKMsgFrom[1],FromUser,Length(MKMsgFrom));
      Move(MKMsgTo[1],toUser,Length(MKMsgTo));
      Move(MKMsgSubj[1],subj,Length(MKMsgSubj));
      Move(TmpStr[1],DateTime,Length(TmpStr));
      TimesRead:=0;
      DestNode:=Dest.Node;
      OrigNode:=Orig.Node;
      Cost:=MKMsgCost;
      origNet:=Orig.Net;
      destNet:=Dest.Net;
      destZone:=Dest.Zone;
      origZone:=Orig.Zone;
      destPoint:=Dest.Point;
      origPoint:=Orig.Point;
      replyTo:=MKMsgReplyTo;
      flag1:=MkMsgFlagLow;
      flag2:=MkMsgFlagHigh;
      nextReply:=MkMsgNextReply;
   End;
{   OldSeek:=FilePos(MsgFile);}
   If Not MsgOpen then Begin
      AssignFile(MsgFile,MsgPath+Long2Str(CurrMsg)+'.Msg');
      {$I-} Reset(MsgFile,1); {$I-}
   End;
   {$I-} Seek(MsgFile,0);
   BlockWrite(MsgFile,NetRec,Sizeof(NetRec));
   Seek(MsgFile,0); {$I+}
   If Not MsgOpen then CloseFile(MsgFile);
   If IOResult<>0 then {absorb};
End;

Procedure TFidoMsgBase.DeleteMsg;
Begin
   DeleteFile(PChar(MsgPath+Long2Str(CurrMsg)+'.MSG'));
   MsgPresent[CurrMsg shr 3]:=MsgPresent[CurrMsg shr 3] and Not (PosArray[CurrMsg and 7]);
End;

Function TFidoMsgBase.MKNumberOfMsgs:LongInt;
Var
   Cnt:Word;
   Active:LongInt;

Begin
   Active:=0;
   For Cnt:=0 To MaxFidMsgArray Do Begin
      If MsgPresent[Cnt]<>0 Then Begin
         If (MsgPresent[Cnt] and $80)<>0 Then Inc(Active);
         If (MsgPresent[Cnt] and $40)<>0 Then Inc(Active);
         If (MsgPresent[Cnt] and $20)<>0 Then Inc(Active);
         If (MsgPresent[Cnt] and $10)<>0 Then Inc(Active);
         If (MsgPresent[Cnt] and $08)<>0 Then Inc(Active);
         If (MsgPresent[Cnt] and $04)<>0 Then Inc(Active);
         If (MsgPresent[Cnt] and $02)<>0 Then Inc(Active);
         If (MsgPresent[Cnt] and $01)<>0 Then Inc(Active);
      End;
    End;
    MKNumberOfMsgs:=Active;
End;

Function TFidoMsgBase.GetLastRead(UNum:LongInt):LongInt;
Var
   LRec:Word;

Begin
   If ((UNum+1)*SizeOf(LRec))>SizeFile(MsgPath+'LastRead') Then GetLastRead:=0
   Else Begin
      If LoadFilePos(MsgPath+'LastRead',LRec,SizeOf(LRec),UNum*SizeOf(LRec))=0 Then
         GetLastRead:=LRec
      Else GetLastRead:=0;
   End;
End;

Procedure TFidoMsgBase.SetLastRead(UNum:LongInt;LR:LongInt);
Var
   LRec: Word;

Begin
   If ((UNum+1)*SizeOf(LRec))>SizeFile(MsgPath+'LastRead') Then
      ExtendFile(MsgPath+'LastRead',(UNum+1)*SizeOf(LRec));
   If LoadFilePos(MsgPath+'LastRead',LRec,SizeOf(LRec),UNum*SizeOf(LRec))=0 Then Begin
      LRec:=LR;
      SaveFilePos(MsgPath+'LastRead',LRec,SizeOf(LRec),UNum*SizeOf(LRec));
   End;
End;

Function TFidoMsgBase.GetTxtPos: LongInt;
Begin
   GetTxtPos:=TextCtr;
End;

Procedure TFidoMsgBase.SetTxtPos(TP:LongInt);
Begin
   TextCtr:=TP;
End;

Function TFidoMsgBase.MKMsgBaseExists:Boolean;
Begin
   Rescan(MsgPath); {jic}
   MKMsgBaseExists:=MsgPathExists;
End;


Procedure TFidoMsgBase.Rescan(S:String);
Var
   SR: TSearchRec;
   TmpNum:Word;
   Code:Word;
   DosError:Integer;

Begin
   MsgPath:=WithBackSlash(S);
   If MsgPath=LastPath then Exit;
   LastPath:=MsgPath;
   FillChar(MsgPresent,SizeOf(MsgPresent),0);
   DosError:=FindFirst(MsgPath+'*.MSG',faReadOnly+faArchive,SR);
   MsgPathExists:=False;
   While DosError=0 Do Begin
      TmpNum:=Str2Long(Copy(SR.Name,1,Pos('.',SR.Name)-1));
      If TmpNum>0 Then Begin
         MsgPathExists:=True;
         If TmpNum<=MaxFidMsgNum Then Begin
            Code:=TmpNum shr 3; {div by 8 to get byte position}
            MsgPresent[Code]:=MsgPresent[Code] or PosArray[TmpNum and 7];
         End;
      End;
      DosError:=FindNext(SR);
   End;
   FindClose(SR);
End;

Function TFidoMsgBase.MsgExists(MsgNum:LongInt):Boolean;
Begin
   If ((MsgNum > 0) and (MsgNum <= MaxFidMsgNum)) Then
      MsgExists:=(MsgPresent[MsgNum shr 3] and PosArray[MsgNum and 7])<>0
   Else MsgExists:=False;
End;

Function  TFidoMsgBase.GetNextSeeAlso:LongInt;
Begin
   GetNextSeeAlso:=MKMsgNextReply;
End;

Procedure TFidoMsgBase.SetNextSeeAlso(Value:LongInt);
Begin
   MKMsgNextReply:=Value;
End;

Procedure TFidoMsgBase.SetCost(Value:Word);
Begin
   MKMsgCost:=Value;
End;

Function  TFidoMsgBase.GetCost:Word;
Begin
   GetCost:=MKMsgCost;
End;

Function  TFidoMsgBase.LockMsgBase:Boolean;
Begin
   LockMsgbase:=True;
End;

Function  TFidoMsgBase.UnLockMsgBase:Boolean;
Begin
   UnLockMsgbase:=True;
End;

Procedure TFidoMsgBase.SetEcho(Value:Boolean);
Begin
   {Not Needed!}
End;

Procedure TFidoMsgBase.DoKludgeLn(Str:String);
Begin
   DoString(#1+Str);
End;

Procedure Register;
Begin
   RegisterComponents('Warpgroup',[TFidoMsgBase]);
End;

End.

