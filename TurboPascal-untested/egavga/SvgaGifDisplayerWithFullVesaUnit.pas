(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0215.PAS
  Description: SVGA GIF Displayer with FULL VESA UNIT!
  Author: LIONEL CORDESSES
  Date: 05-26-95  23:22
*)

{
    I modified  the unit written  by Sean Wenzel in order  to speed
up the  decoding of a picture . I wrote several parts using the ASM
capability of BP 7.0,but I did not change the NextCode procedure at
the beginning.
    As I was interested in any improvement,I decided to use an external
procedure written in assembly language (named ASMGIF3.ASM) : I was
a little bit disappointed:it is  not faster (not noticeable ...).

    You can find :
      - GIFUTIL9.PAS :the new unit ONLY for 256 colors !!!!!!
      - GIFTST.PAS   :an example based on the one written by Sean Wenzel.
      - ASMGIF3.ASM  :the ASM source of NextByte.

  You can use,modified an distribute this source as long as credit is given.


                                      Lionel CORDESSES
                                      from FRANCE.
                                      November 1994
    E-Mail:
      cordesse@opgc.univ-bpclermont.fr



 "The Graphics Interchange Format(c) is the Copyright property of
  CompuServe Incorporated. GIF(sm) is a Service Mark property  of
  CompuServe Incorporated."
}

unit GifUtil9;


{$R-} { range checking off }  { Put them on if you like but it slows down }
{$S-} { stack checking off }  { The decoding  (almost doubles it!) }
{$I-} { i/o checking off }

interface


var status:byte;

procedure general(nom:string);


implementation

uses usvesa, Crt;
type
 TDataSubBlock = record
  Size: byte;     { size of the block -- 0 to 255 }
  Data: array[1..255] of byte; { the data }
 end;

const
 BlockTerminator: byte = 0; { terminates stream of data blocks }

type
 THeader = record
  Signature: array[0..2] of char; { contains 'GIF' }
  Version: array[0..2] of char;   { '87a' or '89a' }
 end;

 TLogicalScreenDescriptor = record
  ScreenWidth: word;              { logical screen width }
  ScreenHeight: word;  { logical screen height }
  PackedFields: byte;     { packed fields - see below }
  BackGroundColorIndex: byte;     { index to global color table }
  AspectRatio: byte;      { actual ratio = (AspectRatio + 15) / 64 }
 end;

const
{ logical screen descriptor packed field masks }
 lsdGlobalColorTable = $80;  { set if global color table follows L.S.D. }
 lsdColorResolution = $70;               { Color resolution - 3 bits }
 lsdSort = $08;
{ set if global color table is sorted - 1 bit }
 lsdColorTableSize = $07;                { size of global color
table - 3 bits }

      { Actual size =
2^value+1    - value is 3 bits }

type
 TColorItem = record     { one item a a color table }
  Red: byte;
  Green: byte;
  Blue: byte;
 end;

 TColorTable = array[0..255] of TColorItem;      { the color table }

const
 ImageSeperator: byte = $2C;

type
 TImageDescriptor = record
  Seperator: byte;                         { fixed value
of ImageSeperator }
  ImageLeftPos: word; {Column in pixels in respect to
left edge of logical screen }
  ImageTopPos: word;{row in pixels in respect to top of
logical screen }
  ImageWidth: word;       { width of image in pixels }
  ImageHeight: word;      { height of image in pixels }
  PackedFields: byte; { see below }
 end;
const
 { image descriptor bit masks }
  idLocalColorTable = $80; { set if a local color table follows }
  idInterlaced = $40;                      { set if image
is interlaced }
  idSort = $20;
 { set if color table is sorted }
  idReserved = $0C;                                {
reserved - must be set to $00 }
  idColorTableSize = $07;  { size of color table as above }

 Trailer: byte = $3B;    { indicates the end of the GIF data stream }

{ other extension blocks not currently supported by this unit
 - Graphic Control extension
 - Comment extension           I'm not sure what will happen if these blocks
 - Plain text extension        are encountered but it'll be interesting
 - application extension }

const
 ExtensionIntroducer: byte = $21;
 MAXSCREENWIDTH = 800;

type
 TExtensionBlock = record
  Introducer: byte;                               { fixed
value of ExtensionIntroducer }
  ExtensionLabel: byte;
  BlockSize: byte;
 end;

 PCodeItem = ^TCodeItem;
 TCodeItem = record
  Code1, Code2: byte;
 end;

const
 MAXCODES = 4095;        { the maximum number of different codes
0 inclusive }



const
{ error constants }
 geNoError = 0;                          { no errors found }
 geNoFile = 1;         { gif file not found }
 geNotGIF = 2;         { file is not a gif file }
 geNoGlobalColor = 3;  { no Global Color table found }
 geImagePreceded = 4;  { image descriptor preceeded by other unknown data }
 geEmptyBlock = 5;                       { Block has no data }
 geUnExpectedEOF = 6;  { unexpected EOF }
 geBadCodeSize = 7;    { bad code size }
 geBadCode = 8;                          { Bad code was found }
 geBitSizeOverflow = 9; { bit size went beyond 12 bits }

type
  stream_ptr=^stream_type;
  stream_type=record
  Header: THeader;
                                        { gif file header }
  LogicalScreen: TLogicalScreenDescriptor;  { gif screen descriptor }
              end;


var fichier:file;
    stream:stream_type;
    TableSize: word;   { number of entrys in the color table }
    GlobalColorTable: TColorTable;            { global color table }
    LocalColorTable: TColorTable;             { local color table }
    ImageDescriptor: TImageDescriptor;        { image descriptor }
    UseLocalColors: boolean;                  { true if local colors in use }
    Interlaced: boolean;                      { true if image is interlaced }
    InterlacePass: byte;                      { interlace pass number }
    LZWCodeSize: byte;                        { minimum size of the LZW
codes in bits }
    BitsLeft,BytesLeft: integer;{ bits left in byte - bytes left in block }
    BadCodeCount: word;          { bad code counter }
    CurrCodeSize: integer;       { Current size of code in bits }
    ClearCode: integer;          { Clear code value }
    EndingCode: integer;         { ending code value }
    Slot: word;                  { position that the next new code is to be
added }
    TopSlot: word;               { highest slot position for the
current code size }
    HighCode: word;              { highest code that does not require decoding
}
    NextByte: integer;           { the index to the next byte in the
datablock array }
    CurrByte: byte;              { the current byte }
    CurrentX, CurrentY: integer; { current screen locations }
    ImageData: TDataSubBlock;    { variable to store incoming gif data }
    DecodeStack: array[0..MAXCODES] of byte; { stack for the decoded codes }
    Prefix: array[0..MAXCODES] of word; { array for code prefixes }
    Suffix: array[0..MAXCODES] of byte; { array for code suffixes }
    LineBuffer: array[0..MAXSCREENWIDTH] of byte; { array for buffer line
output }
    table:array[0..767] of byte;
    indice_sp:integer;           { index to the decode stack }
    indice:word;
    Retour: longint;             { temporary return value }

{$L asmgif3}

function Power(A, N: integer): integer;       { returns A raised to the
power of N }
begin
 Power := 1 shl n;
end;

procedure TGif_Error(What: integer);
begin
 Status := What;
        if What=geNoFile then halt(1);
end;


{ TGif }
procedure TGif_Init(AGIFName: string);
  begin
 if Pos('.',AGifName) = 0 then     { if the filename has no
extension add one }

  AGifName := AGifName + '.gif';
{ New(stream,  2048);}
        assign(fichier,agifname);
        {$i-}
        reset(fichier,1);
        if ioresult<>0 then tgif_Error(geNoFile);
        blockRead(fichier,stream, sizeof(Theader));   { read the header }
 if stream.Header.Signature <> 'GIF' then tgif_Error(geNotGIF);
                            { is vaild signature }
 blockRead(fichier,stream.LogicalScreen, sizeof(TLogicalScreenDescriptor));
 if stream.LogicalScreen.PackedFields and lsdGlobalColorTable =
lsdGlobalColorTable then
 begin
  TableSize :=
trunc(Power(2,(stream.LogicalScreen.PackedFields and lsdColorTableSize)+1));
  blockread(fichier,GlobalColorTable,
TableSize*sizeof(TColorItem)); { read Global Color Table }
 end
 else
  tgif_Error(geNoGlobalColor);
 blockread(fichier,ImageDescriptor, sizeof(ImageDescriptor)); {
read image descriptor }
 if ImageDescriptor.Seperator <> ImageSeperator then
        { verify that it is the descriptor }
  tgif_Error(geImagePreceded);
 if ImageDescriptor.PackedFields and idLocalColorTable =
idLocalColorTable then
 begin
          { if local color table }
  TableSize :=
trunc(Power(2,(ImageDescriptor.PackedFields and idColorTableSize)+1));
  blockread(fichier,LocalColorTable,
TableSize*sizeof(TColorItem)); { read Local Color Table }
  UseLocalColors := True;
 end
 else
  UseLocalColors := false;
 if ImageDescriptor.PackedFields and idInterlaced = idInterlaced then
 begin
  Interlaced := true;
  InterlacePass := 0;
 end;
 Status := 0;
        writeln('nb coul: ',tablesize);
  end;

procedure TGif_Done;
  begin
        close(fichier);
  end;


procedure InitCompressionStream;
var
 I: integer;
        n:byte;
begin
                            { Initialize the graphics display }
 blockread(fichier,LZWCodeSize, sizeof(byte));{ get minimum code size }
 if not (LZWCodeSize in [2..9]) then     { valid code sizes 2-9 bits }
  tgif_Error(geBadCodeSize);

 CurrCodeSize := succ(LZWCodeSize); { set the initial code size }
 ClearCode := 1 shl LZWCodeSize;    { set the clear code }
 EndingCode := succ(ClearCode);     { set the ending code }
 HighCode := pred(ClearCode);                     { set the
highest code not needing decoding }
 BytesLeft := 0;                    { clear other variables }
 BitsLeft := 0;
 CurrentX := 0;
 CurrentY := 0;
end;
{$f-}
procedure TGif_ReadSubBlock;
begin
 blockread(fichier,ImageData.Size, sizeof(ImageData.Size)); {
get the data block size }
 if ImageData.Size = 0 then tgif_Error(geEmptyBlock); { check
for empty block }
 blockread(fichier,ImageData.Data, ImageData.Size);   { read in the block }
 NextByte := 1;                                  { reset next byte }
 BytesLeft := ImageData.Size;
                                        { reset bytes left }
end;

const
 CodeMask: array[0..12] of longint = (  { bit masks for use with Next code }
  0,
  $0001, $0003,
  $0007, $000F,
  $001F, $003F,
  $007F, $00FF,
  $01FF, $03FF,
  $07FF, $0FFF);

{$f-}
function NextCode: word;external; { returns a code of the proper bit size }

procedure write_pal(var pal;start,quant:word);
  begin
    asm
      push ds
      lds si,pal
      mov dx,3c8h
      cld
      mov cx,quant
      mov bx,start
      @deb1:
        mov al,bl
        out dx,al
        inc dx
        lodsb
        out dx,al
        lodsb
        out dx,al
        lodsb
        out dx,al
        dec dx
        inc bl
      loop @deb1
      pop ds
    end;
  end;


procedure InitGraphics;
var
        n:byte;
        x,y,i:word;
begin
        { you can change the $101 value for other VESA modes }
        n:=setmode($101);
 if n =0  then
 begin
  Writeln('vesa error ');
  Halt(1);
 end;

 { the following loop sets up the RGB palette }
        x:=0;
 if not UseLocalColors then
          begin
            for I := 0 to TableSize - 1 do
              begin
               table[x]:=GlobalColorTable[I].Red div 4;
               inc(x);
               table[x]:=GlobalColorTable[i].Green div 4;
               inc(x);
               table[x]:=GlobalColorTable[I].Blue div 4;
               inc(x);
             end;
             write_pal(table[0],0,tablesize);
          end
 else
          begin
            x:=0;
            for I := 0 to TableSize - 1 do
              begin
               table[x]:=localColorTable[I].Red div 4;
               inc(x);
               table[x]:=localColorTable[i].Green div 4;
               inc(x);
               table[x]:=localColorTable[I].Blue div 4;
               inc(x);
             end;
             write_pal(table[0],0,tablesize);
           end;
{
       for x:=0 to 255 do
         for y:=0 to 255 do
           setpix(x,y,x);}
end;


procedure DrawLine;
var
 I: integer;

begin
        if not write_fast(0,CurrentY,ImageDescriptor.ImageWidth,
          LineBuffer[0]) then
 for I := 0 to ImageDescriptor.ImageWidth do
  setpix(I, CurrentY, LineBuffer[I]);
 inc(CurrentY);

 if InterLaced then     { Interlace support }
 begin
  case InterlacePass of
   0: CurrentY := CurrentY + 7;
   1: CurrentY := CurrentY + 7;
   2: CurrentY := CurrentY + 3;
   3: CurrentY := CurrentY + 1;
  end;
  if CurrentY >= ImageDescriptor.ImageHeight then
  begin
   inc(InterLacePass);
   case InterLacePass of
    1: CurrentY := 4;
    2: CurrentY := 2;
    3: CurrentY := 1;
   end;
  end;
 end;
end;

{ this procedure initializes the graphics mode and actually decodes the
 GIF image }
procedure Decode(Beep: boolean);


{ local procedure that decodes a code and puts it on the decode stack }
procedure DecodeCode(var code:word);assembler;
  asm
      les di,code
      mov bx,word ptr [es:di]
      mov si,indice_sp
      cmp bx,HighCode
      jbe @@fin

    @@boucle:
      mov al,[offset word ptr Suffix+bx]  { al:=suffix[code] }
      mov [Offset word ptr DecodeStack+si],al      { decodestack:=al }
      inc si

      shl bx,1   { array of  word }
      mov bx,[Offset word ptr Prefix+bx]    {code:=prefix[code }
      cmp bx,word ptr HighCode
      ja @@boucle

    @@fin:
      mov [Offset word ptr DecodeStack+si],bx

      inc si
      mov indice_sp,si
      mov word ptr [es:di],bx
  end;


var
 TempOldCode, OldCode: word;
 BufCnt: word;           { line buffer counter }
 Code, C: word;
 CurrBuf: word;  { line buffer index }
begin
 InitGraphics;             { Initialize the graphics mode and RGB palette }
 InitCompressionStream;    { Initialize decoding paramaters }
 OldCode := 0;
 indice_sp := 0;
 BufCnt := ImageDescriptor.ImageWidth; { set the Image Width }
 CurrBuf := 0;

 C := NextCode;                                          { get
the initial code - should be a clear code }
 while C <> EndingCode do  { main loop until ending code is found }
 begin
  if C = ClearCode then   { code is a clear code - so clear }
  begin
   CurrCodeSize := LZWCodeSize + 1;{ reset the code size }
   Slot := EndingCode + 1;
        { set slot for next new code }
   TopSlot := 1 shl CurrCodeSize;  { set max slot number }
   while C = ClearCode do
    C := NextCode;                  { read
until all clear codes gone - shouldn't happen }
   if C = EndingCode then
   begin
    tgif_Error(geBadCode);   { ending code
after a clear code }
    break;
                { this also should never happen }
   end;
   if C >= Slot { if the code is beyond preset
codes then set to zero }
    then c := 0;
   OldCode := C;
   DecodeStack[indice_sp] := C;
               { output code to decoded stack }
   inc(indice_sp);
                         { increment decode stack index }
  end
  else   { the code is not a clear code or an ending code
so it must }
  begin  { be a code code - so decode the code }
   Code := C;
   if Code < Slot then     { is the code in the table? }
   begin
    DecodeCode(Code);
                { decode the code }
    if Slot <= TopSlot then
    begin                             { add
the new code to the table }
                                 Suffix[Slot] := Code;
        { make the suffix }
     PreFix[slot] := OldCode;
{ the previous code - a link to the data }
     inc(Slot);
                                        { increment slot number }
     OldCode := C;
                                { set oldcode }
    end;
    if Slot >= TopSlot then { have reached
the top slot for bit size }
    begin                   { increment code bit size }
     if CurrCodeSize < 12 then { new
bit size not too big? }
     begin
      TopSlot := TopSlot shl
1;       { new top slot }
      inc(CurrCodeSize)
                                { new code size }
     end
     else

tgif_Error(geBitSizeOverflow); { encoder made a boo boo }
    end;
   end
   else
   begin           { the code is not in the table }
    if Code <> Slot then
{ code is not the next available slot }
     tgif_Error(geBadCode);  { so error out }

    { the code does not exist so make a new
entry in the code table
     and then translate the new code }
    TempOldCode := OldCode;  { make a copy
of the old code }
    while OldCode > HighCode do { translate
the old code and place it }
    begin
{ on the decode stack }
     DecodeStack[indice_sp] :=
Suffix[OldCode]; { do the suffix }
     OldCode := Prefix[OldCode];
    { get next prefix }
    end;
    DecodeStack[indice_sp] := OldCode;
{ put the code onto the decode stack }


{ but DO NOT increment stack index }
    { the decode stack is not incremented
because because we are only
     translating the oldcode to get
the first character }
    if Slot <= TopSlot then
    begin                 { make new code entry }
     Suffix[Slot] := OldCode;
         { first char of old code }
     Prefix[Slot] := TempOldCode; {
link to the old code prefix }
     inc(Slot);                   {
increment slot }
    end;
    if Slot >= TopSlot then { slot is too big }
    begin                   { increment code size }
     if CurrCodeSize < 12 then
     begin
      TopSlot := TopSlot shl
1;       { new top slot }
      inc(CurrCodeSize)
                                { new code size }
     end
     else
      tgif_Error(geBitSizeOverFlow);
    end;
    DecodeCode(Code); { now that the table
entry exists decode it }
    OldCode := C;     { set the new old code }
   end;
  end;
  { the decoded string is on the decode stack so pop it
off and put it
   into the line buffer }

                        asm
                          mov cx,BufCnt
                          mov si,CurrBuf
                          mov bx,indice_sp
                          cmp bx,0
                          je @@fin

                        @@boucle:
                          dec bx
                          mov al,[offset byte ptr DecodeStack+bx]
                          mov  [offset byte ptr LineBuffer+si],al
                          inc si
                          dec cx
                          jnz @@suite
                                  pusha
                                  push di
                                  call DrawLine
                                  pop di
                                  popa
                                  mov si,0
                                  mov cx,[offset ImageDescriptor.ImageWidth]
                        @@suite:
                          cmp bx,0
                          ja @@boucle
                        @@fin:
                          mov BufCnt,cx
                          mov indice_sp,bx
                          mov CurrBuf,si
                        end;

 C := NextCode;  { get the next code and go at is some more }
 end;            { now that wasn't all that bad was it? }
 if Beep then
  if Status = 0 then
  begin
   Sound(200);     { Beep if status is ok }
   Delay(0);
   NoSound;
  end
  else
  begin
   Sound(1100); { Boop if status is not ok }
   Delay(0);
   NoSound;
  end;
end;

procedure general(nom:string);
  begin
    tgif_init(nom);
    decode(true);
    tgif_done;
  end;

end.

{
cut here
----------------------------------------------------------------------------
}

program Gift;
{
 Gifutil9 sample program
 November 1994

}

uses GifUtil9, CRT, Dos;




var
 A: string;
 Hours, Minutes, Seconds, Sec100: word;
 H, M, S, S100: word;
        tps1,tps2:longint;

function donne_heure:longint;
var heure,minute,seconde,sec100:word;
  begin
    gettime(heure,minute,seconde,sec100);
    donne_heure:=heure*3600*100+minute*60*100+seconde*100+sec100;
  end;

begin
 Writeln('Sample program for using GIFUTIL9.PAS unit');
        Writeln;
        Writeln('Based on code written by Sean Wenzel ');
        Writeln('Modified by Lionel Cordesses ( FRANCE )');
        Writeln('Only tested with 256 colors GIF pictures ...');
 Writeln('Press ENTER ');
        Readln;


 if ParamCount <> 1 then
 begin
  Writeln('use: gift <gifname>[.gif] to run...');
  Exit;
 end;
 GetTime(Hours, Minutes, Seconds, Sec100);
        tps1:=donne_heure;
  general(ParamStr(1));
        tps2:=donne_heure;
 GetTime(H, M, S, S100);
        readln;
        textmode(co80);


        writeln('time: ',tps2-tps1);
 while not(KeyPressed) do;

 writeln('"The Graphics Interchange Format(c) is the Copyright property of');
 writeln('CompuServe Incorporated. GIF(sm) is a Service Mark property of ');
 writeln('CompuServe Incorporated."');
end.

{ cut here
-----------------------------------------------------------------------------
}
;ASMGIF3 for  GIFUTILxx.pas   Lionel CORDESSES (November 1994 )

.model large,pascal

data segment public
data ends

radix 10
P386
NOSMART

dataseg
  extrn NextByte:word;
  extrn BitsLeft:word;
  extrn BytesLeft:word;
  extrn ImageData:near ptr dword;
  extrn CurrByte:byte;
  extrn retour:dword;
  extrn CurrCodeSize:word;
  extrn CodeMask:near ptr dword;

.code

extrn tgif_ReadSubBlock


NextCode  PROC near
public NextCode

       mov ax,[BitsLeft]
       cmp ax,0
       jg @@suite1

       mov ax,[BytesLeft]
       cmp ax,0
       jg @@suite2

;         if buffer is empty
       pusha
       push di
       call near ptr Tgif_ReadSubBlock
       pop di
       popa

    @@suite2:
       mov bx,[NextByte]

       mov al,byte ptr [offset ImageData+bx] ;
       mov [CurrByte],al

       inc bx
       mov [NextByte],bx
       mov [BitsLeft],8
       dec [BytesLeft]

    @@suite1:
       mov eax,0
       mov al,[CurrByte]
       mov cx,8
       mov dx,[BitsLeft]
       sub cx,dx
       shr eax,cl
       mov cx,dx          ;save BitsLeft in CX
       mov edx,eax
       mov bx,[NextByte]

    @@while:
       cmp [CurrCodeSize],cx
       jng @@fin2

       cmp [BytesLeft],0
       jg @@suite4
;         if buffer is empty
       pusha
       push di
       call near ptr Tgif_ReadSubBlock
       pop di
       popa
       mov bx,[NextByte]

    @@suite4:

       mov eax,0

       mov al,byte ptr [offset ImageData+bx] ;
       mov [CurrByte],al
       inc bx


       shl eax,cl
       or edx,eax

       add cx,8
       dec [BytesLeft]

       jmp @@while

    @@fin2:
       mov [NextByte],bx
       mov bx,[CurrCodeSize]
       sub cx,bx
       mov [BitsLeft],cx
       shl bx,2               ; longint = 4 Bytes !!!!
       lea di,[CodeMask]
       mov eax,[di+bx]
       and edx,eax
;       mov [retour],edx
       mov ax,dx
       ret


;tasm_shl endp
NextCode endp

end

{ cut here
-----------------------------------------------------------------------------
  Here is the ASMGIF3.OBJ file in .XX format
}


*XX3402-001268-171194--72--85-08325-----ASMGIF3.OBJ--1-OF--1
U02+5oAuL27EL2l7HplHJYR-L3J5GINQEJBBFoZ4Amt-IoogW0+++++QJ5JmMawUELBnNKpW
P4Jm60-KNL7nOKxi61AiAda67k-+uJ6yMFoTEndQEZ-QH2ZDL3BKFo3QJIR7FZl-Iop5GIMn
9Y3HHSS6+k-+uImK+U++O6U1+20VZ7MH++l-Iop5GIMnLpF3K3E2Eox2FNuM-k-6eU+0+k3d
ZUk+-Jx2EJF--2F-J250a+Q+G+++-+I-1tM4++F2EJF-FdU5+4U+++M-+T4K0++4F2RGHpJE
Wtc2++Tz+ZeA0k+6HaJsR27tR4I+9cU2+21U0YeA0k+6EaZoQolZNbE+F6U2+21U0YeA1++7
EbZoNLBANKNo+Aq6-+-+s+d8X+k+0IZhMKRZF43oME+0W+E+EC+8Gck9++V1RL7mEbZoNE+l
W+E+EC+6H6k7++NmNLFjRL6+l6U2+21U12WA1k+AErJmQYBjN4JHOLdZ+8S6-+-+s+d8X+g+
02BjN4JBMLBf+3e6-+-+s+d8X-E+2LFbOKNTIaJVN3BpMY7gPqBf+9K6-+-+s+d8Y+w+++26
HaJsR2BjN4I++++yW+I+EC2R+1K6-+-+cU4FW+I+ECc2+2K60+-+slU+-U+e-MU7+21X4E++
+0E+1sU7+21X4U+++0E-1MU9+21X4k+++0A++++AW+g+ECAQ++++6k+2++S60k-+slo++++X
++2+0MU9+21X5U+++0A+-E+2W+c+ECAT++6+3Ek+0MUc+21c+-x1CZl0I3lAGIxQIpN5EJlJ
FoZ4L23HHIR7FXAiEJBBIXtV5SSIsk+++G+++++V++A+6U+4+0E+0U+Z++o+7U+E+0Y+3++e
+-I+8k+K+0k+4E+h+-c+A++P+16+5k+n+0A+BE+a+1M+7k+r+0g+C++l+1g+BE+w+1g+DE+y
+1s+EE+z+2I+E+-5+22+GU-0+2k+Ek-D+2M+Ik-5+3Q+GE-P+2c+M+-A+4E+HE-Z+2s+NU-D
+4Y+I+-e+32+Ok-J+4w+Jk-p+3U+SE-N+5k+L+-x+3o+U+-T+6A+M+04+46+WU-Z+6k+NU0E
+4Q+Z+-c+7M+OE0O+4c+bE-f+82+P+0Y+4s+dk-j+8Y+ZMUG+21a02-+IpJ7J2Im4E+++Fg+
lsUG+21a02-+IpJ7J2Il4E+++HI+fcUF+21a-o-+JoV7H2IN+++-Ik1IW-6+ECM6E2-HJIZI
FHEN+++-Pk-lW-++ECM4E2-4GIsm4E+++Mk+-sUG+21a02t3K3F1HoF35E+++E++k80i++2+
+82++1o++5whY70V+++x++-z0N0EM3Tc++-TMMgS++08Vk++cU++EsYS++15-U++0+1z1U++
NfU+++++c+++iEU+WlM++0j8NhDcWwdaWx095U++CEs++5snY701DU+++5wBY7-UJyU++3xV
Wls++4Os+++++6e5++0W++-1NhDUNUjEUw26zks++Cj5WFs++6gS+++fmsYC++1-sk8BDU++
Ncg-NWDEWw91Jdlo+AE-3U20l+gK+EC23kM-0QER3U2-l02K+EH27-M--QEd3U2-l0oK+E92
AlM-+wEw3U23l2AK+E92IFM-+QFJ3U25l3oK+EC2NkM-0QFh3U2-l5QK+EH2SVM--QG63U21
l6sK+E52YVM--wGM3U20l7wK+EVLWU6++5E+
***** END OF BLOCK 1 *****

{ cut here
----------------------------------------------------------------------------
}

unit usvesa;
{
****************************************************************************

      Here is an other VESA unit !!!!!!

      It is based on various sources ( DVPEG,John Bridges VGAKIT,
    SWAG an many others ).
      You can use,modified an distribute this source as long as credit
    is given.


    Supported modes:
      - 256 colors
      - 32768 colors
      - 16 millions colors


    The demo program for this unit is DemoVesa.

                                              Lionel Cordesses
                                              From FRANCE.
                                              November 1994

****************************************************************************
}

{$f+}
interface

uses dos,crt;


var

  use_16,use_32:boolean;
  x_size:word;

function  write_fast(x1,y,x2:word;var entree):boolean;
procedure getpix_16(x,y:word;var rouge,vert,bleu:byte);
procedure find_black(max_color:word;var black,white:byte);
function  setmode(mode:word):byte;  { return 0 if bad, 1 if OK }
procedure setpix(x,y,col:word);
procedure setpix_16(x,y:word;rouge,vert,bleu:byte);
function  getpix(x,y:word):byte;
procedure wrtxt(x,y:word;txt:string);{write TXT to pos (X,Y)}







implementation


var
  reg:registers;
  vgran,curbank:word;
  add_bank:procedure;
  tps1,tps2:longint;
  heure,minute,seconde,sec100:word;





{$ifdef msdos}
procedure setbank(bank:byte);far;
var banque:word;
  begin
    banque:=bank*longint(64) div vgran;
    asm
      mov bl, 0
      mov dx, banque
      call  [add_bank]
    end;
    curbank:=bank;
end;

{$else}

procedure setbank(bank:byte{word});far;
var banque:word;

  begin
             reg.ax:=$4f05;
             reg.bx:=0;
             reg.dx:=bank*longint(64) div vgran;

             intr($10,reg);
             reg.ax:=$4f05;
             reg.bx:=1;
             intr($10,reg);

  curbank:=255;{bank;}
end;
{$endif}

function setvesa(mode:word):byte;

  begin
    asm
     mov ax,4F02h
     mov bx,mode
     int 10h
     sub ax,004Fh
(*     mov al,0
     cmp ah,1   { if ah=1 that is bad ==>false }
     je  @fin
     mov al,1  {false }
   @fin:*)

     mov @RESULT,al
   end;
{   reg.ax:=$4f02;
   reg.bx:=mode;
   intr($10,reg);
   setvesa:=reg.al;}
{  textmode(co80);
  write(reg.ah,' ',reg.al);
  readln;}

  end;



{$ifdef msdos}
function setmode(mode:word):byte;  { 0 if bad,1 if OK}
type type_vesarec=array[0..555] of byte;
     ves_ptr=^type_vesarec;

type
  long=record
         lo,hi:word;
       end;

var pro:byte;
    vesarec:ves_ptr;

    vesa_info:record
      debut:array[0..3] of byte;
      granularite:word;
      winsize,
      winaseg,
      winbseg:word;
      add_proc:procedure;
      bytes:word;
      width,
      height:word;
      reste:array[0..250] of byte;
    end;


  begin
    setmode:=1;
    getmem(vesarec,556);
    pro:=setvesa(mode);
    fillchar(vesarec^[0],256,0); { set all to zero  }

      reg.ax:=$4f01;
      reg.cx:=mode;
      reg.es:=long(vesarec).hi;
      reg.di:=long(vesarec).lo;

      intr($10,reg);
      if reg.ah=0 then
        begin
          setmode:=1;
          pro:=1;
        end
      else
        begin
          setmode:=0;
          pro:=0;
        end;

      move(vesarec^[0],vesa_info.debut[0],256);
      if reg.al=0 then
        begin
          setmode:=1;
          pro:=1;
        end;
      vgran:=vesa_info.granularite;
      x_size:=vesa_info.width;                 { nb pt per lines }
      add_bank:=vesa_info.add_proc;        { change bank far ptr }

    freemem(vesarec,556);

    use_16:=false;
    use_32:=false;
    if mode=$112 then use_16:=true;
    if mode=$110 then use_32:=true;




  end;


{$endif}

procedure setpix(x,y,col:word);assembler;
var  decalage:word;
      asm
 mov bx,x
 mov ax,y {removed all range checking on x,y for speed}
 mul x_size {640 bytes wide in most cases}
 add bx,ax
 adc dx,0
 mov ax, dx { what a $#%%# stupid microprocessor}
 adc ax, 0

        {mov provi,al}   { bank  }
        mov decalage,bx
        cmp ax,curbank
        jz @nonew
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { here ax = bank }
        @nonew:

          mov bx,col
          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov [es:di],bl
      end;

procedure getpix_16(x,y:word;var rouge,vert,bleu:byte);assembler;
var l:longint;
    provi:byte;
    couleur,decalage:word;

      asm
        mov al,use_16
        cmp al,0
        je @v32000

 mov bx,x
        mov ax,bx
        shl bx,1
        add bx,ax       { x*3 }
 mov ax,y {removed all range checking on x,y for speed}
        shl ax,1
        add ax,y        { y*3 }
 mul x_size {640 bytes wide in most cases}
 add bx,ax
 adc dx,0
 mov ax, dx { what a $#%%# stupid microprocessor}
 adc ax, 0

        mov provi,al   { bank  }
        mov decalage,bx
        cmp ax,curbank
        jz @nonewa
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { here ax= bank }
        @nonewa:

          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov bl,[es:di]
          les di,bleu
          mov byte ptr [es:di],bl

        add decalage,1
        mov ah,0
        mov al,provi
        adc ax,0
        mov provi,al
        cmp ax,curbank
        jz @nonew1
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   {  ax = bank }
        @nonew1:

          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov bl,[es:di]
          les di,vert
          mov byte ptr [es:di],bl

        add decalage,1
        mov ah,0
        mov al,provi
        adc ax,0
        cmp ax,curbank
        jz @nonew2
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   {  ax= bank }
        @nonew2:

          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov bl,[es:di]
          les di,rouge
          mov byte ptr [es:di],bl

          jmp @fin

      @v32000:
 mov bx,x
 mov ax,y {removed all range checking on x,y for speed}
 mul x_size {640 bytes wide in most cases}
 add bx,ax
 adc dx,0
 mov ax, dx { what a $#%%# stupid microprocessor}
 shl ax, 1
 shl bx, 1
 adc ax, 0   { pour untiliser un eventuel carry
                          positionne par precedent ADD }

        mov provi,al   { bank  }
        mov decalage,bx
        cmp ax,curbank
        je @nonew
{        mov ah,0}
        push cs
        push ax
        call  far ptr setbank   {  ax = bank }
        @nonew:


        mov ax,sega000
        mov es,ax
        mov di,decalage
        mov bx,[es:di]
        mov al,bl
        and al,31
        shl al,3
        les di,bleu
        mov byte ptr [es:di],al
        shr bx,5
        mov al,bl
        and al,31
        shl al,3
        les di,vert
        mov byte ptr [es:di],al
        shr bx,5
        mov al,bl
        and al,31
        shl al,3
        les di,rouge
        mov byte ptr [es:di],al

        @fin:
      end;



procedure setpix_16(x,y:word;rouge,vert,bleu:byte);
var l:longint;
    provi:byte;
    couleur,decalage:word;
  begin
    if use_16=true then
      asm

 mov bx,x
        mov ax,bx
        shl bx,1
        add bx,ax       { x*3 }
 mov ax,y {removed all range checking on x,y for speed}
        shl ax,1
        add ax,y        { y*3 }
 mul x_size {640 bytes wide in most cases}
 add bx,ax
 adc dx,0
 mov ax, dx { what a $#%%# stupid microprocessor}
 adc ax, 0

        mov provi,al   { bank  }
        mov decalage,bx
        cmp ax,curbank
        jz @nonew
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { ax= bank }
        @nonew:

          mov bl,bleu
          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov [es:di],bl

        add decalage,1
        mov ah,0
        mov al,provi
        adc ax,0
        mov provi,al
        cmp ax,curbank
        jz @nonew1
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   {  ax= bank }
        @nonew1:

          mov bl,vert
          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov [es:di],bl

        add decalage,1
        mov ah,0
        mov al,provi
        adc ax,0
        cmp ax,curbank
        jz @nonew2
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { ax= bank }
        @nonew2:

          mov bl,rouge
          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov [es:di],bl


      end;

  if use_32=true then
      asm
 mov bx,x
 mov ax,y {removed all range checking on x,y for speed}
 mul x_size {640 bytes wide in most cases}
 add bx,ax
 adc dx,0
 mov ax, dx { what a $#%%# stupid microprocessor}
 shl ax, 1
 shl bx, 1
 adc ax, 0   { pour untiliser un eventuel carry
                          positionne par precedent ADD }

        mov provi,al   { bank  }
        mov decalage,bx
        cmp ax,curbank
        je @nonew
{        mov ah,0}
        push cs
        push ax
        call  far ptr setbank   {  ax= bank }
        @nonew:


        mov al,rouge
        shr al,3
        mov ah,0
        shl ax,10
        mov bl,vert
        shr bl,3
        mov bh,0
        shl bx,5
        add ax,bx
        mov bl,bleu
        shr bl,3
        mov bh,0
        add bx,ax
        mov ax,sega000
        mov es,ax
        mov di,decalage
        mov [es:di],bx
      end;
  end;

Procedure Move16(Var Source,Dest;Count:Word); Assembler;
Asm
  PUSH DS
  LDS SI,SOURCE
  LES DI,DEST
  MOV AX,COUNT
  MOV CX,AX
  SHR CX,1
  REP MOVSW
  TEST AX,1
  JZ @end
  MOVSB
@end:POP DS
end;


function write_fast(x1,y,x2:word;var entree):boolean;

var coord1,coord2:longint;
    couleur:byte;
  begin
    write_fast:=false;
    coord1:=longint(y)*longint(x_size)+x1;
    coord2:=coord1+longint((x2-x1)+1);
    if (coord1 shr 16)<> curbank then  setbank(coord1 shr 16);
    if (coord1 shr 16)=(coord2 shr 16) then
      begin
         move16(entree,mem[sega000:(coord1 mod 65536)],(x2-x1+1));
         write_fast:=true;
      end;
  end;


function donne_heure:longint;
var heure,minute,seconde,sec100:word;
  begin
    gettime(heure,minute,seconde,sec100);
    donne_heure:=heure*3600*100+minute*60*100+seconde*100+sec100;
  end;




procedure find_black(max_color:word;var black,white:byte);
var luminance,n:byte;
    reg:registers;
    table:array[0..767] of byte;
    i,x,y:word;

  begin
       with reg do
         begin
           ah:=$10;
           al:=$17;
           bx:=0;
           cx:=max_color;
           es:=seg(table);
           dx:=ofs(table);
           intr($10,reg);
         end;
    i:=0;
    white:=0;
    black:=255;
    for n:=0 to max_color-1 do
      begin
        luminance:=round(((0.59*table[i+1])+(0.3*table[i])+
        (0.11*table[i+2])));
        if luminance>white then
          begin
            white:=luminance;
            x:=n;
          end;
        if luminance<black then
          begin
            black:=luminance;
            y:=n;
          end;
        inc(i,3);
      end;
    i:=0;
    black:=y;
    white:=x;
  end;


procedure wrtxt(x,y:word;txt:string);{write TXT to pos (X,Y)}
type
  pchar=array[char] of array[0..15] of byte;
var
  p:^pchar;
  c:char;
  i,j,z,b:integer;
  noir,blanc:byte;
begin
  reg.ax:=$1130;
  reg.bh:=6;
  intr($10,reg);
  p:=ptr(reg.es,reg.bp);
  if (use_16=false) and (use_32=false) then
    find_black(256,noir,blanc)
  else
    begin
      noir:=0;
      blanc:=255;
    end;
      for z:=1 to length(txt) do
      begin
        c:=txt[z];
        for j:=0 to 15 do
        begin
          b:=p^[c][j];
          for i:=x+7 downto x do
          begin
            if (use_16=false) and (use_32=false)  then
              begin
                if odd(b) then setpix(i,y+j,blanc)
                          else setpix(i,y+j,noir);
              end
            else
              begin
                if odd(b) then setpix_16(i,y+j,blanc,blanc,blanc)
                          else setpix_16(i,y+j,noir,noir,noir);
              end;

            b:=b shr 1;
          end;
        end;
        inc(x,8);
      end;

end;

function getpix(x,y:word):byte;assembler;
var  decalage:word;
      asm
 mov bx,x
 mov ax,y {removed all range checking on x,y for speed}
 mul x_size {640 bytes wide in most cases}
 add bx,ax
 adc dx,0
 mov ax, dx { what a $#%%# stupid microprocessor}
 adc ax, 0

        {mov provi,al}   { bank  }
        mov decalage,bx
        cmp ax,curbank
        jz @nonew
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { ax= bank }
        @nonew:

          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov al,[es:di]
      end;


end.


{
  This is the second part of a message for SWAG dealing with VESA
cards.

{
****************************************************************************

      Here is an other VESA unit !!!!!!

      It is based on various sources ( DVPEG,John Bridges VGAKIT,
    SWAG an many others ).
      You can use,modified an distribute this source as long as credit
    is given.


    Supported modes:
      - 256 colors
      - 32768 colors
      - 16 millions colors


    The demo program for this unit is DemoVesa.

                                              Lionel Cordesses
                                              From FRANCE.
                                              November 1994

    E-Mail:
      cordesse@opgc.univ-bpclermont.fr

****************************************************************************
}
unit usvesa;
{$f+}
interface

uses dos,crt;


var

  use_16,use_32:boolean;
  x_size:word;

function  write_fast(x1,y,x2:word;var entree):boolean;
procedure getpix_16(x,y:word;var rouge,vert,bleu:byte);
procedure find_black(max_color:word;var black,white:byte);
function  setmode(mode:word):byte;  { return 0 if bad, 1 if OK }
procedure setpix(x,y,col:word);
procedure setpix_16(x,y:word;rouge,vert,bleu:byte);
function  getpix(x,y:word):byte;
procedure wrtxt(x,y:word;txt:string);{write TXT to pos (X,Y)}







implementation


var
  reg:registers;
  vgran,curbank:word;
  add_bank:procedure;
  tps1,tps2:longint;
  heure,minute,seconde,sec100:word;





{$ifdef msdos}
procedure setbank(bank:byte);far;
var banque:word;
  begin
    banque:=bank*longint(64) div vgran;
    asm
      mov bl, 0
      mov dx, banque
      call  [add_bank]
    end;
    curbank:=bank;
end;

{$else}

procedure setbank(bank:byte{word});far;
var banque:word;

  begin
             reg.ax:=$4f05;
             reg.bx:=0;
             reg.dx:=bank*longint(64) div vgran;

             intr($10,reg);
             reg.ax:=$4f05;
             reg.bx:=1;
             intr($10,reg);

  curbank:=255;{bank;}
end;
{$endif}

function setvesa(mode:word):byte;

  begin
    asm
     mov ax,4F02h
     mov bx,mode
     int 10h
     sub ax,004Fh
(*     mov al,0
     cmp ah,1   { if ah=1 that is bad ==>false }
     je  @fin
     mov al,1  {false }
   @fin:*)

     mov @RESULT,al
   end;
{   reg.ax:=$4f02;
   reg.bx:=mode;
   intr($10,reg);
   setvesa:=reg.al;}
{  textmode(co80);
  write(reg.ah,' ',reg.al);
  readln;}

  end;



{$ifdef msdos}
function setmode(mode:word):byte;  { 0 if bad,1 if OK}
type type_vesarec=array[0..555] of byte;
     ves_ptr=^type_vesarec;

type
  long=record
         lo,hi:word;
       end;

var pro:byte;
    vesarec:ves_ptr;

    vesa_info:record
      debut:array[0..3] of byte;
      granularite:word;
      winsize,
      winaseg,
      winbseg:word;
      add_proc:procedure;
      bytes:word;
      width,
      height:word;
      reste:array[0..250] of byte;
    end;


  begin
    setmode:=1;
    getmem(vesarec,556);
    pro:=setvesa(mode);
    fillchar(vesarec^[0],256,0); { set all to zero  }

      reg.ax:=$4f01;
      reg.cx:=mode;
      reg.es:=long(vesarec).hi;
      reg.di:=long(vesarec).lo;

      intr($10,reg);
      if reg.ah=0 then
        begin
          setmode:=1;
          pro:=1;
        end
      else
        begin
          setmode:=0;
          pro:=0;
        end;

      move(vesarec^[0],vesa_info.debut[0],256);
      if reg.al=0 then
        begin
          setmode:=1;
          pro:=1;
        end;
      vgran:=vesa_info.granularite;
      x_size:=vesa_info.width;                 { nb pt per lines }
      add_bank:=vesa_info.add_proc;        { change bank far ptr }

    freemem(vesarec,556);

    use_16:=false;
    use_32:=false;
    if mode=$112 then use_16:=true;
    if mode=$110 then use_32:=true;




  end;


{$endif}

procedure setpix(x,y,col:word);assembler;
var  decalage:word;
      asm
 mov bx,x
 mov ax,y {removed all range checking on x,y for speed}
 mul x_size {640 bytes wide in most cases}
 add bx,ax
 adc dx,0
 mov ax, dx { what a $#%%# stupid microprocessor}
 adc ax, 0

        {mov provi,al}   { bank  }
        mov decalage,bx
        cmp ax,curbank
        jz @nonew
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { here ax = bank }
        @nonew:

          mov bx,col
          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov [es:di],bl
      end;

procedure getpix_16(x,y:word;var rouge,vert,bleu:byte);assembler;
var l:longint;
    provi:byte;
    couleur,decalage:word;

      asm
        mov al,use_16
        cmp al,0
        je @v32000

 mov bx,x
        mov ax,bx
        shl bx,1
        add bx,ax       { x*3 }
 mov ax,y {removed all range checking on x,y for speed}
        shl ax,1
        add ax,y        { y*3 }
 mul x_size {640 bytes wide in most cases}
 add bx,ax
 adc dx,0
 mov ax, dx { what a $#%%# stupid microprocessor}
 adc ax, 0

        mov provi,al   { bank  }
        mov decalage,bx
        cmp ax,curbank
        jz @nonewa
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { here ax= bank }
        @nonewa:

          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov bl,[es:di]
          les di,bleu
          mov byte ptr [es:di],bl

        add decalage,1
        mov ah,0
        mov al,provi
        adc ax,0
        mov provi,al
        cmp ax,curbank
        jz @nonew1
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   {  ax = bank }
        @nonew1:

          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov bl,[es:di]
          les di,vert
          mov byte ptr [es:di],bl

        add decalage,1
        mov ah,0
        mov al,provi
        adc ax,0
        cmp ax,curbank
        jz @nonew2
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   {  ax= bank }
        @nonew2:

          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov bl,[es:di]
          les di,rouge
          mov byte ptr [es:di],bl

          jmp @fin

      @v32000:
 mov bx,x
 mov ax,y {removed all range checking on x,y for speed}
 mul x_size {640 bytes wide in most cases}
 add bx,ax
 adc dx,0
 mov ax, dx { what a $#%%# stupid microprocessor}
 shl ax, 1
 shl bx, 1
 adc ax, 0   { if carry }

        mov provi,al   { bank  }
        mov decalage,bx
        cmp ax,curbank
        je @nonew
{        mov ah,0}
        push cs
        push ax

        call  far ptr setbank   {  ax = bank }
        @nonew:


        mov ax,sega000
        mov es,ax
        mov di,decalage
        mov bx,[es:di]
        mov al,bl
        and al,31
        shl al,3
        les di,bleu
        mov byte ptr [es:di],al
        shr bx,5
        mov al,bl
        and al,31
        shl al,3
        les di,vert
        mov byte ptr [es:di],al
        shr bx,5
        mov al,bl
        and al,31
        shl al,3
        les di,rouge
        mov byte ptr [es:di],al

        @fin:
      end;



procedure setpix_16(x,y:word;rouge,vert,bleu:byte);
var l:longint;
    provi:byte;
    couleur,decalage:word;
  begin
    if use_16=true then
      asm

 mov bx,x
        mov ax,bx
        shl bx,1
        add bx,ax       { x*3 }
 mov ax,y {removed all range checking on x,y for speed}
        shl ax,1
        add ax,y        { y*3 }
 mul x_size {640 bytes wide in most cases}
 add bx,ax
 adc dx,0
 mov ax, dx { what a $#%%# stupid microprocessor}
 adc ax, 0

        mov provi,al   { bank  }
        mov decalage,bx
        cmp ax,curbank
        jz @nonew
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { ax= bank }
        @nonew:

          mov bl,bleu
          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov [es:di],bl

        add decalage,1
        mov ah,0
        mov al,provi
        adc ax,0
        mov provi,al
        cmp ax,curbank
        jz @nonew1
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   {  ax= bank }
        @nonew1:

          mov bl,vert
          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov [es:di],bl

        add decalage,1
        mov ah,0
        mov al,provi
        adc ax,0
        cmp ax,curbank
        jz @nonew2
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { ax= bank }
        @nonew2:

          mov bl,rouge
          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov [es:di],bl


      end;

  if use_32=true then
      asm
 mov bx,x
 mov ax,y {removed all range checking on x,y for speed}
 mul x_size {640 bytes wide in most cases}
 add bx,ax
 adc dx,0
 mov ax, dx { what a $#%%# stupid microprocessor}
 shl ax, 1
 shl bx, 1
 adc ax, 0   { if carry }

        mov provi,al   { bank  }
        mov decalage,bx
        cmp ax,curbank
        je @nonew
{        mov ah,0}
        push cs
        push ax
        call  far ptr setbank   {  ax= bank }
        @nonew:


        mov al,rouge
        shr al,3
        mov ah,0
        shl ax,10
        mov bl,vert
        shr bl,3
        mov bh,0
        shl bx,5
        add ax,bx
        mov bl,bleu
        shr bl,3
        mov bh,0
        add bx,ax
        mov ax,sega000
        mov es,ax
        mov di,decalage
        mov [es:di],bx
      end;
  end;

Procedure Move16(Var Source,Dest;Count:Word); Assembler;
Asm
  PUSH DS
  LDS SI,SOURCE
  LES DI,DEST
  MOV AX,COUNT
  MOV CX,AX
  SHR CX,1
  REP MOVSW
  TEST AX,1
  JZ @end
  MOVSB
@end:POP DS
end;


function write_fast(x1,y,x2:word;var entree):boolean;
var coord1,coord2:longint;
    couleur:byte;
  begin
    write_fast:=false;
    coord1:=longint(y)*longint(x_size)+x1;
    coord2:=coord1+longint((x2-x1)+1);
    if (coord1 shr 16)<> curbank then  setbank(coord1 shr 16);
    if (coord1 shr 16)=(coord2 shr 16) then
      begin
         move16(entree,mem[sega000:(coord1 mod 65536)],(x2-x1+1));
         write_fast:=true;
      end;
  end;


function donne_heure:longint;
var heure,minute,seconde,sec100:word;
  begin
    gettime(heure,minute,seconde,sec100);
    donne_heure:=heure*3600*100+minute*60*100+seconde*100+sec100;
  end;




procedure find_black(max_color:word;var black,white:byte);
var luminance,n:byte;
    reg:registers;
    table:array[0..767] of byte;
    i,x,y:word;

  begin
       with reg do
         begin
           ah:=$10;
           al:=$17;
           bx:=0;
           cx:=max_color;
           es:=seg(table);
           dx:=ofs(table);
           intr($10,reg);
         end;
    i:=0;
    white:=0;
    black:=255;
    for n:=0 to max_color-1 do
      begin
        luminance:=round(((0.59*table[i+1])+(0.3*table[i])+
        (0.11*table[i+2])));
        if luminance>white then
          begin
            white:=luminance;
            x:=n;
          end;
        if luminance<black then
          begin
            black:=luminance;
            y:=n;
          end;
        inc(i,3);
      end;
    i:=0;
    black:=y;
    white:=x;
  end;


procedure wrtxt(x,y:word;txt:string);{write TXT to pos (X,Y)}
type
  pchar=array[char] of array[0..15] of byte;
var
  p:^pchar;
  c:char;
  i,j,z,b:integer;
  noir,blanc:byte;
begin
  reg.ax:=$1130;
  reg.bh:=6;
  intr($10,reg);
  p:=ptr(reg.es,reg.bp);
  if (use_16=false) and (use_32=false) then
    find_black(256,noir,blanc)
  else
    begin
      noir:=0;
      blanc:=255;
    end;
      for z:=1 to length(txt) do
      begin
        c:=txt[z];
        for j:=0 to 15 do
        begin
          b:=p^[c][j];
          for i:=x+7 downto x do
          begin
            if (use_16=false) and (use_32=false)  then
              begin
                if odd(b) then setpix(i,y+j,blanc)
                          else setpix(i,y+j,noir);
              end
            else
              begin
                if odd(b) then setpix_16(i,y+j,blanc,blanc,blanc)
                          else setpix_16(i,y+j,noir,noir,noir);
              end;

            b:=b shr 1;
          end;
        end;
        inc(x,8);
      end;

end;

function getpix(x,y:word):byte;assembler;
var  decalage:word;
      asm
 mov bx,x
 mov ax,y {removed all range checking on x,y for speed}
 mul x_size {640 bytes wide in most cases}
 add bx,ax
 adc dx,0
 mov ax, dx { what a $#%%# stupid microprocessor}
 adc ax, 0

        {mov provi,al}   { bank  }
        mov decalage,bx
        cmp ax,curbank
        jz @nonew
        mov ah,0
        push cs
        push ax
        call  far ptr setbank   { ax= bank }
        @nonew:

          mov ax,sega000
          mov es,ax
          mov di,decalage
          mov al,[es:di]
      end;


end.

{ cut here
----------------------------------------------------------------------------
}

program VesaDemo;
{
*****************************************************************************

    Sample program for the unit Usvesa.

    Only 2 mode tested here:
      - 256 colors
      - 16 millions colors

    You can change the
       "n:=setmode($112);" and write :
       "n:=setmode($110);" .
    I am sure that you will see the difference between 32768 an 16 millions
  colors !!!

                                           Lionel Cordesses
                                           From FRANCE.
                                           November 1994
*****************************************************************************
}

{$f+}

uses dos,crt,usvesa;

var n:byte;
    x,y,i:word;
    ch:char;
    funckey:boolean;
    code:byte;

procedure touche(var funckey:boolean;var code:byte);
var ch:char;
  begin

    while keypressed do
      ch:=readkey;
    repeat
    until not keypressed;
    ch:=readkey;
    if ch<>#0 then funckey:=false
    else
      begin
        funckey:=true;
        ch:=readkey;
      end;
    code:=ord(ch);
  end;



procedure test_256;
  begin
    clrscr;
    writeln('Testing VESA mode 640x480 256 colors');
    writeln('Press a key ...');
    repeat
      touche(funckey,code)
    until (code<>0) or (funckey=true);
    n:=setmode($101);
    if n=0 then
      begin
        textmode(co80);
        writeln('WARNING:no VESA driver or unsupported mode !!! ');
        halt(1);
      end;
    for x:=0 to 255 do
      for y:=0 to 255 do
        setpix(x,y,x);
    wrtxt(10,300,'Mode VESA 101h OK : Press a key to quit ...');
    repeat
       touche(funckey,code)
    until (code<>0) or (funckey=true);
    textmode(co80);
  end;

procedure test_16;
  begin
    clrscr;
    writeln('Testing VESA mode 640x480 16 millions  colors');
    writeln('Press a key ...');
    repeat
      touche(funckey,code)
    until (code<>0) or (funckey=true);
    n:=setmode($112);
    if n=0 then
      begin
        textmode(co80);
        writeln('WARNING:no VESA driver or unsupported mode !!! ');
        halt(1);
      end;
    for y:=0 to 255 do
      for x:=0 to 255 do
        setpix_16(x,y,x,y,255-x);
     wrtxt(10,300,'Mode VESA 112h OK : Press a key to quit ...');
    repeat
      touche(funckey,code)
    until (code<>0) or (funckey=true);
    textmode(co80);
  end;


begin
  test_256;
  test_16;
  textmode(co80);
end.

