==============================================================================
 BBS: ─≡─ The Graphics Connection ─≡─ Speciali
  To: JOE JACOBSON                 Date: 12-20-92 (15:25)
From: GUY MCLOUGHLIN             Number: 1137   [121] Pascal-IL
Subj: CTRL-ALT-DELETE TRAPPING   Status: Public
------------------------------------------------------------------------------
  ...Unit captured from FIDONET:

UNIT CAD;

{- Area: PASCAL ---------------------}
{  Date: 10-16-92  22:12             }
{  From: Wilbert van Leijen          }
{    To: John Martzall               }
{  Subj: Ctrl-Alt-Delete             }
{------------------------------------}

INTERFACE

USES Dos;

VAR
  Int9Handler  : POINTER;

PROCEDURE InterceptCtrlAltDel;
PROCEDURE RestoreCAD;

  IMPLEMENTATION

PROCEDURE InterceptCtrlAltDel; Assembler;

CONST
  Ctrl         = 4;
  Alt          = 8;
  Del          = $53;
  KbdPort      = $60;                  { Keyboard port }
  KbdCtrlPort  = $61;                  { Keyboard control port }
  PIC          = $20;                  { 8259 Interrupt controller }
  EOI          = $20;                  { End-of-interrupt }

  ASM
  { Make sure we can access our global data }

  PUSH   AX
  PUSH   DS
  MOV    AX, SEG @Data
  MOV    DS, AX
  STI

  { Read keyboard port and mask out the 'break bit'.
          Check whether the <Del> key was pressed. }

  IN     AL, KbdPort
  AND    AL, 01111111b
  CMP    AL, Del
  JNE    @2

  { <Del> key was pressed, now check whether <Ctrl> and <Alt>
          are held down }

  @1 :     MOV    AH, 2               { BIOS Get keyboard flags service }
  INT    16h
  TEST   AL, Ctrl + Alt
  JNZ    @3

  { Chain to previous owner of INT 9 }

  @2 :     PUSHF
  CALL   [Int9Handler]
  JMP    @4

  { Ctrl-Alt-Del combination found: send the break code }

  @3 :     IN     AL, KbdCtrlPort
  MOV    AH, AL
  OR     AL, 10000000b
  OUT    KbdCtrlPort, AL
  XCHG   AH, AL
  OUT    KbdCtrlPort, AL
  CLI

  { Signal 'End Of Interrupt' to the 8259 interrupt controller chip }

  MOV    AL, EOI
  OUT    PIC, AL
  @4 :     POP    DS
  POP    AX
  IRET                       { make sure we return correctly }
END;  { InterceptCtrlAltDel }

PROCEDURE RestoreCAD;

BEGIN
  SETINTVEC (9, Int9Handler);
END;  { RestoreCAD }

BEGIN
  GETINTVEC (9, Int9Handler);
  SETINTVEC (9, @InterceptCtrlAltDel);
END.
                               - Guy
---
 ■ DeLuxe²/386 1.25 #5060 ■
 ■ QNet3ß ■ ILink - Canada Remote Systems - Toronto, Ont (416) 798-4713
