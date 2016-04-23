>> I need to put a 64k Raw Image onto Page 0 in 320x200 X-Mode.
>
> Bas van Gaalen
>Well, that wasn't too hard. Faster then the following one doesn't seem
>possible. Don't try to make the f_bufsize too large: it'll probably hang your
>computer and it won't speed up the picture display. You could, however, set the
>palette to all black when displaying the picture, and when it's ready, set the
>colors of the picture correctly.

Actually, you can make it a lot faster.
Since I haven't seen the original post, there is no way for me to know what
you need this for, but to speed up execution speed, I've divided it into
two files, raw2mxi, and viewmxi.  If it is intended for a viewer (but
then you wouldn't use mode X at all, I guess), there should be no problems
rewriting it, sorry for the slow disk read/write routines, but I'm a little
rusty in Pascal. (Haven't used it the last half year.)
There is two differences, one I write to the change plane ports 4 times
while van Gaalen wrote to the ports each time he drew a pixel, and when I
draw, I just use int 21 (Yes, I know this might be slower, but on slower
machines, you may actually gain speed on slower systems because the DOS
file handler uses DMA to write directly to the memory area.

---------- cut here ----------- start ---------------- raw2mxi.pas ------------

{$A+,B-,D+,E+,F-,G+,I+,L+,N+,O-,P-,Q-,R-,S+,T-,V+,X+} { TP7.0 Directives }
{$M 16384,0,655360}


PROGRAM OptimizeImageForModeX;
{ Program to optimize raw images for mode X, written by Kjetil Furnes, AKA
  ShadowBeam. E-Mail: hefurnes@online.no
  it assumes that the given file is a raw image without a header (i.e. it
  only contains the pixel color information. I leave it up to the coder to
  add the pallette since he wanted it to be a raw image (for the uninitated,
  a raw image is basically a string of bytes. There is nothing that indicates
  the pallette, the size of the image or anything.

  And yes, I know I could probably optimize this code a lot, but I'm lazy :)
  and this doesn't affect run-time of the other part of the program.
}


USES
  CRT, DOS;

VAR
  f: FILE OF BYTE;
  T: FILE OF BYTE;

  buffer: ARRAY[0..63999] OF BYTE;
  ca, cb, cc: WORD;



FUNCTION InFile(FileName: PathStr): BOOLEAN;
BEGIN
  IF FileName = '' THEN BEGIN
    WriteLn('Please supply a raw-image filename.');
    InFile := False;
    Exit;
  END;
  Assign(f, FileName);
  {$I-} Reset(f); {$I+}
  IF IOResult <> 0 THEN BEGIN
    WriteLn(fexpand(filename) + ' not found.');
    InFile := False;
    Exit;
  END;
  ASM
    push DS
    mov BX, SEG f
    mov DS, BX
    lea BX, [f]
    mov BX, [BX]
    pop DS
    lea DX, [buffer]

    mov BX, SI
    mov AH, 3Fh
    mov CX, 16000
    int 21h

  END;
  FOR ca := 0 TO 63999  DO Read(f, buffer[ca]);
  Close(f);
  InFile := True;
END;


PROCEDURE OutFile(P: PathStr);
VAR D: DirStr; N: NameStr; E: ExtStr;

BEGIN
  FSplit(P, D, N, E);
  E := '.mxi';
  P := D + N + E;
  Assign(T, P);
  rewrite(T);
  FOR cc := 0 TO 3 DO BEGIN
      cb := cc;
    FOR ca := 0 TO 15999 DO BEGIN
        Write(T, buffer[cb]);
        cb := cb + 4;
    END;
  END;
  Close(T);
  WriteLn('File was successfully completed.');
END;


BEGIN
  IF InFile(ParamStr(1)) THEN OutFile(ParamStr(1));
END.

---------- cut here ------------ end ----------------- raw2mxi.pas ------------
---------- cut here ----------- start ---------------- mxidraw.pas ------------

{$A+,B-,D+,E+,F-,G+,I+,L+,N+,O-,P-,Q-,R-,S+,T-,V+,X+} { TP7.0 Directives }
{$M 16384,0,655360}


PROGRAM DrawModeXImage;
{ Program to display mxi images in mode X 320x200x256, written by Kjetil
  Furnes, AKA ShadowBeam. E-Mail: hefurnes@online.no
  it assumes that the given file is a mxi image, that is, a raw image
  converted by the raw2mxi (and in case you are wondering. Mode X Image)

  Oh, and close an image file before you open another, you don't have an
  endless amount of file allocation space.
}
uses
  CRT, DOS;

var
  f: FILE OF BYTE;
  video    :ARRAY [0..63999] OF BYTE ABSOLUTE $0A000:$0;
  ca, cb, cc: WORD;


PROCEDURE SetModeX; ASSEMBLER;
ASM
    mov AX, 13h;
    int 10h;
    mov DX, 3C4h;
    mov AX, 0604h;
    out DX, AX;
    mov AX, 0F02h
    out DX, AX;
    mov CX, 64000;
    mov AX, 0A000h;
    mov ES, AX
    xor AX, AX;
    mov DI, AX;
rep stosw
    mov DX, 3D4h;
    mov AX, 0014h;
    out DX, AX;
    mov AX, 0E317h;
    out DX, AX;
END;

PROCEDURE Retrace; ASSEMBLER;
ASM
    mov DX, 3DAh;
@V1:
    in AL, DX;
    test AL, 8;
    jz @V1
@V2:
    in AL, DX;
    test AL, 8;
    jnz @V2;
END;




FUNCTION LoadMXI(FileName: PathStr): BOOLEAN;
BEGIN
  IF FileName = '' THEN BEGIN
    WriteLn('Please supply a mxi-image filename.');
    LoadMXI := False;
    Exit;
  END;
  Assign(f,FileName);
  {$I-} Reset(f); {$I+}
  IF IOResult <> 0 THEN BEGIN
    WriteLn(fexpand(filename) + ' not found.');
    LoadMXI := False;
    Exit;
  END;
  LoadMXI := True;
END;


PROCEDURE DrawMXI;
BEGIN
  ASM
    push DS
    push SI
    mov SI, SEG f
    mov DS, SI
    lea SI, [f]
    mov SI, [SI]
    mov AX, 0A000h
    mov DS, AX

    mov DX, 03C4h;
    mov AX, 102h;
    out DX, AX;

    xor DX, DX
    mov BX, SI
    mov AH, 3Fh
    mov CX, 16000
    int 21h

    mov DX, 03C4h;
    mov AX, 202h;
    out DX, AX;

    xor DX, DX
    mov BX, SI
    mov AH, 3Fh
    mov CX, 16000
    int 21h

    mov DX, 03C4h;
    mov AX, 402h;
    out DX, AX;

    xor DX, DX
    mov BX, SI
    mov AH, 3Fh
    mov CX, 16000
    int 21h

    mov DX, 03C4h;
    mov AX, 802h;
    out DX, AX;

    xor DX, DX
    mov BX, SI
    mov AH, 3Fh
    mov CX, 16000
    int 21h

    pop SI
    pop DS
  END;
  Reset(f);
END;


BEGIN
  IF LoadMXI(ParamStr(1)) = FALSE THEN Exit;
  SetModeX;
  Retrace;

  DrawMXI;

  ReadKey;
  Close(f);
END.

---------- cut here ------------ end ----------------- mxidraw.pas ------------


That's all I guess.

Just to be on the safe side:
I'm allowing anyone to use this code without any restrictions or legalities,
except that the one who compiles this code takes responsibility for what
happens with the machine, this code will work if the machine is set up
correctly, but I don't know how it'll work on a machine without a vga
compatible device connected since the code write to some of its prots.


						- Kjetil Furnes