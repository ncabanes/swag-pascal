(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0009.PAS
  Description: Redirection in DOS
  Author: MARTIN AUSTERMEIER
  Date: 11-02-93  05:32
*)

{
MARTIN AUSTERMEIER

> PKZIP Filename -Z < zipcomment
> Is there any way to do this WithOUT calling COMSPEC For anothershell?

yes, but much more complicated than leaving the job to %comspec..

Before executing PKZIP, you have to

  * open a Text File
  * get its handle (see TextRec); save it in - say - "newStdIn"
  * then perform something like
  if (newSTDIN <> 0) then begin
    saveHandle[STDIN]:=DosExt.DuplicateHandle (STDIN);
    DosExt.ForceDuplicateHandle (newSTDIN, STDIN);
    created[STDIN]:=True;
  end;
  (DosExt.xx Routines and STDIN Const explained below)

  * Exec()
  * Cancel redirections:
}

Procedure CancelRedirections; { of ExecuteProgram }
Var
  redirCnt : Word;
begin
  For redirCnt := STDIN to STDOUT do
  begin
    if created[redirCnt] then
    begin
      DosExt.ForceDuplicateHandle(saveHandle[redirCnt], redirCnt);
      DosExt.CloseHandle(saveHandle[redirCnt]);
    end;
  end;
end;

Const
  STDIN  = 0;
  STDOUT = 1;
  STDERR = 2;

Procedure CallDos; Assembler;
Asm
  mov Dos.DosError, 0
  Int 21h
  jnc @@Ok
  mov Dos.DosError, ax
 @@Ok:
end;

Function DuplicateHandle(handle : Word) : Word;  Assembler;
Asm
  mov ah, 45h
  mov bx, handle
  call CallDos
  { DuplicateHandle := AX; }
end;

Procedure ForceDuplicateHandle(h1, h2 : Word); Assembler;
Asm
  mov ah, 46h
  mov bx, h1
  mov cx, h2
  call CallDos
end;


