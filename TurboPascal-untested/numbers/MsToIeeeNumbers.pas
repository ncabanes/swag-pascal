(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0026.PAS
  Description: MS to IEEE Numbers
  Author: TREVOR CARLSON
  Date: 08-27-93  21:39
*)

{
Trevor Carlson

> Does anyone have source examples of how to convert an MSBIN to a
> LongInt Type Variable?
}

Type
  MKS = Array [0..3] of Byte;

Function MStoIEEE(Var MS) : Real;
{ Converts a 4 Byte Microsoft format single precision Real Variable as
  used in earlier versions of QuickBASIC and GW-BASIC to IEEE 6 Byte Real }
Var
  m    : MKS Absolute MS;
  r    : Real;
  ieee : Array [0..5] of Byte Absolute r;
begin
  FillChar(r, sizeof(r), 0);
  ieee[0] := m[3];
  ieee[3] := m[0];
  ieee[4] := m[1];
  ieee[5] := m[2];
  MStoieee := r;
end;  { MStoIEEE }


Function IEEEtoMS(ie : Real) : LongInt;
{ LongInt Type used only For convenience of Typecasting. Note that this will
  only be effective where the accuracy required can be obtained in the 23
  bits that are available With the MKS Type. }
Var
  ms    : MKS;
  ieee  : Array [0..5] of Byte Absolute ie;
begin
  ms[3] := ieee[0];
  ms[0] := ieee[3];
  ms[1] := ieee[4];
  ms[2] := ieee[5];
  IEEEtoMS := LongInt(ms);
end; { IEEEtoMS }

