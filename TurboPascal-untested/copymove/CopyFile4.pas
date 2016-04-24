(*
  Category: SWAG Title: FILE COPY/MOVE ROUTINES
  Original name: 0004.PAS
  Description: Copy File #4
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:35
*)

{I am having a bit of a problem in Pascal.  I am writing a routine to
copy Files.  The Program is to be used in an area where anything at
all can happen, so it has to be totally bullet-proof.  All is well,
except one little thing.  Should the Program encounter a major disk
error (for example, the user removes the disk While the copy is taking
place), the Program breaks into Dos after an 'Abort, Retry, Fail'
prompt.  Now comes the weird part.  This crash to Dos only occurs only
once the Program terminates.  It processes the error perfectly, and only
gives the error once my entire Program is at an end!  Following is the
source code in question:
}
Program FileTest;

Uses
  Dos;

Procedure FileCopy(SrcPath, DstPath, FSpec : String; Var ExStat : Integer);
Var
  DirInfo : SearchRec;
  Done    : Boolean;

Procedure Process(X : String);
Var
  Source,
  Dest     : File;
  Buffer   : Array[1..4096] of Byte;
  ReadCnt,
  WriteCnt : Word;

begin
  {$I-}
  ExStat:=0;
  Assign(Source,SrcPath+X);
  Reset(Source,1);
  If IOResult <> 0 then
    ExStat := 1;
  If ExStat = 0 then
  begin
    Assign(Dest,DstPath+X);
    ReWrite(Dest,1);
    If IOResult <> 0 then
      ExStat := 2;
    If ExStat = 0 then
    begin
      Repeat
        BlockRead(Source,Buffer,Sizeof(Buffer),ReadCnt);
        BlockWrite(Dest,Buffer,ReadCnt,WriteCnt);
        If IOResult <> 0 then
          ExStat := 3;
      Until (ReadCnt = 0) or (WriteCnt <> ReadCnt) or (ExStat <> 0);
      Close(Dest);
    end;
    Close(Source);
  end;
  {$I+}
end;

begin
  {$I-}
    ExStat := 0;
    FindFirst(SrcPath + FSpec, Archive, DirInfo);
    Done := False;
    While Not Done do
    begin
      Write('Copying ',DirInfo.Name,' ');
      Process(DirInfo.Name);
      If (ExStat = 0) then
      begin
        FindNext(DirInfo);
        If (DosError<>0) then
          Done := True;
      end
      else
        Done := True;
    end;
  {$I+}
end;

Procedure Main;
Var
  ExC : Integer;
begin
  FileCopy('C:\Dos\','A:\','*.BAS',ExC);
  Writeln('Exit Code:',ExC);
end;

begin
  Main;
  Writeln('Program is Complete');
end.
{
That's it.  All errors get logged normally, and right after 'Program is
Complete', I get an 'Abort, Retry, Fail'.  It must be a File left open,
and TP tries to close it once the Program terminates, but I can't
imagine which File it might be!
}
