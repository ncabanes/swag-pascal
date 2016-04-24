(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0071.PAS
  Description: Extended to Real Converter
  Author: ERWINK@XS1.XS4ALL.NL
  Date: 05-26-95  23:26
*)

{
:>I am looking for a routine that can convert the Extended
:>type to and from a real type without the need to use
:>$N+,$E+ in TP. I have got to read a file containing

:In the back of the TP 6.0 and BP 7.0 manuals, it lists the data format for
:the Extended and Real data types. Conversion should be relatively easy from
:Real to Extended, just a few shifts, as the extended mantissa /exponent
:parts are both larger than the corresponding ones for the Real data type.
:For the same reason, conversion to extended from real will be tricky, as the
:value may not be within the range of a real.

: If I remember correctly, the extended type has a 63-bit mantissa, 1 sign
: bit, and a 16-bit exponent. The real type has an 8-bit exponent, 1 sign bit,
: and a 39-bit mantissa.

From: erwink@xs1.xs4all.nl (erwink)

Seems to work. Here is the result of this hard work:
}

unit convert;
{ converts extended type to real without coprocessor support
  or emulation (so can be compiled with $N-,$E-).
  Extended is represented by an array of 10 bytes.
}


Interface

   type
      b10 = array[1..10] of byte;

   function Extended2Real(x:b10; var r:real) : boolean;
     { converts 10 byte array containing an extended to a real }
     { returns TRUE if ok, FALSE if overflow }
   procedure Real2Extended(r:real; var x:b10);
     { converts real to 10 byte array containing an extended }


implementation

const
 signmask : byte = $80;
 not_signmask : byte = $7F;

type
  b2 = array[1..2] of byte;
  ff = record
          case integer of
             1 : (r : real);
             2 : (a : array[1..6] of byte);
          end;


function Extended2Real(x : b10; var r : real) : boolean;

var
  exp2 : b2;
  exponent : integer;
  sign : boolean;
  i : boolean;
  m : ff;

begin
   { extract sign bit and clear it }
   sign := (x[10] and signmask) <> 0;
   x[10] := x[10] and not_signmask;

   { extract exponent }
   exp2[1] := x[9];
   exp2[2] := x[10];
   exponent := integer(exp2)-16383;

   { extract this funny number i and clear it }
   i := (x[8] and signmask) <> 0;
   x[8] := x[8] and not_signmask;

   { if i is not set then we had a denormalized number so
     return 0 }
   if not i then begin
      r := 0.0;
      Extended2Real := true;
      exit;
   end;

   { extract mantissa }
   m.a[6] := x[8];
   m.a[5] := x[7];
   m.a[4] := x[6];
   m.a[3] := x[5];
   m.a[2] := x[4];

   { plug in exponent }
   exponent := exponent +129;
   if (exponent > 255) then begin
     Extended2Real := false;
     exit;
   end;
   if (exponent < 0) then begin
       { underflow }
       r := 0.0;
       Extended2Real := True;
       exit;
   end;
   m.a[1] := exponent;

   { set sign bit }
   if sign then
      m.r := -m.r;

   r := m.r;
   Extended2Real := true;
end;

procedure real2extended(r : real; var x : b10);

var
   sign : boolean;
   rr : ff absolute r;
   exp2 : b2;
   exponent : integer;
   i : integer;

begin
   { treat 0 specially }
   if (r=0.0) then begin
       for i := 1 to 10 do
          x[i] := 0;
       exit;
   end;

   { extract sign bit and set it }
   sign := (rr.a[6] and signmask) <> 0;
   rr.a[6] := rr.a[6] or signmask;

   { copy mantissa }
   x[8] := rr.a[6];
   x[7] := rr.a[5];
   x[6] := rr.a[4];
   x[5] := rr.a[3];
   x[4] := rr.a[2];
   x[3] := 0;
   x[2] := 0;
   x[1] := 0;

   { copy exponent }
   exp2[2] := 0;
   exp2[1] := rr.a[1];
   exponent := integer(exp2)+16254;
   exp2 := b2(exponent);

   { plug in sign bit }
   exp2[2] := exp2[2] and not_signmask;
   if sign then
      exp2[2] := exp2[2] or signmask;

   x[10] := exp2[2];
   x[9] := exp2[1];
end;


end.

