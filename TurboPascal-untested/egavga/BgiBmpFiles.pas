(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0140.PAS
  Description: BGI BMP Files
  Author: RANDALL ELTON DING
  Date: 11-26-94  04:58
*)

{
  Subj: using brute force to load
From: randyd@alpha2.csd.uwm.edu (Randall Elton Ding)

Some have been asking how to load bmp's and such from a file into
the bgi..  Here is a brute force method for doing that in 16 color
EGAVGA or HercMono modes.

There are two programs after this discussion, the first is the bmp
utility and the second is a program that generates a bmp test pattern
with the 16 standard colors used by the bmpgetimage example.

First - if you look at this program, then look in the manual, you will
find that the manual is dead wrong about the setpalette procedure.

          Declaration:
          procedure SetPalette(ColorNum: Word; Color: Shortint);

          Changes the ColorNum entry in the palette to Color.
wrong --> SetPalette(0, LightCyan) makes the first color in the
          palette light cyan. ColorNum can range from 0 to 15......

LightCyan is a constant and is equil to 11 but should be 59, see below.
The color param used by setpalette proc is RGB defined in this way...

    bits: 0 = high intensity blue
          1 = high intensity green
          2 = high intensity red
          3 = low intensity blue
          4 = low intensity green
          5 = low intensity red
          6 = 0
          7 = 0

The bmpgetimage procedure below reads the 64 byte pallet from the bmp
and uses the 2 most sig bits from each BB GG RR 00 entry.
This conversion is not the greatest but this is a brute force method.


-------------- begin 1 of 2 programs ---------------
}
program bmp2bgi;

uses graph;

type
  string80 = string[80];

{ for vga putimage data, each line is repeated 4 times (4 bit planes) }
{ one for each color bit (16 color egavga) }
{ for hercmono, there is only 1 bit plane }
{ the word following the end of the last line
{ must be 00 00 in hercmono to tell BGI that there is only 1 bit plane }
{ for VGA the last word is 0F 00 ($000F) for 16 colors (4 bit planes) }

{ ! must be in graphics mode to call this procedure }
{ does getimage like function on either 2 color or 4 color bmp file }
{ use dw=0 dh=0 to get bmp image from dx,dy to extreme edge }
{ this procedure will load a 2 color bmp as a B&W image into a 16 color
{ 4 bit plan putimage structure provided that the current video mode is }
{ egavga, but will not load a 16 color bmp into a single bit plane }
{ when the current video mode is hercmono }
{ no memory will be allocated if an error occurs (error when errs <> '') }

procedure bmpgetimage
        (     fn          : string80;    { bmp file name }
          var datapointer : pointer;     { ^ to putimage data }
              dx,dy,dw,dh : word;        { offset into bmp & requested size }
          var errs        : string80;    { error string, '' if none }
          var palette     : palettetype; { returns converted EGA palette }
          var size        : word);       { returns memory taken by image }
                                         { for caller to release the memory }
                                         { with freemem(datapointer,size); }
  type
    bmpheadtype = record

             { bit map file header }
             bftype: word;                   { "BM" or $4D42 }
             bfsize: longint;                { size of file in bytes }
             bfreserved1: word;
             bfreserved2: word;
             bfoffbits: longint;             { ^ where graphic data begins }

             { bit map information header }
             bisize: longint;                { length of this header, $28 }
             biwidth: longint;               { pixel width }
             biheight: longint;              { pixel height }
             biplanes: word;                 { = 1 }
             bibitcount: word;               { color bits per pixel }
             bicompression: longint;         { = 0 for no compression }
             bisizeimage: longint;           { = bfsize - bfoffbits }
             bixpelspermeter: longint;       { x pixels per meter }
             biypelspermeter: longint;       { y pixels per meter }
             biclrused: longint;             { \ I have never seen these }
             biclrimportant: longint;        { / two used for anything }
           end;
           { A note on windows BMP files.. }
           { At this point in the bmp file, there is allocated }
           { 1 longint for each color, RGB pallet data BB GG RR 00. }
           { For greyscale viewing on color monitor, BB=GG=RR=shade }
           { Number colors = 2^bibitcount, then pixel data follows. }
           { For 16 colors, there are 64 bytes between header and }
           { line data; Data lines are padded out to 32 bit incrimemts }
           { also, bmp data is saved from bottom line up, and left to right }

  label badpalette,badread;

  const
    maxbuf = 65520-1-4;  { -4 for iw and ih words }
    defaultcolors: array[0..15] of byte =
      (0,1,2,3,4,5,20,7,56,57,58,59,60,61,62,63);

  type buftype = record      { .data includes trailing word for # bitplanes }
                   iw,ih: word;
                   data : array[0..maxbuf] of byte;
                 end;
  var
    f: file;
    bmphead: bmpheadtype;
    buf: ^buftype;
    i,graphics,num,n,byteskip,bw,bw1,startbit: word;
    dbyte,bit,bit1,x,y,loc,loc1,x1: word;
    fs: longint;
    rgbpalette: array[0..15,0..3] of byte;

  begin  { loadbmp }
    errs:= '';
    assign(f,fn);
    {$I-}
    reset(f,1);
    {$I+}
    if ioresult<>0 then begin
      errs:= 'cannot open '+fn;
      exit;
    end;
    blockread(f,bmphead,sizeof(bmphead),num);
    if num < sizeof(bmphead) then begin
      errs:= 'unexpected end of file';
      close(f);
      exit;
    end;
    with bmphead do begin
      if (dw=0) and (biwidth>dx) then dw:= biwidth-dx;
      if (dh=0) and (biheight>dy) then dh:= biheight-dy;
      if (dx+dw>biwidth) or (dy+dh>biheight) or (dw=0) or (dh=0) then begin
        errs:= 'x+width,y+height exceeds bmp bounds';
        close(f);
        exit;
      end;
      fs:= filesize(f);
      if not ((bftype=$4D42) and (fs=bfsize) and (bisizeimage=fs-bfoffbits))
      then begin
        errs:= 'corrupt bmp file or not a bmp';
        close(f);
        exit;
      end;
      if not (bibitcount in [1,4]) then begin
        errs:= 'bmp must be 2 or 16 color';
        close(f);
        exit;
      end;

      graphics:= 0;
      size:= imagesize(dx,dy,dx+dw-1,dy+dh-1);
      if (graphresult=grerror) or (size-4 > maxbuf+1) then begin
        errs:= 'image too large';
        close(f);
        exit;
      end;
      bw1:= dw div 8;
      if dw mod 8 > 0 then bw1:= bw1 + 1;
      if bw1*dh*4+6=size then graphics:= 4;  { figure out what video mode }
      if bw1*dh+6=size then graphics:= 1;    { we are in, 1 or 4 bit planes }
      if graphics=0 then begin               { graphics = # bit planes to }
        errs:= 'internal error';             { save putimage data with }
        close(f);
        exit;
      end;
      if (graphics=1) and (bibitcount>1) then begin
        errs:= 'bmp must be 2 color for present graphics mode';
        close(f);
        exit;
      end;

      getmem(datapointer,size);
      buf:= datapointer;
      n:= 32 div bibitcount;              { pixels per longint }
      bw:= biwidth div n;                 { longint width of one line }
      if biwidth mod n > 0 then bw:= bw + 1;
      bw:= bw * n;                        { line length to nearest 32 pixels }
      n:= n div 4;                        { pixels per byte }
      byteskip:= (dx+dw) div n;
      if (dx+dw) mod n > 0 then byteskip:= byteskip + 1;
      byteskip:= byteskip * n;
      byteskip:= (bw-byteskip) div n;     { bytes to skip at end of line }
      startbit:= dx mod n;                { starting bit position }
      dx:= dx div n;                      { x byte offset into data }
      byteskip:= byteskip + dx;           { add bytes to skip at beginning }
      bw:= bw div n;                      { byte length of line }

      if (graphics=4) and (bibitcount=4) then begin
        {$I-}
        seek(f,bisize+14);
        {$I+}
        if ioresult<>0 then goto badpalette;
        blockread(f,rgbpalette,sizeof(rgbpalette),num);
        if num<>sizeof(rgbpalette) then begin
          badpalette:
          errs:= 'error reading bmp palette';
          close(f);
          freemem(datapointer,size);
          exit;
        end;
        getpalette(palette);
        if palette.size = 16 then for i:= 0 to 15 do begin
          dbyte:= 0;
          if rgbpalette[i,2] and $80 = $80 then dbyte:= dbyte or $04;
          if rgbpalette[i,2] and $40 = $40 then dbyte:= dbyte or $20;
          if rgbpalette[i,1] and $80 = $80 then dbyte:= dbyte or $02;
          if rgbpalette[i,1] and $40 = $40 then dbyte:= dbyte or $10;
          if rgbpalette[i,0] and $80 = $80 then dbyte:= dbyte or $01;
          if rgbpalette[i,0] and $40 = $40 then dbyte:= dbyte or $08;
          palette.colors[i]:= dbyte;
        end;
      end;
      if (graphics=4) and (bibitcount=1) then begin
        getpalette(palette);
        if palette.size = 16 then move(defaultcolors,palette.colors,16);
      end;
      if graphics=1 then getpalette(palette);

      {$I-}
      seek(f,bfoffbits);
      {$I+}
      if (ioresult<>0) or (fs-filepos(f) <> bw*biheight) then begin
        errs:= 'bad bmp file length, doesn''t match image size parameters';
        close(f);
        freemem(datapointer,size);
        exit;
      end;
      {$I-}                        { !! bmp's are saved from bottom up !! }
      seek(f,bfoffbits + (biheight-dh-dy)*bw + dx);
      {$I+}
      if ioresult<>0 then goto badread;
      fillchar(buf^,size,#0);
      buf^.iw:= dw-1;         { bgi putimage data has width & height values }
      buf^.ih:= dh-1;         { stored as width-1, height-1 }
      for y:= dh-1 downto 0 do begin
        bit:= startbit;
        blockread(f,dbyte,1,num);
        if num <> 1 then goto badread;
        loc:= bw1*y*graphics;
        bit1:= $80;
        x1:= 0;
        for x:= 0 to dw-1 do begin
          loc1:= loc+x1;
          if graphics <> bibitcount then dbyte:= (dbyte and $FF) shl 1;
          for i:= 0 to graphics-1 do begin
            if graphics = bibitcount then dbyte:= (dbyte and $FF) shl 1;
            if hi(dbyte)=1 then buf^.data[loc1]:= buf^.data[loc1] or bit1;
            loc1:= loc1+bw1;
          end;
          bit1:= bit1 shr 1;
          if bit1=0 then begin
            bit1:= $80;
            x1:= x1+1;
          end;
          bit:= bit+1;
          if (bit >= n) and (x<dw-1) then begin
            bit:= 0;
            blockread(f,dbyte,1,num);
            if num <> 1 then goto badread;
          end;
        end;
        if (byteskip>0) and (y>0) then begin
          {$I-}
          seek(f,filepos(f)+byteskip);
          {$I+}
          if ioresult<>0 then begin
            badread:
            errs:= 'error reading bmp data';
            close(f);
            freemem(datapointer,size);
            exit;
          end;
        end;
      end;
      close(f);
      loc1:= dh*bw1*graphics;    { set number of bitplanes parameter }
      buf^.data[loc1+1]:= 0;
      if bibitcount = 4 then buf^.data[loc1]:= $F else buf^.data[loc1]:= 0;
    end;
  end;  { bmpgetimage }



procedure example;
  var
    p: pointer;
    i,x,y,w,h,size: word;
    errs: string80;
    grmode,grdriver,errcode: integer;
    palette,origpalette: palettetype;

  begin
    grdriver:= detect;
    initgraph(grdriver,grmode,'e:\bp\bgi');
    errcode:= graphresult;
    if errcode <> grok then begin
      writeln('Graphics error: ',grapherrormsg (errcode));
      halt(1);
    end;
    x:= 0;   { start reading the bmp data from 0,0 }
    y:= 0;
    w:= 0;   { w=0 means tells bmpgetimage to use maximum width of bmp }
    h:= 0;   { h=0 same here }
    bmpgetimage('d:\windows\winlogo.bmp',p,x,y,w,h,errs,palette,size);
    if errs='' then begin       { test error string for possible error }
      getpalette(origpalette);
      setallpalette(palette);
      putimage(0,0,p^,normalput);
      readln;
      setallpalette(origpalette);
      closegraph;
      freemem(p,size);
    end
    else begin
      closegraph;
      writeln(errs);
      readln;
    end;
  end;


begin
  example;
end.

{
------------- end first program, begin second program --------------
}
{ makes a test pattern bmp file with correct palette, 640x128, 4 bits/pixel }
program makebmptestpattern;
type
  bmpheadtype = record

           { bit map file header }
           bftype: word;                   { "BM" or $4D42 }
           bfsize: longint;                { size of file in bytes }
           bfreserved1: word;
           bfreserved2: word;
           bfoffbits: longint;             { ^ where graphic data begins }

           { bit map information header }
           bisize: longint;                { length of this header, $28 }
           biwidth: longint;               { pixel width }
           biheight: longint;              { pixel height }
           biplanes: word;                 { = 1 }
           bibitcount: word;               { color bits per pixel }
           bicompression: longint;         { = 0 for no compression }
           bisizeimage: longint;           { = bfsize - bfoffbits }
           bixpelspermeter: longint;       { x pixels per meter }
           biypelspermeter: longint;       { y pixels per meter }
           biclrused: longint;             { \ I have never seen these }
           biclrimportant: longint;        { / two used for anything }
         end;

type
  paltype = array[0..15,0..3] of byte;
  bodytype = array[0..127,0..319] of byte;
  buftype = record
              head: bmpheadtype;
              pal : paltype;
              body: bodytype;
            end;
  colorstype = array[0..15] of byte;

const
  colors: colorstype = (0,1,2,3,4,5,20,7,56,57,58,59,60,61,62,63);


var
  f: file;
  buf: ^buftype;
  r,g,b,i,x,y,c: integer;


begin
  new(buf);
  with buf^,buf^.head do begin
    for i:= 0 to 15 do begin
      r:= 0;  g:= 0;  b:= 0;
      if colors[i] and 1 = 1 then b:= b + 128;
      if colors[i] and 2 = 2 then g:= g + 128;
      if colors[i] and 4 = 4 then r:= r + 128;
      if colors[i] and 8 = 8 then b:= b + 64;
      if colors[i] and 16 = 16 then g:= g + 64;
      if colors[i] and 32 = 32 then r:= r + 64;
      pal[i,0]:= b;
      pal[i,1]:= g;
      pal[i,2]:= r;
      pal[i,3]:= 0;
    end;
    for y:= 0 to 127 do
      for x:= 0 to 319 do begin
        c:= (x div 10) mod 16;
        c:= (c shl 4) + c;
        body[y,x]:= c;
      end;
    bftype:= $4D42;                 { "BM" or $4D42 }
    bfsize:= sizeof(buf^);          { size of file in bytes }
    bfreserved1:= 0;
    bfreserved2:= 0;
    bfoffbits:= 14+40+64;           { where graphic data begins }
    bisize:= 40;                    { length of this header }
    biwidth:= 640;                  { pixel width }
    biheight:= 128;                 { pixel height }
    biplanes:= 1;                   { =1 }
    bibitcount:= 4;                 { color bits per pixel }
    bicompression:= 0;              { =0 for no compression }
    bisizeimage:= bfsize-bfoffbits;
    bixpelspermeter:= 0;
    biypelspermeter:= 0;
    biclrused:= 0;
    biclrimportant:= 0;
  end;
  assign(f,'testpat.bmp');
  rewrite(f,1);
  blockwrite(f,buf^,sizeof(buf^));
  close(f);
end.

{
--------------- end of programs ---------------
}
