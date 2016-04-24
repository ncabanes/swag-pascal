(*
  Category: SWAG Title: DATA TYPE & COMPARE ROUTINES
  Original name: 0039.PAS
  Description: Multi Format File
  Author: BRAD ZAVITSKY
  Date: 11-22-95  13:28
*)

{
Can someone give me some tips on how to speed up/improve my unit for  storing
multiple format data structures in a single file?

I use numerous data types that must be saved, so I came up with a simple
multi format file (MFF <g>) structure.  It has a 5 byte Header Id which
designates it a MFF structure, and a 7 byte Program Id which is used to
define which program the file belongs to (I would use 8 byte ProgId, but  then
would have to deal with all the triskadekaphobes out there =-> ).   The rest
of the file is made up of data packets which start with 2,  2byte word
variables, one denoting the type, the other the size of the  following data.

{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,Y-}

unit MFFUnit;

interface

const
  HeaderId     = 'MFF01';
  HeaderIdSize = 5;
  ProgIdSize   = 7;

type
  Arr5  = array[1..5] of char;
  Arr7  = array[1..7] of char;
  Arr12 = array[1..12] of char;
  Str5  = string[5];
  Str7  = string[7];

procedure WriteHeader(var F: file; HId: str5; Pid: str7);
procedure ReadHeader(var F: file; var HId: str5; var Pid: str7);
procedure WritePacket(var F: file; FPos: longint; var Dat; DataType,
                      DataSize: Word);
procedure ReadPacket(var F: file; FPos: longint; var Dat; var DataType,
                     DataSize: Word);


implementation

procedure WriteHeader;
var
  A1: Arr12;
  Count: integer;
begin
  Seek(F, 0);
  FillChar(A1, 12, #0);
  for Count := 1 to length(HiD) do A1[Count] := HiD[Count];
  for Count := 1 to length(PiD) do A1[Count+5] := PiD[Count];
  BlockWrite(F, A1, 12);
end;

procedure ReadHeader;
var
  A1: Arr12;
  Count: integer;
begin
  Seek(F, 0);
  Hid[0] := #5;
  PiD[0] := #7;

  BlockRead(F, A1, 12);

  for Count := 1 to 5 do if A1[Count] = #0 then
  begin
    HiD[0] := Chr(Count-1);
    break;
  end else HiD[Count] := A1[Count];

  for Count := 1 to 7 do if A1[Count+5] = #0 then
  begin
    PiD[0] := chr(Count-1);
    break;
  end else PiD[Count] := A1[Count+5];
end;

procedure WritePacket;
begin
  Seek(F, FPos);
  BlockWrite(F, DataType, 2);
  BlockWrite(F, DataSize, 2);
  BlockWrite(F, Dat, DataSize);
end;

procedure ReadPacket;
begin
  Seek(F, FPos);
  BlockRead(F, DataType, 2);
  BlockRead(F, DataSize, 2);
  BlockRead(F, Dat, DataSize);
end;

end.

