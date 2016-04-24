(*
  Category: SWAG Title: 16/32 BIT CRC ROUTINES
  Original name: 0010.PAS
  Description: 16 & 32 BIT CRC
  Author: SAM LEVENTER
  Date: 08-27-93  20:34
*)

{
SAM LEVENTER

>    I'm not quite sure how CRC's work.  I have routines For calculating both
> 16-bit and 32-bit CRC values, however, they seem to be only For one Byte.
> How would I go about calculating the 16-bit CRC of an entire File?

  CRCs are CYCLIC redundancy codes.  That means that you cycle through the
entire File, ORing it With the old CRC.

Just call updateCRC in the below Unit.

This Program is donated to the Public
Domain by MarshallSoft Computing, Inc.
It is provided as an example of the use
of the Personal Communications Library.
}

Unit mycrc16;

Interface

Function UpdateCRC(crc:Word;data:Byte):Word;

Implementation

Const
  POLY = $1021;

Var
  CRCtable : Array [0..255] of Word;

{ compute updated CRC }
Function  UpdateCRC(crc : Word; data : Byte) : Word;
begin
  UpDateCRC := (crc SHL 8) xor (CRCtable[(crc SHR 8) xor data]);
end;

{ initialize CRC table }
Procedure InitCRC;
Var
  i : Integer;

  { calculate CRC table entry }
  Function CalcTable(data, genpoly, accum : Word) : Word;
  Var
    i : Word;
  begin
    data := data SHL 8;
    For i := 8 downto 1 do
    begin
      if ((data xor accum) and ($8000 <> 0)) then
        accum := (accum SHL 1) xor genpoly
      else
        accum := accum SHL 1;
      data := data SHL 1;
    end;
    CalcTable := accum;
  end;

begin
  For i := 0 to 255 do
    CRCtable[i] := CalcTable(i, POLY, 0);
end;

begin
  InitCRC;
end.

