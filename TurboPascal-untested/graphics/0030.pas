{===========================================================================
Date: 08-23-93 (08:26)
From: NORMAN YEN
Subj: RE: .PCX AND COMM ROUTINE
---------------------------------------------------------------------------

 MB> I heard something in this echo about someone having Pascal source to
 MB> view .PCX
 MB> files and I would appreciate if they would re-post the source if it's
 MB> not too
 MB> long or tell me where I can get it.  I am also looking for some good
 MB> COMM routines for Pascal, anyone have any or no where I can get some?

        The routine I have will only work with 320x200x256c images.
Hope it helps!

Norman

{
        For all those Pascal programmers who just want something simple
        to display a 320x200x256 colour PCX file on the screen here it is.
        This was a direct translation from the C source code of PCXVIEW
        written by Lee Hamel (Patch), Avalanche coder.  I removed the
        inline assembly code so that you beginners can see what was going
        on behind those routines.

                                                      Norman Yen
                                                      Infinite Dreams BBS
                                                      August 11, 1993
}

type pcxheader_rec=record
     manufacturer: byte;
     version: byte;
     encoding: byte;
     bits_per_pixel: byte;
     xmin, ymin: word;
     xmax, ymax: word;
     hres: word;
     vres: word;
     palette: array [0..47] of byte;
     reserved: byte;
     colour_planes: byte;
     bytes_per_line: word;
     palette_type: word;
     filler: array [0..57] of byte;
     end;

var header: pcxheader_rec;
    width, depth: word;
    bytes: word;
    palette: array [0..767] of byte;
    f: file;
    c: byte;

procedure Read_PCX_Line(vidoffset: word);
var c, run: byte;
    n: integer;
    w: word;
begin
  n:=0;
  while (n < bytes) do
  begin
    blockread (f, c, 1);

    { if it's a run of bytes field }
    if ((c and 192)=192) then
    begin

      { and off the high bits }
      run:=c and 63;

      { get the run byte }
      blockread (f, c, 1);
      n:=n+run;
      for w:=0 to run-1 do
      begin
        mem [$a000:vidoffset]:=c;
        inc (vidoffset);
      end;
    end else
    begin
      n:=n+1;
      mem [$a000:vidoffset]:=c;
      inc (vidoffset);
    end;
  end;
end;

procedure Unpack_PCX_File;
var i: integer;
begin
  for i:=0 to 767 do
    palette [i]:=palette [i] shr 2;
  asm
    mov ax,13h
    int 10h
    mov ax,1012h
    xor bx,bx
    mov cx,256
    mov dx,offset palette
    int 10h
  end;
  for i:=0 to depth-1 do
    Read_PCX_Line (i*320);
  asm
    xor ax,ax
    int 16h
    mov ax,03h
    int 10h
  end;
end;

begin
  if (paramcount > 0) then
  begin
    assign (f, paramstr (1));
    reset (f,1);
    blockread (f, header, sizeof (header));
    if (header.manufacturer=10) and (header.version=5) and
       (header.bits_per_pixel=8) and (header.colour_planes=1) then
    begin
      seek (f, filesize (f)-769);
      blockread (f, c, 1);
      if (c=12) then
      begin
        blockread (f, palette, 768);
        seek (f, 128);
        width:=header.xmax-header.xmin+1;
        depth:=header.ymax-header.ymin+1;
        bytes:=header.bytes_per_line;
        Unpack_PCX_File;
      end else writeln ('Error reading palette.');
    end else writeln ('Not a 256 colour PCX file.');
    close (f);
  end else writeln ('No file name specified.');
end.

