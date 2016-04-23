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

Unit NetMsg;

Interface

Const
  AllMessage        = 0;  { receive all message                   }
  ServerOnly        = 1;  { receive message from file server only }
  NoMessage         = 2;  { not receive messag                    }
  StoreMessage      = 3;  { store message                         }
  DisableCheckTimer = 5;  { disable check shell timer             }
  EnableCheckTimer  = 6;  { enable check shell timer              }


Procedure SetBroadcastMode(Mode: byte);

Procedure SendToCon(Msg:String);
{send message to console }

Procedure DisableMSG;
{ disable broadcast message}

Procedure EnableMSG;
{ enable broadcast message }

Function  GetBroadcastMode : byte;
{ return current broadcast mode }

Function  SendBroadcastMessage(Message:string;
                               ConnectionNumber:byte) : byte;
{ send broadcast message to station with
  connection number}

Function  GetBroadcastMessage : String;

Function LogNetWorkMessage(msg : string) : byte;
{}

Function OpenMessagePipe(ConnectionList  : string;
                         Var ResultList  : string;
                         ConnectionCount : byte) : byte;

Function CloseMessagePipe(ConnectionList : string;
                         Var ResultList  : string;
                         ConnectionCount : byte) : byte;

Function CheckPipeStatus (ConnectionList  : string;
                          Var ResultList  : string;
                          ConnectionCount : byte) : byte;

Function  SendPersonalMessage(Message:string;
                               ConnectionNumber:byte) : byte;

Function  GetPersonalMessage (Var ConnectionNumber : byte): String;



Implementation

Uses Dos;


Procedure SetBroadcastMode(Mode : byte);
 var
    r : registers;
 begin
    r.BX := r.DS;
    r.AH := $0DE;
    r.DL := MODE;
    intr($21,r);
    r.DS := r.BX;
 end;

Function GetBroadcastMode : byte;
 var
   r : registers;
 begin
   r.AH := $0DE;
   r.DL := 4;
   Intr($21,r);
   GetBroadcastMode := r.AL;
 end;

Procedure DisableMSG;
 var
   r : registers;
   SendPacket  : array[0..4] of byte;
   ReplyPacket : array[0..3] of byte;
   WordPtr     : ^word;
 begin
  SendPacket[2] := 2;
  WordPtr  := addr(SendPacket);
  WordPtr^ := 1;
  WordPtr  := addr(ReplyPacket);
  WordPtr^ := 2;
  r.BX := r.DS;
  r.AH := $0E1;
  r.DS := SEG(SendPacket);
  r.SI := OFS(SendPacket);
  r.ES := SEG(ReplyPacket);
  r.DI := OFS(ReplyPacket);
  intr($21,r);
  r.DS := r.BX;
 end;


Procedure EnableMSG;
 var
   r : registers;
   SendPacket  : array[0..4] of byte;
   ReplyPacket : array[0..3] of byte;
   WordPtr     : ^word;
begin
  SendPacket[2] := 3;
  WordPtr  := addr(SendPacket);
  WordPtr^ := 1;
  WordPtr  := addr(ReplyPacket);
  WordPtr^ := 2;
  r.BX := r.DS;
  r.AH := $0E1;
  r.DS := SEG(SendPacket);
  r.SI := OFS(SendPacket);
  r.ES := SEG(ReplyPacket);
  r.DI := OFS(ReplyPacket);
  intr($21,r);
  r.DS := r.BX;
end;

Function SendBroadcastMessage(Message:string; ConnectionNumber:byte) : byte;
  var
    WordPtr     : ^word;
    SendPacket  : array [0..160] of byte;
    ReplyPacket : array [0..103] of byte;

    r  : registers;

  begin
   SendPacket[2] := 0;
   SendPacket[3] := 1;
   SendPacket[4] := ConnectionNumber;
   SendPacket[5] := length(Message);
   if SendPacket[5] > 56 then SendPacket[5] := 56;
   move(Message[1],SendPacket[6],length(Message));
   WordPtr  := addr(SendPacket);
   WordPtr^ := Length(Message) + 4;
   WordPtr  := addr(ReplyPacket);
   WordPtr^ := 2;
   ReplyPacket[2] := 1;
   ReplyPacket[3] := 0;
   ReplyPacket[4] := 0;
     r.AH := $E1;
     r.BX := r.DS;
     r.DS := SEG(SendPacket);
     r.SI := OFS(SendPacket);
     r.ES := SEG(ReplyPacket);
     r.DI := OFS(ReplyPacket);
     Intr($21,r);
     r.DS := r.BX;
     SendBroadcastMessage := r.AL;
 end;

Procedure SendToCon(Msg : string);
var
  s   : array [0..64] of byte;
  i   : integer;
  r   : registers;
begin

  s[0] := 0;
  s[1] := 4;
  s[2] := $09;
  s[3] := length(Msg);
  if S[3] > 60 then S[3] := 60;
  move(Msg[1],s[4],length(Msg));
  r.AH := $0E1;
  r.BX := r.DS;
  r.DS := SEG(S);
  r.SI := OFS(S);
  Intr($21,r);
  r.DS := r.BX;
end;

Function LogNetWorkMessage(msg : string) : byte;
  var
    SendPacket  : array[0..84] of byte;
    ReplyPacket : array[0..2] of byte;
    r : registers;
    WordPtr     : ^word;

begin
    SendPacket[2] := $0D;
    SendPacket[3] := Length(Msg);
    if Length(Msg) > 80 then SendPacket[3] := 80;
    move(Msg[1],SendPacket[4],SendPacket[3]);
    WordPtr  := addr(SendPacket);
    WordPtr^ := SendPacket[3] + 2;
    WordPtr  := addr(ReplyPacket);
    WordPtr^ := 0;
     r.AL := 0;
     r.AH := $E3;
     r.BX := r.DS;
     r.DS := SEG(SendPacket);
     r.SI := OFS(SendPacket);
     r.ES := SEG(ReplyPacket);
     r.DI := OFS(ReplyPacket);
     Intr($21,r);
     r.DS := r.BX;
     LogNetWorkMessage := r.AL;
end;

Function  GetBroadcastMessage : String;
  var
    r: registers;
    SendPacket  : array [0..3] of byte;
    ReplyPacket : array [0..58] of byte;
    WordPtr     : ^word;
    Len         : byte;
    St          : string;

  begin
    WordPtr  := addr(SendPacket);
    WordPtr^ := 1;
    SendPacket[2] := 1;
    WordPtr  := addr(ReplyPacket);
    WordPtr^ := 56;
    ReplyPacket[2] := 55;
     r.AH := $E1;
     r.BX := r.DS;
     r.DS := SEG(SendPacket);
     r.SI := OFS(SendPacket);
     r.ES := SEG(ReplyPacket);
     r.DI := OFS(ReplyPacket);
     Intr($21,r);
     r.DS := r.BX;
     if r.AL = 0 then
      begin
        Len := ReplyPacket[2];
        move(ReplyPacket[3], st[1], Len);
        move(Len,st[0],1);
        GetBroadcastMessage := st;
      end;
    end;

Function OpenMessagePipe(ConnectionList  : string;
                         Var ResultList  : string;
                         ConnectionCount : byte) : byte;
{ æ«ºñá¡¿Ñ ¬á¡á½á «í¼Ñ¡á ß««íΘÑ¡¿∩¼¿ }
var
    r: registers;
    SendPacket  : array [0..104] of byte;
    ReplyPacket : array [0..103] of byte;
    WordPtr     : ^word;

begin
   SendPacket[2] := 6;
   SendPacket[3] := ConnectionCount;
   move(ConnectionList[1],SendPacket[4],ConnectionCount);
   WordPtr  := addr(SendPacket);
   WordPtr^ := ConnectionCount + 2;
   WordPtr  := addr(ReplyPacket);
   WordPtr^ := ConnectionCount + 1;
     r.AH := $E1;
     r.BX := r.DS;
     r.DS := SEG(SendPacket);
     r.SI := OFS(SendPacket);
     r.ES := SEG(ReplyPacket);
     r.DI := OFS(ReplyPacket);
     Intr($21,r);
     r.DS := r.BX;
     if r.AL = 0 then
      move(ReplyPacket[3],ResultList[1],ConnectionCount);
      OpenMessagePipe := r.AL;
end;


Function CloseMessagePipe(ConnectionList : string;
                         Var ResultList  : string;
                         ConnectionCount : byte) : byte;
{ çá¬αδΓ¿Ñ ¬á¡á½á «í¼Ñ¡á ß««íΘÑ¡¿∩¼¿ }
var
    r: registers;
    SendPacket  : array [0..104] of byte;
    ReplyPacket : array [0..103] of byte;
    WordPtr     : ^word;
begin
   SendPacket[2] := 7;
   SendPacket[3] := ConnectionCount;
   move(ConnectionList[1],SendPacket[4],ConnectionCount);
   WordPtr  := addr(SendPacket);
   WordPtr^ := ConnectionCount + 2;
   WordPtr  := addr(ReplyPacket);
   WordPtr^ := ConnectionCount + 1;
   ReplyPacket[2] := ConnectionCount;
     r.AH := $E1;
     r.BX := r.DS;
     r.DS := SEG(SendPacket);
     r.SI := OFS(SendPacket);
     r.ES := SEG(ReplyPacket);
     r.DI := OFS(ReplyPacket);
     Intr($21,r);
     r.DS := r.BX;
     if r.AL = 0 then
      move(ReplyPacket[3],ResultList[1],ConnectionCount);
      CloseMessagePipe := r.AL;

end;

Function CheckPipeStatus (ConnectionList  : string;
                          Var ResultList  : string;
                          ConnectionCount : byte) : byte;
{ Åα«óÑα¬á ß«ßΓ«∩¡¿∩ ¬á¡á½á «í¼Ñ¡á ß««íΘÑ¡¿∩¼¿ }
var
    r: registers;
    SendPacket  : array [0..104] of byte;
    ReplyPacket : array [0..103] of byte;
    WordPtr     : ^word;
begin
   SendPacket[2] := 8;
   SendPacket[3] := ConnectionCount;
   move(ConnectionList[1],SendPacket[4],ConnectionCount);
   WordPtr  := addr(SendPacket);
   WordPtr^ := ConnectionCount + 2;
   WordPtr  := addr(ReplyPacket);
   WordPtr^ := ConnectionCount + 1;
   ReplyPacket[2] := ConnectionCount;
     r.AH := $E1;
     r.BX := r.DS;
     r.DS := SEG(SendPacket);
     r.SI := OFS(SendPacket);
     r.ES := SEG(ReplyPacket);
     r.DI := OFS(ReplyPacket);
     Intr($21,r);
     r.DS := r.BX;
     if r.AL = 0 then
      move(ReplyPacket[3],ResultList[1],ConnectionCount);
      CheckPipeStatus := r.AL;

end;

Function SendPersonalMessage(Message:string; ConnectionNumber:byte) : byte;
  var
    WordPtr     : ^word;
    SendPacket  : array [0..231] of byte;
    ReplyPacket : array [0..103] of byte;
    r  : registers;

  begin
   SendPacket[2] := 4;
   SendPacket[3] := 1;
   SendPacket[4] := ConnectionNumber;
   SendPacket[5] := length(Message);
   if SendPacket[5] > 126 then SendPacket[5] := 126;
   move(Message[1],SendPacket[6],length(Message));
   WordPtr  := addr(SendPacket);
   WordPtr^ := Length(Message) + 4;
   WordPtr  := addr(ReplyPacket);
   WordPtr^ := 2;
   ReplyPacket[2] := 1;
   ReplyPacket[3] := 0;
   ReplyPacket[4] := 0;
     r.AH := $E1;
     r.BX := r.DS;
     r.DS := SEG(SendPacket);
     r.SI := OFS(SendPacket);
     r.ES := SEG(ReplyPacket);
     r.DI := OFS(ReplyPacket);
     Intr($21,r);
     r.DS := r.BX;
     SendPersonalMessage := r.AL;
 end;

Function  GetPersonalMessage(Var ConnectionNumber: byte) : String;
  var
    r: registers;
    SendPacket  : array [0..3] of byte;
    ReplyPacket : array [0..132] of byte;
    WordPtr     : ^word;
    Len         : byte;
    St          : string;

  begin
    WordPtr  := addr(SendPacket);
    WordPtr^ := 1;
    SendPacket[2] := 5;
    WordPtr  := addr(ReplyPacket);
    WordPtr^ := 130;
     r.AH := $E1;
     r.BX := r.DS;
     r.DS := SEG(SendPacket);
     r.SI := OFS(SendPacket);
     r.ES := SEG(ReplyPacket);
     r.DI := OFS(ReplyPacket);
     Intr($21,r);
     r.DS := r.BX;
     if r.AL = 0 then
      begin
        Len := ReplyPacket[3];
        move(ReplyPacket[4], st[1], Len);
        move(Len,st[0],1);
        GetPersonalMessage := st;
      end
    else GetPersonalMessage := '';
    ConnectionNumber := ReplyPacket[2];
    end;

end.
