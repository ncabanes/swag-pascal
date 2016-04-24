(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0004.PAS
  Description: GET-ID3.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:52
*)

{
[   Does anyone know the syntax For Novell-specific interrupts in Pascal
[(or C)?  I have posted this message in all the pascal confs nad haven't
[had any replies.  Any help is appreciated.
[  Specifically, I need to use interrupts to find the username, security
[in a certain directory and groups belongs to.

Since this is Novell-specific I hope the moderator won't mind if I
answer this one in this conference, rather than Pascal conf...

You Absolutely NEED a copy of "System Calls - Dos" from Novell. This
book has every last call you'll ever need For getting inFormation out of
NetWare. Warning: some of their inFormation is erroneous, and you'll
just have to do things like count up the size of the Reply buffers, For
example, and not trust their reported Record sizes.

Just as an example of how to use the inFormation from the System Calls
book, here's an example of a Function I slapped together to return a
3-Character username. Pretty much all the Novell calls work the same
way: you set up a Request buffer and a Reply buffer, then you read your
results into whatever Format you want them. Hope this helps:
}

Function GetNetUserID:String;
Var
  NovRegs:Registers;
  Answer:String[3];
  iii:Integer;
  ConnectNo:Byte;
  Request   : Record
                Len    : Word;                    {LO-HI}
                SubF   : Byte;
                ConnNum: Word;                    {HI-LO}
              end;
  Reply     : Record
                Len    : Word;                    {LO-HI}
                ObjID  : LongInt;                 {HI-LO}
                ObjType: Word;
                ObjName: Array[1..48] of Byte;
                LogTime: Array[1..7] of Byte;
              end;
begin
  if (ReqdNetType <> Novell) then
    GetNetUserID := copy(ParamStr(2),1,3);
  if (ReqdNetType = Novell) then

  begin

    With NovRegs do
    begin
      AH := $dc;
      AL := $00;
      cx := $0000;
    end;

    MsDos(NovRegs);
    ConnectNo:=NovRegs.AL;

    For iii := 1 to 48 do
    begin
      Reply.ObjName[iii] := $00;
    end;

    With Request do
    begin
      Len    := Sizeof(Request) - 2;
      SubF   := $16;
      ConnNum:= (ConnectNo);
    end;

    Reply.Len := Sizeof(Reply) - 2;

    With NovRegs do
    begin
      AH := $e3;
      DS := Seg(Request);
      SI := ofs(Request);
      ES := Seg(Reply);
      DI := ofs(Reply);
    end;

    MsDos(NovRegs);
    Answer:='   ';

    For iii:= 1 to 3 do
    begin
      Answer[iii]:= chr(Reply.ObjName[iii]);
    end;

    GetNetUserID:= Answer;
  end;
end; {GetNetUserID}

{
That $e3 in the AH register is the generic bindery call. $16 is the
subFunction For "Get Connection Name" in the Bindery calls.
}

