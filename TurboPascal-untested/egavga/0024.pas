{
After several tricks to redefine Characters in EGA and VGA in this echo,
here is one you can use in CGA mode 4,5,6. You will find an Unit, and a
test Program.
}

Unit graftabl;

{
released into the public domain
author : Emmanuel ROUSSIN
FIDO   : 2:320/200.21
Email  : roussin@frmug.fr.mugnet.org

for using redefined Characters (128 to 255)
in CGA mode 4,5 and 6 Without using GRAFTABL.EXE
}

Interface

Type
  Tcaractere8 = Array [1..8] of Byte;
  Tgraftabl = Array [128..255] of Tcaractere8;

{
if you want to use only one font, define it in this Unit, For example :

Const
  the_only_font : Tgraftabl = (
                              (x,x,x,x,x,x,x,x),
                              .
                              .
                              (x,x,x,x,x,x,x,x),
                              (x,x,x,x,x,x,x,x)
                              );

Or you can in your main Program :

Var
  my_font : Tgraftabl;

and define it after
}

Var
  seg_graftabl,
  ofs_graftabl : Word;

{internal Procedures}

Procedure get_graftabl(Var segment, offset : Word);
Procedure put_graftabl(segment, offset : Word);

{Procedures to use in your Programs}

Procedure init_graftabl;
Procedure use_graftabl(Var aray : Tgraftabl);
Procedure end_graftabl;

Implementation

Procedure get_graftabl(Var segment, offset : Word);
begin
  segment := memw[0 : $1F * 4 + 2];
  offset  := memw[0 : $1f * 4];
end;

Procedure put_graftabl(segment, offset : Word);
begin
  memw[0 : $1f * 4 + 2] := segment;
  memw[0 : $1f * 4] := offset
end;

Procedure init_graftabl;
{ interrupt 1F is a Pointer to bitmaps For high 128 Chars (8 Bytes per
  Character) defined by GRAFTABL.EXE we save this initial Pointer }
begin
  get_graftabl(seg_graftabl, ofs_graftabl);
end;

Procedure use_graftabl(Var aray : Tgraftabl);
{ we define a new Pointer : the address of an Array }
begin
  put_graftabl(seg(aray),ofs(aray));
end;

Procedure end_graftabl;
{ we restore the original Pointer }
begin
  put_graftabl(seg_graftabl,ofs_graftabl);
end;

end.

Program test;

Uses
  Graph3, Crt, graftabl;


Var
  font    : Tgraftabl;
  i,j,tmp : Byte;
  rid     : Char;

begin
  hires;
  init_graftabl;
  fillChar(font,sizeof(font),0);
  use_graftabl(font);

  {$F000:$FA6E is the ROM address where the Characters 0 to 127 are defined}

  For i := 1 to 26 do
    For j := 0 to 7 do
    begin
      tmp := mem[$F000 : $FA6E + 97 * 8 + (i - 1) * 8 + j] xor $FF;
      tmp := tmp xor $FF;
      tmp := tmp or (tmp div 2);
      font[i + 127, j + 1] := tmp;
      { Char 128 to 153 are redefined }
    end;

  For i := 1 to 26 do
    For j := 0 to 7 do
    begin
      tmp := mem[$F000 : $FA6E + 97 * 8 + (i - 1) * 8 + j] or $55;
      font[i + 153, j + 1 ] := tmp;
      { Char 154 to 181 are redefined }
    end;

  Writeln('the normal Characters ($61 to $7A) :');
  Writeln;
  For i := $61 to $7A do
    Write(chr(i));
  Writeln; Writeln;
  Writeln('now, these same Characters, but thick :');
  Writeln;
  For i := 128 to 153 do
    Write(chr(i));
  Writeln; Writeln;
  Writeln('the same Characters, but greyed :');
  Writeln;
  For i := 154 to 181 do
    Write(chr(i));
  rid := ReadKey;
  end_graftabl;
  Textmode(co80);
end.

