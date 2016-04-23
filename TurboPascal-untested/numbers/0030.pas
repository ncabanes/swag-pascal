{===========================================================================
Date: 10-09-93 (23:23)
From: J.P. Ritchey
Subj: MSBIN to IEEE
---------------------------------------------------------------------------
GE>         Does anyone have any code for Converting MSBIN format
GE>         numbers into IEEE?  }

{$A-,B-,D-,E+,F-,I-,L-,N+,O-,R-,S-,V-}
unit BFLOAT;
(*
            MicroSoft Binary Float to IEEE format Conversion
                    Copyright (c) 1989 J.P. Ritchey
                            Version 1.0

         This software is released to the public domain.  Though
         tested, there could be some errors.  Any reports of bugs
         discovered would be appreciated. Send reports to
                 Pat Ritchey     Compuserve ID 72537,2420
*)
interface

type
  bfloat4 = record
    { M'Soft single precision }
    mantissa : array[5..7] of byte;
    exponent : byte;
    end;

  Bfloat8 = record
    { M'Soft double precision }
    mantissa : array[1..7] of byte;
    exponent : byte;
    end;


Function Bfloat4toExtended(d : bfloat4) : extended;
Function Bfloat8toExtended(d : Bfloat8): extended;

{ These routines will convert a MicroSoft Binary Floating point
  number to IEEE extended format.  The extended is large enough
  to store any M'Soft single or double number, so no over/underflow
  problems are encountered.  The Mantissa of an extended is large enough
  to hold a BFloatx mantissa, so no truncation is required.

  The result can be returned to TP single and double variables and
  TP will handle the conversion.  Note that Over/Underflow can occur
  with these types. }

Function HexExt(ep:extended) : string;

{ A routine to return the hex representation of an IEEE extended variable
  Left in from debugging, you may find it useful }

Function ExtendedtoBfloat4(ep : extended; var b : bfloat4) : boolean;
Function ExtendedtoBfloat8(ep : extended; var b : Bfloat8) : boolean;

{ These routines are the reverse of the above, that is they convert
  TP extended => M'Soft format.  You can use TP singles and doubles
  as the first parameter and TP will do the conversion to extended
  for you.

  The Function result returns True if the conversion was succesful,
  and False if not (because of overflow).

  Since an extended can have an exponent that will not fit
  in the M'Soft format Over/Underflow is handled in the following
  manner:
    Overflow:  Set the Bfloatx to 0 and return a False result.
    Underflow: Set the BFloatx to 0 and return a True Result.

  No rounding is done on the mantissa.  It is simply truncated to
  fit. }


Function BFloat4toReal(b:bfloat4) : Real;
Function BFloat8toReal(b:bfloat8) : Real;

{ These routines will convert a MicroSoft Binary Floating point
  number to Turbo real format.  The real is large enough
  to store any M'Soft single or double Exponent, so no over/underflow
  problems are encountered.  The Mantissa of an real is large enough
  to hold a BFloat4 mantissa, so no truncation is required.  The
  BFloat8 mantissa is truncated (from 7 bytes to 5 bytes) }

Function RealtoBFloat4(rp: real; var b:bfloat4) : Boolean;
Function RealtoBFloat8(rp : real; var b:bfloat8) : Boolean;

{ These routines do the reverse of the above.  No Over/Underflow can
  occur, but truncation of the mantissa can occur
  when converting Real to Bfloat4 (5 bytes to 3 bytes).

  The function always returns True, and is structured this way to
  function similar to the IEEE formats }

implementation
type
  IEEEExtended = record
     Case integer of
     0 : (Mantissa : array[0..7] of byte;
          Exponent : word);
     1 : (e : extended);
     end;

  TurboReal = record
     Case integer of
     0 : (Exponent : byte;
          Mantissa : array[3..7] of byte);
     1 : (r : real);
     end;

Function HexExt(ep:extended) : string;
var
 e : IEEEExtended absolute ep;
 i : integer;
 s : string;
 Function Hex(b:byte) : string;
  const hc : array[0..15] of char = '0123456789ABCDEF';
  begin
  Hex := hc[b shr 4]+hc[b and 15];
  end;
begin
  s := hex(hi(e.exponent))+hex(lo(e.exponent))+' ';
  for i := 7 downto 0 do s := s+hex(e.mantissa[i]);
HexExt := s;
end;

Function NullMantissa(e : IEEEextended) : boolean;
var
 i : integer;
begin
NullMantissa := False;
for i := 0 to 7 do if e.mantissa[i] <> 0 then exit;
NullMantissa := true;
end;

Procedure ShiftLeftMantissa(var e);
{ A routine to shift the 8 byte mantissa left one bit }
inline(
{0101} $F8/          {   CLC                        }
{0102} $5F/          {   POP    DI                  }
{0103} $07/          {   POP    ES                  }
{0104} $B9/$04/$00/  {   MOV    CX,0004             }
{0107} $26/$D1/$15/  {   RCL    Word Ptr ES:[DI],1  }
{010A} $47/          {   INC    DI                  }
{010B} $47/          {   INC    DI                  }
{010C} $E2/$F9       {   LOOP   0107                }
);

Procedure Normalize(var e : IEEEextended);
{ Normalize takes an extended and insures that the "i" bit is
  set to 1 since M'Soft assumes a 1 is there. An extended has
  a value of 0.0 if the mantissa is zero, so the first check.
  The exponent also has to be kept from wrapping from 0 to $FFFF
  so the "if e.exponent = 0" check.  If it gets this small
  for the routines that call it, there would be underflow and 0
  would be returned.
}
var
 exp : word;

begin
exp := e.exponent and $7FFF; { mask out sign }
if NullMantissa(e) then
   begin
   E.exponent := 0;
   exit
   end;
while e.mantissa[7] < 128 do
   begin
   ShiftLeftMantissa(e);
   dec(exp);
   if exp = 0 then exit;
   end;
e.exponent := (e.exponent and $8000) or exp;  { restore sign }
end;

Function Bfloat8toExtended(d : Bfloat8) : extended;
var
  i : integer;
  e : IEEEExtended;
begin
  fillchar(e,sizeof(e),0);
  Bfloat8toExtended := 0.0;
  if d.exponent = 0 then exit;
  { if the bfloat exponent is 0 the mantissa is ignored and
    the value reurned is 0.0 }
  e.exponent := d.exponent - 129 + 16383;
  { bfloat is biased by 129, extended by 16383
    This creates the correct exponent }
  if d.mantissa[7] > 127 then
     { if the sign bit in bfloat is 1 then set the sign bit in the extended }
     e.exponent := e.exponent or $8000;
  move(d.Mantissa[1],e.mantissa[1],6);
  e.mantissa[7] := $80 or (d.mantissa[7] and $7F);
  { bfloat assumes 1.fffffff, so supply it for extended }
  Bfloat8toExtended := e.e;
end;

Function Bfloat4toExtended(d : bfloat4) : extended;
var
  i : integer;
  e : IEEEExtended;
begin
  fillchar(e,sizeof(e),0);
  Bfloat4toExtended := 0.0;
  if d.exponent = 0 then exit;
  e.exponent := integer(d.exponent - 129) + 16383;
  if d.mantissa[7] > 127 then
     e.exponent := e.exponent or $8000;
  move(d.Mantissa[5],e.mantissa[5],2);
  e.mantissa[7] := $80 or (d.mantissa[7] and $7F);
  Bfloat4toExtended := e.e;
end;

Function ExtendedtoBfloat8(ep : extended; var b : Bfloat8) : boolean;
var
  e : IEEEextended absolute ep;
  exp : integer;
  sign : byte;
begin
FillChar(b,Sizeof(b),0);
ExtendedtoBfloat8 := true; { assume success }
Normalize(e);
if e.exponent = 0 then exit;
sign := byte(e.exponent > 32767) shl 7;
exp := (e.exponent and $7FFF) - 16383 + 129;
if exp < 0 then exp := 0; { underflow }
if exp > 255 then { overflow }
   begin
   ExtendedtoBfloat8 := false;
   exit;
   end;
b.exponent := exp;
move(e.mantissa[1],b.mantissa[1],7);
b.mantissa[7] := (b.mantissa[7] and $7F) or sign;
end;

Function ExtendedtoBfloat4(ep : extended; var b : Bfloat4) : boolean;
var
  e : IEEEextended absolute ep;
  exp : integer;
  sign : byte;
begin
FillChar(b,Sizeof(b),0);
ExtendedtoBfloat4 := true; { assume success }
Normalize(e);
if e.exponent = 0 then exit;
sign := byte(e.exponent > 32767) shl 7;
exp := (e.exponent and $7FFF) - 16383 + 129;
if exp < 0 then exp := 0; { underflow }
if exp > 255 then { overflow }
   begin
   ExtendedtoBfloat4 := false;
   exit;
   end;
b.exponent := exp;
move(e.mantissa[5],b.mantissa[5],3);
b.mantissa[7] := (b.mantissa[7] and $7F) or sign;
end;

Function BFloat4toReal(b:bfloat4) : Real;
var
 r : TurboReal;
begin
  fillchar(r,sizeof(r),0);
  r.exponent := b.exponent;
  move(b.mantissa[5],r.mantissa[5],3);
  Bfloat4toReal := r.r;
end;

Function BFloat8toReal(b:bfloat8) : Real;
var
 r : TurboReal;
begin
  fillchar(r,sizeof(r),0);
  r.exponent := b.exponent;
  move(b.mantissa[3],r.mantissa[3],5);
  Bfloat8toReal := r.r;
end;

Function RealtoBFloat4(rp: real; var b:bfloat4) : Boolean;
var
 r : TurboReal absolute rp;
begin
  fillchar(b,sizeof(b),0);
  b.exponent := r.exponent;
  move(r.mantissa[5],b.mantissa[5],3);
  RealtoBfloat4 := true;
end;

Function RealtoBFloat8(rp : real; var b:bfloat8) : Boolean;
var
 r : TurboReal absolute rp;
begin
  fillchar(b,sizeof(b),0);
  b.exponent := r.exponent;
  move(r.mantissa[3],b.mantissa[3],5);
  RealtoBfloat8 := true;
end;

end.
