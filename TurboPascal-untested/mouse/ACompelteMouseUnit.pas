(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0004.PAS
  Description: A Compelte Mouse Unit
  Author: SWAG SUPPORT TEAM
  Date: 08-17-93  08:46
*)

UNIT Mouse;

{Program:   Master Mouse Routine Library}

INTERFACE

USES DOS;

CONST

  {Button press definitions}

   PrL = 1;
   PrR = 2;
   PrLr = 3;
   PrM = 4;
   PrLM = 5;
   PrMR = 6;
   PrAll = 7;
   PrNone = 0;

  {Button definitions}

   ButtonLeft = 0;
   ButtonRight = 1;
   ButtonMiddle = 2;


FUNCTION ThereIsAMouse: Boolean;
FUNCTION MouseReset: Boolean;
FUNCTION GetMouseStatus
         (VAR MPosX, MPosY: Byte): Byte;

PROCEDURE ClearButton (Button: Byte);
PROCEDURE MouseOn;
PROCEDURE MouseOff;
PROCEDURE SetMouseSoftCursor
   (MouseChar, MouseFGColor, MouseBGColor: Byte);

IMPLEMENTATION

CONST
   MouseIntr = $33;

VAR
   MouseVisible                         : Boolean;
   MHMax, MVMax, MHCell, MVCell         : Word;
   Regs : Registers;

PROCEDURE MouseHandler (A, B, C, D: Byte);
   BEGIN
      WITH Regs DO
                        BEGIN
                                ax := A;
                                bx := B;
                                cx := C;
                                dx := D;
                                Intr(MouseIntr, Regs)
                        END
   END;

FUNCTION GetButtonUpStatus
  (Button: Byte;VAR MPosX, MPosY: Word): Boolean;

   BEGIN
      WITH Regs DO
                        BEGIN
                                ax := 6;
                                bx := Button;
                                MouseHandler(ax, bx, 0, 0);
                                MPosX := cx DIV MHCell + 1;
                                MPosY := dx DIV MVCell + 1;
                                IF ax = 0 THEN
                                        GetButtonUpStatus := TRUE
                                ELSE
                                        GetButtonUpStatus := FALSE
                        END
   END;

PROCEDURE ClearButton (Button: Byte);
VAR
   MPosX,MPosY: Word;

   BEGIN
      REPEAT UNTIL
          GetButtonUpStatus(Button, MPosX,MPosY)
   END;

FUNCTION GetMouseStatus
         (VAR MPosX, MPosY: Byte): Byte;
   BEGIN
      WITH Regs DO
                        BEGIN
                                ax := 3;
                                MouseHandler(ax, 0, 0, 0);
                                GetMouseStatus := bx;
                                MPosX := cx DIV MHCell + 1;
                                MPosY := dx DIV MVCell + 1
                        END
   END;

PROCEDURE MouseOff;
   BEGIN
      IF MouseVisible THEN
                        BEGIN
                                MouseHandler(2, 0, 0, 0);
                                MouseVisible := FALSE
                        END
   END;

PROCEDURE MouseOn;
   BEGIN
      IF NOT MouseVisible THEN
                        BEGIN
                                MouseHandler(1, 0, 0, 0);
                                MouseVisible := TRUE
                        END
   END;

FUNCTION MouseReset: Boolean;
   BEGIN
      MHMax := 639; {Max virtual horizontal pos}
      MVMax := 199; {Max virtual vertical pos}
      MHCell := 8;  {Mouse horizontal cell width}
      MVCell := 8;  {Mouse vertical cell height}
      MouseHandler(0, 0, 0, 0);
      IF Regs.ax = 0 THEN
         MouseReset := FALSE
      ELSE
         MouseReset := TRUE;
                        MouseVisible := FALSE
   END;

PROCEDURE SetMouseSoftCursor
   (MouseChar, MouseFGColor, MouseBGColor: Byte);
   BEGIN
      MouseOn;
      Regs.ax := 10;
      Regs.bx := 0; {Select software cursor}
   {Screen Mask Value (don't change character)}
      Regs.cx := $8800;
      Regs.dx := $8800 + MouseBGColor * 4096 +
                  MouseFGColor * 256 + MouseChar;
      Intr($33,Regs);
      MouseOff
   END;

FUNCTION ThereIsAMouse: Boolean;
CONST
   IRET = 207;
VAR
   MouseSegment : Word ABSOLUTE $0000:$00CE;
   MouseOffset : Word ABSOLUTE $0000:$00CC;
   MouseInstruction: Byte;
   BEGIN
      IF (MouseSegment = 0) AND
           (MouseOffset = 0) THEN
         ThereIsAMouse := FALSE
      ELSE
                        BEGIN
                                MouseInstruction :=
                   MEM[MouseSegment:MouseOffset];
                                IF MouseInstruction = IRET THEN
                                        ThereIsAMouse := FALSE
                                ELSE
                                        ThereIsAMouse := TRUE
                        END
   END;

{No initialization section}

END.

