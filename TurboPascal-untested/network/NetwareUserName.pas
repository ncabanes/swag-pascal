(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0011.PAS
  Description: NETWARE User name
  Author: NORBERT IGL
  Date: 11-21-93  09:43
*)

{
From: NORBERT IGL
Subj: Netware "User name"

 I need a way to get the current user name from the netware shell.
 For instance, if I'm logged into server MYSERVER as user SUPERVISOR,
 I need some way to get 'supervisor' as the user name.  (Kind of like
 WHOAMI would return: You are user SUPERVISOR on server MYSERVER)
}

uses dos;

function lStationNumber:byte;   { MY logical Station(connection)-Number }
var   regs     : Registers;
begin
   regs.ah := $DC;
   MsDos(regs );
   lStationNumber := pcregs.al;
end;

function GetUserName( Station: byte):String;
Var
  i               : byte;
  Regs            : Registers;
  name            : string[50];
  Reply    : Record
                Filler1      : Array [1..8] of byte;
                ObjectName   : Array [1..48] of Byte;
                Filler2me    : Array [1..8] of Byte;
             End;
  Request : Record
               PacketLen : Integer;
               vFunc     : Byte;
               ConnNb    : Byte;
             End;

Begin
  With Request do
  begin
    PacketLen := 2;
    vFunc     := 22;
    ConnNbm   := Station;
  End;
  Reply.ReturnLength := 62;
  With Regs Do Begin
    Ah := $e3;
    Ds := Seg(Request);
    Si := Ofs(Request);
    Es := Seg(Reply);
    Di := Ofs(Reply);
  End;
  MsDos(Reg);
          {         1         2         3         4        }
          {123456789012345678901234567890123456789012345678}
  name := '                                                ';
  If Regs.al = 0 Then with reply do
  begin
     move( objectName[1] , name[1], 48 );
     i := pos(#0, name );
     name[0] := char(i-1);
  end;
end;

[...]

var me : byte;

begin
   me := lStationNumber;
   writeln(' Hello, ', GetUserName( me ),
           ' you''re hooked in on Station # ', me );
end.

