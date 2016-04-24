(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0065.PAS
  Description: BP Bug
  Author: ANDRES CVITKOVICH
  Date: 01-27-94  11:56
*)

{
I'm not sure if the following bug in Contains() of STDDLG.PAS has been fixed
in 7.01 (since I still don't have it) so I decided to post it.

STDDLG.PAS, function Contains()
}
{ Contains returns true if S1 contains any characters in S2 }
function Contains(S1, S2 : String): Boolean; near; assembler;
asm
  PUSH    DS
  CLD
  LDS     SI, S1
  LES     DI, S2
  MOV     DX, DI
> INC     DX           { DX still pointed at len byte }
  XOR     AH, AH
  LODSB
  MOV     BX, AX
  OR      BX, BX
  JZ      @@2
  MOV     AL, ES:[DI]
  XCHG    AX, CX
 @@1:
  PUSH    CX
  MOV     DI, DX
  LODSB
  REPNE   SCASB
  POP     CX
  JE      @@3
  DEC     BX
  JNZ     @@1
 @@2:
  XOR     AL, AL
  JMP     @@4
 @@3:
  MOV     AL, 1
 @@4:
  POP     DS
end;

{
BUT: fixing the bug reveals another bug  <g>

The function is used to determine whether a filename or path contains illegal
characters or not. The last character in the constant "IllegalChars" is the
backslash "\" that would have been ignored by the buggy version of Contains().
However, the corrected version returns TRUE for Contains('\MYPATH\',
IllegalChars) (as it's supposed to).  Since a path name created by FSplit
normally contains a "\" the filename is considered as FALSE by ValidFileName.
My solution is to add a second const named IllegalCharsFN for illegal chars in
the filename (but legal chars in path names) currently just containing '\'.
Furthermore, I removed space ' ' from the list of illegal characters (since it
isn't an illegal char!) and added '/' instead. But have a look at my final
correction suggestion:
}

function ValidFileName(var FileName : PathStr) : Boolean;
const
  IllegalCharsFN = '\';
  IllegalChars   = ';,=+<>|"[]/';
var
  Dir  : DirStr;
  Name : NameStr;
  Ext  : ExtStr;

  { Contains returns true if S1 contains any characters in S2 }
  function Contains(S1, S2 : String) : Boolean; near; assembler;
  asm
     {...see above...}
  end;

begin
  ValidFileName := True;
  FSplit(FileName, Dir, Name, Ext);
  if not ((Dir = '') or PathValid(Dir)) or
     Contains(Name, IllegalChars + IllegalCharsFN) or
     Contains(Dir, IllegalChars) then
    ValidFileName := False;
end;

