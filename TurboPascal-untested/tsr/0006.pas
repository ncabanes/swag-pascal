Unit TSRUnit; {Create TSR Programs With Turbo Pascal 5.0 & TSRUnit}

{$B-,F-,I+,R-,S+} {Set Compiler directives to normal values.}

Interface {=======================================================}
{
The author and any distributor of this software assume no responsi-
bility For damages resulting from this software or its use due to
errors, omissions, inCompatibility With other software or with
hardware, or misuse; and specifically disclaim any implied warranty
of fitness For any particular purpose or application.
}
Uses Dos, Crt;
Const
{*** Shift key combination codes.                                 }
  AltKey = 8;  CtrlKey = 4;  LeftKey = 2;  RightKey = 1;

  TSRVersion : Word = $0204;       {Low Byte.High Byte = 2.04     }

Type
  String80  = String[80];
  ChrWords  = Record Case Integer of
                  1: ( W: Word );
                  2: ( C: Char; A: Byte );
              end;
  LineWords = Array[1..80] of ChrWords;
  WordFuncs = Function : Word;

Var
  TSRScrPtr : Pointer; {Pointer to saved screen image.            }
  TSRChrPtr : Pointer; {Pointer to first Character to insert.     }
  TSRMode   : Byte;    {Video mode --------- beFore TSR popped up.}
  TSRWidth  : Byte;    {Number of screen columns-- " "    "    " .}
  TSRPage   : Byte;    {Active video page number-- " "    "    " .}
  TSRColumn : Byte;    {Cursor column number ----- " "    "    " .}
  TSRRow    : Byte;    {Cursor row number -------- " "    "    " .}
{
** Procedure For installing the TSR Program.                      }
Procedure TSRInstall( TSRName : String;   {Name or title For TSR. }
                      TSRFunc : WordFuncs;{Ptr to Function to call}
                      ShiftComb: Byte;    {Hot key--shift key comb}
                      KeyChr   : Char );  {Hot Key--Character key.}
{
  ShiftComb and KeyChr specify the default hot keys For the TSR.
  ShiftComb may be created by adding or oring the Constants AltKey,
  CtrlKey, LeftKey, and RightKey together.  KeyChr may be
  Characters 0-9 and A-Z.

  The default hot keys may be overridden when the TSR is installed
  by specifying optional parameters on the command line.  The
  parameter Format is:
                       [/A] [/C] [/R] [/L] [/"[K["]]]
  The square brackets surround optional items--do not include them.
  Any Characters between parameters are ignored. The order of the
  Characters does not matter; however, the shift keys specified are
  cummulative and the last Character key "K" specified is the used.
}
{
** Functions For checking status of Printer LPT1.                 }
Function PrinterOkay:   Boolean; {Returns True if Printer is okay.}
Function PrinterStatus: Byte;    {Returns status of Printer.
  Definition of status Byte bits (1 & 2 are not used), if set then:
 Bit: -- 7 ---  ---- 6 ----  -- 5 ---  -- 4 ---  -- 3 --  --- 0 ---
      not busy  Acknowledge  No paper  Selected  I/O Err. Timed-out
}
{
** Routines For obtaining one row of screen Characters.           }
Function ScreenLineStr( Row: Byte ): String80; {Returns Char. str.}
Procedure ScreenLine( Row: Byte; Var Line: LineWords; {Returns    }
                                 Var Words: Byte );   {chr & color}

Implementation {==================================================}
Var
  BuffSize, InitCMode : Word;
  NpxFlag             : Boolean;
  Buffer              : Array[0..8191] of Word;
  NpxState            : Array[0..93] of Byte;
  RetrnVal, InitVideo : Byte;
  TheirFunc           : WordFuncs;

Const    {offsets to items contained in Procedure Asm.            }
  UnSafe = 0;    Flg   = 1;     Key     = 2;     Shft  = 3;
  Stkofs = 4;    StkSs = 6;     DosSp   = 8;     DosSs = 10;
  Prev  = 12;    Flg9  = 13;    InsNumb = 14;
  Dos21 = $10;         Dos25  = Dos21+4;      Dos26  = Dos25+4;
  Bios9 = Dos26+4;     Bios16 = Bios9+4;      DosTab = Bios16+4;
  Our21 = DosTab+99;   Our25  = Our21+51;     Our26  = Our25+27;
  Our09 = Our26+27;    Our16  = Our09+127+8;  InsChr = Our16+180-8;
  PopUp = InsChr+4;

Procedure Asm1; {Inline code--data storage and intercept routines. }
INTERRUPT;
begin
Inline(
{***  Storage For interrupt vectors.                              }
      {Dos21:  }  >0/>0/    {Dos func. intr vector.               }
      {Dos25:  }  >0/>0/    {Dos abs. disk read intr. vector.     }
      {Dos26:  }  >0/>0/    {Dos abs. sector Write intr.vector.   }
      {Bios9:  }  >0/>0/    {BIOS key stroke intr. vector.        }
      {Bios16: }  >0/>0/    {BIOS buffered keybd. input intr.vect.}

      {DosTab: Array[0..98] of Byte = {Non-reetrant Dos Functions.}
      0/0/0/0/0/0/0/0/  0/0/0/0/0/1/1/1/  1/1/1/1/1/1/1/1/
      1/1/1/1/1/1/1/1/  1/1/1/1/1/1/0/1/  1/1/1/1/1/1/1/0/
      1/0/0/0/0/0/1/1/  1/1/1/1/1/1/1/1/  1/1/1/1/1/1/1/1/
      0/0/0/0/0/0/1/1/  0/0/0/0/1/0/1/1/  0/1/1/1/1/0/0/0/  0/0/0/

{*** OurIntr21 ******* Intercept routine For Dos Function Intr.***}
{  0} $9C/               { PUSHF            ;Save flags.          }
{  1} $FB/               { STI              ;Enable interrupts.   }
{  2} $80/$FC/$63/       { CMP  AH,63H      ;Assume unsafe if new }
{  5} $73/<22-7/         { JNB  IncF        ;Function--skip table.}
{  7} $50/               { PUSH AX          ;Save Registers.      }
{  8} $53/               { PUSH BX          ;Load offset to table.}
{  9} $BB/>DosTab/       { MOV  BX,[DosTab]                       }
{ 12} $8A/$C4/           { MOV  AL,AH       ;Load table entry     }
{ 14} $2E/               { CS:              ;index.               }
{ 15} $D7/               { XLAT             ;Get value from table.}
{ 16} $3C/$00/           { CMP  AL,0        ;if True then set flag}
{ 18} $5B/               { POP  BX          ;Restore Registers.   }
{ 19} $58/               { POP  AX          ;                     }
{ 20} $74/$17/           { JZ   JmpDos21    ;Jump to orig. intr.  }
{ 22} $2E/          {IncF: CS:              ;                     }
{ 23} $FE/$06/>UnSafe/   { inC  [UnSafe]    ;Set UnSafe flag.     }
{ 27} $9D/               { POPF             ;Restore flags.       }
{ 28} $9C/               { PUSHF            ;                     }
{ 29} $2E/               { CS:              ;                     }
{ 30} $FF/$1E/>Dos21/    { CALL Far [Dos21] ;Call orig. intr.     }
{ 34} $FB/               { STI              ;Enable interrupts.   }
{ 35} $9C/               { PUSHF            ;Save flags.          }
{ 36} $2E/               { CS:              ;                     }
{ 37} $FE/$0E/>UnSafe/   { DEC  [UnSafe]    ;Clear UnSafe flag.   }
{ 41} $9D/               { POPF             ;Restore flags.       }
{ 42} $CA/$02/$00/       { RETF 2           ;Return & remove flag.}

{ 45} $9D/      {JmpDos21: POPF             ;Restore flags.       }
{ 46} $2E/               { CS:              ;                     }
{ 47} $FF/$2E/>Dos21/    { JMP Far [Dos21]  ;Jump to orig. intr.  }
{ 51}
{*** OurIntr25 ********** Intercept routine For Dos Abs. Read *** }
{  0} $9C/               { PUSHF            ;Save flags.          }
{  1} $2E/               { CS:              ;                     }
{  2} $FE/$06/>UnSafe/   { inC  [UnSafe]    ;Set UnSafe flag.     }
{  6} $9D/               { POPF             ;Restore flags.       }
{  7} $9C/               { PUSHF            ;                     }
{  8} $2E/               { CS:              ;                     }
{  9} $FF/$1E/>Dos25/    { CALL Far [Dos25] ;Call Dos abs. read.  }
{ 13} $68/>Our25+19/     { PUSH Our25+19    ;Clean up stack with- }
{ 16} $C2/$02/$00/       { RET  2           ;out changing flags.  }
{ 19} $9C/               { PUSHF            ;Save flags.          }
{ 20} $2E/               { CS:              ;                     }
{ 21} $FE/$0E/>UnSafe/   { DEC  [UnSafe]    ;Clear UnSafe flag.   }
{ 25} $9D/               { POPF             ;Restore flags.  Leave}
{ 26} $CB/               { RETF             ;old flags on the stk.}
{ 27}
{*** OurIntr26 ********** Intercept routine For Dos Abs. Write ***}
{  0} $9C/               { PUSHF            ;Save flags.          }
{  1} $2E/               { CS:              ;                     }
{  2} $FE/$06/>UnSafe/   { inC  [UnSafe]    ;Set UnSafe flag.     }
{  6} $9D/               { POPF             ;Restore flags.       }
{  7} $9C/               { PUSHF            ;                     }
{  8} $2E/               { CS:              ;                     }
{  9} $FF/$1E/>Dos26/    { CALL Far [Dos26] ;Call Dos abs. Write. }
{ 13} $68/>Our26+19/     { PUSH Our26+19    ;Clean up stack with- }
{ 16} $C2/$02/$00/       { RET  2           ;out changing flags.  }
{ 19} $9C/               { PUSHF            ;Save flags.          }
{ 20} $2E/               { CS:              ;                     }
{ 21} $FE/$0E/>UnSafe/   { DEC  [UnSafe]    ;Clear UnSafe flag.   }
{ 25} $9D/               { POPF             ;Restore flags.  Leave}
{ 26} $CB/               { RETF             ;old flags on the stk.}
{ 27}

{*** OurIntr9 ********** Intercept For BIOS Hardware Keyboard Intr}
{  0} $9C/               { PUSHF            ;Entry point.         }
{  1} $FB/               { STI              ;Enable interrupts.   }
{  2} $1E/               { PUSH DS          ;                     }
{  3} $0E/               { PUSH CS          ;DS := CS;            }
{  4} $1F/               { POP  DS          ;                     }
{  5} $50/               { PUSH AX          ;Preserve AX on stack.}
{  6} $31/$C0/           { xor  AX,AX       ;Set AH to 0.         }
{  8} $E4/$60/           { in   AL,60h      ;Read Byte from keybd }
{ 10} $3C/$E0/           { CMP  AL,0E0h     ;if multi-Byte codes, }
{ 12} $74/<75-14/        { JE   Sfx         ;then jump and set    }
{ 14} $3C/$F0/           { CMP  AL,0F0h     ;multi-Byte flag, Flg9}
{ 16} $74/<75-18/        { JE   Sfx         ;                     }
{ 18} $80/$3E/>Flg9/$00/ { CMP  [Flg9],0    ;Exit if part of      }
{ 23} $75/<77-25/        { JNZ  Cfx         ;multi-Byte code.     }
{ 25} $3A/$06/>Key/      { CMP  AL,[Key]    ;Exit if key pressed  }
{ 29} $75/<88-31/        { JNE  PreExit     ;is not hot key.      }

{ 31} $50/               { PUSH AX          ;Hot key was pressed, }
{ 32} $06/               { PUSH ES          ;check shift key      }
{ 33} $B8/$40/$00/       { MOV  AX,0040h    ;status Byte.  First  }
{ 36} $8E/$C0/           { MOV  ES,AX       ;load BIOS segment.   }
{ 38} $26/               { ES:              ;                     }
{ 39} $A0/>$0017/        { MOV  AL,[0017h]  ;AL:= Shift key status}
{ 42} $07/               { POP  ES          ;Restore ES register. }
{ 43} $24/$0F/           { and  AL,0Fh      ;Clear unwanted bits. }
{ 45} $3A/$06/>Shft/     { CMP  AL,[Shft]   ;Exit if not hot key  }
{ 49} $58/               { POP  AX          ;shift key combination}
{ 50} $75/<88-52/        { JNE  PreExit     ;(Restore AX first).  }

                         {                  ;Hot Keys encountered.}
{ 52} $3A/$06/>Prev/     { CMP  AL,[Prev]   ;Discard Repeated hot }
{ 56} $74/<107-58/       { JE   Discard     ;key codes.           }
{ 58} $A2/>Prev/         { MOV  [Prev],AL   ;Update Prev.         }
{ 61} $F6/$06/>Flg/3/    { TEST [Flg],3     ;if Flg set, keep key }
{ 66} $75/<99-68/        { JNZ  JmpBios9    ;& Exit to orig. BIOS }
{ 68} $80/$0E/>Flg/1/    { or   [Flg],1     ;9.  else set flag and}
{ 73} $EB/<107-75/       { JMP SHorT Discard;discard key stroke.  }

{ 75} $B4/$01/       {Sfx: MOV  AH,1        ;Load AH With set flag}
{ 77} $88/$26/>Flg9/ {Cfx: MOV  [Flg9],AH   ;Save multi-Byte flag.}
{ 81} $C6/$06/>Prev/$FF/ { MOV  [Prev],0FFh ;Change prev key Byte.}
{ 86} $EB/<99-88/        { JMP SHorT JmpBios9                     }

{ 88} $3C/$FF/   {PreExit: CMP  AL,0FFh     ;Update previous key  }
{ 90} $74/<99-92/        { JE   JmpBios9    ;unless key is buffer-}
{ 92} $3C/$00/           { CMP  AL,0        ;full code--a 00h     }
{ 94} $74/<99-96/        { JZ   JmpBios9    ;0FFh                 }
{ 96} $A2/>Prev/         { MOV [Prev],AL    ;Update previous key. }

{ 99} $58/      {JmpBios9: POP  AX          ;Restore Registers and}
{100} $1F/               { POP  DS          ;flags.               }
{101} $9D/               { POPF             ;                     }
{102} $2E/               { CS:              ;                     }
{103} $FF/$2E/>Bios9/    { JMP  [Bios9]     ;Exit to orig. intr 9.}

{107} $E4/$61/   {Discard: in   AL,61h      ;Clear key from buffer}
{109} $8A/$E0/           { MOV  AH,AL       ;by resetting keyboard}
{111} $0C/$80/           { or   AL,80h      ;port and sending EOI }
{113} $E6/$61/           { OUT  61h,AL      ;to intr. handler     }
{115} $86/$E0/           { XCHG AH,AL       ;telling it that the  }
{117} $E6/$61/           { OUT  61h,AL      ;key has been         }
{119} $B0/$20/           { MOV  AL,20h      ;processed.           }
{121} $E6/$20/           { OUT  20h,AL      ;                     }
{123} $58/               { POP  AX          ;Restore Registers and}
{124} $1F/               { POP  DS          ;flags.               }
{125} $9D/               { POPF             ;                     }
{126} $CF/               { IRET             ;Return from interrupt}
{127}

{*** OurIntr16 ***** Intercept routine For Buffered Keyboard Input}
{  0} $58/     {JmpBios16: POP  AX          ;Restore AX, DS, and  }
{  1} $1F/               { POP  DS          ;FLAGS Registers then }
{  2} $9D/               { POPF             ;exit to orig. BIOS   }
{  3} $2E/               { CS:              ;intr. 16h routine.   }
{  4} $FF/$2E/>Bios16/   { JMP  [Bios16]    ;                     }

{  8} $9C/     {OurIntr16: PUSHF            ;Preserve FLAGS.      }
{  9} $FB/               { STI              ;Enable interrupts.   }
{ 10} $1E/               { PUSH DS          ;Preserve DS and AX   }
{ 11} $50/               { PUSH AX          ;Registers.           }
{ 12} $0E/               { PUSH CS          ;DS := CS;            }
{ 13} $1F/               { POP  DS          ;                     }
{ 14} $F6/$C4/$EF/       { TEST AH,EFh      ;Jmp if not read Char.}
{ 17} $75/<48-19/        { JNZ  C3          ;request.             }

                         {*** Intercept loop For Read Key service.}
{ 19} $F6/$06/>Flg/1/ {C1: TEST [Flg],1     ;if pop up Flg bit is }
{ 24} $74/<29-26/        { JZ   C2          ;set then call Inline }
{ 26} $E8/>122-29/       { CALL toPopUp     ;pop up routine.      }
{ 29} $F6/$06/>Flg/16/{C2: TEST [Flg],10h   ;Jmp if insert flg set}
{ 34} $75/<48-36/        { JNZ  C3          ;                     }
{ 36} $FE/$C4/           { inC  AH          ;Use orig. BIOS       }
{ 38} $9C/               { PUSHF            ;service to check For }
{ 39} $FA/               { CLI              ;Character ready.     }
{ 40} $FF/$1E/>Bios16/   { CALL Far [Bios16];Disable interrupts.  }
{ 44} $58/               { POP  AX          ;Restore AX and save  }
{ 45} $50/               { PUSH AX          ;it again.            }
{ 46} $74/<19-48/        { JZ   C1          ;Loop Until chr. ready}

{ 48} $F6/$06/>Flg/17/{C3: TEST [Flg],11h   ;Exit if neither bit  }
{ 53} $74/<-55/          { JZ   JmpBios16   ;of Flg is set.       }
{ 55} $F6/$06/>Flg/$01/  { TEST [Flg],1     ;if pop up Flg bit is }
{ 60} $74/<65-62/        { JZ   C4          ;set then call Inline }
{ 62} $E8/>122-65/       { CALL toPopUp     ;pop up routine.      }
{ 65} $F6/$06/>Flg/$10/{C4:TEST [Flg],10h   ;Exit unless have     }
{ 70} $74/<-72/          { JZ   JmpBios16   ;Characters to insert.}
{ 72} $F6/$C4/$EE/       { TEST AH,0EEh     ;if request is not a  }
{ 75} $75/<-77/          { JNZ  JmpBios16   ;chr. request, Exit.  }

                         {*** Insert a Character.                 }
{ 77} $58/               { POP  AX          ;AX := BIOS service no}
{ 78} $53/               { PUSH BX          ;Save BX and ES.      }
{ 79} $06/               { PUSH ES          ;                     }
{ 80} $C4/$1E/>InsChr/   { LES  BX,[InsChr] ;PTR(ES,BX) := InsChr;}
{ 84} $26/               { ES:              ;AL := InsChr^;       }
{ 85} $8A/$07/           { MOV  AL,[BX]     ;                     }
{ 87} $07/               { POP  ES          ;Restore ES and BX.   }
{ 88} $5B/               { POP  BX          ;                     }
{ 89} $F6/$C4/$01/       { TEST AH,01h      ;if AH in [$01,$11]   }
{ 92} $B4/$00/           { MOV  AH,00h      ;   then ReportOnly;  }
{ 94} $75/<114-96/       { JNZ  ReportOnly  ;Set Scan code to 0.  }
{ 96} $FE/$06/>InsChr/   { inC  [InsChr]    ;Inc( InsChr );       }
{100} $FF/$0E/>InsNumb/  { DEC  [InsNumb]   ;Dec( InsNumb );      }
{104} $75/<111-106/      { JNZ  SkipReset   ;if InsNumb = 0 then  }
{106} $80/$26/>Flg/$EF/  { and  [Flg],0EFh  ; Clear insert chr flg}
{111} $1F/     {SkipReset: POP  DS          ;Restore BX, DS, and  }
{112} $9D/               { POPF             ;FLAGS, then return   }
{113} $CF/               { IRET             ;from interrupt.      }

{114} $1F/    {ReportOnly: POP  DS          ;Report Char. ready.  }
{115} $9D/               { POPF             ;Restore DS and FLAGS.}
{116} $50/               { PUSH AX          ;Clear zero flag bit  }
{117} $40/               { inC  AX          ;to indicate a        }
{118} $58/               { POP  AX          ;Character ready.     }
{119} $CA/>0002/         { RETF 2           ;Exit & discard FLAGS }

                         {*** Interface to PopUpCode Routine.     }
{122} $50/       {toPopUp: PUSH AX          ;Save AX.             }
{123} $FA/               { CLI              ;Disable interrupts.  }
{124} $F6/$06/>UnSafe/$FF/{TEST [UnSafe],0FFh ;if UnSafe <> 0     }
{129} $75/<177-131/      { JNZ  PP2           ;      then Return. }
{131} $A0/>Flg/          { MOV  AL,[Flg]    ;Set in-use bit; clear}
{134} $24/$FE/           { and  AL,0FEh     ;pop up bit of Flg.   }
{136} $0C/$02/           { or   AL,2        ;Flg := (Flg and $FE) }
{138} $A2/>Flg/          { MOV  [Flg],AL    ;        or 2;        }
                         {                  ;**Switch to our stack}
{141} $A1/>Stkofs/       { MOV  AX,[Stkofs] ;Load top of our stack}
{144} $87/$C4/           { XCHG AX,SP       ;Exchange it With     }
{146} $A3/>DosSp/        { MOV  [DosSp],AX  ;stk.ptr, save old SP.}
{149} $8C/$16/>DosSs/    { MOV  [DosSs],SS  ;Save old SS.         }
{153} $8E/$16/>StkSs/    { MOV  SS,[StkSs]  ;Replace SS With our  }
{157} $FB/               { STI              ;SS. Enable interrupts}

{158} $9C/               { PUSHF            ;Interrupt call to pop}
{159} $FF/$1E/>PopUp/    { CALL Far [PopUp] ;up TSR routine.      }

{163} $FA/               { CLI              ;Disable interrupts.  }
{164} $8B/$26/>DosSp/    { MOV  SP,[DosSp]  ;Restore stack ptr    }
{168} $8E/$16/>DosSs/    { MOV  SS,[DosSs]  ;SS:SP.  Clear in-use }
{172} $80/$26/>Flg/$FD/  { and  [Flg],0FDh  ;bit of Flg.          }

{177} $FB/           {PP2: STI              ;Enable interrupts.   }
{178} $58/               { POP  AX          ;Restore AX.          }
{179} $C3 );             { RET              ;Return.              }
{180}
end; {Asm.} {end corresponds to 12 Bytes of code--used For storage}

Procedure PopUpCode; {Interface between the BIOS intercept        }
INTERRUPT;           {routines and your TSR Function.             }
Const  BSeg = $0040;   VBiosofs = $49;
Type
  VideoRecs = Record
                VideoMode                      : Byte;
                NumbCol, ScreenSize, Memoryofs : Word;
                CursorArea      : Array[0..7] of Word;
                CursorMode                     : Word;
                CurrentPage                    : Byte;
                VideoBoardAddr                 : Word;
                CurrentMode, CurrentColor      : Byte;
              end;
Var
  Regs             : Registers;
  VideoRec         : VideoRecs;
  KeyLock          : Byte;
  ScrnSeg, NumbChr : Word;
begin
  SwapVectors;                            {Set T.P. intr. vectors.}
  Move( Ptr(BSeg,VBiosofs)^, VideoRec,    {Get Video BIOS info.   }
        Sizeof(VideoRec) );
  With VideoRec, Regs do begin
    if (VideoMode > 7) or                  {Abort pop up if unable}
       (ScreenSize > BuffSize) then begin  {to save screen image. }
      SwapVectors;                         {Restore intr. vectors.}
      Exit;
    end;
    KeyLock := Mem[BSeg:$0017];            {Save lock key states. }
    if VideoMode = 7 then ScrnSeg := $B000 {Save screen--supports }
    else ScrnSeg := $B800;                 {Text, MGA & CGA modes.}
    Move( PTR( ScrnSeg, Memoryofs )^, Buffer, ScreenSize );
    AX := InitVideo;                       {if in Graphics mode,  }
    if (VideoMode >=4)                     {switch to Text mode.  }
       and (VideoMode <= 6) then Intr( $10, Regs );
    AX := $0500;                           {Select display page 0.}
    Intr( $10, Regs );
    CX := InitCMode;                       {Set cursor size.      }
    AH := 1;
    Intr( $10, Regs );

    TSRMode   := VideoMode;              {Fill global Variables   }
    TSRWidth  := NumbCol;                {with current inFormation}
    TSRPage   := CurrentPage;
    TSRColumn := Succ( Lo( CursorArea[CurrentPage] ) );
    TSRRow    := Succ( Hi( CursorArea[CurrentPage] ) );

    if NpxFlag then                      {Save co-processor state.}
      Inline( $98/ $DD/$36/>NpxState );  {WAIT FSAVE [NpxState]   }
{
*** Call user's Program and save return code--no. Char. to insert.
}
    NumbChr := TheirFunc;
    MemW[CSeg:InsNumb] := NumbChr;
    if NumbChr > 0 then begin               {Have Char. to insert.}
      MemL[CSeg:InsChr] := LongInt( TSRChrPtr );
      Mem[CSeg:Flg]     := Mem[CSeg:Flg] or $10;
    end;
{
*** Pop TSR back down--Restore Computer to previous state.
}
    if NpxFlag then                      {Restore co-prcssr state.}
      Inline( $98/ $DD/$36/>NpxState );  {WAIT FSAVE [NpxState]   }

    Mem[BSeg:$17] :=                     {Restore key lock status.}
      (Mem[BSeg:$17] and $0F) or (KeyLock and $F0);

    if Mem[BSeg:VBiosofs] <> VideoMode then begin
      AX := VideoMode;                   {Restore video mode.     }
      Intr( $10, Regs );
    end;
    AH := 1;  CX := CursorMode;          {Restore cursor size.    }
    Intr( $10, Regs );
    AH := 5;  AL := CurrentPage;         {Restore active page.    }
    Intr( $10, Regs );
    AH := 2;  BH := CurrentPage;         {Restore cursor positon. }
    DX := CursorArea[CurrentPage];
    Intr( $10, Regs );                   {Restore screen image.   }
    Move( Buffer, PTR( ScrnSeg, Memoryofs )^, ScreenSize );

    SwapVectors;                        {Restore non-T.P. vectors.}
  end;
end;  {PopUp.}
{
***** Printer Functions:
}
Function PrinterStatus: Byte;             {Returns status of LPT1.}
{ Definition of status Byte bits (1 & 2 are not used), if set then:
 Bit: -- 7 ---  ---- 6 ----  -- 5 ---  -- 4 ---  -- 3 --  --- 0 ---
      not busy  Acknowledge  No paper  Selected  I/O Err. Timed-out
}
Var Regs  : Registers;
begin
  With Regs do begin
    AH := 2;  DX := 0;    {Load BIOS Function and Printer number. }
    Intr( $17, Regs );    {Call BIOS Printer services.            }
    PrinterStatus := AH;  {Return With Printer status Byte.       }
  end;
end; {PrinterStatus.}

Function PrinterOkay: Boolean;  {Returns True if Printer is okay. }
Var  S : Byte;
begin
  S := PrinterStatus;
  if ((S and $10) <> 0) and ((S and $29) = 0) then
    PrinterOkay := True
  else PrinterOkay := False;
end;  {PrinterOkay.}
{
***** Procedures to obtain contents of saved screen image.
}
Procedure ScreenLine( Row: Byte; Var Line: LineWords;
                                 Var Words: Byte );
begin
  Words := 40;                        {Determine screen line size.}
  if TSRMode > 1 then  Words := Words*2;          {Get line's     }
  Move( Buffer[Pred(Row)*Words], Line, Words*2 ); {Characters and }
end;  {ScreenLine.}                               {colors.        }

Function ScreenLineStr( Row: Byte ): String80; {Returns just Chars}
Var
  Words, i   : Byte;
  LineWord   : LineWords;
  Line       : String80;
begin
  ScreenLine( Row, LineWord, Words );   {Get Chars & attributes.  }
  Line := '';                           {Move Characters to String}
  For i := 1 to Words do Insert( LineWord[i].C, Line, i );
  ScreenLineStr := Line;
end;  {ScreenString.}
{
***** TSR Installation Procedure.
}
Procedure TSRInstall( TSRName: String; TSRFunc: WordFuncs;
                      ShiftComb: Byte; KeyChr: Char );
Const
  ScanChr = '+1234567890++++QWERTYUIOP++++ASDFGHJKL+++++ZXCVBNM';
  CombChr = 'RLCA"';
Var
  PlistPtr         : ^String;
  i, j, k          : Word;
  Regs             : Registers;
  Comb, ScanCode   : Byte;
begin
  if ofs( Asm1 ) <> 0 then Exit;           {offset of Asm must be 0}
  MemW[CSeg:StkSs]  := SSeg;              {Save Pointer to top of }
  MemW[CSeg:Stkofs] := Sptr + 562;        {TSR's stack.           }
  MemL[CSeg:PopUp]  := LongInt(@PopUpCode); {Save PopUpCode addr. }
  TheirFunc         := TSRFunc;           {& their TSR func. addr.}
  Writeln('Installing Stay-Resident Program: ',TSRName );
{
*****  Save intercepted interrupt vectors: $09, $16, $21, $25, $26.
}
  GetIntVec( $09, Pointer( MemL[CSeg:Bios9] ) );
  GetIntVec( $16, Pointer( MemL[CSeg:Bios16] ) );
  GetIntVec( $21, Pointer( MemL[CSeg:Dos21] ) );
  GetIntVec( $25, Pointer( MemL[CSeg:Dos25] ) );
  GetIntVec( $26, Pointer( MemL[CSeg:Dos26] ) );
{
***** Get equipment list and video mode.
}
  With Regs do begin
    Intr( $11, Regs );                  {Check equipment list For }
    NpxFlag := (AL and 2) = 2;          {math co-processor.       }
    AH      := 15;                      {Get current video mode   }
    Intr( $10, Regs );                  {and save it For when TSR }
    InitVideo := AL;                    {is activated.            }
    AH := 3; BH := 0;                   {Get current cursor size  }
    Intr( $10, Regs );                  {and save it For when TSR }
    InitCMode := CX;                    {is activated.            }
  end;  {WITH Regs}
{
***** Get info. on buffer For saving screen image.
}
  BuffSize := Sizeof( Buffer );
  TSRScrPtr := @Buffer;
{
*** Determine activation key combination.
}
  Comb := 0;  i := 1;                       {Create ptr to        }
  PlistPtr := Ptr( PrefixSeg, $80 );        {parameter list.      }
  While i < Length( PlistPtr^ ) do begin    {Check For parameters.}
    if PlistPtr^[i] = '/' then begin        {Process parameter.   }
      Inc( i );
      j := Pos( UpCase( PlistPtr^[i] ), CombChr );
      if (j > 0) and (j < 5) then Comb := Comb or (1 SHL Pred(j))
      else if j <> 0 then begin             {New activation Char. }
        Inc( i );   k := Succ( i );
        if i > Length(PlistPtr^) then KeyChr := #0
        else begin
          if ((k <= Length(PlistPtr^)) and (PlistPtr^[k] = '"'))
             or (PlistPtr^[i] <> '"') then KeyChr := PlistPtr^[i]
          else KeyChr := #0;
        end;  {else begin}
      end;  {else if ... begin}
    end; {if PlistPtr^[i] = '/'}
    Inc( i );
  end;  {While ...}
  if Comb = 0 then Comb := ShiftComb;  {Use default combination.  }
  if Comb = 0 then Comb := AltKey;     {No default, use [Alt] key.}
  ScanCode := Pos( UpCase( KeyChr ), ScanChr );  {Convert Char. to}
  if ScanCode < 2 then begin                     {scan code.      }
    ScanCode := 2;  KeyChr := '1';
  end;
  Mem[CSeg:Shft] := Comb;             {Store shift key combination}
  Mem[CSeg:Key]  := ScanCode;         {and scan code.             }
{
*** Output an installation message:  Memory used & activation code.
}
  {Writeln( 'Memory used is approximately ',
   ( ($1000 + Seg(FreePtr^) - PrefixSeg)/64.0):7:1,' K (K=1024).');
  }Writeln(
'Activate Program by pressing the following keys simultaneously:');
  if (Comb and 1) <> 0 then Write(' [Right Shift]');
  if (Comb and 2) <> 0 then Write(' [Left Shift]');
  if (Comb and 4) <> 0 then Write(' [Ctrl]');
  if (Comb and 8) <> 0 then Write(' [Alt]');
  Writeln(' and "', KeyChr, '".');
{
*** Intercept orig. interrupt vectors; then Exit and stay-resident.
}
  SetIntVec( $21, Ptr( CSeg, Our21 ) );
  SetIntVec( $25, Ptr( CSeg, Our25 ) );
  SetIntVec( $26, Ptr( CSeg, Our26 ) );
  SetIntVec( $16, Ptr( CSeg, Our16 ) );
  SetIntVec( $09, Ptr( CSeg, Our09 ) );
  SwapVectors;                           {Save turbo intr.vectors.}
  MemW[CSeg:UnSafe] := 0;                {Allow TSR to pop up.    }
  Keep( 0 );                             {Exit and stay-resident. }
end;  {TSRInstall.}
end.  {TSRUnit.}


Program TSRDemo;  {An example TSR Program created using TSRUnit.   }

{$M $0800,0,0}   {Set stack and heap size For demo Program.        }

Uses Crt, Dos, TSRUnit; {Specify the TSRUnit in the Uses statement.}
                        {Do not use the Printer Unit, instead treat}
                        {the Printer like a File; i.e. use the     }
                        {Assign, ReWrite, and Close Procedures.    }

Const  DemoPgmName : String[16] = 'TSR Demo Program';

Var
  Lst      : Text;      {Define Variable name For the Printer.     }
  TextFile : Text;      {  "        "     "    "   a data File.    }
  InsStr   : String;    {Storage For Characters to be inserted into}
                        {keyboard input stream--must be a gobal or }
                        {heap Variable.                            }

Function IOError: Boolean;    {Provides a message when an I/O error}
Var  i : Word;                {occurs.                             }
begin
  i       := Ioresult;
  IOError := False;
  if i <> 0 then begin
    Writeln('I/O Error No. ',i);
    IOError := True;
  end;
end;  {OurIoresult.}
{
***** Demo routine to be called when TSRDemo is popped up.
      be Compiled as a Far Function that returns a Word containing
      the number of Characters to insert into the keyboard input
      stream.
}
{$F+} Function DemoTasks: Word; {$F-}
Const
  FileName : String[13] = ' :TSRDemo.Dat';
  endPos = 40;
  Wx1 = 15; Wy1 = 2;   Wx2 = 65; Wy2 = 23;
Var
  Key, Drv          : Char;
  Done, IOErr       : Boolean;
  InputPos, RowNumb : Integer;
  DosVer            : Word;
  InputString       : String;

  Procedure ClearLine; {Clears current line and resets line Pointer}
  begin
    InputString := '';     InputPos := 1;
    GotoXY( 1, WhereY );   ClrEol;
  end;

begin
  DemoTasks   := 0;             {Default to 0 Characters to insert.}
  Window( Wx1, Wy1, Wx2, Wy2 ); {Set up the screen display.        }
  TextColor( Black );
  TextBackground( LightGray );
  LowVideo;
  ClrScr;                      {Display initial messages.          }
  Writeln;
  Writeln('  Example Terminate & Stay-Resident (TSR) Program');
  Writeln(' --written With Turbo Pascal 5.0 and Uses TSRUnit.');
  Window( Wx1+1, Wy1+4, Wx2-1, Wy1+12);
  TextColor( LightGray );
  TextBackground( Black );
  ClrScr;                      {Display Function key definitions.  }
  Writeln;
  Writeln('    Function key definitions:');
  Writeln('        [F1]  Write message to TSRDEMO.DAT');
  Writeln('        [F2]    "     "     to Printer.');
  Writeln('        [F3]  Read from saved screen.');
  Writeln('        [F8]  Exit and insert Text.');
  Writeln('        [F10] Exit TSR and keep it.');
  Write(  '        or simply echo your input.');

                               {Create active display Window.      }
  Window( Wx1+1, Wy1+14, Wx2-1, Wy2-1 );
  ClrScr;
                               {Display system inFormation.        }
  Writeln('TSRUnit Version: ', Hi(TSRVersion):8, '.',
                               Lo(TSRVersion):2 );
  Writeln('Video Mode, Page:', TSRMode:4, TSRPage:4 );
  Writeln('Cursor Row, Col.:', TSRRow:4, TSRColumn:4 );

  DosVer := DosVersion;
  Writeln('Dos Version:     ', Lo(DosVer):8, '.', Hi(DosVer):2 );

  InputString := '';          {Initialize Variables.               }
  InputPos    := 1;
  Done        := False;

  Repeat                      {Loop For processing keystrokes.     }
    GotoXY( InputPos, WhereY );    {Move cursor to input position. }
    Key := ReadKey;                {Wait For a key to be pressed.  }
    if Key = #0 then begin         {Check For a special key.       }
      Key := ReadKey;              {if a special key, get auxiliary}
      Case Key of                  {Byte to identify key pressed.  }

{Cursor Keys and simple editor.}
{Home}  #71: InputPos := 1;
{Right} #75: if InputPos > 1 then Dec( InputPos );
{Left}  #77: if (InputPos < Length( InputString ))
                or ((InputPos = Length( InputString ))
                    and (InputPos < endPos )) then Inc( InputPos );
{end}   #79: begin
               InputPos := Succ( Length( InputString ) );
               if InputPos > endPos then InputPos := endPos;
             end;
{Del}   #83: begin
               Delete( InputString, InputPos, 1 );
               Write( Copy( InputString, InputPos, endPos ), ' ');
             end;

{Function Keys--TSRDemo's special features.}
{F1}    #59: begin                 {Write short message to a File. }
               ClearLine;
               Repeat
                 Write('Enter disk drive:  ',FileName[1] );
                 Drv := UpCase( ReadKey );  Writeln;
                 if Drv <> #13 then FileName[1] := Drv;
                 Writeln('Specifying an invalid drive will cause your');
                 Write('system to crash.  Use drive ',
                        FileName[1], ': ?  [y/N] ');
                 Key := UpCase( ReadKey );  Writeln( Key );
               Until Key = 'Y';
               Writeln('Writing to ',FileName );
               {$I-}                         {Disable I/O checking.}
               Assign( TextFile, 'TSRDemo.Dat' );
               if not IOError then begin     {Check For error.     }
                 ReWrite( TextFile );
                 if not IOError then begin
                   Writeln(TextFile,'File was written by TSRDemo.');
                   IOErr := IOError;
                   Close( TextFile );
                   IOErr := IOError;
                 end;
               end;
               {$I+}                 {Enable standard I/O checking.}
               Writeln('Completed File operation.');
             end;  {F1}

{F2}    #60: begin {Print a message, use TSRUnit's auxiliary       }
                   {Function PrinterOkay to check Printer status.  }
               ClearLine;
               Writeln('Check Printer status, then print if okay.');
               if PrinterOkay then begin  {Check if Printer is okay}
                 Assign( Lst, 'LPT1' );   {Define Printer device.  }
                 ReWrite( Lst );          {Open Printer.           }
                 Writeln( Lst, 'Printing perFormed from TSRDemo');
                 Close( Lst );            {Close Printer.          }
               end
               else Writeln('Printer is not ready.');
               Writeln( 'Completed print operation.' );
             end;  {F2}

{F3}    #61: begin {Display a line from the saved screen image--not}
                   {valid if the TSR was popped up While the       }
                   {display was in a Graphics mode.                }
               ClearLine;
               Case TSRMode of    {Check video mode of saved image.}
                 0..3,
                 7: begin
                      {$I-}
                      Repeat
                        Writeln('Enter row number [1-25] from ');
                        Write('which to copy Characters:  ');
                        Readln( RowNumb );
                      Until not IOError;
                      {$I+}
                      if RowNumb <= 0 then RowNumb := 1;
                      if RowNumb > 25 then RowNumb := 25;
                      Writeln( ScreenLineStr( RowNumb ) );
                    end;
               else Writeln('not valid For Graphics modes.');
               end;  {Case TSRMode}
             end;  {F3}
{F8}    #66: begin {Exit and insert String into keyboard buffer.}
               ClearLine;
               Writeln('Enter Characters to insert;');
               Writeln('Up to 255 Character may be inserted.');
               Writeln('Terminate input String by pressing [F8].');
               InsStr := '';
               Repeat                     {Insert Characters into a}
                 Key := ReadKey;          {Until [F8] is pressed.  }
                 if Key = #0 then begin     {Check For special key.}
                   Key := ReadKey;          {Check if key is [F8]. }
                   if Key = #66 then Done := True; {[F8] so done.  }
                 end
                 else begin {not special key, add it to the String.}
                   if Length(InsStr) < Pred(Sizeof(InsStr)) then
                   begin
                     if Key = #13 then Writeln
                     else Write( Key );
                     InsStr := InsStr + Key;
                   end
                   else Done := True; {Exceeded Character limit.   }
                 end;
               Until Done;
               DemoTasks := Length( InsStr );  {Return no. of chr. }
               TSRChrPtr := @InsStr[1];        {Set ptr to 1st chr.}
             end;  {F8}

{F10}   #68: Done := True; {Exit and Stay-Resident.                }

      end;  {Case Key}
    end  {if Key = #0}
    else begin   {Key pressed was not a special key--just echo it. }
      Case Key of
{BS}    #08: begin  {Backspace}
               if InputPos > 1 then begin
                 Dec( InputPos );
                 Delete( InputString, InputPos, 1 );
                 GotoXY( InputPos, WhereY );
                 Write( Copy( InputString, InputPos, endPos ), ' ');
               end;
             end;  {BS}
{CR}    #13: begin  {Enter}
               Writeln;
               InputString := '';
               InputPos    := 1;
             end;  {CR}
{Esc}   #27: ClearLine;
      else
        if Length( InputString ) >= endPos then
          Delete( InputString, endPos, 1 );
        Insert( Key, InputString, InputPos );
        Write( Copy( InputString, InputPos, endPos ) );
        if InputPos < endPos then
          Inc( InputPos );
      end;  {Case...}
    end;  {else begin--Key <> #0}
    Until Done;
end;  {DemoTasks.}

begin
  TSRInstall( DemoPgmName, DemoTasks, AltKey, 'E' );
end.  {TSRDemo.}


