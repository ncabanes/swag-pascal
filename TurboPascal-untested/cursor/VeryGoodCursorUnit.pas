(*
  Category: SWAG Title: CURSOR HANDLING ROUTINES
  Original name: 0019.PAS
  Description: Very GOOD Cursor Unit
  Author: JON JASIUNAS
  Date: 11-02-93  17:47
*)

{
From: JON JASIUNAS
Subj: Cursor Stuff

Here's a bit of code that will hide / unhide the cursor, without using
assembler: }

uses
  Dos;

var
  R: Registers;

procedure HideCursor;
begin   { HideCursor }
  R.AH := $03;    {- Current cursor status }
  Intr($10, R);
  R.AH := $01;    {- Set cursor }
  R.CH := R.Ch or $20;
  Intr($10, R);
end;    { HideCursor }

procedure ShowCursor;
begin   { ShowCursor }
  R.AH := $03;
  Intr($10, R);
  R.AH := $01;
  R.CH := R.CH and $1F;
  Intr($10, R);
end;    { ShowCursor }

{ However, if you want to use assembler, you can, and you don't need the
  DOS unit.  Here's my Cursor modification unit (in assembler), if you're
  interested. }

{****************************
 *     CURSOR.PAS v1.0      *
 *                          *
 *  General purpose cursor  *
 *  manipulation routines   *
 ****************************

1992-93 - HyperDrive Software
Released into the Public Domain.}

{$S-,R-,D-}
{$IFOPT O+}
  {$F+}
{$ENDIF}

unit Cursor;

{\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\}
                                   interface
{/////////////////////////////////////////////////////////////////////////////}

const
  csLine  = $01;
  csHalf  = $02;
  csBlock = $03;

procedure DefineCursor(Size: Byte);
procedure GotoXy(X, Y: Byte);
procedure RestoreCursor;
procedure HideCursor;
procedure ShowCursor;
function  CursorHidden: Boolean;

{\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\}
                                 implementation
{/////////////////////////////////////////////////////////////////////////////}

var
  dcStart, dcEnd: Byte;

{=============================================================================}

procedure DefineCursor(Size: Byte);  ASSEMBLER;
asm     { DefineCursor }
  mov   AH, $0F
  int   $10
  cmp   AL, $07
  jne   @Color

@Mono:
  mov   AH, $03
  int   $10
  cmp   Size, csLine
  je    @MonoL
  cmp   Size, csHalf
  je    @MonoH
  cmp   Size, csBlock
  je    @MonoB
@MonoL:
  mov   CH, $0C
  jmp   @MonoDone
@MonoH:
  mov   CH, $07
  jmp   @MonoDone
@MonoB:
  mov   CH, $00
@MonoDone:
  mov   CL, $0D
  jmp   @Done

@Color:
  mov   AH, $03
  int   $10
  cmp   Size, csLine
  je    @ColorL
  cmp   Size, csHalf
  je    @ColorH
  cmp   Size, csBlock
  je    @ColorB
@ColorL:
  mov   CH, $06
  jmp   @ColorDone
@ColorH:
  mov   CH, $04
  jmp   @ColorDone
@ColorB:
  mov   CH, $00
@ColorDone:
  mov   CL, $07

@Done:
  mov   AH, $01
  int   $10
end;    { DefineCursor }

{-----------------------------------------------------------------------------}

procedure GotoXy(X, Y: Byte);  ASSEMBLER;
asm     { GotoXy }
  mov   AH, $0F
  int   $10
  mov   AH, $02
  dec   Y
  mov   DH, Y
  dec   X
  mov   DL, X
  int   $10
end;    { GotoXy }

{-----------------------------------------------------------------------------}

procedure RestoreCursor;  ASSEMBLER;
asm     { RestoreCursor }
  mov   AH, $01
  mov   CH, dcStart
  mov   CL, dcEnd
  int   $10
end;    { RestoreCursor }

{-----------------------------------------------------------------------------}

procedure HideCursor;  ASSEMBLER;
asm     { HideCursor }
  mov   AH, $03
  int   $10
  mov   AH, $01
  or    CH, $20
  int   $10
end;    { HideCursor }

{-----------------------------------------------------------------------------}

procedure ShowCursor;  ASSEMBLER;
asm     { ShowCursor }
  mov   AH, $03
  int   $10
  mov   AH, $01
  and   CH, $1F
  int   $10
end;    { ShowCursor }

{-----------------------------------------------------------------------------}

function  CursorHidden: Boolean; ASSEMBLER;
asm     { CursorHidden }

  mov   AH, $03
  int   $10
  cmp   CH, $20
  je    @Hidden
  mov   AL, $00
  jmp   @End
@Hidden:
  mov   AL, $01;
@End:
end;    { CursorHidden }

{-----------------------------------------------------------------------------}
                                {** PRIVATE **}
{-----------------------------------------------------------------------------}

procedure SaveCursor;  ASSEMBLER;
asm     { SaveCursor }
  mov   AH, $03
  int   $10
  mov   dcStart, CH
  mov   dcEnd, CL
end;    { SaveCursor }

{=============================================================================}
{$F+}

var
  OldExitProc: Pointer;

procedure NewExitProc;
begin
  ExitProc := OldExitProc;
  RestoreCursor;               {- Restore startup cursor mode }
end;    { NewExitProc }

{$F-}
{=============================================================================}

begin   { Cursor }
  OldExitProc := ExitProc;
  ExitProc    := @NewExitProc;
  SaveCursor;                  {- Save startup cursor mode }
end.    { Cursor }

