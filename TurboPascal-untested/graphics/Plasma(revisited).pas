(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0090.PAS
  Description: RE: PLASMA  (revisited)
  Author: KAARE BOEEGH
  Date: 05-25-94  08:20
*)

{
{TITLE: Plasma  FROM: Kaare Boeegh  DATE: Sun Apr 17 1994 08:25 pm}
{$A+,B-,D-,E-,F+,G+,I-,L-,N-,O-,R-,S-,V-,X-}
PROGRAM plasma;

CONST ys : BYTE = 0;
      yt : BYTE = 255;

VAR ft   : ARRAY [0..512] OF BYTE;
    sint : ARRAY [0..256] OF BYTE;
    i1,a,b,d,c,od,color,e,y : BYTE;
    x,k,i                   : WORD;

PROCEDURE do_tables;
  VAR i : WORD;
  BEGIN
    FOR i := 0 TO 512 DO   FT [i] := ROUND(64+63*SIN(i/40.74));
    FOR i := 0 TO 256 DO SINT [i] := ROUND(128+127*SIN(i/40.74))-1;
  END;

PROCEDURE do_palette;
  VAR i : WORD;
  BEGIN
    PORT[$3C8] := 0;
    FOR i := 0 TO 255 DO
      BEGIN
        PORT[$3C9] := i DIV 4;
        PORT[$3C9] := i DIV 6;
        PORT[$3C9] := i DIV 8;
      END;
  END;

BEGIN
  ASM
    mov al,ys
    mov y,al
    mov ax,0013h;
    int 10h;      {Set Mode $13}

    mov dx,3d4h   {Go into Double Height Pixel Mode}
    mov al,9
    out dx,al
    inc dx
    in al,dx
    and al,0e0h
    add al,3
    out dx,al

    call do_palette;
    call do_tables;

@3: inc i1  {Main Loop}                                          {Grid Counter}
    sub c,2
    inc od
    mov al,od
    mov d,al

    mov al,ys                          {Alternate Starting Position every pass}
    mov ah,yt
    xchg al,ah
    mov ys,al
    mov ah,yt
    mov y,al

  @2: mov al,y                 {Calculate Offset and add one every second line}
      mov bx,320
      mul bx
      mov bx,ax
      mov al,y
      mov ah,0
      and al,1
      add ax,bx
      mov k,ax

      mov al,i1                   {move grid one pixel down every second frame}
      mov ah,0
      and al,1
      mov ah,0
      mov bx,320
      mul bx

      mov bx,k
      sub bx,ax
      mov k,bx

      mov al,d
      add al,2
      mov d,al

      mov al,c           {[(c}
      add al,y           {+y)}
      and ax,255         {and 255]}
      mov di,offset sint {get sint mem location}
      add di,ax          {[c+y] and 255}
      mov al,ds:[di]     {sint[(c+y) and 255]}
      mov a,al

      mov di,offset sint
      mov al,d
      and al,255
      add di,ax
      mov al,ds:[di]
      mov b,al

      mov ax,0
      mov bx,0
      mov cx,0

    @1: mov di,offset ft    {get ft mem location}
        mov al,a            {a}
        add al,b            {+b}
        add di,ax           {[a+b]}
        mov al,ds:[di]      {ft[a+b]}
        mov bx,ax           {Store}
        inc bx              {+1}
        mov di,offset ft    {get ft mem location}
        mov al,y            {y}
        add al,b            {+b}
        add di,ax           {[y+b]}
        mov ax,ds:[di]      {ft[y+b]}
        add ax,bx           {+}
        mov color,al        {color:=}

        mov bx,0a000h       {screen memory location}
        mov es,bx           {mov it to es}
        mov di,k            {k is screen offset}


        mov es:[di+80],al      {plot color to screen}
                 { ^^ center}
        mov al,b
        add al,2
        mov b,al

        mov ax,k {Ofs of Plasma Pixel, Increased by 2 to Create the Grid}
        add ax,2
        mov k,ax

        mov ah,0                                  {INC(a,1+color SHR 7);}
        mov al,color
        shr al,7
        add al,1
        mov ah,0
        mov bl,al
        mov al,a
        add al,bl
        mov a,al

        inc cx
        cmp cx,80  {160}
        jnz @1     {inner loop}

      inc y
      cmp y,101
      jnz @2     {outer loop, number of lines}

    mov ah,01h
    int 16h
    jz @3      {get keypress}

    mov ax,03h {mode 3}
    int 10h
  END;
END.
-----------------------------------------------------------------------------
Shipley
--- Synchronet
 * Origin: The Brook Forest Inn [714] 951-5282 (1:103/950)
                              
