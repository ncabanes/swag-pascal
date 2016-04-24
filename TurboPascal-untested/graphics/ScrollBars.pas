(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0124.PAS
  Description: Scroll Bars
  Author: BAS VAN GAALEN
  Date: 08-24-94  13:56
*)

USES dos, crt;

CONST
    v_vidseg   : WORD = $B800;  { $B000 for mono }
    v_columns  : BYTE = 80;     { Number of CRT columns }

VAR
    x : BYTE;
{
the dspat routine, as you can see.  Displays a string QUICKLY
If 'Col' (=columns, NOT color) is negative (-1) the centence will be centered.
Works also in exotic screenmodes, like 132x44, 100x44 or whatever you like.
}
procedure dspat(Str : string; Col : integer; Row,Attr : byte); assembler;
asm
  push ds          { Save Turbo's DS }
  mov es,v_vidseg  { Place VideoBuffer in es }
  xor dh,dh        { Clear DH }
  mov dl,v_columns { Bytes per row }

  lds si,Str       { DS:SI pts to Str }
  xor cx,cx        { clear CX }
  mov cl,[si]      { String len counted in CX }
  jcxz @l5         { If null, quit }
  inc si           { Point DS:SI to first char }

  mov ax,Col       { Get Column value }
  cmp ax,0
  jge @l6          { Absolute, or centered? }

  mov ax,dx
  sub ax,cx        { Substract stringlen from total }
  shr ax,1         { Centre}

 @l6:
  mov di,ax
  shl di,1         { Double for attributes }

  mov al,Row       { Get Row value }
  mul dl           { Times rows }
  shl ax,1

  add di,ax        { ES:DI pts to lst pos }
  cld              { Direction flag forward }
  mov ah,Attr      { Get Attribute }
 @l1:
  lodsb            { Get a character}
  stosw            { Write it with attribute }
  loop @l1         { Go do next }
 @l5:
  pop ds           { Restore DS and quit }
end;

procedure filltext(Dir : char; X1,Y1,X2,Y2,Col : byte); assembler;
asm
  push ds          { Save Turbo's DS }

  xor dh,dh        { Clear DH }
  mov dl,v_columns { Bytes per row (number of columns) }

  xor ah,ah
  mov es,v_vidseg  { Place VideoBuffer in ES and DS }
  mov al,[X1]
  mov di,ax
  shl di,1         { Double for attributes }
  mov al,[Y1]      { Get Row value }
  mul dl           { Times rows }
  shl ax,1
  add di,ax        { ES:DI pts to upperleft corner }

  xor ch,ch
  mov cl,[X2]
  inc cl
  sub cl,[X1]      { Number of bytes to move in CL (columns) }
  xor bh,bh
  mov bl,[Y2]
  inc bl
  sub bl,[Y1]      { Number of rows to move in BL }

  sub dl,[X2]      { Substract right site }
  dec dl
  shl dx,1         { Times two for attribs }
  xor ah,ah        { Clear AH }
  mov al,[X1]      { Left site }
  shl ax,1         { Times two for attribs }
  add dx,ax        { Calculated difference between last col - first col }

  mov al,[Dir]
  mov ah,[Col]

  cld              { Direction flag forward }
 @L1:
  push cx
  rep stosw
  pop cx
  add di,dx
  dec bl
  jnz @L1

  pop ds           { Restore DS and quit }
end;

{ Displays Veritical scrollbar }
procedure ScrollBar(BarXPos,
                    BarYPos : byte;
                    CurPos,
                    ScrLen,                     { max screen row }
                    NofItems : word;
                    ColAttr : byte);
var barpos,maxpos : word;
begin
  dspat(#30,barxpos,barypos,colattr);
  dspat(#31,barxpos,barypos+scrlen-1,colattr);
  filltext('▒',barxpos,barypos+1,barxpos,barypos+scrlen-2,colattr);
  if nofitems >= 1 then begin
    maxpos := scrlen-3;
    if nofitems <> 1 then barpos := round(((curpos-1)/(nofitems-1))*maxpos)
    else barpos := 0;
    dspat('■',barxpos,barypos+barpos+1,colattr);
  end;
end; { ScrollBar }

BEGIN  { demo coded by Gayle Davis for SWAG 8/18/94 }

   ClrScr;
   { put at col 40 of Row x, 3rd item selected }

   FOR X := 1 to 24 DO
       BEGIN
       ScrollBar(40,1,x,22,40,31);
       DELAY(300);
       END;

END.

The assembler stuff is nicely documented, so shouldn't be a problem. What's
missing here, you can define as constants at the top of your source, or try to
find out using interrupt-calls or whatever...

Btw: these routines are taken from my very private video-unit, and seem to work
on many different configurations (so far...) But that's also due to the fact
that the v_columns is found through some interrupt-calls and stuff...
The routines work also in 132x44 or whatever strange video-mode.

Another point of discussion: no snow-checking is performed. I got in some
anoying discussions about this, because (imho) CGA's are hardly used these
days. So it seems a little ... nuts ... to make support for that hand full of
CGA-users. Ah well, enclose the sc yourself. it's not hard, but it REALY slow's
stuff down. And these routines were designed with SPEED as first concern and
compatibily with MODERN hardware as a second...

 _    _
|_]  | _
|__].|__].

