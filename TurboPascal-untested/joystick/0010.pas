
UNIT JoyStick;
(* Public Domain.  Written by Ian Hinson   November 1993 *)

INTERFACE

PROCEDURE ReadPosns;
{ Updates values of JoyA_X, JoyA_Y, JoyB_X, and JoyB_Y }

PROCEDURE ReadButtons;
{ Updates the state of all buttons }

{ Call the function for whichever button(s) you want to test
  after updating all their states with a call to ReadButtons. }
FUNCTION JoyA_Button1: BOOLEAN;
FUNCTION JoyA_Button2: BOOLEAN;
FUNCTION JoyB_Button1: BOOLEAN;
FUNCTION JoyB_Button2: BOOLEAN;
FUNCTION AnyButton: BOOLEAN;

VAR
{ These variables provide the X&Y positions after
  they have been updated by a call to ReadPositions }
JoyA_X, JoyA_Y, JoyB_X, JoyB_Y: WORD;


IMPLEMENTATION

VAR
buttons: SET OF (JoyA_1, JoyA_2, JoyB_1, JoyB_2);

PROCEDURE ReadPosns; ASSEMBLER;
   ASM
   mov ah,$84
   mov dx,1
   int $15
   mov JoyA_X,ax
   mov JoyA_Y,bx
   mov JoyB_X,cx
   mov JoyB_Y,dx
   END;

PROCEDURE ReadButtons; ASSEMBLER;
   ASM
   mov ah,$84
   mov dx,0
   int $15
   shr al,4
   xor al,$0F
   mov buttons,al
   END;

FUNCTION JoyA_Button1: BOOLEAN;
  BEGIN
    JoyA_Button1 := JoyA_1 IN buttons;
  END;

FUNCTION JoyA_Button2: BOOLEAN;
  BEGIN
    JoyA_Button2 := JoyA_2 IN buttons;
  END;

FUNCTION JoyB_Button1: BOOLEAN;
  BEGIN
    JoyB_Button1 := JoyB_1 IN buttons;
  END;

FUNCTION JoyB_Button2: BOOLEAN;
  BEGIN
    JoyB_Button2 := JoyB_2 IN buttons;
  END;

FUNCTION AnyButton: BOOLEAN;
  BEGIN
    AnyButton := buttons <> [];
  END;

END.

