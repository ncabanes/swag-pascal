{
Author : GREGORY P. SMITH

> Is there any way to detect OS/2 (in a Dos box) sessions and Windows
> Sessions? I'd like to throw in support For these multitaskers so I can
> run an idlekey Program.

Actual code is always the best example For me..  Look at this Unit (and use
it, I think you'll like it).  Check With someone else if you want to
specifically detect winslows.  This Unit will, however, give up time to any
multitasker.
}

(* Public Domain Unit by Gregory P. Smith, No Rights Reserved *)
(* ...  This also means no guarantees  ... *)

Unit OS_Test; { DESQview, OS/2, & 386 v86 machine Interfaces }

{$X+,S-,R-,F-,O-,D-,G-} { extended syntax, nothing else }

Interface

Const
  In_DV  : Boolean = False; { are we in DESQview? }
  In_VM  : Boolean = False; { are we in a 386+ virtual machine? }
  In_OS2 : Boolean = False; { are we in OS/2? }

Function  OS2_GetVersion: Word; { Get OS/2 version # }
Function  DV_GetVersion: Word; { update In_DV and get version # }
Function  DV_Get_Video_Buffer(vseg:Word): Word; { get the alt video buffer }
Procedure DV_Pause; { give up time slice }
Procedure MT_Pause; Inline($cd/$28); { give up time in most multitaskers }
Procedure KillTime; { Release time in any situation }
Procedure DV_begin_Critical; { don't slice away }
  Inline($b8/$1b/$10/$cd/$15);
Procedure DV_end_Critical; { allow slicing again }
  Inline($b8/$1c/$10/$cd/$15);
Procedure DV_Sound(freq,dur:Integer); { Create a Sound in the Bkg }

Implementation

Function OS2_GetVersion: Word; Assembler;
Asm
  MOV    AH, 30h  { Dos Get Version Call }
  INT    21h      { AL = major version * 10, AH = minor version }
  MOV    BH, AH   { save minor version }
  xor    AH, AH
  MOV    CL, 10
  div    CL       { divide by 10 to get the major version }
  MOV    AH, BH   { restore minor version }
  XCHG   AH, AL   { AH = major, AL = minor }
end;

Function DV_GetVersion: Word; Assembler;
Asm
  MOV    CX,'DE'     { CX+DX to 'DESQ' (invalid date) }
  MOV    DX,'SQ'
  MOV    AX,02B01H   { Dos' set date funct. }
  INT    21H         { call Dos }
  CMP    AL,0FFH     { Was it invalid? }
  JE     @No_dv      { yep, no dv }
  MOV    AX,BX       { AH=major AL=minor }
  MOV    In_DV,1     { Set In_DV flag }
  JMP    @DvGv_x     { other routines }
 @No_dv:
  xor    AX,AX       { Return 0 or no DV }
 @DvGv_x:
end; { DV_GetVersion }

Function DV_Get_Video_Buffer(vseg:Word): Word; Assembler;
Asm                      { Modified by Scott Samet April 1992 }
  CALL   DV_GetVersion   { Returns AX=0 if not in DV }
  MOV    ES,vseg         { Put current segment into ES }
  TEST   AX,AX           { In DV? }
  JZ     @DVGVB_X        { Jump if not }
  MOV    AH,0FEH         { DV's get video buffer Function }
  INT    10H             { Returns ES:DI of alt buffer }
 @DVGVB_X:
  MOV    AX,ES           { Return video buffer }
end; { DV_Get_Video_Buffer }

Procedure DV_Pause;
begin
  if In_DV then
  Asm
    MOV AX, 1000h    { pause Function }
    INT 15h
  end;
end; { DV_Pause }

Procedure KillTime;
begin
  if In_VM then
  Asm
    MOV AX, 1680h    { give up VM time slice }
    INT 2Fh
  end
  else
  if In_DV then
  Asm
    MOV AX, 1000h    { DV pause call }
    INT 15h
  end
  else
    MT_Pause;      { Dos Idle call }
end;

(* Procedure DV_begin_Critical; Assembler;
Asm
  MOV AX,$101B       { DV begin critical Function }
  INT 15h
end; { DV_begin_Critical }

Procedure DV_end_Critical; Assembler;
Asm
  MOV AX,$101C       { DV end critical Function }
  INT 15h
end; { DV_end_Critical }  *)

Procedure DV_Sound(freq,dur:Integer); Assembler; { Sound a tone }
Asm
  MOV   AX,1019H
  MOV   BX,freq  { frequency above 20 Hz }
  MOV   CX,dur   { duration in clock ticks }
  INT   15H
end;

{ ** -- initalization -- ** }

begin
  DV_GetVersion; { discard answer.  Just update In_DV }
  Asm
    MOV AX, 1680h
    INT 2Fh          { Gives up time slice in most 386+ virtual machines }
    not AL           { AL = 00h if supported, remains 80h if not }
    MOV CL, 7
    SHR AL, CL       { move bit 7 to bit 0 For a Boolean }
    MOV In_VM, AL    { update the flag }
  end;
  In_OS2 := (OS2_GetVersion >= $0100); { version 1.0 or greater }
end.

