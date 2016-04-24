(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0004.PAS
  Description: Prevent Ctl/Alt/Del Keys
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  14:09
*)

PROGRAM NoBoot ;
{$M 1024, 0, 0 }     { TSR : reserve 1K stack no heap   }
{$S-}                { Needed in a TSR }

Uses
   Crt,    { Sound }
   Dos,
   KeyIntr ;

Var
   OldInt09 : Pointer ;

{$F+}
Procedure NewInt09 ; Interrupt ;
Begin
   EnableInterrupts ;                        { Delete key }
   If ControlPressed and AltPressed and (ReadScanCode = $53) then
   Begin
      ResetKeyboard ;                         { Ignore key }
      EOI ;

      Sound( 880 ) ;                          { optional }
      Delay( 100 ) ;
      Sound( 440 ) ;
      Delay( 100 ) ;
      NoSound ;

   End
   Else
      CallInterrupt( OldInt09 ) ;
End ;

BEGIN
   GetIntVec( $09, OldInt09 ) ;
   SetIntVec( $09, Addr(NewInt09) ) ;
   Keep( 0 ) ;                                 { make this a TSR }
END.

