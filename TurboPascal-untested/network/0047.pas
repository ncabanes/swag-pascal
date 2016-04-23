{
I have an IPX unit I would like to contribute to SWAG.  It uses the
advanced calls in Netware 2.0a and above.  (INT 2F/AX = 7A00)  This is
now the recomended way to interface the IPX unlike INT 7A.  I have seen
a few IPX units but they all use INT 7A.  Mine is the only one I have
seen using the new procedures.

Thanks!
Jack Neely
}

unit IPX;
{Version 1.0  Copyright 1997 Jack Neely.  All rights reserved.}

{This unit provides IPX interface.  Requirements are Novell
NetWare 2.0a or higher.  This uses the new IPX call INT 2F/AX=7A00h.
This calls no interrupts save for in the init section.  TSR safe.

If needed (by you or anyone) there are other IPX functions that can be added
to this unit.  If you would like to contact me for whatever reason my e-mail
address is below.  Enjoy!

Jack Neely
hneely@ac.net
http://www.ac.net/~hneely/
}

interface

type
	netAddr  = array[1..4] of byte;    { The address of a network }
	nodeAddr = array[1..6] of byte;    { The address of a node in a network }
	address  = array[0..1] of word;    { A pointer to the data 0=offset 1=seg }
	netAddress = record
		Net    : netAddr;   { network address }
		Node   : nodeAddr;  { node address }
		Socket : word;      { Big endian socket number}
		end;
	localAddrT = record
		Net    : netAddr;   { my network address }
		Node   : nodeAddr;  { my node address }
		end;
	ECBType = record
		link      : address;    { Pointer to next ECB? }
		ESR       : address;    { Event Service Routine 00000000h if none }
		inUse     : byte;       { In use flag }
		complete  : byte;       { Completeing flag }
		socket    : word;       { Big endian socket number }
		IPXwork   : array[1..4] of byte;  { IPX work space }
		Dwork     : array[1..12] of byte; { Driver work space }
		immedAddr : nodeAddr;   { Immediate local node address }
		fragCount : word;       { Fragment count }
		fragData  : address;    { Pointer to data fragment }
		fragSize  : word;       { Size of data fragment }
		end;
	IPXheader = record
		check  : word;                { big endian checksum }
		length : word;                { big endian length in bytes }
		tc     : byte;                { transport control }
		pType  : byte;                { packet type }
		dest   : netAddress;          { destination network address }
		src    : netAddress;          { source network address }
		end;

const
	BROADCAST : nodeAddr = ($ff,$ff,$ff,$ff,$ff,$ff);  { Address for broadcast }

var
        IPXInstalled:boolean;  {You MUST check this BEFORE calling ANY procs}
        API:procedure;         {FAR entry point.}
        localAddr:localAddrT;   {Filled during init}
        major, minor:word;     {Verson of IPX}
        t1, t2:word;           {temps}

procedure InitSendPacket(var ecb:ecbType; var ipx:ipxHeader; size, sock:word);
{Constructs and preinitializes Transmission packet.  Required before usage.}

procedure InitReceivePacket(var ecb:ecbType; var ipx:ipxHeader; size, sock:word);
{Constructs and preinitializes reception packet.  Required before usage.}

function  IPXopenSocket(longevity : byte; var socketNumber : word):byte;
{Open a socket for use.  You must open a socket to use the IPX.
   LONGEVITY is 0 for open until close or terminate, FF for open until
   close.  TSRs need to use FF, non-resident programs should use 0.
   SOCKETNUMBER can by 0000 for dynamic allocation.  Retunrs 0 if
   successful.}

procedure IPXcloseSocket(socketNumber : word);
{Closes SOCKETNUMBER socket.  This cancels all pending events set by any
   ECBs.  Applications should close all sockets before termination.}

procedure IPXsendPacket(var E : ECBtype);
{E is an ECB.  This procedure attemps to send a packet in the background,
   therefore it always returns imediantly.}

function  IPXlistenForPacket(var E : ECBtype):byte;
{E is an ECB.  Returns 00 if successful else FF.  This provides the IPX
   with an ECB for recieving an IPX packet, but does not wait for a
   packet to arrive.  The calling app must have opend a socket and
   initilizied the ECB.  There is no limit to the number of packets that
   can be listening on the same socket.}

procedure GetLocalAddress(var localAddr:localAddrT);
{Returns intrernetwork address.}

procedure Idle;
{This call returns nothing but tells the IPX driver that the app is idle
   and permits the IPX driver to do some work.}


implementation

function  IPXopenSocket(longevity : byte; var socketNumber : word):byte;
var
   return:byte;
   n:word;
begin
   n:= swap(socketnumber);
   asm
      mov bx, 0000h;
      mov al, longevity;
      mov dx, n;
      call API;
      mov return, al;
      mov n, dx;
   end;
   socketnumber:= swap(n);
   IPXOpenSocket:= return;
end;

procedure IPXcloseSocket(socketNumber : word);
begin
   socketnumber:= swap(socketnumber);
   asm
      mov bx, 0001h;
      mov dx, socketnumber;
      call API;
   end;
end;

procedure IPXsendPacket(var E : ECBtype);
begin
   t1:= seg(e);
   t2:= ofs(e);
   asm
      mov bx, 0003h;
      mov es, t1;
      mov si, t2;
      call API;
   end;
end;

function  IPXlistenForPacket(var E : ECBtype):byte;
var
   return:byte;
begin
   t1:= seg(e);
   t2:= ofs(e);
   asm
      mov bx, 0004h;
      mov es, t1;
      mov si, t2;
      call API;
      mov return, al;
   end;
   IPXListenforPacket:= return;
end;

procedure GetLocalAddress(var localAddr:localAddrT);
begin
   t1:= seg(localaddr);
   t2:= ofs(localaddr);
   asm
      mov bx, 0009h;
      mov es, t1;
      mov si, t2;
      call API;
   end;
end;

procedure Idle;
begin
   asm
      mov bx, 000Ah;
      call API;
   end;
end;

procedure InitSendPacket(var ecb : ecbType; var ipx : ipxHeader; size,sock : word);
begin
	fillChar(ecb,sizeOf(ecb),#0);
	fillChar(ipx,sizeOf(ipx),#0);
	with ecb do begin
		socket:=swap(sock);               { Big endian socket number }
		fragCount:=1;                     { Fragment count }
		fragData[0]:=ofs(IPX);            { Pointer to data fragment }
		fragData[1]:=seg(IPX);
		fragSize:=sizeof(IPX)+size;       { Size of data fragment }
		immedAddr:=BROADCAST;             { Needs to be BROADCAST?? }
		end;
	with ipx do begin
		check:=$ffff;                     { NO CHECKSUM }
		ptype:=0;                         { Packet exchange packet }
		dest.net:=localAddr.net;          { Send to this network }
		dest.node:=BROADCAST;             { Send to everybody! }
		dest.socket:=swap(sock);          { Send to my socket }
		src.net:=localAddr.net;           { From this net }
		src.node:=localAddr.node;         { From ME }
		src.socket:=swap(sock);           { From my socket }
		end;
end;

procedure InitReceivePacket(var ecb : ecbType; var ipx : ipxHeader; size,sock : word);
begin
  fillChar(ecb,sizeOf(ecb),#0);
  fillChar(ipx,sizeOf(ipx),#0);
  with ecb do begin
	inUse:=$1d;                               { ???? }
	socket:=swap(sock);                       { Big endian socket number }
	fragCount:=1;                             { Fragment count }
	fragData[0]:=ofs(IPX);                    { Pointer to data fragment }
	fragData[1]:=seg(IPX);
	fragSize:=sizeof(IPX)+size;               { Size of data fragment }
  end;
end;

var
   t:byte;

begin
   asm
      mov ax, 7a00h;
      int 2fh;
      mov t, al;
      mov major, es;
      mov minor, bx;
      mov t1, es;
      mov t2, di;
   end;
   IPXInstalled:= (t=$FF);
   if IPXInstalled then
      begin
         @API:= ptr(t1, t2);
         getlocaladdress(localaddr);
      end
   else
      @API:= nil;
end.
