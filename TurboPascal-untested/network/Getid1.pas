(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0002.PAS
  Description: GET-ID1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:52
*)

{ TS> Can anybody help me finding the interrupt For getting
 TS> a novell current user_name and the current station adress ??
}
Procedure GetConnectionInfo
(Var LogicalStationNo: Integer; Var Name: String; Var HEX_ID: String;
 Var ConnType : Integer; Var DateTime : String; Var retcode:Integer);

Var
  Reg            : Registers;
  I,X            : Integer;
  RequestBuffer  : Record
                     PacketLength : Integer;
                     FunctionVal  : Byte;
                     ConnectionNo : Byte;
                   end;
  ReplyBuffer    : Record
                     ReturnLength : Integer;
                     UniqueID1    : Packed Array [1..2] of Byte;
                     UniqueID2    : Packed Array [1..2] of Byte;
                     ConnType     : Packed Array [1..2] of Byte;
                     ObjectName   : Packed Array [1..48] of Byte;
                     LoginTime    : Packed Array [1..8] of Byte;
                   end;
  Month          : String[3];
  Year,
  Day,
  Hour,
  Minute         : String[2];

begin
  With RequestBuffer Do begin
    PacketLength := 2;
    FunctionVal := 22;  { 22 = Get Station Info }
    ConnectionNo := LogicalStationNo;
  end;
  ReplyBuffer.ReturnLength := 62;
  With Reg Do begin
    Ah := $e3;
    Ds := Seg(RequestBuffer);
    Si := ofs(RequestBuffer);
    Es := Seg(ReplyBuffer);
    Di := ofs(ReplyBuffer);
  end;
  MsDos(Reg);
  name := '';
  hex_id := '';
  connType := 0;
  datetime := '';
  if Reg.al = 0 then begin
    With ReplyBuffer Do begin
      I := 1;
      While (I <= 48)  and (ObjectName[I] <> 0) Do begin
        Name[I] := Chr(Objectname[I]);
        I := I + 1;
      end { While };
      Name[0] := Chr(I - 1);
      if name<>'' then
      begin
       Str(LoginTime[1]:2,Year);
       Month := Months[LoginTime[2]];
       Str(LoginTime[3]:2,Day);
       Str(LoginTime[4]:2,Hour);
       Str(LoginTime[5]:2,Minute);
       if Day[1] = ' ' then Day[1] := '0';
       if Hour[1] = ' ' then Hour[1] := '0';
       if Minute[1] = ' ' then Minute[1] := '0';
       DateTime := Day+'-'+Month+'-'+Year+' ' + Hour + ':' + Minute;
      end;
    end { With };
  end;
  retcode := reg.al;
  if name<>'' then
  begin
   hex_id := '';
   hex_id := hexdigits[replybuffer.uniqueid1[1] shr 4];
   hex_id := hex_id + hexdigits[replybuffer.uniqueid1[1] and $0F];
   hex_id := hex_id + hexdigits[replybuffer.uniqueid1[2] shr 4];
   hex_id := hex_id + hexdigits[replybuffer.uniqueid1[2] and $0F];
   hex_id := hex_id + hexdigits[replybuffer.uniqueid2[1] shr 4];
   hex_id := hex_id + hexdigits[replybuffer.uniqueid2[1] and $0F];
   hex_id := hex_id + hexdigits[replybuffer.uniqueid2[2] shr 4];
   hex_id := hex_id + hexdigits[replybuffer.uniqueid2[2] and $0F];
   ConnType := replybuffer.connType[2];
  { Now we chop off leading zeros }
   While hex_id[1]='0' do hex_id := copy(hex_id,2,length(hex_id));
 end;
end; { GetConnectInfo };


