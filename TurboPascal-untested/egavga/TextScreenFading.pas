(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0117.PAS
  Description: Text Screen Fading
  Author: DAVE JARVIS
  Date: 08-24-94  13:36
*)

{
I recently found out that you can adjust the colours regardless of what
video mode you happen to be in.  Play around with this program ...

------------------- 8< ------------------------------------
{ Simple little program to "fade" out text on the screen.

  Feel free to play around with it ...

  Doesn't fully work, but should give you a good idea.  Note that it requires
  a VGA (or better) graphics card. }

USES CRT;
 
CONST 
  { Colour of DOS text. } 
  DOS_COLOUR = LIGHTGRAY; 
 
TYPE 
  PaletteType = RECORD 
                  R, G, B : BYTE; 
                End; 
 
VAR 
  Colour, 
  ColourCnt  : BYTE; 
  AllColours : ARRAY[ 0..63 ] OF PaletteType; 
 
BEGIN 
  FOR Colour := 0 TO 16 DO 
  Begin 
    TextColor( Colour ); 
    WriteLn( 'This is some text' );
  End; 
 
  { Read in all the colours of the palette into an array. } 
  FOR Colour := 0 TO 63 DO 
  Begin 
    { Indicate that the palette registers are going to be read } 
    Port[ $3C7 ] := 0; 
 
    AllColours[ Colour ].R := Port[ $3C9 ]; 
    AllColours[ Colour ].G := Port[ $3C9 ]; 
    AllColours[ Colour ].B := Port[ $3C9 ]; 
  End; 
 
  { Fade out any text that is on the screen. } 
  WHILE AllColours[ 61 ].B > 1 DO 
    FOR Colour := 0 TO 63 DO 
    Begin 
      Port[ $3C8 ] := Colour; 
 
      IF AllColours[ Colour ].R > 0 THEN
        DEC( AllColours[ Colour ].R ); 
 
      IF AllColours[ Colour ].G > 0 THEN 
        DEC( AllColours[ Colour ].G ); 
 
      IF AllColours[ Colour ].B > 0 THEN 
        DEC( AllColours[ Colour ].B ); 
 
      Port[ $3C9 ] := AllColours[ Colour ].R; 
      Port[ $3C9 ] := AllColours[ Colour ].G; 
      Port[ $3C9 ] := AllColours[ Colour ].B; 
 
      Delay( 10 ); 
    End; 
 
  TextColor( DOS_COLOUR ); 
 
  ClrScr; 
  WriteLn( 'Watch me fade back in ...' ); 

  FOR ColourCnt := 0 TO 42 DO 
  Begin 
    Port[ $3C8 ] := DOS_COLOUR; 
 
    Port[ $3C9 ] := ColourCnt; 
    Port[ $3C9 ] := ColourCnt; 
    Port[ $3C9 ] := ColourCnt; 
 
    Delay( 20 ); 
  End; 
END. 

