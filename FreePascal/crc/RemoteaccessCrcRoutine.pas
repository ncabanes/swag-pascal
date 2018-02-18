(*
  Category: SWAG Title: 16/32 BIT CRC ROUTINES
  Original name: 0018.PAS
  Description: RemoteAccess CRC Routine
  Author: MARTIN WOODS
  Date: 02-21-96  21:04
*)

(*
unit racrc;
interface

procedure makecrc32table;
function updatecrc32(c : byte; crc : longint) : longint;
function calccrc(pass1: string) : longint;

implementation
*)
var
    crc32table : array [byte] of longint;
    crcval : longint;
    j      : integer;

procedure makeCRC32table;
var crc : longint;
    i,n : byte;
begin
 for i := 0 to 255 do
   begin
     crc := i;
     for n := 1 to 8 do
       if odd(crc) then
         crc := (crc shr 1) xor $EDB88320
       else
         crc := crc shr 1;
     crc32table[i] := crc;
   end;
end;

function updateCRC32(c : byte; crc : longint) : longint;
begin
 updateCRC32 := crc32table[lo(crc) xor c] xor (crc shr 8);
end;

function calccrc(pass1 : string) : longint;
begin
  makecrc32table;
  crcval := $FFFFFFF(*F*);
  for j := 1 to length(pass1) do
    begin
      crcval := updateCRC32(ord(pass1[j]),crcval);
    end;
    calccrc := crcval;
end;


(*Use like this:*)
var
  password: string;
  i: longint;
begin
  password := 'REMOTEACCSS';
  i := calccrc(password);
  writeLn(i);
  readln;
end.
