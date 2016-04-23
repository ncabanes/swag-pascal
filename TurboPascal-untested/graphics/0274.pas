
{Jaco van Niekerk   sparky@lantic.co.za}
{Any comments, whatever, please mail!}

{Please note : I take NO responsibility on the effect of the code  }
{              I've tested it on many machines, so I can't see any }
{              reason why it should not work on yours.             }


{worm hole in 320x200}
{$N+}
program wormhole;
uses crt; {for keypressed}

var circle_x : array[1..80, 0..61] of integer;
    circle_y : array[1..80, 0..61] of integer;
    cposx, xposy : array[1..80, 0..61] of integer;
    relpos_x : array[1..80] of integer;
    relpos_y : array[1..80] of integer;
    vscreen : pointer;

procedure calc_circles;
var deg, x, y, c : integer;
begin
     for c:=1 to 80 do
     begin
          relpos_x[c]:=0; relpos_y[c]:=0;
          for deg:=0 to 60 do
          begin
               x:=round(c*3*cos(deg*pi/30)); y:=round(c*3*sin(deg*pi/30));
               circle_x[c, deg]:=160+x; circle_y[c, deg]:=100+y;
          end;
     end;
end;

procedure copyw(source : pointer; dest : pointer; cnt : word);assembler;
asm
   les di, [dest]
   push ds
   lds si, [source]
   mov cx, [cnt]
   cld
   rep movsw
   pop ds
end;

procedure clrdw(source : pointer; cnt : word);assembler;
asm
   les di, [source]
   mov cx, [cnt]
   db $66; xor ax, ax {xor eax, eax}
   db $66; rep stosw  {rep storsdw}
end;

procedure waitretrace;assembler;
asm {this waits for a vertical retrace, exiting when it occurs}
   mov dx,3DAh
   @loop1:
   in al,dx
   and al,08h
   jnz @loop1
   @loop2:
   in al,dx
   and al,08h
   jz @loop2
end;

var xp, yp, i, j, sg, os, new_y, new_x : word;
    cx, cy, dx, dy : real;
    tx, ty : integer;

    mpos : integer;

begin
     randomize;
     if maxavail<64000 then
        begin writeln('Not enough memory!'); halt(1); end;

     getmem(vscreen, 64000);

     calc_circles;
     sg:=seg(vscreen^); os:=ofs(vscreen^);
     cx:=0; cy:=0; dx:=0; dy:=0;
     tx:=random(20)-10; ty:=random(20)-10;
     asm mov ax, 13h; int 10h; end;

     port[$3c8]:=1;
     for i:=1 to 80 do
     begin
          port[$3c9]:=round(i*0.7);
          port[$3c9]:=round(i*0.7);
          port[$3c9]:=round(i*0.7);
     end;

     repeat
           {clear screen}
           clrdw(vscreen, 16000);

           {update offset buffer}
           for i:=80 downto 1 do
               begin
                    relpos_x[i]:=relpos_x[i-1];
                    relpos_y[i]:=relpos_y[i-1];
               end;

           {create "new" circle}
           if cx>tx then dx:=dx-0.55 else
              if cx<tx then dx:=dx+0.55;
           if cy>ty then dy:=dy-0.55 else
              if cy<ty then dy:=dy+0.55;
           if sqr(cx-tx)+sqr(cy-ty)<200 then
           begin tx:=random(80)-30; ty:=random(50)-25; end;
           cx:=cx+dx; cy:=cy+dy;

           {speed control}
           if dx>5 then dx:=5;
           if dx<-5 then dx:=-5;
           if dy>5 then dy:=5;
           if dy<-5 then dy:=-5;

           {update new circle}
           relpos_x[1]:=round(cx); relpos_y[1]:=round(cy);

           {plot circles}
           for i:=1 to 80 do
               for j:=0 to 60 do
               begin
                    new_x:=circle_x[i][j] + relpos_x[i];
                    new_y:=circle_y[i][j] + relpos_y[i];
                    if (new_x>0) and (new_x<320) and
                       (new_y>0) and (new_y<200) then
                       mem[sg:os+new_y shl 6+new_y shl 8+new_x]:=i;

               end;

           {blast to screen}
           waitretrace;
           copyw(vscreen, ptr($a000,0000), 32000);
     until (keypressed);
     asm mov ax, 03h; int 10h; end;

     freemem(vscreen, 64000);
end.
--Message-Boundary-5639
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Text from file 'SIMBA.PAS'

{ By Jaco van Niekerk - sparky@lantic.co.za
   (Any problems, feel free to mail me)

{Please note : I take NO responsibility on the effect of the code  }
{              I've tested it on many machines, so I can't see any }
{              reason why it should not work on yours.             }

{The wonders of the VGA card}
{$N+}
program run_around;
uses crt;

type header = record
       manufacturer : byte;
       version : byte;
       encoding : byte;
       bits_per_pixel : byte;
       xmin, ymin, xmax, ymax : integer;
       hdpi, vdpi : integer;
       colormap : array[0..47] of byte;
       reserved : byte;
       nplanes : byte;
       bytes_per_line : integer;
       palette_info : integer;
       hscreensize, vscreensize : integer;
       dummy : array[0..53] of byte;
     end;

const width : byte = 80; {80 * 8 = 640}
      fade = 20;
      spin = 200;

procedure initmode; {320x200 chain4 off}
begin
     {first go to chain-4 mode}
     asm
        mov ah, 0
        mov al, 13h
        int 10h
     end;
     {turn chain-4 bit off}
     port[$3c4]:=$4; {index 2}
     port[$3c5]:=port[$3c5] and $f7; {now set bit 3 to zero}
     {turn off word mode}
     port[$3d4]:=$17; {index 17}
     port[$3d5]:=port[$3d5] or $40;
     {turn off double word mode}
     port[$3d4]:=$14; {index 14}
     port[$3d5]:=0;
     {set logical screen width}
     port[$3d4]:=$13;
     port[$3d5]:=width;
     {clear the video memory}
     portw[$3c4]:=$0f02;
     fillchar(mem[$a000:000],65535,0);
end;

procedure moveto(x, y : word);
var offset : word;
begin
     offset:=width*2*y+(x div 4);
     port[$3d4]:=$c; port[$3d5]:=hi(offset);
     port[$3d4]:=$d; port[$3d5]:=lo(offset);
     {smooth panning compatible}
     port[$3c0]:=$13 or $20;
     port[$3c0]:=(x mod 4) shl 1;
end;

procedure putpixel(x, y : word; col : byte);assembler;
asm
   mov ax, 0a000h
   mov es, ax           {video address in es}
   mov dx, 03c4h        {mov register value into dx}
   mov al, 02h          {we want index 2}
   mov ah, 01h          {from here on, calculate the correct plane}
   mov cx, [x]
   and cx, 3
   shl ah, cl
   out dx, ax           {one port write}
   mov ax, [y]          {calculate address}
   shl ax, 1
   shl ax, 4
   mov di, ax
   shl ax, 2
   add di, ax
   mov ax, [x]
   shr ax, 2
   add di, ax
   mov al, [col]
   mov [es:di], al      {plot the colour}
end;

function getpixel(x, y : word):byte;assembler;
asm
   mov ax, 0a000h
   mov es, ax
   mov dx, $3ce         {prepare port word}
   mov bx, [x]
   and bx, 3
   mov ah, bl
   mov al, 04h
   out dx, ax           {write ax to port dx}
   mov ax, [y]          {calculate address}
   shl ax, 1
   shl ax, 4
   mov di, ax
   shl ax, 2
   add di, ax
   mov ax, [x]
   shr ax, 2
   add di, ax
   mov al, [es:di]      {get the colour}
end;

function pcxbackground(fname : string):boolean;
{INPUT  : filename of 256 colour pcx image                       }
{OUTPUT : TRUE if image load successful                          }
{OTHER  : either loads pcx file or not, fades palette in         }
const dskbufsize = 8192;
var hdrb : header;
    palb : array[0..767] of byte;
var {general vars}
    f : file;
    eb, dta, rle, ecode : byte;
    dx, dy, i, j  : word;
    tot, mc : longint;

    {global cashread vars}
    dskbuf : array[0..dskbufsize-1] of byte;
    cnt, cursize : word;

    function casheread : byte;
    begin {cashread routine}
         if cnt=cursize then {read ahead}
         begin
              blockread(f, dskbuf, dskbufsize, cursize); cnt:=0;
         end;
         cnt:=cnt+1;
         casheread:=dskbuf[cnt-1];
    end;

begin
     assign(f, fname);
     {$I-} reset(f, 1); {$I+} eb:=ioresult;
     if eb=0 then
     begin
          {set up globals}
          port[$3c8]:=0; for i:=0 to 767 do port[$3c9]:=0;
          cnt:=0; cursize:=0; ecode:=0;
          if filesize(f)<1920 then ecode:=3;
          if ecode=0 then
          begin
               {pcx header}
               blockread(f, hdrb, 128);

               {256 colour palette}
               seek(f, filesize(f)-768); blockread(f, palb, 768);
               seek(f, 128); {actual data}
          end;

          {complete encoding test}
          with hdrb do
          begin
		if manufacturer<>10 then ecode:=3;
		if encoding<>1 then ecode:=3;
		if bits_per_pixel<>8 then ecode:=3;
		if nplanes<>1 then ecode:=3;
	  end;
          if ecode<>3 then
          begin
               {calc needy vars}
               dx:=(hdrb.xmax-hdrb.xmin)+1; dy:=(hdrb.ymax-hdrb.ymin)+1;
               tot:=longint(dx) * longint(dy);
               mc:=0;

               while (mc<tot) and (ecode=0) do
               begin
                    dta:=casheread;
                    if (dta and $c0) = $c0 then
                    begin {run-length-encoding}
                         rle:=casheread; dta:=dta and $3f;
                         for i:=0 to dta-1 do
                             putpixel((mc+i) mod dx, (mc+i) div dx, rle);
                         inc(mc, dta);
                    end else
                    begin {no compression}
                         putpixel(mc mod dx, mc div dx, dta);
                         inc(mc);
                    end;
               end;
               close(f);
              { for j:=0 to 100 do
               begin} j:=100;
                    port[$3c8]:=0;
                    for i:=0 to 767 do port[$3c9]:=round(palb[i]*j/100) div 4;
              { end; }
               pcxbackground:=true;
          end;
     end else pcxbackground:=false;
end;

procedure waitretrace;assembler;
asm
   mov dx,3DAh
   @loop1:
   in al,dx
   and al,08h
   jnz @loop1
   @loop2:
   in al,dx
   and al,08h
   jz @loop2
end;

var i, j, k : word;
    x, y, deg, w : real;
    f : file;
    c : array[0..768] of real;

begin
     initmode;
     {any 640x400 pcx file, 8bit}
     if pcxbackground('yourfile.pcx') then
     begin
          x:=0; y:=0; deg:=0;
          while keypressed do readkey;

          repeat
                moveto(round(160+x), round(100+y));
                x:=160*sin(deg*2)*cos(deg);
                y:=100*sin(deg/2)*sin(deg);
                deg:=deg+0.001;
          until keypressed;
     end;

     asm
        mov ah, 0
        mov al, 03h
        int 10h
     end;
end.
--Message-Boundary-5639
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Text from file 'RS232.PAS'

{ By Jaco van Niekerk - sparky@lantic.co.za
   (Any problems, feel free to mail me)

  Unit to handle RS232 communication
  Set the COM ports up with open_serial
  Shut down with close_serial
  recieve_byte and send_byte fot the communication }

{Please note : I take NO responsibility on the effect of the code  }
{              I've tested it on many machines, so I can't see any }
{              reason why it should not work on yours.             }


unit rs232;

interface

const COM_1 = $3f8;
      COM_2 = $2f8;

      SER_BAUD_600 = 192;
      SER_BAUD_1200 = 96;
      SER_BAUD_2400 = 48;
      SER_BAUD_9600 = 12;
      SER_BAUD_19200 = 6;
      SER_BAUD_115200 = 1;

      SER_STOP_1 = 0;
      SER_STOP_2 = 4;

      SER_BITS_5 = 0;
      SER_BITS_6 = 1;
      SER_BITS_7 = 2;
      SER_BITS_8 = 3;

      PARITY_NONE = 0;
      PARITY_ODD = 8;
      PARITY_EVEN = 24;

var chars_waiting : integer;

procedure open_serial(port_base, baud, configuration : word);
procedure close_serial;

function receive_byte:byte;
procedure send_byte(thingy : byte);

implementation
uses dos;

const Max_buffer_size = 8192;   {8kb circular buffer}

{these variables CAN NOT be implemented as locals
{and must therefore be declared global}

var open_port : word;
    serial_lock : byte;
    old_int_mask : byte;
    old_handler : procedure;
    my_buffer : array[0..Max_buffer_size-1] of byte;
    buf_read, buf_write : integer;

procedure my_handler;interrupt;
var my_byte : byte;
begin
     serial_lock:=1;                    {lock the buffer}
     my_byte:=port[open_port + 0];      {get byte from harware port}
     my_buffer[buf_write]:=my_byte;     {put byte into software buffer}

     buf_write:=(buf_write+1) mod Max_buffer_size;  {add + wrap around}
     inc(chars_waiting);                            {one more byte}

     port[$20]:=$20;          {let PIC know, we are done!}
     serial_lock:=0;          {unlock buffer}
end;

procedure close_serial;
begin
     {disable required interrupts}
     port[open_port + 4]:=0;
     port[open_port + 1]:=0;
     port[$21]:=old_int_mask;

     {give controll back to old handler}
     if (open_port = COM_1) then setintvec($0c, addr(old_handler))
                            else setintvec($0b, addr(old_handler));
end;

procedure open_serial(port_base, baud, configuration : word);
begin
     {set up global variables}
     open_port:=port_base;
     buf_read:=0; buf_write:=0;
     chars_waiting:=0;

     {set the baud rate}
     port[open_port + 3]:=128;
     port[open_port + 0]:=baud and 255; {lsb}
     port[open_port + 1]:=(baud shr 8) and 255; {msb}


     {set the configuration}
     port[open_port + 3]:=configuration;

     {setup interrupts and enable them}
     port[open_port + 4]:=8;               {enable interrupts}
     port[open_port + 1]:=1;               {interrupt CPU for char received}

     {now, take control!}
     if (open_port = COM_1) then
     begin
          getintvec($0c, @old_handler);
          setintvec($0c, addr(my_handler));
     end else
     begin
          getintvec($0b, @old_handler);
          setintvec($0b, addr(my_handler));
     end;

     {tell mr. PIC}
     old_int_mask:=port[$21];
     if (open_port = COM_1) then port[$21]:=old_int_mask and $ef
                            else port[$21]:=old_int_mask and $e7;
end;

function receive_byte:byte;
var ret_this : byte;
begin
     while (serial_lock = 1) do;
     if (chars_waiting>0) then
     begin
          ret_this:=my_buffer[buf_read];                {get next byte}
          buf_read:=(buf_read+1) mod Max_buffer_size;   {add + wrap around}
          dec(chars_waiting);                           {one less byte}
     end else ret_this:=0;
     receive_byte:=ret_this;
end;

procedure send_byte(thingy : byte);
begin
     {pole line-status-register for "ready to send"}
     while not((port[open_port + 5] and $20)=$20) do {nothing};

     {interrupts has to be disbaled while sending is in progress}
     {unfortunatly this makes full-duplex communications not possible}
     asm cli end;
     port[open_port + 0]:=thingy;
     asm sti end;
end;

begin
end.
