(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0093.PAS
  Description: Copy Multiple files to any dir
  Author: SCOTT TUNSTALL
  Date: 05-31-96  09:17
*)

{
MULTI COPY

This program will copy multiple files to a specified area. I
hope that this shit works too.

This program cannot copy files to a single file nor can it be
expected to know the difference between a file and a directory;

Therefore you must append a back-slash if copying
into a directory.

Example: To Copy COMMAND.COM into C:\tp7\code\work

You'd use MCOPY COMMAND.COM C:\tp7\code\work\
}

Program Mcopy;

Uses dos;


{$R+}


Procedure Usage;
Begin
     Writeln;
     Writeln('Multiple File Copier  (C) 1995 Scott Tunstall. ');
     Writeln;
     Writeln('Usage :');
     Writeln;
     Writeln('MCOPY <FileSpec1> [..FileSpec2] [..FileSpec3 etc.]  <DestSpec>');
     Writeln;
     Writeln;
     Writeln('You can copy as many different types of file in one go as can');
     Writeln('fit on one line just as long as you specify a destination, ');
     Writeln('which must ALWAYS be the last parameter.');
     Writeln;
     Writeln('Also, make sure that if you are copying to a directory that a "\"');
     Writeln('is appended to the directory name otherwise the copy will FAIL !.');
     Writeln;
     Writeln('Example: C:\WORK should be C:\WORK\ with this program.');
     Writeln;
End;


Procedure Error;
Begin
     Writeln;
     Writeln('You need to specify at least two parameters, a source and a');
     Writeln('destination! ');
     Writeln;
     Writeln('Type MCOPY ? for help.');
     Writeln;
End;






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




Procedure BeginCopying;
Var DestinationSpec: PathStr;
    SourceCount: byte;
    SourceFileSpec: PathStr;
    SearchRecord: SearchRec;
    Errorcode: byte;

Begin
     DestinationSpec:=ParamStr(ParamCount);

     For SourceCount:=1 to ParamCount-1 do
         Begin
         SourceFileSpec:=ParamStr(SourceCount);
         FindFirst(SourceFileSpec,$27,SearchRecord);

         If DosError <>0 Then
            Begin
            Writeln;
            Writeln('Cannot open source file(s) !');
            Writeln;
            End
         Else
             Begin
             Repeat
                   Write(SearchRecord.Name,'..');
                   ErrorCode:=CopyFile(SearchRecord.Name,DestinationSpec+SearchRecord.Name);

                   If ErrorCode<>0 Then
                      Begin
                      Write('Error (',ErrorCode,') : ');
                      Case ErrorCode Of
                      1: Writeln('Source and destination are the same !');
                      2: Writeln('Cannot open source file(s) !');
                      3: Writeln('Unable to create destination file(s) !');
                      4: Writeln('Copying error. Check disk integrities !');
                      End;
                      End
                   Else
                       Writeln('copied.');


                   FindNext(SearchRecord);

             Until DosError <>0;

             Writeln;
             Writeln('Operation Complete. ');
             Writeln;
             End;
     End;
End;




Begin
     If ParamStr(1)='?' Then
        Usage
     Else
         If ParamCount <2 Then
            Error
         Else
             BeginCopying;
End.


