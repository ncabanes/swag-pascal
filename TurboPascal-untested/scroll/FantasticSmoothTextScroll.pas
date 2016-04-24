(*
  Category: SWAG Title: SCREEN SCROLLING ROUTINES
  Original name: 0020.PAS
  Description: Fantastic Smooth Text Scroll
  Author: GRANT SMITH
  Date: 05-26-95  23:28
*)

{
From: denthor@goth.vironix.co.za (Grant Smith)

: I was watching an old demo by iguana called heartquake the other day. In
: the very beginning, wher the user could make sound card settings, etc.,
: the was a very smooth vertical text scroll, not char by char, but
: semmingly scanline by scanline. Anyone got any idea on how this was
: done?

Here you go :-) Full source to smooth scroll. For more gfx stuff, check out
my trainer series : http://goth.vironix.co.za/~denthor
                    ftp.eng.ufl.edu /pub/msdos/demos/code/graph/tutor
                    denthor@beastie.cs.und.ac.za Subject : request-list

Byeeee...
  - Denthor / Asphyxia
}

Uses
  Crt;


Procedure Soft;
var i,j,k,old : integer; 
ch : char; 
    f:text; 
    temp:string; 
 
procedure VFine(y:byte); 
assembler; 
asm 
  mov     dx,03dah 
@W2: 
  in      al,dx 
  test    al,8 
  jz      @W2 
{  sti;} 
  mov     dx,03d4h 
  mov     ah,Y 
  mov     al,8 
  out     dx,ax 
end; 

procedure scroff(soffset:integer);
assembler;
asm 
 { cli} 
  mov     dx,03dah 
@W1:
  in      al,dx 
  test    al,8 
  jnz     @W1 
  mov dx,03d4h 
  mov bx,soffset 
  mov ah,bh 
  mov al,00ch 
  out dx,ax 
  mov ah,bl 
  inc al 
  out dx,ax 
 { sti} 
end; 
 
procedure split(Line:word); 
assembler; 
asm 
 mov ax,Line
 shl ax,1 
 mov bl,ah 
 mov ah,al 
 mov bh,bl 
 shr bh,1 
        mov     cl, 6 
 shl bh,cl 
 and bl,1 
        mov     cl,4 
 shl bl,cl 
 mov dx,03d4h 
 mov al,018h 
 out dx,ax 
 mov al,7 
 out dx,al 
 inc dx 
 in  al,dx 
 and al,0ffh-16 
 or  al,bl 
 mov ah,al 
 mov al,7
 dec dx 
 out dx,ax
 
 mov al,9 
 out dx,al 

 inc dx 
 in  al,dx 
 and al,0ffh-64 
 or  al,bh 
 mov ah,al 
 dec dx 
 mov al,9 
 out dx,ax 
end; 
 
 
 
procedure fasttext(x, y : word; col : byte; what : string); 
assembler; 
asm 
      push   ds 
 
      dec    [x]
      dec    [y] 
      mov    ax, 0b800h 
      mov    es, ax 
      mov    ax, [y] 
      mov    bl, 160 
      mul    bl 
      add    ax, [x] 
      add    ax, [x] 
      mov    di, ax 
 
      lds    si, what 
      cld 
      lodsb 
      xor    ch, ch 
      mov    ah, [col] 
      mov    cl, al 
      cmp    cx, 0 
      jz     @@2 
 
 @@1: lodsb 
      stosw
      loop   @@1 

 @@2: 
      pop    ds 
end; 

 
begin 
  textattr := 15; 
  clrscr; 
  split(192); 
  asm 
    mov   ah,01 
    mov   ch,20h 
    int   10h 
  end; 
  j := 0; 
  old := 0; 
  j := 2; 
  scroff (j*80); 
  fasttext (1,1,$1E,'        --==[ Copyright Asphyxia Software, 1994 All Rights Reserved ]==--       ');
  for i := 1 to 24 do BEGIN
    fasttext (1,i+27,$0F,'Denthor / Asphyxia / Coder / +27 31 732129 / denthor@beastie.cs.und.ac.za');
  END; 
 
  for j:=2 to 27 do BEGIN 
    scroff((j-1)*80); 
    for i := 0 to 15 do 
    begin 
      vfine (i); 
      delay(1); 
    end 
  END; 
  while keypressed do readkey; 
  readkey; 
  for j:=28 to 52 do BEGIN 
    scroff((j-1)*80); 
    for i := 0 to 15 do 
    begin 
      vfine (i); 
      delay(1);
    end
  END;
  textmode(co80);
end;

begin
  Soft;
end.


