(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0006.PAS
  Description: FAST Mode 13h Line Draw
  Author: SEAN PALMER
  Date: 08-23-93  09:18
*)

{
===========================================================================
 BBS: Beta Connection
Date: 08-20-93 (09:59)             Number: 2208
From: SEAN PALMER                  Refer#: NONE
  To: ALL                           Recvd: NO  
Subj: FAST mode 13h Li (Part 1)      Conf: (232) T_Pascal_R
---------------------------------------------------------------------------
Hey! Here's THE fastest mode 13h bresenham's line drawing function ever.
(I think...prove me wrong, please!!)

It's written for TP 6 or better, uses BASM. If you don't know assembly, just
put it in a unit and don't worry about how it works. If you do, fine.
Some good optimizations in there...

Have fun! If anyone wants the mostly-pascal equivalent, let me know.
It's still fast.

{by Sean Palmer}
{public domain}

var color:byte;

procedure line(x,y,x2,y2:word);assembler;asm {mode 13}
 mov ax,$A000
 mov es,ax
 mov bx,x
 mov ax,y
 mov cx,x2
 mov si,y2
 cmp ax,si
 jbe @NO_SWAP   {always draw downwards}
 xchg bx,cx
 xchg ax,si
@NO_SWAP:
 sub si,ax         {yd (pos)}
 sub cx,bx         {xd (+/-)}
 cld               {set up direction flag}
 jns @H_ABS
 neg cx      {make x positive}
 std
@H_ABS:
 mov di,320
 mul di
 mov di,ax
 add di,bx   {di:adr}
 or si,si
 jnz @NOT_H
{horizontal line}
 cld
 mov al,color
 inc cx
 rep stosb
 jmp @EXIT
@NOT_H:
 or cx,cx
 jnz @NOT_V
{vertical line}
 cld
 mov al,color
 mov cx,si
 inc cx
 mov bx,320-1
@VLINE_LOOP:
 stosb
 add di,bx
 loop @VLINE_LOOP
 jmp @EXIT
@NOT_V:
 cmp cx,si    {which is greater distance?}
 lahf         {then store flags}
 ja @H_IND
 xchg cx,si   {swap for redundant calcs}
@H_IND:
 mov dx,si    {inc2 (adjustment when decision var rolls over)}
 sub dx,cx
 shl dx,1
 shl si,1     {inc1 (step for decision var)}
 mov bx,si    {decision var, tells when we need to go secondary direction}
 sub bx,cx
 inc cx
 push bp      {need another register to hold often-used constant}
 mov bp,320
 mov al,color
 sahf         {restore flags}
 jb @DIAG_V
{mostly-horizontal diagonal line}
 or bx,bx     {set flags initially, set at end of loop for other iterations}
@LH:
 stosb        {plot and move x, doesn't affect flags}
 jns @SH      {decision var rollover in bx?}
 add bx,si
 loop @LH   {doesn't affect flags}
 jmp @X
@SH:
 add di,bp
 add bx,dx
 loop @LH   {doesn't affect flags}
 jmp @X
@DIAG_V:
{mostly-vertical diagonal line}
 or bx,bx    {set flags initially, set at end of loop for other iterations}
@LV:
 mov es:[di],al   {plot, doesn't affect flags}
 jns @SV          {decision var rollover in bx?}
 add di,bp        {update y coord}
 add bx,si
 loop @LV         {doesn't affect flags}
 jmp @X
@SV:
 scasb   {sure this is superfluous but it's a quick way to inc/dec x coord!}
 add di,bp        {update y coord}
 add bx,dx
 loop @LV         {doesn't affect flags}
@X:
 pop bp
@EXIT:
 end;

var k,i,j:word;
begin
 asm mov ax,$13; int $10; end;
 for k:=0 to 31 do begin
  i:=k*10;
  j:=k*6;
  color:=14;
  line(159,99,i,0);
  color:=13;
  line(160,99,319,j);
  color:=12;
  line(160,100,319-i,199);
  color:=11;
  line(159,100,0,199-j);
  i:=k*9;
  j:=k*5;
  color:=6;
  line(i,0,159,99);
  color:=5;
  line(319,j,160,99);
  color:=4;
  line(319-i,199,160,100);
  color:=3;
  line(0,199-j,159,100);
  end;
 Readln;
 asm mov ax,3; int $10; end;
 end.

... I'm not unemployed, I'm indefinitely leisured.
___ Blue Wave/QWK v2.12
---
 * deltaComm Online 919-481-9399 - 10 lines
 * PostLink(tm) v1.06  DELTA (#22) : RelayNet(tm) HUB

