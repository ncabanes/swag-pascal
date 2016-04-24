(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0042.PAS
  Description: Netware 3.11 API Library - File Server
  Author: S.PEREVOZNIK
  Date: 11-29-96  08:17
*)

{
            ╔══════════════════════════════════════════════════╗
            ║     ┌╦═══╦┐┌╦═══╦┐┌╦═══╦┐┌╦═╗ ╦┐┌╦═══╦┐┌╔═╦═╗┐   ║
            ║     │╠═══╩┘├╬═══╬┤└╩═══╦┐│║ ║ ║│├╬══      ║      ║
            ║     └╩     └╩   ╩┘└╩═══╩┘└╩ ╚═╩┘└╩═══╩┘   ╩      ║
            ║                                                  ║
            ║     NetWare 3.11 API Library for Turbo Pascal    ║
            ║                      by                          ║
            ║                S.Perevoznik                      ║
            ║                     1996                         ║
            ╚══════════════════════════════════════════════════╝
}
Unit NetSrv;
{ Working with file-server}

Interface

Function  CheckConsolePrivileges : boolean;
{true, if user is console operator}

Function EnableFileServerLogin : byte;
{ enable login on file server }

Function DisableFileServerLogin : byte;
{ disable user's login on file server}

Function  EnableTransactionTracking : byte;
{ enable transaction tracking }

Function  DisableTransactionTracking : byte;
{ disable transaction tracking }

Function DownFileServer(ForceFlag : integer) : byte;
{ Down File server}

Function ClearConnectionNumber(connectionNumber : word) : byte;
{ clear connection}

Function GetFileServerDescriptionStrings(Var DString: string) : byte;
{ return file server description string}

Procedure Logout;
{ logout from network}


Implementation

Uses Dos;

Function  CheckConsolePrivileges : boolean;
Var
  r : registers;
  SendPacket  : array [0..3] of byte;
  ReplyPacket : array [0..2] of byte;
  WordPtr     : ^Word;

Begin
  SendPacket[2] := 200;
  WordPtr  := addr(SendPacket);
  WordPtr^ := 1;
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
  if r.AL = 0 then CheckConsolePrivileges := true
    else CheckConsolePrivileges := false;
End;

Function EnableFileServerLogin : byte;
Var
  r : registers;
  SendPacket  : array [0..3] of byte;
  ReplyPacket : array [0..2] of byte;
  WordPtr     : ^Word;

Begin
  SendPacket[2] := 204;
  WordPtr  := addr(SendPacket);
  WordPtr^ := 1;
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
  EnableFileServerLogin := r.AL;
end;

Function DisableFileServerLogin : byte;
Var
  r : registers;
  SendPacket  : array [0..3] of byte;
  ReplyPacket : array [0..2] of byte;
  WordPtr     : ^Word;

Begin
  SendPacket[2] := 203;
  WordPtr  := addr(SendPacket);
  WordPtr^ := 1;
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
  DisableFileServerLogin := r.AL;

end;

Function  EnableTransactionTracking : byte;
Var
  r : registers;
  SendPacket  : array [0..3] of byte;
  ReplyPacket : array [0..2] of byte;
  WordPtr     : ^Word;

Begin
  SendPacket[2] := 208;
  WordPtr  := addr(SendPacket);
  WordPtr^ := 1;
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
  EnableTransactionTracking := r.AL;

end;

Function  DisableTransactionTracking : byte;

Var
  r : registers;
  SendPacket  : array [0..3] of byte;
  ReplyPacket : array [0..2] of byte;
  WordPtr     : ^Word;

Begin
  SendPacket[2] := 207;
  WordPtr  := addr(SendPacket);
  WordPtr^ := 1;
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
  DisableTransactionTracking := r.AL;

end;

Function DownFileServer(ForceFlag : integer) : byte;
Var
  r : registers;
  SendPacket  : array [0..4] of byte;
  ReplyPacket : array [0..2] of byte;
  WordPtr     : ^Word;

Begin
  SendPacket[2] := 211;
  SendPacket[3] := ForceFlag or $FF00;
  WordPtr  := addr(SendPacket);
  WordPtr^ := 2;
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
  DownFileServer := r.AL;

end;

Function ClearConnectionNumber(connectionNumber : word) : byte;
Var
  r : registers;
  SendPacket  : array [0..4] of byte;
  ReplyPacket : array [0..2] of byte;
  WordPtr     : ^Word;

Begin
  SendPacket[2] := 210;
  SendPacket[3] := ConnectionNumber;
  WordPtr  := addr(SendPacket);
  WordPtr^ := 2;
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
  ClearConnectionNumber := r.AL;

end;

Function GetFileServerDescriptionStrings(Var DString     : string) : byte;


  var
    WordPtr:^Word;
    r:registers;
    SendPacket  : array[0..3] of byte;
    ReplyPacket : array[0..514] of byte;
    i           : integer;

    begin
      SendPacket[2] := $C9;
      WordPtr := addr(SendPacket);
      WordPtr^:=1;
      WordPtr := addr(ReplyPacket);
      WordPtr^ := 514;
      r.ah := $E3;
      r.BX := r.DS;
      r.ds := seg(SendPacket);
      r.si := ofs(SendPacket);
      r.es := seg(ReplyPacket);
      r.di := ofs(ReplyPacket);
      intr($21,r);
      r.DS := r.BX;
      GetFileServerDescriptionStrings := r.AL;
      if r.AL = 0
        then
        begin
           i := 32;
           move(ReplyPacket[2],DString[1],32);
           move(i,DString[0],1);
       end;
          end;

Procedure Logout;
Var
  r : registers;
  SendPacket  : array [0..2] of byte;
  ReplyPacket : array [0..2] of byte;
  WordPtr     : ^Word;

Begin
  WordPtr  := addr(SendPacket);
  WordPtr^ := 0;
  WordPtr  := addr(ReplyPacket);
  WordPtr^ := 0;
  r.BX := r.DS;
  r.AH := 215;
  r.DS := SEG(SendPacket);
  r.SI := OFS(SendPacket);
  r.ES := SEG(ReplyPacket);
  r.DI := OFS(ReplyPacket);
  intr($21,r);
  r.DS := r.BX;

end;

End.

