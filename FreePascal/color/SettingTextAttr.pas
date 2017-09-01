(*
  Category: SWAG Title: TEXT/GRAPHICS COLORS
  Original name: 0016.PAS
  Description: Setting Text Attr
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:34
*)

{YZ> Does anyone know how to "extract" the foreground and background
YZ> colours from TextAttr?
}

uses crt;

{
    Foreground := TextAttr and $0f;
    Background := (TextAttr and $f0) shr 4;
}

{A few days ago, I read a message from someone who was trying to extract
foreground and background colors from one Byte Variable. I have since
lost the mail packet, and forgotten the user's name, but here's a
routine that will do that anyways. Hope it gets to the person who was
asking For it......
}
Procedure GetColors(Color : Byte; Var BackGr : Byte; Var ForeGr : Byte);
begin
  BackGr := Color shr 4;
  ForeGr := Color xor (Backgr shl 4);
end;

var
    fc, bc: byte;

begin
    textAttr := 30;
    WriteLn('Hi!');
    
    fc := TextAttr and $0f;
    bc := (TextAttr and $f0) shr 4;
    WriteLn('FC=',fc,' BC=',bc);
    textcolor(fc);
    textbackground(bc);
    WriteLn('Hi 2!');
    
    GetColors(TextAttr, bc, fc);
    WriteLn('FC=',fc,' BC=',bc);
    textcolor(fc);
    textbackground(bc);
    WriteLn('Hi 3!');
end.
