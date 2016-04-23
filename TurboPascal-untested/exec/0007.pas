{$S-,R-,V-,I-,N-,B-,F-}

{$IFNDEF Ver40}
  {Allow overlays}
  {$F+,O-,X+,A-}
{$ENDIF}

UNIT FINDEXEC;

INTERFACE

USES CRT,DOS;

PROCEDURE FLUSHALLDOS;
PROCEDURE REBOOT;
FUNCTION  EXECUTE (Name : PathStr ; Tail : STRING) : WORD;
PROCEDURE RunInWindow (FN, Cmd : STRING; PAUSE : BOOLEAN);

IMPLEMENTATION
VAR
     cname   : STRING;
     Old_29H : POINTER;

PROCEDURE FLUSHALLDOS; ASSEMBLER;
ASM
  mov   ah, 0Dh
  INT   21h
  XOR   cx, cx
@1 :
  push  cx
  INT   28h
  pop   cx
  loop  @1
END;

PROCEDURE Reboot; assembler;
asm
  CALL  FLUSHALLDOS
  MOV   ds, cx
  MOV   WORD PTR [472h], 1234h
  DEC   cx
  PUSH  cx
  PUSH  ds
END;

{F+}
Procedure Int29Handler(AX, BX, CX, DX, SI, DI, DS, ES, BP : Word); Interrupt;
Var
  Dummy : Byte;
begin
  Asm
    Sti
  end;
  Write(Char(Lo(Ax)));
  Asm
    Cli
  end;
end;
{$F-}

{   EXECUTE STUFF - SHRINK HEAP AND EXECUTE LIKE EXECDOS }

PROCEDURE ReallocateMemory (P : POINTER); ASSEMBLER;
ASM
  MOV  AX, PrefixSeg
  MOV  ES, AX
  MOV  BX, WORD PTR P + 2
  CMP  WORD PTR P, 0
  JE   @OK
  INC  BX

 @OK :
  SUB  BX, AX
  MOV  AH, 4Ah
  INT  21h
  JC   @X
  LES  DI, P
  MOV  WORD PTR HeapEnd, DI
  MOV  WORD PTR HeapEnd + 2, ES
 @X :
END;

{ ZAP this DEFINE if NOT 386,486}
{..$DEFINE CPU386}

FUNCTION EXEC (Name : PathStr ; Tail : STRING) : WORD; ASSEMBLER;
ASM
  CALL    FLUSHALLDOS
  {$IFDEF CPU386}
  DB      66h
  PUSH    WORD PTR HeapEnd
  DB      66h
  PUSH    WORD PTR Name
  DB      66h
  PUSH    WORD PTR Tail
  DB      66h
  PUSH    WORD PTR HeapPtr
  {$ELSE}
  PUSH    WORD PTR HeapEnd + 2
  PUSH    WORD PTR HeapEnd
  PUSH    WORD PTR Name + 2
  PUSH    WORD PTR Name
  PUSH    WORD PTR Tail + 2
  PUSH    WORD PTR Tail
  PUSH    WORD PTR HeapPtr + 2
  PUSH    WORD PTR HeapPtr

  {$ENDIF}

  CALL ReallocateMemory
  CALL SwapVectors
  CALL DOS.EXEC
  CALL SwapVectors
  CALL ReallocateMemory
  MOV  AX, DosError
  OR   AX, AX
  JNZ  @OUT
  MOV  AH, 4Dh
  INT  21h

 @OUT :

END;

FUNCTION EXECUTE (Name : PathStr ; Tail : STRING)  : WORD;
VAR W : PathStr;
BEGIN
 DosError := 2;
 W := FSEARCH (Name, GetEnv ('PATH') );
 IF W = '' THEN EXIT;
 EXECUTE := EXEC(W,Tail);
END;

PROCEDURE RunInWindow (FN, Cmd : STRING; PAUSE : BOOLEAN);

VAR sa : BYTE;
    w  : pathstr;

BEGIN

 DosError := 2;
 W := FSEARCH (fn, GetEnv ('PATH') );
 IF W = '' THEN EXIT;
 sa       := Textattr;

 GETINTVEC ($29, OLD_29H);
 SETINTVEC ($29, @Int29Handler);         { Install interrupt handler }
 WINDOW (LO (WindMin) + 1, HI (WindMin) + 1, LO (WindMax) + 1, HI (WindMax) + 1);
 EXEC (W, Cmd );
 SETINTVEC ($29, OLD_29h);

 IF PAUSE THEN
    BEGIN
    WRITELN;
    WRITELN (' .. Any Key Continues .. ');
    asm
      Mov AX, $0C00;               { flush keyboard }
      Int 21h;
    end;
    WHILE NOT KEYPRESSED DO;
    asm
      Mov AX, $0C00;
      Int 21h;
    end;
    END;
 Textattr := sa;
END;

END.