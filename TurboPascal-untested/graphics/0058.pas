
unit PCX;

{   The following display modes are supported:

          Mode      TP GraphMode     Resolution    Colors
          ~~~~      ~~~~~~~~~~~~     ~~~~~~~~~~    ~~~~~~
          $04       CGAC0 to C3      320 x 200         4
          $06       CGAHi            640 x 200         2
          $0D        ---             320 x 200        16
          $0E       EGALo/VGALo      640 x 200        16
          $10       EGAHi/VGAMed     640 x 350        16
          $12       VGAHi            640 x 480        16
          $13        ---             320 x 200       256

   Mode $13 is supported only for files containing palette information,
   i.e. not those produced by versions of Paintbrush earlier than 3.0.}

INTERFACE

uses DOS, GRAPH;

type    RGBrec = record
                   redval, greenval, blueval: byte;
                 end;

var     pcxfilename: pathstr;
        file_error: boolean;
        pal: palettetype;
        RGBpal: array[0..15] of RGBrec;
        RGB256: array[0..255] of RGBrec;
        page_addr: word;
        bytes_per_line: word;
        buff0, buff1: pointer;

        { CGA display memory banks: }
        screenbuff0: array[0..7999] of byte absolute $b800:$0000;
        screenbuff1: array[0..7999] of byte absolute $b800:$2000;

const   page0 = $A000;           { EGA/VGA display segment }

procedure SETMODE(mode: byte);
procedure SETREGISTERS(var palrec);
procedure READ_PCX_FILE(gdriver: integer; pfilename: pathstr);
procedure READ_PCX256(pfilename: pathstr);

{========================================================================}

IMPLEMENTATION

var     scratch, abuff0, abuff1: pointer;
        is_CGA, is_VGA: boolean;
        repeatcount: byte;
        datalength: word;
        columncount, plane, video_index: word;
        regs: registers;

const   buffsize = 65521;   { Largest possible }

{ -------------------------- BIOS calls --------------------------------- }

{ For modes not supported by the BGI, use SetMode to initialize the
  graphics. Since SetRGBPalette won't work if Turbo hasn't done the
  graphics initialization itself, use SetRegisters to change the colors
  in mode $13. }

procedure SETMODE(mode: byte);

begin
regs.ah:= 0;                 { BIOS set mode function }
regs.al:= mode;              { Display mode }
intr($10, regs);             { Call BIOS }
end;

procedure SETREGISTERS(var palrec);

{ Palrec is any string of 768 bytes containing the RGB data. }

begin
regs.ah:= $10;               { BIOS color register function }
regs.al:= $12;               { Subfunction }
regs.es:= seg(palrec);       { Address of palette info. }
regs.dx:= ofs(palrec);
regs.bx:= 0;                 { First register to change }
regs.cx:= $100;              { Number of registers to change }
intr($10, regs);             { Call BIOS }
end;

{ ====================== EGA/VGA 16-color files ========================= }

procedure DECODE_16; assembler;

asm
push    bp

{ ----------------- Assembler procedure for 16-color files -------------- }

{ The first section is initialization done on each run through the
  input buffer. }

@startproc:
mov     bp, plane           { plane in BP }
mov     es, page_addr       { video display segment }
mov     di, video_index     { index into video segment }
mov     ah, byte ptr bytes_per_line  { line length in AH }
mov     dx, columncount     { column counter }
mov     bx, datalength      { no. of bytes to read }
xor     cx, cx              { clean up CX for loop counter }
mov     cl, repeatcount     { count in CX }
push    ds                  { save DS }
lds     si, scratch         { input buffer pointer in DS:SI }
add     bx, si
cld                         { clear DF for stosb }
cmp     cl, 0               { was last byte a count? }
jne     @multi_data         { yes, so next is data }
jmp     @getbyte            { no, so find out what next is }

{ -------------- Procedure to write EGA/VGA image to video -------------- }

@writebyte:
stosb                       { AL into ES:DI, inc DI }
inc     dl                  { increment column }
cmp     dl, ah              { reached end of scanline? }
je      @doneline           { yes }
loop    @writebyte          { no, do another }
jmp     @getbyte            {   or get more data }
@doneline:
shl     bp, 1               { shift to next plane }
cmp     bp, 8               { done 4 planes? }
jle     @setindex           { no }
mov     bp, 1               { yes, reset plane to 1 but don't reset index }
jmp     @setplane
@setindex:
sub     di, dx              { reset to start of line }
@setplane:
push    ax                  { save AX }
cli                         { no interrupts }
mov     ax, bp              { plane is 1, 2, 4, or 8 }
mov     dx, 3C5h            { sequencer data register }
out     dx, al              { mask out 3 planes }
sti                         { enable interrupts }
pop     ax                  { restore AX }
xor     dx, dx              { reset column count }
loop    @writebyte          { do it again, or fetch more data }

@getbyte:                   { last byte was not a count }
cmp     si, bx              { end of input buffer? }
je      @exit               { yes, quit }
lodsb                       { get a byte from DS:SI into AL, increment SI }
cmp     al, 192             { test high bits }
jb      @one_data           { not set, it's data to be written once }
 { It's a count byte: }
xor     al, 192             { get count from 6 low bits }
mov     cl, al              { store repeat count }
cmp     si, bx              { end of input buffer? }
je      @exit               { yes, quit }
@multi_data:
lodsb                       { get data byte }
jmp     @writebyte          { write it CL times }
@one_data:
mov     cl, 1               { write byte once }
jmp     @writebyte

{ ---------------------- Finished with buffer --------------------------- }

@exit:
pop     ds                  { restore Turbo's data segment }
mov     plane, bp           { save status for next run thru buffer }
mov     repeatcount, cl
mov     columncount, dx
mov     video_index, di
pop     bp
end;  { asm }

{ ===================== CGA 2- and 4-color files ======================== }

procedure DECODE_CGA; assembler;

asm

push    bp
jmp     @startproc

{ ------------- Procedure to store CGA image in buffers ----------------- }

@storebyte:
stosb                       { AL into ES:DI, increment DI }
inc     dx                  { increment column count }
cmp     dl, ah              { reached end of line? }
je      @row_ends           { yes }
loop    @storebyte          { not end of row, do another byte }
ret
@row_ends:
xor     bp, 1               { switch banks }
cmp     bp, 1               { is bank 1? }
je      @bank1              { yes }
mov     word ptr abuff1, di { no, save index into bank 1 }
les     di, abuff0          { bank 0 pointer into ES:DI }
xor     dx, dx              { reset column counter }
loop    @storebyte
ret
@bank1:
mov     word ptr abuff0, di { save index into bank 0 }
les     di, abuff1          { bank 1 pointer into ES:DI }
xor     dx, dx              { reset column counter }
loop    @storebyte
ret

{ ---------------- Main assembler procedure for CGA --------------------- }

@startproc:
mov     bp, 0                        { bank in BP }
mov     es, word ptr abuff0[2]       { segment of bank 0 buffer }
mov     di, word ptr abuff0          { offset of buffer }
mov     ah, byte ptr bytes_per_line  { line length in AH }
mov     bx, datalength               { no. of bytes to read }
xor     cx, cx                       { clean up CX for loop counter }
xor     dx, dx                       { initialize column counter }
mov     si, dx                       { initialize input index }
cld                                  { clear DF for stosb }

{ -------------------- Loop through input buffer ------------------------ }

@getbyte:
cmp     si, bx              { end of input buffer? }
je      @exit               { yes, quit }
push    es                  { save output pointer }
push    di
les     di, scratch         { get input pointer in ES:DI }
add     di, si              { add current offset }
mov     al, [es:di]         { get a byte }
inc     si                  { advance input index }
pop     di                  { restore output pointer }
pop     es
cmp     cl, 0               { was previous byte a count? }
jg      @multi_data         { yes, this is data }
cmp     al, 192             { no, test high bits }
jb      @one_data           { not set, not a count }
 { It's a count byte: }
xor     al, 192             { get count from 6 low bits }
mov     cl, al              { store repeat count }
jmp     @getbyte            { go get data byte }
@one_data:
mov     cl, 1               { write byte once }
call    @storebyte
jmp     @getbyte
@multi_data:
call    @storebyte          { CL already set }
jmp     @getbyte

{ ---------------------- Finished with buffer --------------------------- }

@exit:
pop     bp
end;  { asm }

{ ============= Main procedure for CGA and 16-color files =============== }

procedure READ_PCX_FILE(gdriver: integer; pfilename: pathstr);

type    ptrrec = record
                   segm, offs: word;
                 end;

var     entry, gun, pcxcode, mask, colorID: byte;
        palbuf: array[0..66] of byte;
        pcxfile: file;

begin   { READ_PCX_FILE }
is_CGA:= (gdriver = CGA);   { 2 or 4 colors }
is_VGA:= (gdriver = VGA);   { 16 of 256K possible colors }
                            { Otherwise EGA - 16 of 64 possible colors }
assign(pcxfile, pfilename);
{$I-} reset(pcxfile, 1);  {$I+}
file_error:= (IOresult <> 0);
if file_error then exit;

getmem(scratch, buffsize);                 { Allocate scratchpad }
blockread(pcxfile, scratch^, 128);         { Get header into scratchpad }

move(scratch^, palbuf, 67);
bytes_per_line:= palbuf[66];

{------------------------ Setup for CGA ---------------------------------}

if is_CGA then
begin
  getmem(buff0, 8000);      { Allocate memory for output }
  getmem(buff1, 8000);
  abuff0:= buff0;           { Make copies of pointers }
  abuff1:= buff1;
end else

{----------------------- Setup for EGA/VGA ------------------------------}

begin
  video_index:= 0;
  port[$3C4]:= 2;           { Index to map mask register }
  plane:= 1;                { Initialize plane }
  port[$3C5]:= plane;       { Set sequencer to mask out other planes }

  for entry:= 0 to 15 do
  begin
    colorID:= 0;
    for gun:= 0 to 2 do
    begin
      pcxcode:= palbuf[16 + entry * 3 + gun];   { Get primary color value }
      if not is_VGA then
      begin                                     { Interpret for EGA }
        case (pcxcode div $40) of
          0: mask:= $00;    { 000000 }
          1: mask:= $20;    { 100000 }
          2: mask:= $04;    { 000100 }
          3: mask:= $24;    { 100100 }
        end;
        colorID:= colorID or (mask shr gun);    { Define two bits }
      end  { not is_VGA }
      else
      begin  { is_VGA }
        with RGBpal[entry] do                   { Interpret for VGA }
        case gun of
          0: redval:= pcxcode div 4;
          1: greenval:= pcxcode div 4;
          2: blueval:= pcxcode div 4;
        end;
      end;  { is_VGA }
    end;  { gun }
    if is_VGA then pal.colors[entry]:= entry
              else pal.colors[entry]:= colorID;
  end;  { entry }
  pal.size:= 16;
end;   { not is_CGA }

{ ---------------- Read and decode the image data ----------------------- }

repeatcount:= 0;                        { Initialize assembler vars. }
columncount:= 0;
repeat
  blockread(pcxfile, scratch^, buffsize, datalength);
  if is_CGA then decode_CGA else decode_16;   { Call assembler routine }
until eof(pcxfile);
close(pcxfile);
if not is_CGA then port[$3C5]:= $F;     { Reset mask map }
freemem(scratch,buffsize);              { Discard scratchpad }
end;  { READ_PCX_FILE }

{ ========================= 256-color files ============================= }

procedure DECODE_PCX256; assembler;

asm
mov     es, page_addr       { video segment }
mov     di, video_index     { index into video }
xor     cx, cx              { clean up loop counter }
mov     cl, repeatcount     { count in CL }
mov     bx, datalength      { end of input buffer }
push    ds                  { save DS }
lds     si, scratch         { pointer to input in DS:SI }
add     bx, si              { adjust datalength - SI may not be 0 }
cld                         { clear DF }
cmp     cl, 0               { was last byte a count? }
jne     @multi_data         { yes, so next is data }

{ --------------------- Loop through input buffer ----------------------- }

@getbyte:                   { last byte was not a count }
cmp     si, bx              { end of input buffer? }
je      @exit               { yes, quit }
lodsb                       { get byte into AL, increment SI }
cmp     al, 192             { test high bits }
jb      @one_data           { not set, not a count }
{ It's a count byte }
xor     al, 192             { get count from 6 low bits }
mov     cl, al              { store repeat count }
cmp     si, bx              { end of input buffer? }
je      @exit               { yes, quit }
@multi_data:
lodsb                       { get byte into AL, increment SI }
rep     stosb               { write byte CX times }
jmp     @getbyte
@one_data:
stosb                       { byte into video }
jmp     @getbyte

{ ------------------------- Finished with buffer ------------------------ }

@exit:
pop     ds                  { restore Turbo's data segment }
mov     video_index, di     { save status for next run thru buffer }
mov     repeatcount, cl
end;  { asm }

{ ================= Main procedure for 256-color files ================== }

procedure READ_PCX256(pfilename: pathstr);

var     x, gun, pcxcode: byte;
        pcxfile: file;
        palette_start, total_read: longint;
        palette_flag: byte;
        version: word;

procedure CLEANUP;

begin
close(pcxfile);
freemem(scratch, buffsize);
end;

begin    { READ_PCX256 }
assign(pcxfile, pfilename);
{$I-} reset(pcxfile, 1);  {$I+}
file_error:= (IOresult <> 0);
if file_error then exit;
getmem(scratch, buffsize);                  { Allocate scratchpad }
blockread(pcxfile, version, 2);             { Read first two bytes }
file_error:= (hi(version) < 5);             { No palette info. }
if file_error then
begin
  cleanup; exit;
end;
palette_start:= filesize(pcxfile) - 769;

seek(pcxfile, 128);                        { Scrap file header }
total_read:= 128;

repeatcount:= 0;                           { Initialize assembler vars. }
video_index:= 0;

repeat
  blockread(pcxfile, scratch^, buffsize, datalength);
  inc(total_read, datalength);
  if (total_read > palette_start) then
      dec(datalength, total_read - palette_start);
  decode_pcx256;
until (eof(pcxfile)) or (total_read>= palette_start);

seek(pcxfile, palette_start);
blockread(pcxfile, palette_flag, 1);
file_error:= (palette_flag <> 12);
if file_error then
begin
  cleanup; exit;
end;
blockread(pcxfile, RGB256, 768);         { Get palette info. }
for x:= 0 to 255 do
with RGB256[x] do
begin
  redval:= redval shr 2;
  greenval:= greenval shr 2;
  blueval:= blueval shr 2;
end;
cleanup;
end;  { READ_PCX256 }

{ ========================== Initialization ============================= }

BEGIN
page_addr:= page0;                      { Destination for EGA/VGA data }
END.
