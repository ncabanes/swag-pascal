
Unit Graphic;
{Graphics routines Chris Austin and SWAG}
Interface
Var ScrBase : Word;
  Procedure VideoMode ( Mode : Byte );
  Procedure SetColor ( Color, Red, Green, Blue : Byte );
  Procedure Pset(X,Y,C : Word);
  Procedure Line(x,y,x2,y2:word; color:byte);
  Procedure WaitRetrace;
implementation

    Procedure WaitRetrace; Assembler;
      Asm
        mov     dx,3dah
@L1:
        in      al,dx
        test    al,08h
        jne     @L1
@L2:
        in      al,dx
        test    al,08h
        je      @L2
      End;

  Procedure VideoMode ( Mode : Byte );
    Begin { VideoMode }
      Asm
        Mov  AH,00
        Mov  AL,Mode
        Int  10h
      End;
    End;  { VideoMode }

  Procedure SetColor ( Color, Red, Green, Blue : Byte );
    Begin { SetColor }
      Port[$3C8] := Color;
      Port[$3C9] := Red;
      Port[$3C9] := Green;
      Port[$3C9] := Blue;
    End;  { SetColor }

procedure Pset(X,Y,C : Word);
begin
Mem[$0A000+Y*320+X] := C;
end;

procedure line(x,y,x2,y2:word; color:byte);assembler;asm {mode 13}
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

End.
