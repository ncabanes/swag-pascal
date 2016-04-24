(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0098.PAS
  Description: Screen Dump To File
  Author: MARTIN RICHARDSON
  Date: 05-26-94  06:18
*)

 {
   DUMPSCR.PAS
   Demo to dump a 25 line screen to disk and then restore it
   By Martin Richardson
   (This code is Public Domain... Enjoy!)
 }
 USES CRT;

 TYPE
    ScreenArray = ARRAY[1..25 * 80] OF WORD;
    ScreenPtr = ^ScreenArray;

 VAR
   _Screen: ScreenPtr;
   fHandle: FILE;
   ScreenRows: BYTE;

 BEGIN
     IF (LastMode = Mono) THEN
        _Screen := PTR( $B000, 0 )
     ELSE
        _Screen := PTR( $B800, 0 );

     ASSIGN( fHandle, 'DUMP.SCR' );

 { First we save the screen to the file DUMP.SCR }
     REWRITE( fHandle, 1 );
     BLOCKWRITE( fHandle, _Screen^, SIZEOF( _Screen^ ) );
     CLOSE( fHandle );

 { Now a little pause as we catch our breath }
     CLRSCR;
     WRITELN( 'Press any key...' );
     WHILE READKEY = #0 DO;

 { And finally we restore the screen from the file DUMP.SCR }
     RESET( fHandle, 1 );
     BLOCKREAD( fHandle, _Screen^, SIZEOF( _Screen^ ) );
     CLOSE( fHandle );

 { Another pause to view our handiwork }
     WHILE READKEY = #0 DO;
 END.


