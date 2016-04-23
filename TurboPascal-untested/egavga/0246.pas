{$G+}
UNIT MODEX;

INTERFACE

TYPE
     Virtual_Scr = Array [1..64000] of byte;  {The size of our Virtual Screen}
     Virtual_Pal = Array [0..255, 1..3] Of Byte; {Our virtual Palette}

     Virt_ScrPtr = ^Virtual_Scr;              {Pointer to the virtual screen}
     Virt_PalPtr = ^Virtual_Pal;              {Pointer to the virtual palette}

CONST
     View_Page : Word = $A000;       {the viewable page}


         PROCEDURE Init_VGA; {Puts you in 320x200x256 VGA}
         PROCEDURE Init_VGA2; {Puts you in 320x200x256 VGA}
         PROCEDURE Init_TEXT; {Puts you back in 80x25 text mode}
         PROCEDURE Clear_VGA(Page: Word); {Clears the 320x200x256 VGA}
         PROCEDURE Stretch(Value : byte);
         PROCEDURE WaitVR;
         PROCEDURE WaitDE;
         PROCEDURE MoveCursor (X,Y : byte); {Moves the cursor to (X,Y)}
         FUNCTION ReadCursorX: byte; {Get X position of cursor}
         FUNCTION ReadCursorY: byte; {Get Y position of cursor}
         PROCEDURE BIOSWrite(Str : String; Color : Byte);
         PROCEDURE SetPix(x, y: integer; c: Byte; Page: Word);
         PROCEDURE Move_Up(x1, y1, x2, y2: Word);
         PROCEDURE Move_Up2(x1, y1, x2, y2: Word);
         PROCEDURE Move_Up3(x1, y1, x2, y2: Word);
         PROCEDURE Move_Left(x1, y1, x2, y2: Word);
         PROCEDURE Screen_Pan(ScrOfs : Word);
         PROCEDURE Synk;
         PROCEDURE Set_Color(ColorNum, R, G, B: Byte);
         PROCEDURE Get_Color(ColorNum: Byte; Var R, G, B: Byte);
         FUNCTION GetPix(x, y, Page : Word) : Byte;
         PROCEDURE Flip(Source, Dest: Word);
         PROCEDURE ScaleBitmap(VAR bmp2scale; actualx, actualy : Byte;
                                   bstrtx, bstrty, bendx, bendy : Word);
         PROCEDURE GetImage (X1, Y1, X2, Y2: Integer; Var Dest);
         PROCEDURE PutImage(X1, Y1: Integer; Var Source);
         PROCEDURE DrawBar(X1, Y1, X2, Y2: Integer; Color: Byte);
         PROCEDURE Pan(X,Y: Word);
         PROCEDURE VgaBase(Xscroll,Yscroll:integer; Var Slide: Word);
         PROCEDURE SetAddress(ad:word);
         PROCEDURE SetLinecomp(ad:word);
         PROCEDURE Draw_Line( x, y, x2, y2: Word; Color: Byte; Page: word);
         PROCEDURE Fade_Area(x, y, x2, y2: Word;  Difference: Integer; Page: Word);


IMPLEMENTATION

CONST
     Crtadress    : Word = $3d4;
     Inputstatus  : Word = $3DA;

TYPE
     Fixed = RECORD
           CASE Boolean OF
                True  : (w : LongInt);
                False : (f, i : Word);
           END;


PROCEDURE Init_VGA; ASSEMBLER;  {Puts you in 320x200x256 VGA}
          ASM
             XOR  AH, AH  {save as MOV AH, 0 but faster}
             MOV  AL, $13
             {MOV  AX, $13}
             INT  $10
          End;

PROCEDURE Init_VGA2; ASSEMBLER;
          ASM
        mov ax,13h
        int 10h
        mov dx,3c4h
        mov ax,0604h
        out dx,ax
        mov ax,0f02h
        out dx,ax
        mov cx,320*200
        mov es,view_page
        xor ax,ax
        mov di,ax
        rep stosw
        mov dx,3d4h
        mov ax,0014h
        out dx,ax
        mov ax,0e317h
        out dx,ax
          END;

PROCEDURE Init_TEXT; ASSEMBLER; {Puts you back in 80x25 text mode}
          ASM
             XOR  AH, AH  {save as MOV AH, 0 but faster}
             MOV  AL, $3
             {MOV  AX, $3}
             INT  $10
          End;


PROCEDURE Clear_VGA(Page: Word); Assembler;
          ASM
             cld
             mov ax, [Page]
             mov es, ax
             xor di, di
             xor ah, ah
             mov cx, 32000
             rep stosw
          End;


{stretches the screen : EFFECT}
PROCEDURE Stretch(Value : byte); assembler;
          ASM
             push   ax         {Save the necessary registers}
             push   dx
             mov    al, $9      {Index 09h }
             mov    dx, $3D4    {CRTC register }
             out    dx, al      {Output with a value of 0 }
             mov    dx, $3D5    {Get ready to read the port }
             in     al, dx      {read from it }
             and    al, $0E0
             add    al, Value   {Put the value in al }
             out    dx, al      {go ahead and do it }
             pop    dx
             pop    ax         {Restore the registers }
          End;


{Wait for a vertical retrace}
PROCEDURE WaitVR; assembler;
          asm
             mov dx, $03DA
             @wvr:
                  in   al,dx
                  test al,8
             jz @wvr
          end;


{wait for Display Enable}
PROCEDURE WaitDE; assembler;
          asm
             mov dx, $03DA
             @wde:
                  in   al,dx
                  test al,1
             jnz @wde
          end;

PROCEDURE MoveCursor (X,Y : byte); Assembler; {Moves the cursor to (X,Y)}
          ASM
             MOV ah, $02
             XOR bx, bx
             MOV dh, Y
             MOV dl, X
             INT $10
          End;



FUNCTION ReadCursorX: byte; assembler;  {Get X position of cursor}
         ASM
            MOV ah, $03
            XOR bx, bx
            INT $10
            MOV al, dl
         End;


FUNCTION ReadCursorY: byte; assembler;  {Get Y position of cursor}
         ASM
            MOV ah, $03
            XOR bx, bx
            INT $10
            MOV al, dh
         End;

PROCEDURE BIOSWrite(Str : String; Color : Byte); Assembler;
          ASM
             les  di, Str
             mov  cl, es:[di]     { cl = longueur chane }
             inc  di              { es:di pointe sur 1er caractre }
             xor  ch, ch          { cx = longueur chane }
             mov  bl, Color       { bl:=coul }
             jcxz @ExitBW         { sortie si Length(s)=0 }
             @BoucleBW:
                       mov  ah, 0eh         { sortie TTY }
                       mov  al, es:[di]     { al=caractre  afficher }
                       int  10h             { et hop }
                       inc  di              { caractre suivant }
             loop @BoucleBW
             @ExitBW:
          End;

PROCEDURE SetPix(x, y: integer; c: Byte; Page: Word);
          Begin
               Mem[View_Page: y * 320 + x] := c;
          End;

PROCEDURE SetPix2(x, y: integer; c: Byte; Page: Word); Assembler;
          asm
             mov ax, [Page]
             mov es, ax
             mov ax, y
             mov bx, 320
             mul bx
             mov di, x
             add di, ax
             mov al, c
             mov es:[di],al
          End;


PROCEDURE Move_Up(x1, y1, x2, y2: Word);
          type t_bmp_type = Array[0..63999] of Byte;
               pt_bmp_type = ^t_bmp_type;

          var
             t_bmp : pt_bmp_type;

          Begin
               New(t_bmp);
               GetImage(x1, y1, x2, y2, t_bmp^);
               PutImage(x1, y1 - 1, t_bmp^);
               Dispose(t_bmp);
          End;


PROCEDURE Move_Up2(x1, y1, x2, y2: Word);
          Var
             x,
             y  : Word;

          Begin
               For Y := y1 to y2 Do
                   For X := x1 To x2 Do
                       SetPix(x, y, GetPix(x, y + 1, View_Page), View_Page);
          End;


PROCEDURE Move_Up3(x1, y1, x2, y2: Word);
          Var
             y  : Word;

          Begin
               for y := y1 to y2 do
                   Move(MEM[$A000:y*320], MEM[$A000:pred(y)*320], 320);
          End;

PROCEDURE Move_Left(x1, y1, x2, y2: Word);
          type t_bmp_type = Array[0..63999] of Byte;
               pt_bmp_type = ^t_bmp_type;

          var
             t_bmp : pt_bmp_type;

          Begin
               New(t_bmp);
               GetImage(x1 + 1, y1, x2, y2, t_bmp^);
               PutImage(x1, y1, t_bmp^);
               Dispose(t_bmp);
          End;



PROCEDURE Screen_Pan(ScrOfs : Word); Assembler;
          Asm
             mov bx, ScrOfs
             mov dx, $3d4
             mov ah, bh
             mov al, 0ch
             out dx, ax
             mov ah, bl
             inc al
             out dx, ax
          End;

PROCEDURE Synk; Assembler;
          Asm
             mov     dx, $3da
             @L1:
                 in      al, dx
                 test    al, $8
             jne     @L1
             @L2:
                 in      al, dx
                 test    al, $8
             je      @L2
          End;

PROCEDURE Set_Color(ColorNum, R, G, B: Byte);
          Begin
               Port[$3C8] := ColorNum;
               Port[$3C9] := R;
               Port[$3C9] := G;
               Port[$3C9] := B;
          End;

PROCEDURE Get_Color(ColorNum: Byte; Var R, G, B: Byte);
          Begin
               Port[$3C8] := ColorNum;
               R := Port[$3C9];
               G := Port[$3C9];
               B := Port[$3C9];
               If ColorNum = 0 Then
                  Begin
                       R := 0;
                       G := 0;
                       B := 0;
                  End;
          End;

FUNCTION GetPix(x, y, Page : Word) : Byte;
         Begin
              GetPix := Mem[View_Page: y * 320 + x];
         End;

FUNCTION GetPix2(x, y, Page : Word) : Byte; Assembler;
         ASM
            push  ds
            mov   ax, [Page]
            mov   ds, ax
            mov   ax, y
            shl   ax, 6
            mov   si, ax
            shl   ax, 2
            add   si, ax
            add   si, x
            lodsb
            pop   ds
         End;

PROCEDURE Flip(Source, Dest: Word); Assembler;
{This copies the entire screen at "source" to destination}
          asm
             push    ds
             mov     ax, [Dest]
             mov     es, ax
             mov     ax, [Source]
             mov     ds, ax
             xor     si, si
             xor     di, di
             mov     cx, 32000
             rep     movsw
             pop     ds
          end;


{ originally by SEAN PALMER, I just mangled it  :^) }
PROCEDURE ScaleBitmap(VAR bmp2scale; actualx, actualy : Byte;
                      bstrtx, bstrty, bendx, bendy: Word);
{ These are notes I added, so they might be wrong.  :^)     }
{ - bmp2scale is an array [0..actualx, 0..actualy] of byte  }
{   which contains the original bitmap                      }
{ - actualx and actualy are the actual width and height of  }
{   the normal bitmap                                       }
{ - bstrtx and bstrty are the x and y values for the upper- }
{   left-hand corner of the scaled bitmap                   }
{ - bendx and bendy are the lower-right-hand corner of the  }
{   scaled version of the original bitmap                   }
{ - eg. to paste an unscaled version of a bitmap that is    }
{   64x64 pixels in size in the top left-hand corner of the }
{   screen, fill the array with data and call:              }
{     ScaleBitmap(bitmap, 64, 64, 0, 0, 63, 63);            }
{ - apparently, the bitmap is read starting at (0,0) and    }
{   then going to (0,1), then (0,2), etc; meaning that it's }
{   not read horizontally, but vertically                   }
VAR
   bmp_sx, bmp_sy, bmp_cy : Fixed;
   bmp_s, bmp_w, bmp_h    : Word;
BEGIN
     bmp_w := bendx - bstrtx + 1;
     bmp_h := bendy - bstrty + 1;
     bmp_sx.w := actualx * $10000 DIV bmp_w;
     bmp_sy.w := actualy * $10000 DIV bmp_h;
     bmp_s := 320 - bmp_w;
     bmp_cy.w := 0;
     ASM
        PUSH DS
        MOV DS,WORD PTR bmp2scale + 2
        MOV AX,$A000;
        MOV ES,AX;
        CLD;
        MOV AX,320;
        MUL bstrty;
        ADD ax,bstrtx;
        MOV DI,AX;
        @L2:
            MOV AX,bmp_cy.i;
            MUL actualx;
            MOV BX,AX;
            ADD BX,WORD PTR bmp2scale;
            MOV CX,bmp_w;
            XOR SI,SI;  {MOV SI,0}
            MOV DX,bmp_sx.f;
        @L:
           MOV AL,[BX];
           STOSB;
           ADD SI,DX;
           ADC BX,bmp_sx.i;
        LOOP @L
             ADD DI,bmp_s;
             MOV AX,bmp_sy.f;
             MOV bx,bmp_sy.i;
             ADD bmp_cy.f,AX;
             ADC bmp_cy.i,BX;
             DEC WORD PTR bmp_h;
        JNZ @L2;

        POP DS;
     END;
END;

PROCEDURE GetImage (X1, Y1, X2, Y2: Integer; Var Dest);
          Var
             Width,
             S,
             O : Word;

          Begin
               S := SEG (DEST);
               O := OFS (DEST);

               ASM
                  PUSH DS

                  MOV DX, $A000
                  MOV DS, DX
                  MOV BX, 320
                  MOV AX, Y1; MUL BX
                  ADD AX, X1; MOV SI, AX

                  MOV DX, S
                  MOV ES, DX
                  MOV DI, O

                  MOV DX, Y2; SUB DX, Y1; INC DX
                  MOV BX, X2; SUB BX, X1; INC BX
                  MOV WIDTH, BX

                  MOV AX, WIDTH
                  STOSW
                  MOV AX, DX
                  STOSW

                  @LOOP:
                        MOV CX, WIDTH
                        REP MOVSB
                        ADD SI, 320;
                        SUB SI, WIDTH
                        DEC DX
                  JNZ @LOOP

                  POP DS
               End; {end of assembler}
          End; {end of procedure}

PROCEDURE PutImage(X1, Y1: Integer; Var Source);
          Var
             Width,
             S,
             O      : Word;

          Begin
               S := SEG (SOURCE);
               O := OFS (SOURCE);

               ASM
                  PUSH DS

                  MOV DX, $A000
                  MOV ES, DX
                  MOV BX, 320            { Setup Dest Addr }
                  MOV AX, Y1; MUL BX
                  ADD AX, X1; MOV DI, AX

                  MOV DX, S { Setup Source Addr }
                  MOV DS, DX
                  MOV SI, O

                  LODSW   { Get Width and Height }
                  MOV WIDTH, AX
                  LODSW
                  MOV DX, AX

                  @LOOP:
                        MOV CX, WIDTH
                        REP MOVSB
                        ADD DI, 320
                        SUB DI, WIDTH
                        DEC DX
                  JNZ @LOOP

                  POP DS
               End; {end of the ASM}
          End; {end of the procedure}


PROCEDURE DrawBar(X1, Y1, X2, Y2: Integer; Color: Byte);
          Var
             Row : Word;

          Begin
               IF X1 < 1 Then
                  X1 := 1;
               If Y1 < 1 Then
                  Y1 := 1;
               If X2 > 320 Then
                  X2 := 320;
               If Y2 > 200 Then
                  Y2 := 200;
               For Row := Y1 To Y2 Do
                   FillChar(MEM[$A000:(320 * Row) + X1], X2 - X1, Color);
          End;


PROCEDURE Pan(X,Y: Word); Assembler;
          ASM
             mov    bx, 320
             mov    ax, y
             mul    bx
             add    ax, x
             push   ax
             pop    bx
             mov    dx, InputStatus
             @WaitDE:
                     in     al,dx
                     test   al,01h
             jnz    @WaitDE       {display enable is active?}
             mov    dx, Crtadress
             mov    al, $0C
             mov    ah, bh

             out    dx, ax
             mov    al, $0D
             mov    ah, bl
             out    dx, ax
             MOV    dx, InputStatus
             @wait:
                   in      al,dx
                   test    al,8                    {?End Vertical Retrace?}
             jz    @wait
          End;

Procedure VgaBase(Xscroll,Yscroll:integer; Var Slide: Word);
  var dum:byte;
 Begin
  Dec(Slide, (Xscroll+320*Yscroll));   { slide scrolling state         }
  Port[$03d4]:=13;                    { LO register of VGAMEM offset  }
  Port[$03d5]:=(SLIDE shr 2) and $FF; { use 8 bits:  [9..2]           }
  Port[$03d4]:=12;                    { HI register of VGAMEM offset  }
  Port[$03d5]:= SLIDE shr 10;         { use 6 bits   [16..10]         }
  Dum:=Port[$03DA];                   { reset to input by dummy read  }
  Port[$03C0]:=$20 or $13;            { smooth pan = register $13     }
  Port[$03C0]:=(SLIDE and 3) Shl 1;   { use bits [1..0], make it 0-2-4-6
}
 End;

PROCEDURE SetAddress(ad:word); assembler;
          ASM
             mov dx,3d4h
             mov al,0ch
             mov ah,[byte(ad)+1]
             out dx,ax
             mov al,0dh
             mov ah,[byte(ad)]
             out dx,ax
          End;

PROCEDURE SetLinecomp(ad:word); assembler;
          ASM
             mov dx,3d4h
             mov al,18h
             mov ah,[byte(ad)]
             out dx,ax
             mov al,7
             out dx,al
             inc dx
             in al,dx
             dec dx
             mov ah,[byte(ad)+1]
             and ah,00000001b
             shl ah,4
             and al,11101111b
             or al,ah
             mov ah,al
             mov al,7
             out dx,ax
             mov al,9
             out dx,al
             inc dx
             in al,dx
             dec dx
             mov ah,[byte(ad)+1]
             and ah,00000010b
             shl ah,5
             and al,10111111b
             or al,ah
             mov ah,al
             mov al,9
             out dx,ax
          End;

PROCEDURE Draw_Line( x, y, x2, y2: Word; Color: Byte; Page: word); Assembler;
          asm
             mov ax,[Page];
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

PROCEDURE Fade_Area(x, y, x2, y2: Word;  Difference: Integer; Page: Word);
          Var
             Color: Byte;
             ty,
             tx   : Word;

          Begin
               For ty := y to y2 Do
                   for tx := x to x2 Do
                       SetPix(tx, ty, GetPix(tx, ty, View_Page) + Difference, View_Page);
          End;

BEGIN
END.