(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0083.PAS
  Description: Help code for WINSOCK for PASCAL
  Author: DARRYL LUFF
  Date: 11-25-95  09:26
*)


{These are just a couple of handy routines. Not part of the winsock api, but
useful with it. }

UNIT wsockhlp;
{ helper routines that aren't part of the spec, but are handy }
{ darryl luff 14Nov95 }

interface
USES
  Winsock;

FUNCTION SockErrorStr(e : Longint): String;
FUNCTION SetBlocking(s : TSocket; sw : Boolean): Integer;

implementation


FUNCTION SetBlocking(s : TSocket; sw : Boolean): Integer;
{ sets the blocking state on a socket }
VAR
  cmd, argp : Longint;
BEGIN
  cmd := FIONBIO; argp := Word(sw);
  SetBlocking := ioctlsocket(s, cmd, argp);
END;

FUNCTION SockErrorStr(e : Longint): String;
{ returns an error string for }
{ the winsock error number    }
VAR
  s : String;
BEGIN
  CASE e OF
    WSAEINTR   : s := '';
    WSAEBADF   : s := '';
    WSAEACCES  : s := '';
    WSAEFAULT  : s := '';
    WSAEINVAL  : s := '';
    WSAEMFILE  : s := '';

  { windows sockets definitions of regular berkeley error constants }
    WSAEWOULDBLOCK      : s := 'WouldBlock';
    WSAEINPROGRESS      : s := 'InProgress';
    WSAEALREADY         : s := 'Already';
    WSAENOTSOCK         : s := 'NotSock';
    WSAEDESTADDRREQ     : s := 'DestAddrReq';
    WSAEMSGSIZE         : s := 'MsgSize';
    WSAEPROTOTYPE       : s := 'ProtoType';
    WSAENOPROTOOPT      : s := 'NoProtoOpt';
    WSAEPROTONOSUPPORT  : s := 'ProtoNoSupport';
    WSAESOCKTNOSUPPORT  : s := 'SocktNoSupport';
    WSAEOPNOTSUPP       : s := 'OpNotSupp';
    WSAEPFNOSUPPORT     : s := 'PFNoSupport';
    WSAEAFNOSUPPORT     : s := 'AFNoSupport';
    WSAEADDRINUSE       : s := 'AddrInUse';
    WSAEADDRNOTAVAIL    : s := 'AddrNotAvail';
    WSAENETDOWN         : s := 'NetDown';
    WSAENETUNREACH      : s := 'NetUnreach';
    WSAENETRESET        : s := 'NetReset';
    WSAECONNABORTED     : s := 'ConnAborted';
    WSAECONNRESET       : s := 'ConnReset';
    WSAENOBUFS          : s := 'NoBuffs';
    WSAEISCONN          : s := 'IsConn';
    WSAENOTCONN         : s := 'NotConn';
    WSAESHUTDOWN        : s := 'ShutDown';
    WSAETOOMANYREFS     : s := 'TooManyRefs';
    WSAETIMEDOUT        : s := 'TimedOut';
    WSAECONNREFUSED     : s := 'ConnRefused';
    WSAELOOP            : s := 'Loop';
    WSAENAMETOOLONG     : s := 'NameNotLong';
    WSAEHOSTDOWN        : s := 'HostDown';
    WSAEHOSTUNREACH     : s := 'HostUnreach';
    WSAENOTEMPTY        : s := 'NotEmpty';
    WSAEPROCLIM         : s := 'Proclim';
    WSAEUSERS           : s := 'Users';
    WSAEDQUOT           : s := 'DQuot';
    WSAESTALE           : s := 'Stale';
    WSAEREMOTE          : s := 'Remote';

    { extended windows sockets error constant definitions }
    WSASYSNOTREADY      : s := 'SysNotReady';
    WSAVERNOTSUPPORTED  : s := 'VerNotSupported';
    WSANOTINITIALISED   : s := 'NotInitialised';

  { error return codes from gethostbyname() and gethostbyaddr() }
  { (when using the resolver). note that these errors are       }
  { retrieved via WSAGetLastError() and must therefore follow   }
  { the rules for avoiding clashes with error numbers from      }
  { specific implementations or language run-time systems. for  }
  { this reason the codes are based at WSABASEERR+1001. note    }
  { also that [WSA]NO_ADDRESS is defined only for compatibility }
  { purposes.                                                   }

  { authoritative answer: Host not found }
  WSAHOST_NOT_FOUND     : s := 'Host Not Found';

  { non-authoritative: Host not found, or SERVERFAIL }
  WSATRY_AGAIN          : s := 'Host not found - try again';

  { non-recoverable errors, FORMERR, REFUSED, NOTIMP }
  WSANO_RECOVERY        : s := 'Unrecoverable error';

  { valid name, no data record of requested type }
  WSANO_DATA            : s := 'Valid name but no data';

  WSANO_ADDRESS         : s := 'No address, look for MX record';
  ELSE
    s := ''
  END;
  SockErrorStr := s
END;

END.

