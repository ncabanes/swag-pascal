(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0017.PAS
  Description: Display MAKE/BREAK codes
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:49
*)

PROGRAM ScanCode ;      { display MAKE and BREAK scan codes }

USES Crt, Dos, KeyIntr ;      { keyboard interrupt support }

{ ----- this program will probably hang a debugger ----- }

Var
   OldInt09 : Pointer ;
   ExitSave : Pointer ;

{$F+} Procedure RestoreInt09 ;
Begin
   ExitProc := ExitSave ;
   SetIntVec( $09, OldInt09 ) ;
End ;

{$F+} Procedure NewInt09 ; Interrupt ;   { return scan code as key's value }
Var
   ScanCode : Byte ;
   BufferFull : Boolean ;

Begin
   EnableInterrupts ;
   ScanCode := ReadScanCode ;
   ResetKeyboard ;
   BufferFull := Not StoreKey( ScanCode, ScanCode ) ;
   EOI ;
   If BufferFull then
   Begin
      Sound( 880 ) ;
      Delay( 100 ) ;
      Sound( 440 ) ;
      Delay( 100 ) ;
      NoSound ;
   End ;
                { variation : move the EOI before the beep to after it }
                {      note the difference when the keyboard overflows }
End ;

{ see Turbo Pascal 5.0 reference p 450 for a list of scan codes }
{                  6.0 programmers guide p 354                  }

Var
   N  : Byte ;

BEGIN
   ExitSave := ExitProc ;
   ExitProc := @RestoreInt09 ;
   GetIntVec( $09, OldInt09 ) ;
   SetIntVec( $09, @NewInt09 ) ;

   WriteLn( '   Display "make" and "break" scan codes ' ) ;
   WriteLn ;
   WriteLn( '   Hit the <Esc> key to exit ' ) ;
   Repeat
      Delay( 400 ) ;               { make it easy to overrun keyboard }
      N := Ord( ReadKey ) ;        { n is the scan code from NewInt09 }
      If N < 128 then
         WriteLn( 'Make  ', n )
      Else
         WriteLn( '    Break  ', n - 128 ) ;
   Until n = 1 ;      { the make code for Esc }
END.

