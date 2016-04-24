(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0045.PAS
  Description: DISPLAY Text in Graphics
  Author: RAPHAEL VANNEY
  Date: 11-26-93  17:01
*)

{
RAPHAEL VANNEY

*You mean displaying Text While in Graphics mode :-) ?

> Yup. Already got a suggestion on using 640x480 With 8x8 font, so if
> you have any other one please do tell.. ttyl...

Sure. Just call the BIOS routines to display Characters With a "standard"
look. By standard look, I mean they look like they were Characters in
Text mode.

Okay, here is the basic Procedure to display a String (Works in any Text/
Graphics mode) :
}

Procedure BIOSWrite(Str : String; Color : Byte); Assembler;
Asm
  les  di, Str
  mov  cl, es:[di]     { cl = longueur chane }
  inc  di              { es:di pointe sur 1er caractre }
  xor  ch, ch          { cx = longueur chane }
  mov  bl, Color       { bl:=coul }
  jcxz @ExitBW         { sortie si Length(s)=0 }
 @BoucleBW:
  mov  ah, 0eh         { sortie TTY }
  mov  al, es:[di]     { al=caractre  afficher }
  int  10h             { et hop }
  inc  di              { caractre suivant }
  loop @BoucleBW
 @ExitBW:
end ;

{
I'm not sure how to manage the background color in Graphics mode ; maybe
you should experiment With values in "coul", there could be a magic bit
to keep actual background color.
}


