(*
  Category: SWAG Title: FILE COPY/MOVE ROUTINES
  Original name: 0003.PAS
  Description: Copy File #3
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:35
*)

{
> Or can someone put up some Procedure that will copy Files.
}

{$O+}

Uses
  Dos;

Function CopyFile(SourceFile, TargetFile : String): Byte;
{ Return codes:  0 successful
                 1 source and target the same
                 2 cannot open source
                 3 unable to create target
                 4 error during copy
}
Var
  Source,
  Target  : File;
  BRead,
  BWrite  : Word;
  FileBuf : Array[1..2048] of Char;
begin
  If SourceFile = TargetFile then
  begin
    CopyFile := 1;
    Exit;
  end;
  Assign(Source,SourceFile);
  {$I-}
  Reset(Source,1);
  {$I+}
  If IOResult <> 0 then
  begin
    CopyFile := 2;
    Exit;
  end;
  Assign(Target,TargetFile);
  {$I-}
  ReWrite(Target,1);
  {$I+}
  If IOResult <> 0 then
  begin
    CopyFile := 3;
    Exit;
  end;
  Repeat
    BlockRead(Source,FileBuf,SizeOf(FileBuf),BRead);
    BlockWrite(Target,FileBuf,Bread,BWrite);
  Until (Bread = 0) or (Bread <> BWrite);
  Close(Source);
  Close(Target);
  If Bread <> BWrite then
    CopyFile := 4
  else
    CopyFile := 0;
end; {of func CopyFile}


