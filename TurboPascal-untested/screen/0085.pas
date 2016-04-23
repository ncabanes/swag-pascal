{
From: sean.palmer@delta.com (Sean Palmer)

>Here it is, the latest collection of VGA 80 character text modes. So fa
>have been able to collect 14 text modes, 10 of them being actually usef
>(i.e. 25x80 or larger). The plum in the pudding is a 60x80 character te
>mode, for people who are really desperate to spoil their eyes. All the
>modes should operate on standard VGA cards.

Cool.

>Have fun, and let me (or the newsgroup) know of any suggestions, bugs o
>improvements you might have. I have heard rumours of x90 character mode
>Anybody know about that? If it gets rid of the 1 pixel spacing between
>character cells, wouldn't all the letters run together?

No. They have 2 pixel gaps normally.

Once you turn off 9th bit padding, you have to adjust the bios save data
area appropriately or it freaks out.
}

const HorizParms:array[0..1,0..6]of word=
 (($6A00,$5901,$5A02,$8D03,$6004,$8505,$2D13),
  ($5F00,$4F01,$5002,$8203,$5504,$8105,$2813));

procedure SetCharWidth(w:word); assembler; asm
 mov ax,$40; mov es,ax;
 mov dx,es:[$63];  {locate CRTC}
 mov al,$11; out dx,al; inc dx; in al,dx; dec dx;
 mov ah,al; mov al,$11; push ax; and ah,$7F; out dx,ax; {no write protect}
 mov bx,w; sub bl,8; neg bx; and bx,14; lea si,horizParms[bx];
 mov cx,7
@L: lodsw; out dx,ax; loop @L;
 pop ax; out dx,ax; {restore write protect}
 mov dx,$3C4;   {sequencer}
 cli
 mov ax,$100; out dx,ax;
 mov bx,1; cmp byte ptr w,8; je @S; mov bx,$800; @S:
 mov ah,bl; mov al,1; out dx,ax;
 mov ax,$300; out dx,ax;
 sti
 xor dx,dx; mov ax,720; div w; mov es:[$4A],ax;  {set bios cols}
 end;

var i:word;

begin
 setCharWidth(8);
 writeln('Hellacious dude!');
 for i:=1 to 9 do write('!---------');
 readln;
 setCharWidth(9);
 writeln('Hellacious dude!');
 for i:=1 to 9 do write('!---------');
 readln;
 asm mov ax,3; int $10; end;
end.
