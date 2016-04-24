(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0094.PAS
  Description: High Intensity Background
  Author: DARRYL FRIESEN
  Date: 01-27-94  17:46
*)

UNIT Lite;
{***************************************************************************}
{*                                                                         *}
{*  Unit Lite - Routines to produce high intensity backgrounds             *}
{*                                                                         *}
{*                         AUTHOR:  Darryl Friesen                         *}
{*                        CREATED:  01-JUN-1991                            *}
{*                  LAST MODIFIED:  06-JAN-1992                            *}
{*                CURRENT VERSION:  Version 1.0.1                          *}
{*                 COMPILED USING:  Turbo Pascal 6.0                       *}
{*                                                                         *}
{*                                                                         *}
{*  UNIT DEPENDANCIES:                                                     *}
{*                                                                         *}
{*           INTERFACE:  [none]                                            *}
{*      IMPLEMENTATION:  DOS                                               *}
{*                                                                         *}
{***************************************************************************}
{*                                                                         *}
{*  REVISION HISTORY                                                       *}
{*  ----------------                                                       *}
{*  01-JUN-1991  - Creation of VERSION 1.00                                *}
{*  06-JAN-1992  - Version 1.0.1                                           *}
{*                   Fixed a bug in the BlinkOn routine.  On a VGA machine *}
{*                   the blink state was turned off instead of on.         *}
{*                                                                         *}
{***************************************************************************}

{=========================================================================}
INTERFACE
{=========================================================================}

Procedure BlinkOff;
Procedure BlinkOn;
Function  EGA: Boolean;


{=========================================================================}
IMPLEMENTATION
{=========================================================================}

USES DOS;


{================================================================}
PROCEDURE SetBlinkState(State : BOOLEAN);
{================================================================}
{================================================================}

VAR
  ModeReg     : BYTE;
  ModeRegPort : WORD;

Begin
   INLINE($FA); { CLI }
   ModeRegPort:=MEMW[$0040:$0063]+4;
   ModeReg:=MEM[$0040:$0065];
   If State Then
     ModeReg:=ModeReg OR $20
   Else
     ModeReg:=ModeReg AND $DF;

   Port[ModeRegPort] := ModeReg;
   MEM[$0040:$0065]:= ModeReg;
   INLINE($FB) { STI }
END;


{================================================================}
FUNCTION EGA : BOOLEAN;
{================================================================}
{================================================================}

VAR
  Regs : Registers;

Begin
  Regs.AH:=$12;
  Regs.BX:=$FF10;
  INTR( $10, Regs );
  EGA := (Regs.BX AND $FEFC=0)
End;


{================================================================}
PROCEDURE SetEGABlinkState(State : BOOLEAN);
{================================================================}
{================================================================}

VAR
  Regs: Registers;

Begin
  Regs.AX := $1003;
  Regs.BL := ORD(State);
  INTR( $10, Regs )
End;


{================================================================}
PROCEDURE BlinkOn;
{================================================================}
{================================================================}

Begin
  If EGA Then
    SetEGABlinkState(TRUE)
  Else
    SetBlinkState(TRUE)
End;


{================================================================}
PROCEDURE BlinkOff;
{================================================================}
{================================================================}

Begin
  If EGA Then
    SetEGABlinkState(FALSE)
  Else
    SetBlinkState(FALSE)
End;


{=========================================================================}

End.

