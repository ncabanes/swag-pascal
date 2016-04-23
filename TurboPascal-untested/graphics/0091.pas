{
RE: Re: Virtual Reality.
BY: Bas van Gaalen to John Shipley on Fri Mar 25 1994 02:26 pm

 > John Shipley wrote in a message to Bas van Gaalen:
 > 
 >  > I posted it recently, so you must have seen it passing by...
 >  JS> You did? I read just about every post you write, I didn't
 >  JS> see any program by that name come by here.
 > 
 > I suppose it got lost. You're the second... Anyway, I posted it again. Check
 > previous message... It should be there.

Hello Bas!

Yes, I got it today... basically the problem I saw with the code was lack of
optimization and it also looked like you were trying to do too much. You
didn't need all the asm. But it could be even faster if you included it. I'm
sending back my modified version of your DYCP program. The "writecharasm"
procedure was screwed up so I removed it and I will check it out at a later
time. I modified the "writechar" procedure which you had commented out.

-------8<---------Snip---------8<---------Snip---------8<--------Snip---------

{$G+}
PROGRAM different_y_char_position;

(* Programmed by Bas van Gaalen, Holland, PD  *)
(* Modified by John Shipley, USA, PD 03/30/94 *)

USES CRT;

CONST vseg : WORD   = $a000;
      txt  : STRING = '**** Well... 38 chars, let''s see. ****';
                   (*  12345678901234567890123456 78901234567890 *)
      txt1 : STRING = 'This is another Strng of 38 Characters';
VAR stab      : ARRAY[0..255] OF BYTE;
    fseg,fofs : WORD;

PROCEDURE getfont; ASSEMBLER;
  ASM
    mov ax,1130h;
    mov bh,1;
    int 10h;
    mov fseg,es;
    mov fofs,bp;
  END;

PROCEDURE csin;
  VAR i : BYTE;
  BEGIN
    for i := 0 to 255 do stab[i] := round(sin(6*i*pi/255)*25)+40;(*150*)
  END;

PROCEDURE clear(x,y: WORD); ASSEMBLER;
  ASM
    mov es,vseg
    mov dx,0
   @lout:
    mov cx,0
   @lin:
    mov ax,y
    add ax,dx
    shl ax,6
    mov di,ax
    shl ax,2
    add di,ax
    add di,x
    add di,cx
    xor ax,ax
    mov [es:di],ax
    add cx,2
    cmp cx,8
    jne @lin
    inc dx
    cmp dx,2 (* Was 8 *)
    jne @lout
  END;

PROCEDURE writechar(ch: CHAR; x,y: WORD; col: BYTE);
  VAR j,k : BYTE;
      pre : WORD;
      opt : WORD;
  BEGIN
    pre := BYTE(ch)*8; (* Opt *)
    clear(x,y-2);      (* Key *)
    FOR j:=0 TO 7 DO
      FOR k:=0 TO 7 DO
        BEGIN
          opt := (y+j)*320+x+k;  (* Opt *)
          IF ((MEM[fseg:fofs+pre+j] SHL k) AND 128)=0 THEN
            MEM[$a000:opt] := 0 (* Key *)
          ELSE
            MEM[$a000:opt] := col;
        END;
    INC(y,8);   (* Opt *)
    clear(x,y); (* Key *)
  END;

PROCEDURE dodycp;
  VAR sctr,i,l: BYTE;
      a,b,c : WORD;
  BEGIN
    sctr := 0;
    l := LENGTH(txt); (* Opt *)
    REPEAT
      WHILE (PORT[$3da] AND 8)<>0 DO;
      WHILE (PORT[$3da] AND 8)=0 DO;
      FOR i := 1 TO l DO
        BEGIN
          a := i*8;
          b := stab[(sctr+2*i) MOD 255];
          c := stab[sctr+i] MOD 64;
          INC(c,32);
          writechar(txt[i],a,b,c);
          INC(b,110);
          writechar(txt1[i],a,b,c);
        END;
      INC(sctr);
    UNTIL KEYPRESSED;
  END;

BEGIN
  getfont;
  csin;
  ASM
    mov ax,13h;
    int 10h;
  END;
  dodycp;
  TEXTMODE(lastmode);
END.
