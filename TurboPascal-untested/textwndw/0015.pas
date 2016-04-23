{
Ok, here comes my window routines. They should be quite fast, and hopefully
not too hard to understand. No range-checking on the screen coordinates is
done (I don't think it's necessary).

The ColorAttr variable is the color-attribute :-). It's used as in the
videomemory. If you want to call the procedure with a separate foreground
and background color (why?), drop me a note and I'll fix it if you can't
do it yourself.

It'll run on a 8086, and I don't want copies optimized with 286 code!

(if this message gets chopped for you -- too bad. Get it from a friend or
tell someone to upload it to a BBS in the US if you want it. Use good
mailing software!)

--------------------------------------------------->8-------------------------

{ Window routines by Jens Larsson (Fido address, 2:201/2120.3), Sweden, PD. }
{ Feel free to use it in your own programs. But do credit me, will you? :-) }
{ Put it in SWAG if you like... }

{$M 1024,0,0}
Uses Crt;

{ The following variable should be assigned at startup to the correct segment }
{ address (b800h or b000h). I've posted a source for doing this before, thus  }
{ it's not included here. }

 Const TextVidSeg : Word = $b800;

   Var ScrBuf, Pdwns : Word;

      Function AllocMemory(Paragraphs : Word) : Word; Assembler;
         Asm
           mov   ax,4800h
           mov   bx,Paragraphs  { Number of 16-byte chunks }
           int   21h
           jnc   @Done          { Ok? }
           mov   ax,4c00h
           int   21h            { If not, halt program! }
@Done:
         End;

      Procedure PullDown(x1, y1, x2, y2 : Word;
                         FrameType,
                         ColorAttr      : Byte;
                         PDName         : String); Assembler;

        Var DeltaX, DeltaY, AddDI : Word;

         Asm
           jmp   @CodeBegin    { Jump to the actual code }

{ Ok Pascal-lovers... I'm sorry, but I declared the data like below...  }
{ Somehow it seemed easier to me (I guess I've used assembler too much) }

@Frame:

{ This is all the ASCII codes for all the possible types of frames }

           db    020h,020h,020h,020h,020h,020h  { '      ' }
           db    0dah,0c4h,0bfh,0b3h,0c0h,0d9h  { '┌─┐│└┘' }
           db    0c9h,0cdh,0bbh,0bah,0c8h,0bch  { '╔═╗║╚╝' }
           db    0d6h,0c4h,0b7h,0bah,0d3h,0bdh  { '╓─╖║╙╜' }
           db    0d5h,0cdh,0b8h,0b3h,0d4h,0beh  { '╒═╕│╘╛' }

@FrameOfs:

{ And this is the offsets to the above structures }

           db    000h,006h,00ch,012h,018h

@CodeBegin:
           cmp   Pdwns,16      { Max pulldowns = 16 (16 * 4096 = 65536) }
           jz    @Done

           cld

{ Calculate start offset }

           mov   di,y1
           dec   di
           mov   ax,di
           mov   cl,5
           shl   di,cl
           mov   cl,7
           shl   ax,cl
           add   di,ax
           mov   ax,x1
           dec   ax
           add   ax,ax
           add   di,ax

           mov   dx,di
           add   dx,4    { This is the offset for the PutName part later }

           mov   ax,x2
           sub   ax,x1
           dec   ax
           mov   DeltaX,ax
           add   ax,2
           mov   bx,80
           sub   bx,ax
           sub   bx,2
           add   bx,bx
           mov   AddDI,bx
           mov   ax,y2
           sub   ax,y1
           dec   ax
           mov   DeltaY,ax

           push  ds
           push  di

           mov   si,di
           mov   di,Pdwns
           mov   cl,12
           shl   di,cl         { Calculate offset in save segment }
           mov   es,ScrBuf     { Save segment -> ES }
           mov   ds,TextVidSeg
           mov   es:[di],si    { Store offset to screen }
           mov   bx,DeltaX
           add   bx,4
           mov   es:[di+2],bx  { Store DeltaX }
           mov   cx,DeltaY
           add   cx,3
           mov   es:[di+4],cx  { Store DeltaY }
           mov   ax,AddDI
           mov   es:[di+6],ax  { Store AddDI }
           add   di,8
@SaveScreen:
           push  cx
           mov   cx,bx
           rep   movsw         { Save line }
           add   si,ax
           pop   cx
           dec   cx
           jnz   @SaveScreen

           pop   di
           pop   ds

           mov   es,TextVidSeg

           xor   bh,bh
           mov   bl,FrameType
           lea   si,@FrameOfs
           add   si,bx
           mov   bl,cs:[si]    { Get offset within frame data }
           lea   si,@Frame
           add   si,bx         { SI points to frame }

           mov   ah,ColorAttr
           mov   al,cs:[si]
           stosw               { Print upper-left corner }
           mov   al,cs:[si+1]
           mov   cx,DeltaX
           rep   stosw         { Print horisontal line }
           mov   al,cs:[si+2]
           stosw               { Print upper-right corner }
           add   di,AddDI
           add   di,4

           push  ds

           xchg  dx,di         { Save DI }
           mov   bx,si         { Save SI }
           lds   si,PDName
           mov   cl,[si]       { Get length of string }
           xor   ch,ch
           mov   ah,ColorAttr
           inc   si
@PutName:
           lodsb               { Get next char }
           stosw               { Print next name-char }
           dec   cx
           jnz   @PutName
           mov   di,dx
           mov   si,bx

           pop   ds

           mov   cx,DeltaY
@PutWindow:
           push  cx
           mov   al,cs:[si+3]  { Get horisontal-line char }
           stosw               { Print... }
           mov   al,20h
           mov   cx,DeltaX
           rep   stosw         { Print some spaces }
           mov   al,cs:[si+3]
           stosw
           mov   al,08h        { Shadow attribute (Bkgr = 0 Frgr = 8) }
           inc   di
           stosb               { Print first shaded char... }
           inc   di
           stosb               { ... and second }
           add   di,AddDI
           pop   cx
           dec   cx
           jnz   @PutWindow

           mov   al,cs:[si+4]
           stosw               { Print lower-left corner }
           mov   al,cs:[si+1]
           mov   cx,DeltaX
           rep   stosw
           mov   al,cs:[si+5]
           stosw               { Print lower-right corner }
           mov   al,08h
           inc   di
           stosb
           inc   di
           stosb
           add   di,AddDI
           add   di,5

           mov   cx,DeltaX
           add   cx,2
@PutLastShadowLine:
           stosb
           inc   di
           dec   cx
           jnz   @PutLastShadowLine

           inc   Pdwns
@Done:
         End;

      Procedure RestoreScreen; Assembler;
         Asm
           cmp   Pdwns,0       { If no pulldowns then exit }
           jz    @Done
           cld
           dec   Pdwns
           mov   si,Pdwns
           mov   es,TextVidSeg
           push  ds
           mov   ds,ScrBuf
           mov   cl,12
           shl   si,cl
           mov   di,[si]       { Load offset to screen }
           mov   bx,[si+2]     { Load DeltaX }
           mov   cx,[si+4]     { ... DeltaY }
           mov   dx,[si+6]     { ... AddDI }
           add   si,8
@PutText:
           push  cx
           mov   cx,bx
           rep   movsw         { Restore line }
           add   di,dx
           pop   cx
           dec   cx
           jnz   @PutText
           pop   ds
@Done:
         End;

{ Short example program }

           Begin
             ScrBuf := AllocMemory(4096);
             TextBackground(4);
             ClrScr;
             PullDown(10,5,70,20,1,$1f,' Window #1 ');
             ReadKey;
             PullDown(5,10,60,22,2,$4e,' Window #2 ');
             ReadKey;
             RestoreScreen;
             ReadKey;
             RestoreScreen;
           End.

