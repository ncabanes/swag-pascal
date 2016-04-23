(*


Hi..

This Unit is made all by myself, And There may be some problems with it, If
so please let me know..

All the routines that are present here come from one big unit that i have,
so there could be something missing( but as i said, just let me know))

there are some thing You have to keep in Mind when you are using these
routines, But i will go over them..

There are routines where the x coordinate isn't 640 but 80 (Like Text),
I've done this because I use 8x8 Text. (I now know that it isn't very hard
for me to change it so you can put a char on every x-coordinate, But i don't
feel much like it at the moment, Maybe in a couple of days))

Oh Yeah, None of my routines check if the coordinates are correct..

Andre Jakobs
  MicroBrain Technologies Inc.
    The Netherlands


Procedure Plot12h(x,y:word;Color:byte);
{x        (0-639)
 y        (0-479)
 Color    (0-15)
 Plots a pixel in [Color] at [x],[y]}
Procedure HLine12h(x,y,Length:word;Color:byte);
{x        (0-639)
 y        (0-479)
 Length   (0-639)(But can of course be larger, cause there is no checking)
 Color    (0-15)
 Draws a horizontal Line in [Color] at [x],[y]}
Procedure VLine12h(x,y,Length:word;Color:byte);
{x        (0-639)
 y        (0-479)
 Length   (0-479)
 Color    (0-15)
 Draws a vertical Line in [Color] at [x],[y]}
Procedure Block12h(x,y,Width,Height:word;Color:byte);
{x        (0-639)
 y        (0-479)
 Width    (0-639)
 Height   (0-479)
 Color    (0-15)
 Draws a Box in [Color] at [x],[y] wich is [Width] Wide and [Height] High}
Procedure Frame12h(x,y,Width,Height:word;Color:byte);
{x        (0-639)
 y        (0-479)
 Width    (0-639)
 Height   (0-479)
 Color    (0-15)
 Draws a Frame in [Color] at [x],[y] wich is [Width] Wide and [Height] High}
Procedure PutChar12h(x,y:word;color:byte;cha:char);
{x        (0-79)  !!!
 y        (0-479)
 Color    (0-15)
 cha      ('Character')
 Puts a character in [Color] at [x],[y]
  Doesn't erase background, So if there already is a character use block to
  erase it.
  example:
          Block(50 shl 3,100,8,8,1);
                ^^^^^^^^  (50 is the x coordinate that is used for the char
                           but because block uses 0-639 and not (0-79) you
                           have to multiply it by 8 (shl 3))
          PutChar(50,100,7,'A');}
Procedure PutString12h(x,y:word;Color:byte;Str:String);
{x        (0-79)  !!!
 y        (0-479)
 Color    (0-15)
 Str      ('String')
 Puts a String in [Color] at [x],[y]
  Doesn't erase background, So if there already is a String use block to
  erase it.
  example:
          Block(50 shl 3,100,Length(String) shl 8,8,1);
                ^^^^^^^^  (50 is the x coordinate that is used for the char
                           but because block uses 0-639 and not (0-79) you
                           have to multiply it by 8 (shl 3))
          PutString(50,100,7,'A');}
Procedure Window12h(x,y,Width,Height:word;Color0,Color1,Color2:byte);
{x        (0-79)  !!!
 y        (0-479)
 Width    (0-79)  !!!
 Height   (0-479)
 Color1   (0-15)    (Darkest Color)
 Color2   (0-15)    (Window Main Color)
 Color3   (0-15)    (Lightest Color)
 Draws a Window at [x],[y] wich is [Width] Wide and [Height] High
 example:
         Window12h(9,89,39,79,8,7,15)
 }
Procedure CloseWindow12h;
{closes Last opened Window, there is a max of 16 windows at the moment, But you
 can increase it if you want}
Procedure SaveScreen12h;
{Saves a complete Mode 12h Screen}
Procedure RestoreScreen12h;
{Restores Screen that is saved using SaveScreen12h}
 
Procedure Mode12h;{640x480x16, write mode 2}
{Sets Up mode 12h}
Procedure Button(x,y,W,H:Word;Color0,Color1,Color2:byte);
{x        (0-639)
 y        (0-479)
 Width    (0-639)
 Height   (0-479)
 Color1   (0-15)    (Darkest Color)
 Color2   (0-15)    (Window Main Color)
 Color3   (0-15)    (Lightest Color)
 Draws a Button at [x],[y] wich is [Width] Wide and [Height] High
 }

Procedure LoadFont;
{This Loads a 8x8 Font into an array '_8x8P' that is used to display the text
 You can optain this font by saving the 8x8 ROM font to a binary file and then
 load it into this array.. (you can use a font util to save the font to disk
 try some at (x2ftp.oulu.fi msdos/programming, and search for something that
 has the name 2l8 (Too Late) font editor v1.20)},
 Or you can load the _8x8Seg,_8x8Ofs with the Segment and Offset to the VGA 8x8
 ROM Font..
 
Hope You can use these routines, Cause I use them alot now (Don't use textmode
anymore, But this Mode)..
 
*)
UNIT VGA_12h;
 
INTERFACE
USES CRT,DOS;
Type
    PlotProc     =Procedure(x,y:word;Color:byte);
    HLineProc    =Procedure(x,y,Length:word;Color:byte);
    VLineProc    =Procedure(x,y,Length:word;Color:byte);
    BlockProc    =Procedure(x,y,Width,Height:word;Color:byte);
    FrameProc    =Procedure(x,y,Width,Height:word;Color:byte);
    PutCharProc  =Procedure(x,y:word;color:byte;cha:char);
    PutStringProc=Procedure(x,y:word;Color:byte;Str:String);
 
var
   Result       : word;
 
{Procedures}
   ClrScr       : Procedure;            {Clear Screen}
   Plot         : PlotProc;             {Plot(x,y,Color)}
   HLine        : HLineProc;            {HorizontalLine(x,y,Length,Color)}
   VLine        : VLineProc;            {VerticalLine(x,y,Length,Color)}
   Block        : BlockProc;            {Block(x,y,Width,Height,Color)}
   Frame        : FrameProc;
   PutChar      : PutCharProc;          {PutCharacter(x,y,Color,Char)}
   PutString    : PutStringProc;        {PutString(x,y,Color,String)}
   SaveScreen   : Procedure;            {SaveScreen}
   RestoreScreen: Procedure;            {RestoreScreen}
 
{Mode 12h Routines}
Procedure Plot12h(x,y:word;Color:byte);
Procedure HLine12h(x,y,Length:word;Color:byte);
Procedure VLine12h(x,y,Length:word;Color:byte);
Procedure Block12h(x,y,Width,Height:word;Color:byte);
Procedure Frame12h(x,y,Width,Height:word;Color:byte);
Procedure PutChar12h(x,y:word;color:byte;cha:char);
Procedure PutString12h(x,y:word;Color:byte;Str:String);
Procedure Window12h(x,y,Width,Height:word;Color0,Color1,Color2:byte);
Procedure CloseWindow12h;
Procedure SaveScreen12h;
Procedure RestoreScreen12h;
 
Procedure Mode12h;{640x480x16, write mode 2}
Procedure Button(x,y,W,H:Word;Color0,Color1,Color2:byte);
 
IMPLEMENTATION
 
Type
    Window12hType = record
                      Width : byte;
                      Height: word;
                      VidOfs: word;
                      Plane0: pointer;
                      Plane1: pointer;
                      Plane2: pointer;
                      Plane3: pointer;
                     end;
Var
   WindowList12h     : Array [1..16] of ^Window12hType;
   LastWindow12h     : byte;
   ScreenGrab        : Array [0..3] of pointer;
   _8x8Seg,_8x8Ofs   : word;
   _8x8P             : Array [0..2048] of byte;
 
{*****************************************************************
                    GRAPHICS & TEXT ROUTINES
 *****************************************************************}
Procedure LoadFont;
var
   F    : file;
begin
  assign(F,'8x8');
  reset(F,1);
  blockread(f,_8x8P[0],2048);
  close(F);
  _8x8Seg:=Seg(_8x8P[0]);
  _8x8Ofs:=Ofs(_8x8P[0]);
 end;
 
Procedure Mode12h;{Assembler;{640x480x16}
begin
  @Plot:=@Plot12h;
  @VLine:=@VLine12h;
  @HLine:=@HLine12h;
  @Block:=@Block12h;
  @Frame:=@Frame12h;
  @PutChar:=@PutChar12h;
  @PutString:=@PutString12h;
  @SaveScreen:=@SaveScreen12h;
  @RestoreScreen:=@RestoreScreen12h;
  Asm
    Mov     AH,00
    Mov     AL,12h
    Int     10h
    mov     dx,03ceh    {Graphics Controller}
    mov     ax,0205h    {Mode Register, Write Mode 2}
    out     dx,ax
   end;
end;
 
Procedure Button(x,y,W,H:Word;Color0,Color1,Color2:byte);
begin
  Block(x,y,W,H,Color1);
  HLine(x+1,y,W-2,Color2);
  VLine(x,y+1,H-2,Color2);
  HLine(x+1,y+H-1,W-1,Color0);
  VLine(x+W-1,y+1,H-1,Color0);
 end;
 
Procedure ClrScr12h;assembler;
asm
  mov   es,SegA000
  mov   di,00h
  mov   ax,00h
  mov   cx,19200
  rep   stosw
 end;

Procedure Plot12h(x,y:word;Color:byte); assembler;
asm
  mov   ax,SegA000      {Calculate Offset}
  mov   es,ax
  mov   bx,[y]
  mov   di,bx
  shl   di,6            {80*y}
  shl   bx,4
  add   di,bx
 
  mov   cx,[x]
  mov   bx,cx
  shr   bx,3            {/8}
  add   di,bx           {80*y+ (x/8)}
 
  and   cx,7            {Get Bit that Changes}
  mov   ah,128
  shr   ah,cl
  mov   dx,03ceh
  mov   al,8
  out   dx,ax
  mov   dl,[es:di]
  mov   al,[Color]
  mov   [es:di],al
end;
 
Procedure HLine12h(x,y,Length:word;Color:byte);Assembler;
asm
  mov   bx,[x]
  mov   si,[Length]
  or    si,si           {Check if Length=0}
  jz    @D_End           {If So then jump to End}
  mov   dx,03ceh        {Graphics Controller}
 
  mov   ax,SegA000      {Calculate Offset}
  mov   es,ax
  mov   ax,[y]
  mov   di,ax
  shl   di,6            {80*y}
  shl   ax,4
  add   di,ax
 
  mov   ax,bx
  shr   ax,3            {/8}
  add   di,ax           {80*y+ (x/8)}
 
{di = Offset in VMem}
{Si = Length}
{bx = x}
{dx = Graphix Controller}
 
{ax = empty}
{cx = empty}
 
  mov   cx,bx           {Get StartBit}
  and   cx,07h
 
  mov   ax,si
  add   ax,cx
  cmp   ax,8            {Is x+Length<One Byte}
  jb    @D_One
 
  mov   ah,0ffh         {11111111b}
  shr   ah,cl           {BitMask}
  mov   al,8            {BitMask Register}
  out   dx,ax           {Write BitMask}
  mov   al,[es:di]
  mov   al,[Color]
  mov   [es:di],al
  inc   di
 
  mov   al,8            {BitMask Register}
  mov   ah,0ffh         {BitMask}
  out   dx,ax           {Write BitMask}
 
  mov   ax,si
  mov   ch,8
  sub   ch,cl
  mov   cl,ch
  xor   ch,ch
  sub   ax,cx
  shr   ax,3            {Length div 8}
  mov   cx,ax
  mov   al,[Color]
  rep   stosb
 
  mov   cx,bx           {cx:=x+Length}
  add   cx,si
  and   cx,07h          {cx and 07}
  mov   ah,0ffh
  shr   ah,cl           {BitMask}
  cmp   ah,0
  je    @D_End
 
  not   ah
  mov   al,8            {BitMask Register}
  out   dx,ax           {Write BitMask}
  mov   cl,[es:di]
  mov   al,[Color]
  mov   [es:di],al
  jmp   @D_End
 
@D_One:
  mov   ah,0ffh
  shr   ah,cl           {Left BitMask}
 
  add   bx,si
  dec   bx
  and   bx,07h
 
  mov   cx,7
  sub   cx,bx
 
  mov   bl,0ffh
  shl   bl,cl          {Right BitMask}
 
  and   ah,bl          {Full  BitMask}
  mov   al,8           {BitMask Register}
  out   dx,ax          {Write BitMask}

  mov   dl,[es:di]     {Fill Latches}
  mov   al,[Color]
  mov   [es:di],al     {Write Pixel}
@D_End:
 end;
 
Procedure VLine12h(x,y,Length:word;Color:byte);Assembler;
asm
  mov   ax,SegA000      {Calculate Offset}
  mov   es,ax
  mov   bx,[y]
  mov   di,bx
  shl   di,6            {80*y}
  shl   bx,4
  add   di,bx
 
  mov   cx,[x]
  mov   bx,cx
  shr   bx,3            {/8}
  add   di,bx           {80*y+ (x/8)}
 
  and   cx,7            {Get Bit that Changes}
  mov   ah,80h
  shr   ah,cl           {BitMask Value}
  mov   dx,03ceh        {Graphics Controller}
  mov   al,8            {BitMask Register}
  out   dx,ax           {BitMask Setup}
  mov   bx,[Length]
  mov   al,[Color]
@D_L:
  mov   dl,[es:di]
  mov   [es:di],al      {Put Byte at Offset}
  add   di,80
  dec   bx
  jnz   @D_L
 end;
 
Procedure Block12h(x,y,Width,Height:word;Color:byte);Assembler;
asm
  mov   bx,[x]
  mov   si,[Width]
  or    si,si           {Check if Length=0}
  jz    @D_End           {If So then jump to End}
 
  mov   ax,SegA000      {Calculate Offset}
  mov   es,ax
  mov   ax,[y]
  mov   di,ax
  shl   di,6            {80*y}
  shl   ax,4
  add   di,ax
 
  mov   ax,bx
  shr   ax,3            {/8}
  add   di,ax           {80*y+ (x/8)}
 
{di = Offset in VMem}
{Si = Length}
{bx = x}
{dx = Graphix Controller}
 
{ax = empty}
{cx = empty}
 
  mov   cx,bx           {Get StartBit}
  and   cx,07h
 
  mov   ax,si
  add   ax,cx
  cmp   ax,8            {Is x+Length<One Byte}
  jb    @D_One

  mov   ah,0ffh         {11111111b}
  shr   ah,cl           {BitMask}
  mov   al,8            {BitMask Register}
  mov   dx,03ceh        {Graphics Controller}
  out   dx,ax           {Write BitMask}
  push  cx
  mov   ah,[Color]
  mov   cx,[Height]
  mov   dx,di
@D_LL:                   {Draw Left of Box}
  mov   al,[es:di]
  mov   [es:di],ah
  add   di,80           {di:=di+80}
  dec   cx
  jnz   @D_LL
  mov   di,dx
  inc   di
  pop   cx
 
  mov   al,8            {BitMask Register}
  mov   ah,0ffh         {BitMask}
  mov   dx,03ceh        {Graphics Controller}
  out   dx,ax           {Write BitMask}

  mov   ax,si
  mov   ch,8
  sub   ch,cl
  mov   cl,ch
  xor   ch,ch
  sub   ax,cx
  shr   ax,3            {Length div 8}
 
  push  di
  push  bx
  mov   bx,[Height]
  mov   dx,ax
  mov   al,[Color]
@D_LC:
  mov   cx,dx
  rep   stosb
  add   di,80
  sub   di,dx
  dec   bx
  jnz   @D_LC
  pop   bx
  pop   di
  add   di,dx

  mov   cx,bx           {cx:=x+Length}
  add   cx,si
  and   cx,07h          {cx and 07}
  mov   ah,0ffh
  shr   ah,cl           {BitMask}
  cmp   ah,0
  je    @D_End
 
  not   ah
  mov   al,8            {BitMask Register}
  mov   dx,03ceh        {Graphics Controller}
  out   dx,ax           {Write BitMask}
  mov   cx,[Height]
  mov   al,[Color]
@D_LR:
  mov   ah,[es:di]
  mov   [es:di],al
  add   di,80
  dec   cx
  jnz   @D_LR
 
  jmp   @D_End
 
@D_One:
  mov   ah,0ffh
  shr   ah,cl           {Left BitMask}
 
  add   bx,si
  dec   bx
  and   bx,07h
 
  mov   cx,7
  sub   cx,bx
 
  mov   bl,0ffh
  shl   bl,cl          {Right BitMask}
 
  and   ah,bl          {Full  BitMask}
  mov   al,8           {BitMask Register}
  mov   dx,03ceh        {Graphics Controller}
  out   dx,ax          {Write BitMask}
  mov   cx,[Height]
  mov   al,[Color]
@D_L:
  mov   dl,[es:di]     {Fill Latches}
  mov   [es:di],al     {Write Pixel}
  add   di,80
  dec   cx
  jnz   @D_L
@D_End:
 end;
 
Procedure Frame12h(x,y,Width,Height:word;Color:byte);
begin
  HLine(x,y,Width,Color);
  VLine(x,y,Height,Color);
  VLine(x+Width-1,y,Height,Color);
  HLine(x,y+Height-1,Width,Color);
 end;

Procedure PutChar12h(x,y:word;Color:byte;cha:char);Assembler;
asm
  push  ds
  xor   bx,bx
  mov   bl,[cha]
  shl   bx,3
  mov   ax,_8x8Seg
  mov   ds,ax
  mov   si,_8x8Ofs
  add   si,bx
 
  mov   ax,SegA000      {Calculate Offset}
  mov   es,ax
  mov   di,[y]
  mov   ax,di
  shl   ax,6
  shl   di,4
  add   di,ax
  add   di,[x]
  mov   cx,8
  mov   dx,03ceh
  mov   al,8
  mov   bl,[Color]
@D_L:
  mov   ah,[ds:si]
  out   dx,ax
  mov   ah,[es:di]
  mov   [es:di],bl
  inc   si
  add   di,80
  dec   cx
  jnz   @D_L
  pop   ds
end;
 
Procedure PutString12h(x,y:word;Color:byte;Str:String);
var
   f1   : byte;
   Cha  : char;
begin
for f1:=1 to ord(Str[0]) do
 begin
   cha:=Str[f1];
   asm
     push  ds
     mov   ax,_8x8Seg
     mov   ds,ax
     mov   si,_8x8Ofs
     xor   ax,ax
     mov   al,cha
     shl   ax,3
     add   si,ax
 
     mov   ax,SegA000      {Calculate Offset}
     mov   es,ax
     mov   di,[y]
     mov   ax,di
     shl   ax,6
     shl   di,4
     add   di,ax
     add   di,[x]
     mov   cx,8
     mov   dx,03ceh
     mov   al,8
     mov   bl,[Color]
@D_L:
     mov   ah,[ds:si]
     out   dx,ax
     mov   ah,[es:di]
     mov   [es:di],bl
     inc   si
     add   di,80
     dec   cx
     jnz   @D_L
     pop   ds
    end;
    inc(x);
  end;{For}
end;
 
Procedure Window12h(x,y,Width,Height:word;Color0,Color1,Color2:byte);
var
   VidOfs       : word;
   ImOfs,ImSeg  : word;
   ScrW         : word;
   O0,S0,O1,S1  : word;
   O2,S2,O3,S3  : word;
begin
  if LastWindow12h<16 then
    begin
      inc(LastWindow12h);
      new(WindowList12h[LastWindow12h]);
      VidOfs:=(y shl 6)+(y shl 4)+x;
      WindowList12h[LastWindow12h]^.VidOfs:=VidOfs;
      WindowList12h[LastWindow12h]^.Width :=Width;
      WindowList12h[LastWindow12h]^.Height:=Height;
      ScrW:=Width*Height;
      GetMem(WindowList12h[LastWindow12h]^.Plane0,ScrW);
      GetMem(WindowList12h[LastWindow12h]^.Plane1,ScrW);
      GetMem(WindowList12h[LastWindow12h]^.Plane2,ScrW);
      GetMem(WindowList12h[LastWindow12h]^.Plane3,ScrW);
      S0:=Seg(WindowList12h[LastWindow12h]^.Plane0^);
      O0:=Ofs(WindowList12h[LastWindow12h]^.Plane0^);
      S1:=Seg(WindowList12h[LastWindow12h]^.Plane1^);
      O1:=Ofs(WindowList12h[LastWindow12h]^.Plane1^);
      S2:=Seg(WindowList12h[LastWindow12h]^.Plane2^);
      O2:=Ofs(WindowList12h[LastWindow12h]^.Plane2^);
      S3:=Seg(WindowList12h[LastWindow12h]^.Plane3^);
      O3:=Ofs(WindowList12h[LastWindow12h]^.Plane3^);
      ScrW:=80-Width;
      asm
        push  ds
 
        mov   bx,[Width]
        mov   cx,[Height]
 
        mov   si,[VidOfs]
        mov   ds,SegA000                 {ds:si VideoMem}
        mov   dx,03ceh                   {Graphics Controller}
        mov   ax,0005h                   {Mode Register, Write 0, Read  0}
        out   dx,ax
 
 
        mov   di,[O3]                    {Read Plane 3}
        mov   es,[S3]                    {es:di ImageOfset}
        mov   ax,0304h                   {Read Plane Select}
        out   dx,ax
        push  si                         {Save 'Start Window in VideoMem'}
        push  cx
        mov   ax,cx                      {cx=Height}
    @B3:
        mov   cx,bx                      {bx=Width}
        rep   movsb                      {Read 8 Pixels}
        add   si,[ScrW]                  {Goto Next Line by adding ScrWidth}
        dec   ax
        jnz   @B3
        pop   cx
        pop   si                         {Restore 'Start Window in VideoMem'}
 
        mov   di,[O2]                    {Read Plane 2}
        mov   es,[S2]                    {es:di ImageOfset}
        mov   ax,0204h                   {Read Plane Select}
        out   dx,ax
        push  si                         {Save 'Start Window in VideoMem'}
        push  cx
        mov   ax,cx                      {cx=Height}
    @B2:
        mov   cx,bx                      {bx=Width}
        rep   movsb                      {Read 8 Pixels}
        add   si,[ScrW]                  {Goto Next Line by adding ScrWidth}
        dec   ax
        jnz   @B2
        pop   cx
        pop   si                         {Restore 'Start Window in VideoMem'}
 

        mov   di,[O1]                    {Read Plane 1}
        mov   es,[S1]                    {es:di ImageOfset}
        mov   ax,0104h                   {Read Plane Select}
        out   dx,ax
        push  si                         {Save 'Start Window in VideoMem'}
        push  cx
        mov   ax,cx                      {cx=Height}
    @B1:
        mov   cx,bx                      {bx=Width}
        rep   movsb                      {Read 8 Pixels}
        add   si,[ScrW]                  {Goto Next Line by adding ScrWidth}
        dec   ax
        jnz   @B1
        pop   cx
        pop   si                         {Restore 'Start Window in VideoMem'}
 
 
        mov   di,[O0]                    {Read Plane 0}
        mov   es,[S0]                    {es:di ImageOfset}
        mov   ax,0004h                   {Read Plane Select}
        out   dx,ax
        mov   ax,cx                      {cx=Height}
    @B0:
        mov   cx,bx                      {bx=Width}
        rep   movsb                      {Read 8 Pixels}
        add   si,[ScrW]                  {Goto Next Line by adding ScrWidth}
        dec   ax
        jnz   @B0
 
        mov   ax,0205h                   {Mode Register, Write Mode 2}
        out   dx,ax
        pop   ds
       end;
     Width:=Width shl 3;
     x:=x shl 3;
     Block(x,y,Width,Height,Color1);
     HLine(x+1,y,Width-2,Color2);
     VLine(x,y+1,Height-2,Color2);
     HLine(x+1,y+Height-1,Width-1,Color0);
     VLine(x+width-1,y+1,Height-1,Color0);
    end;
end;
 
Procedure CloseWindow12h;
var
  Width,Height  : word;
  SegWin,OfsWin : word;
  OfsVid        : word;
  ScrW          : word;
  O0,S0,O1,S1   : word;
  O2,S2,O3,S3   : word;
begin
  if LastWindow12h>0 then
   begin
     Width:=WindowList12h[LastWindow12h]^.Width;
     Height:=WindowList12h[LastWindow12h]^.Height;
     OfsVid:=WindowList12h[LastWindow12h]^.VidOfs;
 
     S0:=Seg(WindowList12h[LastWindow12h]^.Plane0^);
     O0:=Ofs(WindowList12h[LastWindow12h]^.Plane0^);
     S1:=Seg(WindowList12h[LastWindow12h]^.Plane1^);
     O1:=Ofs(WindowList12h[LastWindow12h]^.Plane1^);
     S2:=Seg(WindowList12h[LastWindow12h]^.Plane2^);
     O2:=Ofs(WindowList12h[LastWindow12h]^.Plane2^);
     S3:=Seg(WindowList12h[LastWindow12h]^.Plane3^);
     O3:=Ofs(WindowList12h[LastWindow12h]^.Plane3^);
     ScrW:=80-Width;
     Asm
       push ds
      {GET OFFSET IN VIDEOMEM/MOUSEBACKUP}
 
       mov  bx,[Width]
       mov  cx,[Height]
       mov  es,SegA000
       mov  di,[OfsVid]                {es:di Start in VideoMem}
       mov  dx,03ceh                   {Graphics Controller}
       mov  ax,0805h                   {Mode Register, Write Mode 0, Read Mode 
1}
       out  dx,ax
       mov  ax,0007h                   {color don't care Register}
       out  dx,ax
       mov  ax,0ff08h                  {BitMask Register}
       out  dx,ax
       mov  dx,03c4h                   {Sequencer Controller}
 
       cli
       mov  si,[O3]
       mov  ds,[S3]                    {ds:si Start in Memory}
       mov  ax,0802h                   {Write Plane Select,Plane 3}
       out  dx,ax                      {Write Read Plane Select}
       push di                         {Save 'Start Window in VideoMem'}
       mov  ax,[Height]                {Height}
   @R3:
       mov  cx,bx                      {bx=Width}
       rep  movsb                      {Draw 8 Pixels}
       add  di,[ScrW]                  {Goto Next Line by adding ScrWidth}
       dec  ax
       jnz  @R3
       pop  di                         {Restore 'Start Window in VideoMem'}
 
 
       mov  si,[O2]
       mov  ds,[S2]                    {ds:si Start in Memory}
       mov  ax,0402h                   {Write Plane Select,Plane 2}
       out  dx,ax                      {Write Read Plane Select}
       push di                         {Save 'Start Window in VideoMem'}
       mov  ax,[Height]                {Height}
   @R2:
       mov  cx,bx                      {bx=Width}
       rep  movsb                      {Draw 8 Pixels}
       add  di,[ScrW]                  {Goto Next Line by adding ScrWidth}
       dec  ax
       jnz  @R2
       pop  di                         {Restore 'Start Window in VideoMem'}
 
       mov  si,[O1]
       mov  ds,[S1]                    {ds:si Start in Memory}
       mov  ax,0202h                   {Write Plane Select,Plane 1}
       out  dx,ax                      {Write Read Plane Select}
       push di                         {Save 'Start Window in VideoMem'}
       mov  ax,[Height]                {Height}
   @R1:
       mov  cx,bx                      {bx=Width}
       rep  movsb                      {Draw 8 Pixels}
       add  di,[ScrW]                  {Goto Next Line by adding ScrWidth}
       dec  ax
       jnz  @R1
       pop  di                         {Restore 'Start Window in VideoMem'}
 
       mov  si,[O0]
       mov  ds,[S0]                    {ds:si Start in Memory}
       mov  ax,0102h                   {Write Plane Select,Plane 2}
       out  dx,ax                      {Write Read Plane Select}
       mov  ax,[Height]                {Height}
   @R0:
       mov  cx,bx                      {bx=Width}
       rep  movsb                      {Draw 8 Pixels}
       add  di,[ScrW]                  {Goto Next Line by adding ScrWidth}
       dec  ax
       jnz  @R0
 
       mov  ax,0f02h                   {Set All Planes to write}
       out  dx,ax

       mov  dx,03ceh                   {Graphics Controller}
       mov  ax,0205h                   {Mode Register, Write Mode 2}
       out  dx,ax
       sti
       pop  ds
      end;
     ScrW:=Width*Height;
     FreeMem(WindowList12h[LastWindow12h]^.Plane0,ScrW);
     FreeMem(WindowList12h[LastWindow12h]^.Plane1,ScrW);
     FreeMem(WindowList12h[LastWindow12h]^.Plane2,ScrW);
     FreeMem(WindowList12h[LastWindow12h]^.Plane3,ScrW);
     Dispose(WindowList12h[LastWindow12h]);
     dec(LastWindow12h);
    end;
end;
 
Procedure SaveScreen12h;
var
   O0,S0,O1,S1  : word;
   O2,S2,O3,S3  : word;
begin
  GetMem(ScreenGrab[0],38592);{80*480+64*3(Palet)}
  GetMem(ScreenGrab[1],38400);{80*480}
  GetMem(ScreenGrab[2],38400);{80*480}
  GetMem(ScreenGrab[3],38400);{80*480}
 
  S0:=Seg(ScreenGrab[0]^);
  O0:=Ofs(ScreenGrab[0]^);
 
  S1:=Seg(ScreenGrab[1]^);
  O1:=Ofs(ScreenGrab[1]^);
 
  S2:=Seg(ScreenGrab[2]^);
  O2:=Ofs(ScreenGrab[2]^);
 
  S3:=Seg(ScreenGrab[3]^);
  O3:=Ofs(ScreenGrab[3]^);
  asm
    push ds
 
    mov  di,[O3]
    mov  es,[S3]
   {es:di          ImageOfset}
    mov  ds,SegA000
    xor  si,si
   {ds:si          VideoMem}
    mov  dx,03ceh                   {Graphics Controller}
    mov  ax,0005h                   {Mode Register, Write 0, Read  0}
    out  dx,ax
    mov  ax,0304h                   {Read Plane Select}{Plane 3}
    out  dx,ax
    mov  cx,19200
    rep  movsw
 
    mov  es,[S2]
    mov  di,[O2]
    xor  si,si
    dec  ah                         {Plane 2}
    out  dx,ax
    mov  cx,19200
    rep  movsw
 
    mov  es,[S1]
    mov  di,[O1]
    xor  si,si
    dec  ah                         {Plane 1}
    out  dx,ax
    mov  cx,19200
    rep  movsw
 
    mov  es,[S0]
    mov  di,[O0]
    xor  si,si
    dec  ah                         {Plane 0}
    out  dx,ax
    mov  cx,19200
    rep  movsw
 
    mov  dx,03ceh                   {Graphics Controller}
    mov  ax,0205h                   {Mode Register, Write Mode 2}
    out  dx,ax
 
    mov  dx,03c7h                   {Save Palette behind Plane 0}
    mov  al,0
    out  dx,al
    mov  dx,03c9h
    mov  cx,192                     {64 Colors RxGxB starting}
    rep  insb
    pop  ds
   end;
 end;
 
Procedure RestoreScreen12h;
var
   O0,S0,O1,S1  : word;
   O2,S2,O3,S3  : word;
Label
     C1,C2,rt1,rt2;
begin
  S0:=Seg(ScreenGrab[0]^);
  O0:=Ofs(ScreenGrab[0]^);
 
  S1:=Seg(ScreenGrab[1]^);
  O1:=Ofs(ScreenGrab[1]^);
 
  S2:=Seg(ScreenGrab[2]^);
  O2:=Ofs(ScreenGrab[2]^);

  S3:=Seg(ScreenGrab[3]^);
  O3:=Ofs(ScreenGrab[3]^);
  Asm
    push ds
 
    mov   dx,03c8h
    mov   al,0
    out   dx,al
    inc   dx
    mov   cx,192
  C1:
    out   dx,al
    dec   cx
    jnz   C1
 
    mov  dx,03ceh                   {Graphics Controller}
    mov  ax,0805h                   {Mode Register, Write Mode 0, Read Mode 1}
    out  dx,ax
    mov  ax,0007h                   {color don't care Register}
    out  dx,ax
    mov  ax,0ff08h                  {BitMask Register}
    out  dx,ax
    mov  dx,03c4h                   {Sequencer Controller}
   {GET OFFSET IN VIDEOMEM}
    mov  es,SegA000
    xor  di,di
   {es:di                Start in VideoMem}
    mov  si,[O3]
    mov  ds,[S3]
   {ds:si                Start in Memory}
    mov  ax,0802h                     {Write Plane Select}
    out  dx,ax
    cli
    mov  cx,19200
    rep  movsw

    xor  di,di
   {es:di                Start in VideoMem}
    mov  si,[O2]
    mov  ds,[S2]
   {ds:si                Start in Memory}
    mov  ax,0402h                     {Write Plane Select}
    out  dx,ax
    mov  cx,19200
    rep  movsw
 
    xor  di,di
   {es:di                Start in VideoMem}
    mov  si,[O1]
    mov  ds,[S1]
   {ds:si                Start in Memory}
    mov  ax,0202h                     {Write Plane Select}
    out  dx,ax
    mov  cx,19200
    rep  movsw
 
    xor  di,di
   {es:di                Start in VideoMem}
    mov  si,[O0]
    mov  ds,[S0]
   {ds:si                Start in Memory}
    mov  ax,0102h                     {Write Plane Select}
    out  dx,ax
    mov  cx,19200
    rep  movsw
    sti
    mov  ax,0f02h                  {Set All Planes to write}
    out  dx,ax
 
    mov  dx,03ceh                  {Graphics Controller}
    mov  ax,0205h                  {Mode Register, Write Mode 2}
    out  dx,ax
 
    mov   dx,03c8h
    mov   al,0
    out   dx,al
    inc   dx
    mov   cx,192
    rep   outsb
    pop  ds
   end;
  FreeMem(ScreenGrab[3],38400);{80*480}
  FreeMem(ScreenGrab[2],38400);{80*480}
  FreeMem(ScreenGrab[1],38400);{80*480}
  FreeMem(ScreenGrab[0],38592);{80*480+64*3}
 end;
 
begin
  LastWindow12h:=0;
  LoadFont;
 end.
