{
Hallo Swag Team

You wrote that there would be other users trying to interface DOS machines to
the Winsock interface. So I'd like to ask, if it is possible to bring us
together in 
any kind, because I started a little piece of coding which I think is the fist
step,
and it might be usefull to discuss with the others. Here it is:

It's based on the TCPIP.EXE found at Novell as TCP16.EXE self extracting.
you have to extract, then use the following to setup the Network.

LSL.COM           starts the ...
e.g. 200ep.com   the hardware driver for your network ethernet card,
                               can be anything other as well, but I think it
must me ethernet
TCPIP.EXE       the TCP protocol stack

the NET.CFG looks like this:
--------------------------------------
Link Driver 200ep
   int 10
   port 240
   frame ETHERNET_II

Link Support
   Buffers 16 1518
   MemPool 2048

Protocol TCPIP
   ip_address 192.0.0.104
---------------------------------------
Now with having no network shell, you already have a DOS based TCP-Stack

There is a PING program, that will now find other TCP-Stacks in your network,
if you call PING <other IP adress>

Now based on this, I have some Pascal code that looks like this:
---------------------------------------------------------------------------------
-------}

unit tcp_lib;
 { Thomas Kerkmann  CIS 100576,3276
 
   based on information found in  Ralf Browns Interrupt list Release 51 
     available at the BORLAND DELPHI FORUM Section 17 TP/BP DOS Prog
    as the 	Programmers interrupt bible

   Internet: ralf@pobox.com (currently forwards to ralf@telerama.lm.com) 
   UUCP: {uunet,harvard}
{
   pobox.com!ralf
   FIDO: Ralf Brown 1:129/26.1
	or post a message to me in the DR_DEBUG echo (I probably won't see it
	unless you address it to me)
   CIS:  >INTERNET:ralf@pobox.com
}
Interface
type
   IPstring = string[15];
const
   err_timedout = 60;

   function tcp_installed:boolean;
   function tcp_GetIPAdress:LongInt;
   function tcp_OpenSocket:byte;
   function tcp_CloseSocket(sock:byte):byte;
   function tcp_Connect (sock:byte; IPAdr:LongInt; Port:word):byte;
   function tcp_Listen (sock:byte; Port:word):byte;
   { helpers }
   function tcp_IPAdrToStr(ip:LongInt):IPstring;
   function tcp_ResultStr(result:byte):string;

Implementation
uses
   dos;

CONST
   EntryPoint : Pointer = NIL;
   Version    : word    = 0;

TYPE
   pTCP_PARMS = ^tTCP_PARMS;
   tTCP_PARMS = record
      byte0        : byte;          { 00 }
      byte1        : byte;          { 01 }
      byte2        : byte;          { 02 }
      byte3        : byte;          { 03 }
      word0        : word;          { 04 }
      word1        : word;          { 06 }
      CallBack     : Pointer;       { 08 }
      flags        : byte;          { 0C }
      sevenbytes   : array[1..7] of byte;
      byte4        : byte;
      functioncode : byte;
      socket       : byte;
      result       : byte;
      ParmWords    : array[0..15] of word;
   end;

procedure CallEntryPoint(rec:pTCP_PARMS); assembler;
asm
   les si,rec
   call dword ptr EntryPoint
end;

function tcp_installed:boolean;
var
   r : registers;
begin
   tcp_installed := false;

   R.AX := $7A40;
   Intr ($2F,R);
   if r.ax=$7AFF then
    begin
      EntryPoint   := Ptr(R.ES,R.DI);
      Version       := r.cx;
      tcp_installed := true;
    end;
end;

function tcp_GetIPAdress:LongInt;
var
   parms : tTCP_PARMS;
   l     : LongInt;
begin
   FillChar (parms,sizeof(parms),0);
   parms.functioncode := $05;
   if EntryPoint<>NIL then
      callEntryPoint(@parms)
   else
      writeln ('ERROR: tcp/ip is not installed');
   Move (parms.Parmwords[1],l,4);
   tcp_GetIPAdress := l;
end;

function tcp_OpenSocket:byte;
var
   parms:tTCP_PARMS;
begin
   tcp_OpenSocket := 0;
   FillChar (parms,sizeof(parms),0);
   parms.functioncode := $11;  { open socket }
   parms.ParmWords[0] := 6;    { required TCP protocol }
   callEntryPoint (@parms);
   if parms.result=0 then
      tcp_OpenSocket := parms.socket
   else
      writeln ('ERROR: OpenSocket=',parms.result);
end;

function tcp_CloseSocket(sock:byte):byte;
var
   parms:tTCP_PARMS;
begin
   FillChar (parms,sizeof(parms),0);
   parms.functioncode := $03;  { close socket }
   parms.socket := sock;
   callEntryPoint (@Parms);
   tcp_CloseSocket := parms.result;
end;

function tcp_Connect (sock:byte; IPAdr:LongInt; Port:word):byte;
var
   parms:tTCP_PARMS;
begin
   FillChar (parms,sizeof(parms),0);
   parms.functioncode := $04;          { connect }
   parms.Socket := sock;
   parms.ParmWords[1] := Port;
   Move (IPAdr,parms.Parmwords[2],4);  { set IP address }
   callEntryPoint (@Parms);
   tcp_Connect := parms.result;
end;

function tcp_Listen (sock:byte; Port:word):byte;
var
   parms:tTCP_PARMS;
begin
   FillChar (parms,sizeof(parms),0);
   parms.functioncode := $0C;          { listen }
   parms.Socket := sock;
   parms.ParmWords[1] := Port;
   callEntryPoint (@Parms);
   tcp_Listen := parms.result;
end;

{ helpers }

function intToStr(i:LongInt):string;
var
   s : string[15];
begin
   str (i,s);
   IntToStr := s;
end;

function tcp_IPAdrToStr(ip:LongInt):IPstring;
var
   b : array[0..3] of byte absolute ip;
   s : IPstring;
   i : integer;
begin
   s := '';
   for i:=0 to 3 do
    begin
      s := s + InttoStr(b[i]);
      if i<3 then s := s + '.';
    end;
   tcp_IPAdrToStr := s;
end;

function tcp_ResultStr(result:byte):string;
begin
   case result of
     60   : tcp_ResultStr := 'TIMEDOUT';
     else   tcp_ResultStr := IntToStr(result);
   end;
end;

end.
---------------------------------------------------------------------------------
-------

And a little program trying to use it

---------------------------------------------------------------------------------
--------
program test;
uses
   mylib,
   tcp_lib;
var
   ipadr  : longInt;
   sock   : byte;
   result : byte;
begin
   if tcp_installed then
    begin
      writeln ('tcp/ip protocol stack installed');
      ipadr := tcp_GetIPAdress;
      writeln ('tcp_GetIPAdress returned : ',tcp_IPAdrToStr(ipadr));
      sock := tcp_opensocket;
      writeln ('tcp_opensocket returned : ',sock);

      result := tcp_Listen (sock,5000);
      writeln ('tcp_listen result=',tcp_ResultStr(result));

      write ('[ENTER] to close socket'); readln;
      result := tcp_closesocket (sock);
      writeln ('tcp_closesocket result=',result);
    end
   else
      writeln ('tcp/ip protocol stack not found');
end.
---------------------------------------------------------------------------------
-----
It will run including opening a socket, but I don't know how to 
continue for starting to LISTEN or to CONNECT to another TCP-IP
Software in the Network. If you try, please don't reboot to quickly,
the LISTEN call will hang for about 1-2 minutes, but will return back
to your program.

If somebody can find out how to continue, please let me know.

Kind regards from

Thomas

