{
From: COLIN CYR
Subj: Ctrl-Alt-Del...
}

UNIT CADThief;

{Intercept Control+Alternate+Delete keypresses}

INTERFACE

USES Crt,Dos;

FUNCTION GetCAD   : boolean;
FUNCTION HandleCADs: boolean;

IMPLEMENTATION

VAR
   OldInt09,OldExitProc: pointer;
   KeyStat: ^byte;
   CADStatus: boolean;

PROCEDURE GoOldInt(OldIntVector: pointer);
INLINE(
   $5B/    {POP BX - Get Segment}
   $58/    {POP AX - Get Offset}
   $89/    {MOV SP,BP}
   $EC/
   $5D/    {POP BP}
   $07/    {POP ES}
   $1F/    {POP DS}
   $5F/    {POP DI}
   $5E/    {POP SI}
   $5A/    {POP DX}
   $59/    {POP CX}
   $87/    {XCHG SP,BP}
   $EC/
   $87/    {XCHG [BP],BX}
   $5E/
   $00/
   $87/    {XCHG [BP+2],AX}
   $46/
   $02/
   $87/    {XCHG SP,BP}
   $EC/
   $CB);   {RETF}

PROCEDURE SetCAD(Status: boolean);
  BEGIN
    CADStatus := Status     {Set flag}
  END;

FUNCTION GetCAD: boolean;
  BEGIN
    GetCAD := CADStatus;
  END;

{$F+}
PROCEDURE NewExitProc;
{$F-}
 BEGIN
   ExitProc := OldExitProc;
   SetIntVec($09,OldInt09);
   CheckBreak := TRUE
 END;

{$F+}
PROCEDURE NewInt09(AX,BX,CX,DX,SI,DI,DS,ES,BP: Word); INTERRUPT;
{$F-}
 VAR
   I,J : integer;
 CONST
   KsDelCode = $53;
 BEGIN
   I := Port[$60];                   {Get Scan Code}
   if ((I and $7F) = KsDelCode) and  {DEL key?}
     ((KeyStat^ and $0C) = $0C)      {CTL + ALT ?}
     THEN
   BEGIN
     SetCAD(TRUE);
     J := Port[$61];         {Save Kbd Status}
     Port[$61] := J and $80; {Reset Kbd Int}
     Port[$61] := J and $7F;
     Port[$20] := $20;
     Sound(880);Delay(100);Sound(1220);Delay(250);NoSound;
   END
      ELSE
   GoOldInt(OldInt09)
 END;

FUNCTION HandleCADs: boolean;

VAR
   XPos,YPos: byte;
   A : char;
   Regs : Registers;

BEGIN
  WITH Regs DO   {Flush keyboard buffer}
    BEGIN
      AH := $0C;
      AL := 0;
      MsDOS(Regs)
    END;
  XPos :=WhereX;      {Save old cursor position}
  YPos := WhereY;
  GotoXY(1,1);
  WriteLn('Ctrl+Alt+Del pressed');
  Delay(250);Sound(1600);Delay(250);NoSound;
  GotoXY(1,1);WriteLn('                    ');
  GotoXY(1,1);Write('Are you sure you want to quit? ');
  A := ReadKey;Write(A);
  GotoXY(1,1);Write('                                ');
  IF UpCase(A) = 'Y' THEN
     HandleCADs := TRUE
  ELSE
     HandleCADs := FALSE;
  GotoXY(XPos,YPos);SetCAD(FALSE)
END;

PROCEDURE InstallCADHndlr;

  BEGIN
    OldExitProc := ExitProc;
    ExitProc := @NewExitProc;
    GetIntVec($09,OldInt09);
    SetIntVec($09,@NewInt09);
    SetCBreak(FALSE);
    CheckBreak := FALSE;
    KeyStat := Ptr($40,$17);
  END;

BEGIN
  InstallCADHndlr;
  SetCAD(FALSE)
END.
