(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0113.PAS
  Description: Pallete Handling
  Author: PAUL BROMAN
  Date: 08-24-94  13:42
*)

{ GrafCont initializes the graphics mode and handles pallete fades. }

unit GrafCont;

interface

uses
  Crt, Dos, Graph;

type
  Palette256 = array[0..255, 0..2] of Byte;
  Palette16 = array[0..15, 0..2] of Byte;

var
  Mode           : byte;

procedure Init256VGA;
procedure Init16VGA;
procedure SetVGAPalette256(PalBuf: Palette256);
procedure GetVGAPalette256(var PalBuf: Palette256);
procedure SetVGAPalette16(PalBuf: Palette16);
procedure GetVGAPalette16(var PalBuf: Palette16);
procedure GetRGBPalette(PalNum: integer; var R, G, B: byte);
procedure FadeOutScreen256;
procedure FadeOutScreen16;
procedure FadeInScreen256(PalToMake: Palette256);
procedure FadeInScreen16(PalToMake: Palette16);

implementation

procedure Init256VGA;
   {This procedure relies on BGI drivers obtained for Pascal.
    You may need to create a new procedure based on your own
    method for turning on the graphics mode.}

   var
     graphmode      : integer;
     graphdriver    : integer;

   begin
   graphdriver := VGA256Graph;  {Defined as an OBJ}
   graphmode := 0;
   initgraph(graphdriver, graphmode, '');
   end;

procedure Init16VGA;
   var
     graphdriver    : integer;
     graphmode      : integer;

   begin
   graphdriver := 9;
   graphmode := 2;
   initgraph(graphdriver, graphmode, '');
   end;

procedure SetVGAPalette256;
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
end;

procedure GetVGAPalette256;
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
  PalBuf[0, 0] := 0;
  PalBuf[0, 1] := 0;
  PalBuf[0, 2] := 0;
end;

procedure SetVGAPalette16;
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
end;

procedure GetVGAPalette16;
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
  PalBuf[0, 0] := 0;
  PalBuf[0, 1] := 0;
  PalBuf[0, 2] := 0;
end;


procedure GetRGBPalette;

begin
  Port[$3C8] := PalNum;
  R := Port[$3C9];
  G := Port[$3C9];
  B := Port[$3C9];
end;

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
           PaletteStuff[ColorOn, 0] := (PaletteStuff[ColorOn, 0] * Count) div 63;
           PaletteStuff[ColorOn, 1] := (PaletteStuff[ColorOn, 1] * Count) div 63;
           PaletteStuff[ColorOn, 2] := (PaletteStuff[ColorOn, 2] * Count) div 63;
           Port[$3C9] := PaletteStuff[ColorOn, 0];
           Port[$3C9] := PaletteStuff[ColorOn, 1];
           Port[$3C9] := PaletteStuff[ColorOn, 2];
           end;
       end;
   end;

procedure FadeOutText;
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
       Delay(20);
       for ColorOn := 0 to 255 do
           begin
           PaletteStuff[ColorOn, 0] := (PaletteStuff[ColorOn, 0] * Count) div 63;
           PaletteStuff[ColorOn, 1] := (PaletteStuff[ColorOn, 1] * Count) div 63;
           PaletteStuff[ColorOn, 2] := (PaletteStuff[ColorOn, 2] * Count) div 63;
           Port[$3C9] := PaletteStuff[ColorOn, 0];
           Port[$3C9] := PaletteStuff[ColorOn, 1];
           Port[$3C9] := PaletteStuff[ColorOn, 2];
           end;
       end;
   end;

procedure FadeInScreen256;
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
           PaletteStuff[ColorOn, 0] := (PaletteStuff[ColorOn, 0] * Count) div 63;
           PaletteStuff[ColorOn, 1] := (PaletteStuff[ColorOn, 1] * Count) div 63;
           PaletteStuff[ColorOn, 2] := (PaletteStuff[ColorOn, 2] * Count) div 63;
           Port[$3C9] := PaletteStuff[ColorOn, 0];
           Port[$3C9] := PaletteStuff[ColorOn, 1];
           Port[$3C9] := PaletteStuff[ColorOn, 2];
           end;
       end;
   end;

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
           PaletteStuff[ColorOn, 0] := (PaletteStuff[ColorOn, 0] * Count) div 63;
           PaletteStuff[ColorOn, 1] := (PaletteStuff[ColorOn, 1] * Count) div 63;
           PaletteStuff[ColorOn, 2] := (PaletteStuff[ColorOn, 2] * Count) div 63;
           Port[$3C9] := PaletteStuff[ColorOn, 0];
           Port[$3C9] := PaletteStuff[ColorOn, 1];
           Port[$3C9] := PaletteStuff[ColorOn, 2];
           end;
       end;
   end;

procedure FadeInScreen16;
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
           PaletteStuff[ColorOn, 0] := (PaletteStuff[ColorOn, 0] * Count) div 63;
           PaletteStuff[ColorOn, 1] := (PaletteStuff[ColorOn, 1] * Count) div 63;
           PaletteStuff[ColorOn, 2] := (PaletteStuff[ColorOn, 2] * Count) div 63;
           Port[$3C9] := PaletteStuff[ColorOn, 0];
           Port[$3C9] := PaletteStuff[ColorOn, 1];
           Port[$3C9] := PaletteStuff[ColorOn, 2];
           end;
       end;
   end;

end.


