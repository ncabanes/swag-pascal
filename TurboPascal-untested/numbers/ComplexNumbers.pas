(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0039.PAS
  Description: Complex Numbers
  Author: DJ MURDOCH
  Date: 01-27-94  11:56
*)

{
>A>overlooked. No Pascal compiler that I know of (including Turbo) can return
>A>a complex value (i.e., a record or an array) from a FUNCTION. In order for
>
>Hmm...never tried this before. Anyway, the sollution is quite simple:
>just have the megaword-variable public, and pass it to the procedure.

Returning function values by setting a public variable is pretty dangerous -
what if your function calls another that uses the same public to return its
value?  In this case, it's not necessary, since there's a trick to let TP
return complex numbers:
}

type
  Float = Double;
  TComplex = string[2*sizeof(float)];
  { Complex number.  Not a true string:  the values are stored in binary
    format within it. }

  TCmplx = record   { The internal storage format for TComplex }
    len : byte;
    r,i : float;
  end;

function Re(z:TComplex):float;
begin
  Re := TCmplx(z).r;
end;

function Im(z:TComplex):float;
begin
  Im := TCmplx(z).i;
end;

function Complex(x,y:float):TComplex;
{ Convert x + iy to complex number. }
var
  result : TCmplx;
begin
  with result do
  begin
    len := 2*sizeof(float);
    r := x;
    i := y;
  end;
  Complex := TComplex(result);
end;

{You can use these to build up lots of functions returning TComplex types.}

