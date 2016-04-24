(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0145.PAS
  Description: Mode-X Raw Image Put
  Author: BAS VAN GAALEN
  Date: 11-26-94  05:02
*)

{
> I need to put a 64k Raw Image onto Page 0 in 320x200 X-Mode.

Well, that wasn't too hard. Faster then the following one doesn't seem
possible. Don't try to make the f_bufsize too large: it'll probably hang your
computer and it won't speed up the picture display. You could, however, set the
palette to all black when displaying the picture, and when it's ready, set the
colors of the picture correctly.

You can alter the offsets of the palette and the picture as you like. The
defaults are for the ColoRIX/EGA Paint format, converted with VPic.
}
{$a+,b-,d+,e+,f-,g+,i+,l+,n-,o-,p-,q-,r-,s+,t-,v+,x+} { tp7.0 directives }
{$m 16384,0,655360}

program putmodexpicture;
{ Display raw picture in mode-x (320x200x256x4), by Bas van Gaalen,
  fido 2:285/213.8, email bas.van.gaalen@schotman.nl, Aug. '94 }

uses
  crt,dos;                   { crt for keypressed, dos for pathstr }

const
  pal_offset=$000a;          { offset of palette in pic-file }
  pic_offset=$030a;          { offset of picture in pic-file }
  f_bufsize=4096;            { file-buffer size }
  vidseg:word=$a000;         { VGA graphics segment }

type
  errmsg=string[80];
  f_buf=array[0..f_bufsize-1] of byte;
  pal_buf=array[0..$2ff] of byte;

var
  p_file:file;

procedure error(err:errmsg); begin writeln; writeln(err); halt(1); end;

procedure setpal(c,r,g,b:byte); assembler; asm
  mov dx,3c8h; mov al,[c]; out dx,al; inc dx; mov al,[r]
  out dx,al; mov al,[g]; out dx,al; mov al,[b]; out dx,al; end;

procedure setmodex; assembler; asm
  mov ax,13h; int 10h; mov dx,3c4h; mov ax,0604h; out dx,ax; mov ax,0f02h
  out dx,ax; mov cx,320*200; mov es,vidseg; xor ax,ax; mov di,ax; rep stosw
  mov dx,3d4h; mov ax,0014h; out dx,ax; mov ax,0e317h; out dx,ax; end;

procedure putpixel(offs:word; col:byte); assembler; asm
  mov dx,03c4h; mov al,2; mov cx,[offs]; and cx,3; mov ah,1; shl ah,cl
  out dx,ax; mov es,vidseg; mov ax,[offs]; shr ax,2; mov di,ax
  mov al,[col]; mov [es:di],al; end;

procedure retrace; assembler; asm
  mov dx,3dah; @vert1: in al,dx; test al,8; jz @vert1
  @vert2: in al,dx; test al,8; jnz @vert2; end;

procedure initfile(filename:pathstr);
begin
  if filename='' then error('Enter raw-picture filename on commandline.');
  assign(p_file,filename);
  {$i-} reset(p_file,1); {$i+}
  if ioresult<>0 then error(fexpand(filename)+' not found.');
end;

procedure initpal;
var buf:pal_buf; c:word; i:byte;
begin
  seek(p_file,pal_offset);
  blockread(p_file,buf,$300);
  setmodex;
  c:=0;
  for i:=0 to 255 do begin
    setpal(i,buf[c],buf[c+1],buf[c+2]);
    inc(c,3);
  end;
end;

procedure displaypic;
var buf:f_buf; i,bufidx:word; nofread:integer;
begin
  bufidx:=0;
  repeat
    blockread(p_file,buf,f_bufsize,nofread);
    for i:=0 to nofread do putpixel(bufidx+i,buf[i]);
    inc(bufidx,nofread);
  until nofread<>f_bufsize;
  close(p_file);
end;

var dummy:byte;
begin
  initfile(paramstr(1));
  initpal;
  port[$03c0]:=0; { screen blanck }
  displaypic;
  retrace; dummy:=port[$03da]; port[$03c0]:=32; { show screen }
  repeat until keypressed;
  asm mov ax,3; int 10h; end;
end.


