
{$G+}
{- FUEGO.PAS
                              Fuego - Flames
                             ----------------
                           tlaure@lsa.lsa.com.uy
                           Tomas Laurenzo - 1997
                            Montevideo - Uruguay
 ----------------------------------------------------------------------------
 
  DISCLAIMER: Same as usual, use it at your own risk.
 
  COPYRIGHT: Use it freely, just remember _I_ coded it :)
 
 
  DESCRIPTION:
  This is a simple flames routine, with two fades at the end
  I do use some routines that i've collected for quite awhile.
  I think most of'em are from the SWAG files, and from the Asphyxia VGA
  Trainer by Denthor... which helped me a lot, (not very long :) time ago.
 
  Sorry, it's not optimized, but as long as it uses no ASM (appart from
  plotting dots and the palette stuff, wich is not "Fire code"), it's really
  easy to follow the code.
 
  Once the program is running, with the keys '4','5','1' and '2', you can
  move the limits of the fire.
 
  Any comments, suggestions, whatever, _please_ mail.
 
  Salú,
    Tom.
 
^`º:;,.,;:º'^`º:;,.,;:º'^`º:;,.,;:º'^`º:;,.,;:º'^`º:;,.,;:º'^`º:;,.,;:º'^`º:;,.
}
 
 
 
PROGRAM Fuego;
 
 USES
   Crt;
 
 
 CONST Alt  = 100;    { The line from where we start redrawing the screen }
       VGA  = $A000;
 
 TYPE
      Tcolor  = RECORD                      { Las componentes RGB de un color}
                 R,G,B : Byte;
               END;
 
 
     Tpaleta = ARRAY [0..255] of Tcolor;
 
 
 VAR Y,
     X     : Word;
     Scr   : ARRAY [0..319, Alt-1..199] OF BYTE; { This will store the colors }
     MinX,                                       { of every dot in the screen }
     MaxX  : Word;                  { The limits of the fire }
     Sigue : Boolean;
     Tecla : Char;
 
 
{............................................................................}
 
 PROCEDURE Retraso; Assembler;   { Waits for the vertical retrace }
  ASM
      mov   dx,3DAh
  @@1:
      in    al,dx
      and   al,08h
      jnz   @@1
  @@2:
      in    al,dx
      and   al,08h
      jz    @@2
  END;
 
{............................................................................}
 
 PROCEDURE SeteaColor (Col : Byte; Color : Tcolor);
   { Sets a color of the palette}
  VAR R,G,B : Byte;
 
  BEGIN
    R := Color.R;
    G := Color.G;
    B := Color.B;
 
   ASM
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
   END;
  END;
 
{............................................................................}
 
 PROCEDURE CargaColor (Col : Byte; VAR Color : Tcolor);
   { Loads a color from the palette }
 
  VAR
    rr,gg,bb : Byte;
 
  BEGIN
    ASM
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
    END;
    Color.r := rr;
    Color.g := gg;
    Color.b := bb;
  END;
 
{............................................................................}
 
 PROCEDURE FadeOut (Ret : Boolean); { Fades the screen out }
  VAR I       : Byte;
      ColTemp : tColor;
      Paleta  : tPaleta;
 
  FUNCTION Hay : Boolean;
    VAR I       : Byte;
        ColTemp : tColor;
        Paleta  : tPaleta;
        H       : Boolean;
 
    BEGIN
     FOR I := 0 TO 255 DO CargaColor (I,Paleta[I]);
     H := False;
     FOR I := 0 TO 255 DO BEGIN
           IF Paleta[I].R > 0 THEN H := True;
           IF Paleta[I].G > 0 THEN H := True;
           IF Paleta[I].B > 0 THEN H := True;
           IF H = True THEN Exit;
     END;
     Hay := H;
    END;
 
  BEGIN
   WHILE Hay DO BEGIN
    FOR I := 0 TO 255 DO CargaColor (I,Paleta[I]);
    FOR I := 0 TO 255 DO BEGIN
          IF Paleta[I].R > 0 THEN Dec (Paleta[I].R);
          IF Paleta[I].G > 0 THEN Dec (Paleta[I].G);
          IF Paleta[I].B > 0 THEN Dec (Paleta[I].B);
    END;
    FOR I := 255 DownTO 0 DO SeteaColor (I,Paleta[I]);
    IF Ret = True THEN Retraso;
   END;
  END;
 
{............................................................................}
 
 PROCEDURE FadeWhite (Ret : Boolean);  { Fade the screens to white }
  VAR J,
      I       : Byte;
      ColTemp : tColor;
      Paleta  : tPaleta;
 
  BEGIN
   FOR J := 0 TO 64 DO BEGIN
    FOR I := 0 TO 255 DO CargaColor (I,Paleta[I]);
    FOR I := 0 TO 255 DO BEGIN
          IF Paleta[I].R < 63 THEN Inc (Paleta[I].R)
                               ELSE Paleta[I].R := 63;
          IF Paleta[I].G < 63 THEN Inc (Paleta[I].G)
                               ELSE Paleta[I].G := 63;
          IF Paleta[I].B < 63 THEN Inc (Paleta[I].B)
                               ELSE Paleta[I].B := 63;
    END;
    FOR I := 255 DownTO 0 DO SeteaColor (I,Paleta[I]);
    IF Ret = True THEN Retraso;
   END;
  END;
 
{............................................................................}
 
  PROCEDURE Cls (Col : Byte; Where:word); assembler;  { Clears the screen }
   ASM                                                { to the color #col }
    push    es
    mov     cx, 32000;
    mov     es,[where]
    xor     di,di
    mov     al,[col]
    mov     ah,al
    rep     stosw
    pop     es
   END;
 
 
{............................................................................}
 
  PROCEDURE Modo13h; Assembler;   { Goes into 13h VGA mode }
   ASM
    MOV AX, 13h
    INT 10h
   END;
 
{............................................................................}
 { Plots a dot to the screen }
 PROCEDURE PutDot (X,Y : Integer; Color : Byte; SegDes:word); assembler;
  ASM
   cmp  X,0
   jl   @@END
   cmp  Y,0
   jl   @@END
   cmp  X,319
   jg   @@END
   cmp  Y,199
   jg   @@END
   mov  ax,SegDes
   mov  es,ax
   mov  al,Color
   mov  di,Y
   mov  bx,X
   mov  dx,di
   xchg dh,dl
   shl  di,6
   add  di,dx
   add  di,bx
   mov  es:[di],al
 @@END:
 END;
 
{............................................................................}
 
 PROCEDURE Promedio;       { Averages the screen dots }
  VAR X, Y : Word;
  BEGIN
   FOR X := MinX+1 TO MaxX-1 DO FOR Y := Alt TO 199 DO
     Scr [X,Y] := (Scr[X,Y+1] + Scr [X,Y+1] + Scr[X+1,Y+1] + Scr [X-1,Y-1]) div 4
  END;
 
 
{............................................................................}
 
 PROCEDURE Escribo;        { This plots the dots to the screen }
  VAR X, Y : Word;
  BEGIN
   FOR X := MinX TO MaxX DO FOR Y := Alt TO 198 DO IF Scr[X,Y] > 0 THEN PutDot (X,Y,Scr[X,Y],VGA);
  END;
 
{............................................................................}
 
 PROCEDURE CreoPaleta;    {  Creates the palette }
  VAR Paleta  : tPaleta;
      ColTemp : tColor;
      I       : Byte;
 
  BEGIN
    FOR I := 1 TO 64 DO BEGIN
      ColTemp.R := I;
      ColTemp.G := 0;
      ColTemp.B := 0;
      Paleta[I] := ColTemp;
    END;
    FOR I := 64 TO 128 DO BEGIN
      ColTemp.R := 255;
      ColTemp.G := I;
      ColTemp.B := 0;
      Paleta[I] := ColTemp;
    END;
    FOR I := 118 TO 150 DO BEGIN
      ColTemp.R := 255;
      ColTemp.G := 128;
      ColTemp.B := 0;
      Paleta[I] := ColTemp;
    END;
    FOR I := 1 TO 150 DO SeteaColor (I,Paleta[I])
  END;
 
{............................................................................}
                               { Main }
 BEGIN
   Modo13h;
   CreoPaleta;
   Cls (0,VGA);
   MinX := 0;
   MaxX := 319;
   Sigue := True;
   FOR X := MinX TO MaxX DO BEGIN       { Initialize the Scr array to 0 }
     FOR Y := Alt-1 TO 199 DO BEGIN
       Scr [X,Y] := 0;
     END;
   END;
   WHILE Sigue DO BEGIN
    FOR X := MinX TO MaxX DO Scr [X,199] := Random (100)+40; { The first line }
    Promedio;
    Escribo;
 
    IF KeyPressed THEN BEGIN
      Tecla := ReadKey;
      CASE Tecla OF
        '4' : IF (MaxX > 0) AND (MaxX > MinX+10) THEN BEGIN
                Dec (MaxX,10);
                FOR X := MaxX to 319 DO
                    FOR Y := Alt-1 to 199 DO PutDot (X,Y,0,VGA);
              END;
 
        '5' : IF MaxX < 319 THEN Inc (MaxX,10);
        '1' : IF MinX > 0 THEN Dec (MinX,10);
        '2' : IF (MinX < 319) AND (MinX < MaxX-10) THEN BEGIN
                Inc (MinX,10);
                FOR X := 0 to MinX DO
                    FOR Y := Alt-1 to 199 DO PutDot (X,Y,0,VGA);
              END;
      ELSE Sigue := False;
      END;
     END;
    END;
   FadeWhite (True);
   Cls (53,VGA);
   FadeOut (True);
 END.
