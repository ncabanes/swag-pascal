(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0037.PAS
  Description: FLUSHDOS.PAS
  Author: SWAG SUPPORT TEAM
  Date: 11-21-93  09:30
*)

PROGRAM FlushDem;

  FUNCTION DosFlush(VAR F) : BOOLEAN; Assembler;
  ASM
    MOV AX, 3000h       {get DOS version}
    INT 21h
    CMP AL, 3           {DOS < 3? old!}
    JL @old
    CMP AH, 1Eh         {DOS < 3.3? old!}
    LES DI, F
    MOV BX, ES:[DI]     {file handle is first word}
    MOV AH, 68h         {commit file function}
    INT 21h
    JC @BadEnd
    JMP @GoodEnd

    @old:
    LES DI, F
    MOV BX, ES:[DI]     {file handle is first word}
    MOV AH, 45h         {duplicate handle function}
    INT 21h
    JC @BadEnd
    @ok:
    MOV BX, AX          {put duped handle in BX...}
    MOV AH, 3Eh         {... and close it}
    INT 21h
    JC @BadEnd
    @GoodEnd:
    MOV AX, 0
    @BadEnd:
  END;

VAR
  T1, T2 : Text;
  S      : String;
  W      : Word;
BEGIN
  Assign(T1, 'DEMO1.$$$');
  Rewrite(T1);
  Assign(T2, 'DEMO2.$$$');
  Rewrite(T2);
  S := 'This is just a sample line of text.';
  FOR W := 1 to 100 DO
    BEGIN
      WriteLn(T1, W:4, ' ', S);
      WriteLn(T2, W:4, ' ', S);
    END;
  IF DosFlush(T2) THEN
    BEGIN
      WriteLn('Successfully flushed the second demo ',
              'file.  Please reboot your computer.');
      ReadLn;
      WriteLn('Hey, I said PLEASE reboot.  Oh well... ',
              ' I will erase the temporary files.');
      Close(T1);  Erase(T1);
      Close(T2);  Erase(T2);
    END
  ELSE WriteLn('DosFlush routine failed.');
END.
