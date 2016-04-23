{
>> 1. Scrolling 256c fonts Fast and Smooth.
>> 2. Now to do it on top of graphics...
>> 3. 3D object engine - If someone can post me one or direct me
>> to build one.
>> 4. Shade Bobs/Whatever it called - Taking a shape and moving it
>> across the screen when it leaves trail.  Then, moving again
>> on the trail will couse a stronger color to appear. n' on...
>> 5. Moving floor that is NOT a couse of a palette rotetion.
>> 6. 2D Scale procedure.
>> 7. Centered Stars. And SMOOTH ones.
>> 8. Vector Balls

I don't want to give it all away, but I just made some Shaded-bobs (or
whatever). It realy isn't difficult. It worked right away. Now YOU make a nicer
sin-curve and palette. Here's some source:
}

{$G+}

program ShadingBobs;
const
  Gseg : word = $a000;
  Sofs = 75; Samp = 75; Slen = 255;
  SprPic : array[0..15,0..15] of byte = (
    (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0),
    (0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0),
    (0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0),
    (0,0,1,1,1,1,1,2,2,1,1,1,1,1,0,0),
    (0,1,1,1,1,1,2,2,2,2,1,1,1,1,1,0),
    (0,1,1,1,1,2,2,3,3,2,2,1,1,1,1,0),
    (1,1,1,1,2,2,3,3,3,3,2,2,1,1,1,1),
    (1,1,1,1,2,2,3,4,4,3,2,2,1,1,1,1),
    (1,1,1,1,2,2,3,3,3,3,2,2,1,1,1,1),
    (0,1,1,1,1,2,2,3,3,2,2,1,1,1,1,0),
    (0,1,1,1,1,1,2,2,2,2,1,1,1,1,1,0),
    (0,0,1,1,1,1,1,2,2,1,1,1,1,1,0,0),
    (0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0),
    (0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0),
    (0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0),
    (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0));
type SinArray = array[0..Slen] of word;
var Stab : SinArray;

procedure CalcSinus; var I : word; begin
  for I := 0 to Slen do Stab[I] := round(sin(I*4*pi/Slen)*Samp)+Sofs; end;

procedure SetGraphics(Mode : word); assembler; asm
  mov ax,Mode; int 10h end;

function keypressed : boolean; assembler; asm
  mov ah,0bh; int 21h; and al,0feh; end;

procedure DrawSprite(X,Y : integer; W,H : byte; Sprite : pointer); assembler;
asm
  push ds
  lds si,[Sprite]
  mov es,Gseg
  cld
  mov ax,[Y]
  shl ax,6
  mov di,ax
  shl ax,2
  add di,ax
  add di,[X]
  mov bh,[H]
  mov cx,320
  sub cl,[W]
  sbb ch,0
 @L:
  mov bl,[W]
 @L2:
  lodsb
  or al,al
  jz @S
  mov dl,[es:di]
  add dl,al
  mov [es:di],dl
 @S:
  inc di
  dec bl
  jnz @L2
  add di,cx
  dec bh
  jnz @L
  pop ds
end;

procedure Retrace; assembler; asm
  mov dx,3dah;
  @l1: in al,dx; test al,8; jnz @l1;
  @l2: in al,dx; test al,8; jz @l2; end;

procedure Setpalette;
var I : byte;
begin
  for I := 0 to 255 do begin
    port[$3c8] := I;
    port[$3c9] := I div 3;
    port[$3c9] := I div 2;
    port[$3c9] := I;
  end;
end;

procedure Bobs;
var X,Y : integer; I,J : byte;
begin
  I := 0; J := 25;
  repeat
    X := 2*Stab[I]; Y := Stab[J];
    inc(I); inc(J);
    Retrace;
    DrawSprite(X,Y,16,16,addr(SprPic));
  until keypressed;
end;

begin
  CalcSinus;
  SetGraphics($13);
{  SetPalette;}
  Bobs;
  SetGraphics(3);
end.

{ DrawSprite procedure taken from Sean Palmer (again).
  It contained some minor bugs: [X] was added to AX, should be DI, and
  jz @S was jnz @S, so the sprite wasn't drawn. Now it is...
  And of course it was changed to INCREASE the video-mem, not to poke it.

  If you get rid of the Retrace it goes a LOT faster. }

