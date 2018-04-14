(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0032.PAS
  Description: Setting/Getting BITS
  Author: CHRIS QUARTETTI
  Date: 11-02-93  05:00
*)

{
CHRIS QUARTETTI

>Is there an easy way to create a 1-bit or 2-bit data structure.  For
>example, a 2-bit Type that can hold 4 possible values.  For that matter,
>is there a hard way? <g>  Thanks very much -Greg

   I suppose this would qualify For the hard way-- not too flexible, but it
works. It would be a bit easier to do this if you wanted a bunch of the same
size Variables (ie 4 4 bit Variables, or an Array of 4*x 4 bit Variables).
FWIW I used BP7 here, but TP6 and up will work. Also, it need not be Object
oriented.
}

Type
  bitf = Object                                                                                  { split 'bits' into bitfields }
    bits : Word;                         { 16 bits total }

    Function  get : Word;

    Procedure set1(value : Word);        { this will be 2 bits }
    Function  get1 : Word;

    Procedure set2(value : Word);        { this will be 13 bits }
    Function  get2 : Word;

    Procedure set3(value : Word);        { this will be 1 bit }
    Function  get3 : Word;
  end;

Function bitf.get : Word;
begin
  get := bits;
end;

Procedure bitf.set1(value : Word);
{ Set the value of the first bitfield }
Const
  valmask  : Word = $C000;  { 11000000 00000000 }
  bitsmask : Word = $3FFF;  { 00111111 11111111 }
begin
  value := value shl 14 and valmask;
  bits  := value + (bits and bitsmask);
end;

Function bitf.get1 : Word;
{ Get the value of the first bitfield }
begin
  get1 := bits shr 14;
end;

Procedure bitf.set2(value : Word);
{ Set the value of the second bitfield }
Const
  valmask  : Word = $3FFE;  { 00111111 11111110 }
  bitsmask : Word = $C001;  { 11000000 00000001 }
begin
  value := (value shl 1) and valmask;
  bits  := value + (bits and bitsmask);
end;

Function bitf.get2 : Word;
{ Get the value of the second bitfield }
Const
  valmask : Word = $3FFE;   { 00111111 11111110 }
begin
  get2 := (bits and valmask) shr 1;
end;

Procedure bitf.set3(value : Word);
{ Set the value of the third bitfield }
Const
  valmask  : Word = $0001;  { 00000000 00000001 }
  bitsmask : Word = $FFFE;  { 11111111 11111110 }
begin
  value := value and valmask;
  bits  := value + (bits and bitsmask);
end;

Function bitf.get3 : Word;
{ Get the value of the third bitfield }
Const
  valmask : Word = $0001;  { 00000000 00000001 }
begin
  get3 := bits and valmask;
end;

Var
  x : bitf;

begin
  x.set1(3);        { set all to maximum values }
  x.set2(8191);
  x.set3(1);
  Writeln(x.get1, ', ', x.get2, ', ', x.get3, ', ', x.get);
end.

