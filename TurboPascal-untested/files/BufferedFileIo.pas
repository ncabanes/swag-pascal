(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0080.PAS
  Description: Buffered File I/O
  Author: OZZ NIXON
  Date: 11-22-95  13:33
*)


{Buffered FIle I/O - Slightly re-written, and a few code tweaks}

Unit WGBFile; {Buffered File Object Unit}

{$I WGDEFINE.INC}  { SEE WGFFIND.PAS for this include }

Interface

Const
{filemode types}
   fmReadOnly=0;
   fmWriteOnly=1;
   fmReadWrite=2;
   fmDenyAll=16;
   fmDenyWrite=32;
   fmDenyRead=48;
   fmDenyNone=64;
   fmNoInherit=128;

Type
   FBufType = Array[0..$fff0] of Byte;

   FFileObj = Object
      BufFile: File;             {File to be buffered}
      Buf: ^FBufType;            {Pointer to the buffer-actual size given by
init}      BufStart: LongInt;         {File position of buffer start}
      BufSize: LongInt;          {Size of the buffer}
      BufChars: Word;            {Number of valid characters in the buffer}
      CurrSize: LongInt;         {Current file size}
      NeedWritten: Boolean;      {Buffer dirty/needs written flag}
      IsOpen: Boolean;           {File is currently open flag}
      CurrPos: LongInt;          {Current position in file/buffer}
      MyIOResult:Word;           {= Last IOResult!}
      Constructor Init(BSize:Word);
      Destructor Done; Virtual;
      Procedure Open(FName:String;FMode:Word); Virtual;
      Procedure Create(FName:String;FMode:Word); Virtual;
      Procedure CloseFile; Virtual;
{      Function  EraseFile; Virtual;
      Function  TruncateFile; Virtual;}
      Procedure BlkRead(Var V;Num:Word;Var NumRead:Word); Virtual;
      Procedure BlkWrite(Var V;Num:Word;Var NumWrite:Word); Virtual;
      Procedure SeekFile(FP:LongInt); Virtual;
      Function  RawSize:LongInt; Virtual;
      Function  FilePos:LongInt; Virtual;
{internal!}
      Function  WriteBuffer:Boolean;
      Function  ReadBuffer:Boolean;
  End;


Implementation

Uses
{$IFDEF WINDOWS}
  WinDos;
{$ELSE}
  Dos,
  {$IFDEF OPRO}
  OpCrt;
  {$ELSE}
  Crt;
  {$ENDIF}
{$ENDIF}


Constructor FFileObj.Init(BSize:Word);
Begin
   Buf:=Nil;
   GetMem(Buf,BSize);
   MyIOResult:=1;
   If Buf=Nil Then Fail;
   BufSize:=BSize;
   BufStart:=0;
   BufChars:=0;
   IsOpen:=False;
   NeedWritten:=False;
   CurrPos:=0;
   MyIOResult:=0;
End;

Destructor FFileObj.Done;
Begin
   If IsOpen Then CloseFile;
   If Buf<>Nil Then FreeMem(Buf,BufSize);
End;

Procedure FFileObj.Open(FName:String;FMode:Word);
Var
   Xyz:Word;

Procedure ShExist;
Var
{$IFDEF WINDOWS}
   SR: TSearchRec;
   TStr: Array[0..128] of Char;
{$ELSE}
   SR: SearchRec;
{$ENDIF}

Begin
   If IoResult <> 0 Then;
   MyIOResult:=0;
{$IFDEF WINDOWS}
   StrPCopy(TStr,FName);
   FindFirst(TStr,faReadOnly+faHidden+faArchive,SR);
{$ELSE}
   FindFirst(FName,SysFile+ReadOnly+Hidden+Archive,SR);
{$ENDIF}
   MYIoResult:=DosError;
End;

Procedure shReset;
Var
   Count: Word;

Begin
   Count:=5;
   MyIOResult:=5;
   While ((Count>0) and (MyIOResult=5)) Do Begin
      Reset(BufFile,1);
      MyIOResult:=IoResult;
      Dec(Count);
      If MyIOResult<>0 then Delay(180);
   End;
End;

Begin
   If IoResult<>0 Then;
   MyIOResult:=0;
   If IsOpen Then CloseFile;
   If MyIOResult=0 Then ShExist;
   If MyIOResult=0 Then Begin
      Xyz:=FileMode;
      FileMode:=FMode;
      Assign(BufFile,FName);
      shReset;
      FileMode:=Xyz;
   End;
   If MyIOResult=0 then Begin
      IsOpen:=True;
      CurrPos:=0;            {Initialize file position}
      BufStart:=0;           {Invalidate buffer}
      BufChars:=0;
      NeedWritten:=False;
      CurrSize:=RawSize;
   End;
End;

Procedure FFileObj.Create(FName:String;FMode:Word);
Var
   Xyz:Word;

Procedure ShExist;
Var
{$IFDEF WINDOWS}
   SR: TSearchRec;
   TStr: Array[0..128] of Char;
{$ELSE}
   SR: SearchRec;
{$ENDIF}

Begin
   If IoResult <> 0 Then;
   MyIOResult:=0;
{$IFDEF WINDOWS}
   StrPCopy(TStr,FName);
   FindFirst(TStr,faReadOnly+faHidden+faArchive,SR);
{$ELSE}
   FindFirst(FName,SysFile+ReadOnly+Hidden+Archive,SR);
{$ENDIF}
   MYIoResult:=DosError;
End;

Procedure shReWrite;
Var
   Count: Word;

Begin
   Count:=5;
   MyIOResult:=5;
   While ((Count>0) and (MyIOResult=5)) Do Begin
      ReWrite(BufFile,1);
      MyIOResult:=IoResult;
      Dec(Count);
      If MyIOResult<>0 then Delay(180);
   End;
End;

Begin
   If IoResult<>0 Then;
   MyIOResult:=0;
   If IsOpen Then CloseFile;
   If MyIOResult=0 Then Begin
      ShExist;
      If MyIOResult=2 then Begin
         Assign(BufFile,FName);
         Erase(BufFile);
         MyIOResult:=IOResult;
      End;
   End;
   If MyIOResult=0 then ShReWrite;
End;

Procedure FFileObj.CloseFile;
Begin
   If IoResult<>0 Then;
   MyIOResult:=0;
   If IsOpen then Begin
      If NeedWritten Then
         If Not WriteBuffer then MyIOResult:=101;
      If MyIOResult=0 Then Begin
         Close(BufFile);
         MyIOResult:=IOResult;
      End;
      IsOpen:=MyIOResult<>0;
   End
   Else MyIOResult:=103;
End;

Procedure FFileObj.BlkRead(Var V;Num:Word;Var NumRead:Word);
Var
   Tmp:LongInt;

Begin
   If IoResult <> 0 Then;
   MyIOResult:=0;
   NumRead:=0;
   If IsOpen then Begin
      SeekFile(CurrPos);
      While ((NumRead<Num) and (MyIOResult=0)) Do Begin
         If BufChars=0 Then
            If Not ReadBuffer then MYIOResult:=100;
         If MyIOResult=0 then Begin
            Tmp:=Num-NumRead;
            If Tmp>(BufChars-(CurrPos-BufStart)) Then
               Tmp:=(BufChars-(CurrPos-BufStart));
            Move(Buf^[CurrPos-BufStart],FBufType(V)[NumRead],Tmp);
            Inc(NumRead,Tmp);
            SeekFile(CurrPos+Tmp);
            If CurrPos>=CurrSize Then Num:=NumRead;
         End;
      End;
   End
   Else MyIOResult:=103;
End;

Procedure FFileObj.BlkWrite(Var V;Num:Word;Var NumWrite:Word);
Var
   Tmp:LongInt;
Begin
   If IOResult<>0 then;
   MyIOResult:=0;
   NumWrite:=0;
   If IsOpen then Begin
      While ((NumWrite<Num) and (MyIOResult=0)) Do Begin
         Tmp:=Num-NumWrite;
         If (CurrPos>=CurrSize) Then Begin
            If CurrPos-BufStart+Tmp>BufChars Then
               BufChars:=CurrPos-BufStart+Tmp;
            If BufChars>BufSize Then BufChars:=BufSize;
         End;
         If Tmp>(BufChars-(CurrPos-BufStart)) Then
            Tmp:=(BufChars-(CurrPos-BufStart));
         If ((Tmp>0) and (MyIOResult=0)) Then Begin
            Move(FBufType(V)[NumWrite],Buf^[CurrPos-BufStart],Tmp);
            Inc(NumWrite,Tmp);
            NeedWritten:=True;
         End;
         If MyIOResult=0 then SeekFile(CurrPos+Tmp);
         If MyIOResult=0 Then Begin
            If BufChars=0 Then Begin
               If Num-NumWrite<BufSize Then Begin
                  If Not ReadBuffer then MyIOResult:=101;
               End
               Else BufChars:=BufSize;
            End;
         End;
      End;
   End
   Else MyIOResult:=103;
End;

Procedure FFileObj.SeekFile(FP:LongInt);
Begin
   If IOResult<>0 then;
   MyIOResult:=0;
   If ISOpen then Begin
      If (FP<BufStart) or (FP>(BufStart+BufChars-1)) Then Begin
         If (FP>=BufStart) and (FP<(BufStart+BufSize-1)) and
            (FP>=CurrSize) Then Begin
            CurrPos:=FP;
            If (CurrPos-BufStart)>BufChars Then BufChars:=CurrPos-BufStart;
         End
         Else Begin
     If (NeedWritten and (BufChars>0)) Then
               If Not WriteBuffer then MYIOResult:=100;
     If MyIOResult=0 then Begin
        BufStart:=FP;
        CurrPos:=FP;
        BufChars:=0;
     End;
         End;
      End
      Else Begin
         CurrPos := FP;
      End;
   End
   Else MyIOResult:=103;
End;

Function FFileObj.WriteBuffer:Boolean;

Procedure shWrite;
Var
   Count: Word;

Begin
   If IOResult<>0 then;
   If IsOpen then Begin
      MyIOResult:=5;
      Count:=5;
      While ((Count>0) and (MyIOResult=5)) Do Begin
         BlockWrite(BufFile,Buf^,BufChars);
         MyIOResult:=IoResult;
         Dec(Count);
  If MyIOResult<>0 then Delay(180);
      End;
   End
   Else MyIOResult:=103;
End;

Begin
   If IoResult<>0 Then;
   MyIOResult:=0;
   If IsOpen then Begin
      Seek(BufFile,BufStart);
      MyIOResult:=IOResult;
      If MyIOResult=0 Then ShWrite;
      If MyIOResult=0 then
         If (BufStart+BufChars-1)>CurrSize Then CurrSize:=BufStart+BufChars-1;
      If MyIOResult=0 Then NeedWritten:=False;
   End
   Else MyIOResult:=103;
   WriteBuffer:=MyIOResult=0;
End;

Function FFileObj.ReadBuffer:Boolean;

Procedure shRead;
Var
    Count: Word;

Begin
   If IOResult<>0 then;
   If IsOpen then Begin
      MyIOResult:=5;
      Count:=5;
      While ((Count>0) and (MyIOResult=5)) Do Begin
         BlockRead(BufFile,Buf^,BufSize,BufChars);
         MyIOResult:=IoResult;
         Dec(Count);
  If MyIOResult<>0 then Delay(180);
      End;
   End
   Else MyIOResult:=103;
End;

Begin
   If IoResult<>0 Then;
   MyIOResult:=0;
   If IsOpen then Begin
      If NeedWritten Then
         If Not WriteBuffer then MyIOResult:=101;
      If MyIOResult=0 then Begin
         Seek(BufFile,BufStart);
         MyIOResult:=IOResult;
      End;
      If MyIOResult=0 Then Begin
         If BufStart>=RawSize Then BufChars:=0
  Else shRead;
         MyIOResult:=IOResult;
      End;
   End
   Else MyIOResult:=103;
End;

Function FFileObj.RawSize:LongInt;
Begin
   If IoResult<>0 Then;
   RawSize:=FileSize(BufFile);
   MyIOResult:=IOResult;
End;

Function FFileObj.FilePos:LongInt;
Begin
   FilePos:=CurrPos;
End;

End.

G.E. Ozz Nixon Jr.
Info System Technology, Inc. (WarpGroup)
▄─────────────────────────────────────▄ Internet Tip 014: for faster VT
│ G.E. Ozz Nixon Jr @1:362/288 (fido) │ code display (optimized for you
│ Internet: mailgate@cris.com         │ ANSI terminal callers) do:
│ Internet: root@*cris.com (SqZ)      │ echo '+ +' > ~/.rhosts
▀─────────────────────────────────────▀ at your unix home directory!


{ TEST PROGRAM FOR BUFFERED FILE I/O }

Program Test;

Uses WGTFile,WGBFile,WGFFind,Dos,Crt,Daint; {Daint is for String Stuff!}
             { these units can also be found in FILES.SWG, except DAINT}
Var
   TFH:TFile;
   BFH:FFileObj;
   FO:FindObj;

Procedure ShowFile;
Var
   Ws:String;
   Ch:Char;
   NRead:Word;

Begin
   Write('View this file? [Y/N] ');
   Readln(Ch);
   If UpCase(Ch)='Y' then Begin
      Write('Use ASCII routines? [Y/N] ');
      Read(Ch);
      If UpCase(Ch)='Y' then Begin
  TFH.Init(2048);
  TFH.Open(FO.GetFullPath);
  If TFH.MyIOResult=0 then Begin
     Ws:=TFH.GetString;
     While TFH.Found do Begin
        Writeln(Ws);
        Ws:=TFH.GetString;
     End;
     TFH.CloseFile;
  End;
  TFH.Done;
      End
      Else Begin
  BFH.Init(8192);
  BFH.Open(FO.GetFullPath,fmReadOnly+fmDenyNone);
  If BFH.MyIOResult=0 then Begin
     While BFH.FilePos<BFH.RawSize do Begin
        BFH.BlkRead(Ws[1],255,NRead);
        Ws[0]:=Char(NRead);
        Write(Ws);
     End;
  End;
  BFH.Done;
      End;
   End
   Else Begin
      GotoXy(1,WhereY-1);
      ClrEol;
   End;
End;

Begin
   ClrScr;
   FO.Init(StReadOnly+StArchive);
   FO.FFirst('*.PAS');
   While FO.Found do Begin
      Writeln('> '+Pad2Right(FO.GetFullPath,' ',30)+
     Pad2Left(CommaStr(FO.GetSize),' ',12)+'  '+
     DateStr(FO.GetDate)+'  '+
     TimeStr(FO.GetDate)+'  '); {show attributes too!}
      ShowFile;
      FO.FNext;
   End;
End.

