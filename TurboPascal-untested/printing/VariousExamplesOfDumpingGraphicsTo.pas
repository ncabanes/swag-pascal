(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0053.PAS
  Description: Various Examples of Dumping Graphics to
  Author: RON NOSSAMAN
  Date: 08-30-96  09:36
*)


{ there are six examples included here.  Cut each one out to try them all }

{   EXAMPLE #1 }
{ ----------------------------   CUT  ------------------------- }

{print dump for John Bridges' 360x480x256 mode}
uses printer,crt;
var x,y:integer;

{$F+}
procedure set360x480;
{courtesy of John Bridges}
begin
   asm
      push si
      push di
      mov ax,12h     {clear video memory with bios}
      int 10h        {and set 640x480x16 mode}
      mov ax,13h     {set 320x200x256 mode with bios}
      int 10h
      mov dx,3c4h    {alter sequencer registers}
      mov ax,0604h   {disable chain 4}
      out dx,ax
      mov ax,0100h   {syncronus reset}
      out dx,ax
      mov dx,3c2h
      mov al,0e7h
      out dx,al
      mov dx,3c4h
      mov ax,0300h
      out dx,ax
      mov dx,3d4h
      mov al,11h
      out dx,al
      inc dx
      in al,dx
      and al,7fh
      out dx,al
      dec dx
      mov ax,06b00h  {horiz total}
      out dx,ax
      mov ax,05901h  {horiz displayed}
      out dx,ax
      mov ax,05a02h  {start horiz blanking}
      out dx,ax
      mov ax,08e03h  {end horiz blanking}
      out dx,ax
      mov ax, 05e04h  {start h sync}
      out dx,ax
      mov ax, 08a05h  {end h sync}
      out dx,ax
      mov ax, 00d06h  {vertical total}
      out dx,ax
      mov ax, 03e07h  {overflow}
      out dx,ax
      mov ax, 04009h  {cell height}
      out dx,ax
      mov ax, 0ea10h  {v sync start}
      out dx,ax
      mov ax, 0ac11h  {v sync end and protect cr0-cr7}
      out dx,ax
      mov ax, 0df12h  {vertical displayed}
      out dx,ax
      mov ax, 02d13h  {offset}
      out dx,ax
      mov ax, 00014h  {turn off dword mode}
      out dx,ax
      mov ax, 0e715h  {v blank start}
      out dx,ax
      mov ax, 00616h  {v blank end}
      out dx,ax
      mov ax, 0e317h  {turn on byte mode}
      out dx,ax
     pop di
     pop si
   end;
end;

procedure dot360x480(drawx,drawy,color:word);
begin
   asm
       mov ax,0a000h                {VGA_SEGMENT}
       mov es,ax
       mov ax,90                    {SCREEN_WIDTH/4}
       mul DrawY
       mov di,DrawX
       shr di,1
       shr di,1
       add di,ax
       mov cl,byte ptr DrawX
       and cl,3
       mov ah,1
       shl ah,cl
       mov al,2                    {MAP_MASK}
       mov dx,03c4h                {SC_INDEX}
       out dx,ax
       mov al,byte ptr Color
       stosb                       {draw pixel}
    end;
end;

Function Read360x480(Readx,Ready:word):word;
{Read360x480 PROC FAR ReadX:WORD, ReadY:WORD RETURNS result:WORD}
begin
   asm
       mov ax,0a000h                {VGA_SEGMENT}
       mov es,ax
       mov ax,90                    {SCREEN_WIDTH/4}
       mul ReadY
       mov si,ReadX
       shr si,1
       shr si,1
       add si,ax
       mov ah,byte ptr ReadX
       and ah,3
       mov al,4                    {READ_MAP}
       mov dx,3ceh                 {GC_INDEX}
       out dx,ax
       SEGES mov al,[si]
       sub ah,ah
       mov @result,ax
   end;
end;

{$F-}


procedure putpixel(x,y,hue:integer);
{with brute force (dip stick) clipping}
begin
   if x<0 then exit;
   if y<0 then exit;
   if x>359 then exit;
   if y>479 then exit;
   dot360x480(x,y,hue);
end;

procedure Ellipse(X,Y,YRad,XRad: integer; Color: byte); {borrowed for demo}
var
 EX,EY: integer;
 YRadSqr,YRadSqr2,XRadSqr,XRadSqr2,D,DX,DY: longint;
begin
 EX:=0;
 EY:=XRad;
 YRadSqr:=longint(YRad)*YRad;
 YRadSqr2:=2*YRadSqr;
 XRadSqr:=longInt(XRad)*XRad;
 XRadSqr2:=2*XRadSqr;
 D:=XRadSqr-YRadSqr*XRad+YRadSqr div 4;
 DX:=0;
 DY:=YRadSqr2*XRad;
 PutPixel(Y-EY,X,Color);
 PutPixel(Y+EY,X,Color);
 PutPixel(Y,X-YRad,Color);
 PutPixel(Y,X+YRad,Color);
 while (DX<DY) do begin
  if (D>0) then begin
   Dec(EY);
   Dec(DY,YRadSqr2);
   Dec(D,DY);
  end;
  Inc(EX);
  Inc(DX,XRadSqr2);
  Inc(D,XRadSqr+DX);
  PutPixel(Y+EY,X+EX,Color);
  PutPixel(Y+EY,X-EX,Color);
  PutPixel(Y-EY,X+EX,Color);
  PutPixel(Y-EY,X-EX,Color);
 end;
 Inc(D,(3*(YRadSqr-XRadSqr) div 2-(DX+DY)) div 2);
 while (EY>0) do begin
  if(D<0) then begin
   Inc(EX);
   Inc(DX,XRadSqr2);
   Inc(D,XRadSqr+DX);
  end;
  Dec(EY);
  Dec(DY,YRadSqr2);
  Inc(D,YRadSqr-DY);
  PutPixel(Y+EY,X+EX,Color);
  PutPixel(Y+EY,X-EX,Color);
  PutPixel(Y-EY,X+EX,Color);
  PutPixel(Y-EY,X-EX,Color);
 end;
end;


Procedure Xlaser360x480x256;
{Ron Nossaman May 1996   nossaman@southwind.net}
{ Each screen pixel in 360X480 graphics mode translates to an 8X5 printer
   pixel at 300 dpi. This routine maps X,Y screen coordinates into the
   halftone pel, determines the gray density level according to the
   rgb values of each palette entry, and sends the results to a LaserJet II
   compatible laser printer. Since the pel only has 32 levels of gray,
   the pels are, themselves, dithered on an secondary matrix to smooth
   the spread to 256 distinct levels of gray. You get an 8 bit dump from
   a 6 bit dac. You're welcome, but I'd request credit please if you use it.
   The dither pattern is, unfortunately, intrusive in the lighter shades.
   I tried halftoning the halftone pel instead, but the results were lumpier
   than what I have here. Maybe someone has a good scatter dither that is
   adaptable to this use??}
Var
   x,y,pdq,off,linePos,pass,color,color1,color2,i:integer;
   OutByte,cmod,pel:byte;
   linepix:array[0..359] of byte;
   outline:string[255];
   gray:array[0..255]of byte;

const
   yrange=479;
   xhalftone:array[0..287]of byte=(
      35, 39, 54, 62,159,155,105, 98, 99,103,118,126,223,219, 41, 34, 35, 39,
      42, 46, 50, 58,151,147,109,102,106,110,114,122,215,211, 45, 38, 42, 46,
     156,148,144,140,136,143,113,117,220,212,208,204,200,207, 49, 53,156,148,
     159,152,133,129,132,139,121,125,223,216,197,193,196,203, 57, 61,159,152,
      95, 91,137,130,131,135,150,158, 31, 27,201,194,195,199,214,222, 95, 91,
      87, 83,141,134,138,142,146,154, 23, 19,205,198,202,206,210,218, 87, 83,
      72, 79,145,149, 28, 20, 16, 12,  8, 15,209,213, 92, 84, 80, 76, 72, 79,
      68, 75,153,157, 31, 24,  5,  1,  4, 11,217,221, 95, 88, 69, 65, 68, 75,
      67, 71, 86, 94,255,251,  9,  2,  3,  7, 22, 30,191,187, 73, 66, 67, 71,
      74, 78, 82, 90,247,243, 13,  6, 10, 14, 18, 26,183,179, 77, 70, 74, 78,
     252,244,240,236,232,239, 17, 21,188,180,176,172,168,175, 81, 85,252,244,
     255,248,229,225,228,235, 25, 29,191,184,165,161,164,171, 89, 93,255,248,
      63, 59,233,226,227,231,246,254,127,123,169,162,163,167,182,190, 63, 59,
      55, 51,237,230,234,238,242,250,119,115,173,166,170,174,178,186, 55, 51,
      40, 47,241,245,124,116,112,108,104,111,177,181, 60, 52, 48, 44, 40, 47,
      36, 43,249,253,127,120,101, 97,100,107,185,189, 63, 56, 37, 33, 36, 43);


   procedure graysum;
   var r,g,b:byte;
       c:word;
       i:integer;
   begin
      for i:=0 to 255 do
      begin
         c:=i;
         asm             {get rgb values for this color}
           mov ah,$10;
           mov al,$15;
           mov bx,c;
           int $10;
           mov r,dh;
           mov g,ch;
           mov b,cl;
         end;
       {stretch from six bit to eight bit gray scale for print dump}
         gray[i]:=255-(round(r*1.2)+round(g*2.36)+round(b*0.44)); {& invert}
    {     gray[i]:=255-i; }   {test stuff for gray fountain}
      end;
   end;


Begin        {LandscapeXlaser}
   write(lst,#27,'E');
   write(lst,#27,'&l1O');      {landscape}
   write(lst,#27,'*r0F');      {no rotation}
   write(lst,#27,'*p150X');    {Set horizontal cursor position}
   write(lst,#27,'*p-100Y');     {set vertical cursor position}
   write(lst,#27,'*t300R');    {raster graphics @300dpi}
   write(lst,#27,'*r1A');      {start graphics - current cursor}
   graysum;
   for y:=0 to yrange do
    begin
       for x:=0 to 359 do linepix[x]:=gray[read360x480(x,y)];
       if keypressed then if readkey =#27 then
          begin
             write(lst,#27,'*rB');               {end graphics}
             write(lst,#27,#38,#108,#48,#72);    {page feed}
             exit;
          end;
       for pass:=0 to 4 do  {pixel is 5 dots deep at 300 dpi}
       begin
          off :=((y*5+pass) mod 16)*18; {index into halftone pel}
          putpixel(0,y-1,pass); {visual progress report}
          write(lst,#27,'*b360W'); {inform printer, 360 bytes graphics coming}
          x:=0;
          linepos:=1;
          while x<360 do
          begin
             color:=linepix[x];
             pdq:=off;
             if odd(x) then inc(pdq,8);

          {convert to halftone}
             color1:=color div 8;
             cmod:=color mod 8;
             OutByte:=0;         {avoid range check error when it's shifted}
             for i:=0 to 7 do                      {pixel is 8 dots wide}
             begin
                outbyte:=outbyte shl 1;
                color2:=color1;
                pel:=xhalftone[pdq+i];
                if cmod<succ((pel and 224)shr 5) then
                   if color2>0 then dec(color2);
                if color2>=(pel and 31)then outbyte:=outbyte or 1;
             end;
             inc(x);
             outline[linepos]:=chr(outbyte);
             inc(linepos);
             if linepos>255 then
             begin
                outline[0]:=chr(255);
                write(lst,outline);
                linepos:=1;
             end;
          end; {while x<320]}
          outline[0]:=chr(linepos-1);
          write(lst,outline);
       end; {pass}
   end; {for y}
   write(lst,#27,'*rB');               {end graphics}
   write(lst,#27,#38,#108,#48,#72);    {page feed}
   write(lst,#27,'E');             {reset printer}
end;  {Xlaser360x480x256}





begin
   set360x480;

   for y:=0 to 479 do for x:=0 to 359 do putpixel(x,y,x mod 256);
   for y:=1 to 235 do
   begin
      Ellipse(240,180,y,round(y*0.6),y);
      Ellipse(241,180,y,round(y*0.6),y);    {Moire killers}
      Ellipse(240,181,y,round(y*0.6),y);
      Ellipse(239,180,y,round(y*0.6),y);
      Ellipse(240,179,y,round(y*0.6),y);
   end;

 (*
   for y:=0 to 58 do      {gray fountain}
   begin
      for x:=0 to 359 do
      begin
         putpixel(x,y,x div 10);
         putpixel(x,59+y,32+x div 10);
         putpixel(x,118+y,64+(x div 10));
         putpixel(x,177+y,96+(x div 10));
         putpixel(x,236+y,128+(x div 10));
         putpixel(x,295+y,160+(x div 10));
         putpixel(x,354+y,192+(x div 10));
         putpixel(x,413+y,224+(x div 10));
      end;
   end;
   for y:=470 to 479 do for x:=0 to 319 do putpixel(x,y,x mod 256);
   *)
   xlaser360x480x256;
   asm
    mov ah,0
    mov al,$3     {80x25x16 text}
    int 10h
   end;
    {Miller time}
end.

{   EXAMPLE #2 }
{ ----------------------------   CUT  ------------------------- }
{ MUST have VESA driver in memory to work }

uses printer,crt;
var x,y:integer;
   xmax,ymax:word;
   Current_bank: byte;
   Pp: byte;


Procedure PutPix(x,y: word; c: byte); assembler;
Asm
  { Do some simple checking }
  mov  ax, x
  cmp  xmax,ax
  jb   @end          {x too big}

  mov  ax, y
  cmp  ymax, ax
  jb   @end          {y too big}

 { dec  x}

  { Calculate where we're going to place the pixel at A000:???? }
  mov ax,$a000
  Mov  ES, ax
  Mov  AX, Ymax
  Mul  pp            {page offset?}
  Add  Ax, Y
  Mov  Bx, Ax
  Mov  Ax, Xmax
  Mul  Bx
  Add  Ax, X
  Adc  Dx, 0
  Mov  Di, Ax
  Cmp  Dl, Current_bank
  { If we're at the bank we need to be, then skip it }
  Je   @skip
  { Set the video bank to what we need }
  Mov  Current_bank, Dl
  Mov  Ax, 4F05h
  Xor  Bx, Bx
  Int  10h

 @Skip:
  Mov  Al, C
  Mov  Es:[Di], Al
 @End:
End;


function GetPix(x,y: word):byte; assembler;
Asm
  { Do some simple checking }
  mov  ax, x
  cmp  xmax,ax
  jb   @end          {x too big}

  mov  ax, y
  cmp  ymax, ax
  jb   @end          {y too big}

{  dec  x}

  { Calculate where we're going to read the pixel at A000:???? }
  mov ax,$a000
  Mov  ES, ax
  Mov  AX, Ymax
  Mul  pp            {page offset?}
  Add  Ax, Y
  Mov  Bx, Ax
  Mov  Ax, Xmax
  Mul  Bx
  Add  Ax, X
  Adc  Dx, 0
  Mov  Di, Ax
  Cmp  Dl, Current_bank
  { If we're at the bank we need to be, then skip it }
  Je   @skip
  { Set the video bank to what we need }
  Mov  Current_bank, Dl
  Mov  Ax, 4F05h
  Xor  Bx, Bx
  Int  10h

 @Skip:
  Mov  al, Es:[Di]
 @End:
End;



Procedure Xlaser640x480x256; {vesa mode printer dump $101}
{Ron Nossaman May 1996   nossaman@southwind.net}
{ Each screen pixel in 640X480 graphics mode translates to a 4X4 printer
   pixel at 300 dpi. This routine maps X,Y screen coordinates into the
   halftone pel, determines the gray density level according to the
   rgb values of each palette entry, and sends the results to a LaserJet II
   compatible laser printer. Since the pel only has 32 levels of gray,
   the pels are, themselves, dithered on an secondary matrix to smooth
   the spread to 256 distinct levels of gray. You get an 8 bit dump from
   a 6 bit dac. You're welcome, but I'd request credit please if you use it.
   The dither pattern is, unfortunately, intrusive in the lighter shades.
   I tried halftoning the halftone pel instead, but the results were lumpier
   than what I have here. Maybe someone has a good scatter dither that is
   adaptable to this use??}
Var
   x,y,pdq,off,linePos,pass,color,color1,color2,i:integer;
   OutByte,acc,cmod,pel:byte;
   linepix:array[0..639] of byte;
   outline:string[255];
   gray:array[0..255]of byte;

const
   yrange=479;
   xhalftone:array[0..287]of byte=(
      35, 39, 54, 62,159,155,105, 98, 99,103,118,126,223,219, 41, 34, 35, 39,
      42, 46, 50, 58,151,147,109,102,106,110,114,122,215,211, 45, 38, 42, 46,
     156,148,144,140,136,143,113,117,220,212,208,204,200,207, 49, 53,156,148,
     159,152,133,129,132,139,121,125,223,216,197,193,196,203, 57, 61,159,152,
      95, 91,137,130,131,135,150,158, 31, 27,201,194,195,199,214,222, 95, 91,
      87, 83,141,134,138,142,146,154, 23, 19,205,198,202,206,210,218, 87, 83,
      72, 79,145,149, 28, 20, 16, 12,  8, 15,209,213, 92, 84, 80, 76, 72, 79,
      68, 75,153,157, 31, 24,  5,  1,  4, 11,217,221, 95, 88, 69, 65, 68, 75,
      67, 71, 86, 94,255,251,  9,  2,  3,  7, 22, 30,191,187, 73, 66, 67, 71,
      74, 78, 82, 90,247,243, 13,  6, 10, 14, 18, 26,183,179, 77, 70, 74, 78,
     252,244,240,236,232,239, 17, 21,188,180,176,172,168,175, 81, 85,252,244,
     255,248,229,225,228,235, 25, 29,191,184,165,161,164,171, 89, 93,255,248,
      63, 59,233,226,227,231,246,254,127,123,169,162,163,167,182,190, 63, 59,
      55, 51,237,230,234,238,242,250,119,115,173,166,170,174,178,186, 55, 51,
      40, 47,241,245,124,116,112,108,104,111,177,181, 60, 52, 48, 44, 40, 47,
      36, 43,249,253,127,120,101, 97,100,107,185,189, 63, 56, 37, 33, 36, 43);

   procedure graysum;
   var r,g,b:byte;
       c:word;
       i:integer;
   begin
      for i:=0 to 255 do
      begin
         c:=i;
         asm             {get rgb values for this color}
           mov ah,$10;
           mov al,$15;
           mov bx,c;
           int $10;
           mov r,dh;
           mov g,ch;
           mov b,cl;
         end;
       {stretch from six bit to eight bit gray scale for print dump}
         gray[i]:=255-(round(r*1.2)+round(g*2.36)+round(b*0.44)); {& invert}
   {      gray[i]:=255-i; }   {test stuff for gray fountain}
      end;
   end;


Begin        {LandscapeXlaser800x600x256}
   write(lst,#27,'E');
   write(lst,#27,'&l1O');      {landscape}
   write(lst,#27,'*r0F');      {no rotation}
   write(lst,#27,'*p50X');   {Set horizontal cursor start position}
   write(lst,#27,'*p50Y');   {set vertical cursor start position}
   write(lst,#27,'*t300R');    {raster graphics @300dpi}
   write(lst,#27,'*r1A');      {start graphics - current cursor}
   graysum;
   for y:=0 to yrange do
    begin
       for x:=0 to 639 do linepix[x]:=gray[getpix(x,y)];
       if keypressed then if readkey =#27 then
          begin
             write(lst,#27,'*rB');               {end graphics}
             write(lst,#27,#38,#108,#48,#72);    {page feed}
             write(lst,#27,'E');                 {reset printer}
             exit;
          end;
       for pass:=0 to 3 do  {pixel is 4 dots deep at 300 dpi}
       begin
          off :=((y*4+pass) mod 16)*18; {y index into halftone pel}
          for i:=0 to 4 do putpix(i,y,pass);   {visual progress report}
          write(lst,#27,'*b320W'); {inform printer, graphics coming}
          x:=0;
          linepos:=1;
          outbyte:=0;
          acc:=0;
          while x<640 do
          begin
             color:=linepix[x];
             pdq:=off+((x mod 4)*4);  {+ x offset}

      {convert to halftone}
             color1:=color div 8;
             cmod:=color mod 8;
             for i:=0 to 3 do             {pixel is 4 dots wide}
             begin
                outbyte:=outbyte shl 1;
                color2:=color1;
                pel:=xhalftone[pdq+i];
                if cmod<succ((pel and 224)shr 5) then
                   if color2>0 then dec(color2);
                if color2>=(pel and 31)then outbyte:=outbyte or 1;
                inc(acc);
                if acc>7 then
                begin
                   outline[linepos]:=chr(outbyte);
                   inc(linepos);
                   acc:=0; outbyte:=0;
                   if linepos>255 then
                   begin
                      outline[0]:=chr(255);
                      write(lst,outline);
                      linepos:=1;
                   end;
                end;
             end; {for i  - pixel width}
             inc(x);
          end; {while x<640}
          outline[0]:=chr(linepos-1);
          write(lst,outline);
       end; {pass}
   end; {for y}
   write(lst,#27,'*rB');               {end graphics}
   write(lst,#27,#38,#108,#48,#72);    {page feed}
   write(lst,#27,'E');                 {reset printer}
end;  {Xlaser640x480x256}


Function SetMode(mode: word): boolean; assembler; {borrowed for demo}
{ This function will work for more than just VESA modes, and more than  }
{ Just VESA cards also.  If it's under $100 (where vesa modes begin) it }
{ will use the normal video bios instead. So people without VESA cards/ }
{ drivers still can use this for 320x200x256, etc.                      }
asm
  { Comment this part out if you want to use vesa for this }
  {--}
  Cmp Mode, 100h
  Jb  @Normal_VGA { If it's below 100h then it's a std mode, why use VESA? }
  {--}
  Mov Ax, 4F02h   { VESA set modes }
  Mov Bx, mode
  Int 10h
  Cmp Ax, 004Fh   { AL=4F VESA supported, AH=00 successful }
  Jne @Error      { Else Error }
  mov al, true
  jmp @done
 @Error:
  mov al, false
  Jmp @done
 @Normal_VGA:
  mov ax, mode    { AH will of course be zero, as intended }
  int 10h
  Mov al, true
 @done:
end;



Procedure Circle(X,Y,size: longint; color: byte);  {borrowed for demo}
Var Xl,Yl : LongInt;
Begin
  If Size=0 Then Begin
    PutPix(X,Y,color);
    Exit;
  End;
  Xl := 0;
  Yl := Size;
  Size := Size*Size+1;
  Repeat
    PutPix(X+Xl,Y+Yl,color);
    PutPix(X-Xl,Y+Yl,color);
    PutPix(X+Xl,Y-Yl,color);
    PutPix(X-Xl,Y-Yl,color);
    If Xl*Xl+Yl*Yl >= Size Then Dec(Yl)
    Else Inc(Xl);
  Until Yl = 0;
  PutPix(X+Xl,Y+Yl,color);
  PutPix(X-Xl,Y+Yl,color);
  PutPix(X+Xl,Y-Yl,color);
  PutPix(X-Xl,Y-Yl,color);
end;






begin
   xmax := 640;
   ymax := 480;
   setmode($101);     {640x480x256 VESA}
   current_bank:=0;  pp:=0;

                     {dither test stuff}
 for y:=0 to 479 do for x:=0 to 639 do putpix(x,y,x mod 256);
 for y:=1 to 236 do circle(320,240,y,y mod 256);
(*
 for y:=0 to 59 do         {gray fountain}
 begin
    for x:=0 to 639 do
    begin
       putpix(x,y,x div 32);
       putpix(x,60+y,32+x div 32);
       putpix(x,120+y,64+(x div 32));
       putpix(x,180+y,96+(x div 32));
       putpix(x,240+y,128+(x div 32));
       putpix(x,300+y,160+(x div 32));
       putpix(x,360+y,192+(x div 32));
       putpix(x,420+y,224+(x div 32));
    end;
 end;
 for y:=465 to 479 do for x:=0 to 639 do putpix(x,y,round(x/2.5));
 *)
 xlaser640x480x256;    {dump}
 setmode(lastmode);    {Miller time}
end.

{   EXAMPLE #3 }
{ ----------------------------   CUT  ------------------------- }

{ MUST have VESA driver in memory to work }

uses printer,crt;
var x,y:integer;
   xmax,ymax:word;
   Current_bank: byte;
   Pp: byte;


Procedure PutPix(x,y: word; c: byte); assembler;
Asm
  { Do some simple checking }
  mov  ax, x
  cmp  xmax,ax
  jb   @end          {x too big}

  mov  ax, y
  cmp  ymax, ax
  jb   @end          {y too big}

 { dec  x}

  { Calculate where we're going to place the pixel at A000:???? }
  mov ax,$a000
  Mov  ES, ax
  Mov  AX, Ymax
  Mul  pp            {page offset?}
  Add  Ax, Y
  Mov  Bx, Ax
  Mov  Ax, Xmax
  Mul  Bx
  Add  Ax, X
  Adc  Dx, 0
  Mov  Di, Ax
  Cmp  Dl, Current_bank
  { If we're at the bank we need to be, then skip it }
  Je   @skip
  { Set the video bank to what we need }
  Mov  Current_bank, Dl
  Mov  Ax, 4F05h
  Xor  Bx, Bx
  Int  10h

 @Skip:
  Mov  Al, C
  Mov  Es:[Di], Al
 @End:
End;


function GetPix(x,y: word):byte; assembler;
Asm
  { Do some simple checking }
  mov  ax, x
  cmp  xmax,ax
  jb   @end          {x too big}

  mov  ax, y
  cmp  ymax, ax
  jb   @end          {y too big}

{  dec  x}

  { Calculate where we're going to read the pixel at A000:???? }
  mov ax,$a000
  Mov  ES, ax
  Mov  AX, Ymax
  Mul  pp            {page offset?}
  Add  Ax, Y
  Mov  Bx, Ax
  Mov  Ax, Xmax
  Mul  Bx
  Add  Ax, X
  Adc  Dx, 0
  Mov  Di, Ax
  Cmp  Dl, Current_bank
  { If we're at the bank we need to be, then skip it }
  Je   @skip
  { Set the video bank to what we need }
  Mov  Current_bank, Dl
  Mov  Ax, 4F05h
  Xor  Bx, Bx
  Int  10h

 @Skip:
  Mov  al, Es:[Di]
 @End:
End;



Procedure Xlaser800x600x256; {vesa mode printer dump $102}
{Ron Nossaman May 1996   nossaman@southwind.net}
{ Each screen pixel in 800X600 graphics mode translates to a 4X4 printer
   pixel at 300 dpi. This routine maps X,Y screen coordinates into the
   halftone pel, determines the gray density level according to the
   rgb values of each palette entry, and sends the results to a LaserJet II
   compatible laser printer. Since the pel only has 32 levels of gray,
   the pels are, themselves, dithered on an secondary matrix to smooth
   the spread to 256 distinct levels of gray. You get an 8 bit dump from
   a 6 bit dac. You're welcome, but I'd request credit please if you use it.
   The dither pattern is, unfortunately, intrusive in the lighter shades.
   I tried halftoning the halftone pel instead, but the results were lumpier
   than what I have here. Maybe someone has a good scatter dither that is
   adaptable to this use??}
Var
   x,y,pdq,off,linePos,pass,color,color1,color2,i:integer;
   OutByte,acc,cmod,pel:byte;
   linepix:array[0..799] of byte;
   outline:string[255];
   gray:array[0..255]of byte;

const
   yrange=599;
   xhalftone:array[0..287]of byte=(
      35, 39, 54, 62,159,155,105, 98, 99,103,118,126,223,219, 41, 34, 35, 39,
      42, 46, 50, 58,151,147,109,102,106,110,114,122,215,211, 45, 38, 42, 46,
     156,148,144,140,136,143,113,117,220,212,208,204,200,207, 49, 53,156,148,
     159,152,133,129,132,139,121,125,223,216,197,193,196,203, 57, 61,159,152,
      95, 91,137,130,131,135,150,158, 31, 27,201,194,195,199,214,222, 95, 91,
      87, 83,141,134,138,142,146,154, 23, 19,205,198,202,206,210,218, 87, 83,
      72, 79,145,149, 28, 20, 16, 12,  8, 15,209,213, 92, 84, 80, 76, 72, 79,
      68, 75,153,157, 31, 24,  5,  1,  4, 11,217,221, 95, 88, 69, 65, 68, 75,
      67, 71, 86, 94,255,251,  9,  2,  3,  7, 22, 30,191,187, 73, 66, 67, 71,
      74, 78, 82, 90,247,243, 13,  6, 10, 14, 18, 26,183,179, 77, 70, 74, 78,
     252,244,240,236,232,239, 17, 21,188,180,176,172,168,175, 81, 85,252,244,
     255,248,229,225,228,235, 25, 29,191,184,165,161,164,171, 89, 93,255,248,
      63, 59,233,226,227,231,246,254,127,123,169,162,163,167,182,190, 63, 59,
      55, 51,237,230,234,238,242,250,119,115,173,166,170,174,178,186, 55, 51,
      40, 47,241,245,124,116,112,108,104,111,177,181, 60, 52, 48, 44, 40, 47,
      36, 43,249,253,127,120,101, 97,100,107,185,189, 63, 56, 37, 33, 36, 43);

   procedure graysum;
   var r,g,b:byte;
       c:word;
       i:integer;
   begin
      for i:=0 to 255 do
      begin
         c:=i;
         asm             {get rgb values for this color}
           mov ah,$10;
           mov al,$15;
           mov bx,c;
           int $10;
           mov r,dh;
           mov g,ch;
           mov b,cl;
         end;
       {stretch from six bit to eight bit gray scale for print dump}
         gray[i]:=255-(round(r*1.2)+round(g*2.36)+round(b*0.44)); {& invert}
   {      gray[i]:=255-i;}    {test stuff for gray fountain}
      end;
   end;


Begin        {LandscapeXlaser800x600x256}
   write(lst,#27,'E');
   write(lst,#27,'&l1O');      {landscape}
   write(lst,#27,'*r0F');      {no rotation}
   write(lst,#27,'*p-100X');   {Set horizontal cursor start position}
   write(lst,#27,'*p-100Y');   {set vertical cursor start position}
   write(lst,#27,'*t300R');    {raster graphics @300dpi}
   write(lst,#27,'*r1A');      {start graphics - current cursor}
   graysum;
   for y:=0 to yrange do
    begin
       for x:=0 to 799 do linepix[x]:=gray[getpix(x,y)];
       if keypressed then if readkey =#27 then
          begin
             write(lst,#27,'*rB');               {end graphics}
             write(lst,#27,#38,#108,#48,#72);    {page feed}
             write(lst,#27,'E');                 {reset printer}
             exit;
          end;
       for pass:=0 to 3 do  {pixel is 4 dots deep at 300 dpi}
       begin
          off :=((y*4+pass) mod 16)*18; {y index into halftone pel}
          for i:=0 to 4 do putpix(i,y,pass);   {visual progress report}
          write(lst,#27,'*b400W'); {inform printer, graphics coming}
          x:=0;
          linepos:=1;
          outbyte:=0;
          acc:=0;
          while x<800 do
          begin
             color:=linepix[x];
             pdq:=off+((x mod 4)*4);  {+ x offset}

      {convert to halftone}
             color1:=color div 8;
             cmod:=color mod 8;
             for i:=0 to 3 do             {pixel is 4 dots wide}
             begin
                outbyte:=outbyte shl 1;
                color2:=color1;
                pel:=xhalftone[pdq+i];
                if cmod<succ((pel and 224)shr 5) then
                   if color2>0 then dec(color2);
                if color2>=(pel and 31)then outbyte:=outbyte or 1;
                inc(acc);
                if acc>7 then
                begin
                   outline[linepos]:=chr(outbyte);
                   inc(linepos);
                   acc:=0; outbyte:=0;
                   if linepos>255 then
                   begin
                      outline[0]:=chr(255);
                      write(lst,outline);
                      linepos:=1;
                   end;
                end;
             end; {for i  - pixel width}
             inc(x);
          end; {while x<799}
          outline[0]:=chr(linepos-1);
          write(lst,outline);
       end; {pass}
   end; {for y}
   write(lst,#27,'*rB');               {end graphics}
   write(lst,#27,#38,#108,#48,#72);    {page feed}
   write(lst,#27,'E');                 {reset printer}
end;  {Xlaser800x600x256}


Function SetMode(mode: word): boolean; assembler; {borrowed for demo}
{ This function will work for more than just VESA modes, and more than  }
{ Just VESA cards also.  If it's under $100 (where vesa modes begin) it }
{ will use the normal video bios instead. So people without VESA cards/ }
{ drivers still can use this for 320x200x256, etc.                      }
asm
  { Comment this part out if you want to use vesa for this }
  {--}
  Cmp Mode, 100h
  Jb  @Normal_VGA { If it's below 100h then it's a std mode, why use VESA? }
  {--}
  Mov Ax, 4F02h   { VESA set modes }
  Mov Bx, mode
  Int 10h
  Cmp Ax, 004Fh   { AL=4F VESA supported, AH=00 successful }
  Jne @Error      { Else Error }
  mov al, true
  jmp @done
 @Error:
  mov al, false
  Jmp @done
 @Normal_VGA:
  mov ax, mode    { AH will of course be zero, as intended }
  int 10h
  Mov al, true
 @done:
end;



Procedure Circle(X,Y,size: longint; color: byte);  {borrowed for demo}
Var Xl,Yl : LongInt;
Begin
  If Size=0 Then Begin
    PutPix(X,Y,color);
    Exit;
  End;
  Xl := 0;
  Yl := Size;
  Size := Size*Size+1;
  Repeat
    PutPix(X+Xl,Y+Yl,color);
    PutPix(X-Xl,Y+Yl,color);
    PutPix(X+Xl,Y-Yl,color);
    PutPix(X-Xl,Y-Yl,color);
    If Xl*Xl+Yl*Yl >= Size Then Dec(Yl)
    Else Inc(Xl);
  Until Yl = 0;
  PutPix(X+Xl,Y+Yl,color);
  PutPix(X-Xl,Y+Yl,color);
  PutPix(X+Xl,Y-Yl,color);
  PutPix(X-Xl,Y-Yl,color);
end;






begin
   xmax := 800;
   ymax := 600;
   setmode($103);     {800x600x256 VESA}
   current_bank:=0;  pp:=0;
(*                     {secondary dither test stuff}
 for y:=0 to 599 do for x:=0 to 799 do putpix(x,y,x mod 256);
 for y:=1 to 290 do circle(400,300,y,y mod 256);
 *)
 for y:=0 to 74 do         {gray fountain}
 begin
    for x:=0 to 799 do
    begin
       putpix(x,y,x div 32);
       putpix(x,75+y,32+x div 32);
       putpix(x,150+y,64+(x div 32));
       putpix(x,225+y,96+(x div 32));
       putpix(x,300+y,128+(x div 32));
       putpix(x,375+y,160+(x div 32));
       putpix(x,450+y,192+(x div 32));
       putpix(x,525+y,224+(x div 32));
    end;
 end;
 for y:=580 to 599 do for x:=0 to 799 do putpix(x,y,x div 3);

 xlaser800x600x256;    {dump}
 setmode(lastmode);    {Miller time}
end.

{   EXAMPLE #4 }
{ ----------------------------   CUT  ------------------------- }

uses printer,crt;
var x,y:integer;
   xmax,ymax:word;
   Current_bank: byte;
   Pp: byte;


Procedure PutPix(x,y: word; c: byte); assembler;
Asm
  { Do some simple checking }
  mov  ax, x
  cmp  xmax,ax
  jb   @end          {x too big}

  mov  ax, y
  cmp  ymax, ax
  jb   @end          {y too big}

 { dec  x}

  { Calculate where we're going to place the pixel at A000:???? }
  mov ax,$a000
  Mov  ES, ax
  Mov  AX, Ymax
  Mul  pp            {page offset?}
  Add  Ax, Y
  Mov  Bx, Ax
  Mov  Ax, Xmax
  Mul  Bx
  Add  Ax, X
  Adc  Dx, 0
  Mov  Di, Ax
  Cmp  Dl, Current_bank
  { If we're at the bank we need to be, then skip it }
  Je   @skip
  { Set the video bank to what we need }
  Mov  Current_bank, Dl
  Mov  Ax, 4F05h
  Xor  Bx, Bx
  Int  10h

 @Skip:
  Mov  Al, C
  Mov  Es:[Di], Al
 @End:
End;


function GetPix(x,y: word):byte; assembler;
Asm
  { Do some simple checking }
  mov  ax, x
  cmp  xmax,ax
  jb   @end          {x too big}

  mov  ax, y
  cmp  ymax, ax
  jb   @end          {y too big}

{  dec  x}

  { Calculate where we're going to read the pixel at A000:???? }
  mov ax,$a000
  Mov  ES, ax
  Mov  AX, Ymax
  Mul  pp            {page offset?}
  Add  Ax, Y
  Mov  Bx, Ax
  Mov  Ax, Xmax
  Mul  Bx
  Add  Ax, X
  Adc  Dx, 0
  Mov  Di, Ax
  Cmp  Dl, Current_bank
  { If we're at the bank we need to be, then skip it }
  Je   @skip
  { Set the video bank to what we need }
  Mov  Current_bank, Dl
  Mov  Ax, 4F05h
  Xor  Bx, Bx
  Int  10h

 @Skip:
  Mov  al, Es:[Di]
 @End:
End;



Procedure Xlaser1024x768x256; {vesa mode printer dump $105}
{Ron Nossaman May 1996   nossaman@southwind.net}
{ Each screen pixel in 1024X768 graphics mode translates to a 3X3 printer
   pixel at 300 dpi. This routine maps X,Y screen coordinates into the
   halftone pel, determines the gray density level according to the
   rgb values of each palette entry, and sends the results to a LaserJet II
   compatible laser printer. Since the pel only has 32 levels of gray,
   the pels are, themselves, dithered on an secondary matrix to smooth
   the spread to 256 distinct levels of gray. You get an 8 bit dump from
   a 6 bit dac. You're welcome, but I'd request credit please if you use it.
   The dither pattern is, unfortunately, intrusive in the lighter shades.
   I tried halftoning the halftone pel instead, but the results were lumpier
   than what I have here. Maybe someone has a good scatter dither that is
   adaptable to this use??}
Var
   x,y,pdq,off,linePos,pass,color,color1,color2,i:integer;
   OutByte,acc,cmod,pel:byte;
   linepix:array[0..1023] of byte;
   outline:string[255];
   gray:array[0..255]of byte;

const
   yrange=767;
   xidx:array[0..15]of byte=(0,3,6,9,12,15,2,5,8,11,14,1,4,7,10,13);
   xhalftone:array[0..287]of byte=(
      35, 39, 54, 62,159,155,105, 98, 99,103,118,126,223,219, 41, 34, 35, 39,
      42, 46, 50, 58,151,147,109,102,106,110,114,122,215,211, 45, 38, 42, 46,
     156,148,144,140,136,143,113,117,220,212,208,204,200,207, 49, 53,156,148,
     159,152,133,129,132,139,121,125,223,216,197,193,196,203, 57, 61,159,152,
      95, 91,137,130,131,135,150,158, 31, 27,201,194,195,199,214,222, 95, 91,
      87, 83,141,134,138,142,146,154, 23, 19,205,198,202,206,210,218, 87, 83,
      72, 79,145,149, 28, 20, 16, 12,  8, 15,209,213, 92, 84, 80, 76, 72, 79,
      68, 75,153,157, 31, 24,  5,  1,  4, 11,217,221, 95, 88, 69, 65, 68, 75,
      67, 71, 86, 94,255,251,  9,  2,  3,  7, 22, 30,191,187, 73, 66, 67, 71,
      74, 78, 82, 90,247,243, 13,  6, 10, 14, 18, 26,183,179, 77, 70, 74, 78,
     252,244,240,236,232,239, 17, 21,188,180,176,172,168,175, 81, 85,252,244,
     255,248,229,225,228,235, 25, 29,191,184,165,161,164,171, 89, 93,255,248,
      63, 59,233,226,227,231,246,254,127,123,169,162,163,167,182,190, 63, 59,
      55, 51,237,230,234,238,242,250,119,115,173,166,170,174,178,186, 55, 51,
      40, 47,241,245,124,116,112,108,104,111,177,181, 60, 52, 48, 44, 40, 47,
      36, 43,249,253,127,120,101, 97,100,107,185,189, 63, 56, 37, 33, 36, 43);

   procedure graysum;
   var r,g,b:byte;
       c:word;
       i:integer;
   begin
      for i:=0 to 255 do
      begin
         c:=i;
         asm             {get rgb values for this color}
           mov ah,$10;
           mov al,$15;
           mov bx,c;
           int $10;
           mov r,dh;
           mov g,ch;
           mov b,cl;
         end;
       {stretch from six bit to eight bit gray scale for print dump}
         gray[i]:=255-(round(r*1.2)+round(g*2.36)+round(b*0.44)); {& invert}
   {      gray[i]:=255-i; }   {test stuff for gray fountain}
      end;
   end;


Begin        {LandscapeXlaser1024x768x256}
   write(lst,#27,'E');
   write(lst,#27,'&l1O');      {landscape}
   write(lst,#27,'*r0F');      {no rotation}
   write(lst,#27,'*p-50X');   {Set horizontal cursor start position}
   write(lst,#27,'*p-50Y');   {set vertical cursor start position}
   write(lst,#27,'*t300R');    {raster graphics @300dpi}
   write(lst,#27,'*r1A');      {start graphics - current cursor}
   graysum;
   for y:=0 to yrange do
    begin
       for x:=0 to 1023 do linepix[x]:=gray[getpix(x,y)];
       if keypressed then if readkey =#27 then
          begin
             write(lst,#27,'*rB');               {end graphics}
             write(lst,#27,#38,#108,#48,#72);    {page feed}
             exit;
          end;
       for pass:=0 to 2 do  {pixel is 3 dots deep at 300 dpi}
       begin
          off :=((y*3+pass) mod 16)*18; {y index into halftone pel}
          for i:=0 to 4 do putpix(i,y,pass);   {visual progress report}
          write(lst,#27,'*b384W'); {inform printer, 384 bytes graphics coming}
          x:=0;
          linepos:=1;
          outbyte:=0;
          acc:=0;
          while x<1024 do
          begin
             color:=linepix[x];
             pdq:=off+xidx[x mod 16];  {+ x offset}

      {convert to halftone}
             color1:=color div 8;
             cmod:=color mod 8;
             for i:=0 to 2 do             {pixel is 3 dots wide}
             begin
                outbyte:=outbyte shl 1;
                color2:=color1;
                pel:=xhalftone[pdq+i];
                if cmod<succ((pel and 224)shr 5) then
                   if color2>0 then dec(color2);
                if color2>=(pel and 31)then outbyte:=outbyte or 1;
                inc(acc);
                if acc>7 then
                begin
                   outline[linepos]:=chr(outbyte);
                   inc(linepos);
                   acc:=0; outbyte:=0;
                   if linepos>255 then
                   begin
                      outline[0]:=chr(255);
                      write(lst,outline);
                      linepos:=1;
                   end;
                end;
             end; {for i  - pixel width}
             inc(x);
          end; {while x<1024}
          outline[0]:=chr(linepos-1);
          write(lst,outline);
       end; {pass}
   end; {for y}
   write(lst,#27,'*rB');               {end graphics}
   write(lst,#27,#38,#108,#48,#72);    {page feed}
   write(lst,#27,'E');
end;  {Xlaser320x200x256}


Function SetMode(mode: word): boolean; assembler;
{ This function will work for more than just VESA modes, and more than  }
{ Just VESA cards also.  If it's under $100 (where vesa modes begin) it }
{ will use the normal video bios instead. So people without VESA cards/ }
{ drivers still can use this for 320x200x256, etc.                      }
asm
  { Comment this part out if you want to use vesa for this }
  {--}
  Cmp Mode, 100h
  Jb  @Normal_VGA { If it's below 100h then it's a std mode, why use VESA? }
  {--}
  Mov Ax, 4F02h   { VESA set modes }
  Mov Bx, mode
  Int 10h
  Cmp Ax, 004Fh   { AL=4F VESA supported, AH=00 successful }
  Jne @Error      { Else Error }
  mov al, true
  jmp @done
 @Error:
  mov al, false
  Jmp @done
 @Normal_VGA:
  mov ax, mode    { AH will of course be zero, as intended }
  int 10h
  Mov al, true
 @done:
end;


Procedure Circle(X,Y,size: longint; color: byte);
Var Xl,Yl : LongInt;
Begin
  If Size=0 Then Begin
    PutPix(X,Y,color);
    Exit;
  End;
  Xl := 0;
  Yl := Size;
  Size := Size*Size+1;
  Repeat
    PutPix(X+Xl,Y+Yl,color);
    PutPix(X-Xl,Y+Yl,color);
    PutPix(X+Xl,Y-Yl,color);
    PutPix(X-Xl,Y-Yl,color);
    If Xl*Xl+Yl*Yl >= Size Then Dec(Yl)
    Else Inc(Xl);
  Until Yl = 0;
  PutPix(X+Xl,Y+Yl,color);
  PutPix(X-Xl,Y+Yl,color);
  PutPix(X+Xl,Y-Yl,color);
  PutPix(X-Xl,Y-Yl,color);
end;






begin
   xmax := 1024;
   ymax := 768;
   setmode($105);     {1024x768x256}

 for y:=0 to 767 do for x:=0 to 1023 do putpix(x,y,x mod 256);
 for y:=1 to 380 do circle(512,384,y,y mod 256);
 (*
 for y:=0 to 95 do        {gray fountain}
 begin
    for x:=0 to 1023 do
    begin
       putpix(x,y,x div 32);
       putpix(x,96+y,32+x div 32);
       putpix(x,192+y,64+(x div 32));
       putpix(x,288+y,96+(x div 32));
       putpix(x,384+y,128+(x div 32));
       putpix(x,480+y,160+(x div 32));
       putpix(x,576+y,192+(x div 32));
       putpix(x,672+y,224+(x div 32));
    end;
 end;
 for y:=740 to 767 do for x:=0 to 1023 do putpix(x,y,x div 4);
   *)
 xlaser1024x768x256;    {dump}
{ repeat until keypressed;}
 setmode(lastmode);    {Miller time}
end.

{   EXAMPLE #5 }
{ ----------------------------   CUT  ------------------------- }

uses printer,crt;

var x,y:integer;


Procedure Xlaser320x200x256;
{Ron Nossaman May 1996   nossaman@southwind.net}
{ Each screen pixel in 320X200 graphics mode translates to an 8X10 printer
   pixel at 300 dpi. This routine maps X,Y screen coordinates into the
   halftone pel, determines the gray density level according to the
   rgb values of each palette entry, and sends the results to a LaserJet II
   compatible laser printer. Since the pel only has 32 levels of gray,
   the pels are, themselves, dithered on an secondary matrix to smooth
   the spread to 256 distinct levels of gray. You get an 8 bit dump from
   a 6 bit dac. You're welcome, but I'd request credit please if you use it.
   The dither pattern is, unfortunately, intrusive in the lighter shades.
   I tried halftoning the halftone pel instead, but the results were lumpier
   than what I have here. Maybe someone has a good scatter dither that is
   adaptable to this use??}
Var
   x,y,pdq,off,linePos,pass,color,color1,color2:integer;
   OutByte,pel,cmod,i:byte;
   linepix:array[0..319] of byte;
   outline:string[255];
   gray:array[0..255]of byte;

const
   yrange=199;
   xhalftone:array[0..287]of byte=(
      35, 39, 54, 62,159,155,105, 98, 99,103,118,126,223,219, 41, 34, 35, 39,
      42, 46, 50, 58,151,147,109,102,106,110,114,122,215,211, 45, 38, 42, 46,
     156,148,144,140,136,143,113,117,220,212,208,204,200,207, 49, 53,156,148,
     159,152,133,129,132,139,121,125,223,216,197,193,196,203, 57, 61,159,152,
      95, 91,137,130,131,135,150,158, 31, 27,201,194,195,199,214,222, 95, 91,
      87, 83,141,134,138,142,146,154, 23, 19,205,198,202,206,210,218, 87, 83,
      72, 79,145,149, 28, 20, 16, 12,  8, 15,209,213, 92, 84, 80, 76, 72, 79,
      68, 75,153,157, 31, 24,  5,  1,  4, 11,217,221, 95, 88, 69, 65, 68, 75,
      67, 71, 86, 94,255,251,  9,  2,  3,  7, 22, 30,191,187, 73, 66, 67, 71,
      74, 78, 82, 90,247,243, 13,  6, 10, 14, 18, 26,183,179, 77, 70, 74, 78,
     252,244,240,236,232,239, 17, 21,188,180,176,172,168,175, 81, 85,252,244,
     255,248,229,225,228,235, 25, 29,191,184,165,161,164,171, 89, 93,255,248,
      63, 59,233,226,227,231,246,254,127,123,169,162,163,167,182,190, 63, 59,
      55, 51,237,230,234,238,242,250,119,115,173,166,170,174,178,186, 55, 51,
      40, 47,241,245,124,116,112,108,104,111,177,181, 60, 52, 48, 44, 40, 47,
      36, 43,249,253,127,120,101, 97,100,107,185,189, 63, 56, 37, 33, 36, 43);

   procedure graysum;
   var r,g,b:byte;
       c:word;
       i:integer;
   begin
      for i:=0 to 255 do
      begin
         c:=i;
         asm             {get rgb values for this color}
           mov ah,$10;
           mov al,$15;
           mov bx,c;
           int $10;
           mov r,dh;
           mov g,ch;
           mov b,cl;
         end;
       {stretch from six bit to eight bit gray scale for print dump}
         gray[i]:=255-(round(r*1.2)+round(g*2.36)+round(b*0.44)); {& invert}
  {       gray[i]:=255-i; }   {test stuff for gray fountain}
      end;
   end;


Begin        {LandscapeXlaser}
   write(lst,#27,'E');
   write(lst,#27,'&l1O');      {landscape}
   write(lst,#27,'*r0F');      {no rotation}
   write(lst,#27,'*p300X');    {Set cursor position}
   write(lst,#27,'*t300R');    {raster graphics @300dpi}
   write(lst,#27,'*r1A');      {start graphics - current cursor}
   graysum;
   for y:=0 to yrange do
    begin
       move(mem[$a000:y*320],linepix,320);
       for x:=0 to 319 do linepix[x]:=gray[linepix[x]];
       if keypressed then if readkey =#27 then
          begin
             write(lst,#27,'*rB');               {end graphics}
             write(lst,#27,#38,#108,#48,#72);    {page feed}
             exit;
          end;
       for pass:=0 to 9 do  {pixel is 10 dots deep at 300 dpi}
       begin
          off :=((y*10+pass) mod 16)*18; {index into halftone pel}
          mem[$a000:y*320]:=pass; {visual progress report}
          write(lst,#27,'*b320W'); {inform printer, 320 bytes graphics coming}
          x:=0;
          linepos:=1;
          while x<320 do
          begin
             color:=linepix[x];
             pdq:=off;
             if odd(x) then inc(pdq,8);

          {convert to halftone}
             color1:=color div 8;
             cmod:=color mod 8;
             OutByte:=0;       {avoid range check error when it's shifted}
             for i:=0 to 7 do          {pixel is 8 dots wide}
             begin
                outbyte:=outbyte shl 1;
                color2:=color1;
                pel:=xhalftone[pdq+i];
                if cmod<succ((pel and 224)shr 5) then
                   if color2>0 then dec(color2);
                if color2>=(pel and 31)then outbyte:=outbyte or 1;
             end;
             inc(x);
             outline[linepos]:=chr(outbyte);
             inc(linepos);
             if linepos>255 then
             begin
                outline[0]:=chr(255);
                write(lst,outline);
                linepos:=1;
             end;
          end; {while x<320]}
          outline[0]:=chr(linepos-1);
          write(lst,outline);
       end; {pass}
   end; {for y}
   write(lst,#27,'*rB');               {end graphics}
   write(lst,#27,#38,#108,#48,#72);    {page feed}
end;  {Xlaser320x200x256}





{this stuff isn't mine, it's borrowed just to demo the dump}
procedure PutPixel(X,Y: word; Color: byte); assembler;
asm
 mov ax,y
 mov bx,x
 xchg ah,al
 add bx,ax
 shr ax,1
 shr ax,1
 add bx,ax
 mov ax,0a000h
 mov es,ax
 mov al,Color
 mov es:[bx],al
end;

procedure Ellipse(X,Y,YRad,XRad: integer; Color: byte);
var
 EX,EY: integer;
 YRadSqr,YRadSqr2,XRadSqr,XRadSqr2,D,DX,DY: longint;
begin
 EX:=0;
 EY:=XRad;
 YRadSqr:=longint(YRad)*YRad;
 YRadSqr2:=2*YRadSqr;
 XRadSqr:=longInt(XRad)*XRad;
 XRadSqr2:=2*XRadSqr;
 D:=XRadSqr-YRadSqr*XRad+YRadSqr div 4;
 DX:=0;
 DY:=YRadSqr2*XRad;
 PutPixel(Y-EY,X,Color);
 PutPixel(Y+EY,X,Color);
 PutPixel(Y,X-YRad,Color);
 PutPixel(Y,X+YRad,Color);
 while (DX<DY) do begin
  if (D>0) then begin
   Dec(EY);
   Dec(DY,YRadSqr2);
   Dec(D,DY);
  end;
  Inc(EX);
  Inc(DX,XRadSqr2);
  Inc(D,XRadSqr+DX);
  PutPixel(Y+EY,X+EX,Color);
  PutPixel(Y+EY,X-EX,Color);
  PutPixel(Y-EY,X+EX,Color);
  PutPixel(Y-EY,X-EX,Color);
 end;
 Inc(D,(3*(YRadSqr-XRadSqr) div 2-(DX+DY)) div 2);
 while (EY>0) do begin
  if(D<0) then begin
   Inc(EX);
   Inc(DX,XRadSqr2);
   Inc(D,XRadSqr+DX);
  end;
  Dec(EY);
  Dec(DY,YRadSqr2);
  Inc(D,YRadSqr-DY);
  PutPixel(Y+EY,X+EX,Color);
  PutPixel(Y+EY,X-EX,Color);
  PutPixel(Y-EY,X+EX,Color);
  PutPixel(Y-EY,X-EX,Color);
 end;
end;


begin
 asm
  mov ah,0
  mov al,$13     {320x200x256 graphic}
  int 10h
 end;

 for y:=0 to 199 do for x:=0 to 319 do putpixel(x,y,x mod 256);
 for y:=1 to 98 do
 begin
    Ellipse(100,160,y,round(y*1.2),y);
    Ellipse(101,160,y,round(y*1.2),y);    {Moire killers}
    Ellipse(100,161,y,round(y*1.2),y);
    Ellipse(99,160,y,round(y*1.2),y);
    Ellipse(100,159,y,round(y*1.2),y);
 end;

(*
 for y:=0 to 24 do         {gray fountain}
 begin
    for x:=0 to 319 do
    begin
       putpixel(x,y,x div 10);
       putpixel(x,25+y,32+x div 10);
       putpixel(x,50+y,64+(x div 10));
       putpixel(x,75+y,96+(x div 10));
       putpixel(x,100+y,128+(x div 10));
       putpixel(x,125+y,160+(x div 10));
       putpixel(x,150+y,192+(x div 10));
       putpixel(x,175+y,224+(x div 10));
    end;
 end;
 for y:=190 to 199 do for x:=0 to 319 do putpixel(x,y,x mod 256);
 *)
 xlaser320x200x256;    {dump}
 asm
  mov ah,0
  mov al,$3     {80x25x16 text}
  int 10h
 end;
  {Miller time}
end.

{   EXAMPLE #6 }
{ ----------------------------   CUT  ------------------------- }

uses printer,graph,crt;

var grDriver,grMode,ErrCode,x,y:integer;


Procedure LandscapeXlaser;
(* Ron Nossaman May 1996        nossaman@southwind.net
   Each screen pixel in 640X480x16 graphics mode translates to a 4X4 printer
   pixel at 300 dpi to maintain a similar aspect ratio . This routine
   maps X,Y screen coordinates into the halftone pel, determines the gray
   density level [0..15] according to the color's rgb values, and sends
   the results to a LaserJet II compatible laser printer.  Credit, please
   if you use it in anything.  *)
Var
   x,y,pdq,linePos,pass,pass8,y32,color,color2:integer;
   OutByte:byte;
   linepix:array[0..639] of byte;
   outline:string[255];

   gray:array[0..15]of byte;
const
   yrange=479;
      xhalf :array[0..79]of byte=(
                     03,07,22,30,            31,27,      09,02,
                     10,14,18,26,            23,19,      13,06,
                                 28,20,16,12,08,15,      17,21,
                                 31,24,05,01,04,11,      25,29,
                           31,27,      09,02,03,07,22,30,
                           23,19,      13,06,10,14,18,26,
                           08,15,      17,21,            28,20,16,12,
                           04,11,      25,29,            31,24,05,01,
                     03,07,22,30,            31,27,      09,02,
                     10,14,18,26,            23,19,      13,06);

procedure graysum;
var palette:palettetype;
    r,g,b:byte;
    c:word;
    i:integer;
begin
   getpalette(palette);
   for i:=0 to 15 do
   begin
      c:=palette.colors[i];
      asm
        mov ah,$10;
        mov al,$15;
        mov bx,c;
        int $10;
        mov r,dh;
        mov g,ch;
        mov b,cl;
      end;
      gray[i]:=round((r*0.3)+(g*0.59)+(b*0.11))div 4;
   end;
end;


   Procedure assemblebyte;
   var i:integer;
   begin
      color2:=color shl 1;
      for i:=0 to 3 do
      begin
         outbyte:=outbyte shl 1;
         if color2>=xhalf[pdq+i] then outbyte:=outbyte or 1;
      end;
   end;{assemblebyte}


Begin        {LandscapeXlaser}
   write(lst,#27,'E');
   write(lst,#27,'&l1O');    {landscape}
   write(lst,#27,'*r0F');    {no rotation}
   write(lst,#27,'*p300X');  {Set cursor position}
   write(lst,#27,'*t300R');    {raster graphics @300dpi}
   write(lst,#27,'*r1A');      {start graphics - current cursor}
   graysum;      {convert to grayscale by color intensity}
   for y:= 0 to yrange do
    begin
       y32:=(y and 1)*32;
       for x:=0 to 639 do linepix[x]:=gray[getpixel(x,y)];  {screen dump}
       if keypressed then if readkey =#27 then
          begin
             write(lst,#27,'*rB');               {end graphics}
             write(lst,#27,#38,#108,#48,#72);    {page feed}
             exit;
          end;
       for pass:=0 to 3 do
       begin
          pass8:=pass*8;
          setcolor(pass); Line(0,y,20,y); {visual progress report}
          write(lst,#27,'*b320W');
          x:=0;
          linepos:=1;
          while x<640 do
          begin
             OutByte:=0;  {avoid range check error when it's shifted later}
             pdq:=pass8+y32;
             color:=linepix[x];
             assemblebyte;
             inc(x);
             pdq:=pdq+4;
             color:=linepix[x];
             assemblebyte;
             inc(x);
             outline[linepos]:=chr(outbyte);
             inc(linepos);
             if linepos>255 then
             begin
                outline[0]:=chr(255);
                write(lst,outline);
                linepos:=1;
             end;
          end; {while x<640]}
          outline[0]:=chr(linepos-1);
          write(lst,outline);
       end; {pass}
   end; {for y}
   write(lst,#27,'*rB');               {end graphics}
   write(lst,#27,#38,#108,#48,#72);    {page feed}
end;  {landscapeXlaser}




begin
  grDriver := Detect;
  InitGraph(grDriver,grmode,'');
  setgraphmode(2);
  ErrCode := GraphResult;
  if ErrCode <> grOk then
    begin
      CloseGraph;
      Writeln('Graphics error:', GraphErrorMsg(ErrCode));
      exit;
    end;
  for y:=0 to 470 do
  begin
     setcolor((y mod 256) div 16);
     line(y,y,639,y);
     line(y,y,y,479);
  end;
  for y:=1 to 180 do
  begin
     setcolor((y mod 128) div 8);
     circle(190,240,y);
     circle(191,240,y);
     circle(450,240,y);
     circle(449,240,y);
  end;
  landscapexlaser;
  closegraph;
end.

