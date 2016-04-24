(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0253.PAS
  Description: Graphics Screen Handling unit
  Author: SWAG SUPPORT TEAM
  Date: 03-04-97  13:18
*)

{$F+,O+}
unit Screen_d;
INTERFACE

uses DOS, GRAPH;

type    RGBrec = record
                   redval, greenval, blueval: byte;
                 end;

var     SCRfilename: pathstr;
        file_error: boolean;
        pal: palettetype;
        RGBpal: array[0..15] of RGBrec;
        page_addr: word;
        bytes_per_line: word;
        buff0, buff1: pointer;

        { CGA display memory banks: }
        screenbuff0: array[0..7999] of byte absolute $b800:$0000;
        screenbuff1: array[0..7999] of byte absolute $b800:$2000;

const   page0 = $A000;           { EGA/VGA display segment }

procedure READSCR(pfilename: pathstr);

{========================================================================}

IMPLEMENTATION

var     scratch, abuff0, abuff1: pointer;
        is_VGA: boolean;
        repeatcount: byte;
        datalength: word;
        columncount, plane, video_index: word;
        regs: registers;

const   buffsize = 65521;   { Largest possible }

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

{ ============= Main procedure for CGA and 16-color files =============== }

procedure READSCR(pfilename: pathstr);
type    ptrrec = record
                   segm, offs: word;
                 end;

var     entry, gun, SCRcode, mask, colorID: byte;
        palbuf: array[0..66] of byte;
        SCRfile: file;

begin   { READ_SCR_FILE }
        assign(SCRfile, pfilename);
        {$I-}
        reset(SCRfile, 1);
        {$I+}
        getmem(scratch, buffsize);                 { Allocate scratchpad }
        blockread(SCRfile, scratch^, 128);         { Get header into scratchpad }
        move(scratch^, palbuf, 67);
        bytes_per_line:= palbuf[66];
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
                  SCRcode:= palbuf[16 + entry * 3 + gun];   { Get primary color value }
                  begin
                  with RGBpal[entry] do                   { Interpret for VGA }
                       case gun of
                        0: redval:= SCRcode div 4;
                        1: greenval:= SCRcode div 4;
                        2: blueval:= SCRcode div 4;
                       end;
                  end;  { is_VGA }
                  end;  { gun }
                  pal.colors[entry]:= entry;
             end;  { entry }
             pal.size:= 16;
        end;   { not is_CGA }
        repeatcount:= 0;                        { Initialize assembler vars. }
        columncount:= 0;
        repeat
              blockread(SCRfile, scratch^, buffsize, datalength);
              decode_16;   { Call assembler routine }
        until eof(SCRfile);
        close(SCRfile);
        freemem(scratch,buffsize);              { Discard scratchpad }
end;  { READ_SCR_FILE }

Begin
     Page_addr := Page0;
END.


