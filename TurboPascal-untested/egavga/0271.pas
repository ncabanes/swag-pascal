
                                                  Date: June 24, 1995
╔═════════════════════╗
║ vga2pcx.zip package ║
╚═════════════════════╝

                  *FAST* Turbo Pascal unit (part assembly langauge).

  DESCRIPTION:

  Saves a copy of the 640x480 VGA 16 color screen to a properly
  formatted PCX file.  This routine also takes care to save
  the current palette so your colors will be preserved correctly.


  REQUIRED:

  *  Turbo Pascal 6+ to run these routines, however, if you just want
     to learn the PCX format you can read the source code and comments.
     I think Pascal code is a relatively easy language to read and
     understand.

  *  EGAVGA.BGI supplied by Borland with the Turbo Pascal compiler


  FILE LIST:

  vga2pcx.pas    Source code for pcx routines
  vga2pcx.tpu    Turbo Pascal 6.0 object code
  test.pas       Example program to use the vga2pcx unit
  test.exe       Compiled example program
  test.pcx       PCX file created by test.exe program


  COMMON USES:

  *  Programmer can give user ability to save a copy of his/her
     exact graphics screen for presentation or documentation purposes.
     The PCX format is common format that is easily imported into
     word processors, etc.

  *  Slide show programs often operate on PCX files.  You can save
     a sequence of pictures and then run a program to cycle through
     them like a demonstration.

  *  Frees the DOS programmer from having to support multiple
     printing devices.  If you can fit your graphics on the screen,
     the screen can be saved into a standard PCX file.  This opens
     the door to printing via other, more specialized, programs.

  *  Source code included, so you can learn the PCX format and
     customize for your own use.


  AUTHOR INFO:

  Bren Sessions
  1590 NW Maple
  Corvallis, OR  97330

  Tel: (503) 758-2256
  Email: sessioj@ece.orst.edu



  PARTICULARS:

  No copyright!!!   Feel free to incorporate this into your own code.

  If you find these functions useful, I'd appreciate to hear from you.
  If you feel like supporting my efforts, be great too.  Some people
  have sent me mail telling me that we've been waiting for these routines
  for years.  I suggest $5, but you can send me whatever you think is
  reasonable.




unit vga2pcx;

interface

uses crt,          { gives sound ability }
     graph;        { allows reading the current palette }

{
  Saves a copy of the 640x480 VGA 16 color screen to a properly
  formatted PCX file.  This routine also takes care to save
  the current palette so your colors will be preserved correctly.

  COMMON USES:

  *  Programmer can give user ability to save a copy of his/her
     exact graphics screen for presentation or documentation purposes.
     The PCX format is common format that is easily imported into
     word processors, etc.

  *  Slide show programs often operate on PCX files.  You can save
     a sequence of pictures and then run a program to cycle through
     them like a demonstration.

  *  Frees the DOS programmer from having to support multiple
     printing devices.  If you can fit your graphics on the screen,
     the screen can be saved into a standard PCX file.  This opens
     the door to printing via other, more specialized, programs.

  *  Source code included, so you can learn the PCX format and
     customize for your own use.

--------------------------------------------------------------------------

  No copyright!!!   Feel free to incorporate this into your own code.

  If you find these functions useful, I'd appreciate to hear from you.
  If you feel like supporting my efforts, be great too.  Some people
  have sent me mail telling me that we've been waiting for these routines
  for years.  I suggest $5, but you can send me whatever you'd like.

  Have fun!!

  Bren Sessions
  1590 N.W. Maple
  Corvallis, OR 97330
  (503) 758-2256

  sessioj@ece.orst.edu

-------------------------------------------------------------------------

}

procedure write_pcx(fn : string; var ok : boolean);

{
  Will save the current 640x480 VGA 16 color screen into file passed
  as parameter 'fn'.  If the save is successful (e.g. the filename
  was legal, 'ok' is given the value of true
}

implementation

{-----------------------------------------------------------------------}

procedure get_rgb(color : integer; var r,g,b : integer);

{ converts a VGA16 color into its reg, green, blue components }

begin

  r:=(((color and $20) shr 5) or ((color and $04) shr 1))*84;
  g:=(((color and $10) shr 4) or ((color and $02)      ))*84;
  b:=(((color and $08) shr 3) or ((color and $01) shl 1))*84;

end;

{-----------------------------------------------------------------------}

procedure write_pcx(fn : string; var ok : boolean);

{ saves windowed region into a RLE .PCX file }
{
   *** compression idea:

      Each scanline is decomposed into a continous stream of 4 bit planes
      = 80 bytes * 4 = 320 bytes.  This stream is checked for consecutive
      byte patterns.  Up to 63 ($3F) values can compressed into two bytes
      forming a RLE code of $C0 or'ed with the run length (up to $3F). This
      forms the first byte, usually ($FF = 1100 0000 | 0011 1111)  The
      next byte is the actual data byte.  If a single byte is encountered
      it is written to the file as simply itself UNLESS the top two
      bits are set (mask $C0) which would indicate a RLE.  If this is
      the case then a special RLE of length 1 must be written in the
      general RLE form.  Here this would be ($C0 | 01 => $C1 followed
      by the data byte.).  I compress each scan line separately thus ending
      possible RLE's at the end of each scan line.  This seems to be
      accepted practice.

      Bren Sessions, June 17, 1995
}


type header_rec =

         record
           pcx_id  : byte;   { 0) 0x0a = ZSoft .PCX file          }
           pcx_ver : byte;   { 1) 0x05 = PC PaintBrush 3.0        }
           encode  : byte;   { 2) 0x01 = RLE                      }
           bpp     : byte;   { 3) 0x01 = bits/pixel why VGA16=1?  }
           left    : word;   { 4-5) Window Left                   }
           top     : word;   { 6-7) Window Top                    }
           right   : word;   { 8-9) Window Right                  }
           bott    : word;   { 10-11) Window Bottom               }
           xres    : word;   { 12-13) Horizontal resolution       }
           yres    : word;   { 14-15) Vertical resolution         }
           rgb     : array[0..15,1..3] of byte;  { (R-G-B) values }
           resv    : byte;   { 64) Reserved                       }
           bplanes : byte;   { 65) Number of bit planes, VGA16=4  }
           bpl     : word;   { 66-67) # of bytes/line, VGA16=80   }
           ptype   : word;   { 68-69) palette type, color=1       }
           unused  : array[70..127] of byte;
         end;

const BUFSIZE = 256;   { will write to disk at this byte interval }

var header : header_rec;
    pal    : palettetype;   { from graph unit }
    r,g,b  : integer;
    i,y,j  : integer;
    fz     : file;
    data   : array[0..319] of byte; { (4 bitplanes) * (scan line=80 bytes) }
    buf    : array[1..BUFSIZE] of byte;
    bi     : integer;   { buffer index }
    dta    : byte;
    index  : integer;
    count  : integer;

label done;

         { - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure flushit;

begin

  blockwrite(fz,buf,bi);
  bi:=0;

end;

         { - - - - - - - - - - - - - - - - - - - - - - - - - }

procedure get_bitplane_info_at_scan_line(plane, scanline : word; var address);

{ Dumps the requested scanline (0-479) at a particular bitplane (0-3)
  into a memory address.  Space required = 80 bytes (640 pixel)
}

begin

  asm

    cld

    mov   bx,ds

    mov   ax,0a000h
    mov   ds,ax

    mov   ax,80
    mul   scanline
    mov   si,ax

    mov   dx,03ceh
    mov   ax,0005h
    out   dx,ax
    mov   ax,plane
    mov   ah,al
    mov   al,04h
    out   dx,ax
    mov   cx,40         { 40 words = 80 bytes = 1 scan line }
    les   di,address
    rep   movsw
    mov   ax,1005h
    out   dx,ax
    mov   ax,0004h
    out   dx,ax
    mov   ds,bx

  end;

end;

         { - - - - - - - - - - - - - - - - - - - - - - - - - }

begin

  ok:=false;
  if fn='' then exit;                   { exit if no filename given }
  fillchar(header,sizeof(header),#0);

  with header do
  begin
    pcx_id  := $0A;
    pcx_ver := $05;
    encode  := $01;
    bpp     := $01;
    left    := 0;
    top     := 0;
    right   := 639;
    bott    := 479;
    xres    := 640;
    yres    := 480;

    getpalette(pal);
    for i:=0 to 15 do
    begin
      get_rgb(pal.colors[i],r,g,b);
      rgb[i,1]:=r;  rgb[i,2]:=g;  rgb[i,3]:=b;
    end;

    bplanes :=  4;
    bpl     :=  80;   { bytes per line }
    ptype   :=  1;
  end;

  assign(fz,fn);
  {$i-} rewrite(fz,1); {$i+}
  if ioresult<>0 then
  begin
    sound(200); delay(2000); nosound;
    sound(50); delay(2000); nosound;
    exit;
  end;
  blockwrite(fz,header,sizeof(header));

  bi:=0;      { buffer index }

  for y:=0 to 479 do
  begin

    get_bitplane_info_at_scan_line(0,y,data[0]);
    get_bitplane_info_at_scan_line(1,y,data[80]);
    get_bitplane_info_at_scan_line(2,y,data[160]);
    get_bitplane_info_at_scan_line(3,y,data[240]);

    index:=0;

    repeat
      count:=0;
      dta:=data[index];
      repeat
        inc(index); inc(count);

        if count>$3F then
        begin
          if bi=BUFSIZE then flushit; inc(bi); buf[bi]:=$FF;
          if bi=BUFSIZE then flushit; inc(bi); buf[bi]:=dta;
          count:=1;
        end;
      until (index>319) or (data[index]<>dta);

      done:
      if count>1 then
      begin
        if bi=BUFSIZE then flushit; inc(bi); buf[bi]:=$C0 or count;
        if bi=BUFSIZE then flushit; inc(bi); buf[bi]:=dta;
      end
      else
      begin
        if (dta and $C0)=$C0 then
        begin
          if bi=BUFSIZE then flushit; inc(bi); buf[bi]:=$C1;
          if bi=BUFSIZE then flushit; inc(bi); buf[bi]:=dta;
        end
        else
        begin
          if bi=BUFSIZE then flushit; inc(bi); buf[bi]:=dta;
        end;
      end;

    until index=320;
  end;

  if bi>0 then flushit;

  close(fz);

  { Sounds the bell that everything is o.k. }
    sound(800); delay(200); nosound;
    sound(600); delay(200); nosound;


  ok:=true;

end;

{ -------------------------------------------------------------------------}

end.
