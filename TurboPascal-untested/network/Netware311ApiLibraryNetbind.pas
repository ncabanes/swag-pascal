(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0036.PAS
  Description: Netware 3.11 API Library - NetBind
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
            ║                 S.Perevoznik                     ║
            ║                     1996                         ║
            ╚══════════════════════════════════════════════════╝
}

Unit NetBind;

Interface

Uses NetConv;



Const

  OT_UNKNOWN                      = $00;
  OT_USER                         = $01;
  OT_USER_GROUP                   = $02;
  OT_PRINT_QUEUE                  = $03;
  OT_FILE_SERVER                  = $04;
  OT_JOB_SERVER                   = $05;
  OT_GATEWAY                      = $06;
  OT_PRINT_SERVER                 = $07;
  OT_ARCHIVE_QUEUE                = $08;
  OT_ARCHIVE_SERVER               = $09;
  OT_JOB_QUEUE                    = $0A;
  OT_ADMINISTRATION               = $0B;

  OT_NAS_SNA_GATEWAY              = $21;  { }
  OT_REMOTE_BRIDGE_SERVER         = $24;  { }
  OT_TIME_SYNCHRONIZATION_SERVER  = $2D;  { }
  OT_ARCHIVE_SERVER_DYNAMIC_SAP   = $2E;  { }
  OT_ADVERTISING_PRINT_SERVER     = $47;  { }
  OT_BTRIEVE_VAP                  = $4B;  { }
  OT_PRINT_QUEUE_USER             = $53;  { }

Function ScanBinderyObject( searchObjectName : string;
                            searchObjectType : word;
                            Var objectID     : LongInt;
                            Var objectName   : string;
                            Var objectType   : word;
                            Var objectHasProperties  : byte;
                            Var objectFlag           : byte;
                            Var objectSecurity       : byte ) : byte;

Function ScanProperty( ObjectName           : string;
                       ObjectType           : word;
                       SearchPropertyName   : string;
                       Var SequenceNumber   : LongInt;
                       Var PropertyName     : string;
                       Var PropertyFlags    : byte;
                       Var PropertySecurity : byte;
                       Var PropertyHasValue : byte;
                       Var MoreProperties   : byte) : byte;


Function ReadPropertyValue(ObjectName       : string;
                           ObjectType       : word;
                           PropertyName     : string;
                           SegmentNumber    : byte;
                           Var PropertyValue: string;
                           Var MoreSegments : byte;
                           Var PropertyFlags: byte) : byte;

Implementation

Uses Dos;

Function ScanBinderyObject( searchObjectName : string;
                            searchObjectType : word;
                            Var objectID     : LongInt;
                            Var objectName   : string;
                            Var objectType   : word;
                            Var objectHasProperties  : byte;
                            Var objectFlag           : byte;
                            Var objectSecurity       : byte ) : byte;

 var
   r : registers;
   SendPacket  : array[0..57] of byte;
   ReplyPacket : array[0..59] of byte;
   WordPtr     : ^word;
   LongPtr     : ^longInt;

begin
   SendPacket[2] := 55;
   LongPtr  := addr(SendPacket[3]);
   LongPtr^ := GetLong(addr(ObjectID));
   WordPtr  := addr(SendPacket[7]);
   WordPtr^ := GetWord(addr(SearchObjectType));
   SendPacket[9] := Length(SearchObjectName);
   move(SearchObjectName[1],SendPacket[10],Length(SearchObjectName));
   WordPtr  := Addr(SendPacket);
   WordPtr^ := Length(SearchObjectName) + 8;
   WordPtr  := Addr(ReplyPacket);
   WordPtr^ := 57;
   r.AH := 227;
   r.BX := r.DS;
   r.DS := SEG(SendPacket);
   r.SI := OFS(SendPacket);
   r.ES := SEG(ReplyPacket);
   r.DI := OFS(ReplyPacket);
   intr($21,r);
   ScanBinderyObject := r.AL;
   r.DS := r.BX;
   if r.AL = 0 then
    begin
      ObjectID   := GetLong(addr(ReplyPacket[2]));
      ObjectType := GetWord(addr(ReplyPacket[6]));
      move(ReplyPacket[8],ObjectName[1],48);
      ObjectName[0]  := chr(48);
      ObjectFlag     := ReplyPacket[56];
      ObjectSecurity := ReplyPacket[57];
      ObjectHasProperties := ReplyPacket[58];
    end;
end;

Function ScanProperty( ObjectName           : string;
                       ObjectType           : word;
                       SearchPropertyName   : string;
                       Var SequenceNumber   : LongInt;
                       Var PropertyName     : string;
                       Var PropertyFlags    : byte;
                       Var PropertySecurity : byte;
                       Var PropertyHasValue : byte;
                       Var MoreProperties   : byte) : byte;

 var
   r : registers;
   SendPacket  : array[0..57] of byte;
   ReplyPacket : array[0..59] of byte;
   WordPtr     : ^word;
   LongPtr     : ^longInt;

begin
   SendPacket[2] := 60;
   WordPtr  := addr(SendPacket[3]);
   WordPtr^ := GetWord(addr(ObjectType));
   SendPacket[5] := Length(ObjectName);
   move(ObjectName[1],SendPacket[6],Length(ObjectName));
   LongPtr  := Addr(SendPacket[Length(ObjectName)+6]);
   LongPtr^ := GetLong(addr(SequenceNumber));
   SendPacket[Length(ObjectName) + 10] := Length(SearchpropertyName);
   move(SearchPropertyName[1],SendPacket[Length(ObjectName) + 11],
        Length(searchPropertyName));
   WordPtr  := Addr(SendPacket);
   WordPtr^ := Length(ObjectName) + Length(SearchPropertyName) + 9;
   WordPtr  := Addr(ReplyPacket);
   WordPtr^ := 26;
   r.AH := 227;
   r.BX := r.DS;
   r.DS := SEG(SendPacket);
   r.SI := OFS(SendPacket);
   r.ES := SEG(ReplyPacket);
   r.DI := OFS(ReplyPacket);
   intr($21,r);
   ScanProperty := r.AL;
   r.DS := r.BX;
   if r.AL = 0 then
    begin
      move(ReplyPacket[2],PropertyName[1],16);
      PropertyName[0]  := chr(16);
      PropertyFlags    := ReplyPacket[18];
      PropertySecurity := ReplyPacket[19];
      SequenceNumber   := GetLong(addr(ReplyPacket[20]));
      PropertyHasValue := ReplyPacket[24];
      MoreProperties   := ReplyPacket[25];
    end;
end;

Function ReadPropertyValue(ObjectName       : string;
                           ObjectType       : word;
                           PropertyName     : string;
                           SegmentNumber    : byte;
                           Var PropertyValue: string;
                           Var MoreSegments : byte;
                           Var PropertyFlags: byte) : byte;
 var
   r : registers;
   SendPacket  : array[0..70] of byte;
   ReplyPacket : array[0..132] of byte;
   WordPtr     : ^word;
   LongPtr     : ^longInt;
   i           : byte;
begin
    SendPacket[2] := 61;
    WordPtr  := addr(SendPacket[3]);
    WordPtr^ := GetWord(addr(ObjectType));
    SendPacket[5] := Length(ObjectName);
    move(ObjectName[1],SendPacket[6],Length(ObjectName));
    SendPacket[Length(ObjectName) + 6] := SegmentNumber;
    SendPacket[Length(ObjectName) + 7] := Length(PropertyName);
    move(PropertyName[1],SendPacket[Length(ObjectName) + 8],
         Length(PropertyName));
   WordPtr  := Addr(SendPacket);
   WordPtr^ := Length(ObjectName) + Length(PropertyName) + 6;
   WordPtr  := Addr(ReplyPacket);
   WordPtr^ := 130;
   r.AH := 227;
   r.BX := r.DS;
   r.DS := SEG(SendPacket);
   r.SI := OFS(SendPacket);
   r.ES := SEG(ReplyPacket);
   r.DI := OFS(ReplyPacket);
   intr($21,r);
   ReadPropertyValue := r.AL;
   if r.AL = 0 then
    begin
      move(ReplyPacket[2],PropertyValue[1],128);
      PropertyValue[0] := chr(128);
      i := Pos(chr(0),PropertyValue);
      PropertyValue[0] := chr(i);
      MoreSegments  := ReplyPacket[130];
      PropertyFlags := ReplyPacket[131];
    end;
end;



end.

