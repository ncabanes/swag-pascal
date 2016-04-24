(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0092.PAS
  Description: Multiple File Delete
  Author: SCOTT TUNSTALL
  Date: 05-31-96  09:17
*)

{
DELM - Multiple delete

(C) 1996 Scott Tunstall.

Without entering any crap utils like CO, DR etc you can do this
straight from the command line.. nice 'n' easy !! :)

}


Uses Dos;

Procedure Usage;
Begin
     Writeln;
     Writeln;
     Writeln('DELM - Delete Multiple Files quickly via command line.');
     Writeln('(C) 1996 Scott Tunstall. All rights reserved.');
     Writeln;
     Writeln('Usage :');
     Writeln;
     Writeln('DELM <FileSpec1> [FileSpec2] [FileSpec3..]');
     Writeln;
     Writeln;
End;



Procedure RemoveFiles(FirstParmToUse, EndParm: byte);
Var
    Fails: byte;                { No of missed files }
    Count: byte;
    Rec: SearchRec;
    FileToErase: file;

Begin
     Fails:=0;
     For Count:=FirstParmToUse To EndParm do
         Begin
         FindFirst(ParamStr(Count), $2F, Rec);
         If DosError <>0 Then
            Begin
            Writeln('No file matches the pattern ', ParamStr(Count), '!');
            Inc(Fails);
            End
         Else
             while DosError = 0 do
             Begin
                  Writeln('Deleting ', Rec.Name, '.');
                  Assign(FileToErase, Rec.Name);
                  {$i-}
                  Erase(FileToErase);
                  {$i+}
                  FindNext(Rec);
             End;
     End;
     Halt(Fails);
End;




Begin
     If ParamCount = 0 Then
        Usage
     Else
         RemoveFiles(1, ParamCount);
End.
