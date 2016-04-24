(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0126.PAS
  Description: Sprite Game
  Author: JOHN HOWARD
  Date: 08-24-94  13:58
*)


program SpriteGame;         {Verifies a VGA is present}
{$G+,R-}
(* jh  Syntax:  spritegame.exe  [number]
  optional number is the total population of sprites.  Default is maxsprites.
*)
{ Original Sprites program by Bas van Gaalen, Holland, PD }
{ Modified by Luis Mezquita Raya }
{ Modified by John Howard (jh) into a game }
{ 30-MAY-1994 jh Version 1.0
  Now a game to see which sprite survives the longest.
  Renamed tScrArray to Screen, and tSprArray to SpriteData.
  Removed CRT unit & saved around 1616 bytes.  Added command line parameter.
  Added timer and energy definitions to provide statistics.
  21-JUN-1994 jh Version 1.1 = ~7.5k
  Added OnlyVGA and SetMode procedures.  Added CharSet & CharType definitions.
  Implemented characters as sprites.
  29-JUN-1994 jh Version 1.2 = ~8.5k due to command line help
  Places identification on each sprite by using HexDigits.  CharColor defaults
  to sprite number (0..maxsprites) as a color index in the palette.  Fixed bug
  in moire background screen limits.
}
const
      maxsprites=128;                   { Number of sprites is [1..128] }
      pxsize=320;                       { screen x-size }
      pysize=200;                       { screen y-size }
      xsize=32;                         { sprite x-size }
      ysize=32;                         { sprite y-size }
      CharRows=8;                       { Characters are 8 rows high }
      HexDigits : ARRAY[0..15] OF Char = '0123456789ABCDEF';

type
      Screen=array[0..pysize-1, 0..pxsize-1] of byte;
      pScreen=^Screen;
      SpriteData=array[0..ysize-1, 0..xsize-1] of byte;
      pSpriteData=^SpriteData;
      SprRec=record
              x,y : word;              {Absolute location of sprite}
              xspd,yspd : shortint;    {Velocity horizontal and vertical}
              energy : shortint;       {Hide is neg., dead is 0, show is pos.}
              buf : pSpriteData;       {Rectangle of sprite definition}
             end;
      CharType = array[1..CharRows] of Byte;

var
      CharSet : array[0..255] of CharType absolute $F000:$FA6E;
      sprite : array[1..maxsprites] of SprRec;
      vidscr,virscr,bgscr : pScreen;   {video, virtual, background screens}
      dead : byte;                     {Counts the dead sprites}
      survivor : byte;                 {Identify the last dead sprite}
      Population : word;               {Population from 1..128}
      {CharColor : byte;}              {Character digit color 0..255}

      Timer : longint;                 {Stopwatch}
      H, M, S, S100 : Word;
      Startclock, Stopclock : Real;
      mins, secs     : integer;
      Code: integer;                     {temporary result of VAL conversion}

procedure GetTime(var Hr, Mn, Sec, S100 : word); assembler; {Avoids DOS unit}
asm
    mov ah,2ch
    int 21h
    xor ah,ah                 {fast register clearing instead of MOV AH,0}
    mov al,dl
    les di,S100
    stosw
    mov al,dh
    les di,Sec
    stosw
    mov al,cl
    les di,Mn
    stosw
    mov al,ch
    les di,Hr
    stosw
end;

procedure StartTimer;
begin
  GetTime(H, M, S, S100);
  StartClock := (H * 3600) + (M * 60) + S + (S100 / 100);
end;

procedure StopTimer;
begin
  GetTime(H, M, S, S100);
  StopClock := (H * 3600) + (M * 60) + S + (S100 / 100);
  Timer := trunc(StopClock - StartClock);
  secs := Timer mod 60;                             {Seconds remaining}
  mins := Timer div 60;                             {Reduce into minutes}
end;
function KeyPressed : boolean; assembler;   {Avoids unit CRT.KeyPressed}
asm
    mov ah,01h;    int 16h;    jnz @0;    xor ax,ax;    jmp @1;
@0: mov al,1
@1:
end;

procedure SetMode(M:byte); assembler;
asm
    mov ah,0;        mov al,M;        int 10h;
end;
procedure SetPal(col,r,g,b:byte); assembler;      {256 color palette}
asm
    mov dx,03c8h
    mov al,col             {color}
    out dx,al
    inc dx
    mov al,r               {red component}
    out dx,al
    mov al,g               {green component}
    out dx,al
    mov al,b               {blue component}
    out dx,al
end;
procedure flip(srcscr, destscr : pScreen); assembler;   {copy screen}
asm
    push ds
    lds si,srcscr
    les di,destscr
    mov cx,pxsize*pysize/2
    rep movsw
    pop ds
end;
procedure cls(scr : pScreen); assembler;   {clear screen}
asm
    les di,scr;  xor ax,ax;  mov cx,pxsize*pysize/2;  rep stosw
end;
procedure retrace; assembler;
asm
        mov dx,03dah
@vert1: in al,dx
        test al,8
        jnz @vert1
@vert2: in al,dx
        test al,8
        jz @vert2
end;
procedure PutSprite(var sprite: SprRec; virseg: pScreen); assembler;
asm
        push ds
        lds si,sprite                   { get sprite segment }
        les di,virseg                   { get virtual screen segment }
        mov ax,SprRec[ds:si].y
        shl ax,6
        mov di,ax
        shl ax,2
        add di,ax                       { y*pxsize }
        add di,SprRec[ds:si].x          { y*pxsize+x }
        mov dx,pxsize-xsize             { number of pixels left on line }
        lds si,SprRec[ds:si].buf
        mov bx,ysize
@l1:    mov cx,xsize
@l0:    lodsb
        or al,al
        jz @skip                        { check if transparent "Black" }
        mov es:[di],al                  { draw it }
@skip:  inc di
        dec cx
        jnz @l0
        add di,dx
        dec bx
        jnz @l1
        pop ds
end;
procedure OnlyVGA; assembler;
asm
  @CheckForVga: {push    es}
                mov     AH,1ah         {Get Display Combination Code}
                mov     AL,00h         {AX := $1A00;}
                int     10h            {Intr($10, Regs);}
                cmp     AL,1ah         {IsVGA:= (AL=$1A) AND((BL=7) OR(BL=8))}
                jne     @NoVGA
                cmp     BL,07h         {VGA w/ monochrome analog display}
                je      @VgaPresent
                cmp     BL,08h         {VGA w/ color analog display}
                je      @VgaPresent
  @NoVGA:
                mov     ax,3           {text mode}
                int     10h
                push    cs
                pop     ds
                lea     dx,@message
                mov     ah,9
                int     21h            {print $ terminated string}
                mov     ax,4c00h
                int     21h            {terminate}
  @message:     db      'Sorry, but you need a VGA to see this!',10,13,24h
  @VgaPresent:  {pop     es}
  {... After here is where your VGA code can execute}
end;  {OnlyVGA}

VAR   n : byte;               {sprite number}
      hx,hy,i,j,k,np : integer;
BEGIN  {PROGRAM}
 {Get text from command line and convert into a number}
 Val(ParamStr(1), Population, Code);
 if (Code <> 0)    {writeln('Bad number at position: ', Code);}
   OR (Population <1) OR (Population > maxsprites) then
   Population := maxsprites;    {default}
 if ParamStr(1) = '?' then
   begin
    writeln('Howard International, P.O. Box 34633, NKC, MO 64116 USA');
    writeln('1994 Freeware Sprite Game v1.2');
    writeln('Syntax:  spritegame.exe  [number]');
    writeln('         optional number is the total population of sprites (1 to 128)');
    halt;
   end;

 {CharColor := Population;}
 OnlyVGA;
 SetMode($13);                  {320x200x256x1 plane}
 Randomize;
 vidscr := Ptr($A000,0);
 New(virscr); cls(virscr); New(bgscr); cls(bgscr);
 np := 128 div Population;
 for i := 0 to Population-1 do
  begin  {Define moire background pattern}
   case i mod 6 of
    0:begin
       hx := 23;       hy := i*np;       n := 0;
      end;
    1:begin
       hx := i*np;     hy := 23;         n := 0;
      end;
    2:begin
       hx := i*np;     hy := 0;          n := 23;
      end;
    3:begin
       hx := 23;       hy := 0;          n := i*np;
      end;
    4:begin
       hx := 0;        hy := 23;         n := i*np;
      end;
    5:begin
       hx:= 0;         hy:= i*np;        n := 23;
      end;
   end;
   for j := 0 to np-1 do
    begin
     k := j shr 1;
     SetPal(np*i+j+1, k+hx, k+hy, k+n);
    end;
  end;

 for i := 1 to 127 do SetPal(127+i, i div 3, 20+i div 5, 20+i div 7);
 for i := 0 to pxsize-1 do     {jh bug!  Reduce to legal screen limits}
   for j := 0 to pysize-1 do
     bgscr^[j,i] := 128+ ABS(i*i - j*j) and 127;
(*
 flip(bgscr, vidscr);               {copy background to video}
 {SetPal(?,r,g,b)}                  {force a visible text palette entry}
 writeln('Sprite Game v1.2 ');      {modify video}
 flip(vidscr, bgscr);               {copy video to background}
*)
 hx := xsize shr 1;
 hy := ysize shr 1;
 for n := 1 to Population do
  begin
   with sprite[n] do
    begin
     x := 20+ random(280 - xsize);
     y := 20+ random(160 - ysize);
     xspd := random(6) - 3;
     yspd := random(6) - 3;
     energy := random(10);         {punishes liberals}
     if xspd=0 then
       begin
        xspd := 1;
        energy := random(20);      {average life expectancy}
       end;
     if yspd=0 then
       begin
        yspd := 1;
        energy := random(40);      {rewards conservatives}
       end;
     New(buf);
     for i := 0 to xsize-1 do
      for j := 0 to ysize-1 do
       begin
        k := (i-hx) * (i-hx) + (j-hy) * (j-hy);
        if (k< hx*hx) and (k> hx*hx div 16)
        then buf^[j,i] := k mod np  + np * (n-1)
        else buf^[j,i] := 0;       {CRT color "Black" is transparent}
       end;
    end; {with}
  end; {for}

  {jh Can store your own bitmap image in any sprite[n].buf^[j,i] such as: }
  for i := 0 to xsize-1 do
    for j := 0 to ysize-1 do
      begin
        sprite[1].buf^[j,i] := j;           {first sprite.  Horizontal bars}
        sprite[Population].buf^[j,i] := i;  {last sprite.  Vertical bars}
      end;

  {jh Get characters from default font and attach to sprites}
  for i := 1 to CharRows do
    for j := 1 to CharRows do
      begin
        for n := 1 to Population do
          begin
            {first hex digit for current sprite}
            if (CharSet[ord(HexDigits[n SHR 4]),i] shr (8-j) and 1 = 1) then
              sprite[n].buf^[i,j] := n       {CharColor}
            else
              sprite[n].buf^[i,j] := 0;      {transparent}
            {second hex digit for current sprite}
            if (CharSet[ord(HexDigits[n AND $F]),i] shr (8-j) and 1 =1) then
              sprite[n].buf^[i,j+CharRows] := n   {CharColor}
            else
              sprite[n].buf^[i,j+CharRows] := 0;  {transparent}
          end;
(* {mark last sprite 'Z'}
   sprite[Population].buf^[i,j] := CharSet[ord('Z'),i] shr (8-j) and 1; *)
      end;

  {jh Keep track of the last dead sprite and how old it was. }
  StartTimer;
  while not (KeyPressed or (dead=Population)) do
  begin
  flip(bgscr, virscr);
  retrace;
  dead := 0;                         {reset the sentinel}
  for n := 1 to Population do
    with sprite[n] do
    begin
      if energy > 0 then PutSprite(sprite[n], virscr)     {show(n)}
      { else if energy < 0 then hide(n) }
      else inc(dead);
      inc(x,xspd);
      if (x<10) or (x > (310 - xsize)) then
      begin
        xspd := -xspd;
        energy := energy - 1;
      end;
      inc(y,yspd);
      if (y<10) or (y > (190 - ysize)) then
      begin
        yspd := -yspd;
        energy := energy - 1;
      end;
    end; {with}
  flip(virscr, vidscr);
  end; {while}

  StopTimer;
  survivor := 0;
  for n := 1 to Population do
    begin                           {find last dead sprite with zero energy}
      if sprite[n].energy = 0 then survivor := n;
      Dispose(sprite[n].buf);
    end;
  Dispose(virscr);  Dispose(bgscr);
  SetMode($3);      {resume text video mode 3h= 80x25x16 color}
  writeln('Last dead sprite was # ', survivor, ' of ', Population);
  writeln('Time of death was ', trunc(StopClock));
  writeln('Life span was ', mins:2, ' Minute and ', secs:2, ' Seconds');
END.   {PROGRAM}

