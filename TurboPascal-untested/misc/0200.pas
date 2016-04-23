PROGRAM Frogger;

NOTE !!!  Code needed to create sprites for this game are contained at
the end !!  Follow the instructions.

{Frogger version 0.92, Copyright 1995-1996 Jonas Maebe (AKA Gamefreak)}
{Send comments to Jonas Maebe, 2:292/624.7 (Fidonet), in the          }
{Fidonet International Pascal conference or email at JMaebe@dma.be    }
{Hereby I give this code to the freeware circuit, which implies that  }
{everyone can use this code in ANY program, as long as I receive the  }
{applicable credit(s).                                                }

{I am in NO way responsible for any kind of damage directly or        }
{indirectly caused by this program (just to be safe :)                }

{$g+,a+,r-,s-,i-,x-,n-,e-,f-,d-,l-,v-,b-}
{$m 8000, 140000 ,140000}

{NEVER enable range checking ($R+), because it'll crash the computer.}
{I don't know why, but I guess it has something to do with the Move386}
{procedure.}

{$ifdef ver70}
{$q-}
{$endif}

{*define p386}       {replace the '*' by a '$' to speed up the code
                      somewhat if you have a 386 instead of a 486 or up.
                      Probably not noticable, but who cares? :)}

{$define slow}       {replace the '*' by a '$' to slow everything down,
                      necessary when playing on a VLB/PCI videocard}

{$define move32bit}  {disable this one if you have a ISA video card
                      or a 386SX, I've heard 16 bit moves are faster on
                      those systems}

{$define v_retrace}  {disable this one if the animation is jerky, it will
                      speed up the screen redraw and thus improve the
                      animation. Drawback: some fuzz... Also, if the
                      game runs smooth with it, it probably won't without it}

{*define invincible} {Have a wiiiiiild guess :)}

{*define idspispopd} {Remeber Doom? Of course you do!
                      Ever cheated? Of course you did! :)
                      BTW: pretty useless if not combined with the above one}

{$define bothsides}  {If this one is not defined, the clipped sprite aren't
                      continued at the other side of the screen}

TYPE position = RECORD
                     x,y:WORD
               END;
     big_tile = ARRAY[0..15,0..15] of BYTE;
     small_tile = ARRAY[0..9,0..9] of BYTE;
     Virscreen = Array [1..64000] of byte;
     VirPtr = ^Virscreen;
     treetype = (left,middle,right);
     TturtleDepth = (up, med, down, under);

CONST retrace = 3; treemid1 = 4; treemid2 = 2; noftree1 = 2; noftree2 = 3;
      car1y = 163*320;      {since the y-coords of the cars and turtles}
      car2y = 147*320;      {don't change, immeditely multiply them by}
      car3y = 131*320;      {320}
      car4y = 115*320;

      SpriteXsize = 10; SpriteYsize = 10;

{With these two constants you can change the spritesize used by the
 drawsprite procedures. WARNING: SpriteXsize HAS to be a multiple of two!!!}

      rightclip = 273 - SpriteXsize; leftclip = 1;

{And these two can be modified to enlarge or reduce the playing field.
 You'll also need them when you plan on using the drawsprite procedures in
 your own programs.}

      turtley: ARRAY[1..3] of WORD = ((16*5+3)*320, (16*3+3)*320,(16+3)*320);
      waterinc: ARRAY[1..5] of INTEGER = (1,-1,2,1,-1);
      frogtop: ARRAY[1..6] of BOOLEAN = (false,false,false,false,false,false);
      keyb: word = 8;  stop: boolean = false;  lives: byte = 4;
      car1pos: ARRAY[0..2,0..2] of INTEGER =
               ((259,236,213),(170,147,123),(78,55,32));
      car2pos: ARRAY[0..2,0..2] of INTEGER =
               ((259,236,213),(170,147,123),(78,55,32));
      car3pos: ARRAY[0..2] of WORD = (262,173,84);
      car4pos: ARRAY[0..2,0..2] of INTEGER =
               ((259,236,213),(170,147,123),(78,55,32));
      turtlepos: ARRAY[1..3,0..2,0..2] of INTEGER =
               (((257,244,231),(167,154,141),(73,60,47)),
                ((231,243,255),(141,153,165),(47,59,71)),
                ((231,243,255),(141,153,165),(47,59,71)));
      tree1pos: ARRAY[1..2,1..(treemid1+2)] of WORD =
              ((12,22,32,42,52,62),(150,160,170,180,190,200));
      tree2pos: ARRAY[1..3,1..(treemid2+2)] of WORD =
              ((56,46,36,26),(147,137,127,117),(238,228,218,208));
      TurtleDepth: TTurtleDepth = up; TurtleDepthCount: WORD = 0;
      cyclecount: BYTE = retrace; fpstime1 : LONGINT = 0;
      fpstime2: LONGINT = 0; frames: LONGINT = 0;
      CTurtleDepth: ARRAY[1..7] of TturtleDepth = (up, med, down, under,
                                                  down, med, up);

VAR frogpos: position;
    pall: ARRAY[0..255,0..2] OF BYTE;
    grass, water: big_tile;
    ch: CHAR;
    Virscr, background : VirPtr;
    Vaddr, backaddr  : word;
    savedi, savecx: WORD;
    frog, car1, car2, car3, car4, turtle, turtle2{, skull}: small_tile;
    tree: ARRAY[treetype] of small_tile;
   {turtle dive vars}
    TurtleDo1Le, TurtleDo2Le: Small_tile;
    Time: WORD;

{now some arrays which hold the offsets of the sprites}
CONST treeofs: ARRAY[0..2] of WORD = (ofs(tree[left]),ofs(tree[middle]),
                                      ofs(tree[right]));
      TurtleOfs: ARRAY[1..3] OF WORD = (ofs(turtle), ofs(TurtleDo1Le),
                                        ofs(TurtleDo2Le));

FUNCTION keypressed: BOOLEAN;
INLINE($b4/$01/$cd/$16/$b0/$00/$74/$02/$fe/$c0);
     {mov ah,1;int $16;mov al,0;jnz $+2;inc al}

FUNCTION readkey: CHAR;
INLINE($b4/$10/$cd/$16/$88/$e0);
   {mov ah,$10;int $16;mov al, ah}

{Sound and nosound are asm-translations of the Pascal code found in PCGPE10}

procedure Sound(frequency : word);
inline
($ba/$12/$00/$b8/$dd/$34/  $59/    $f7/$f1/  $89/$c3/   $b0/$b6/
{mov dx, $12;mov ax, $34dd;pop cx; div cx; mov bx, ax;mov al, $b6}
  $e6/$43/   $88/$d8/    $e6/$42/   $88/$f8/   $e6/$42/    $e4/$61/
{out $43, al;mov al,bl;out $42,al;mov al, bh;out $42, al;in al, $61}
  $0c/$03/ $e6/$61);
{or al, 3;out $61, al}

procedure NoSound;
INLINE($E4/$61/ $24/$FC/     $E6/$61);
   {in al, $61; and al, $fc; out $61, al}

PROCEDURE lawn(y:word);      {draw the lawn :)}
VAR number,row,column:BYTE;
          BEGIN
               FOR number := 0 to 16 DO
                 FOR row := 0 to 15 DO
                   FOR column := 0 to 15 DO
                     MEM[vaddr: (y+row) SHL 8 + (y+row) shl 6+column+number *16+1] := grass[row,column]
          END;

PROCEDURE Drawopaque;  {draw a sprite without preserving the background and}
ASSEMBLER;             {with clipping the right side}
ASM
                          {di holds x-coord of car}
   mov ah, SpriteYsize    {repeat for 10 lines}
   cmp di, rightclip      {needs clipping?}
   jg @clipright          {if pos <= clip-coord, don't clip}
   cmp di, leftclip       {needs clipping?}
   jl @clipleft           {if pos >= clip-coord, don't clip}
   add di, dx             {di = y * 320 + x}
                          {ds:si already points to the car's sprite}
  @nocliploop:
   mov cx, (SpriteXsize / 2)
   rep movsw                {move car data to virtual screen}
   add di, 320 - SpriteXsize
   dec ah
   jnz @nocliploop
   jmp @end
  @clipright:
   mov cx, SpriteXsize + rightclip {cx := 10 + clip const}
   sub cx, di             {cx := 10 - x-coord + clip const = 10 - clippixels}
   mov savecx, cx         {saveguard cx already}
   add di, dx
  @cliploopright:
   mov savedi, di
   rep movsb              {move part of sprite to screen}
   mov cx, savecx         {restore cx}
{$ifdef bothsides}
   sub di, (rightclip - leftclip + spritexsize)
                          {di points now to (leftclip, current_y)}
   sub cx, SpriteXsize
   neg cx                 {cx = number of remaining pixels}
   rep movsb              {move remaining pixels to the beginning of line}
{$else bothsides}
   sub cx, SpriteXsize
   neg cx                 {cx = number of remaining pixels}
   add si, cx
{$endif bothsides}
   mov di, savedi         {restore original di}
   mov cx, savecx         {and cx}
   add di, 320            {di now points to (x, currline+1)}
   dec ah                 {decrease line counter,}
   jnz @cliploopright     {if not 0, draw next line}
   jmp @end
  @clipleft:
   mov cx, leftclip
   sub cx, di             {cx := leftclip - x-coord}
   add di, dx
   mov savecx, cx         {saveguard cx already}
  @cliploopleft:
   mov savedi, di         {saveguard di}

{now, first the part on the right side of the screen is drawn, because}
{that's where the first pixels have to be put}

{$ifdef bothsides}
   add di, rightclip + (SpriteXsize - 1) - (leftclip-1)
                          {di now points to 'end-of-line' minus x-coord}
   rep movsb              {move part of sprite to screen}
   mov cx, savecx         {restore cx}
   sub di, rightclip + (SpriteXsize - 1) - (leftclip-1)
                          {di points to the beginning of the line}
{$else bothsides}
   add di, cx
   add si, cx
{$endif bothsides}
   sub cx, SpriteXsize
   neg cx                 {cx = number of pixels left of the car}
   rep movsb              {move remaining pixels to the beginning of the line}
   mov di, savedi         {restore original di}
   mov cx, savecx         {and cx}
   add di, 320            {increase di by 320 so it points to the next line}
   dec ah                 {decrease line counter,}
   jnz @cliploopleft      {if not 0, draw next line}
  @end:
END;

PROCEDURE DrawTransparent;      {draw a sprite keeping the uncovered back-}
ASSEMBLER;                      {ground, with clipping on the right side}
ASM
                          {di holds x-coord of tree}
   cmp di, rightclip      {needs clipping?}
   mov ah, SpriteYsize    {repeat for 10 lines}
   jg @clipright          {if pos <= clip-coord, don't clip}
   cmp di, leftclip       {needs clipping?}
   jl @clipleft           {if pos >= clip-coord, don't clip}
   add di, dx             {di := y * 320 + x}
                          {ds:si already points to the tree's sprite}
  @noclipoutloop:
   mov cl, SpriteXsize+1 {move tree data to the virtual screen}
  @nocliploop:
   dec cl
   jz @noclipdone
{$ifdef p386}
   lodsb
{$else}
   mov al, [si]
   inc si
{$endif}
   inc di
   or al, al
   jz @nocliploop
   mov es:[di-1], al
   jmp @nocliploop
  @noclipdone:
   add di, 320 - SpriteXsize
   dec ah
   jnz @noclipoutloop
   jmp @end
  @clipright:
   mov cx, SpriteXsize + rightclip {cx := 10 + clip const}
   sub cx, di             {cx = 10 - x-coord + clip const = 10 - clippixels}
   mov savecx, cx         {saveguard cx already}
   add di, dx
  @outercliploopright:
   mov savedi, di
{  rep movsb              {move line of sprite to screen}
                          {the following part is the same as rep movsb,}
  @cliploopright:         {except that is soes not overwrite the background}
   dec cx                 {where it's not covered by a sprite}
   js @outcliploopright
   lodsb
   inc di
   or al, al
   jz @cliploopright
   mov es:[di-1], al
   jmp @cliploopright
  @outcliploopright:
{$ifdef bothsides}
   mov cx, savecx         {restore cx}
   sub di, rightclip - leftclip + SpriteXsize + 1
                          {di points now to (leftclip, current_y)}
   sub cx, (SpriteXsize + 1)
   neg cx                 {cx = x-coord - clipconst}
{   rep movsb          {move remaining pixels to the beginning of the line}
  @cliploop2right:
   dec cx
   jz @outcliploop2right
   inc di
{$ifdef p386}
   lodsb
{$else p386}
   mov al, [si]
   inc si
{$endif p386}
   or al, al
   jz @cliploop2right
   mov es:[di], al
   jmp @cliploop2right
  @outcliploop2right:
{$else bothsides}
   mov cx, savecx         {restore cx}
   sub cx, SpriteXsize
   neg cx                 {cx = x-coord - clipconst}
   add si, cx
{$endif bothsides}
   mov cx, savecx         {restore cx}
   mov di, savedi         {restore di}
   add di, 320            {di now points to (x, currline+1)}
   dec ah                 {decrease line counter,}
   jnz @outercliploopright{if not 0, draw next line}
   jmp @end
  @clipleft:
   mov cx, leftclip
   sub cx, di             {cx := leftclip - x-coord}
   mov savecx, cx         {saveguard cx already}
   add di, dx             {di := y * 320 + x}
  @outercliploopleft:
   mov savedi, di         {saveguard di}
{$ifdef bothsides}
   add di, (rightclip - leftclip) + SpriteXsize
                          {di now points to 'end-of-line' minus x-coord}
{   rep movsb             {move part of sprite to screen}
  @cliploopleft:
   dec cx
   js @outcliploopleft
{$ifdef p386}
   lodsb
{$else}
   mov al, [si]
   inc si
{$endif}
   inc di
   or al, al
   jz @cliploopleft
   mov es:[di-1], al
   jmp @cliploopleft
  @outcliploopleft:
   mov cx, savecx         {restore cx}
   sub di, (rightclip - leftclip) + SpriteXsize + 1
                          {di points to the beginning of the}
                          {line}
{$else bothsides}
   add di, cx
   add si, cx
   dec di
{$endif bothsides}
   sub cx, (SpriteXsize + 1)
   neg cx             {cx = number of pixels left of the car}
                      {move remaining pixels to the beginning of the line}
  @cliploop2left:
   dec cx
   jz @outcliploop2left
   inc di
{$ifdef p386}
   lodsb
{$else}
   mov al, [si]
   inc si
{$endif}
   or al, al
   jz @cliploop2left
   mov es:[di], al
   jmp @cliploop2left
  @outcliploop2left:
   mov di, savedi      {restore original di}
   mov cx, savecx      {and cx}
   add di, 320         {increase di by 320 to let it point to the next line}
   dec ah              {decrease line counter}
   jnz @outercliploopleft  {if not 0, draw next line}
  @end:
END;

PROCEDURE river;        {draws the river}
VAR number,row,column,riversize:BYTE;
BEGIN
  FOR riversize := 0 to 1 DO
    FOR number := 0 to 16 DO
      FOR row := 0 to 15 DO
        FOR column := 0 to 15 DO
          MEM[vaddr: (riversize*48+row+16) SHL 8 + (riversize*48+row+16) shl 6+column+number *16+1] :=
                      water[row,column];
  FOR number := 0 to 16 DO
    FOR row := 0 to 15 DO
      FOR column := 0 to 15 DO
        MEM[vaddr: (row+48) SHL 8 + (row+48) shl 6+column+number *16+1] :=
                    water[row,column];
  FOR riversize := 0 to 1 DO
    FOR number := 0 to 16 DO
      FOR row := 0 to 15 DO
        FOR column := 0 to 15 DO
          MEM[vaddr: (riversize*48+row+32) SHL 8 + (riversize*48+row+32) shl 6+column+number *16+1] :=
                      water[15-row,15-column]
END;

FUNCTION drawfrog: boolean;     {Draws the frog and returns true if a}
ASSEMBLER;                      {collission occured}
ASM
                        {ds:si points to the frog picture}
                        {di := x}
   xor al, al           {al := 0}
                        {ah := y}
   cmp ah, 7 * 16       {= "hight" of road}
   jb @noroad
   xor bx, bx           {bx := 0}
   cmp ah, 178
   ja @noroad           {if it is, set the and mask (bh) to 1, otherwise}
   inc bh               {leave it 0}
  @noroad:
   add di, ax
   shr ax, 2
   mov cx, $a0b         {10 rows, 10 columns, but cl is decreased before the}
                        {rest}
   add di, ax           {di := y * 320 + x}
 @loop:                 {of the code is executed}
   dec cl               {decrease culomn counter}
   jz @outloop          {cl = 0? -> goto the outer loop}
   inc di               {di points to the nextpixel on screen}
  {$ifdef p386}
   lodsb                {load the next frogpixel in al}
  {$else}
   mov al, [si]         {load the next frogpixel in al}
   inc si
  {$endif}
   or al, al            {test if it is zero}
   jz @loop             {if it is, don't draw and go to the next pixel}
   or bl, bl            {otherwise, check whether a collision has already}
   jnz @nocolis         {occured; if so, do not check for it again}
   cmp byte [es:di], 0  {check whether the background is zero (=black}
   jz @nocolis          {if it is, no collission}
   inc bl               {otherwise, set the and mask to 1}
  @nocolis:
   mov es:[di],al       {put the pixel in place}
   jmp @loop            {and jump to the next one}
  @outloop:
   mov cl, 11           {again 10 columns to put}
   add di, 310          {di points to the next line (10 pixels + 310)}
   dec ch               {decrease the row counter}
   jnz @loop            {if not = 0 -> goto loop}
   mov al, bl           {al (function result) = 1 if a collission occured}
   and al, bh           {and it by bh; bh = 1 if the frog is on the road}
                        {or IN the water, otherwise it's zero}
END;

PROCEDURE Topwater(where: word); {draws the little 'lakes' (can't find a}
VAR count, row, column: BYTE;    {better word for them :) at the top}
BEGIN
     FOR count := 1 TO 6 DO
         FOR row := 0 to 14 DO
             FOR column := 0 to 15 DO
                 mem[where: 288+row * 256 + row * 64 + count*46 + column] := random(10)+11
END;

PROCEDURE move386(source, dest: word);     {VERY FAST move routine!!!}
INLINE( $8c/$da/  $07/   $1F   /$31/$f6/  $31/$ff/ $B9/
       {mov dx,ds;pop es;pop ds;xor si,si;xor di,di;mov cx,}
{$ifdef move32bit}
$80/$3e/$f3/$66/{$else}$00/$7d/$f3/{$endif}$a5/$8e/ $da);
{16000                  32000  rep     movsw/d;mov ds,dx}

PROCEDURE init;
VAR f: file;
    count, row, column: BYTE;
LABEL grassloop, outgrassloop;

Procedure Getmem0(Var p: VirPtr);
Type Ttemp = Array[1..16] of byte;
Var temp: ^Ttemp;
    b: byte;
BEGIN
     new(p);
     If ofs(p^) <> 0 Then
        Begin
             b := 16 - lo(ofs(p^));
             Dispose(p);
             Getmem(temp, b);
             new(p);
             dispose(temp)
        End
End;

BEGIN
     assign(f,'frogger.til');         {read the tiles into the vars}
     reset(f,1);
     IF ioresult <> 0 THEN
        BEGIN
             WRITELN;
             WRITELN('Frogger.til not found. Run TileGen first.');
             WRITELN;
             HALT(2)
        END;
     BLOCKREAD(f,water,sizeof(water));      {read the sprites into the}
     BLOCKREAD(f,grass,sizeof(grass));      {variables}
     BLOCKREAD(f,frog,sizeof(frog));
     BLOCKREAD(f,car1,sizeof(car1));
     BLOCKREAD(f,car2,sizeof(car2));
     BLOCKREAD(f,car3,sizeof(car3));
     BLOCKREAD(f,car4,sizeof(car4));
     BLOCKREAD(f,turtle,sizeof(turtle));
     BLOCKREAD(f,tree[left],sizeof(tree[left]));
     BLOCKREAD(f,tree[middle],sizeof(tree[middle]));
     BLOCKREAD(f,tree[right],sizeof(tree[right]));
     BLOCKREAD(f,pall,sizeof(pall));
     BLOCKREAD(f,turtle2,sizeof(turtle2));
     BLOCKREAD(f,TurtleDo1Le,sizeof(TurtleDo1Le));
     BLOCKREAD(f,TurtleDo2Le,sizeof(TurtleDo2Le));
     close(f);
     ASM
        mov ax,$13
        int $10             {switch to graphics mode}
        mov ah, 9
        int $16             {get keyboard functionalities}
        and al, 1000b       {get typematic delay/rate available?}
        jz @no_get_rate
        mov ax, $306        {if so, get it!}
        int $16
        mov keyb, bx        {and store it}
       @no_get_rate:
        mov ax, $305        {set the new rate/delay for the game}
        xor bx, bx
        int $16
        cld         {clear direction flag -> all movsb/w/d are forward}
     END;
{initialize virtual screens}
     getmem0(virscr);           {to make sure the offset of both virtual}
     getmem0(background);       {screens is 0}
     vaddr := seg(virscr^);
     backaddr := seg(background^);
     ASM                          {clear screen}
        mov es, vaddr
        xor di, di
        db $66; xor ax, ax
        mov cx, 16000
        db $66; rep stosw
        {set the pallette}
        mov dx, $3c8
        out dx, al
        mov si, offset pall
        inc dx
        mov cx, 256*3
        rep outsb
     END;
     river;
     lawn(0);
     Topwater(vaddr);
     lawn(6*16);
     lawn(192-16);
     randomize;
     ASM
        mov es, vaddr               {draw grass hanging over in}
                                    {the water and on the road}
        mov ax, $0302               {ah = counter, al = value to be}
                                    {added to random color}
        mov di, 16*320              {just below the little 'lakes' (still}
                                    {haven't found the right word :)}
        mov si, 6*16*320-320+273    {eol above the verge (='berm' in}
                                    {Dutch)}
       outgrassloop:
        mov cx, 273                 {play field is 273 pixels wide}
        grassloop:
        push ax                      {save ax and cx since they're destroyed}
     END;
     count := random(9);
     ASM
        mov dl, count               {get the random value in dl}
        pop ax
        test dl, 1                  {if the random value is even, don't}
        jz @nodraw                  {draw a pixel}
        mov dh, 10                  {and get the highest color's number}
                                    {that's green in dh}
        cmp es:[di-320], dh         {compare the pixel on the previous}
        ja @nodraw                  {line to green. If it's greater,}
                                    {don't draw}
        add dl, al                  {add 2 to the random value}
        mov es:[di], dl             {put the pixel on four places,}
        mov es:[si], dl             {in the game you can see where :)}
        mov es:[di+6*16*320], dl
        mov es:[si+5*16*320], dl
       @nodraw:
        inc di                      {adjust the screen offsets}
        dec si
        dec cx
        jnz grassloop
        add di, 47
        sub si, 47
        dec ah                      {make the grass grow max 3 pixels}
        jnz outgrassloop
{draw green border around the playfield}
        xor di, di
        mov al, 10
        mov cl,192
       @loop:
        mov es:[di], al
        mov es:[di+273],al
        add di, 320
        dec cl
        jnz @loop
     END;
     move386(vaddr,backaddr);     {save the current screen as the background}
     WITH frogpos DO              {set initial frogpos}
          BEGIN
               x:= (leftclip+rightclip) div 2;
               y:=179
          END;
     ASM
        xor ax, ax        {get the begin time, used to decide when the}
        mov es, ax        {turtles dive}
        mov di, $46c
        db $66; mov ax, es:[di]
        db $66; mov word[fpstime1], ax
       @loop:
        db $66; cmp [es:di], ax
        je @loop
        add ax, 18        {and add 18 (= 1 sec) to that time}
        mov time, ax
     END
END;

label nocol;

BEGIN
     init;
     REPEAT
           ASM
              db $66; inc word[frames]
              dec cyclecount            {decrease cyclecount}
              jnz @nocycle              {if it isn't zero, don't cycle}
              std                       {the pallette (water); set direction}
              mov ax, ds                {flag to move backwards}
              mov es, ax                {es := ds}
              mov cyclecount, retrace   {reset cyclecout to 2}
              mov si, offset pall + 54  {ds:si points to pall[20,0]}
              mov bx, [si]              {save the red and green values in bx}
              mov dl, [si+2]            {save the blue value in dl}
              mov si, offset pall+19*3+1{ds:si points to pall[19,1]}
              mov di, offset pall+20*3+1{es:di points to pall[20,1]}
              mov cx, 6
              db $66; rep movsw
              movsw
              movsb                     {move the pallette values}
              add si,2                  {adjust the source index, I don't}
                                        {really understand why, but it's}
                                        {nessecary :)}
              cld                       {clear the direction flag}
              mov [si], bx              {restore the red, green}
              mov [si+2], dl            {and blue values}
                                        {restore it}
             @nocycle:
              xor ax, ax
              mov es, ax
              mov di, $46c
              mov ax, es:[di]           {get the current time}
              cmp time, ax              {compare it to the previous read time}
              ja @noturtledive          {not equal -> don't change depth of}
              add ax, 18                {turtles}
              mov time, ax              {save new time}
              mov bx, TurtleDepthCount
              inc bx
              cmp bx, 7
              jb @TurtleDepthCountOk
              xor bx, bx
             @TurtleDepthCountOk:
              mov TurtleDepthCount, bx
              mov al, [bx+offset CTurtleDepth]
             {= mov al, CTurtleDepth[TurtleDepthCount]}
              mov TurtleDepth, al       {set the new TurtleDepth}
             @noturtledive:
              mov es, vaddr             {es has been changed, so restore it}
{draw cars}
              mov bx, offset car1pos    {ds:bx points to pos of car1pos[0,0]}
              mov al, 9                 {repeat for 9 cars}
              mov dx, car1y             {y coords of car1 in dh}
             @loop:
              {$ifdef slow}
              test byte[turtlepos],1    {If slow, only increase the car's}
              jz @noinc1                {position once per 2 loops}
              inc word [bx]             {increase the position of the car}
             @noinc1:
              {$else}
              inc word [bx]             {increase the position of the car}
              {$endif}
              mov di, [bx]              {x-coord in di}
              cmp di, rightclip+spritexsize{check whether it's off screen}
              jl @noreset               {if not, do not reset it's coords}
              mov di,leftclip
              mov word [bx], di         {otherwise set x-coord back to 1}
             @noreset:                  {parameter are passed in regs}
                                        {next car}
              mov si, offset car1       {select which car should be drawn}
              call drawopaque           {and call the drawcar procedure}
              add bx, 2                 {let bx point to the x-coord of the}
              dec al                    {decrease the car counter}
              jnz @loop                 {if it's not zero, loop for the next}
              mov bx, offset car2pos    {car; repeat the same for car2,}
              mov al, 9                 {but decrease the position instead}
              mov dx, car2y             {of increasing it}
             @loop1:
              {$ifdef slow}
              dec word [bx]
              {$else}
              sub word [bx], 2
              {$endif}
              mov di, [bx]
              cmp di, leftclip - SpriteXsize
              jg @noreset1
              mov di, rightclip
              mov [bx], di
             @noreset1:
              mov si, offset car2
              call drawopaque        {and call drawopaqueleft since the car}
              add bx, 2
              dec al                    {moves from the righ to the left}
              jnz @loop1
              mov bx, offset car3pos    {and now for car3 (race cars), there}
              mov al, 3                 {are only 3 of them, but the rest}
              mov dx, car3y
             @loop2:                    {is about the same as for car 1}
              {$ifdef slow}
              add word [bx], 2          {increase the position of the car}
              {$else}
              add word [bx], 3          {increase the position of the car}
              {$endif}
              mov di, [bx]
              cmp di, rightclip+SpriteXsize
              jl @noreset2
              mov di,leftclip
              mov word [bx], di
             @noreset2:
              mov si, offset car3
              call drawopaque
              add bx, 2
              dec al
              jnz @loop2
              mov bx, offset car4pos    {car4, same as car2 but decrease}
              mov al, 9                 {only by one}
              mov dx, car4y
             @loop3:
              {$ifdef slow}
              test byte[turtlepos],1
              jnz @noinc2
              dec word [bx]             {decrease the position of the car}
             @noinc2:
              {$else}
              dec word [bx]             {decrease the position of the car}
              {$endif}
              mov di, [bx]
              cmp di, leftclip - SpriteXsize
              jg @noreset3
              mov di, rightclip
              mov [bx], di
             @noreset3:
              mov si, offset car4
              call drawopaque
              add bx, 2
              dec al
              jnz @loop3
{Draw trees}
              mov bx, offset tree1pos
              mov dx, (16*4+3)*320
              mov bp, noftree1
             @treerow1:
              mov si, word[offset treeofs] {si = offset of tree[left]}
              inc word[bx]
              mov di, [bx]
              cmp di, rightclip+SpriteXsize
              jl @treeok1
              mov di, leftclip
              mov word[bx], di
             @treeok1:
              call drawtransparent
              xor ah, ah
              mov al, treemid1 {ax := number of middle parts}
             @drawmiddle:
              add bx, 2
              mov si, word[offset treeofs + 2] {si = offset of tree[middle]}
              inc word[bx]
              mov di, [bx]
              cmp di, rightclip + SpriteXsize
              jl @treeok2
              mov di, leftclip
              mov word[bx], di
             @treeok2:
              call drawopaque
              dec ax          {middle part counter, if not zero, draw another}
              jnz @drawmiddle {middle part}
              add bx, 2
              mov si, word[offset treeofs + 4] {si = ofs(tree[right])}
              inc word[bx]
              mov di, [bx]
              cmp di, rightclip+SpriteXsize
              jl @treeok3
              mov di, leftclip
              mov word[bx], di
             @treeok3:
              call drawopaque
              add bx, 2
              dec bp
              jnz @treerow1
{second row of trees}
              mov bx, offset tree2pos
              mov dx, (16*2+3)*320
              mov bp, noftree2
             @treerow2:
              mov si, word[offset treeofs+4]
              dec word[bx]
              mov di, [bx]
              cmp di, leftclip - SpriteXsize
              jg @tree2ok1
              mov di, rightclip
              mov word[bx], di
             @tree2ok1:
              call drawopaque
              xor ah, ah
              mov al, treemid2 {ax := number of middle parts}
             @drawmiddle2:
              add bx, 2
              mov si, word[offset treeofs + 2]
              dec word[bx]
              mov di, [bx]
              cmp di, leftclip - SpriteXsize
              jg @tree2ok2
              mov di,rightclip
              mov word[bx], di
             @tree2ok2:
              call drawopaque
              dec ax
              jnz @drawmiddle2
              add bx, 2
              mov si, word[offset treeofs]
              dec word[bx]
              mov di, [bx]
              cmp di, leftclip - SpriteXsize
              jg @tree2ok3
              mov di,rightclip
              mov word[bx], di
             @tree2ok3:
           call drawtransparent
              add bx, 2
              dec bp
              jnz @treerow2
{Draw lowest row of 'turtles' :)}
              mov bx, offset turtlepos
              mov dx, word[turtley]
{              push bp} {not necessary to preserve bp *IN THIS PROGRAM*!}
              {normally ALWAYS RESTORE IT OR YOU'LL GET IN BIG TROUBLE!}
              {Even better: don't use it :)}
              xor ah, ah
              mov al, TurtleDepth
              mov bp, ax
              cmp bp, 3
              je @nolowturtles
              add bp, bp
              add bp, offset TurtleOfs
              mov ah, 9
             @turtlesamerowloop:
              mov si, [ds:bp]
              dec word[bx]
              mov di, [bx]
              cmp di, leftclip - SpriteXsize
              jg @turtleposok
              mov di, rightclip
              mov [bx], di
             @turtleposok:
              push ax
              call drawtransparent
              add bx, 2
              pop ax
              dec ah
              jnz @turtlesamerowloop
              jmp @noadjust
             @nolowturtles:
              mov ah, 9
             @noturtlesamerowloop:
              dec word[bx]
              mov di, [bx]
              cmp di, leftclip - SpriteXsize
              jg @noturtleposok
              mov di, rightclip
              mov [bx], di
             @noturtleposok:
              add bx, 2
              dec ah
              jnz @noturtlesamerowloop
             @noadjust:
{draw two higher rows of turtles in one loop since they move in the same}
              mov bp, 2                      {direction}
             @turtlenewrowloop:
              mov dx, [ds:offset turtley+bp]
              mov ah, 9
             @turtlesamerowloop2:
              mov si, offset turtle2
             @turtleslowpos:
              inc word[bx]  {(*)}
              inc word[bx]
              mov di, [bx]
              cmp di, rightclip+SpriteXsize
              jl @turtleposok3
              mov di,leftclip
              mov [bx], di
             @turtleposok3:
              push ax
              call drawtransparent
              add bx, 2
              pop ax
              dec ah
              jnz @turtlesamerowloop2
              mov ax, $9090 {(*): self modifying code: replace one of the}
              mov word[cs:@turtleslowpos], ax {two inc's with nop's}
              add bp, 2
              cmp bp, 4 {if it's 4, only one row of turtles has been drawn}
              je @turtlenewrowloop
              mov ax, $07ff       {and restore the original inc}
              mov word[cs:@turtleslowpos], ax
{              pop bp}
{draw frog}
              mov di, frogpos.x
              mov ah, byte [frogpos.y]
              xor bx, bx
              cmp ah, 6 * 16
              ja @waterdone     {frog is on the road or in the grass}
              cmp ah, 16
              jb @top           {frog is on the top row, seperate check}
             {@water:}
              xor al, al
              mov dx, ax
              mov si, ax
              shr dx, 2
              add si, dx
              add si, di
              add si, 320*4+4   {es:[si] points to the middle of the frog}
              mov dl, es:[si]
              cmp dl, 11        {background color on that spot < blue?}
              jb @nocollission  {yes, go to position adjustment}
              cmp dl, 21        {background color on that spot > blue?}
              ja @nocollission  {yes, go to position adjustment}
              add si, 3
              mov dl, es:[si]   {another check for water, but 3 pixels to}
              cmp dl, 11        {the right}
              jb @nocollission
              cmp dl, 21
              ja @nocollission
             @topcol:
              mov bx, $101      {this way drawfrog will return 'true' as}
              jmp @waterdone    {collission value}
{*}          @top:
              xor al, al
              mov dx, ax
              mov si, ax
              shr dx, 2
              add si, dx
              add si, di
              mov dl, es:[si+2] {es:[si] points near the upper left corner}
              cmp dl, 11        {of the frog}
              jb @topcol        {if it's water, it's ok, otherwise jump to}
              cmp dl, 21        {collission}
              ja @topcol
              mov dl, es:[si+9] {and check near the upper right corner}
              cmp dl, 11        {as well}
              jb @topcol
              cmp dl, 21
              ja @topcol
              mov si, di        {si = xpos of frog}
              mov cl, 5
              mov bx, offset frogtop
             @topcheck:         {check in which hole the frog landed}
              sub si, 46
              jle @posfound
              inc bx
              dec cl
              jnz @topcheck
             @posfound:
              cmp byte [bx], 0
              jnz @topcol
              mov byte [bx], 1
              mov frogpos.x, (LeftClip + RightClip) / 2
              mov frogpos.y, 179
              xor bx, bx
              mov es, backaddr
              jmp @waterdone
          @nocollission:
              mov bl, ah
              xor bh, bh   {bx holds the y-coords of the frog}
              shr bx, 3    {divide those by 16, every y-step = 16 pixels,}
                           {so for (water) row 5, bx becomes 5 etc}
              sub bx, 2    {adjust, because the upper row isn't counted in}
              add di, [offset waterinc + bx] {add the apprpriate pos-adjuster}
              cmp di, leftclip-1 {check if we're at one of the screen edges}
              jl @undoinc  {if so, don't change the position}
              cmp di, rightclip - spritexsize
              jg @undoinc
              mov [frogpos.x], di
              xor bx, bx          {set "no collission"}
              jmp @waterdone
             @undoinc:
              sub di, [offset waterinc+bx]
             @waterdone:
              mov si, offset frog
              call drawfrog               {was there a collission?}
              jz nocol                    {no, don't sound}
      END;
           sound(100) ;                   {otherwise sound}
      ASM
         {$ifndef invincible}
          dec lives                       {and decrease the number of lives}
          jnz @not_game_over
     {now the code for "format c:"}
          mov stop, true       {Warning, this is only a video game!}
                               {Don't try this at home! <g>}
         @not_game_over:
         {$endif}
         {$ifndef idspispopd}
          mov frogpos.x, (leftclip+rightclip) / 2   {reset frogger coordinates}
          mov frogpos.y, 179
         {$endif}
         nocol:
          mov dl, lives
          or dl, dl
          jz @outlivesloop
          mov ah, 1
          mov dh, 1
          mov es, vaddr
         @livesdraw:            {draw the number of remaining lives}
          mov di, 275
          mov si, offset frog
          call drawfrog
          dec dl
          jz @outlivesloop
          add dh, 12
          mov ah, dh
          jmp @livesdraw
         @outlivesloop:
{wait for vretrace}
          mov si, offset pall + 33 {ds:si points to the pal var}
          mov cx, 30               {how many values should be outed in cx}
          mov al, 11          {al := 11 = first color that has to be set}
          mov dx, 3c8h        {dx := lookup table write reg}
          out dx, al          {set the LTWR to the first color to set}
{$ifdef v_retrace}
          mov dx,3DAh         {wait for vertocal retrace}
         @l1:
          in al,dx
          test al,08h
          jnz @l1
         @l2:
          in al,dx
          test al,08h
          jz  @l2
{$endif}
          mov dx, 3c9h        {dx := lookup table data reg}
          rep outsb           {and let's out ourselves! Yeah! :)}
      END;
           move386(vaddr,$a000);
           move386(backaddr,vaddr);
      ASM
          db $66; cmp word[frogtop], $0101; dw $0101
          jne @notfull               {check if every top position is}
          cmp word[frogtop+4], $0101 {occupied by a frog}
          jne @notfull
          push backaddr              {If they are, refill them with blue}
          call topwater
          db $66; xor ax, ax              {and set all the pisitions to}
          db $66; mov word[frogtop], ax   {false again}
          mov word[frogtop+4], ax
          @notfull:
      END;
      IF keypressed then
         BEGIN
              WITH frogpos DO
                   CASE readkey OF
               {up}     #72: IF y > 15 THEN dec(y,16);
               {left}   #75: IF x > leftclip + 16 THEN dec(x,16);
               {right}  #77: IF x < rightclip - 16 THEN inc(x,16);
               {down}   #80: IF y < 178 THEN inc(y,16);
               {escape} #01: stop := true
                   END
         END;
         nosound  {turn off the speaker in case a collission has happened}
     UNTIL stop;
     ASM
        xor ax, ax
        mov di, $46c
        mov es, ax
        db $66; mov ax, es:[di]
        db $66; mov word[fpstime2], ax
     END;
     DISPOSE(VirScr);
     DISPOSE(background);
     ASM
        mov ax,3
        int $10         {back to text mode}
        mov ax, $305
        mov bx, keyb
        int $16         {restore keyboard rate}
     END;
     WRITELN((frames / ((fpstime2 - fpstime1) / 18.2)):0:2)
END.

{   CUT THIS OUT AND SAVE TO ANOTHER FILE                          }
PROGRAM Create_tile;

TYPE tile_array = ARRAY[0..15,0..15] of BYTE;
     treetype = (left,middle,right);

CONST frog: ARRAY[0..9,0..9] OF BYTE =
((00,00,00,00,61,61,00,00,00,00),(00,00,00,25,63,63,25,00,00,00),
(00,61,00,00,62,62,00,00,61,00),(00,00,61,61,63,68,61,61,00,00),
(00,00,00,62,67,64,62,00,00,00),(00,00,00,66,65,68,64,00,00,00),
(00,00,00,62,66,66,62,00,00,00),(00,00,61,61,63,69,61,61,00,00),
(00,61,00,61,62,62,61,00,61,00),(00,00,00,00,61,61,00,00,00,00));

car1: ARRAY[0..9,0..9] OF BYTE =
((00,00,00,00,00,00,00,00,00,00),(00,00,00,00,00,00,00,00,00,00),
(00,00,00,31,31,31,00,00,00,00),(00,00,31,31,31,31,31,00,00,00),
(31,31,31,31,31,31,31,31,31,00),(31,31,31,31,31,31,31,31,31,31),
(00,00,31,00,00,00,00,31,00,00),(00,00,00,00,00,00,00,00,00,00),
(00,00,00,00,00,00,00,00,00,00),(00,00,00,00,00,00,00,00,00,00));

car2: ARRAY[0..9,0..9] OF BYTE =
((00,00,00,00,00,00,00,00,00,00),(00,00,82,81,00,00,00,82,81,00),
(00,93,92,92,93,92,92,93,94,00),(96,91,90,91,95,89,80,80,93,94),
(94,92,91,90,95,90,90,79,80,94),(94,92,91,91,95,89,90,79,80,94),
(96,93,92,92,95,89,80,80,93,94),(00,93,93,92,93,92,92,93,94,00),
(00,00,82,81,00,00,00,82,81,00),(00,00,00,00,00,00,00,00,00,00));

car3: ARRAY[0..9,0..9] OF BYTE =
((00,00,00,00,00,00,00,00,00,00),(29,00,78,80,00,00,00,00,00,00),
(29,00,82,81,00,00,79,00,21,88),(29,00,86,83,85,88,86,00,21,88),
(29,83,85,29,87,87,85,84,21,88),(29,00,86,83,85,88,86,00,21,88),
(29,00,82,81,00,00,79,00,21,88),(29,00,78,80,00,00,00,00,00,00),
(00,00,00,00,00,00,00,00,00,00),(00,00,00,00,00,00,00,00,00,00));

car4: ARRAY[0..9,0..9] of BYTE =
((00,00,00,00,00,00,00,00,00,00),(00,101,100,00,00,00,00,00,00,00),
(00,80,78,100,00,80,78,00,80,78),(00,80,78,00,100,101,100,101,100,78),
(00,80,78,00,00,96,98,97,101,78),(00,80,78,00,101,97,96,99,100,78),
(00,80,78,00,00,96,98,97,101,78),(00,80,78,00,100,101,100,101,100,78),
(00,80,78,100,00,80,78,00,80,78),(00,101,100,00,00,00,00,00,00,00));

tree: ARRAY[treetype] of ARRAY[0..9,0..9] OF byte =
(((00,00,43,43,45,43,44,43,43,44),(00,44,45,45,45,47,46,47,48,45),
(00,45,46,44,47,45,48,48,46,47),(00,47,45,46,48,46,49,47,48,49),
(00,47,49,48,50,49,51,49,50,50),(00,49,49,47,50,49,51,49,50,50),
(00,45,45,46,48,46,49,47,48,49),(00,46,46,44,47,45,48,48,46,47),
(00,45,45,46,45,47,46,47,48,45),(00,00,43,43,45,43,44,43,43,44)),

((45,44,43,43,45,43,44,43,43,44),(46,47,46,45,45,47,46,47,48,45),
(46,48,46,48,47,45,48,48,46,47),(47,46,48,49,48,46,49,47,48,49),
(48,50,51,49,50,49,51,49,50,50),(47,49,50,51,49,51,50,50,49,51),
(47,46,48,49,48,46,49,47,48,49),(46,48,46,48,47,45,48,48,46,47),
(46,47,46,45,45,47,46,47,48,45),(45,44,43,43,45,43,44,43,43,44)),

((44,43,43,45,43,44,43,43,44,48),(46,45,45,47,46,47,48,45,55,52),
(45,47,45,48,48,46,47,54,54,55),(47,48,46,49,47,48,49,56,55,54),
(49,50,49,51,49,50,50,57,59,54),(51,50,49,51,49,50,50,57,59,53),
(47,48,46,49,47,48,49,56,55,54),(45,47,45,48,48,46,47,54,54,54),
(46,45,45,47,46,47,48,45,55,52),(44,42,43,43,42,41,41,42,42,48)));

turtle2: ARRAY[0..9,0..9] of BYTE =
((00,01,00,00,00,00,01,00,00,00),(00,00,01,01,01,01,00,00,00,00),
(00,01,01,03,04,04,03,01,00,00),(01,01,04,05,06,06,04,01,01,29),
(01,03,03,06,08,06,06,04,07,03),(01,03,04,07,06,08,04,01,07,03),
(01,01,04,05,05,05,03,01,01,29),(00,01,02,04,03,03,01,01,00,00),
(00,00,01,02,02,01,00,00,00,00),(00,01,00,00,00,00,01,00,00,00));

turtle: ARRAY[0..9,0..9] of BYTE =
((00,00,00,01,00,00,00,00,01,00),(00,00,00,00,01,01,01,01,00,00),
(00,00,01,01,03,04,04,03,01,00),(29,01,01,04,05,06,06,04,01,01),
(03,07,03,04,06,08,06,04,03,01),(03,07,01,04,06,08,07,04,03,01),
(29,01,01,03,05,05,05,04,01,01),(00,00,01,01,03,03,04,02,01,00),
(00,00,00,00,01,02,02,01,00,00),(00,00,00,01,00,00,00,00,01,00));


turtleDo1Le: ARRAY[0..9,0..9] of BYTE =
((00,00,00,00,00,00,00,00,00,00),(00,00,00,00,00,00,00,00,00,00),
(00,00,00,02,03,03,02,00,00,00),(21,00,02,05,06,05,04,01,00,00),
(00,00,03,06,07,05,04,03,01,00),(00,00,03,06,07,06,04,03,01,00),
(21,00,02,05,05,05,04,01,00,00),(00,00,00,02,03,03,02,00,00,00),
(00,00,00,00,00,00,00,00,00,00),(00,00,00,00,00,00,00,00,00,00));

turtleDo2Le: ARRAY[0..9,0..9] of BYTE =
((00,00,00,00,00,00,00,00,00,00),(00,00,00,00,00,00,00,00,00,00),
(00,00,00,00,00,00,00,00,00,00),(00,00,00,00,04,05,04,00,00,00),
(00,00,00,03,04,06,05,03,00,00),(00,00,00,03,04,06,04,03,00,00),
(00,00,00,00,04,04,03,00,00,00),(00,00,00,00,00,00,00,00,00,00),
(00,00,00,00,00,00,00,00,00,00),(00,00,00,00,00,00,00,00,00,00));

grass: ARRAY[0..15,0..15] OF BYTE =
((04,07,02,09,08,08,06,02,09,03,10,01,06,01,10,09),
(06,02,04,01,01,09,05,07,10,08,07,05,07,03,08,01),
(10,09,04,07,01,04,07,04,03,04,08,01,10,06,01,03),
(10,07,06,01,01,03,07,08,09,03,06,09,04,07,04,03),
(01,03,04,02,03,09,06,03,08,06,06,10,08,05,05,07),
(05,05,10,04,07,06,06,03,05,02,02,05,05,08,01,01),
(01,01,03,10,08,05,04,02,08,10,09,08,10,10,08,04),
(08,07,05,09,09,04,03,10,08,04,06,01,07,09,10,10),
(10,03,09,04,07,09,01,09,03,09,06,08,10,04,08,07),
(07,07,09,10,02,09,02,10,09,01,04,07,04,08,02,05),
(05,06,06,05,02,04,04,04,05,01,06,03,02,10,08,08),
(05,02,03,07,06,10,10,10,06,10,09,07,04,10,05,10),
(02,06,08,10,06,08,03,03,08,03,01,09,08,04,03,09),
(05,10,09,10,06,01,01,01,05,09,10,03,10,04,01,08),
(05,08,09,03,02,07,02,08,09,01,01,04,01,01,05,01),
(05,07,10,03,02,02,08,07,07,01,01,03,09,06,04,04));

Water: ARRAY[0..15,0..15] of byte =
((11,12,13,14,14,15,15,15,16,17,18,19,19,19,20,20),
(11,11,11,12,12,13,14,15,15,16,16,16,16,16,17,17),
(12,13,13,13,13,13,13,13,13,14,14,15,16,17,18,19),
(12,12,12,13,13,14,14,15,16,17,17,17,17,18,19,20),
(13,13,14,15,16,16,17,17,18,19,19,20,20,20,20,20),
(12,12,12,12,12,12,12,13,14,14,15,15,16,16,17,17),
(12,12,13,14,15,16,17,18,18,18,18,18,19,20,20,20),
(13,13,13,13,13,14,15,16,16,17,18,19,20,20,20,20),
(12,12,13,13,13,14,14,14,14,14,14,15,15,16,16,17),
(11,12,13,13,14,14,14,14,15,16,17,17,17,18,18,18),
(13,14,15,16,17,17,18,18,18,18,19,19,19,19,19,20),
(12,13,14,15,15,16,17,17,18,18,19,19,19,20,20,20),
(13,13,13,13,13,14,14,14,14,14,14,15,16,16,17,17),
(12,12,13,14,15,15,16,16,16,17,18,18,19,19,20,20),
(11,12,12,13,13,13,13,14,15,16,16,16,16,17,17,18),
(12,13,14,15,15,16,16,16,17,17,18,18,18,18,19,20));

Pall: Array[1..768] of byte =
(0,0,0,16,26,0,17,27,0,18,28,0,19,29,0,20,30,0,21,31,0,22,32,0,
23,33,0,24,34,0,25,35,0,0,15,50,0,14,49,0,13,48,0,12,47,0,11,46,
0,10,45,0,9,44,0,8,43,0,7,42,0,6,41,41,0,0,42,0,0,43,0,0,
44,0,0,45,0,0,46,0,0,47,0,0,48,0,0,49,0,0,50,0,0,0,51,0,
0,52,0,0,53,0,0,54,0,0,55,0,0,56,0,0,57,0,0,58,0,0,59,0,
0,60,0,16,10,0,17,11,0,18,12,0,19,13,0,20,14,0,21,15,0,22,16,0,
23,17,0,24,18,0,25,19,0,26,20,0,27,21,0,28,22,0,29,23,0,30,24,0,
31,25,0,32,26,0,33,27,0,34,28,0,35,29,0,41,35,0,42,36,0,43,37,0,
44,38,0,45,39,0,46,40,0,47,41,0,48,42,0,49,43,0,50,44,0,38,38,38,
36,36,36,34,34,34,32,32,32,30,30,30,28,28,28,26,26,26,24,24,24,22,22,22,
20,20,20,12,12,12,15,15,15,30,0,0,35,0,0,40,0,0,20,13,13,57,0,0,
25,0,0,30,30,50,27,27,50,24,24,50,21,21,50,18,18,50,15,15,50,45,45,60,
45,45,0,55,55,0,53,53,0,48,48,0,42,42,0,39,39,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

VAR f: FILE;
    tile: tile_array;
    i,count: byte;
BEGIN
     ASSIGN(f, 'frogger.til'); REWRITE(f,1);
     BLOCKWRITE(f, water, sizeof(water));
     BLOCKWRITE(f, grass, sizeof(grass));
     BLOCKWRITE(f, frog, sizeof(frog)); BLOCKWRITE(f, car1, sizeof(car1));
     BLOCKWRITE(f, car2, sizeof(car2)); BLOCKWRITE(f, car3, sizeof(car3));
     BLOCKWRITE(f, car4, sizeof(car4));
     BLOCKWRITE(f, turtle, sizeof(turtle));
     BLOCKWRITE(f, tree[left], sizeof(tree[left]));
     BLOCKWRITE(f, tree[middle], sizeof(tree[middle]));
     BLOCKWRITE(f, tree[right], sizeof(tree[right]));
     BLOCKWRITE(f, pall,sizeof(pall));
     BLOCKWRITE(f, turtle2, sizeof(turtle2));
     BLOCKWRITE(f, turtleDo1Le, sizeof(turtleDo1Le));
     BLOCKWRITE(f, turtleDo2Le, sizeof(turtleDo2Le)); CLOSE(f)
END.
