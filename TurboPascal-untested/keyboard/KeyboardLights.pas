(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0080.PAS
  Description: Keyboard lights
  Author: FLORIAN ANSORGE
  Date: 08-24-94  13:38
*)

{
 ER> Anyway, Does anyone knows who to make the num/caps/scroll leds on the
 ER> keyboard 'flicker' or just light up?
}

PROGRAM FlashLED;

USES DOS, Crt;

CONST
  LOCKSOFF = $8F;  { Mask off all LEDs }
  SCRLOCK  = 16;
  NUMLOCK  = 32;
  CAPLOCK  = 64;

VAR
  KeyLocks  : BYTE ABSOLUTE $0040:$0017;  { LED bits at this FAR address }
  SaveLock  : BYTE;                       { Used to save LED status bits }

{ To make DOS cause LED update }
PROCEDURE DummyDosCall; ASSEMBLER;
asm
  mov ah, 11
  int $21
End;

VAR
  Shift : BYTE;                    { Used in bit shifting of LEDs }

BEGIN
  { Store current state }
  SaveLock := KeyLocks;
  Shift    := 1;

  Repeat
    { Turn on the LED bit according to Shift }
    KeyLocks := (SCRLOCK SHL Shift);

    { Set Shift to indicate the LED to the right }
    Shift := (Shift + 1) MOD 3;

    { Allow DOS to update the LEDs }
    DummyDosCall;

    { Simple pause }
    Delay( 200 );
  Until KeyPressed;

  { Restore original keyboard state }
  KeyLocks := SaveLock;
END.

