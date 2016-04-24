(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0076.PAS
  Description: Screen grabber
  Author: JOHN BALDWIN
  Date: 11-26-94  05:06
*)

{
RH>Is there a method to put a whole screen (640X480X16) in a
RH>file.
RH>I have tried to make a function but it only works with the
RH>colors
RH>black and white.

Here's some code:
}
procedure copy_screen(var f:file);

type data=array[0..65534] of byte;

Var p:^data;

begin
   new(p); rewrite(f,1);
   asm
      mov es,0b800h
      xor di,di
      mov cx,32767^[B
      push ds
      lds si,[p]
      cld
      rep movsw
      pop ds
   end;
   blockwrite(f,p^,65536);
   asm
      mov es,0b801h
      xor di,di
      mov cx,32767
      push ds
      lds si,[p]
      cld
      rep movsw
      pop ds
   end;
   blockwrite(f,p^,65536);
   asm
      mov es,0b802h
      xor di,di
      mov cx,11263
      push ds
      lds si,[p]
      cld
      rep movsw
      pop ds
   end;
   blockwrite(f,p^,11264);
   close(f);
   dispose(p);
end;

Now there is a chance that I've screwed up somewhere, so if this doesn't work
right let me know, also let me know if you want a routine to read a screen back
into video memory.  Good Luck!
John Baldwin

