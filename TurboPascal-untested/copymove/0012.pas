{$S-,R-,V-,I-,N-,B-,F-}

{$IFNDEF Ver40}
  {Allow overlays}
  {$F+,O-,X+,A-}
{$ENDIF}

UNIT MoveFile;

INTERFACE

USES Dos;

FUNCTION MoveFiles ( VAR OldFullPath : PathStr;
                     VAR NewFullPath : PathStr) : BOOLEAN;

IMPLEMENTATION


FUNCTION MoveFiles ( VAR OldFullPath : PathStr;
                     VAR NewFullPath : PathStr) : BOOLEAN;

VAR
  regs : REGISTERS;
  Error_Return,
  N      : BYTE;

  PROCEDURE MoveToNewPath;
  { On same disk drive }
  BEGIN
  OldFullPath [LENGTH (OldFullPath) + 1] := CHR (0);
  NewFullPath [LENGTH (NewFullPath) + 1] := CHR (0);
  WITH regs DO
    BEGIN
      DS := SEG (OldFullPath);
      DX := OFS (OldFullPath) + 1;  {the very first byte is the length}
      ES := SEG (NewFullPath);
      DI := OFS (NewFullPath) + 1;
      AX := $56 SHL 8;               { ERRORS are             }
      INTR ($21, regs);                {   2 : file not found   }
      IF Flags AND 1 = 1 THEN        {   3 : path not found   }
        error_return := AX           {   5 : access denied    }
      ELSE                           {  17 : not same device  }
        error_return := 0;
    END;  {with}
  END;

BEGIN
  Error_Return := 0;
  IF OldFullPath [1] = '\' THEN OldFullPath := FExpand (OldFullPath);
  IF NewFullPath [1] = '\' THEN NewFullPath := FExpand (NewFullPath);
  IF UPCASE (OldFullPath [1]) = UPCASE (NewFullPath [1]) THEN MoveToNewPath
     ELSE Error_Return := 17;

MoveFiles := (Error_Return = 0);
END;

END.