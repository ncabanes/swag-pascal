(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0017.PAS
  Description: Setting a files path
  Author: JON KENT
  Date: 08-27-93  21:21
*)

{
JON KENT

Here's one way to set a File's path "on the fly" using Typed Constants.
}

Uses
  Dos;

Const
  TestFile1 : String = 'TEST1.DAT';
  TestFile2 : String = 'DATA\TEST2.DAT';
Var
  CurrentPath : String;

Function FileStretch(SType : Byte; FileFullName : String) : String;
Var
  P : PathStr;
  D : DirStr;
  N : NameStr;
  E : ExtStr;
begin
  P := FExpand(FileFullName);
  FSplit(P, D, N, E);
  if D[LENGTH(D)] = '\' then
    D[0] := CHR(PRED(LENGTH(D)));
  Case SType OF
    1 :  FileStretch := D;
    2 :  FileStretch := N + E;
    3 :  FileStretch := D + '\' + N;
    4 :  FileStretch := N;
    else FileStretch := '';
  end;
end;

begin
  CurrentPath := FileStretch(1,ParamStr(0));    { Get EXE's Path  }
  TestFile1   := CurrentPath + '\' + TestFile1; { Set DAT Paths   }
  TestFile2   := CurrentPath + '\' + TestFile2;

  {...}

end.
{-----------------------------}

{  if CurrentPath = C:\WORK then

       TestFile1 = C:\WORK\TEST1.DAT
       TestFile2 = C:\WORK\DATA\TEST2.DAT

  This works Really well when you want to store a Program's configuration
  File or data Files in the same directory as the Program regardless its
  location.
}
