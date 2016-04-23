

 > Does anyone have a program (not necessarily source) that will
 > take a full
 > screen GIF or PCX or whatever graphic format and convert it into
 > something I can load in Pascal?  Or even a graphic editor that

You can load a .PCX in pascal! No conversion needed. Here is some source.

{ MCGA PCX decode by Bas van Gaalen, Holland, PD }
{ Modified to use virtual screen/pointers by Ricky Booth, USA, PD }


{$M 65520, 4096, 655360}
{$I-}

program pcx_view;

uses
  crt;

type
  pcxheader = record
    manufacturer,version,encoding,bits_per_pixel : byte;
    xmin,ymin,xmax,ymax,hres,vres : word;
    palette : array[0..47] of byte;
    reserved : byte;
    color_planes : byte;
    bytes_per_line : word;
    palette_type : word;
    filler : array[0..57] of byte;
  end;

var
  pcxfile : file;
  header : pcxheader;

{----------------------------------------------------------------------------}

procedure error(errstr : string);
begin
  writeln(errstr);
  halt;
end;

{----------------------------------------------------------------------------}

function validpcx : boolean;
begin
  seek(pcxfile,0);
  blockread(pcxfile,header,sizeof(header));
  with header do validpcx := (manufacturer = 10) and (version = 5) and
    (bits_per_pixel = 8) and (color_planes = 1);
end;

{----------------------------------------------------------------------------}

function validpal : boolean;
var v : byte;
begin
  seek(pcxfile,filesize(pcxfile)-769);
  blockread(pcxfile,v,1);
  validpal := v = $0c;
end;

{----------------------------------------------------------------------------}

procedure setvideo(md : word); assembler;
asm
  mov ax,md
  int 10h
end;

{----------------------------------------------------------------------------}

CONST VGA = $a000;  (* This sets the constant VGA to the segment of the
                       VGA screen.                                      *)

Type Virtual = Array [1..64000] of byte;  { The size of our Virtual Screen }
     VirtPtr = ^Virtual;                  { Pointer to the virtual screen }

VAR Virscr : VirtPtr;                     { Our first Virtual screen }
    Vaddr  : word;                        { The segment of our virtual screen}

procedure setpal;
var pal : array[0..767] of byte;
begin
  seek(pcxfile,filesize(pcxfile)-768);
  blockread(pcxfile,pal,768);
  asm
    cld
    xor di,di
    xor bx,bx
   @L1:
    mov dx,03c8h
    mov ax,bx
    out dx,al
    inc dx
    mov cx,3
   @L2:
    mov al,byte ptr pal[di]
    shr al,1
    shr al,1
    out dx,al
    inc di
    loop @L2
    inc bx
    cmp bx,256
    jne @L1
  end;
end;

{----------------------------------------------------------------------------}

Procedure SetUpVirtual;
BEGIN
  GetMem (VirScr,64000);
  vaddr := seg (virscr^);
END;

procedure unpack;
var gofs,j : word; i,k,v,loop : byte;
begin
  seek(pcxfile,128);
  gofs := 0;
  for i := 0 to header.ymax-header.ymin+1 do begin
    j := 0;
    while j < header.bytes_per_line do begin
      blockread(pcxfile,v,1);
      if (v and 192) = 192 then begin
        loop := v and 63;
        inc(j,loop);
        blockread(pcxfile,v,1);
        for k := 1 to loop do begin
          Mem[Vaddr:gofs] := v;
          inc(gofs);
        end;
      end
      else begin
        Mem[Vaddr:gofs] := v;
        inc(gofs);
        inc(j);
      end;
    end;
  end;
end;

Procedure WaitRetrace; assembler;
label
  l1, l2;
asm
    mov dx,3DAh
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
    and al,08h
    jz  l2
end;

{----------------------------------------------------------------------------}

begin
  SetUpVirtual; (*initilizes the pointers*)
  if paramstr(1) = '' then error('Enter filename on commandline.');
  assign(pcxfile,paramstr(1));
  reset(pcxfile,1);
  if ioresult <> 0 then error(paramstr(1)+' not found.');
  if not validpcx then error('Not a 256 color PCX file.');
  if not validpal then error('Palette corrupt.');
  Writeln('Decoding Image...');
  Unpack;
  Setvideo($13);
  Setpal;
  Move(Virscr^,MEM[VGA:0],64000); (*Stick the virtual page to the vga mem*)
  repeat until keypressed;
  While keypressed do readln;
  setvideo(3);
  close(pcxfile);
  FreeMem (VirScr,64000); (*Free up virtual memory*)
end.
