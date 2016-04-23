
{
            ╔══════════════════════════════════════════════════╗
            ║     ┌╦═══╦┐┌╦═══╦┐┌╦═══╦┐┌╦═╗ ╦┐┌╦═══╦┐┌╔═╦═╗┐   ║
            ║     │╠═══╩┘├╬═══╬┤└╩═══╦┐│║ ║ ║│├╬══      ║      ║
            ║     └╩     └╩   ╩┘└╩═══╩┘└╩ ╚═╩┘└╩═══╩┘   ╩      ║
            ║                                                  ║
            ║     NetWare 3.11 API Library for Turbo Pascal    ║
            ║                      by                          ║
            ║                 S.Perevoznik                     ║
            ║                     1996                         ║
            ╚══════════════════════════════════════════════════╝
}

Unit NetInfo;

Interface

Uses NetConv;

Function LogInNetWork : boolean;
{True, if log in network}

Function GetFileServerInformation(Var ServerName                  : string;
                                  Var NetWareVersion              : byte;
                                  Var NetWareSubVersion           : byte;
                                  Var MaximumConnectionsSupported : word;
                                  Var ConnectionsInUse            : word;
                                  Var MaximumVolumesSupported     : word;
                                  Var RevisionLevel               : byte;
                                  Var SFTLevel                    : byte;
                                  Var TTSLevel                    : byte;
                                  Var PeakConnectionsUsed         : word) : byte;
{Return server information}

Function GetServerName(Var ServerName : string) : byte;
{ Return server name}

Function GetNetWorkSerialNumber(Var NetWorkSerialNumber : LongInt;
                                Var ApplicationNumber   : Integer) : byte;
{Return network number and number application}

Function SetFileServerDateAndTime(year   : word;
                                  month  : word;
                                  day    : word;
                                  hour   : word;
                                  minute : word;
                                  second : word) : byte;
{Set server date and time}

Function GetFileServerDateAndTime(Var year   : word;
                                  Var month  : word;
                                  Var day    : word;
                                  Var hour   : word;
                                  Var minute : word;
                                  Var second : word) : byte;

{Get server date and time}

Function GetConnectionNumber : byte;
{Return current connection number}

Function GetNumberOfLocalDrives : byte;
{Get number of local disks}

Function GetConnectionInformation(ConnectionNumber:byte;
  Var ObjectName : string; var ObjectType : word;
  var ObjectID   : longint; var LoginTime : string): byte;
{Return current connection information}

Implementation

uses DOS;


Function GetFileServerInformation(Var ServerName                  : string;
                                  Var NetWareVersion              : byte;
                                  Var NetWareSubVersion           : byte;
                                  Var MaximumConnectionsSupported : word;
                                  Var ConnectionsInUse            : word;
                                  Var MaximumVolumesSupported     : word;
                                  Var RevisionLevel               : byte;
                                  Var SFTLevel                    : byte;
                                  Var TTSLevel                    : byte;
                                  Var PeakConnectionsUsed         : word) : byte;

var
   r           : registers;
   SendPacket  : array[0..3] of byte;
   ReplyPacket : array[0..130] of byte;
   WordPtr     : ^Word;
begin
  SendPacket[2] := 17;
  WordPtr := addr(SendPacket);
  WordPtr^ := 1;
  WordPtr  := addr(ReplyPacket);
  WordPtr^ := 128;

  r.BX := r.DS;
  r.AH := $0E3;
  r.DS := SEG(SendPacket);
  r.SI := OFS(SendPacket);
  r.ES := SEG(ReplyPacket);
  r.DI := OFS(ReplyPacket);
  intr($21,r);
  r.DS := r.BX;
  GetFileServerInformation := r.AL;
  if r.AL = 0 then
    begin
      move(ReplyPacket[2],ServerName[1],48);
      ServerName[0] := chr(48);
      NetWareVersion := ReplyPacket[50];
      NetWareSubVersion := ReplyPacket[51];
      move(MaximumConnectionsSupported,ReplyPacket[52],2);
      MaximumConnectionsSupported := Swap(MaximumConnectionsSupported);
      move(ConnectionsInUse,ReplyPacket[54],2);
      ConnectionsInUse := Swap(ConnectionsInUse);
      move(MaximumVolumesSupported,ReplyPacket[56],2);
      MaximumVolumesSupported := Swap(MaximumVolumesSupported);
      RevisionLevel := ReplyPacket[58];
      SFTLevel := ReplyPacket[59];
      TTSLevel := ReplyPacket[60];
      move(PeakConnectionsUsed,ReplyPacket[61],2);
      PeakConnectionsUsed := swap(PeakConnectionsUsed);
    end;
end;

Function GetServerName(Var ServerName : string) : byte;
var
   r           : registers;
   SendPacket  : array[0..3] of byte;
   ReplyPacket : array[0..130] of byte;
   WordPtr     : ^Word;
begin
  SendPacket[2] := 17;
  WordPtr := addr(SendPacket);
  WordPtr^ := 1;
  WordPtr  := addr(ReplyPacket);
  WordPtr^ := 128;

  r.BX := r.DS;
  r.AH := $0E3;
  r.DS := SEG(SendPacket);
  r.SI := OFS(SendPacket);
  r.ES := SEG(ReplyPacket);
  r.DI := OFS(ReplyPacket);
  intr($21,r);
  r.DS := r.BX;
  GetServerName := r.AL;
  if r.AL = 0 then
    begin
      move(ReplyPacket[2],ServerName[1],48);
      ServerName[0] := chr(48);
    end;
end;

Function GetNetWorkSerialNumber(Var NetWorkSerialNumber : LongInt;
                                Var ApplicationNumber   : Integer) : byte;

var
   r           : registers;
   SendPacket  : array[0..3] of byte;
   ReplyPacket : array[0..8] of byte;
   WordPtr     : ^Word;
begin
  SendPacket[2] := 18;
  WordPtr := addr(SendPacket);
  WordPtr^ := 1;
  WordPtr  := addr(ReplyPacket);
  WordPtr^ := 6;
  r.BX := r.DS;
  r.AH := $0E3;
  r.DS := SEG(SendPacket);
  r.SI := OFS(SendPacket);
  r.ES := SEG(ReplyPacket);
  r.DI := OFS(ReplyPacket);
  intr($21,r);
  r.DS := r.BX;
  GetNetWorkSerialNumber := r.AL;
  if r.AL = 0 then
    begin
      NetworkSerialNumber := GetLong(addr(ReplyPacket[2]));
      ApplicationNumber   := GetWord(addr(ReplyPacket[6]));
    end;
end;

Function SetFileServerDateAndTime(year   : word;
                                  month  : word;
                                  day    : word;
                                  hour   : word;
                                  minute : word;
                                  second : word) : byte;
var
   r           : registers;
   SendPacket  : array[0..9] of byte;
   ReplyPacket : array[0..2] of byte;
   WordPtr     : ^Word;

begin

  WordPtr := addr(SendPacket);
  WordPtr^ := 7;
  SendPacket[2] := 202;
  SendPacket[3] := year;
  SendPacket[4] := month;
  SendPacket[5] := day;
  SendPacket[6] := hour;
  SendPacket[7] := minute;
  SendPacket[8] := second;
  WordPtr  := addr(ReplyPacket);
  WordPtr^ := 0;
  r.BX := r.DS;
  r.AH := $0E3;
  r.DS := SEG(SendPacket);
  r.SI := OFS(SendPacket);
  r.ES := SEG(ReplyPacket);
  r.DI := OFS(ReplyPacket);
  intr($21,r);
  r.DS := r.BX;
  SetFileServerDateAndTime := r.AL;
end;

Function GetFileServerDateAndTime(Var year   : word;
                                  Var month  : word;
                                  Var day    : word;
                                  Var hour   : word;
                                  Var minute : word;
                                  Var second : word) : byte;

var
   r           : registers;
   ReplyPacket : array[0..7] of byte;
   WordPtr     : ^Word;

begin
  r.BX := r.DS;
  r.AH := $0E7;
  r.DS := SEG(ReplyPacket);
  r.DX := OFS(ReplyPacket);
  intr($21,r);
  r.DS := r.BX;
  GetFileServerDateAndTime := r.AL;
  Year   := ReplyPacket[0];
  Month  := ReplyPacket[1];
  Day    := ReplyPacket[2];
  Hour   := ReplyPacket[3];
  Minute := ReplyPacket[4];
  Second := ReplyPacket[5];
  end;


Function LogInNetWork : boolean;
var r : registers;
begin
      LogInNetWork := false;
      r.AX := $7A00;
      Intr($2F,r);
      if r.AL = $00 then
      LogInNetWork := false else
      LogInNetWork := true;
end;

Function GetConnectionNumber : byte;
var r : registers;

begin
   r.BX := r.DS;
   r.AH := $DC;
   Intr($21,r);
   r.DS := r.BX;
   GetConnectionNumber := r.AL;
end;

Function GetNumberOfLocalDrives : byte;
var r : registers;

begin
   r.BX := r.DS;
   r.AH := $DB;
   Intr($21,r);
   r.DS := r.BX;
   GetNumberOfLocalDrives := r.AL;
end;

Function GetConnectionInformation(ConnectionNumber:byte;
  Var ObjectName : string; var ObjectType : word;
  var ObjectID   : longint; var LoginTime : string): byte;

  var
    WordPtr:^Word;
    r:registers;
    SendPacket : array[0..4] of byte;
    ReplyPacket : array[0..64] of byte;

    begin
      SendPacket[2] := $16;
      SendPacket[3] := ConnectionNumber;
      WordPtr := addr(SendPacket);
      WordPtr^:=2;
      WordPtr := addr(ReplyPacket);
      WordPtr^ := 62;
      r.BX := r.DS;
      r.DX := r.ES;
      r.ah := $e3;
      r.ds := seg(SendPacket);
      r.si := ofs(SendPacket);
      r.es := seg(ReplyPacket);
      r.di := ofs(ReplyPacket);
      intr($21,r);
      r.DS := r.BX;
      r.ES := r.DX;
      GetConnectionInformation := r.al;
      if r.al = 0
        then
        begin
          ObjectID := GetLong(addr(ReplyPacket[2]));
          ObjectType := GetWord(addr(ReplyPacket[6]));
          move(ReplyPacket[8],ObjectName[1],48);
          ObjectName[0] := chr(48);
          move(ReplyPacket[56],LoginTime[1],7);
          LoginTime[0] := chr(7);
       end;
          end;

end.
