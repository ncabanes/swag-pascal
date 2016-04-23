 Unit Graphic;
 Interface
 Var ScrBase : Word;
   Procedure VideoMode ( Mode : Byte );
   Procedure SetColor ( Color, Red, Green, Blue : Byte );
   Procedure Pset(X,Y,C : Word);
   Procedure SetRGBDAC(Color,R,G,B : Byte);
   Procedure WaitRetrace;
   Function Rad (theta : real) : real;
   Procedure PutPix(x, y : Word; Color : Byte);
   Procedure ScrPan(ScrOfs : Word);
   Procedure SetModeX;
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

     Procedure SetModeX; Assembler;
       Asm
         mov     ax,0012h
         int     10h
         mov     ax,0013h
         int     10h
         mov     dx,3c4h
         mov     ax,0604h
         out     dx,ax
         mov     dx,3d4h
         mov     ax,0014h
         out     dx,ax
         mov     ax,0e317h
         out     dx,ax
       End;

         Procedure ScrPan(ScrOfs : Word); Assembler;
         Asm
         mov     bx,ScrOfs
         mov     dx,3d4h
         mov     ah,bh
         mov     al,0ch
         out     dx,ax
         mov     ah,bl
         inc     al
         out     dx,ax
       End;

     Procedure PutPix(x, y : Word; Color : Byte); Assembler;
       Asm
         mov     ax,0a000h
         mov     es,ax
         mov     bx,x
         mov     dx,3c4h
         mov     ax,0102h
         mov     cl,bl
         and     cl,3
         shl     ah,cl
         out     dx,ax
         mov     ax,y
         shl     ax,4
         mov     di,ax
         shl     ax,2
         add     di,ax
         shr     bx,2
         add     di,bx
         add     di,ScrBase
         mov     al,Color
         mov     es:[di],al
       End;



   Procedure VideoMode ( Mode : Byte );

     Begin { VideoMode }
       Asm
         Mov  AH,00
         Mov  AL,Mode
         Int  10h
       End;
     End;  { VideoMode }

 Procedure SetRGBDAC(Color,R,G,B : Byte);
 Begin
 Asm
 Mov AH,$10;
 Mov AL,$10;
 mov BL,Color;
 Mov CH,G;
 Mov CL,B;
 Mov DH,R;
 Int $10;
 End;
 End;


   Procedure SetColor ( Color, Red, Green, Blue : Byte );
     Begin { SetColor }
       Port[$3C8] := Color;
       Port[$3C9] := Red;
       Port[$3C9] := Green;
       Port[$3C9] := Blue;
     End;  { SetColor }

 procedure Pset(X,Y,C : Word);
 begin
 Mem[$0A000:Y*320+X] := C;
 end;
 Function rad (theta : real) : real;
   {  This calculates the degrees of an angle }
 BEGIN
   rad := theta * pi / 180
 END;

 End.

Try that I'm sure you can figure it out ..:) .. B4 you use SCRPAN you
have to do SETMODEX ... I think PutPix is faster then PSET not srue ..
you could benchmark it ... VIDEOMODE($13); gets you into 320x200x256 grf
mode ... Tell me what ya think .. this is COMPLETELY free but you might
want to tell me what ya think?
Thanks!
Cya!
███████████████████████████████████████
█     Chris Austin - CEO IdeaSoft     █▒
█           SysOp IdeaSoft/2          █▒
█            (609) 884-2717           █▒
█ FidoNet 1:2623/56 : CD-ROM : Doors! █▒
███████████████████████████████████████▒
 ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
