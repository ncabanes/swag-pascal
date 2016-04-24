(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0195.PAS
  Description: Graphics In Assembler
  Author: JANI ALANEN
  Date: 11-22-95  13:27
*)

{
 AL> Does anyone have any basic graphics routines in assembler that I
 AL> could learn from. ie. graphics mode asm
 AL> int 13h
 AL> mov DX, ??
 AL> end

That would be something like:
        ASM
           mov  ax,0013h
           int  10h
        END;


Here's some routines I've been using for awhile:
------------------------------ CUT --------------------------------------- }
{                   A simple
graphics unit.                           }{ Routines by Denthor of Asphyxia,
Vassago and Cenor of Fata Morgana. } {          Feel free to use these
routines. Have fun!                 }
UNIT GFX;

INTERFACE

USES Crt;

CONST VGA = $A000;

TYPE Virtual = Array [1..64000] of byte;  { The size of our Virtual Screen }
     VirtPtr = ^Virtual;                  { Pointer to the virtual screen }

PROCEDURE Paint( StartPoint,EndPoint , From, Dest : Word );
   { Paints screen over another one, doesn't handle color 0 }
PROCEDURE ScrollUp(Where:Word);
   { Scrolls screen up, fast with virtualscreen }
PROCEDURE ScrollUp2(Where:Word);
   { Scrolls screen up, faster when virtualscreen are not used }
PROCEDURE ShutDown;
   { This frees the memory used by the virtual screen }
PROCEDURE SetUpVirtual;
   { This sets up the memory needed for the virtual screen }
PROCEDURE Cls (Where:word;Col : Byte);
   { This clears the screen to the specified color }
PROCEDURE Flip (source,dest:Word);
  { This copies the entire screen at "source" to destination }
PROCEDURE Pal (Col,R,G,B : Byte);
  { This sets the Red, Green and Blue values of a certain color }
PROCEDURE GetPal (Col : Byte; Var R,G,B : Byte);
  { This gets the Red, Green and Blue values of a certain color }
PROCEDURE Putpixel (X,Y : Integer; Col : Byte; where:word);
  { This puts pixel directly to memory, fast }
FUNCTION  Getpixel (X,Y : Integer; where:word):byte;
  { This gets color of pixel from memory, fast }
PROCEDURE SetMCGA;
  { This procedure gets you into 320x200x256 mode. }
PROCEDURE SetText;
  { This procedure returns you to text mode.  }
PROCEDURE WaitRetrace;
  { Waits fo vertical retrace }

VAR    Virscr : VirtPtr;                      { 1st Virtual Screen }
       VirScr2 : VirtPtr;                     { 2nd Virtual Screen }
       VirScr3 : VirtPtr;                     { 3rd Virtual Screen }
       VirtualScreen1  : word;                { Virtual Screen 1. seg }
       VirtualScreen2 : Word;                 { Virtual Screen 2. seg }
       VirtualScreen3 : Word;                 { Virtual Screen 3. seg }

       Palette,Palette2 : Array[0..255,1..3] of Byte;
       Scr_Ofs : Array[0..199] of Word;

IMPLEMENTATION

PROCEDURE Paint( StartPoint,EndPoint , From, Dest : Word ); BEGIN;
      StartPoint:=StartPoint*320;
      EndPoint:=EndPoint*320-StartPoint;
      ASM
         push    ds
         mov     ax, From
         mov     es, ax
         mov     ax, Dest
         mov     ds, ax
         mov     di, EndPoint
         mov     Cx, StartPoint
      @Looppi:
         mov     Al, Es:[Di]
         cmp     Al, 0
         jz      @Ohi
         mov     Ds:[di], Al
      @Ohi:
         inc     di
         loop    @Looppi
         pop     ds
     END;
END;

PROCEDURE ScrollUp(Where:Word); Assembler; ASM
        push    ds
        mov     ax, [Where]
        mov     es, ax
        mov     ax, [Where]
        mov     ds, ax
        mov     Si, 320
        mov     di, 0
        mov     cx, 31840
        rep     movsw
        pop     ds
END;

PROCEDURE ScrollUp2(Where:Word); Assembler; ASM
        push    ds
        mov     ax, [Where]
        mov     es, ax
        mov     ax, [Where]
        mov     ds, ax
        mov     Si, 320
        mov     di, 0
        mov     cx,15920
        db      0F3h, 66h, 0A5h
        pop     ds
END;

Procedure ShutDown;
   { This frees the memory used by the virtual screen }
BEGIN
  FreeMem (VirScr,64000);
  FreeMem (VirScr2,64000);
  FreeMem (VirScr3,64000);
END;


Procedure SetUpVirtual;
   { This sets up the memory needed for the virtual screen }
BEGIN
  GetMem (VirScr,64000);
  VirtualScreen1 := seg (virscr^);
  GetMem (VirScr2,64000);
  VirtualScreen2 := seg (virscr2^);
  GetMem (VirScr3,64000);
  VirtualScreen3 := seg (virscr3^);
END;

Procedure Cls (Where:word;Col : Byte); assembler;
   { This clears the screen to the specified color }
asm
   push    es
   mov     cx, 32000;
   mov     es,[where]
   xor     di,di
   mov     al,[col]
   mov     ah,al
   rep     stosw
   pop     es
End;

procedure flip(source,dest:Word); assembler;
  { This copies the entire screen at "source" to destination }
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

Procedure Pal(Col,R,G,B : Byte); assembler;
  { This sets the Red, Green and Blue values of a certain color }
asm
   mov    dx,3c8h
   mov    al,[col]
   out    dx,al
   inc    dx
   mov    al,[r]
   out    dx,al
   mov    al,[g]
   out    dx,al
   mov    al,[b]
   out    dx,al
end;

Procedure GetPal(Col : Byte; Var R,G,B : Byte);
  { This gets the Red, Green and Blue values of a certain color }
Var
   rr,gg,bb : Byte;
Begin
   asm
      mov    dx,3c7h
      mov    al,col
      out    dx,al

      add    dx,2

      in     al,dx
      mov    [rr],al
      in     al,dx
      mov    [gg],al
      in     al,dx
      mov    [bb],al
   end;
   r := rr;
   g := gg;
   b := bb;
end;

Procedure Putpixel (X,Y : Integer; Col : Byte; where:word); assembler;
  { This puts a pixel on the screen by writing directly to memory. }
asm
   mov  ax,where
   mov  es,ax
   mov  bx,[y]
   shl  bx,1
   mov  di,word ptr [Scr_Ofs + bx]
   add  di,[x]
   mov  al,[col]
   mov  es:[di],al
end;

Function Getpixel (X,Y : Integer; where:word):byte; assembler;
  { This puts a pixel on the screen by writing directly to memory. }
asm
   mov  ax,where
   mov  es,ax
   mov  bx,[y]
   shl  bx,1
   mov  di,word ptr [Scr_Ofs + bx]
   add  di,[x]
   mov  al,es:[di]
end;

Procedure SetMCGA;  { This procedure gets you into 320x200x256 mode. } BEGIN
  asm
     mov        ax,0013h
     int        10h
  end;
END;

Procedure SetText;  { This procedure returns you to text mode.  } BEGIN
  asm
     mov        ax,0003h
     int        10h
  end;
END;

procedure WaitRetrace; assembler;
  {  This waits for a vertical retrace to reduce snow on the screen }
label
  l1, l2;
asm
    mov dx,3DAh
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
    and al,08h
    jz  l2
end;

VAR Loop1:integer;

BEGIN
  For Loop1 := 0 to 199 do
    Scr_Ofs[Loop1] := Loop1 * 320;
END.

