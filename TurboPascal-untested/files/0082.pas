Unit WGTFile; {TextFile Reader for CRLF or LF TEXT FILES!}
              {eventually this unit will be a decendant of WGBFILE!}

{$I WGDEFINE.INC}  { SEE WGFFIND.PAS for this include }

Interface

Uses
   WGBFile,
{$IFDEF WINDOWS}
   WinDos;
{$ELSE}
   Dos;
{$ENDIF}

Type
   TFile = Object
      Decendant:FFileObj; {short cut for now!}
      StringFound:Boolean;
      MyIOResult:Word;
      Constructor Init(BSize:Word);
      Destructor Done;
      Procedure Open(FilePath:String); Virtual;
      Procedure CloseFile; Virtual;
{      Function  EraseFile; Virtual;}
      Function  GetString:String;             {Get CRLF string from file}
      Function  GetUString:String;            {Get LF delimited string}
      Function  Found:Boolean;                {Was a string found}
      Function  SeekFile(SeekPos:LongInt):Boolean; {Seek to position}
      Function  FilePos:LongInt;              {Get text file position}
      Function  RawSize:LongInt;              {Get text file position}
   End;

Implementation

Constructor TFile.Init(BSize:Word);
Begin
   Decendant.Init(BSize);
   If Decendant.MyIOResult<>0 then Fail;
   MyIOResult:=0;
   StringFound:=False;
End;

Destructor TFile.Done;
Begin
   If Decendant.IsOpen then Decendant.CloseFile;
   Decendant.Done;
   StringFound:=False;
End;

Procedure TFile.Open(FilePath:String);
Begin
   Decendant.Open(FilePath,fmReadOnly+fmDenyNone);
   MyIOResult:=Decendant.MyIOResult;
End;

Procedure TFile.CloseFile;
Begin
   Decendant.Closefile;
   MyIOResult:=Decendant.MyIOResult;
End;

Function  TFile.GetString:String;
Var
   TempStr:String;
   GDone:Boolean;
   Ch:Char;
   NRead:Word;

Begin
   TempStr:='';
   StringFound:=False;
   If Decendant.FilePos>=Decendant.RawSize then GDone:=True
   Else GDone:=False;
   While Not GDone Do Begin
      Decendant.BlkRead(Ch,1,NRead);
      MyIOResult:=Decendant.MYIOResult;
      If (MYIOResult<>0) or (NRead<>1) then Ch:=#0;
      Case Ch Of
 #0:If Decendant.FilePos>=Decendant.RawSize Then GDone:=True
       Else Begin
       Inc(TempStr[0]);
       TempStr[Ord(TempStr[0])]:=Ch;
       StringFound:=True;
       If Length(TempStr)=255 Then GDone:=True;
    End;
 #10:;
 #26:;
 #13: Begin
      GDone:=True;
      StringFound:=True;
      End;
      Else Begin
    Inc(TempStr[0]);
    TempStr[Ord(TempStr[0])]:=Ch;
    StringFound:=True;
    If Length(TempStr)=255 Then GDone:=True;
      End;
      End; {case}
   End;
   GetString:=TempStr;
End;

Function  TFile.GetUString:String;
Var
   TempStr:String;
   GDone:Boolean;
   Ch:Char;
   NRead:Word;

Begin
   TempStr:='';
   StringFound:=False;
   If Decendant.FilePos>=Decendant.RawSize then GDone:=True
   Else GDone:=False;
   While Not GDone Do Begin
      Decendant.BlkRead(Ch,1,NRead);
      MyIOResult:=Decendant.MYIOResult;
      If (MYIOResult<>0) or (NRead<>1) then Ch:=#0;
      Case Ch Of
      #0:If Decendant.FilePos>=Decendant.RawSize Then GDone:=True
  Else Begin
     Inc(TempStr[0]);
     TempStr[Ord(TempStr[0])]:=Ch;
     StringFound:=True;
     If Length(TempStr)=255 Then GDone:=True;
  End;
      #13:;
      #26:;
      #10:Begin
        GDone:=True;
        StringFound:=True;
        End;
      Else Begin
    Inc(TempStr[0]);
    TempStr[Ord(TempStr[0])]:=Ch;
    StringFound:=True;
    If Length(TempStr)=255 Then GDone:=True;
      End;
      End; {case}
   End;
   GetUString:=TempStr;
End;

Function  TFile.Found:Boolean;
Begin
   Found:=StringFound;
End;

Function  TFile.SeekFile(SeekPos:LongInt):Boolean; {Seek to position}
Begin
   Decendant.SeekFile(SeekPos);
   MyIOResult:=Decendant.MyIOResult;
End;

Function  TFile.FilePos:LongInt;              {Get text file position}
Begin
   FilePos:=Decendant.FilePos;
End;

Function  TFile.RawSize:LongInt;              {Get text file position}
Begin
   RawSize:=Decendant.RawSize;
End;

End.
