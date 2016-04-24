(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0029.PAS
  Description: File Connections in Novell
  Author: JIM ROBB
  Date: 05-26-95  23:05
*)

{
> Does anyone know how to get the list of connections using a file with
> pascal (bp 7) under Novell (3.11) ?  I know that it is accessed with INT
> $21 Function $E3 sub function $DC.

This function works under Novell 2.x, but it doesn't work in 3.x Netware. You
will need one of the newer $F2 calls.  Here's a unit that should handle it.
We run a couple of programs using this code on 3.11 and 3.12 networks, and
we've also tested it on a 4.0 network.  Caveat - the "Get Directory Handle"
call found herein is fooled by "MAP ROOT" drive mappings.
}

{ F2Calls ==================================================================}
{ =======                                                                   }
{  A collection of calls from Novell's "$F2" series.  This series has neat  }
{  stuff like "Get Connections Using a File" that haven't been seen since   }
{  Version 2.2 of NetWare.                                                  }
{                                                                           }
{===========================================================================}

unit F2Calls;

interface

uses Dos;

type
  ConnInfo = record
    ConnNo     : Word;  { Number of logical connection holding file open    }
    TaskNo     : Word;  { Task number, within connection, holding file open }
    LockType   : Byte;  { Not locked, File lock, or Begin Share File Set    }
    AccessFlag : Byte;  { Bit flag indicating access rights for the file    }
    LockFlag   : Byte   { Bit flag showing lock information                 }
  end;

  ConnReplyType = record
    NextRequest : Word;      { Used if more than 70 connections using file  }
    UseCount    : Word;
    OpenCount   : Word;      { Total times file is open                     }
    OpenReadCt  : Word;      { Total open for read                          }
    OpenWriteCt : Word;      { Total open for write                         }
    DenyReadCt  : Word;      { Total readlock                               }
    DenyWriteCt : Word;      { Total deny write flag                        }
    Locked      : Byte;      { Lock status                                  }
    Fork        : Byte;      { MacJunk - data fork (0) or resource fork (1) }
    ConnCount   : Word;      { Number of connection entries                 }
    ConnArray   : array[ 1..70 ] of ConnInfo
  end;

  ConnReplyPtr = ^ConnReplyType;


{ ConvertPathToDirectoryEntry ----------------------------------------------}
{ ---------------------------                                               }
{   <Path> must be a full pathname with drive, path, and filename.  The     }
{  function returns the number of the volume where the file resides in      }
{  <VolNo>, and the files entry or sequence number in the file system in    }
{  <EntryNo>.  The function result is the success code of the Netware       }
{  API call, where 0 indicates success.                                     }

function ConvertPathToDirectoryEntry( Path : PathStr;
                                 var VolNo : Byte;
                               var EntryNo : Longint ) : byte;


{ GetConnectionsUsingAFile -------------------------------------------------}
{ ------------------------                                                  }
{   < VolNo> is the volume number, and <EntryNo> the directory entry number }
{  of the file in question, as returned by ConvertPathToDirectoryEntry.     }
{  <NextRecord> should be zero the first time you use this function.  The   }
{  reply buffer has room for 70 connections.  If <NextRecord> is non-zero,  }
{  there are more connections to report.  Call the function again, leaving  }
{  <NextRecord> unchanged.  The function result is the success code of the  }
{  NetWare API call, where 0 indicates Success.                             }

function GetConnectionsUsingAFile( VolNo : Byte;
                                 EntryNo : Longint;
                          var NextRecord : Word;
                           var ConnReply : ConnReplyType ) : Byte;


{ ========================================================================= }

implementation

var
  NovRegs : Registers;


{ GetDirHandle -------------------------------------------------------------}
{ ------------                                                              }

function GetDirHandle( DriveLetter : Char;
                       StatusFlags : Byte ) : Byte;
begin
  GetDirHandle := 0;
  with NovRegs do begin
    AH := $E9;
    AL := 0;
    { Convert drive letter to a byte:  A=0, B=1, etc. }
    DX := Byte( UpCase( DriveLetter ) ) - 65;
    MsDos( NovRegs );
    GetDirHandle := AL;
    StatusFlags := AH
  end
end;


{ ConvertPathToDirectoryEntry ----------------------------------------------}
{ ---------------------------                                               }

function ConvertPathToDirectoryEntry( Path : PathStr;
                                 var VolNo : Byte;
                               var EntryNo : Longint ) : byte;
type
  RequestPacket = record
    StructLen : word;
    SFcode    : byte;
    DirHandle : byte;
    DirPath   : string
  end;

  ReplyBuffer = record
    VolumeNo   : Byte;
    DirEntryNo : Longint
  end;

var
  Request : RequestPacket;
  Reply   : ReplyBuffer;
  Status  : Byte;

begin
  with Request do begin
    DirHandle := GetDirHandle( Path[ 1 ], Status );
    StructLen := SizeOf( Request );
    SFcode := 244;
    DirPath := Copy( Path, 3, Length( Path ) - 2 )
  end;

  with NovRegs do begin
    AH := $F2;
    AL := 23;
    CX := SizeOf( Request );
    DX := Sizeof( Reply );
    SI := Ofs( Request );
    DI := Ofs( Reply );
    DS := Seg( Request );
    ES := Seg( Reply );
    MsDos( NovRegs )
  end;
  ConvertPathToDirectoryEntry := NovRegs.AL;
  VolNo := Reply.VolumeNo;
  EntryNo := Reply.DirEntryNo
end;


{ GetConnectionsUsingAFile -------------------------------------------------}
{ ------------------------                                                  }

function GetConnectionsUsingAFile( VolNo      : Byte;
                                   EntryNo    : Longint;
                               var NextRecord : Word;
                               var ConnReply  : ConnReplyType ) : Byte;
type
  RequestBuffer = record
    StructLen   : Word;        { Structure length }
    SFcode      : Byte;        { Sub-function code = $EC }
    ForkType    : Byte;        { MacJunk again! }
    VolumeNo    : Byte;        { Set to <VolNo> parameter }
    DirEntryNo  : Longint;     { Set to <EntryNo> parameter }
    LastRecSeen : Word         { Set to <NextRecord> parameter }
  end;

var
  Request : RequestBuffer;

begin
  with Request do begin
    StructLen := SizeOf( RequestBuffer );
    SFcode := 236;
    ForkType := 0;
    VolumeNo := VolNo;
    DirEntryNo := EntryNo;
    LastRecSeen := NextRecord
  end;

  with NovRegs do begin
    AH := $F2;
    AL := 23;
    CX := SizeOf( RequestBuffer );
    DX := Sizeof( ConnReplyType );
    SI := Ofs( Request );
    DI := Ofs( ConnReply );
    DS := Seg( Request );
    ES := Seg( ConnReply );
    MsDos( NovRegs )
  end;
  GetConnectionsUsingAFile := NovRegs.AL;
  NextRecord := ConnReply.NextRequest
end;

end.

