{
AC>I got my hands on Jare's fire code and thought it was pretty cool,
AC>so I made my own fire program. Although it didn't turn out like I
AC>thought it would (like Jare's) what I have is (at least I think so)
AC>something that looks more realistic.

This is kinda funny... just the other day I was looking at Jare's fire
code, and did an 80x50 textmode version of it in C.  I did a quick and
dirty conversion of it to Pascal so I could post it here for you
(don't you feel special? <G>).  The pascal version came out a bit
slower then my C version, although they are very similar. I haven't
figured out why though... most times I try this, both come out close
to the same speed.

(********************************************************************
 Fire by Eric Coolman (aka. Digitar/SKP), Simple Minded Software
 Much like Jare's (VangelisTeam) fire, but uses 80x50x16 text mode
 rather than 320x200x256 (which was "tweaked" to look like 80x50
 text mode).  Reference : FIRE.TXT by Phil Carlisle (aka Zoombapup,
 CodeX) from PC Game Programmer's Encyclopedia (PCGPE10.ZIP) by Mark
 Feldman and contributers (thanks for the great reads guys!).
 Compiler : Turbo Pascal 6.0
 Released to public domain, July 30, 1994.

 NOTE: FirePalette will not get loaded if running under DESQview
       with "VIRTUALIZE TEXTMODE" on (which will stop any palette
       manipulation).  To fix, go into setup for the DOSBOX, and
       under "VIRTUALIZE TEXT/GRAPHICS" mode, and set it to "N".
       Also for DV, set "WRITES DIRECT TO SCREEN" to "Y"es.
********************************************************************)
}

Program tFire;

const
    MAXX = 80;
    MAXY = 50;
    { Our gradient firepalette (white/yellow/red/orange/slate/black) }
    FirePal : array[0..3*16-1] of byte =
      {       [ HUES ]       }
      {  RED    GREEN   BLUE }
      {  ===    =====   ==== }
      (                                               { Normal Color }
         0,     0,      0,                            { BLACK        }
         0,     5,      3,                            { BLUE         }
         0,     6,      7,                            { GREEN        }
         0,     7,      9,                            { CYAN         }
         0,     8,      11,                           { RED          }
         0,     9,      12,                           { MAGENTA      }
         63,    13,     0,                            { BROWN        }
         60,    4,      4,                            { LIGHTGRAY    }
         63,    58,     21,                           { DARKGRAY     }
         63,    59,     0,                            { LIGHTBLUE    }
         63,    60,     0,                            { LIGHTGREEN   }
         63,    60,     0,                            { LIGHTCYAN    }
         63,    61,     30,                           { LIGHTRED     }
         63,    55,     42,                           { LIGHTMAGENTA }
         63,    60,     55,                           { YELLOW       }
         63,    63,     63                            { WHITE        }
     );

type
     ColorArray = array [0..MAXX+1, 0..MAXY] of Byte;
var
    FireImage : ColorArray;
    CUR       : Word;                                { working color }
    x, y      : Byte;                             { general counters }

(*
 Sets video mode.  If mode is 64d (40h), 8x8 ROM font will be loaded
 and 80x50 textmode will be activated.  Any other value will set
 mode normally.
*)
procedure VidMode(mode : byte); assembler;
asm
     cmp  mode, 40h                      { (64d) want 80x50/43 mode? }
     jnz  @normalset
     mov  ax,1112h                { set 8 point font as current font }
     mov  bl,00h
     jmp  @MakeItSo                                            { ;-) }
   @normalset:
     mov  ah, 00h
     mov  al, mode
   @MakeItSo:
     int  10h
end;

{ grabs and dumps keypress...returns 1 if a key was hit, else 0 }
function KbGrab : boolean;
var
    WasHit : boolean;
begin
    WasHit := False;

    asm
        mov ax, 0100h
        int 16h
        lahf
        test ah, 40h
        jnz @done
        inc WasHit
        mov ax, 0000h                  { grab the key they hit .... }
        int 16h
      @done:
    end;
    KbGrab := WasHit;
end;

(*********************************************************************
 sets only color indexes normally used in textmode (16 of 'em).
 Note the heavy use of ternary operator there... what that means
 is - indexes 7 to 15 (dark gray to white) are actually indexes
 55 to 63, and index 6 (dark brown) is actually 20d (14h) because
 it uses the secondary hues so that it doesn't look too much like
 red.  The rest (0,1,2,4,5,7) are as expected.
*********************************************************************)
procedure SetFirePal;
var
  i, j : Byte;
begin
   for i:= 0 to 16 do                               { for each index }
     begin
       if i <= 7 then begin if i = 6 then j := 20 else j := i; end
       else j := i+48;
       port[$3c8] := j;                             { Send the index }
       port[$3c9] := FirePal[i*3];                    { Send the red }
       port[$3c9] := FirePal[i*3+1];                { Send the green }
       port[$3c9] := FirePal[i*3+2];                 { Send the blue }
    end;
end;


(*********************************************************************
  +----+-----+----+ Table to left are screen ofs's surrounding CUR(0).
  |-81 | -80 |-79 | That we will take average of. 80 is for width of
  +----+-----+----+ screen in chars in textmode (also width of our
  | -1 | CUR | +1 | screen buffer).  The calculated average will be
  +----+-----+----+ assigned to spot '-80' to move the fire upwards,
  |+79 | +80 |+81 | and decremented to fade it out (like a plasma
  +----+-----+----+ effect somewhat).
*********************************************************************)
procedure DoFire;
begin;
    { start at [1,1] or above because 0,0 doesn't have 8 surrounding }
    { stop x at 78 or less for the same reason (ending y doesn't     }
    { matter cause we are setting max y randomly anyways).           }
    { (starting y can be set to 8 to give room for a scroller).      }
     for y := 1 to MAXY do
       for x := 1 to MAXX-1 do
         begin
          { get average of 8 surrounding colors              (-ofs-) }
          CUR := (  FireImage[x-1][y]         { direct to left  (-1) }
                  + FireImage[x+1][y]         { direct to right (+1) }
                  + FireImage[x][y-1]         { direct above   (-80) }
                  + FireImage[x][y+1]         { direct below   (+80) }
                  + FireImage[x-1][y-1]       { above to left  (-81) }
                  + FireImage[x+1][y+1]       { below to right (+81) }
                  + FireImage[x+1][y-1]       { above to right (-79) }
                  + FireImage[x-1][y+1]       { below to left  (+79) }
                ) shr 3;                      { divide by 8          }
         Dec(CUR);                            { make fire fade out   }
         { notice below is assigning the average CUR to (CUR-1 line) }
         { ... this keeps fire moving in upward direction.           }
         FireImage[x][y-1] := CUR;                       { set color }
         mem[$b800:y*160+(x shl 1)+1] := FireImage[x][y];
       end;

       { Randomly set last line of fire... This keeps the fire going }
      for x := 0 to 80 do
         FireImage[x][49] := (random(255)+1);
      { second last line also to give fire some more height. }
      for x := 0 to 80 do
         FireImage[x][48] := (random(255)+1);
end;

begin
   VidMode($03);                     { 80x25 mode (to clear screen) }
   VidMode($40);                                       { 80x50 mode }

   SetFirePal;

  { change to hi-intense background so we have 16 bg colors to }
  { work with.                                                 }
  asm
      mov ax, 1003h                                 { blinking attr }
      mov bx, 0000h            { 0=HiIntBackground, 1=Blinking Attr }
      int 10h
  end;

  { clear fire image }
  fillchar(FireImage, sizeof(FireImage), 63);     { fill with white }

  for x := 0 to 80 do          { set up last line to start the fire }
    FireImage[x][49] := (random(255)+1);

  repeat DoFire; until KbGrab;

  VidMode($03);                                        { 80x25 mode }
end.
