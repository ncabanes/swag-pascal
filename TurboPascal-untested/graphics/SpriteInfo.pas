(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0064.PAS
  Description: Sprite Info
  Author: HARALDS JAKOVELS
  Date: 01-27-94  12:22
*)

{
> Another problem is plotting sprites with "invisible" pixels.  In other
> words, all pixels in the sprite are plotted except for ones with a color
> of 255 (I think I've heard that Origin used this method in Ultima 6).
> Because of my unsuccessful try with asm earlier, I didn't even bother to
> try this in asm.  Unfortunately, the following is MUCH too slow:

try this!
}
uses crt;
type SpriteType = array[0..15,0..15] of byte;

var sprite : spritetype;
    f : file of spritetype;     {sprite's image is stored in file}
    x, y : word;

procedure putinvspriteinasm(x, y : word; sprite : spritetype);
var p : pointer;
    segm, offs : word;
    {these are used to calculate destination address
     in video memory}

begin
  p := addr(sprite[0,0]);
  {this pointer is used only to cheat tp. tp doesn't allow to use addr or
   @ operators in inline asm - or i don't know how to do it}
  segm := $a000 + (320 * y) div 16;
  offs := x;
  {segm:offs is address of upper left corner of sprite in video RAM}
      asm
          push   ds
  {ds is one of the important registers in tp and must be saved}
          lds    si, p
  {ds:si now is source address for sprite's array}
          mov    es, segm
          mov    di, offs
  {es:di now is target address in VRAM}
          mov    bh, 16
  {counter for outer loop}
@loop2:   mov    bl, 16
@loop1:   mov    al, [ds:si]
  {innner loop (marked with label @loop1) is used to draw each line of
   sprite}
          cmp    al, $ff
   {make sure if pixel is $ff or not}
          je     @skip
   {it is - so we don't draw it}
          mov    [es:di], al
   {no, it's not - draw!}
@skip:    inc    si
          inc    di
          dec    bl
          jnz    @loop1
   {we haven't finished to draw this line if bl > 0}
          dec    bh
   {we haven't finished to draw all image if bh > 0}
          jz     @end
          add    di, 320 - 16
   {calculate beginning of next line}
          jmp    @loop2
@end:
          pop    ds

      end
end;

begin
  asm mov ax, 0013h
      int 10h
  end;
  assign(f, 'sprite');
  reset(f);
  read(f, sprite);
  close(f);
  randomize;
  repeat
    x := random(320);
    y := random(200);
    putinvspriteinasm(x, y, sprite);
  until keypressed;
end.
{
i added into code some quick'n'dirty comments to let you understand
how assembly works. i've tested this code and found that it won't work with
Microsoft's workgrp.sys driver - the programm simply crashes when you press a
key. (workgrp.sys driver is one of the Windows for Workgroups drivers).
strange... with all other things (qemm386, lan drivers etc.) programm seems to
work fine. one more thing i must add that better is to pass to procedure
putsprite not array with sprite's data but only pointer to it - because tp
moves all this data around memory - and in this case it's 256 bytes.
}

