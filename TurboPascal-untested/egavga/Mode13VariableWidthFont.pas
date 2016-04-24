(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0265.PAS
  Description: Mode-13 Variable Width font
  Author: EDDY JANSSON
  Date: 02-21-96  21:04
*)

Program SaruFont;
{ Mail suggestions & Improvements to eddy.jansson@saru.ct.se }
Uses Dos,Crt;

var
 F              :File;
 BytesRead      :Word;
 Font           :Array[1..8192] of Byte; { Better safe than sorry ;}

Const
(*
font: db 5,32,58 { Fontheight,first defined character, characters defined }
      db width,bitmapline1,bitmapline2..bitmapline[height]
      etc..
*)
 SmallFont :Array[1..357] of byte = (5, 32, 58, { Space to 'Z' }
  2,  0,  0,  0,  0,  0,  2, 64, 64, 64,  0, 64,  3,144,144,  0,
  0,  0,  3,144,248,144,248,144,  3, 96,128, 64, 32,192,  3,  0,144, 32, 64,
144,  3, 64,160, 64,  0,224,  3, 64,128,  0,  0,  0,  3, 32, 64, 64, 64, 32,
  3, 64, 32, 32, 32, 64,  3,144, 96, 96,144,  0,  3, 32, 32,248, 32, 32,  2,
  0,  0,  0, 64,128,  3,  0,  0,240,  0,  0,  2,  0,  0,  0,  0, 64,  3,  8,
 16, 32, 64,128,  3, 64,160,160,160, 64,  3, 64,192, 64, 64,224,  3,224, 32,
 64,128,224,  3,224, 32,224, 32,224,  3,160,160,224, 32, 32,  3,224,128,224,
 32,224,  3,224,128,224,160,224,  3,224, 32, 32, 32, 32,  3, 64,160, 64,160,
 64,  3,224,160,224, 32, 32,  3,  0, 96,  0,  0, 96,  3,  0, 96,  0,  0, 96,
  3, 64,128,  0,128, 64,  3,  0,240,  0,240,  0,  3, 32, 16,  8, 16, 32,  3,
192, 32, 64,  0, 64,  3,240,  8,104, 72,  8,  3,224,160,224,160,160,  3,192,
160,192,160,192,  3,224,128,128,128,224,  3,192,160,160,160,192,  3,224,128,
192,128,224,  3,224,128,192,128,128,  3,224,128,160,160,224,  3,160,160,224,
160,160,  3,224, 64, 64, 64,224,  3,224, 32, 32, 32,224,  3,160,160,192,160,
160,  3,128,128,128,128,224,  3,160,224,160,160,160,  3,160,224,224,160,160,
  3, 64,160,160,160, 64,  3,192,160,192,128,128,  3, 64,160,160,224, 96,  3,
192,160,192,192,160,  3, 96,128, 64, 32,192,  3,192, 32, 32, 32, 32,  3,160,
160,160,160,224,  3,160,160,160,160, 64,  5,136,168,168,168, 80,  3,160,160,
 64,160,160,  3,160,160, 64, 64, 64,  3,224, 32, 64,128,224);

Procedure SRMUserFont(const Font: Pointer;const X,Y: Word;
                      const Color: Byte;const S: String); Assembler;
{ Write to a 320*200*256 screen using a variable width font.
  Please note that this is my first ever asm-routine, and
  because of that you'll have to use nullterminated pascalstrings,
  _OR_ you could just hack the code.. :-)  // Eddy.Jansson@saru.ct.se }
var
 FirstChar,
 CharHeight   :Byte;
 CharNr,
 ScreenPTR    :Word;

asm
 push ds

 mov ax,0a000h     { Setup ES:[BX] = X,Y to plot at }
 mov es,ax
 mov bx,x
 mov ax,y
 xchg ah,al
 add bx,ax
 shr ax,2
 add bx,ax

(* Use this instead if you have a Lookuptable:
 mov bx,y          { Setup ES:[BX] = X,Y to plot at }
 add bx,bx
 mov ax,$a000      { easily modified to point to a virtual screen }
 mov es,ax         { Lookup tables rules :-) }
 mov bx,word ptr YTable[bx]
 add bx,x          { Voila! bx = offset onto screen }
*)

 lds di,font
 mov dl,[di]       { height of font goes into dh }
 mov CharHeight,dl
 inc di
 mov dl,[di]
 mov FirstChar,dl
 mov CharNr,0     { Ugh! Character counter, not a very }
                  { good method, but I'm all out of registers :-( }

@nextchar:
 inc CharNr       { also skips lengthbyte! }
 push ds          { This I don't like, pushing and popping. }
 lds si,[S]       { But unfortunately I can't seem to find }
 add si,CharNr    { any spare registers? Intel, can you help? }
 lodsb            { load asciivalue into al }
 pop ds
 cmp al,0         { check for null-termination }
 je @exit         { exit if end of string }

 mov ScreenPTR,BX { save bx }
 mov dh,CharHeight
 xor ah,ah
 mov cl,firstchar { firstchar }
 sub al,cl        { al = currentchar - firstchar }
 mov si,ax        { di = scrap register }
 mul dh           { ax * fontheight }
 add ax,si        { ax + characters to skip }

 lds di,font      { This can be omptimized I think (preserve DI) }
 add di,3         { skip header }
 add di,ax        { Point into structure }
 mov cl,[di]      { get character width }

@nextline:
 mov ch,cl        { ch is the height counter. cl is the original. }
 inc di           { .. now points to bitmap }
 mov dl,[di]      { get bitmap byte }

@nextpixel:
 rol dl,1         { rotate bitmap and prepare for next pixel }
 mov al,dl        { mov bitmap into al for manipulation }
 and al,1         { mask out the correct bit }
 jz @masked       { jump if transperent }
 mov al,color
 mov byte ptr es:[bx],al { Set the pixel on the screen }
@masked:
 inc bx           { increment X-offset }
 dec ch           { are we done? last byte in character? }
 jnz @nextpixel   { nope, out with another pixel }
 add bx,320       { Go to next line on the screen }
 sub bx,cx        { X-alignment fixup }
 dec dh           { are we done with the character? }
 jnz @nextline
 mov bx,ScreenPTR { restore screen offset and prepare for next character }
 add bx,cx
 inc bx           { A little gap between the letters, thank you... }
 jmp @nextchar

@exit:
 pop ds
end;

BEGIN
 asm
  mov ax,$13
  int $10
 end;

{
 Assign(F,'C:\TEMP\SMALLER.BIN');
 Reset(F,1);
 BlockRead(F,Font,FileSize(F),BytesRead);
 Close(F);
}


 { This example font gives you about 80*32 characters/screen }

for BytesRead:=0 to 32 do
 SRMUserFont(@SmallFont,0,BytesRead*6,64-BytesRead,
'12345678901234567890123456789012345678901234567890123456789012345678901234567890'+#0);
 ReadLn;

END.

