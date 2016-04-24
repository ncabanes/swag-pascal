(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0064.PAS
  Description: Unit to handle bit operations
  Author: HORST KRAEMER
  Date: 11-26-94  05:09
*)

{ Ok Here is a nice little unit to handle bit operations. }
UNIT Bits;

INTERFACE

function CheckBit(bit_number : byte; byte_on : byte) : boolean;
function ChangeBit(bit_number : byte; byte_on : byte) : byte;
function BitON(bit_number : byte; byte_on : byte) : byte;
function BitOFF(bit_number : byte; byte_on : byte) : byte;

IMPLEMENTATION

const
  test : array[0..7] of byte = (1,2,4,8,$10,$20,$40,$80);

function CheckBit(bit_number : byte; byte_on : byte) : boolean;
begin
  CheckBit := byte_on and test[bit_number] <> 0
end;

function ChangeBit(bit_number : byte; byte_on : byte) : byte;
begin
  ChangeBit := byte_on xor test[bit_number]
end;

function BitON(bit_number : byte; byte_on : byte) : byte;
begin
  BitON := byte_on or test[bit_number]
end;

function BitOFF(bit_number : byte; byte_on : byte) : byte;
begin
  BitOFF := byte_on and not test[bit_number]
end;

end.
