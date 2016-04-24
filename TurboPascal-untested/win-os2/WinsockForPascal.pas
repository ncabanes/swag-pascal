(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0082.PAS
  Description: WINSOCK for Pascal
  Author: DARRYL LUFF
  Date: 11-25-95  09:26
*)


UNIT Winsock;
{ WINSOCK.H converted to Pascal - Darryl Luff 15Nov95 }
{ Not fully tested, please send corrections to either:}
{ dluff@ibm.net,  luffd@ocean.com.au, or              }
{ Darryl Luff at Fido 3:632/506.4                     }

interface
USES
  WinTypes;

TYPE
  { basic type definitions, from BSD sys/types.h }
  u_char  = Byte;
  u_short = Word;
  u_int   = Word;
  u_long  = Longint;  { not really, as longint is signed }

  { new type to be used in all instances which refer to sockets }
  TSocket   = u_int;

  { macros to manipulate the socket arrays }
CONST
  FD_SETSIZE = 64;

TYPE
  Tfd_set = Record  { originally fd_set but name clashed }
    fd_count : u_short;
    fd_array : Array[0..FD_SETSIZE-1] OF TSocket;
  END;

FUNCTION __WSAFDIsSet(s : TSocket; VAR fds : Tfd_set): Integer; {external }

PROCEDURE FD_CLR(fd : TSocket; VAR fdset : Tfd_set);
FUNCTION  FD_ISSET(fd : TSocket; VAR fdset : Tfd_set): Integer;
PROCEDURE FD_SET(fd : TSocket; VAR fdset : Tfd_set);
PROCEDURE FD_ZERO(VAR fdset : Tfd_set);

{ structure used in select() call, from BSD sys/time.h }
TYPE
  timeval = Record
    tv_sec,             { seconds }
    tv_usec : Longint;  { microseconds }
  END;

{ operations on timevals }
FUNCTION timerisset(tvp : timeval): Longint;
FUNCTION timercmp(tvp, uvp : timeval; cmp : String): Boolean;
{ the original timercmp took a third parameter of the operator }
{ (was a 'c' macro. But, the original couldn't handle 2        }
{ character operators ('>=' etc) so we're a bit better off.    }


{ commands for ioctlsocket(), taken from BSD fcntl.h }
CONST
  IOCPARM_MASK  = $7F;                { parms must be <= 128 bytes }
  IOC_VOID      = $20000000;          { no parameters }
  IOC_OUT       = $40000000;          { copy out parameters }
  IOC_IN        = $80000000;          { copy in parameters }
  IOC_INOUT     = IOC_IN OR IOC_OUT;
                  { $20000000 distinguishes new and old ioctl's }

FUNCTION _IO(x, y : Byte): Longint;
FUNCTION _IOR(x : Char; y : Byte; tSize : Integer): Longint;
{ original took a type as the third parameter, and }
{ used 'sizeof' to get size. (c macro)             }
FUNCTION _IOW(x : Char; y, tSize : Longint): Longint;
{FUNCTION _IOW(x : Char; y : Byte; tSize : Word): Longint;}
{ as above }
FUNCTION FIONREAD: Longint;     { get number of bytes to read }
FUNCTION FIONBIO: Longint;      { set/clear non-blocking I/O }
FUNCTION FIOASYNC: Longint;     { set/clear async I/O }

FUNCTION SIOCSHIWAT: Longint;   {set high watermark }
FUNCTION SIOCGHIWAT: Longint;   { get high watermark }
FUNCTION SIOCSLOWAT: Longint;   { set lo watermark }
FUNCTION SIOCGLOWAT: Longint;   { get lo watermark }
FUNCTION SIOCATMARK: Longint;   { at oob mark ? }


{ structures returned by network database library, taken }
{ from BSD file netdb.h. All addresses are supplied in   }
{ host order, and returned in network order.             }

CONST
  MAXALIASES   = 99; { ? }
  MAXADDRESSES = 99; {?}
TYPE
  PAliasList = ^TAliasList;
  TAliasList = Array[0..MAXALIASES-1] OF PChar;
  PAddressList = ^TAddressList;
  TAddressList = Array[0..MAXADDRESSES-1] OF ^u_long;
  { I made these up for the below }

  Phostent = ^hostent;
  hostent = Record
    h_name      : PChar;        { official name of host }
    h_aliases   : PAliasList;   { see above }
    h_addrtype  : Integer;      { host address type }
    h_length    : Integer;      { length of address }
    CASE Boolean OF
      False : (h_addr_list : PAddressList);
      True  : (h_addr      : ^u_long);
    { #define h_addr h_addr_list[0]   for compatibility }
  END;

  { assumed here that a network number fits into 32 bits }
  netent = Record
    n_name      : PChar;        { official name of net }
    n_aliases   : PAliasList;   { alias list }
    n_addrtype  : Integer;      { net address type }
    n_net       : Longint;      { network # }
  END;

  Pservent = ^servent;
  servent = Record
    s_name      : PChar;        { official service name }
    s_aliases   : PAliasList;   { alias list }
    s_port      : Integer;      { port # }
    s_proto     : PChar;        { protocol to use }
  END;

  Pprotoent = ^protoent;
  protoent = Record
    p_name      : PChar;        { official protocol name }
    p_aliases   : PAliasList;   { alias list }
    p_proto     : Integer;      { protocol # }
  END;


{ constants and structures defined by the internet system, }
{ Per RFC790, Sept. 1981. taken from BSD netinet/in.h      }
CONST
  { protocols }
  IPPROTO_IP    = 0;            { dummy for IP }
  IPPROTO_ICMP  = 1;            { control message protocol }
  IPPROTO_GGP   = 2;            { gateway^2 (deprecated) }
  IPPROTO_TCP   = 6;            { tcp }
  IPPROTO_PUP   = 12;           { pup }
  IPPROTO_UDP   = 17;           { udp }
  IPPROTO_IDP   = 22;           { xns idp }
  IPPROTO_ND    = 77;           { UNOFFICIAL net disk proto }

  IPPROTO_RAW   = 255;          { raw IP packet }
  IPPROTO_MAX   = 256;

  { port/socket numbers: network standard functions }
  IPPORT_ECHO       = 7;
  IPPORT_DISCARD    = 9;
  IPPORT_SYSTAT     = 11;
  IPPORT_DAYTIME    = 13;
  IPPORT_NETSTAT    = 15;
  IPPORT_FTP        = 21;
  IPPORT_TELNET     = 23;
  IPPORT_SMTP       = 25;
  IPPORT_TIMESERVER = 37;
  IPPORT_NAMESERVER = 42;
  IPPORT_WHOIS      = 43;
  IPPORT_MTP        = 57;

  { port/socket numbers: host specific functions }
  IPPORT_TFTP       = 69;
  IPPORT_RJE        = 77;
  IPPORT_FINGER     = 79;
  IPPORT_TTYLINK    = 87;
  IPPORT_SUPDUP     = 95;

  { UNIX TCP sockets }
  IPPORT_EXECSERVER   = 512;
  IPPORT_LOGINSERVER  = 513;
  IPPORT_CMDSERVER    = 514;
  IPPORT_EFSSERVER    = 520;

  { UNIX UDP sockets }
  IPPORT_BIFFUDP      = 512;
  IPPORT_WHOSERVER    = 513;
  IPPORT_ROUTESERVER  = 520;

  { ports < IPPORT_RESERVED are reserved for }
  { priveledged processes (eg. root)         }
  IPPORT_RESERVED     = 1024;

  { link numbers }
  IMPLINK_IP          = 155;
  IMPLINK_LOWEXPER    = 156;
  IMPLINK_HIGHEXPER   = 158;

TYPE
  { internet address (old style... should be updated }
  in_addr = Record
    CASE Integer OF

      0 : (s_b1, s_b2, s_b3, s_b4 : Byte); {S_un_b}
      1 : (s_w1, s_w2 : Word);             {S_un_w}
      2 : (s_addr : Longint)               {S_addr}
  END; { S_un; }

  {#define s_addr S_un.s_addr}
  {#define s_host S_un.s_un_b.s_b2}
  {#define s_net  S_un.S_un_b.s_b1}
  {#define s_imp  S_un.S_un_w.s_w2}
  {#define s_impno S_un_b.s_b4}
  {#define s_lh    S_un.S_un_b.b_s3}

CONST
  { definition of bits in internet address integers. }
  { on subnets, the decomposition of addresses to    }
  { host and net parts is done according to the      }
  { subnet masks, not the masks here.                }
  {#define IN_CLASSA(i)   (((long)(i) & 0x80000000) == 0) }
  IN_CLASSA_NET     = $FF000000;
  IN_CLASSA_NSHIFT  = 24;
  IN_CLASSA_HOST    = $00FFFFFF;
  IN_CLASSA_MAX     = 128;

  {#define IN_CLASSB(i)  (((long)(i) & 0xc0000000) == 0x80000000) }
  IN_CLASSB_NET     = $FFFF0000;
  IN_CLASSB_NSHIFT  = 16;
  IN_CLASSB_HOST    = $0000FFFF;
  IN_CLASSB_MAX     = 65536;

  {#define IN_CLASSC(i)  (((long)(i) & 0xc0000000) == 0xc0000000) }
  IN_CLASSC_NET     = $FFFFFF00;
  IN_CLASSC_NSHIFT  = 8;
  IN_CLASSC_HOST    = $000000FF;

  INADDR_ANY        = $00000000;
  INADDR_LOOPBACK   = $7F000001;
  INADDR_BROADCAST  = $FFFFFFFF;
  INADDR_NONE       = $FFFFFFFF;

TYPE
  { socket addresses, internet style }
  sockaddr_in = Record
    sin_family : Integer;
    sin_port   : u_short;
    sin_addr   : in_addr;
    sin_zero   : Array[0..7] OF Char
  END;

CONST
  WSADESCRIPTION_LEN = 256;
  WSASYS_STATUS_LEN  = 128;

TYPE
  WSAData = Record
    wVersion        : WORD;
    wHighVersion    : WORD;
    szDescription   : Array[0..WSADESCRIPTION_LEN+1] OF Char;
    szSystemStatus  : Array[0..WSASYS_STATUS_LEN+1] OF Char;
    iMaxSockets     : Word; { unsigned short }
    iMaxUdpDg       : Word; { unsigned short }
    lpVendorInfo    : Pointer;
  END;
  LPWSADATA = ^WSAData;

  { options for use with [gs]etsockopt at the IP level }
CONST
  IP_OPTIONS  = 1;    { set/get IP per-packet options }

  { definitions related to sockets: types, address families, options }
  { taken from BSD sys/socket.h                                      }

  { this is used instead of -1, since the TSocket type is unsigned }
  INVALID_SOCKET = NOT(0);
  SOCKET_ERROR   = -1;

  { types }
  SOCK_STREAM     = 1;  { stream socket }
  SOCK_DGRAM      = 2;  { datagram socket }
  SOCK_RAW        = 3;  { raw-protocol service }
  SOCK_RDM        = 4;  { reliably-delivered message }
  SOCK_SEQPACKET  = 5;  { sequenced packet stream }

  { option flags per socket }
  SO_DEBUG        = $0001;  { turn on debugging info recording }
  SO_ACCEOTCONN   = $0002;  { socket has had listen() }
  SO_REUSEADDR    = $0004;  { allow local address reuse }
  SO_KEEPALIVE    = $0008;  { keep connections alive }
  SO_DONTROUTE    = $0010;  { just use interface addresses }
  SO_BROADCAST    = $0020;  { permit sending of broadcast messages }
  SO_USELOOPBACK  = $0040;  { bypass hardware when possible }
  SO_LINGER       = $0080;  { linger on close if data present }
  SO_OOBINLINE    = $0100;  { leave received OOB data in line }
  SO_DONTLINGER   = NOT (SO_LINGER);

  { additional options }
  SO_SNDBUF       = $1001;  { send buffer size }
  SO_RCVBUF       = $1002;  { receive buffer size }
  SO_SNDLOWAT     = $1003;  { send low-water mark }
  SO_RCVLOWAT     = $1004;  { receive low-water mark }
  SO_SNDTIMEO     = $1005;  { send timeout }
  SO_RCVTIMEO     = $1006;  { receive timeout }
  SO_ERROR        = $1007;  { get error status and clear }
  SO_TYPE         = $1008;  { get socket type }

  { TCP options }
  TCP_NODELAY     = $0001;

  { address families }
  AF_UNSPEC       = 0;      { unspecified }
  AF_UNIX         = 1;      { local to host (pipes, portals) }
  AF_INET         = 2;      { internetwork: UDP, TCP etc }
  AF_IMPLINK      = 3;      { arpanet imp addresses }
  AF_PUP          = 4;      { pup protocols: eg. BSP }
  AF_CHAOS        = 5;      { mit CHAOS protocols }
  AF_NS           = 6;      { XEROX NS protocols }
  AF_ISO          = 7;      { ISO protocols }
  AF_OSI          = AF_ISO;
  AF_ECMA         = 8;      { european computer manufacturers }
  AF_DATAKIT      = 9;      { datakit protocols }
  AF_CCITT        = 10;     { CCITT protocols, X.25 etc }
  AF_SNA          = 11;     { IBM SNA }
  AF_DECnet       = 12;     { DECnet }
  AF_DLI          = 13;     { Direct data link interface }
  AF_LAT          = 14;     { LAT }
  AF_HYLINK       = 15;     { NSC Hyperchannel }
  AF_APPLETALK    = 16;     { AppleTalk }
  AF_NETBIOS      = 17;     { NetBios-style addresses }

  AF_MAX          = 18;

TYPE
  { structure used by the kernel to store most addresses }
  Psockaddr = ^sockaddr;
  sockaddr = record
    sa_family : u_short;              { address family }
    sa_data   : Array[0..13] OF Char; { up to 14 bytes of direct address }
  END;

  { structure used by the kernel to pass protocol }
  { information in raw sockets.                   }
  sockproto = Record
    sp_family   : u_short;  { address family }
    sp_protocol : u_short;  { protocol }
  END;

CONST
  { protocol families, same as address families for now }
  PF_UNSPEC    = AF_UNSPEC;
  PF_UNIX      = AF_UNIX;
  PF_INET      = AF_INET;
  PF_IMPLINK   = AF_IMPLINK;
  PF_PUP       = AF_PUP;
  PF_CHAOS     = AF_CHAOS;
  PF_NS        = AF_NS;
  PF_ISO       = AF_ISO;
  PF_OSI       = AF_OSI;
  PF_ECMA      = AF_ECMA;
  PF_DATAKIT   = AF_DATAKIT;
  PF_CCITT     = AF_CCITT;
  PF_SNA       = AF_SNA;
  PF_DECnet    = AF_DECnet;
  PF_DLI       = AF_DLI;
  PF_LAT       = AF_LAT;
  PF_HYLINK    = AF_HYLINK;
  PF_APPLETALK = AF_APPLETALK;
  PF_MAX       = AF_MAX;

TYPE
  { structure used for manipulating linger option }
  linger = Record
    l_onoff   : u_short;  { option on/off }
    l_linger  : u_short;  { linger time }
  END;

CONST
  { level number for (get/set)sockopt() to apply to socket itself }
  SOL_SOCKET  = $FFFF;    { OPTIONS FOR SOCKET LEVEL }

  { MAXIMUM QUEUE LENGTH SPECIFIABLE BY LISTEN }
  SOMAXCONN   = 5;

  MSG_OOB       = 1;      { process out-of-band packet }
  MSG_PEEK      = 2;      { peek at incoming messages }
  MSG_DONTROUTE = 4;      { send without using routing tables }
  MSG_MAXIOVLEN = 16;

  { define constant based on RFC883, used by gethostbyxxxx() calls }
  MAXGETHOSTSTRUCT = 1024;

  { define flags to be used with the WSAAsynchSelect() call }
  FD_READ       = $01;
  FD_WRITE      = $02;
  FD_OOB        = $04;
  FD_ACCEPT     = $08;
  FD_CONNECT    = $10;
  FD_CLOSE      = $20;

  { all windows sockets error constants are biased }
  { by WSABASEERR from the 'Normal'                }
  WSABASEERR    = 10000;
  WSAEINTR      = WSABASEERR+4;
  WSAEBADF      = WSABASEERR+9;
  WSAEACCES     = WSABASEERR+13;
  WSAEFAULT     = WSABASEERR+14;
  WSAEINVAL     = WSABASEERR+22;
  WSAEMFILE     = WSABASEERR+24;

  { windows sockets definitions of regular berkeley error constants }
  WSAEWOULDBLOCK      = WSABASEERR+35;
  WSAEINPROGRESS      = WSABASEERR+36;
  WSAEALREADY         = WSABASEERR+37;
  WSAENOTSOCK         = WSABASEERR+38;
  WSAEDESTADDRREQ     = WSABASEERR+39;
  WSAEMSGSIZE         = WSABASEERR+40;
  WSAEPROTOTYPE       = WSABASEERR+41;
  WSAENOPROTOOPT      = WSABASEERR+42;
  WSAEPROTONOSUPPORT  = WSABASEERR+43;
  WSAESOCKTNOSUPPORT  = WSABASEERR+44;
  WSAEOPNOTSUPP       = WSABASEERR+45;
  WSAEPFNOSUPPORT     = WSABASEERR+46;
  WSAEAFNOSUPPORT     = WSABASEERR+47;
  WSAEADDRINUSE       = WSABASEERR+48;
  WSAEADDRNOTAVAIL    = WSABASEERR+49;
  WSAENETDOWN         = WSABASEERR+50;
  WSAENETUNREACH      = WSABASEERR+51;
  WSAENETRESET        = WSABASEERR+52;
  WSAECONNABORTED     = WSABASEERR+53;
  WSAECONNRESET       = WSABASEERR+54;
  WSAENOBUFS          = WSABASEERR+55;
  WSAEISCONN          = WSABASEERR+56;
  WSAENOTCONN         = WSABASEERR+57;
  WSAESHUTDOWN        = WSABASEERR+58;
  WSAETOOMANYREFS     = WSABASEERR+59;
  WSAETIMEDOUT        = WSABASEERR+60;
  WSAECONNREFUSED     = WSABASEERR+61;
  WSAELOOP            = WSABASEERR+62;
  WSAENAMETOOLONG     = WSABASEERR+63;
  WSAEHOSTDOWN        = WSABASEERR+64;
  WSAEHOSTUNREACH     = WSABASEERR+65;
  WSAENOTEMPTY        = WSABASEERR+66;
  WSAEPROCLIM         = WSABASEERR+67;
  WSAEUSERS           = WSABASEERR+68;
  WSAEDQUOT           = WSABASEERR+69;
  WSAESTALE           = WSABASEERR+70;
  WSAEREMOTE          = WSABASEERR+71;

  { extended windows sockets error constant definitions }
  WSASYSNOTREADY      = WSABASEERR+91;
  WSAVERNOTSUPPORTED  = WSABASEERR+92;
  WSANOTINITIALISED   = WSABASEERR+93;

  { error return codes from gethostbyname() and gethostbyaddr() }
  { (when using the resolver). note that these errors are       }
  { retrieved via WSAGetLastError() and must therefore follow   }
  { the rules for avoiding clashes with error numbers from      }
  { specific implementations or language run-time systems. for  }
  { this reason the codes are based at WSABASEERR+1001. note    }
  { also that [WSA]NO_ADDRESS is defined only for compatibility }
  { purposes.                                                   }

{#define h_errno WSAGetLastError() }
FUNCTION h_errno: Longint;

CONST
  { authoritative answer: host not found }
  WSAHOST_NOT_FOUND = WSABASEERR+1001;
  HOST_NOT_FOUND    = WSAHOST_NOT_FOUND;

  { non-authoritative: host not found, or SERVERFAIL }
  WSATRY_AGAIN      = WSABASEERR+1002;
  TRY_AGAIN         = WSATRY_AGAIN;

  { non-recoverable errors, FORMERR, REFUSED, NOTIMP }
  WSANO_RECOVERY    = WSABASEERR+1003;
  NO_RECOVERY       = WSANO_RECOVERY;

  { valid name, no data record of requested type }
  WSANO_DATA        = WSABASEERR+1004;
  NO_DATA           = WSANO_DATA;

  { no address, look for MX record }
  WSANO_ADDRESS     = WSANO_DATA;
  NO_ADDRESS        = WSANO_ADDRESS;

  { windows sockets errors redefined as regular berkley error constants }
  EWOULDBLOCK       = WSAEWOULDBLOCK;
  EINPROGRESS       = WSAEINPROGRESS;
  EALREADY          = WSAEALREADY;
  ENOTSOCK          = WSAENOTSOCK;
  EDESTADDRREQ      = WSAEDESTADDRREQ;
  EMSGSIZE          = WSAEMSGSIZE;
  EPROTOTYPE        = WSAEPROTOTYPE;
  ENOPROTOOPT       = WSAENOPROTOOPT;
  EPROTONOSUPPORT   = WSAEPROTONOSUPPORT;
  ESOCKTNOSUPPORT   = WSAESOCKTNOSUPPORT;
  EOPNOTSUPPORT     = WSAEOPNOTSUPP;
  EPFNOSUPPORT      = WSAEPFNOSUPPORT;
  EAFNOSUPPORT      = WSAEAFNOSUPPORT;
  EADDRINUSE        = WSAEADDRINUSE;
  EADDRNOTAVAIL     = WSAEADDRNOTAVAIL;
  ENETDOWN          = WSAENETDOWN;
  ENETUNREACH       = WSAENETUNREACH;
  ENETRESET         = WSAENETRESET;
  ECONNABORTED      = WSAECONNABORTED;
  ECONNRESET        = WSAECONNRESET;
  ENOBUFS           = WSAENOBUFS;
  EISCONNN          = WSAEISCONN;
  ENOTCONN          = WSAENOTCONN;
  ESHUTDOWN         = WSAESHUTDOWN;
  ETOOMANYREFS      = WSAETOOMANYREFS;
  ETIMEDOUT         = WSAETIMEDOUT;
  ECONNREFUSED      = WSAECONNREFUSED;
  ELOOP             = WSAELOOP;
  ENAMETOOLONG      = WSAENAMETOOLONG;
  EHOSTDOWN         = WSAEHOSTDOWN;
  EHOSTUNREACH      = WSAEHOSTUNREACH;
  ENOTEMPTY         = WSAENOTEMPTY;
  EPROCLIM          = WSAEPROCLIM;
  EUSERS            = WSAEUSERS;
  EDQUOT            = WSAEDQUOT;
  ESTALE            = WSAESTALE;
  EREMOTE           = WSAEREMOTE;


{ socket function prototypes }
FUNCTION accept(s : TSocket; VAR addr : sockaddr; VAR addrlen : Integer):
TSocket; FUNCTION bind(s : TSocket; {const} VAR addr : sockaddr; namelen :
Integer): Integer; FUNCTION closesocket(s : TSocket): Integer; FUNCTION
connect(s : TSocket; {const}VAR name : sockaddr; namelen : Integer): Integer;
FUNCTION ioctlsocket(s : TSocket; cmd : LONGINT; VAR argp : u_long): Integer;
FUNCTION gethostname(name : PChar; namelen : Integer): Integer; FUNCTION
getpeername(s : TSocket; VAR name : sockaddr; VAR namelen : Integer): Integer;
FUNCTION getsockname(s : TSocket; VAR name : sockaddr; namelen : Integer):
Integer; FUNCTION getsockopt(s : TSocket; VAR name : sockaddr; namelen :
Integer): Integer; FUNCTION htonl(hostlong : u_long): u_long; FUNCTION
htons(hostshort: u_short): u_short; FUNCTION inet_addr({const}cp : PChar):
u_long; FUNCTION inet_ntoa(in_ : in_addr): Char; FUNCTION listen(s : TSocket;
backlog : Integer): Integer; FUNCTION ntohl(netlong : u_long): u_long;
FUNCTION ntohs(netshort : u_short): u_short; FUNCTION recv(s : TSocket; buf :
Pointer; len, flags : Integer): Integer; FUNCTION recvfrom(s : TSocket; buf :
Pointer; len, flags : Integer; VAR from : sockaddr; VAR fromLen : Integer):
Integer; FUNCTION select(nfds : Integer; VAR readfds, writefds, exceptfds :
Tfd_set; {const}VAR timeout : timeval): Integer; FUNCTION send(s : TSocket;
buf : Pointer; len, flags : Integer): Integer; FUNCTION sendto(s : TSocket;
buf : Pointer; len, flags : Integer; {const}VAR to_ : sockaddr; tolen :
Integer): Integer; FUNCTION setsockopt(s : TSocket; level, optname : Integer;
optval : Pointer; optlen : Integer): Integer; FUNCTION shutdown(s : TSocket;
how : integer): Integer; FUNCTION socket(af, typ, protocol : Integer):
TSocket;
{ database function prototypes }
FUNCTION gethostbyaddr({const}addr : Pointer; len, typ : Integer): Phostent;
FUNCTION gethostbyname({const}name : PChar): Phostent;
FUNCTION getservbyport(port : Integer; proto : Pointer): Pservent;
FUNCTION getservbyname({const}name : PChar; proto : PChar{Pointer}): Pservent;
FUNCTION getprotobynumber(proto : Integer): Pprotoent;
FUNCTION getprotobyname(name : PChar): Pprotoent;

{ windows extension function prototypes }
FUNCTION WSACleanup: integer;
FUNCTION WSAStartup(wVersionRequired : Word; lpwsaData_ : LPWSADATA): Integer;
FUNCTION WSASetLastError(iError : Integer): Integer;
FUNCTION WSAGetLastError: Integer;
FUNCTION WSAIsBlocking: WordBOOL;
FUNCTION WSAUnhookBlockingHook: Integer;
FUNCTION WSASetBlockingHook(lpBlockFunc : TFARPROC): TFARPROC;
FUNCTION WSACancelBlockingCall: Integer;
FUNCTION WSAAsyncGetServByName(hWnd_ : HWND; wMsg : u_int;
         {const} name : PChar; {const} proto : Pointer;
         buf : Pointer; buflen : Integer): Integer;
FUNCTION WSAAsyncGetServByPort(hWnd_ : HWND; wMsg : u_int; port : Integer;
         {const} proto : Pointer; buf : Pointer; buflen : Integer): Integer;
FUNCTION WSAAsyncGetProtoByName(hWnd_ : HWND; wMsg : u_int;
         {const}name : PChar;
         buf : Pointer; buflen : Integer): Integer;
FUNCTION WSAAsyncGetProtoByNumber(hWnd_ : HWND; wMsg : u_int;
         number : Integer; buf : Pointer; buflen : Integer): Integer;
FUNCTION WSAAsyncGetHostByName(hwnd_ : HWND; wMsg : Integer; name : PChar;
         buf : Pointer; buflen : Integer): Integer;
FUNCTION WSAAsynchGetHostByAddr(hwnd_ : HWND; wMsg : u_int;
         addr : Pointer; len, typ : Integer;
         {const}buf : Pointer; buflen : Integer): Integer;
FUNCTION WSACancelAsyncRequest(hAsyncTaskhandle : THANDLE): Integer;
FUNCTION WSAAsyncSelect(s : TSocket; hwnd_ : HWND; wmsg : u_int; lEvent :
Longint): Integer;
{TYPE
  { windows extended data types }
  {xx not needed xx }

implementation

PROCEDURE FD_CLR(fd : TSocket; VAR fdset : Tfd_set);
VAR
  q : Integer;
BEGIN
  q := 0;
  WHILE  (q < FD_SETSIZE) AND (fdset.fd_array[q] <> fd) DO
    Inc(q);

  IF (fdset.fd_array[q] = fd) THEN
  BEGIN
    FOR q := q TO fdset.fd_count-1 DO
      fdset.fd_array[q] := fdset.fd_array[q+1];
    Dec(fdset.fd_count)
  END
END;

FUNCTION  FD_ISSET(fd : TSocket; VAR fdset : Tfd_set): Integer;
BEGIN
  FD_ISSET := __WSAFDIsSet(fd, fdset)
END;

PROCEDURE FD_SET(fd : TSocket; VAR fdset : Tfd_set);
BEGIN
  IF (fdset.fd_count < FD_SETSIZE-1) THEN
  BEGIN
    Inc(fdset.fd_count);
    fdset.fd_array[fdset.fd_count] := fd
  END
END;

PROCEDURE FD_ZERO(VAR fdset : Tfd_set);
BEGIN
  fdset.fd_count := 0;
END;

{ operations on timevals }
FUNCTION timercmp(tvp, uvp : timeval; cmp : String): Boolean;
{ the original timercmp took a third parameter of the operator }
{ (was a 'c' macro. But, the original couldn't handle 2        }
{ character operators ('>=' etc) so we're a bit better off.    }
BEGIN
  IF (cmp = '>') THEN
  BEGIN
    { greater than? }
    timercmp := (tvp.tv_sec > uvp.tv_sec) OR
                ((tvp.tv_sec = uvp.tv_sec) AND (tvp.tv_usec > uvp.tv_usec))
  END
  ELSE IF (cmp = '=') THEN
  BEGIN
    { equal ? }
    timercmp := (tvp.tv_sec = uvp.tv_sec) AND (tvp.tv_usec = uvp.tv_usec)
  END
  ELSE IF (cmp = '<') THEN
  BEGIN
    { less than? }
    timercmp := (tvp.tv_sec < uvp.tv_sec) OR
                ((tvp.tv_sec = uvp.tv_sec) AND (tvp.tv_usec < uvp.tv_usec))
  END
  ELSE IF (cmp = '>=') OR (cmp = '=>') THEN
  BEGIN
    { greater or equal? }
    timercmp := (tvp.tv_sec >= uvp.tv_sec) OR
                ((tvp.tv_sec = uvp.tv_sec) AND (tvp.tv_usec >= uvp.tv_usec))
  END
  ELSE IF (cmp = '<=') OR (cmp = '=<') THEN
  BEGIN
    { less or equal? }
    timercmp := (tvp.tv_sec <= uvp.tv_sec) OR
                ((tvp.tv_sec = uvp.tv_sec) AND (tvp.tv_usec <= uvp.tv_usec))
  END
  ELSE { error }
    timercmp := False;
END;

FUNCTION timerisset(tvp : timeval): Longint;
BEGIN
  timerisset := tvp.tv_sec OR tvp.tv_usec
END;

{ commands for ioctlsocket() }
FUNCTION _IO(x, y : Byte): Longint;
BEGIN
  _IO := IOC_VOID OR (x SHL 8) OR y
END;

FUNCTION _IOR(x : Char; y : Byte; tSize : Integer): Longint;
{ original took a type as the third parameter, and }
{ used 'sizeof' to get size. (c macro)             }
VAR
  lRes, lTemp : Longint;
BEGIN
  lRes := IOC_OUT;
  lTemp := tSize AND IOCPARM_MASK; lRes := lRes OR (lTemp SHL 16);
  lTemp := Byte(x); lRes := lRes OR (lTemp SHL 8);
  lRes := lRes OR y;
  {_IOR := IOC_OUT OR ((tSize AND IOCPARM_MASK) SHL 16) OR (Byte(x) SHL 8) OR
y} _IOR := lRes END;
FUNCTION _IOW(x : Char; y, tSize : Longint): Longint;
{ as above }
VAR
  lRes, lTemp : Longint;
BEGIN
  {lRes := IOC_IN;
  lTemp := tSize AND IOCPARM_MASK;
  lRes := lRes OR (lTemp SHL 16);
  lTemp := Byte(x);
  lRes := lRes OR (lTemp SHL 8);
  lRes := lRes OR y;}

  lRes := IOC_IN OR ((tSize AND IOCPARM_MASK) SHL 16) OR (Longint(x) SHL 8) OR
y;
  {_IOW := IOC_IN OR ((tSize AND IOCPARM_MASK) SHL 16) OR (Byte(x) SHL 8) OR
y}  _IOW := lRes
END;

FUNCTION FIONREAD: Longint;     { get number of bytes to read }
BEGIN
  FIONREAD := _IOR('f', 127, Sizeof(u_long))
END;

FUNCTION FIONBIO: Longint;      { set/clear non-blocking I/O }
BEGIN
  FIONBIO := _IOW('f', 126, Sizeof(u_long))
END;

FUNCTION FIOASYNC: Longint;     { set/clear async I/O }
BEGIN
  FIOASYNC := _IOW('f', 125, Sizeof(u_long))
END;

FUNCTION SIOCSHIWAT: Longint;   {set high watermark }
BEGIN
  SIOCSHIWAT := _IOW('s', 0, Sizeof(u_long))
END;

FUNCTION SIOCGHIWAT: Longint;   { get high watermark }
BEGIN
  SIOCGHIWAT := _IOR('s', 1, Sizeof(u_long))
END;

FUNCTION SIOCSLOWAT: Longint;   { set lo watermark }
BEGIN
  SIOCSLOWAT := _IOW('s', 2, Sizeof(u_long))
END;

FUNCTION SIOCGLOWAT: Longint;   { get lo watermark }
BEGIN
  SIOCGLOWAT := _IOR('s', 3, Sizeof(u_long))
END;

FUNCTION SIOCATMARK: Longint;   { at oob mark ? }
BEGIN
  SIOCATMARK := _IOR('s', 7, Sizeof(u_long))
END;

FUNCTION h_errno: Longint;
{#define h_errno WSAGetLastError() }
BEGIN
  h_errno := WSAGetLastError;
END;

{ winsock function prototypes }
FUNCTION accept(s : TSocket; VAR addr : sockaddr; VAR addrlen : Integer):
TSocket; external 'WINSOCK' index 1; FUNCTION bind(s : TSocket; {const} VAR
addr : sockaddr; namelen : Integer): Integer; external 'WINSOCK' index 2;
FUNCTION closesocket(s : TSocket): Integer; external 'WINSOCK' index 3;
FUNCTION connect(s : TSocket; {const}VAR name : sockaddr; namelen : Integer):
Integer; external 'WINSOCK' index 4; FUNCTION getpeername(s : TSocket; VAR
name : sockaddr; VAR namelen : Integer): Integer; external 'WINSOCK' index 5;
FUNCTION getsockname(s : TSocket; VAR name : sockaddr; namelen : Integer):
Integer;
         external 'WINSOCK' index 6;
FUNCTION getsockopt(s : TSocket; VAR name : sockaddr; namelen : Integer):
Integer;         external 'WINSOCK' index 7;
FUNCTION htonl(hostlong : u_long): u_long;
         external 'WINSOCK' index 8;
FUNCTION htons(hostshort: u_short): u_short;
         external 'WINSOCK' index 9;
FUNCTION inet_addr({const}cp : PChar): u_long;
         external 'WINSOCK' index 10;
FUNCTION inet_ntoa(in_ : in_addr): Char;
         external 'WINSOCK' index 11;
FUNCTION ioctlsocket(s : TSocket; cmd : LONGINT; VAR argp : u_long): Integer;
         external 'WINSOCK' index 12;
FUNCTION listen(s : TSocket; backlog : Integer): Integer;
         external 'WINSOCK' index 13;
FUNCTION ntohl(netlong : u_long): u_long;
         external 'WINSOCK' index 14;
FUNCTION ntohs(netshort : u_short): u_short;
         external 'WINSOCK' index 15;
FUNCTION recv(s : TSocket; buf : Pointer; len, flags : Integer): Integer;
         external 'WINSOCK' index 16;
FUNCTION recvfrom(s : TSocket; buf : Pointer; len, flags : Integer;
                  VAR from : sockaddr; VAR fromLen : Integer): Integer;
         external 'WINSOCK' index 17;
FUNCTION select(nfds : Integer; VAR readfds, writefds, exceptfds : Tfd_set;
                {const}VAR timeout : timeval): Integer;
         external 'WINSOCK' index 18;
FUNCTION send(s : TSocket; buf : Pointer; len, flags : Integer): Integer;
         external 'WINSOCK' index 19;
FUNCTION sendto(s : TSocket; buf : Pointer; len, flags : Integer;
                {const}VAR to_ : sockaddr; tolen : Integer): Integer;
         external 'WINSOCK' index 20;
FUNCTION setsockopt(s : TSocket; level, optname : Integer;
                    optval : Pointer; optlen : Integer): Integer;
         external 'WINSOCK' index 21;
FUNCTION shutdown(s : TSocket; how : integer): Integer;
         external 'WINSOCK' index 22;
FUNCTION socket(af, typ, protocol : Integer): TSocket;
         external 'WINSOCK' index 23;

{ database function prototypes }
FUNCTION gethostbyaddr({const}addr : Pointer; len, typ : Integer): Phostent;
         external 'WINSOCK' index 51;
FUNCTION gethostbyname({const}name : PChar): Phostent;
         external 'WINSOCK' index 52;
FUNCTION getprotobyname(name : PChar): Pprotoent;
         external 'WINSOCK' index 53;
FUNCTION getprotobynumber(proto : Integer): Pprotoent;
         external 'WINSOCK' index 54;
FUNCTION getservbyname({const}name : PChar; proto : PChar{Pointer}): Pservent;
         external 'WINSOCK' index 55;
FUNCTION getservbyport(port : Integer; proto : Pointer): Pservent;
         external 'WINSOCK' index 56;
FUNCTION gethostname(name : PChar; namelen : Integer): Integer;
         external 'WINSOCK' index 57;

{ windows extension function prototypes }
FUNCTION WSAAsyncSelect(s : TSocket; hwnd_ : HWND; wmsg : u_int; lEvent :
Longint): Integer;         external 'WINSOCK' index 101;
FUNCTION WSAAsynchGetHostByAddr(hwnd_ : HWND; wMsg : u_int;
         addr : Pointer; len, typ : Integer;
         {const}buf : Pointer; buflen : Integer): Integer;
         external 'WINSOCK' index 102;
FUNCTION WSAAsyncGetHostByName(hwnd_ : HWND; wMsg : Integer; name : PChar;
         buf : Pointer; buflen : Integer): Integer;
         external 'WINSOCK' index 103;
FUNCTION WSAAsyncGetProtoByNumber(hWnd_ : HWND; wMsg : u_int;
         number : Integer; buf : Pointer; buflen : Integer): Integer;
         external 'WINSOCK' index 104;
FUNCTION WSAAsyncGetProtoByName(hWnd_ : HWND; wMsg : u_int;
         {const}name : PChar;
         buf : Pointer; buflen : Integer): Integer;
         external 'WINSOCK' index 105;
FUNCTION WSAAsyncGetServByPort(hWnd_ : HWND; wMsg : u_int; port : Integer;
         {const} proto : Pointer; buf : Pointer; buflen : Integer): Integer;
         external 'WINSOCK' index 106;
FUNCTION WSAAsyncGetServByName(hWnd_ : HWND; wMsg : u_int;
         {const} name : PChar; {const} proto : Pointer;
         buf : Pointer; buflen : Integer): Integer;
         external 'WINSOCK' index 107;
FUNCTION WSACancelAsyncRequest(hAsyncTaskhandle : THANDLE): Integer;
         external 'WINSOCK' index 108;
FUNCTION WSASetBlockingHook(lpBlockFunc : TFARPROC): TFARPROC;
         external 'WINSOCK' index 109;
FUNCTION WSAUnhookBlockingHook: Integer;
         external 'WINSOCK' index 110;
FUNCTION WSAGetLastError: Integer;
         external 'WINSOCK' index 111;
FUNCTION WSASetLastError(iError : Integer): Integer;
         external 'WINSOCK' index 112;
FUNCTION WSACancelBlockingCall: Integer;
         external 'WINSOCK' index 113;
FUNCTION WSAIsBlocking: WordBOOL;
         external 'WINSOCK' index 114;
FUNCTION WSAStartup(wVersionRequired : Word; lpwsaData_ : LPWSADATA): Integer;
         external 'WINSOCK' index 115;
FUNCTION WSACleanup: integer;
         external 'WINSOCK' index 116;

FUNCTION __WSAFDIsSet(s : TSocket; VAR fds : Tfd_set): Integer;
         external 'WINSOCK' index 151;

END.

