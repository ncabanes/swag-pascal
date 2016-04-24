(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0033.PAS
  Description: Display PCX Files
  Author: NORMAN YEN
  Date: 11-02-93  05:30
*)

{
> I heard something in this echo about someone having Pascal source to view
> .PCX Files and I would appreciate if they would re-post the source if it's
> not too long or tell me where I can get it.  I am also looking For some
> good COMM routines For Pascal, anyone have any or no where I can get some?

The routine I have will only work With 320x200x256c images.

        For all those Pascal Programmers who just want something simple
        to display a 320x200x256 colour PCX File on the screen here it is.
        This was a direct translation from the C source code of PCXVIEW
        written by Lee Hamel (Patch), Avalanche coder.  I removed the
        Inline assembly code so that you beginners can see what was going
        on behind those routines.

Norman Yen - Infinite Dreams BBS - August 11, 1993
}

Type
  pcxheader_rec = Record
    manufacturer   : Byte;
    version        : Byte;
    encoding       : Byte;
    bits_per_pixel : Byte;
    xmin, ymin     : Word;
    xmax, ymax     : Word;
    hres, vres     : Word;
    palette        : Array [0..47] of Byte;
    reserved       : Byte;
    colour_planes  : Byte;
    Bytes_per_line : Word;
    palette_Type   : Word;
    filler         : Array [0..57] of Byte;
  end;

Var
  header  : pcxheader_rec;
  width,
  depth   : Word;
  Bytes   : Word;
  palette : Array [0..767] of Byte;
  f       : File;
  c       : Byte;

Procedure Read_PCX_Line(vidoffset : Word);
Var
  c, run : Byte;
  n      : Integer;
  w      : Word;
begin
  n := 0;
  While (n < Bytes) do
  begin
    blockread (f, c, 1);
    { if it's a run of Bytes field }
    if ((c and 192) = 192) then
    begin
      { and off the high bits }
      run := c and 63;
      { get the run Byte }
      blockread (f, c, 1);
      n := n + run;
      For w := 0 to run - 1 do
      begin
        mem[$a000 : vidoffset] := c;
        inc(vidoffset);
      end;
    end
    else
    begin
      n := n + 1;
      mem[$a000 : vidoffset] := c;
      inc(vidoffset);
    end;
  end;
end;

Procedure Unpack_PCX_File;
Var
  i : Integer;
begin
  For i := 0 to 767 do
    palette[i] := palette[i] shr 2;
  Asm
    mov ax, 13h
    int 10h
    mov ax, 1012h
    xor bx, bx
    mov cx, 256
    mov dx, offset palette
    int 10h
  end;
  For i := 0 to depth - 1 do
    Read_PCX_Line(i * 320);
  Asm
    xor ax, ax
    int 16h
    mov ax, 03h
    int 10h
  end;
end;

begin
  if (paramcount > 0) then
  begin
    assign(f, paramstr(1));
    reset(f, 1);
    blockread (f, header, sizeof(header));
    if (header.manufacturer = 10) and (header.version = 5) and
       (header.bits_per_pixel = 8) and (header.colour_planes = 1) then
    begin
      seek(f, Filesize(f) - 769);
      blockread(f, c, 1);
      if (c = 12) then
      begin
        blockread(f, palette, 768);
        seek(f, 128);
        width := header.xmax - header.xmin + 1;
        depth := header.ymax - header.ymin + 1;
        Bytes := header.Bytes_per_line;
        Unpack_PCX_File;
      end
      else
        Writeln('Error reading palette.');
    end
    else
      Writeln('Not a 256 colour PCX File.');
    close(f);
  end
  else
    Writeln('No File name specified.');
end.

