(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0017.PAS
  Description: Simple coppering routine
  Author: SEAN PALMER
  Date: 08-27-93  20:28
*)

{
SEAN PALMER

>Okay, I've got this small problem porting one of my assembler routines
>into pascal.  It's a simple coppering routine (multiple setting of the
>same palette register for trippy effects :), and i can't seem to use it
>in my code..  I'll post the code here now (it's fairly short), and if
>someone could help me out here, i'd be most grateful - since my
>assembler/pascal stuff isn't too great..

I imported it, but couldn't get it to work (several problems in the
source) and in the process of getting it to work (for one thing I didn't
know what it was supposed to accomplish in the first place) I added a
few things to it and this probably isn't what you wanted it to look like
but it wouldn't be hard to do now that it's in TP-acceptable form.

I also added one other small palette flipper that's kind of neat.
}

{$G+}
uses
  crt;

procedure copperBars(var colors; lines : word; regNum, count : byte); assembler;
var
  c2 : byte;
asm
{
  okay, Colors is a pointer to the variable array of
  colours to use (6bit rgb values to pump to the dac)
  Lines is the number of scanlines on the screen (for syncing)
  RegNum is the colour register (DAC) to use.
  valid values are 0-255. that should explain that one.
  Count is the number of cycles updates to do before it exits.
}
  push ds

  mov  ah, [RegNum]
  mov  dx, $3DA   {vga status port}
  mov  bl, $C8    {reg for DAC}
  cli
  cld

 @V1:
  in   al, dx
  test al, 8
  jz   @V1 {vertical retrace}
 @V2:
  in   al, dx
  test al, 8
  jnz  @V2

  mov  c2, 1
  mov  di, [lines]

 @UPDATER:
  mov  bh, c2
  inc  c2
  lds  si, [colors]
                {now,just do it.}
 @NIKE:
  mov  cx, 3
  mov  dl, $DA

 @H1:
  in   al, dx
  and  al, 1
  jz   @H1  {horizontal retrace}

  mov  al, ah  {color}
  mov  dl, bl
  out  dx, al
  inc  dx
  rep  outsb              {186 instruction...}

  mov  dl, $DA
 @H2:
  in   al, dx
  and  al, 1
  jnz  @H2;

  dec  di
  jz   @X
  dec  bh
  jnz  @NIKE
  jmp  @UPDATER
 @X:
  dec  count
  jnz  @V1
  sti                    {enable interrupts}
End;

procedure freakout0(lines : word; count : byte); assembler;
asm
  mov dx, $3DA   {vga status port}
  cli
  cld

 @V1:
  (* in   al, dx
     test al, 8
     jz   @V1 {vertical retrace}
  @V2:
     in   al, dx
     test al, 8
     jnz  @V2
  *)

  mov di,[lines]

 @L:
  mov  dl, $C8
  mov  al, 0  {color}
  out  dx, al
  inc  dx
  mov  al, bh
  out  dx, al
  add  al, 20
  out  dx, al
  out  dx, al
  add  bh, 17
  mov  dl, $DA
  in   al, dx
  test al, 1
  jz   @L;  {until horizontal retrace}

  dec  di
  jnz  @L

  mov  dl, $DA
  dec  count
  jnz  @V1
  sti                    {enable interrupts}
End;

const
 pal : array [0..3 * 28 - 1] of byte =
   (2,4,4,
    4,8,8,
    6,12,12,
    8,16,16,
    10,20,20,
    12,24,24,
    14,28,28,
    16,32,32,
    18,36,36,
    20,40,40,
    22,44,44,
    24,48,48,
    26,52,52,
    26,52,52,
    28,56,56,
    28,56,56,
    30,60,60,
    30,60,60,
    30,60,60,
    33,63,63,
    33,63,63,
    33,63,63,
    33,63,63,
    33,63,63,
    30,60,60,
    28,56,56,
    26,52,52,
    24,48,48);

var
  i : integer;

begin
  asm
    mov ax, $13
    int $10
  end;
  for i := 50 to 149 do
    fillchar(mem[$A000 : i * 320 + 50], 220, 1);

  repeat
    copperBars(pal, 398, 0, 8);  {398 because of scan doubling}
  until keypressed;
  readkey;

  repeat
    freakout0(398, 8);  {398 because of scan doubling}
  until keypressed;
  readkey;

  asm
    mov ax, 3
    int $10
  end;
end.

