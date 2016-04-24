(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0141.PAS
  Description: 256 Color 320x200 BMP Loader
  Author: SIMON R BOWSER
  Date: 11-26-94  04:58
*)

{
   320x200x256c BMP loader
   written by:
 .--------- Simon R Bowser ------- aka Pinrut -----------.
 |  Department of Computer Science, Aberdeen University  |
 |            E-Mail: u04srb@abdn.ac.uk                  |
 |     Simon.Bowser@launchpad.unc.edu  |
 `-------------------------------------------------------'
  This code if FREEWARE, do with it as you will.

  note: this ONLY works for 320x200 images
}

Procedure LoadBMP(Name:String;where:word);
type
     Virtual = Array [1..64000] of byte;
VAR
   PicBuf: ^Virtual;

   Data:File;
   RGB:ARRAY[0..255,1..4] OF Byte;
   Header:Array[1..54] of Byte;
   aAddr :word;

   I:Byte;
   {x,y:integer;}

  Procedure SetPal(Col,R,G,B : Byte); assembler;
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

BEGIN
     GetMem (PicBuf,64000);
     Assign(Data,Name); Reset(Data,1);
     BlockRead(Data,Header,54);                 { read and ignore :) }
     BlockRead(Data,RGB,1024);                  { pal info }
     FOR I:=0 TO 255 DO
  SetPal(I,RGB[I,3] div 4,RGB[I,2] div 4,RGB[I,1] div 4);
     BlockRead(Data,PicBuf^,64000);
     Close(Data);
     aAddr := seg (PicBuf^);

  asm                    {AMS routine 2.7 times faster than Pascal one!}
     push si             {wibble, wobble ;) }
     push di             {I'm no ASM, programmer so there MUST me room}
     push es             {for optimisation}
     push ds
     mov es, [where]
     mov ds, [aAddr]
     mov di, 0
     mov dx, 63680
     mov cx, 200
  @page:
     push cx
     mov cx, 320
     mov si, dx
  @line:
     mov bh, byte ptr ds:[si]
     mov es:[di], bh
     inc di
     inc si
     loop @line
     sub dx, 320
     pop cx
     loop @page
     pop ds
     pop es
     pop di
     pop si
  end;

{    for y:=0 to 199 do
      for x:=0 to 319 do
 Mem[where:y*320+x] := Mem[aAddr:(199-y)*320+x];}

  FreeMem(PicBuf,64000);
END;

begin
  asm mov        ax,0013h;int        10h; end;      { set MCGA }
  LoadBMP('whatever.bmp',$A000);

  { repeat until keypressed;  (use crt) }
end.


