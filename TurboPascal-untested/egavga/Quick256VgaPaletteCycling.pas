(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0149.PAS
  Description: Quick 256 VGA Palette Cycling
  Author: TAPIO AIJALA
  Date: 11-26-94  04:58
*)

{
> Any one out there have code to do this
>
> Rotate_PAL_Up(count : byte; from,to: byte):
>   ie.  Rotate_Pal_Up(10,100,120);
>   will rotate the pal up 10 times between the ranges of 100   and 12
> back after 120...
>
> Rotate_Pal_Down(c,f,t : byte);  basicly same as abov! Thanks!

You asked for the palette cycling routine, here you are! As you can see,
there is NO cycling routine in this piece of code which does all the job.
There are several smaller routines (GetRGB, SetRGB etc.) and then the actual
cycling routine which uses other smaller routines. That's because all these
routines are from my own vga util library and I was too lazy to put them to
together to a one piece of code... :)
}

Program CyclePaletteExample;

Uses crt;

Type  PaletteType                 = Record
       red                        : Byte;
       green                      : Byte;
       blue                       : Byte;
      End;

Var   rgb                         : PaletteType;
      pal                         : Array [0..255] of PaletteType;

Var   aa1                         : Word; {Some temp variables}
      aa5                         : Byte;

Procedure SetRGB(col, r, g, b : Byte);

Begin
 ASM
  CLI
 END;
 Port[$3C8] := col;
 Port[$3C9] := r;
 Port[$3C9] := g;
 Port[$3C9] := b;
 ASM
  STI
 END;
End;

Procedure GetRGB(col : Byte);

Begin
 Port[$3C7] := col;
 rgb.red := Port[$3C9];
 rgb.green := Port[$3C9];
 rgb.blue := Port[$3C9];
End;

Procedure SetPalette;

Begin
 For aa5 := 0 to 255 Do SetRGB(aa5,pal[aa5].red,pal[aa5].green,pal[aa5].blue);
End;

Procedure GetPalette;

Begin
 For aa5 := 0 to 255 Do Begin
  GetRGB(aa5);
  pal[aa5] := rgb;
 End;
End;

Procedure CyclePalette(s, e, n, d : Byte);

Var c1 : PaletteType;

Begin
 If d = 1 then Begin
  aa1 := 0;
  Repeat
   c1 := pal[e];
   For aa5 := e downto s + 1 Do Begin
    pal[aa5] := pal[aa5 - 1];
   End;
   pal[s] := c1;
   Inc(aa1);
   SetPalette; {Sets cycled palette}
  Until aa1 = n;
 End;
 If d = 2 then Begin
  aa1 := 0;
  Repeat
   c1 := pal[s];
   For aa5 := s to e - 1 Do Begin
    pal[aa5] := pal[aa5 + 1];
   End;
   pal[e] := c1;
   Inc(aa1);
   SetPalette; {Sets cycled palette}
  Until aa1 = n;
 End;
End;

Begin
 ASM
  MOV  AX,$13 {Video mode is now 13h = 320 x 200 and 256 colors}
  INT  $10
 End;
 For aa1 := 0 to 255 Do Mem[$A000:aa1] := aa1; {Draw 255 pixels}
 GetPalette; {Loads palette from vga's registers}
 Repeat
  CyclePalette(1,255,1,1); {Palette cycling!}
 Until KeyPressed; {Press any key to continue! :)}
 ASM
  MOV  AX,$3 {Back to the text mode}
  INT  $10
 End;
End.

{
Example:

CyclePalette(120, 140, 10, 1) would rotate colors between the ranges
120 and 140 10 times.

The last parameter (d) is the direction of palette rotation:

1       From the first specified color to the last specified color
2       From the last specified color to the first specified color
}

