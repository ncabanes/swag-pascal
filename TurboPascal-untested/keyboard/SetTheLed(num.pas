(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0117.PAS
  Description: Set the LED (Num
  Author: AVONTURE CHRISTOPHE
  Date: 03-04-97  13:18
*)

{

   Set the LED (NumLock, CapsLock, ...) on or off


               ╔════════════════════════════════════════╗
               ║                                        ║░
               ║          AVONTURE CHRISTOPHE           ║░
               ║              AVC SOFTWARE              ║░
               ║     BOULEVARD EDMOND MACHTENS 157/53   ║░
               ║           B-1080 BRUXELLES             ║░
               ║              BELGIQUE                  ║░
               ║                                        ║░
               ╚════════════════════════════════════════╝░
               ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

}

Procedure SetEtatLED (Interrupteur, Flag : Byte);

{ Modify the LED byte attribut

  Interrupteur = 0     Turn Off
                 1     Turn On
  Flag         = LED constant : one of the following
                 ScrollLock = 16
                 NumLock    = 32
                 CapsLock   = 64
                 Insert     = 128
}

Var Led : Byte Absolute $40:$17;

Begin

     If (Interrupteur = 1) Then
        Led := Led Or Flag
     Else
        Led := Led And Not (Flag);

     { Force BIOS to read the LED }

     Asm

       Mov Ah, 1h
       Int 16h

     End;

End;

