==============================================================================
 BBS: «« The Information and Technology Exchan
  To: JEFFREY HUNTSMAN             Date: 11-27─91 (09:08)
From: FLOOR NAAIJKENS            Number: 3162   [101] PASCAL
Subj: CALC (1)                   Status: Public
------------------------------------------------------------------------------
{$O+}
{
                       F i l e    I n f o r m a t i o n

* DESCRIPTION
Supplies missing trigonometric functions for Turbo Pascal 5.5. Also
provides hyperbolic, logarithmic, power, and root functions. All trig
functions accessibile by radians, decimal degrees, degrees-minutes-seconds
and a global DegreeType.

}
unit PTD_Calc;

(*  PTD_Calc  -  Supplies missing trigonometric functions for Turbo Pascal 5.5
 *           Also provides hyperbolic, logarithmic, power, and root functions.
 *           All trig functions accessible by radians, decimal degrees,
 *           degrees-minutes-seconds, and a global DegreeType.  Conversions
 *           between these are supplied.
 *
 *)

interface

type
  DegreeType =  record
                  Degrees, Minutes, Seconds : real;
                end;
const
  Infinity = 9.9999999999E+37;

{  Radians  }
{ sin, cos, and arctan are predefined }

function Tan( Radians : real ) : real;
function ArcSin( InValue : real ) : real;
function ArcCos( InValue : real ) : real;

{  Degrees, expressed as a real number  }

function DegreesToRadians( Degrees : real ) : real;
function RadiansToDegrees( Radians : real ) : real;
function Sin_Degree( Degrees : real ) : real;
function Cos_Degree( Degrees : real ) : real;
function Tan_Degree( Degrees : real ) : real;
function ArcSin_Degree( Degrees : real ) : real;
function ArcCos_Degree( Degrees : real ) : real;
function ArcTan_Degree( Degrees : real ) : real;

{  Degrees, in Degrees, Minutes, and Seconds, as real numbers  }

function DegreePartsToDegrees( Degrees, Minutes, Seconds : real ) : real;
function DegreePartsToRadians( Degrees, Minutes, Seconds : real ) : real;
procedure DegreesToDegreeParts( DegreesIn : real;
                                var Degrees, Minutes, Seconds : real );
procedure RadiansToDegreeParts( Radians : real;
                                var Degrees, Minutes, Seconds : real );
function Sin_DegreeParts( Degrees, Minutes, Seconds : real ) : real;
function Cos_DegreeParts( Degrees, Minutes, Seconds : real ) : real;
function Tan_DegreeParts( Degrees, Minutes, Seconds : real ) : real;
function ArcSin_DegreeParts( Degrees, Minutes, Seconds : real ) : real;
function ArcCos_DegreeParts( Degrees, Minutes, Seconds : real ) : real;
function ArcTan_DegreeParts( Degrees, Minutes, Seconds : real ) : real;

{  Degrees, expressed as DegreeType ( reals in record ) }

function DegreeTypeToDegrees( DegreeVar : DegreeType ) : real;
function DegreeTypeToRadians( DegreeVar : DegreeType ) : real;
procedure DegreeTypeToDegreeParts( DegreeVar : DegreeType;
                                   var Degrees, Minutes, Seconds : real );
procedure DegreesToDegreeType( Degrees : real; var DegreeVar : DegreeType );
procedure RadiansToDegreeType( Radians : real; var DegreeVar : DegreeType );
procedure DegreePartsToDegreeType( Degrees, Minutes, Seconds : real;
                                   var DegreeVar : DegreeType );
function Sin_DegreeType( DegreeVar : DegreeType ) : real;
function Cos_DegreeType( DegreeVar : DegreeType ) : real;
function Tan_DegreeType( DegreeVar : DegreeType ) : real;
function ArcSin_DegreeType( DegreeVar : DegreeType ) : real;
function ArcCos_DegreeType( DegreeVar : DegreeType ) : real;
function ArcTan_DegreeType( DegreeVar : DegreeType ) : real;

{  Hyperbolic functions  }

function Sinh( Invalue : real ) : real;
function Cosh( Invalue : real ) : real;
function Tanh( Invalue : real ) : real;
function Coth( Invalue : real ) : real;
function Sech( Invalue : real ) : real;
function Csch( Invalue : real ) : real;
function ArcSinh( Invalue : real ) : real;
function ArcCosh( Invalue : real ) : real;
function ArcTanh( Invalue : real ) : real;
function ArcCoth( Invalue : real ) : real;
function ArcSech( Invalue : real ) : real;
function ArcCsch( Invalue : real ) : real;

{  Logarithms, Powers, and Roots  }

{ e to the x  is  exp() }
{ natural log is  ln()  }
function Log10( InNumber : real ) : real;
function Log( Base, InNumber : real ) : real;  { log of any base }
function Power( InNumber, Exponent : real ) : real;
function Root( InNumber, TheRoot : real ) : real;


{----------------------------------------------------------------------}
implementation

const
  RadiansPerDegree =  0.017453292520;
  DegreesPerRadian = 57.295779513;
  MinutesPerDegree =   60.0;
  SecondsPerDegree = 3600.0;
  SecondsPerMinute = 60.0;
  LnOf10 = 2.3025850930;

{-----------}
{  Radians  }
{-----------}

{ sin, cos, and arctan are predefined }

function Tan { ( Radians : real ) : real };
  { note: returns Infinity where appropriate }
  var
    CosineVal : real;
    TangentVal : real;
  begin
  CosineVal := cos( Radians );
  if CosineVal = 0.0 then
    Tan := Infinity
  else
    begin
    TangentVal := sin( Radians ) / CosineVal;
    if ( TangentVal < -Infinity ) or ( TangentVal > Infinity ) then
      Tan := Infinity
    else
      Tan := TangentVal;
    end;
  end;

function ArcSin{ ( InValue : real ) : real };
  { notes: 1) exceeding input range of -1 through +1 will cause runtime error }
  {        2) only returns principal values }
  {             ( -pi/2 through pi/2 radians ) ( -90 through +90 degrees ) }
  begin
  if abs( InValue ) = 1.0 then
    ArcSin := pi / 2.0
  else
    ArcSin := arctan( InValue / sqrt( 1 - InValue * InValue ) );
  end;

function ArcCos{ ( InValue : real ) : real };
  { notes: 1) exceeding input range of -1 through +1 will cause runtime error }
  {        2) only returns principal values }
  {             ( 0 through pi radians ) ( 0 through +180 degrees ) }
  var
    Result : real;
  begin
  if InValue = 0.0 then
    ArcCos := pi / 2.0
  else
    begin
    Result := arctan( sqrt( 1 - InValue * InValue ) / InValue );
    if InValue < 0.0 then
      ArcCos := Result + pi
    else
      ArcCos := Result;
    end;
  end;

{---------------------------------------}
{  Degrees, expressed as a real number  }
{---------------------------------------}

function DegreesToRadians{ ( Degrees : real ) : real };
  begin
  DegreesToRadians := Degrees * RadiansPerDegree;
  end;

function RadiansToDegrees{ ( Radians : real ) : real };
  begin
  RadiansToDegrees := Radians * DegreesPerRadian;
  end;

function Sin_Degree{ ( Degrees : real ) : real };
  begin
  Sin_Degree := sin( DegreesToRadians( Degrees ) );
  end;

function Cos_Degree{ ( Degrees : real ) : real };
  begin
  Cos_Degree := cos( DegreesToRadians( Degrees ) );
  end;

function Tan_Degree{ ( Degrees : real ) : real };
  begin
  Tan_Degree := Tan( DegreesToRadians( Degrees ) );

<ORIGINAL MESSAGE OVER 200 LINES, SPLIT IN 2 OR MORE>
==============================================================================
 BBS: «« The Information and Technology Exchan
  To: JEFFREY HUNTSMAN             Date: 11-27─91 (09:08)
From: FLOOR NAAIJKENS            Number: 3163   [101] PASCAL
Subj: CALC (1)           <CONT>  Status: Public
------------------------------------------------------------------------------
  end;

function ArcSin_Degree{ ( Degrees : real ) : real };
  begin
  ArcSin_Degree := ArcSin( DegreesToRadians( Degrees ) );
  end;

function ArcCos_Degree{ ( Degrees : real ) : real };
  begin
  ArcCos_Degree := ArcCos( DegreesToRadians( Degrees ) );
  end;

function ArcTan_Degree{ ( Degrees : real ) : real };
  begin
  ArcTan_Degree := arctan( DegreesToRadians( Degrees ) );
  end;

--- D'Bridge 1.30 demo/922115
 * Origin: EURO-ONLINE Home of The Fast Commander (2:500/233)
==============================================================================
 BBS: «« The Information and Technology Exchan
  To: JEFFREY HUNTSMAN             Date: 11-27─91 (09:08)
From: FLOOR NAAIJKENS            Number: 3164   [101] PASCAL
Subj: CALC (2)                   Status: Public
------------------------------------------------------------------------------

{--------------------------------------------------------------}
{  Degrees, in Degrees, Minutes, and Seconds, as real numbers  }
{--------------------------------------------------------------}

function DegreePartsToDegrees{ ( Degrees, Minutes, Seconds : real ) : real };
  begin
  DegreePartsToDegrees := Degrees + ( Minutes / MinutesPerDegree ) +
                                       ( Seconds / SecondsPerDegree );
  end;

function DegreePartsToRadians{ ( Degrees, Minutes, Seconds : real ) : real };
  begin
  DegreePartsToRadians := DegreesToRadians( DegreePartsToDegrees( Degrees,
                                                        Minutes, Seconds ) );
  end;

procedure DegreesToDegreeParts{ ( DegreesIn : real;
                                  var Degrees, Minutes, Seconds : real ) };
  begin
  Degrees := int( DegreesIn );
  Minutes := ( DegreesIn - Degrees ) * MinutesPerDegree;
  Seconds := frac( Minutes );
  Minutes := int( Minutes );
  Seconds := Seconds * SecondsPerMinute;
  end;

procedure RadiansToDegreeParts{ ( Radians : real;
                                  var Degrees, Minutes, Seconds : real ) };
  begin
  DegreesToDegreeParts( RadiansToDegrees( Radians ),
                          Degrees, Minutes, Seconds );
  end;

function Sin_DegreeParts{ ( Degrees, Minutes, Seconds : real ) : real };
  begin
  Sin_DegreeParts := sin( DegreePartsToRadians( Degrees, Minutes, Seconds ) );
  end;

function Cos_DegreeParts{ ( Degrees, Minutes, Seconds : real ) : real };
  begin
  Cos_DegreeParts := cos( DegreePartsToRadians( Degrees, Minutes, Seconds ) );
  end;

function Tan_DegreeParts{ ( Degrees, Minutes, Seconds : real ) : real };
  begin
  Tan_DegreeParts := Tan( DegreePartsToRadians( Degrees, Minutes, Seconds ) );
  end;

function ArcSin_DegreeParts{ ( Degrees, Minutes, Seconds : real ) : real };
  begin
  ArcSin_DegreeParts := ArcSin( DegreePartsToRadians( Degrees,
                                                      Minutes, Seconds ) );
  end;

function ArcCos_DegreeParts{ ( Degrees, Minutes, Seconds : real ) : real };
  begin
  ArcCos_DegreeParts := ArcCos( DegreePartsToRadians( Degrees,
                                                      Minutes, Seconds ) );
  end;

function ArcTan_DegreeParts{ ( Degrees, Minutes, Seconds : real ) : real };
  begin
  ArcTan_DegreeParts := arctan( DegreePartsToRadians( Degrees,
                                                      Minutes, Seconds ) );
  end;

{-------------------------------------------------------}
{  Degrees, expressed as DegreeType ( reals in record ) }
{-------------------------------------------------------}

function DegreeTypeToDegrees{ ( DegreeVar : DegreeType ) : real };
  begin
  DegreeTypeToDegrees := DegreePartsToDegrees( DegreeVar.Degrees,
                                       DegreeVar.Minutes, DegreeVar.Seconds );
  end;

function DegreeTypeToRadians{ ( DegreeVar : DegreeType ) : real };
  begin
  DegreeTypeToRadians := DegreesToRadians( DegreeTypeToDegrees( DegreeVar ) );
  end;

procedure DegreeTypeToDegreeParts{ ( DegreeVar : DegreeType;
                                     var Degrees, Minutes, Seconds : real ) };
  begin
  Degrees := DegreeVar.Degrees;
  Minutes := DegreeVar.Minutes;
  Seconds := DegreeVar.Seconds;
  end;

procedure DegreesToDegreeType{ ( Degrees : real; var DegreeVar : DegreeType )};
  begin
  DegreesToDegreeParts( Degrees, DegreeVar.Degrees,
                        DegreeVar.Minutes, DegreeVar.Seconds );
  end;

procedure RadiansToDegreeType{ ( Radians : real; var DegreeVar : DegreeType )};
  begin
  DegreesToDegreeParts( RadiansToDegrees( Radians ), DegreeVar.Degrees,
                        DegreeVar.Minutes, DegreeVar.Seconds );
  end;

procedure DegreePartsToDegreeType{ ( Degrees, Minutes, Seconds : real;
                                     var DegreeVar : DegreeType ) };
  begin
  DegreeVar.Degrees := Degrees;
  DegreeVar.Minutes := Minutes;
  DegreeVar.Seconds := Seconds;
  end;

function Sin_DegreeType{ ( DegreeVar : DegreeType ) : real };
  begin
  Sin_DegreeType := sin( DegreeTypeToRadians( DegreeVar ) );
  end;

function Cos_DegreeType{ ( DegreeVar : DegreeType ) : real };
  begin
  Cos_DegreeType := cos( DegreeTypeToRadians( DegreeVar ) );
  end;

function Tan_DegreeType{ ( DegreeVar : DegreeType ) : real };
  begin
  Tan_DegreeType := Tan( DegreeTypeToRadians( DegreeVar ) );
  end;

--- D'Bridge 1.30 demo/922115
 * Origin: EURO-ONLINE Home of The Fast Commander (2:500/233)
==============================================================================
 BBS: «« The Information and Technology Exchan
  To: JEFFREY HUNTSMAN             Date: 11-27─91 (09:08)
From: FLOOR NAAIJKENS            Number: 3165   [101] PASCAL
Subj: CALC (3)                   Status: Public
------------------------------------------------------------------------------
function ArcSin_DegreeType{ ( DegreeVar : DegreeType ) : real };
  begin
  ArcSin_DegreeType := ArcSin( DegreeTypeToRadians( DegreeVar ) );
  end;

function ArcCos_DegreeType{ ( DegreeVar : DegreeType ) : real };
  begin
  ArcCos_DegreeType := ArcCos( DegreeTypeToRadians( DegreeVar ) );
  end;

function ArcTan_DegreeType{ ( DegreeVar : DegreeType ) : real };
  begin
  ArcTan_DegreeType := arctan( DegreeTypeToRadians( DegreeVar ) );
  end;

{------------------------}
{  Hyperbolic functions  }
{------------------------}

function Sinh{ ( Invalue : real ) : real };
  const
    MaxValue = 88.029691931;  { exceeds standard turbo precision }
  var
    Sign : real;
  begin
  Sign := 1.0;
  if Invalue < 0 then
    begin
    Sign := -1.0;
    Invalue := -Invalue;
    end;
  if Invalue > MaxValue then
    Sinh := Infinity
  else
    Sinh := ( exp( Invalue ) - exp( -Invalue ) ) / 2.0 * Sign;
  end;

function Cosh{ ( Invalue : real ) : real };
  const
    MaxValue = 88.029691931;  { exceeds standard turbo precision }
  begin
  Invalue := abs( Invalue );
  if Invalue > MaxValue then
    Cosh := Infinity
  else
    Cosh := ( exp( Invalue ) + exp( -Invalue ) ) / 2.0;
  end;

function Tanh{ ( Invalue : real ) : real };
  begin
  Tanh := Sinh( Invalue ) / Cosh( Invalue );
  end;

function Coth{ ( Invalue : real ) : real };
  begin
  Coth := Cosh( Invalue ) / Sinh( Invalue );
  end;

function Sech{ ( Invalue : real ) : real };
  begin
  Sech := 1.0 / Cosh( Invalue );
  end;

function Csch{ ( Invalue : real ) : real };
  begin
  Csch := 1.0 / Sinh( Invalue );
  end;

function ArcSinh{ ( Invalue : real ) : real };
  var
    Sign : real;
  begin
  Sign := 1.0;
  if Invalue < 0 then
    begin
    Sign := -1.0;
    Invalue := -Invalue;
    end;
  ArcSinh := ln( Invalue + sqrt( Invalue*Invalue + 1 ) ) * Sign;
  end;

function ArcCosh{ ( Invalue : real ) : real };
  var
    Sign : real;
  begin
  Sign := 1.0;
  if Invalue < 0 then
    begin
    Sign := -1.0;
    Invalue := -Invalue;
    end;
  ArcCosh := ln( Invalue + sqrt( Invalue*Invalue - 1 ) ) * Sign;
  end;

function ArcTanh{ ( Invalue : real ) : real };
  var
    Sign : real;
  begin
  Sign := 1.0;
  if Invalue < 0 then
    begin
    Sign := -1.0;
    Invalue := -Invalue;
    end;
  ArcTanh := ln( ( 1 + Invalue ) / ( 1 - Invalue ) ) / 2.0 * Sign;
  end;

function ArcCoth{ ( Invalue : real ) : real };
  begin
  ArcCoth := ArcTanh( 1.0 / Invalue );
  end;

function ArcSech{ ( Invalue : real ) : real };
  begin
  ArcSech := ArcCosh( 1.0 / Invalue );
  end;

function ArcCsch{ ( Invalue : real ) : real };
  begin
  ArcCsch := ArcSinh( 1.0 / Invalue );
  end;

{---------------------------------}
{  Logarithms, Powers, and Roots  }
{---------------------------------}

{ e to the x  is  exp() }
{ natural log is  ln()  }

function Log10{ ( InNumber : real ) : real };
  begin
  Log10 := ln( InNumber ) / LnOf10;
  end;

function Log{ ( Base, InNumber : real ) : real };  { log of any base }
  begin
  Log := ln( InNumber ) / ln( Base );
  end;

function Power{ ( InNumber, Exponent : real ) : real };
  begin
  if InNumber > 0.0 then
    Power := exp( Exponent * ln( InNumber ) )
  else if InNumber = 0.0 then
    Power := 1.0
  else { WE DON'T force a runtime error, we define a function to provide
         negative logarithms! }
    If Exponent=Trunc(Exponent) Then
      Power := (-2*(Trunc(Exponent) Mod 2)+1) * Exp(Exponent * Ln( -InNumber ) )
      Else Power := Trunc(1/(Exponent-Exponent));
              { NOW WE generate a runtime error }
  end;

function Root{ ( InNumber, TheRoot : real ) : real };
  begin
  Root := Power( InNumber, ( 1.0 / TheRoot ) );
  end;

end. { unit PTD_Calc }





P.S. Enjoy yourself!

--- D'Bridge 1.30 demo/922115
 * Origin: EURO-ONLINE Home of The Fast Commander (2:500/233)
