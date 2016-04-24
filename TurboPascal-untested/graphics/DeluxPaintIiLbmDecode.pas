(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0087.PAS
  Description: Delux Paint II LBM decode
  Author: WIM VAN DER VEGT
  Date: 05-25-94  08:20
*)

{
Here a program to display files from deLux Paint II (*.LBM files)
drawings. It uses a PD BGI driver for 320x200x256 color mode. Other
drivers can also be used. Otherwise look in the SWAG lib for routines to
enter this graphics mode and set a pixel in a certain color.

Code isn't optimal and can be made much faster but works. It doesn't
display some brushes because of some undocumented sections in the LBM
file. If the defines are made active the file is decoded and dumped
textual to the screen. After the program a part of a small PD text file
I found and used as base for this program. It contained some bugs but
one evening works does a lot.

Btw. Does anybody know how to distinguish deLux Paint II and deLux Paint
II Enhanced files?
}

{---------------------------------------------------------}
{ Written by : Ir. G.W. van der Vegt                      }
{ Purpose    : a Delux Paint II LBM file displayer/decoder}
{              displays 16 and 256 color bitmaps but no   }
{              brushes and Delux Paint IIe files yet      }
{                                                         }
{              Displays at the moment only                }
{              320x200 or smaller pictures.               }
{                                                         }
{              Uses a PD SVGA driver to access MCGA mode. }
{              Substitute your own if you havn't got it.  }
{                                                         }
{ File format info by Bob Montgomery 9-21-90, although    }
{ it wasn't very accurate (he forgot Motorola swaps       }
{ lo & hi byes of words) and didn't cover the             }
{ DPPV, CRNG & GRAB sections.                             }
{                                                         }
{ Use the verbose (and rle) defines to get a dump of the  }
{ lbm file.                                               }
{---------------------------------------------------------}

PROGRAM lbm(INPUT,OUTPUT);

USES
  crt,
  dos,
  graph;
  routines;

{ DEFINE verbose}
{ DEFINE rle    }
{$I SVGA256.INC}

TYPE
  rgb  = (r,g,b);
  dp2l = ARRAY[0..3] OF BYTE; {read left to right}
  dp2m = ARRAY[1..4] OF CHAR;
  dp2t = ARRAY[rgb] OF BYTE;
  dp2h = RECORD
           msg1         : dp2m; { "FORM" }
           flen         : dp2l;                 { File length - 8 }
           msg2,                { "ILBM" }
           msg3         : dp2m; { "BMHD" }
           hlen         : dp2l;                 { Length of header }
           width,
           Length,
           xoff,
           yoff         : WORD;
           planes,
           masking,
           compression,
           pad          : BYTE;
           tansparent   : INTEGER;
           x_aspect,
           y_aspect     : BYTE;
           screenwidth,
           screenheight : WORD;
         END;

CONST
  max  = 1023;

VAR
   f   : FILE;
   dp2 : dp2h;
   msg : dp2m;
   len : dp2l;
   col : dp2t;

   i,
   j,
   k,
   y   : INTEGER;
   c   : BYTE;
   bl,
   h,
   l   : LONGINT;
   w   : WORD;
   grmode,
   grdriver : INTEGER;
   lin      : ARRAY[0..max] OF BYTE;

CONST
  form  : dp2m = ('F','O','R','M');
  ilbm  : dp2m = ('I','L','B','M');
  bmhd  : dp2m = ('B','M','H','D');
  cmap  : dp2m = ('C','M','A','P');
  body  : dp2m = ('B','O','D','Y');

{$F+}
FUNCTION Detectvga256 : INTEGER;

BEGIN
  Detectvga256 := svga320x200x256;
END;
{$F-}
FUNCTION Len2long(a : dp2l) : LONGINT;

BEGIN
  Len2long:=(((a[0]*256+a[1])*256+a[2])*256+a[3]);
END;

FUNCTION Msg2str(a : dp2m) : STRING;

BEGIN
  Msg2str:=a[1]+a[2]+a[3]+a[4];
END;

FUNCTION Readnext : BYTE;

VAR
 w : WORD;
 c : BYTE;

BEGIN
  Blockread(f,c,1,w);
  IF (w<>1)
    THEN
      BEGIN
        Closegraph;
        Writeln('Unexpected EOF encountered');
        Halt(3);
      END
    ELSE Readnext:=c;
END;

CONST
  cnt : BYTE    = 0;
  rle : BOOLEAN = false;
  dat : BYTE    = 0;
  vir : LONGINT = 0;
  rel : LONGINT = 0;

FUNCTION Getnext : BYTE;

VAR
  c : BYTE;
  w : WORD;

BEGIN
(*
get a code BYTE from the data stream.
IF the msb is 1, the 'count' is (1 - code), max = 127. get the next
   BYTE from the data stream, AND REPEAT it 'count' times.
IF the msb is 0, the 'count' is (1 + code), max = 128. get the next
   'count' bytes from the data stream.
*)
  IF (dp2.compression=0)
    THEN Getnext:=Readnext
    ELSE
      IF (cnt=0)
        THEN
          BEGIN
            c:=Readnext;
            rle:=(c>127);
            IF rle
              THEN
                BEGIN
                  cnt    :=SHORTINT(1-c);
                  dat    :=Readnext;
                  Getnext:=dat;
{$IFDEF rle}
  Delay(500);
  Writeln;
  Write('RLE : ',byte2hex(c),' = ',cnt:3,'x',byte2hex(dat));
{$ENDIF}
                END
              ELSE
                BEGIN
                  cnt    :=1+c;
                  dat    :=Readnext;
                  Getnext:=dat;
{$IFDEF rle}
  Delay(500);
  Writeln;
  Write('UNC : ',byte2hex(c),' : ',byte2hex(dat));
{$ENDIF}
                END;
          END
        ELSE
          BEGIN
            IF NOT(rle)
              THEN dat:=Readnext;
            Getnext:=dat;
{$IFDEF rle}
  IF NOT(rle) THEN Write(' ',byte2hex(dat));
{$ENDIF}
          END;

  Dec(cnt);
  rel:=Filepos(f)-h;
  Inc(vir);
END;

BEGIN
  Assign(f,Paramstr(1)+'.lbm');
  Reset(f,1);

  Blockread(f,dp2,Sizeof(dp2));

  WITH dp2 DO
    BEGIN
{$IFDEF verbose}
      FOR i:=1 TO Sizeof(msg1) DO Write(msg1[i]); Writeln;
      FOR i:=1 TO Sizeof(msg2) DO Write(msg2[i]); Writeln;
{$ENDIF}
      IF (msg1<>form) OR (msg2<>ilbm) OR (msg3<>bmhd)
        THEN
          BEGIN
            Writeln('No DeLux Paint LBM file.');
            Halt(1);
          END;

{$IFNDEF verbose}
      grdriver:=Installuserdriver('SVGA256',@detectvga256);
      grmode  :=svga320x200x256;
      grdriver:=detect;
      Initgraph(grdriver,grmode,'');
{$ENDIF}

    {----Low & high words/bytes are swapped (Motorola 680x0 convention)}
{$IFDEF verbose}
      Writeln('filelength : ',Len2long(flen));
      Writeln('headlength : ',Len2long(hlen));
{$ENDIF}

    {----Low & high bytes are swapped (Motorola 680x0 convention)}
      width       :=Swap(width);
      Length      :=Swap(Length);
      xoff        :=Swap(xoff);
      yoff        :=Swap(yoff);
      screenwidth :=Swap(screenwidth);
      screenheight:=Swap(screenheight);

{$IFDEF verbose}
      Writeln('W .L  : ',width      ,'x',Length);
      Writeln('Xo.Yo : ',xoff       ,'x',yoff  );
      Writeln('Xa.Ya : ',x_aspect   ,'x',y_aspect);
      Writeln('W. H  : ',screenwidth,'x',screenheight);
      Writeln('Planes: ',planes);
      Writeln('Pad   : ',pad);
{$ENDIF}

      Blockread(f,msg,Sizeof(msg));
      Blockread(f,len,Sizeof(len));

{$IFDEF verbose}
      Writeln(Msg2str(msg));
      Delay(1000);
{$ENDIF}

      IF (msg=cmap)
        THEN
          BEGIN
            l:=Len2long(len);
{$IFDEF verbose}
            Writeln('CMAPlen : ',l);
{$ENDIF}
            FOR i:=1 TO l DIV 3 DO
              BEGIN
                Blockread(f,col,Sizeof(col));
{$IFDEF verbose}
                Delay(100);
                Writeln(i-1:4,col[r]:4,col[g]:4,col[b]:4);
{$ELSE}
                Setrgbpalette(i-1,col[r] DIV 4,col[g] DIV 4,col[b] DIV 4);
{$ENDIF}
              END;
            Blockread(f,msg,Sizeof(msg));
          END;

{----dump unkown sections dppv
     the 4 bytes Length is mostly 104 bytes
}
{----dump unkown sections grab
     the 4 bytes Length is 4, section found IN a brush only,
}
{----dump 4 unkown sections crng :
     seems each TO consist OF two entries WITH :
              00 00 0a aa,00 00 01 0e
              00 00 0a aa,00 00 00 00
              00 00 0a aa,00 00 00 00
              00 00 0a aa,00 00 00 00
     brushes contain different values.
}
      WHILE (msg<>body) DO
        BEGIN
          Blockread(f,len,Sizeof(len));
          l:=Len2long(len);
          Writeln(Msg2str(msg)+' : ',l);
          FOR h:=1 TO l DO
            BEGIN
              Blockread(f,c,1);
              Write(' ',byte2hex(c));
            END;
          Blockread(f,msg,Sizeof(msg));
          Writeln;
        END;

      IF (msg=body)
        THEN
          BEGIN
{$IFDEF verbose}
            Writeln(Msg2str(msg));
{$ENDIF}
            Blockread(f,len,Sizeof(len));
            l:=Len2long(len);
            h :=Filepos(f);
{$IFDEF verbose}
            Writeln('BODYlen : ',l);
{$ENDIF}
            IF compression=0
              THEN bl:=l DIV Length DIV planes
              ELSE bl:=width DIV 8;
{$IFDEF verbose}
            Writeln('Bytew   : ',bl);
{$ENDIF}
            FOR y:=1 TO Length DO
              BEGIN
                FOR i:=0 TO max DO lin[i]:=0;
{$R-}
                FOR j:=0 TO planes-1 DO
                  FOR i:=0 TO bl-1 DO
                    BEGIN
                      c:=Getnext;
                      FOR k:=0 TO 7 DO
                        IF (c AND (128 SHR k))>0
                          THEN lin[(i*8)+k]:=lin[(i*8)+k] OR 1 SHL j;
                    END;
{$R+}
{$IFNDEF verbose}
                FOR i:=1 TO width DO
                  Putpixel(i,y,lin[i])
{$ENDIF}
              END;

          END;

{$IFNDEF verbose}
      WHILE NOT Keypressed DO;
      Closegraph;
{$ELSE}
      Writeln('image  ',LONGINT(width)*Length*planes DIV 8);
      Writeln('bodys  ',h);
      Writeln('files  ',Filesize(f));
      Writeln('filep  ',Filepos(f));
      Writeln('heads  ',Sizeof(dp2h));
      Writeln('virtu  ',vir);
{$ENDIF}
      Close(f);
    END;

END.

(*
deluxe paint ii lbm & iff files

the deluxe paint lbm (AND iff) FILE header (40 bytes) has the following
content:
     struct dp2
     {   CHAR msg1[4];               "form"
         BYTE a3, a2, a1, a0;        FILE Length - 8  (Read left TO right)
         CHAR msg2[8];               "ilbmbmhd"
         BYTE b3, b2, b1, b0;        Length OF header (Read left TO right)
         Int  width, Length, xoff, yoff;
         BYTE planes, masking, compression, pad;
         Int  tansparent;
         BYTE x_aspect, y_aspect;
         Int  screenwidth, screenheight;
     } ;
   there may be a color map following a STRING "cmap" IN the FILE. after cmap
        is the Length OF the color map (4 bytes, Read left TO right). the color
        map is BYTE triples (r, g, b) FOR each colors. the number OF colors is
        1 shifted left by planes (1 << planes).
   the actual picture data follows a STRING "body" AND Length OF the picture
        data (4 bytes Read left TO right). the picture data is organized on a
        color plane basis FOR dp2, AND on a pixel basis FOR dp2e (enhanced).
        thus, FOR dp2:
            there are (width / 8) bytes per row.
            the data stream FOR each row consists OF all the bytes FOR plane 0,
                followed by all the bytes FOR plane 1, etc.
        AND FOR dp2e:
            there are (width) bytes/row, where each BYTE is a pixel color.
   IF the data is uncomperessed (compression flag = 0), the data stream bytes
        are fed TO the OUTPUT unmodified. IF it is compressed, it is run Length
        encoded as follows:
            get a code BYTE from the data stream.
            IF the msb is 1, the 'count' is (1 - code), max = 127. get the next
                BYTE from the data stream, AND REPEAT it 'count' times.
            IF the msb is 0, the 'count' is (1 + code), max = 128. get the next
                'count' bytes from the data stream.
*)

