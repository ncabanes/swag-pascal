(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0021.PAS
  Description: Fast Direct Screen Writes
  Author: SEAN PALMER
  Date: 07-16-93  06:05
*)

(*
===========================================================================
 BBS: Canada Remote Systems
Date: 06-22-93 (23:10)             Number: 27381
From: SEAN PALMER                  Refer#: NONE
  To: LOU DUCHEZ                    Recvd: NO
Subj: FAST DIRECT WRITES             Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
LD>SP>I've optimized it a little, if you're interested... 8)

LD>SP>procedure qwrite(x, y: byte; s: string; f, b: byte);

LD>Interesting optimizations -- do I assume that Inc, Dec, Pred, and Succ
LD>are faster than I had ever imagined?  (Shoot, I always figured they'd be
LD>a lot slower than normal arithmetic!)  Thanks!

Succ and Pred are faster for byte-sized ordinals (at least in TP 6.0)
than +1 and -1. The same for word-size. See, with +1 and -1, the byte
gets converted into a word first, but with Succ() and Pred() it
stays a byte... Inc(I) is faster than I:=I+1 or I:=Succ(I) stuff in 6.0
but I think 7.0+ optimize them all to the same code...not sure, I don't
have 7.0...8(

Actually the fastest part of what I did is to pre-calculate the
attribute as the hi byte of a word, and use word stores instead of byte
stores. Could be done alot faster in assembly (don't access any
memory-based variables that way, it's all in registers..8)

Here is a direct screen write unit I wrote in BASM. VERY fast...
*)

{$A-,B-,S-,V-X+}
unit Direct;
interface

CONST
 vSeg:word=$B800;  {change for mono}

VAR
  VMode   : BYTE ABSOLUTE $0040 : $0049; { Video mode: Mono=7, Color=0-3 }
  ScrCols : WORD ABSOLUTE $0040 : $004A; { Number of CRT columns (1-based) }

{in following parms, s=source,d=destination,n=count, words are offsets
 into video memory (you calculate them with ((y*80+x)*2)}
{I did this mainly so less parms would have to be sent, as TP does a
 good job of the arithmetic for that expression...Oh well if you really
 don't like it I could make these use x and y coords, but this was
 basically chopped from another project of mine..}

procedure moveScr(s,d,n:word);    {one part of screen to another}
procedure toScr(var s;d,n:word);  {from string to video ram}
procedure toScrA(var s;d,n:word;a:byte); {ditto with attribute also}
procedure fillScr(d,n:word;c:char);      {mainly useful for rows}
procedure fillAttr(d,n:word;a:byte);     {ditto}

{ I added the following to make this GREAT code more useful for us hackers !!}
{ Gayle Davis 06/26/93 }

function  ScreenAdr (Row,Col : Byte) : WORD;
procedure Qwrite(Row, Col, Attr: byte; S: string);

implementation


procedure moveScr(s,d,n:word);assembler;asm
 mov cx,n; jcxz @X;
 push ds; mov ax,vSeg; mov es,ax; mov ds,ax;
 mov si,s; shl si,1;
 mov di,d; shl di,1;
 cmp si,di; jb @REV;  {move in reverse to prevent overwrite}
 cld; jmp @GO;
@REV: std; shl cx,1; add si,cx; add di,cx; shr cx,1; {start at end}
@GO: repz movsw; {move attr too!}
 pop ds;
@X:
 end;

procedure toScr(var s;d,n:word);assembler;asm
 mov cx,n; jcxz @X;
 push ds; mov es,vSeg;
 mov di,d; shl di,1;
 lds si,s; cld;
@L: movsb; inc di; loop @L;
 pop ds;
@X:
 end;

procedure toScrA(var s;d,n:word;a:byte);assembler;asm
 mov cx,n; jcxz @X;
 push ds; mov es,vSeg;
 mov di,d; shl di,1;
 lds si,s; cld;
 mov al,a;  {attribute}
@L: movsb; {doesn't affect al reg}
 stosb; loop @L;
 pop ds;
@X:
 end;

procedure fillScr(d,n:word;c:char);assembler;asm
 mov cx,n; jcxz @X;
 mov es,vSeg;
 mov di,d; shl di,1;
 mov al,c; cld;
@L: stosb; inc di; loop @L;
@X:
 end;

procedure fillAttr(d,n:word;a:byte);assembler;asm
 mov cx,n; jcxz @X;
 mov es,vSeg;
 mov di,d; shl di,1;
 mov al,a; cld;
@L: inc di; stosb; loop @L;
@X:
 end;

function ScreenAdr (Row,Col : Byte) : WORD;
BEGIN
   ScreenAdr := PRED (Row) * ScrCols + PRED (Col) * 2;
END;

procedure qwrite(Row, Col, Attr: byte; S: string);
BEGIN
toScrA(MemW[Seg(S):SUCC(Ofs(S))], ScreenAdr(Row,Col), Length(S), Attr);
END;

BEGIN
IF VMode = 7 Then VSeg := $B000;
END.



Keep in mind these are VERY low-level and aren't necessarily gonna be
easy to work with but they are, by god, FAST.

LD>As to why I pass attributes and don't use WhereX() and WhereY(), I wrote
LD>QWRITE mostly for screen drawing -- in fact, QWRITE doesn't even move the
LD>cursor.  It's no good for "scrolling" text, but goldang, when you want
LD>to draw a box on the screen or fill a region with a given character ...

These don't either (cursor? who needs it!)

QWrite'll work a little faster now, anyway...

 * OLX 2.2 * Cana-DOS: "Yer sure, eh?" [O]k, eh! [N]o way! [B]eauty! ?

--- Maximus 2.01wb
 * Origin: >>> Sun Mountain BBS <<< (303)-665-6922 (1:104/123)

