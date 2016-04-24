(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0192.PAS
  Description: A Putpixel Benchmark
  Author: ANDREAS JUNG
  Date: 11-22-95  13:21
*)

{
> It seems that the location of the routine in the program also affects
> its performance.  The one closest to the main procedure always seems to
> win. This probably has to do something with caching...

No, I have made many tests ( 3 hours spending on it ) and my results are :
First : The Procedure relative to the main programm has NO affect one the
preformance ( atleast with small programms ).
My System look like this :
        486 DX 50 with 256 kb Cache
        ISA ET4000 W32 VGA-Card
        16 MB RAM

> These numbers are too small to compare, try setting N to 50, and
> swap the position of the routines sometimes. You'll get many different
> results.

Sorry, but when I was testing the routines I had set N to 1000 !!! That
should be big enough.. Well since Jannie Hanekom wrote me a message, I made
again some test and these are my results :

 ( numbers have no meaning, higher is better ,  N = 1000 )
 pix1 :   59,68 M  ( Mem in Pascal )
 pix2 :  158,00 M  ( with lookup table, old proc )
 pix3 :  170,35 M  ( without lookup table )
 pix4 :  186,37 M  ( with lookup table, NEW proc )
 pix5 :  153,31 M  ( with lookup table, optimized by Jannie Hankom
                     trying to reduce penalty cycles, while Memory access )
 pix6 :  213,57 M  ( with lookup table, from Jannie Hanekom,
                     optimized by me )
     { M = Million }


{$A+,B-,D+,E+,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T-,V+,X+,Y+}
{$M 16384,0,655360}

const N = 1000;

var lut : array[0..199] of word;

procedure call(x,y:word; c:byte); begin end;

procedure pix1(x,y:word; c:byte); begin mem[$A000:x+y*320] := c end;

procedure pix2(x,y:word; c:byte); assembler;
asm
 mov ax,0A000h
 mov es,ax
 mov bx,y
 add bx,bx
 mov si,x
 mov bx,word ptr lut[bx]
 mov al,c
 mov es:[bx+si],al
end;

procedure pix3(x,y:word; c:byte); assembler;
asm
 mov ax,0A000h
 mov es,ax
 mov ah,byte ptr y
 mov bx,x
 add bx,ax
 shr ax,2
 add bx,ax
 mov al,c
 mov es:[bx],al
end;

procedure pix4(x,y:word; c:byte); assembler;
{ code from  Andreas Jung  }
asm
 mov ax,0A000h
 mov es,ax
 mov bx,y
 add bx,bx
 mov si,x
 mov bx,word ptr lut[bx]
 mov al,c
 add bx,si
 mov es:[bx],al
end;


Procedure Pix5(X, Y : Word;  C : Byte);  Assembler;
{ code from  Jannie Hanekom  }
Asm
  mov  bx, Y
  add  bx, bx
  mov  es, SegA000
  mov  bx, word ptr lut[bx]  { Note:  BX not changed within 2 cycles }
  add  bx, X
  mov  al, C
  mov  byte ptr es:[bx], al  { Again 1 cycle before memory move }
End;


Procedure Pix6(X, Y : Word;  C : Byte);  Assembler;
{ code from  Jannie Hanekom  }
{ optimized by  Andreas Jung }
Asm
  mov  bx, Y
  add  bx, bx
  mov  ax, 0A000h
  mov  es, ax
  mov  bx, word ptr lut[bx]  { Note:  BX not changed within 2 cycles }
  mov  cx, x
  add  bx, cx
  mov  al, C
  mov  byte ptr es:[bx], al  { Again 1 cycle before memory move }
End;

var time:longint absolute $0:$46c; t,c,p1,p2,p3,p4:longint; i:word;

begin
 write('Filling Look-Up Table');
 for i := 0 to 199 do lut[i] := i*320;

 write(#13#10'Timing Procedure Call');
 randseed := 0; c := 0; t := time; while t = time do; inc(t,N);
 repeat call(random(320),random(200),random(256)); inc(c)
 until time = t;

 asm mov ax,13h; int 10h end;

 randseed := 0; p1 := 0; t := time; while t = time do; inc(t,N);
 repeat pix1(random(320),random(200),random(256)); inc(p1)
 until time = t;


 asm mov ax,03h; int 10h end;

 writeln('1 : ',1/(1/p1-1/c):0:0);

end.


Jannie Hanekom said correctly, if a register is changed one cycle befor a
memory move is made with this register, the processor will make one penalty
cycle to calculate the adress. So you must always try to do such a thing :

  add  bx, cx                   { calc offset to pixel in Mem }
  mov  al, C                    { do some thing else, so the processor can
                                  calc the offset in Mem }
  mov  byte ptr es:[bx], al     { Now you wont get a penalty cycle, because
                                  you have changed bx 2 cycles befor the
                                  Mem move !! }

If you would use this code, you WOULD get a penalty cycle :
  mov  al, C
  add  bx, cx
  mov  byte ptr es:[bx], al
Because you have changed the bx one cycle befor the mem move..

It would be very interessting to know which results you get on your
computer, because pix6 is now the FASTEST routine to put a pixel in
320x200x256 !! Try these thing with N = 1000, so you wont get much
diffrents between two tests..

BTW, if you have found any faster routines, let me know !!!! I'm realy
interessted in this !!

Greetings,
            Andreas.


