(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0089.PAS
  Description: Windows Sockets Unit
  Author: MARK TOWFIQ
  Date: 05-31-96  09:17
*)

unit WinSock;

{$C FIXED PRELOAD DISCARDABLE}

(*
 * WINSOCK.H--definitions to be used with the WINSOCK.DLL
 *
 * This header file corresponds to version 1.1 of the Windows Sockets specification.
 *
 * This file includes parts which are Copyright (c) 1982-1986 Regents
 * of the University of California.  All rights reserved.  The
 * Berkeley Software License Agreement specifies the terms and
 * conditions for redistribution.
 *
 * Original WINSOCK.H Change log:
 *
 * Fri Apr 23 16:31:01 1993  Mark Towfiq  (towfiq@Microdyne.COM)
 *	New version from David Treadwell which adds extern "C" around
 *	__WSAFDIsSet() and removes "const" from buf param of
 *	WSAAsyncGetHostByAddr().  Added change log.
 *
 * Sat May 15 10:55:00 1993 David Treadwell (davidtr@microsoft.com)
 *	Fix the IN_CLASSC macro to account for class-D multicasts.
 *	Add AF_IPX == AF_NS.
 *
 * Tue Oct 19 13:05:02 1993  Mark Towfiq (Mark.Towfiq@Sun.COM)
 *	New version from David Treadwell which changes type of counter in
 *	fd_set to u_int instead of u_short, so that it is correctly
 *	promoted in Winsdows NT and other 32-bit environments.
 *
 * Translated to BP7 by:  Randy Bratton, CServe: 72355,1466
 *
 * NOTE:  I have tried to keep the declaration order in WINSOCK.PAS the
 *        same as that in WINSOCK.H.  Most of the comments from the original
 *        WINSOCK.H have been left intact in the Pascal version.
 *        My comments are labeled with RMB.
 *
 * NO WARRANTY EXPRESSED OR IMPLIED.
 *
 * WINSOCK.PAS Revision History
 *    Version         Date      By     Comments
 *      1.00        03/04/94    RMB    Initial revision.
 *      1.01        08/22/94    RMB    General cleanup before posting to
 *                                     CompuServe.
 *      1.02        09/29/94    RMB    Added h_addr function for THostEnt
 *                                     structure.
 *      1.03        03/10/96    RMB    Fixed bug (noted by P. Payzant) in
 *                                     TWSAData. Now corresponds to WINSOCK.H
 *                                     dated 10/19/93 (except where noted).
 *)

interface

uses
  WinTypes;

type
(*
 * Basic system type definitions, taken from the BSD file sys/types.h.
 *)
  u_char  = char;
  u_short = word;  (* in Borland C++, int and short are both 16-bits RMB *)
  u_int   = word;
  u_long  = longint;

(*
 * Other basic types needed for the C to Pascal translation.  RMB
 *)
  PPChar = ^PChar;  (* used with char FAR * FAR * xxx   RMB *)

(*
 * The new type to be used in all
 * instances which refer to sockets.
 *
 * Must be renamed from SOCKET as there is a function called
 * socket().  RMB
 *)
  PSocket = ^TSocket;
  TSocket = u_int;

(*
 * Select uses arrays of SOCKETs.  These macros manipulate such
 * arrays.  FD_SETSIZE may be defined by the user before including
 * this file, but the default here should be >= 64.
 *
 * CAVEAT IMPLEMENTOR and USER: THESE MACROS AND TYPES MUST BE
 * INCLUDED IN WINSOCK.H EXACTLY AS SHOWN HERE.
 *)
const
  FD_SETSIZE =64;

type
  PFd_Set = ^TFd_Set;
  TFd_Set = record
    fd_count : u_int;                              (* how many are SET? *) (* RMB 03/10/96 1.03 *)
                                                   (* 10/19/93 update to original WINSOCK.H *)
    fd_array : array[0..FD_SETSIZE-1] of TSocket;  (* an array of SOCKETs *)
    end;

function  __WSAFDIsSet(fd: TSocket; aset: PFd_Set): integer;

(*
**  NB:  Have not done any work with socket arrays, therefore these
**  routines have not been tested.  RMB 08/22/94 1.01
*)
procedure Fd_Clr(fd: TSocket; aset: PFd_Set);
procedure Fd_Set(fd: TSocket; aset: PFd_Set);
procedure Fd_Zero(aset: PFd_Set);
function  Fd_IsSet(fd: TSocket; aset: PFd_Set): boolean;

(*
 * Structure used in select() call, taken from the BSD file sys/time.h.
 *)
type
  PTimeval = ^Timeval;
  Timeval = record
        tv_sec: longint;         (* seconds *)
        tv_usec: longint;        (* and microseconds *)
        end;
(*
 * Operations on timevals.
 *
 * NB: timercmp does not work for >= or <=.
 *)
(*
**  DEFINES (macros) for timerisset, timercmp, and timerclear
**  not implemented.  RMB
*)

(*
 * Commands for ioctlsocket(),  taken from the BSD file fcntl.h.
 *
 *
 * Ioctl's have the command encoded in the lower word,
 * and the size of any in or out parameters in the upper
 * word.  The high 2 bits of the upper word are used
 * to encode the in/out status of the parameter; for now
 * we restrict parameters to at most 128 bytes.
 *)
const
  IOCPARM_MASK =   $07f;            (* parameters must be < 128 bytes *)
  IOC_VOID     =   $20000000;       (* no parameters *)
  IOC_OUT      =   $040000000;      (* copy out parameters *)
  IOC_IN       =   $080000000;      (* copy in parameters *)
  IOC_INOUT    =   (IOC_IN or IOC_OUT);
																				(* 0x20000000 distinguishes new &
																					 old ioctl's *)
(*
**  DEFINES (macros) for _IO, _IOR, _IOW, FIONREAD, FIONBIO, FIOASYNC,
**    SIOCSHIWAT, SIOCGHIWAT, SIOCSLOWAT, SIOCGLOWAT, SIOCATMARK
**    not implemented.  RMB
*)

(*
 * Structures returned by network data base library, taken from the
 * BSD file netdb.h.  All addresses are supplied in host order, and
 * returned in network order (suitable for use in system calls).
 *)

type
  PHostEnt = ^THostEnt;
  THostEnt = record
        h_name : PChar;           (* official name of host *)
        h_aliases: PPChar;        (* alias list *)
        h_addrtype: integer;      (* host address type *)
        h_length :  integer;      (* length of address *)
        h_addr_list: PPChar;      (* list of addresses *)
        end;

{
  C #define h_addr h_addr_list[0] omitted as currently only needed for
  backward compatibility.  RMB 08/22/94 1.01
}
function h_addr(aHostEnt: THostEnt): PChar;  (* RMB 09/29/94 1.02 *)

(*
 * It is assumed here that a network number
 * fits in 32 bits.
 *)
type
  PNetEnt = ^TNetEnt;
  TNetEnt = record
        n_name : PChar;           (* official name of net *)
        n_aliases : PPChar;       (* alias list *)
        n_addrtype : integer;     (* net address type *)
        n_net : u_long;           (* network $ *)
        end;

type
  PServEnt = ^TServEnt;
  TServEnt = record
        s_name : PChar;           (* official service name *)
        s_aliases : PPChar;       (* alias list *)
        s_port : integer;         (* port $ *)
        s_proto : PChar;          (* protocol to use *)
        end;

type
  PProtoEnt = ^TProtoEnt;
  TProtoEnt = record
        p_name : PChar;           (* official protocol name *)
        p_aliases : PPChar;       (* alias list *)
        p_proto : integer;        (* protocol $ *)
        end;

(*
 * Constants and procedures defined by the internet system,
 * Per RFC 790, September 1981, taken from the BSD file netinet/in.h.
 *)

(*
 * Protocols
 *)
const
   IPPROTO_IP          =    0;               (* dummy for IP *)
   IPPROTO_ICMP        =    1;               (* control message protocol *)
   IPPROTO_GGP         =    2;               (* gateway^2 (deprecated) *)
   IPPROTO_TCP         =    6;               (* tcp *)
   IPPROTO_PUP         =    12;              (* pup *)
   IPPROTO_UDP         =    17;              (* user datagram protocol *)
   IPPROTO_IDP         =    22;              (* xns idp *)
   IPPROTO_ND          =    77;              (* UNOFFICIAL net disk proto *)

   IPPROTO_RAW         =    255;             (* raw IP packet *)
   IPPROTO_MAX         =    256;

(*
 * Port/socket numbers: network standard functions
 *)
   IPPORT_ECHO         =    7;
   IPPORT_DISCARD      =    9;
   IPPORT_SYSTAT       =    11;
   IPPORT_DAYTIME      =    13;
   IPPORT_NETSTAT      =    15;
   IPPORT_FTP          =    21;
   IPPORT_TELNET       =    23;
   IPPORT_SMTP         =    25;
   IPPORT_TIMESERVER   =    37;
   IPPORT_NAMESERVER   =    42;
   IPPORT_WHOIS        =    43;
   IPPORT_MTP          =    57;

(*
 * Port/socket numbers: host specific functions
 *)
   IPPORT_TFTP         =    69;
   IPPORT_RJE          =    77;
   IPPORT_FINGER       =    79;
   IPPORT_TTYLINK      =    87;
   IPPORT_SUPDUP       =    95;

(*
 * UNIX TCP sockets
 *)
   IPPORT_EXECSERVER   =    512;
   IPPORT_LOGINSERVER  =    513;
   IPPORT_CMDSERVER    =    514;
   IPPORT_EFSSERVER    =    520;

(*
 * UNIX UDP sockets
 *)
   IPPORT_BIFFUDP      =    512;
   IPPORT_WHOSERVER    =    513;
   IPPORT_ROUTESERVER  =    520;
																				(* 520+1 also used *)

(*
 * Ports < IPPORT_RESERVED are reserved for
 * privileged processes (e.g. root).
 *)
   IPPORT_RESERVED    =     1024;

(*
 * Link numbers
 *)
   IMPLINK_IP         =     155;
   IMPLINK_LOWEXPER   =     156;
   IMPLINK_HIGHEXPER  =     158;

(*
 * Internet address (old style... should be updated)
 *)
type
  PIn_Addr = ^TIn_Addr;
  TIn_Addr = record
        case integer of
          1: (S_un_b : record
                      s_b1,
                      s_b2,
                      s_b3,
                      s_b4 : u_char;
                      end);
          2: (S_un_w : record
                      s_w1,
                      s_w2 : u_short;
                      end);
          3: (S_addr : u_long);
        end;

function s_addr(s_un: TIn_Addr): u_long;
function s_host(s_un: TIn_Addr): u_char;
function s_net(s_un: TIn_Addr): u_char;
function s_imp(s_un: TIn_Addr): u_short;
function s_impno(s_un: TIn_Addr): u_char;
function s_lh(s_un: TIn_Addr): u_char;

(*
 * Definitions of bits in internet address integers.
 * On subnets, the decomposition of addresses to host and net parts
 * is done according to subnet mask, not the masks here.
 *)
const
  IN_CLASSA_NET       =    $ff000000;
  IN_CLASSA_NSHIFT    =    24;
  IN_CLASSA_HOST      =    $00ffffff;
  IN_CLASSA_MAX       =    128;

  IN_CLASSB_NET       =    $ffff0000;
  IN_CLASSB_NSHIFT    =    16;
  IN_CLASSB_HOST      =    $0000ffff;
  IN_CLASSB_MAX       =    65536;

  IN_CLASSC_NET       =    $ffffff00;
  IN_CLASSC_NSHIFT    =    8;
  IN_CLASSC_HOST      =    $000000ff;

  INADDR_ANY          =    $000000000;
  INADDR_LOOPBACK     =    $7f000001;
  INADDR_BROADCAST    =    $ffffffff;
  INADDR_NONE         =    $ffffffff;

function In_ClassA(i : longint) : boolean;
function In_ClassB(i : longint) : boolean;
function In_ClassC(i : longint) : boolean;

(*
 * Socket address, internet style.
 *)
type
  PSockAddr_In = ^TSockAddr_In;
  TSockAddr_in = record
          sin_family  : integer;
          sin_port    : u_short;
          sin_addr    : TIn_Addr;
          sin_zero    : array[0..7] of char;
          end;

const
  WSADESCRIPTION_LEN   =   256;
  WSASYS_STATUS_LEN    =   128;

type
  PWSAData = ^TWSAData;
  TWSAData = record
          wVersion       : word;
          wHighVersion   : word;
          szDescription  : array[0..WSADESCRIPTION_LEN] of char;  (* RMB 03/10/96 1.03 *)
          szSystemStatus : array[0..WSASYS_STATUS_LEN] of char;   (* RMB 03/10/96 1.03 *)
          iMaxSockets    : u_short;
          iMaxUdpDg      : u_short;
          lpVendorInfo   : PChar;
          end;

(*
 * Options for use with [gs]etsockopt at the IP level.
 *)
const

  IP_OPTIONS  =    1;               (* set/get IP per-packet options *)

(*
 * Definitions related to sockets: types, address families, options,
 * taken from the BSD file sys/socket.h.
 *)

(*
 * This is used instead of -1, since the
 * SOCKET type is unsigned.
 *)
const
  INVALID_SOCKET = TSocket(not 0);
  SOCKET_ERROR   = -1;

(*
 * Types
 *)
  SOCK_STREAM     = 1;               (* stream socket *)
  SOCK_DGRAM      = 2;               (* datagram socket *)
  SOCK_RAW        = 3;               (* raw-protocol interface *)
  SOCK_RDM        = 4;               (* reliably-delivered message *)
  SOCK_SEQPACKET  = 5;               (* sequenced packet stream *)

(*
 * Option flags per-socket.
 *)
  SO_DEBUG        = $0001;          (* turn on debugging info recording *)
  SO_ACCEPTCONN   = $0002;          (* socket has had listen() *)
  SO_REUSEADDR    = $0004;          (* allow local address reuse *)
  SO_KEEPALIVE    = $0008;          (* keep connections alive *)
  SO_DONTROUTE    = $0010;          (* just use interface addresses *)
  SO_BROADCAST    = $0020;          (* permit sending of broadcast msgs *)
  SO_USELOOPBACK  = $0040;          (* bypass hardware when possible *)
  SO_LINGER       = $0080;          (* linger on close if data present *)
  SO_OOBINLINE    = $0100;          (* leave received OOB data in line *)

  SO_DONTLINGER   = u_int(not SO_LINGER);

(*
 * Additional options.
 *)
  SO_SNDBUF       = $1001;          (* send buffer size *)
  SO_RCVBUF       = $1002;          (* receive buffer size *)
  SO_SNDLOWAT     = $1003;          (* send low-water mark *)
  SO_RCVLOWAT     = $1004;          (* receive low-water mark *)
  SO_SNDTIMEO     = $1005;          (* send timeout *)
  SO_RCVTIMEO     = $1006;          (* receive timeout *)
  SO_ERROR        = $1007;          (* get error status and clear *)
  SO_TYPE         = $1008;          (* get socket type *)

(*
 * TCP options.
 *)
  TCP_NODELAY     = $0001;

(*
 * Address families.
 *)
  AF_UNSPEC       = 0;               (* unspecified *)
  AF_UNIX         = 1;               (* local to host (pipes, portals) *)
  AF_INET         = 2;               (* internetwork: UDP, TCP, etc. *)
  AF_IMPLINK      = 3;               (* arpanet imp addresses *)
  AF_PUP          = 4;               (* pup protocols: e.g. BSP *)
  AF_CHAOS        = 5;               (* mit CHAOS protocols *)
  AF_NS           = 6;               (* XEROX NS protocols *)
  AF_IPX          = 6;               (* IPX and SPX *) (* RMB 03/10/96 1.03 *)
                                                       (* 05/15/93 update to original WINSOCK.H *)
  AF_ISO          = 7;               (* ISO protocols *)
  AF_OSI          = AF_ISO;          (* OSI is ISO *)
  AF_ECMA         = 8;               (* european computer manufacturers *)
  AF_DATAKIT      = 9;               (* datakit protocols *)
  AF_CCITT        = 10;              (* CCITT protocols, X.25 etc *)
  AF_SNA          = 11;              (* IBM SNA *)
  AF_DECnet       = 12;              (* DECnet *)
  AF_DLI          = 13;              (* Direct data link interface *)
  AF_LAT          = 14;              (* LAT *)
  AF_HYLINK       = 15;              (* NSC Hyperchannel *)
  AF_APPLETALK    = 16;              (* AppleTalk *)
  AF_NETBIOS      = 17;              (* NetBios-style addresses *)

  AF_MAX          = 18;

(*
 * Structure used by kernel to store most
 * addresses.
 *)
type
  PSockAddr = ^TSockAddr;
  TSockAddr = record
        sa_family : u_short;            (* address family *)
        sa_data : array[0..13] of char; (* up to 14 bytes of direct address *)
        end;

(*
 * Structure used by kernel to pass protocol
 * information in raw sockets.
 *)
type
  PSockProto = ^TSockProto;
  TSockProto = record
        sp_family : u_short;              (* address family *)
        sp_protocol : u_short;            (* protocol *)
        end;

(*
 * Protocol families, same as address families for now.
 *)
const

  PF_UNSPEC       = AF_UNSPEC;
  PF_UNIX         = AF_UNIX;
  PF_INET         = AF_INET;
  PF_IMPLINK      = AF_IMPLINK;
  PF_PUP          = AF_PUP;
  PF_CHAOS        = AF_CHAOS;
  PF_NS           = AF_NS;
  PF_IPX          = AF_IPX;  (* RMB 3/9/96 1.03 *)
                             (* 5/15/93 update to original WINSOCK.H *)
  PF_ISO          = AF_ISO;
  PF_OSI          = AF_OSI;
  PF_ECMA         = AF_ECMA;
  PF_DATAKIT      = AF_DATAKIT;
  PF_CCITT        = AF_CCITT;
  PF_SNA          = AF_SNA;
  PF_DECnet       = AF_DECnet;
  PF_DLI          = AF_DLI;
  PF_LAT          = AF_LAT;
  PF_HYLINK       = AF_HYLINK;
  PF_APPLETALK    = AF_APPLETALK;

  PF_MAX          = AF_MAX;

(*
 * Structure used for manipulating linger option.
 *)
type
  PLinger = ^TLinger;
  TLinger = record
          l_onoff  : WordBool; {was u_short RMB} (* option on/off *) (* RMB 03/10/96 1.03 *)
          l_linger : u_short;                    (* linger time *)
          end;

(*
 * Level number for (get/set)sockopt() to apply to socket itself.
 *)
const
  SOL_SOCKET      = -1; {was $ffff  RMB}  (* options for socket level *)

(*
 * Maximum queue length specifiable by listen.
 *)
const
  SOMAXCONN       = 5;

  MSG_OOB         = $1;             (* process out-of-band data *)
  MSG_PEEK        = $2;             (* peek at incoming message *)
  MSG_DONTROUTE   = $4;             (* send without using routing tables *)

  MSG_MAXIOVLEN   = 16;

(*
 * Define constant based on rfc883, used by gethostbyxxxx() calls.
 *)
const
  MAXGETHOSTSTRUCT        = 1024;

(*
 * Define flags to be used with the WSAAsyncSelect() call.
 *)
const
  FD_READ         = $01;
  FD_WRITE        = $02;
  FD_OOB          = $04;
  FD_ACCEPT       = $08;
  FD_CONNECT      = $10;
  FD_CLOSE        = $20;

(*
 * All Windows Sockets error constants are biased by WSABASEERR from
 * the "normal"
 *)
const
  WSABASEERR              = 10000;

(*
 * Windows Sockets definitions of regular Microsoft C error constants
 *)
const
  WSAEINTR                = (WSABASEERR+4);
  WSAEBADF                = (WSABASEERR+9);
  WSAEACCES               = (WSABASEERR+13);
  WSAEFAULT               = (WSABASEERR+14);
  WSAEINVAL               = (WSABASEERR+22);
  WSAEMFILE               = (WSABASEERR+24);

(*
 * Windows Sockets definitions of regular Berkeley error constants
 *)
const
  WSAEWOULDBLOCK          = (WSABASEERR+35);
  WSAEINPROGRESS          = (WSABASEERR+36);
  WSAEALREADY             = (WSABASEERR+37);
  WSAENOTSOCK             = (WSABASEERR+38);
  WSAEDESTADDRREQ         = (WSABASEERR+39);
  WSAEMSGSIZE             = (WSABASEERR+40);
  WSAEPROTOTYPE           = (WSABASEERR+41);
  WSAENOPROTOOPT          = (WSABASEERR+42);
  WSAEPROTONOSUPPORT      = (WSABASEERR+43);
  WSAESOCKTNOSUPPORT      = (WSABASEERR+44);
  WSAEOPNOTSUPP           = (WSABASEERR+45);
  WSAEPFNOSUPPORT         = (WSABASEERR+46);
  WSAEAFNOSUPPORT         = (WSABASEERR+47);
  WSAEADDRINUSE           = (WSABASEERR+48);
  WSAEADDRNOTAVAIL        = (WSABASEERR+49);
  WSAENETDOWN             = (WSABASEERR+50);
  WSAENETUNREACH          = (WSABASEERR+51);
  WSAENETRESET            = (WSABASEERR+52);
  WSAECONNABORTED         = (WSABASEERR+53);
  WSAECONNRESET           = (WSABASEERR+54);
  WSAENOBUFS              = (WSABASEERR+55);
  WSAEISCONN              = (WSABASEERR+56);
  WSAENOTCONN             = (WSABASEERR+57);
  WSAESHUTDOWN            = (WSABASEERR+58);
  WSAETOOMANYREFS         = (WSABASEERR+59);
  WSAETIMEDOUT            = (WSABASEERR+60);
  WSAECONNREFUSED         = (WSABASEERR+61);
  WSAELOOP                = (WSABASEERR+62);
  WSAENAMETOOLONG         = (WSABASEERR+63);
  WSAEHOSTDOWN            = (WSABASEERR+64);
  WSAEHOSTUNREACH         = (WSABASEERR+65);
  WSAENOTEMPTY            = (WSABASEERR+66);
  WSAEPROCLIM             = (WSABASEERR+67);
  WSAEUSERS               = (WSABASEERR+68);
  WSAEDQUOT               = (WSABASEERR+69);
  WSAESTALE               = (WSABASEERR+70);
  WSAEREMOTE              = (WSABASEERR+71);

(*
 * Extended Windows Sockets error constant definitions
 *)
const
  WSASYSNOTREADY          = (WSABASEERR+91);
  WSAVERNOTSUPPORTED      = (WSABASEERR+92);
  WSANOTINITIALISED       = (WSABASEERR+93);

(*
 * Error return codes from gethostbyname() and gethostbyaddr()
 * (when using the resolver). Note that these errors are
 * retrieved via WSAGetLastError() and must therefore follow
 * the rules for avoiding clashes with error numbers from
 * specific implementations or language run-time systems.
 * For this reason the codes are based at WSABASEERR+1001.
 * Note also that [WSA]NO_ADDRESS is defined only for
 * compatibility purposes.
 *)

function h_errno : integer;

const
(* Authoritative Answer: Host not found *)
  WSAHOST_NOT_FOUND       = (WSABASEERR+1001);
  HOST_NOT_FOUND          = WSAHOST_NOT_FOUND;

(* Non-Authoritative: Host not found, or SERVERFAIL *)
  WSATRY_AGAIN            = (WSABASEERR+1002);
  TRY_AGAIN               = WSATRY_AGAIN;

(* Non recoverable errors, FORMERR, REFUSED, NOTIMP *)
  WSANO_RECOVERY          = (WSABASEERR+1003);
  NO_RECOVERY             = WSANO_RECOVERY;

(* Valid name, no data record of requested type *)
  WSANO_DATA              = (WSABASEERR+1004);
  NO_DATA                 = WSANO_DATA;

(* no address, look for MX record *)
  WSANO_ADDRESS           = WSANO_DATA;
  NO_ADDRESS              = WSANO_ADDRESS;

(*
 * Windows Sockets errors redefined as regular Berkeley error constants
 *)
const
  EWOULDBLOCK             = WSAEWOULDBLOCK;
  EINPROGRESS             = WSAEINPROGRESS;
  EALREADY                = WSAEALREADY;
  ENOTSOCK                = WSAENOTSOCK;
  EDESTADDRREQ            = WSAEDESTADDRREQ;
  EMSGSIZE                = WSAEMSGSIZE;
  EPROTOTYPE              = WSAEPROTOTYPE;
  ENOPROTOOPT             = WSAENOPROTOOPT;
  EPROTONOSUPPORT         = WSAEPROTONOSUPPORT;
  ESOCKTNOSUPPORT         = WSAESOCKTNOSUPPORT;
  EOPNOTSUPP              = WSAEOPNOTSUPP;
  EPFNOSUPPORT            = WSAEPFNOSUPPORT;
  EAFNOSUPPORT            = WSAEAFNOSUPPORT;
  EADDRINUSE              = WSAEADDRINUSE;
  EADDRNOTAVAIL           = WSAEADDRNOTAVAIL;
  ENETDOWN                = WSAENETDOWN;
  ENETUNREACH             = WSAENETUNREACH;
  ENETRESET               = WSAENETRESET;
  ECONNABORTED            = WSAECONNABORTED;
  ECONNRESET              = WSAECONNRESET;
  ENOBUFS                 = WSAENOBUFS;
  EISCONN                 = WSAEISCONN;
  ENOTCONN                = WSAENOTCONN;
  ESHUTDOWN               = WSAESHUTDOWN;
  ETOOMANYREFS            = WSAETOOMANYREFS;
  ETIMEDOUT               = WSAETIMEDOUT;
  ECONNREFUSED            = WSAECONNREFUSED;
  ELOOP                   = WSAELOOP;
  ENAMETOOLONG            = WSAENAMETOOLONG;
  EHOSTDOWN               = WSAEHOSTDOWN;
  EHOSTUNREACH            = WSAEHOSTUNREACH;
  ENOTEMPTY               = WSAENOTEMPTY;
  EPROCLIM                = WSAEPROCLIM;
  EUSERS                  = WSAEUSERS;
  EDQUOT                  = WSAEDQUOT;
  ESTALE                  = WSAESTALE;
  EREMOTE                 = WSAEREMOTE;

(* Socket function prototypes *)

function accept(s: TSOCKET; addr: PSockAddr; addrlen: PInteger): TSOCKET;

function bind(s: TSOCKET; const addr: PSockAddr; namelen: integer): integer;

function closesocket(s: TSOCKET): integer;

function connect(s: TSOCKET; const name: PSockAddr; namelen: integer): integer;

function getpeername(s: TSOCKET; name: PSockAddr; namelen: PInteger): integer;

function getsockname(s: TSOCKET; name: PSockAddr; namelen: PInteger): integer;

function getsockopt(s: TSOCKET; level: integer; optname: integer;
                    optval: PChar; optlen: PInteger): integer;

function htonl(hostlong: u_long): u_long;

function htons(hostshort: u_short): u_short;

function inet_addr(const cp: PChar): longint;

function inet_ntoa(ain: TIn_Addr): PChar;

function ioctlsocket(s: TSOCKET; cmd: longint; argp: PLongint) : integer;

function listen (s: TSOCKET; backlog: integer): integer;

function ntohl(netlong: u_long): u_long;

function ntohs(netshort: u_short): u_short;

function recv(s : TSOCKET; buf: PChar; len: integer; flags: integer): integer;

function recvfrom(s : TSOCKET; buf: PChar; len: integer; flags: integer;
                  from: PSockAddr; fromlen: PInteger): integer;

function select(nfds: integer; readfds: PFd_Set; writefds: PFd_Set;
                exceptfds: PFd_Set; const timeout: PTimeval): integer;

function send(s: TSOCKET; const buf: PChar; len: integer; flags: integer): integer;

function sendto(s: TSOCKET; const buf: PChar; len: integer; flags: integer;
                const ato: PSockAddr; tolen: integer): integer;

function setsockopt(s: TSOCKET; level: integer; optname: integer;
                    const optval: PChar; optlen: integer): integer;

function shutdown(s: TSOCKET; how: integer): integer;

function socket(af: integer; atype: integer; protocol: integer): TSOCKET;

(* Database function prototypes *)

function gethostbyaddr(const addr: PChar; len: integer; atype: integer): PHostEnt;

function gethostbyname(const name: PChar): PHostEnt;

function gethostname(name: PChar; namelen: integer): integer;

function getprotobyname(const name: PChar): PProtoEnt;

function getprotobynumber(proto: integer): PProtoEnt;

function getservbyname(const name: PChar; const proto: PChar): PServEnt;

function getservbyport(port: integer; const proto: PChar): PServEnt;


(* Microsoft Windows Extension function prototypes *)

function WSAAsyncGetHostByAddr(hWnd: HWND; wMsg: u_int;
                               const addr: PChar; len: integer; atype: integer;
                               buf: PChar; buflen: integer): THandle;  (* RMB 03/10/96 1.03 *)
                                                  (* 04/23/93 update to original WINSOCK.H *)

function WSAAsyncGetHostByName(hWnd: HWND; wMsg: u_int;
                               const name: PChar; buf: PChar;
                               buflen: integer): THandle;

function WSAAsyncGetProtoByName(hWnd: HWND; wMsg: u_int;
                                const name: PChar; buf: PChar;
                                buflen: integer): THandle;

function WSAAsyncGetProtoByNumber(hWnd: HWND; wMsg: u_int;
                                  number: integer; buf: PChar;
                                  buflen: integer): THandle;

function WSAAsyncGetServByName(hWnd: HWND; wMsg: u_int;
                               const name: PChar;
                               const proto: PChar;
                               buf: PChar; buflen: integer): THandle;

function WSAAsyncGetServByPort(hWnd: HWND; wMsg: u_int; port: integer;
                               const proto: PChar; buf: PChar;
                               buflen: integer): THandle;

function WSAAsyncSelect(s : TSocket; hWnd: HWND; wMsg: u_int;
                        lEvent: longint): integer;

function WSACancelAsyncRequest(hAsyncTaskHandle: THandle): integer;

function WSACancelBlockingCall: integer;

function WSACleanup: integer;

function WSAGetLastError: integer;

function WSAIsBlocking: boolean;

function WSASetBlockingHook(lpBlockFunc: TFarProc): TFarProc;

procedure WSASetLastError(iError: integer);

function WSAStartup(wVersionRequired: word; lpWSAData: PWSAData): integer;

function WSAUnhookBlockingHook: integer;

(*
 * Windows message parameter composition and decomposition
 * macros.
 *
 * WSAMAKEASYNCREPLY is inteneded for use by the Windows Sockets implementation
 * when constructing the response to a WSAAsyncGetXByX() routine.
 *)
function WSAMakeAsyncReply(buflen, error: word): longint;
(*
 * WSAMAKESELECTREPLY is intended for use by the Windows Sockets implementation
 * when constructing the response to WSAAsyncSelect().
 *)
function WSAMakeSelectReply(event, error: word): longint;
(*
 * WSAGETASYNCBUFLEN is intended for use by the Windows Sockets application
 * to extract the buffer length from the lParam in the response
 * to a WSAGetXByY().
 *)
function WSAGetAsyncBuflen(lparam: longint): word;
(*
 * WSAGETASYNCERROR is intended for use by the Windows Sockets application
 * to extract the error code from the lParam in the response
 * to a WSAGetXByY().
 *)
function WSAGetAsyncError(lparam: longint): word;
(*
 * WSAGETSELECTEVENT is intended for use by the Windows Sockets application
 * to extract the event code from the lParam in the response
 * to a WSAAsyncSelect().
 *)
function WSAGetSelectEvent(lparam: longint): word;
(*
 * WSAGETSELECTERROR is intended for use by the Windows Sockets application
 * to extract the error code from the lParam in the response
 * to a WSAAsyncSelect().
 *)
function WSAGetSelectError(lparam: longint): word;

implementation

uses
  WinProcs;

function accept; external 'WINSOCK' index 1;
function bind; external 'WINSOCK' index 2;
function closesocket; external 'WINSOCK' index 3;
function connect; external 'WINSOCK' index 4;
function getpeername; external 'WINSOCK' index 5;
function getsockname; external 'WINSOCK' index 6;
function getsockopt; external 'WINSOCK' index 7;
function htonl; external 'WINSOCK' index 8;
function htons; external 'WINSOCK' index 9;
function inet_addr; external 'WINSOCK' index 10;
function inet_ntoa; external 'WINSOCK' index 11;
function ioctlsocket; external 'WINSOCK' index 12;
function listen; external 'WINSOCK' index 13;
function ntohl; external 'WINSOCK' index 14;
function ntohs; external 'WINSOCK' index 15;
function recv; external 'WINSOCK' index 16;
function recvfrom; external 'WINSOCK' index 17;
function select; external 'WINSOCK' index 18;
function send; external 'WINSOCK' index 19;
function sendto; external 'WINSOCK' index 20;
function setsockopt; external 'WINSOCK' index 21;
function shutdown; external 'WINSOCK' index 22;
function socket; external 'WINSOCK' index 23;

function gethostbyaddr; external 'WINSOCK' index 51;
function gethostbyname; external 'WINSOCK' index 52;
function getprotobyname; external 'WINSOCK' index 53;
function getprotobynumber; external 'WINSOCK' index 54;
function getservbyname; external 'WINSOCK' index 55;
function getservbyport; external 'WINSOCK' index 56;
function gethostname; external 'WINSOCK' index 57;

function WSAAsyncSelect; external 'WINSOCK' index 101;
function WSAAsyncGetHostByAddr; external 'WINSOCK' index 102;
function WSAAsyncGetHostByName; external 'WINSOCK' index 103;
function WSAAsyncGetProtoByNumber; external 'WINSOCK' index 104;
function WSAAsyncGetProtoByName; external 'WINSOCK' index 105;
function WSAAsyncGetServByPort; external 'WINSOCK' index 106;
function WSAAsyncGetServByName; external 'WINSOCK' index 107;
function WSACancelAsyncRequest; external 'WINSOCK' index 108;
function WSASetBlockingHook; external 'WINSOCK' index 109;
function WSAUnhookBlockingHook; external 'WINSOCK' index 110;
function WSAGetLastError; external 'WINSOCK' index 111;
procedure WSASetLastError; external 'WINSOCK' index 112;
function WSACancelBlockingCall; external 'WINSOCK' index 113;
function WSAIsBlocking; external 'WINSOCK' index 114;
function WSAStartup; external 'WINSOCK' index 115;
function WSACleanup; external 'WINSOCK' index 116;

function __WSAFDIsSet; external 'WINSOCK' index 151;

procedure Fd_Clr(fd: TSocket; aset: PFd_Set);
var
  i: u_int;
begin
  for i := 0 to aset^.fd_count do
    begin
    if aset^.fd_array[i] = fd then (* found the one to clear *)
      begin
      while i < (aset^.fd_count-1) do
        begin
        aset^.fd_array[i] := aset^.fd_array[i+1];
        inc(i);
        end;
      dec(aset^.fd_count);
      break;
      end;
    end;
end;

procedure Fd_Set(fd: TSocket; aset: PFd_Set);
begin
  if aset^.fd_count < FD_SETSIZE then
    begin
    aset^.fd_array[aset^.fd_count] := fd;
    inc(aset^.fd_count);
    end;
end;

procedure Fd_Zero(aset: PFd_Set);
begin
  aset^.fd_count := 0;
end;

function Fd_IsSet(fd: TSocket; aset: PFd_Set): boolean;
begin
  Fd_IsSet := (__WSAFDIsSet(fd, aSet) > 0);
end;

function h_addr(aHostEnt: THostEnt): PChar;  (* RMB 09/29/94 1.02 *)
begin
  h_addr := aHostEnt.h_addr_list^;
end;

function s_addr(S_un: TIn_Addr): u_long;
begin
  s_addr := S_un.S_addr;  (* can be used for most tcp & ip code *)
end;

function s_host(S_un: TIn_Addr): u_char;
begin
  s_host := S_un.S_un_b.s_b2;  (* host on imp *)
end;

function s_net(S_un: TIn_Addr): u_char;
begin
  s_net := S_un.S_un_b.s_b1;  (* network *)
end;

function s_imp(S_un: TIn_Addr): u_short;
begin
  s_imp := S_un.S_un_w.s_w2; (* imp *)
end;

function s_impno(S_un: TIn_Addr): u_char;
begin
  s_impno := S_un.S_un_b.s_b4; (* imp $ *)
end;

function s_lh(S_un: TIn_Addr): u_char;
begin
  s_lh := S_un.S_un_b.s_b3;  (* logical host *)
end;

function In_ClassA(i : longint) : boolean;
begin
  In_ClassA := ((i and $80000000) = 0);
end;

function In_ClassB(i : longint) : boolean;
begin
  In_ClassB := ((i and  $c0000000) = $80000000);
end;

function In_ClassC(i : longint) : boolean;
begin
  In_ClassC := ((i and $e0000000) = $c0000000);   (* RMB 03/10/96 1.03 *)
                                                  (* 05/15/93 to original WINSOCK.H *)
end;

function h_errno : integer;
begin
  h_errno := WSAGetLastError;
end;

function WSAMakeAsyncReply(buflen, error: word): longint;
begin
  WSAMakeAsyncReply := MakeLong(buflen, error);
end;

function WSAMakeSelectReply(event, error: word): longint;
begin
  WSAMakeSelectReply := MakeLong(event, error);
end;

function WSAGetAsyncBuflen(lparam: longint): word;
begin
  WSAGetAsyncBuflen := LoWord(lparam);
end;

function WSAGetAsyncError(lparam: longint): word;
begin
  WSAGetAsyncError := HiWord(lparam);
end;

function WSAGetSelectEvent(lparam: longint): word;
begin
  WSAGetSelectEvent := LoWord(lparam);
end;

function WSAGetSelectError(lparam: longint): word;
begin
  WSAGetSelectError := HiWord(lparam);
end;

END.

