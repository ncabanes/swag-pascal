(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0165.PAS
  Description: Full 256/16 Colour Fading
  Author: JANNES DROST
  Date: 11-26-94  04:58
*)

unit Fading;
interface
uses Crt;

type
  Palette256 = array[0..255, 0..2] of Byte;
  Palette16 = array[0..15, 0..2] of Byte;

procedure SetVGAPalette256(PalBuf: Palette256);
procedure GetVGAPalette256(var PalBuf: Palette256);
procedure SetVGAPalette16(PalBuf: Palette16);
procedure GetVGAPalette16(var PalBuf: Palette16);
procedure FadeOutScreen256;
procedure FadeOutScreen16;
procedure FadeInScreen256(PalToMake: Palette256);
procedure FadeInScreen16(PalToMake: Palette16);

implementation

procedure SetVGAPalette256(PalBuf: Palette256);
var
  ColorOn : byte;

begin
  Port[$3C8] := 0;
  for ColorOn := 0 to 255 do
      begin
      Port[$3C9] := PalBuf[ColorOn, 0];
      Port[$3C9] := PalBuf[ColorOn, 1];
      Port[$3C9] := PalBuf[ColorOn, 2];
      end;
end; {Sets entire VGA palette.}

procedure GetVGAPalette256(var PalBuf: Palette256);
var
  ColorOn : byte;

begin
  Port[$3C8] := 1;
  for ColorOn := 0 to 255 do
      begin
      PalBuf[ColorOn, 0] := Port[$3C9];
      PalBuf[ColorOn, 1] := Port[$3C9];
      PalBuf[ColorOn, 2] := Port[$3C9];
      end;
  PalBuf[0, 0] := 0; {Color 0 doesn't read right.  I've tried}
  PalBuf[0, 1] := 0; {Changing the $3C8 assigment and fooling with}
  PalBuf[0, 2] := 0; {the loop, with no success.   Help!}
end; {Reads entire VGA palette (except color 0)}

procedure SetVGAPalette16(PalBuf: Palette16);
{I find this a convenient seperate procedure.  You may not need it.}
var
  ColorOn : byte;

begin
  Port[$3C8] := 0;
  for ColorOn := 0 to 15 do
      begin
      Port[$3C9] := PalBuf[ColorOn, 0];
      Port[$3C9] := PalBuf[ColorOn, 1];
      Port[$3C9] := PalBuf[ColorOn, 2];
      end;
end; {Sets entire palette for 16 colors}

procedure GetVGAPalette16(var PalBuf: Palette16);
var
  ColorOn : byte;

begin
  Port[$3C8] := 1;
  for ColorOn := 0 to 15 do
      begin
      PalBuf[ColorOn, 0] := Port[$3C9];
      PalBuf[ColorOn, 1] := Port[$3C9];
      PalBuf[ColorOn, 2] := Port[$3C9];
      end;
  PalBuf[0, 0] := 0; {Same deal as GetVGAPalette256.}
  PalBuf[0, 1] := 0;
  PalBuf[0, 2] := 0;
end; {Reads entire 16 color palette}

procedure FadeOutScreen256;
   var
     Count        : word;
     ColorOn      : byte;
     PalToMake    : Palette256;
     PaletteStuff : Palette256;

   begin
   GetVGAPalette256(PaletteStuff);
   PalToMake := PaletteStuff;
   for Count := 63 downto 0 do
       begin
       Port[$3C8] := 0;
       PaletteStuff := PalToMake;
       Delay(1);
       for ColorOn := 0 to 255 do
           begin
           PaletteStuff[ColorOn, 0] := (PaletteStuff[ColorOn, 0] * Count) div
63;           PaletteStuff[ColorOn, 1] := (PaletteStuff[ColorOn, 1] * Count)
div 63;           PaletteStuff[ColorOn, 2] := (PaletteStuff[ColorOn, 2] *
Count) div 63;           Port[$3C9] := PaletteStuff[ColorOn, 0];
           Port[$3C9] := PaletteStuff[ColorOn, 1];
           Port[$3C9] := PaletteStuff[ColorOn, 2];
           end;
       end;
   end; {Fades out 256 color screen to black}

procedure FadeInScreen256(PalToMake: Palette256);
   var
     Count        : byte;
     ColorOn      : byte;
     PaletteStuff : Palette256;
     FastPal      : Palette256;

   begin
   GetVGAPalette256(PaletteStuff);
   for Count := 0 to 63 do
       begin
       Port[$3C8] := 0;
       PaletteStuff := PalToMake;
       Delay(1);
       for ColorOn := 0 to 255 do
           begin
           PaletteStuff[ColorOn, 0] := (PaletteStuff[ColorOn, 0] * Count) div
63;           PaletteStuff[ColorOn, 1] := (PaletteStuff[ColorOn, 1] * Count)
div 63;           PaletteStuff[ColorOn, 2] := (PaletteStuff[ColorOn, 2] *
Count) div 63;           Port[$3C9] := PaletteStuff[ColorOn, 0];
           Port[$3C9] := PaletteStuff[ColorOn, 1];
           Port[$3C9] := PaletteStuff[ColorOn, 2];
           end;
       end;
   end; {Fades in 256 color screen from black to the given palette}

 procedure FadeOutScreen16;
   var
     Count        : word;
     ColorOn      : byte;
     PalToMake    : Palette16;
     PaletteStuff : Palette16;

   begin
   GetVGAPalette16(PaletteStuff);
   PalToMake := PaletteStuff;
   for Count := 63 downto 0 do
       begin
       Port[$3C8] := 0;
       PaletteStuff := PalToMake;
       Delay(5);
       for ColorOn := 0 to 15 do
           begin
           PaletteStuff[ColorOn, 0] := (PaletteStuff[ColorOn, 0] * Count) div
63;           PaletteStuff[ColorOn, 1] := (PaletteStuff[ColorOn, 1] * Count)
div 63;           PaletteStuff[ColorOn, 2] := (PaletteStuff[ColorOn, 2] *
Count) div 63;           Port[$3C9] := PaletteStuff[ColorOn, 0];
           Port[$3C9] := PaletteStuff[ColorOn, 1];
           Port[$3C9] := PaletteStuff[ColorOn, 2];
           end;
       end;
   end; {Fades out the 16 color screen to black}


procedure FadeInScreen16(PalToMake: Palette16);
   var
     Count        : byte;
     ColorOn      : byte;
     PaletteStuff : Palette16;
     FastPal      : Palette16;

   begin
   GetVGAPalette16(PaletteStuff);
   for Count := 0 to 63 do
       begin
       Port[$3C8] := 0;
       PaletteStuff := PalToMake;
       Delay(5);
       for ColorOn := 0 to 15 do
           begin
           PaletteStuff[ColorOn, 0] := (PaletteStuff[ColorOn, 0] * Count) div
63;           PaletteStuff[ColorOn, 1] := (PaletteStuff[ColorOn, 1] * Count)
div 63;           PaletteStuff[ColorOn, 2] := (PaletteStuff[ColorOn, 2] *
Count) div 63;           Port[$3C9] := PaletteStuff[ColorOn, 0];
           Port[$3C9] := PaletteStuff[ColorOn, 1];
           Port[$3C9] := PaletteStuff[ColorOn, 2];
           end;
       end;
   end;

end.

