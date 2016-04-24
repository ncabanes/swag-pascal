(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0010.PAS
  Description: Yet another Fader
  Author: EIRIK MILCH PEDERESEN
  Date: 05-28-93  13:39
*)

{
Eirik Milch Pedersen

> I too, would appreciate the source for fading colours in 16 colour text
> mode on a VGA, i've tried my hand at it but can't work out a decent
> algoritm, i've been using int 10h to set a block of colour regs for speed
> but can't seem to work out how to fade the colours!

I replyed to the author of the first fade-question, but I might as well post
my code to the public. This is a little demo I made in TP60 for fading form a
palette to another. So techincal you can fade from anything to anything. :-)
The routine should be fast enough for most computers, but if you start to
see 'snow' on the screen try to reduce the number of colors that are faded.
}

{$G+}
uses
  crt;

type
  ColorType = array[0..255] of record
                                 R, G, B : byte;
                               end;

var
  Colors,
  White,
  Black   : ColorType;

procedure SetMode(Mode : word); assembler;
asm
  mov  ax, Mode
  int  010h
end;

procedure MakeColors(ColorArray : pointer); assembler;
label
  RLoop, GLoop, BLoop;
asm
  les  di, ColorArray

  mov  cx, 85
  xor  al, al
 RLoop:
  mov  byte ptr es:[di+0], al
  mov  byte ptr es:[di+1], 0
  mov  byte ptr es:[di+2], 0
  add  di, 3
  inc  al
  and  al, 03Fh
  loop Rloop

  mov  cx, 85
  xor  al, al
 GLoop:
  mov  byte ptr es:[di+0], 0
  mov  byte ptr es:[di+1], al
  mov  byte ptr es:[di+2], 0
  add  di, 3
  inc  al
  and  al, 03Fh
  loop Gloop

  mov  cx, 86
  xor  al, al
 BLoop:
  mov  byte ptr es:[di+0], 0
  mov  byte ptr es:[di+1], 0
  mov  byte ptr es:[di+2], al
  add  di, 3
  inc  al
  and  al, 03Fh
  loop Bloop
end;

procedure DrawBars; assembler;
label
  LineLoop, PixelLoop;
asm
  mov  ax, 0A000h
  mov  es, ax
  xor  di, di

  mov  cx, 200
 LineLoop:
  xor  al, al
  push cx
  mov  cx, 320
 PixelLoop:
  stosb
  inc  al
  loop PixelLoop

  pop  cx
  loop LineLoop
end;

procedure UpdateColorsSlow(ColorBuffer : pointer); assembler;
label
  ColorLoop;
asm
  push ds

  lds  si, ColorBuffer
  mov  cx, 3*256

  mov  dx, 03C8h
  xor  al, al
  out  dx, al
  inc  dx
 ColorLoop:                         { here is the substitute that }
  lodsb                      { goes round the problem.     }
  out  dx, al
  loop ColorLoop

  pop  ds
end;

procedure UpdateColorsFast(ColorBuffer : pointer); assembler;
asm
  push ds

  lds  si, ColorBuffer
  mov  cx, 3*256

  mov  dx, 03C8h
  xor  al, al
  out  dx, al
  inc  dx

  rep  outsb              { here is the cause of the problem. }

  pop  ds
end;


procedure FadeColors(FromColors, ToColors : Pointer;
                     StartCol, NoColors, NoSteps : byte); assembler;
label
  Start, DummyPalette, NoColorsX3,
  DummySub, StepLoop, ColorLoop,
        SubLoop, RetrLoop1, RetrLoop2, Over1, Over2;
asm
        jmp        Start
 DummyPalette:
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 DummySub:
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 NoColorsX3 :
  dw          0
 Start:
        push ds

        lds         si, ToColors
  les         di, FromColors
  xor  ch, ch
  mov         cl, NoColors
  shl         cx, 1
  add         cl, NoColors
  adc  ch, 0
  mov         word ptr cs:[NoColorsX3], cx
  mov         bx, 0
  push di
 SubLoop:
        lodsb
        sub         al, byte ptr es:di
        mov         byte ptr cs:[DummySub+bx], al
  inc         di
  inc         bx
        loop SubLoop
  pop         di

  push cs
  pop         ds
        mov         dh, 0
  mov  dl, NoSteps
 StepLoop:
  push di
  mov         cx, word ptr cs:[NoColorsX3]
  mov         bx, 0
 ColorLoop:
  xor         ah, ah
        mov         al, byte ptr cs:[DummySub+bx]
  or         al, al
  jns         over1
  neg         al
 over1:
  mul         dh
  div         dl
  cmp  byte ptr cs:[DummySub+bx], 0
  jge         over2
  neg         al
 over2:
  mov         ah, byte ptr es:[di]
  add         ah, al
  mov         byte ptr cs:[DummyPalette+bx], ah
  inc         bx
  inc         di
  loop ColorLoop

  push dx
  mov  si, offset DummyPalette
  mov  cx, word ptr cs:[NoColorsX3]

  mov  dx, 03DAh
 retrloop1:
  in          al, dx
  test al, 8
  jnz  retrloop1
 retrloop2:
  in          al, dx
  test al, 8
  jz   retrloop2

  mov  dx, 03C8h
  mov  al, StartCol
  out  dx, al
  inc  dx
  rep         outsb

  pop         dx

  pop         di
  inc         dh
  cmp         dh, dl
  jbe         StepLoop

  pop         ds
end;



begin
  ClrScr;
  MakeColors(@Colors);
  FillChar(Black, 256 * 3, 0);
  FillChar(White, 256 * 3, 63);

  SetMode($13);
  UpdateColorsSlow(@Black);
  DrawBars;

  REPEAT
    FadeColors(@Black, @Colors, 0, 255, 100);
    FadeColors(@Colors, @White, 0, 255, 100);
    FadeColors(@White, @Colors, 0, 255, 100);
    FadeColors(@Colors, @Black, 0, 255, 100);
  UNTIL keyPressed;

  SetMode($3);
END.

