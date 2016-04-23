{
>  Does anybody know of a way to reWrite the keyboard routines, to be abl
>  to read several keys at once? ReadKey will only read the last keypress
>  anything else I've tried can only read the last key you have pressed d
>
>  For example, in many games it will let you move Forward (With the Forw
>  arrow key) and shoot at the same time, With the space bar...Any sugges
}

Unit POLL ;         { polled keyboard handler }
                    { does not support F11 or F12 keys } Interface

Const
   EscKey = 1 ;    { key codes }
   aKey = 30 ;     { see TP 6 Programmers guide p 354 }
   sKey = 31 ;
   endKey = 79 ;
   DownKey = 80 ;

Var
   KeyTable : Array[ 1..127 ] of Boolean ; { KeyTable[ x ] is True when key x
is pressed } { and stays True Until key x is released }

Implementation

Uses Dos, KeyIntr ;  { keyboard interrupt support }

Var
   OldInt09 : Pointer ;
   ExitSave : Pointer ;

{$F+} Procedure RestoreInt09 ;
begin
   ExitProc := ExitSave ;
   SetIntVec( $09, OldInt09 ) ;
end ;

{$F+} Procedure NewInt09 ; interrupt ;
Var
   ScanCode : Byte ;
   KeyCode : Byte ;
begin
   STI ;
   ScanCode := ReadScanCode ;
   KeyCode := ScanCode and $7F ;        { strip make/break bit }
   KeyTable[ KeyCode ] := ( ScanCode and $80 ) = 0 ; (* { For non C Programmers
}
   if ( ScanCode and $80 ) = 0  then    { make code -- key pressed }
      KeyTable[ KeyCode ] := True
   else                                 { break code -- key released }
      KeyTable[ KeyCode ] := False ;
*)
   ResetKeyboard ;
   EOI ;
end ;

Var
   N : Byte ;

begin
   ExitSave := ExitProc ;
   ExitProc := addr( RestoreInt09 ) ;

   For N := 1 to 127 do            { no key pressed }
      KeyTable[ N ] := False ;

   GetIntVec( $09, OldInt09 ) ;
   SetIntVec( $09, addr( NewInt09 ) ) ;
end.
{---------------------------------------------} Program TwoKeys;

Uses Crt, Poll ;  { polled keyboard handler } { ----- this Program will
probably hang a debugger ----- } Var
   X, Y : Byte ;
begin
   ClrScr ;
   X := 40 ;
   Y := 12 ;

   WriteLn( 'Hit keys A S  and  1 2 on the keypad' ) ;
   WriteLn( ' -- Esc to stop' ) ;

   While not KeyTable[ EscKey ] do
   begin
      GotoXY( X, Y ) ;
      Write( ' ' ) ;

{ poll the KeyTable }
      if KeyTable[ endKey ] and ( X > 1 ) then  Dec( X ) ;
      if KeyTable[ DownKey ] and ( X < 80 ) then  Inc( X ) ;
      if KeyTable[ aKey ] and ( Y > 4 ) then  Dec( Y ) ;
      if KeyTable[ sKey ] and ( Y < 24 ) then  Inc( Y ) ;

      GotoXY( X, Y ) ;
      Write( chr( 1 ) ) ;
      Delay( 10 ) ;
   end ;
end.
