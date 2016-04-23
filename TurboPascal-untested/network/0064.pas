unit KJIPX;
{
 Ken Johnson's IPX unit.
 Written November 19th 1996
 kjohnso3@chat.carleton.ca

 A list of the functions/procedures and what they do:

procedure closesocket(socketnum : word);
   Closes a socket.

procedure opensocket(socketnum : word);
   Opens a socket

procedure sendpacket(var ecbpointer);
   This will send a packet, the ecb and ipx records
   should be filled.


procedure scheduleIPXevent(Var ECB;tick_tock : Word);
   Schedule an IPX event. Not really used that often.

Procedure RelinquishControl;
   Give the IPX driver time to do some work

procedure listenforpacket(Var ecb);
   This will listen for a packet but won't wait for one to be
   received.

procedure myaddrASM(var bufferout);
     Get your own address

function  IPXinstalled : Boolean;
    True if IPX is installed

procedure setuplistenECB(Var ecb : tecb;var ipx : tipxheader;
                         var d : datagramrec);
    This sets up your Event control block to get it ready to
    receive data.

procedure setupipxhead(contosendto : Byte;Var ipxhead : tipxheader);
    Sets up an ipx header

procedure setupecb(con : Word;Var ecb : tecb;var ipx : tipxheader;
                   Var d : datagramrec);
    Sets up ecb to send a packet

procedure callint(sub : Byte;Var bufferin,bufferout);
    Internal function

procedure getinternetaddress(con : Byte;VAr A : tinternetworkaddress);
    Get an internet address. If you have someones connection number,
    you can get their address on the network.

Function compareaddress(thisone,thatone : welcomerec) : Boolean;
   Compare two address to see if they are the same.
   IF they are then CompareAddress is true.

}


interface
uses kjnet;

type
     TnetworkAddress=array[1..4] of byte; { hi-endian }
     TnodeAddress   =array[1..6] of byte; { Hi-endian }

  TinterNetworkAddress=record
     net   :array[1..4] of byte; {hi-lo}
     node  :array[1..6] of byte;{hi-lo}
     socket:word;            {lo-hi}
  end;
  welcomerec = record {just some stuff for a chat program...}
    name    : string;
    a       : tinternetworkaddress;
    con     : Byte;
    quote   : string;
    control : Char;
  end;

 datagramRec = array[1..546] of Byte;  {where you put the data to send}
 tipxheader = record
   checksum : word;
   Len      : word;
   control  : byte;
   packettype : byte;
   dest,
   source : tinternetworkaddress;
 end;
  tfrag = record
    FragPtr : pointer;
    Size : Word;
  end;
  tECB = record
    Link         : pointer;
    ESR          : pointer;
    inuse        : byte;
    code         : byte;
    socketnum    : word;
    ipxworkspace : array[1..4]  of byte;
    driver       : array[1..12] of byte;
    localnode    : array[1..6]  of byte;
    fragcount    : word;
    fragdata     : array[1..2]  of tfrag;
  end;

procedure closesocket(socketnum : word);
procedure opensocket(socketnum : word);
procedure sendpacket(var ecbpointer);
procedure scheduleIPXevent(Var ECB;tick_tock : Word);
Procedure RelinquishControl;
procedure listenforpacket(Var ecb);
procedure myaddrASM(var bufferout);
function  IPXinstalled : Boolean;
procedure setuplistenECB(Var ecb : tecb;var ipx : tipxheader;
                         var d : datagramrec);
procedure setupipxhead(contosendto : Byte;Var ipxhead : tipxheader);
procedure setupecb(con : Word;Var ecb : tecb;var ipx : tipxheader;
                   Var d : datagramrec);
procedure callint(sub : Byte;Var bufferin,bufferout);
procedure getinternetaddress(con : Byte;VAr A : tinternetworkaddress);
Function compareaddress(thisone,thatone : welcomerec) : Boolean;

Const
  openuntilclosed     = $ff;
  openuntilterminated = $00;
  doomsocket = $869c;
  filesocket = $451;
  novellsocket = $8000;
Var
  sockettype : byte;
  result : byte;
  listensocket,sendon : word;


implementation
{---------------------------------------------------------------------------}
Function compareaddress(thisone,thatone : welcomerec) : Boolean;
var a : Boolean;
    x : byte;
  begin
    compareaddress := false;
    For x := 1 to 4 do
    if not (thisone.a.net[x] = thatone.a.net[x]) then EXit;
    for x := 1 to 6 do
      if not (thisone.a.node[x] = thatone.a.node[x]) then exit;
    Compareaddress := true;
  end;

{--------------------------------------------------------------------------}
procedure callint(sub : Byte;Var bufferin,bufferout);assembler;
  asm
    push ds
    push si  {push source index as well}
    Mov ah,$e3
    lds si,bufferin
    les di,bufferout
    int $21
    pop si
    pop ds
  end;
{--------------------------------------------------------------------------}
procedure getinternetaddress(con : Byte;VAr A : tinternetworkaddress);
type
  request = record
    len : word;
    sub : byte;
    c   : byte;
  end;
 reply = record
   len : word;
   a : tinternetworkaddress;
 end;
Var
  bufferin : request;
  bufferout : reply;
  begin
    Fillchar(bufferout,sizeof(Bufferout),0);
    bufferout.len := sizeof(bufferout)-2;
    with bufferin do
      begin
        len := 2;
        sub := $13;
        c := con;
      end;
   Callint($e3,bufferin,bufferout);
   Bufferout.a.socket := swap(bufferout.a.socket);
   move(bufferout.a,a,sizeof(a));
  end;
{--------------------------------------------------------------------------}
function IPXinstalled : Boolean;assembler;
  asm
    mov ax,7a00h
    int $2f
    mov [byte ptr ipxinstalled],al
  end;
{------------------------------------------------------------------------}
procedure closesocket(socketnum : word);
var i:word;
  begin
   i := swap(Socketnum);
     asm
       xor cx,cx
       mov bx,0001h
       mov dx,i
       int $7a
     end;
  end;
{------------------------------------------------------------------------}
procedure opensocket(socketnum : word);
var i : word;
  begin
    i := swap(socketnum);
      asm
        mov bx,0000h
        mov dx,i
        mov al,sockettype
        int $7a
        mov [byte ptr result],al
      end;
  end;
{------------------------------------------------------------------------}
procedure sendpacket(var ecbpointer);assembler;
  asm
    mov bx,$0003
    push bp
    les si,ecbpointer
    int $7a
    mov [byte ptr result],al
    pop bp
  end;
{------------------------------------------------------------------------}
procedure scheduleIPXevent(Var ECB;tick_tock : Word);assembler;
  asm
    mov bx,0005h
    mov ax,tick_tock
    les si,ECB  {event control block}
    int $7a
  end;
{------------------------------------------------------------------------}
Procedure RelinquishControl;assembler;
  asm             {app is idle and IPX can do work}
    mov bx,$000a
    int $7a
  end;
{------------------------------------------------------------------------}
procedure listenforpacket(Var ecb);assembler;
  asm
    mov bx,$0004
    push bp
    les si,ecb
    int $7a
    mov [byte ptr result],al
    pop bp
  end;
{------------------------------------------------------------------------}
procedure myaddrASM(var bufferout);assembler;
  asm
{    push es}
    mov bx,0009h
    les si,bufferout
    int $7a
{    pop es   }
  end;
{------------------------------------------------------------------------}
procedure setuplistenECB(Var ecb : tecb;var ipx : tipxheader;
                         var d : datagramrec);
var
  t : tnodeaddress;
  tick : word;
  dest : tinternetworkaddress;
  begin
    fillchar(ecb,sizeof(ecb),0);
    fillchar(ipx,sizeof(ipx),0);
    with ecb do
      begin
        socketnum := swap(listensocket);
        Fragcount := 2;
        fragdata[1].size := sizeof(ipx);
        fragdata[1].fragptr := @ipx;
        fragdata[2].size := sizeof(D);
        fragdata[2].fragptr := @d;
      end;
  end;
{------------------------------------------------------------------------}
procedure setupecb(con : Word;Var ecb : tecb;var ipx : tipxheader;
                   Var d : datagramrec);
var
  t : tnodeaddress;
  tick : word;
  begin
    fillchar(ecb,sizeof(ecb),0);
    With ecb do
      begin
        socketnum := swap(sendon);
        if not (Con = 0) Then
            Move(ipx.dest.node,localnode,sizeof(localnode)) else
        Fillchar(localnode,sizeof(localnode),$ff);
        fragcount := 2;
        fragdata[1].size    := sizeof(tipxheader);
        fragdata[1].fragPTR := @(IPX);{pointer to IPX}
        fragdata[2].size    := sizeof(d);
        fragdata[2].fragptr := @(d);
      end;
  end;
{------------------------------------------------------------------------}
procedure setupipxhead(contosendto : Byte;Var ipxhead : tipxheader);
  begin
    fillchar(ipxhead,sizeof(ipxhead),0);
    if not (contosendto = 0) Then
        getinternetaddress(contosendto,ipxhead.dest) else
        fillchar(ipxhead.dest.node,6,$ff);
    with ipxhead do
      begin
        checksum      := swap(0);
        len           := swap(sizeof(ipxhead));
        dest.socket   := swap(sendon);
      end;
  end;
{------------------------------------------------------------------------}
begin
  sockettype := openuntilterminated;
  sendon := $5678;
  listensocket := $5678;
end.
