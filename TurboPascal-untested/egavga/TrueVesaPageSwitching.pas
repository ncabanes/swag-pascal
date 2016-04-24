(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0225.PAS
  Description: True VESA Page Switching
  Author: JASON RENNIE
  Date: 05-26-95  23:27
*)

{
> I would like to work in 640x480x256 BUT well how?  I mean I know that you
> have acces to 64k at once not the 265k you need.  What MEM location is the
> current work page on?
}
Procedure ChgPage(page : integer);
Begin
  Asm
    mov ax,$4F05
    mov bx,0
    mov dx,page
    int $10
  End;
  currpage := page;
End;
{
The above is the VESA standard for changing pages.  DOS only allocates 64k of
memory to the video, so to access the full 265k of info, you must switch
between 5 different pages to access all the memory.  This isn't the most
efficient procedure considering that it has an int 10h, but at least it will
get you started.
}

