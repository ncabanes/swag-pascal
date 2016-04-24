(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0062.PAS
  Description: Additions to ENHDOS
  Author: MARIUS ELLEN
  Date: 08-24-94  13:35
*)


function PathTest(Pth:pchar):word;
assembler;
asm
        CLD;    LES DI,Pth
        XOR     AX,AX
        MOV     CX,0FFFFH
        REPNE   SCASB; NOT CX; JCXZ @NoAst; DEC DI; MOV DX,DI; STD
        MOV     BX,CX; MOV SI,DI; MOV AL,'.'; REPNE SCASB; JNE @U
        OR      AH,fcExtension
        INC     DI; MOV DX,DI
@U:     MOV     CX,BX; MOV DI,SI; MOV AL,'\'; REPNE SCASB; JE  @F
        MOV     CX,BX; MOV DI,SI; MOV AL,':'; REPNE SCASB; JNE @G
@F:     INC     DI
@G:     INC     DI
        CMP     DX,DI; JE @NoNam
        OR      AH,fcFileName
@NoNam: MOV     CX,BX; MOV DI,SI; MOV AL,'\'; REPNE SCASB; JNE @NoPth
        OR      AH,fcDirectory
@NoPth: MOV     CX,BX; MOV DI,SI; MOV AL,':'; REPNE SCASB; JNE @NoDrv
        OR      AH,fcDrive
@NoDrv: MOV     CX,BX; MOV DI,SI; MOV AL,'?'; REPNE SCASB; JNE @NoQst
        OR      AH,fcWildcards
@NoQst: MOV     CX,BX; MOV DI,SI; MOV AL,'*'; REPNE SCASB; JNE @NoAst
        OR      AH,fcWildcards
@NoAst: MOV     AL,AH
        XOR     AH,AH
end;

function PathBuild(Dst,Pth,Nam,Ext:PChar):PChar;
assembler;
asm
 CLD
 PUSH    DS
 XOR     AL,AL
        XOR     CX,CX;  LES   DI,Ext
        MOV     DX,ES;  AND   DX,DX; JE   @NoExt
        DEC     CX;     REPNE SCASB;
        NOT     CX;     DEC   CX
@NoExt: PUSH    CX
        XOR     CX,CX;  LES   DI,Nam
        MOV     DX,ES;  AND   DX,DX; JE   @NoNam
        DEC     CX;     REPNE SCASB
        NOT     CX;     DEC   CX
@NoNam: PUSH    CX
        XOR     CX,CX;  LES   DI,Pth
        MOV     DX,ES;  AND   DX,DX; JE   @NoPth
        DEC     CX;     REPNE SCASB
        NOT     CX;     DEC   CX
@NoPth:
 LES     DI,Dst
 MOV     BX,DI
 LDS     SI,Pth
        REP     MOVSB
 LDS     SI,Nam
        POP     CX
        REP     MOVSB
 LDS     SI,Ext
        POP     CX
        REP     MOVSB
        STOSB
        MOV     DX,ES
 MOV     AX,BX
 POP     DS
end;

procedure PathSplit(Pth,Dir,Nam,Ext:pchar);
assembler;
asm
        PUSH    DS
        LES     DI,Pth; CLD
        MOV     CX,0FFFFH
        XOR     AL,AL; REPNE SCASB; NOT CX; DEC DI; MOV BX,DI; STD
        MOV     SI,CX; MOV DX,DI; MOV AL,'.'; REPNE SCASB; JNE @U
        INC     DI; MOV BX,DI
@U:     MOV     CX,SI; MOV DI,DX; MOV AL,'\'; REPNE SCASB; JE  @F
        MOV     CX,SI; MOV DI,DX; MOV AL,':'; REPNE SCASB; JNE @G
@F:     INC     DI
@G:     INC     DI
        LDS     SI,Pth; CLD
        MOV     CX,fsDirectory
        SUB     DI,SI;  CMP DI,CX; JA @3; XCHG DI,CX
@3:     LES     DI,Dir; MOV AX,ES; AND AX,AX; JE @NoDir
        REP     MOVSB;  XOR AL,AL; STOSB
@NoDir: ADD     SI,CX
        MOV     CX,fsFilename
        MOV     AX,BX;  SUB AX,SI; CMP AX,CX; JA @4; XCHG AX,CX
@4:     LES     DI,Nam; MOV AX,ES; AND AX,AX; JE @NoNam
        REP     MOVSB;  XOR AL,AL; STOSB
@NoNam: ADD     SI,CX
        MOV     CX,fsExtension
        MOV     AX,DX;  SUB AX,SI; CMP AX,CX; JA @5; XCHG AX,CX
@5:     LES     DI,Ext; MOV AX,ES; AND AX,AX; JE @NoExt
        REP     MOVSB;  XOR AL,AL; STOSB
@NoExt: POP     DS
end;

procedure PathSplitName(Pth,Dir,NamExt:pchar);
assembler;
asm
        PUSH    DS
        LES     DI,Pth; CLD
        MOV     CX,0FFFFH
        XOR     AL,AL; REPNE SCASB; NOT CX; DEC DI; STD
        MOV     SI,CX; MOV BX,DI; MOV AL,'\'; REPNE SCASB; JE  @F
        MOV     CX,SI; MOV DI,BX; MOV AL,':'; REPNE SCASB; JNE @G
@F:     INC     DI
@G:     INC     DI
        LDS     SI,Pth; CLD
        MOV     CX,fsDirectory
        SUB     DI,SI;  CMP DI,CX; JA @3; XCHG DI,CX
@3:     LES     DI,Dir; MOV AX,ES; AND AX,AX; JE @NoDir
        REP     MOVSB;  XOR AL,AL; STOSB
@NoDir: ADD     SI,CX
        MOV     CX,fsFilename+fsExtension
        MOV     AX,BX;  SUB AX,SI; CMP AX,CX; JA @4; XCHG AX,CX
@4:     LES     DI,NamExt; MOV AX,ES; AND AX,AX; JE @NoNam
        REP     MOVSB;  XOR AL,AL; STOSB
@NoNam: POP     DS
end;

{
Is't a pitty you did not include some cacheable reads/writes in your unit
ENHDOS. Also some functions could be included using USES windos. (Or my own
bputils ;-) Here's some cacheable stuff (also protected mode).
}

function fLargeRead(Handle:word;MemPtr:pointer;Size:longint):longint;
{read Size bytes from a file to Seg:0, return bytes read}
assembler;
var Sg:word absolute Handle;
asm
        PUSH    DS
        MOV     CX,$8000
        MOV     BX,Handle
        MOV     AX,SelectorInc
        MOV     DI,Size.word[2]
        MOV     SI,Size.word[0]
        MOV     Sg,AX
        LDS     DX,MemPtr
        AND     DX,DX; JE @St
        MOV     AX,267
@Er:    {Halt(error)}
        POP     DS
        PUSH    AX
        CALL    bpHaltNr
@Re:    AND     DI,DI;  JNE @Do
        CMP     SI,CX;  JA  @Do;   MOV CX,SI
@Do:    MOV     AH,$3F; INT 21H;   JC @Er
        SUB     SI,AX;  SBB DI,0
        SUB     AX,CX;  JNE @Eo
        ADD     DX,CX;  JNC @St
        MOV     AX,DS;  ADD AX,Sg; MOV DS,AX
@St:    MOV     AX,DI;  XOR AX,SI; JNE @Re
@Eo:    POP     DS
        MOV     AX,Size.word[0]; SUB AX,SI
        MOV     DX,Size.word[2]; SBB DX,DI
@eX:
end;


function fLargeWrite(Handle:word;MemPtr:pointer;Size:longint):longint;
{write Size bytes to a file from Seg:0, return bytes written}
assembler;
var Sg:word absolute Handle;
asm
        PUSH    DS
        MOV     CX,$8000
        MOV     BX,Handle
        MOV     AX,SelectorInc
        MOV     DI,Size.word[2]
        MOV     SI,Size.word[0]
        MOV     Sg,AX
        LDS     DX,MemPtr
        AND     DX,DX; JE @St
        MOV     AX,267
        JMP     @Er
@Wr:    MOV     AX,101
@Er:    {Halt(error)}
        POP     DS
        PUSH    AX
        CALL    bpHaltNr
@Re:    AND     DI,DI;  JNE @Do
        CMP     SI,CX;  JA  @Do;   MOV CX,SI
@Do:    MOV     AH,$40; INT 21H;   JC @Er
        SUB     SI,AX;  SBB DI,0
        SUB     AX,CX;  JNE @Wr
        ADD     DX,CX;  JNC @St
        MOV     AX,DS;  ADD AX,Sg; MOV DS,AX
@St:    MOV     AX,DI;  XOR AX,SI; JNE @Re
@Eo:    POP     DS
        MOV     AX,Size.word[0]; SUB AX,SI
        MOV     DX,Size.word[2]; SBB DX,DI
@eX:
end;

