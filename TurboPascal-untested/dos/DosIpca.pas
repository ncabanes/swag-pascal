(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0020.PAS
  Description: Dos IPCA
  Author: GUY MCLOUGHLIN
  Date: 08-27-93  20:49
*)

{
GUY MCLOUGHLIN

 Program to load data into 16 Byte area of RAM known as
 the Dos "Inter-Process Communication Area".
}

Program Load_Dos_IPCA;

Type
  arby16 = Array[1..16] of Byte;

{ "Absolute" Array Variable used to access the Dos IPCA. }
Var
  IPCA  : arby16 Absolute $0000:$04F0;
  Index : Byte;

begin
{ Write data to the Dos IPCA. }
  For Index := 1 to 16 do
    IPCA[Index] := (100 + Index)
end.

{ Program to read data from 16 Byte area of RAM known  }
{ as the Dos "Inter-Process Communication Area". }
Program Read_Dos_IPCA;

Type
  arby16 = Array[1..16] of Byte;

{ "Absolute" Array Variable used to access the Dos IPCA. }
Var
  IPCA  : arby16 Absolute $0000:$04F0;
  Index : Byte;

begin
  Writeln;
  { Display the current data found in the Dos IPCA. }
  For Index := 1 to 16 do
    Write(IPCA[Index] : 4);
  Writeln
end.

{
  NOTE:
  if you plan on using this in any of your serious applications, I would
  recommend using the last 2 Bytes of the IPCA as a CRC-16 error-check. As
  you have no guarantee that another Program won't use the IPCA too.
}
