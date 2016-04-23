
{Written By     : Wesley Burns                                               }
{Email          : microcon@iafrica.com                                       }

{Email: me if you have ANY questions about                                   }
{ : 64k DMA Sound Blaster Programming using XMS                              }
{ : Fast Memory Management                                                   }
{ : PCX using XMS                                                            }
{ : XMS Units                                                                }
{ : Pascal in general                                                        }
{ : Or if you have some fast procedures that you don't mind parting with.    }

PROGRAM FastClipMask;
{values: . x,y         :coords of picture
         . width,height:width and height of picture
         . maskcolor   :color to leave out
         . Sprite      :Souce of picture(Pointer)
         . Dest        :Pointer of destionation e.g Dest = ptr($a000:0000)}

var Pic,VScreen,BScreen:Pointer;
    Counter:word;
    time:real;
    color:integer;

{General Timer}
 Function timer:real;begin  timer:=meml[$0040:$006c]/18.2; end;

{Wait for vertical retrace, to stop flicker}
 Procedure WaitRetrace; Begin while ((Port[$3DA] AND 8) > 0) do; while 
((Port[$3DA] AND 8) = 0) do; End;

{Much Faster that pascal Move Command}
 procedure DMove (var source, dest; count: word); assembler;
  asm
   push ds
   lds  si,source      {ds,si = source}
   les  di,dest        {es,di = dest}
   mov  cx,count       {cx = count}
   mov  ax,cx          {ax = count}
   cld
   shr  cx,2           {cx = count / 4}
   db   66h
   rep  movsw          {copy double words}
   mov  cl,al          {get rest bytes}
   and  cl,3
   rep  movsb          {copy rest}
   pop  ds
 end;

{Mask Picture}
Procedure MaskPic(X,Y,Width,Height:integer; Maskcolor:byte; Sprite, 
Dest:Pointer);
 Begin

  If (x <= -width) or (x >= 320) or (y <= -height) or (y >= 200) then exit;
   {The above command checks to seek if the picture TOTAL runs of the scneen.}
   {This is so, because if the below procedure is given a picture that falls}
   {total past >= 320X200 then it screws up.}

 Asm
   PUSH  DS             { save DS. Turbo Pascal automatically }
                        { saves other registers (ES SI DI)    }
   LDS   SI,Sprite      { Make DS:SI point to image data }
   MOV   AX,WIDTH       { store width in variable }
   MOV   DX,AX
   PUSH  DX             { Save width for use with the }
                        { actual screen copying }
   ADD   AX,X           { Add X to width, check for right side cut }
   PUSH  Width          { save origonal width for possible top cutting }
   CMP   AX,320         { Check for right side clipping }
   JG    @RightCut
   SUB   AX,X           { Check for left side clipping }
   JC    @LeftCut
   JMP   @CheckBottom   { no clipping necessary on sides }

 @RightCut:
   SUB   AX,Width
   SUB   AX,320
   NEG   AX             { AX= -(new width), NEG to get + value }
   MOV   Width,AX       { set new width according to rightclip }
   JMP   @CheckBottom

 @LeftCut:
   ADD   AX,X
   MOV   Width,AX       { set width according to left clip }
   SUB   DX,AX
   ADD   SI,DX
   XOR   BX,BX
   MOV   X,BX           { recalculate X parameter }

 @CheckBottom:
   MOV   AX,Height
   ADD   AX,Y
   CMP   AX,200         { Check for bottom cut }
   JG    @BottomCut

   SUB   AX,Y           { Check for top cut }
   JC    @TopCut
   POP   BX             { Saved Width is no longer necessary }
                        { so remove it from the stack }
   JMP   @Display       { no clipping on bottom necessary }

 @BottomCut:
   POP   BX             { remove saved width from stack }
                        { no longer necessary }
   SUB   AX,Height
   SUB   AX,200
   NEG   AX
   MOV   Height,AX       { adjust height according to clip}
   JMP   @Display

 @TopCut:
  ADD   AX,Y
  POP   BX             { retreive saved width value }
  PUSH  AX             { save AX, which is new height value }
  MOV   AX,Y
  NEG   AX
  IMUL  BX
  ADD   SI,AX          { adjust starting offset in sprite data }
                       { according to the top cut }
  POP   AX             { retrieve new height value }

  MOV   Height,AX       { adjust height according to clip}
  MOV   BX,0
  MOV   Y,BX            { Recalculate Y parameter }
 
 @Display:
 {  les   AX,dest}
 {  MOV   di,AX}
   LES di,dest
 {  XOR   DI,DI           { Make ES:DI point to A000h:0000h}
   MOV   AX,320
   IMUL  [Y]
   MOV   DI,AX
   ADD   DI,X            { Calculate screen offset }
   POP   DX              { Retrieve origional width }

   MOV   BX,Width        { Store values in registers }
   MOV   CX,Height       { for optimal speed }

   { The actual sprite is copied here.
     The Byte Ptr operations are used because they are faster
     than LODSB and STOSB on 386+ CPUs! Change it and see
     for yourself! The same is true with the DEC CX/JNZ
     instead of the LOOP instruction }

  @HeightLoop:               { Loop for height }
   PUSH  SI
   PUSH  DI

   PUSH  CX
   MOV   CX,BX
  @WidthLoop:                { Loop for width }
   MOV   AL,Byte Ptr [DS:SI] { get 1 byte of sprite data }
   CMP   AL,Maskcolor        { check for "transparent" color }
   JZ    @Skipped
   MOV   Byte Ptr [ES:DI],AL { Store sprite data onto screen }

  @Skipped:
   INC   SI
   INC   DI

   DEC   CX
   JNZ  @WidthLoop

   POP   CX
   POP   DI
   POP   SI
   ADD   DI,320  { Increment video memory by 1 line }
   ADD   SI,DX   { Increment Sprite data by 1 line (DX=Width)}

   DEC   CX
   JNZ  @HeightLoop
 
   POP   DS
   {all done, whew!}
 End;
End;

Begin
 asm; mov ax,13h;int 10h;end;
 Getmem(Pic,40000);       {50x50 picture}
 GetMem(VScreen,64000);  {Virtual Screen, Scratch Pad}
 GetMem(BScreen,64000);  {Background, holds "game scenery"}
 Fillchar(VScreen^,64000,0);
 Fillchar(BScreen^,64000,4);
 Color := 0;

 {make picture}
 for counter := 0 to 40000 do
  begin color := not color;
   IF COLOR = -1 THEN mem[seg(Pic^):counter] := 0;
   IF COLOR = 0 THEN mem[seg(Pic^):counter] := random(2)+1;
  end;

 {Animate }
 time:=timer;
 for counter := 0 to 199 do
  begin
   {picture has black(0) and blue(1) stripes, masking only Black(0)}
   {                             | mask color, try changing it.    }
   MaskPic(counter,counter, 200, 200, 0, Pic, VScreen); {Draw Picture To 
VIRTUAL SCREEN}
   DMove(VScreen^, mem[$A000:0000], 64000);        {Move VScreen to 
Screen($a000:0000)}
   DMove(BScreen^, VScreen^, 64000);               {Restore Background screen}
   WaitRetrace;
  end;

 {Shut Down}
 asm; mov ax,03h;int 10h;end;

 writeln;
 writeln('With Background Updating, Copying to screen and Wait Retrace');
 writeln(' Tested on 486-DX4-100MHz                : 2.91 seconds for 100x200x200 frames');
 writeln(' On This machine for 100x 200x200 frames : ', timer-time:3:2, 'seconds');

 Freemem(Pic,40000);
 FreeMem(VScreen,64000);
 FreeMem(BScreen,64000);
End.
