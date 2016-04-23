
UNIT business;
  {$N+}

 (*  DESCRIPTION :
   I.  Financial functions from spreadsheet - Fonctions financières.
       Name of functions , number and order of arguments are based upon
       Lotus 1-2-3 and Quattro , which are different from Excel.
  II.  Conversion : anglo-saxon measure unit <---->  metric measure unit
       Conversion entre mesures anglo-saxonnes et métriques.
 III.  Percentage calculation - Calcul de pourcentage .

     RELEASE     :  2.0
     DATE        :  27/02/94
     AUTHOR      :  Fernand LEMOINE
                    rue du Collège 34
                    B-6200 CHATELET
                    BELGIQUE
     All code granted to the public domain
     Questions and comments are welcome
     REQUIREMENT :  Turbo Pascal 5.0 or later
     Compatible with Borland Pascal protected mode
     Compatible with Borland Pascal for Windows (Wincrt)
  *)

INTERFACE
CONST
  Max_Pmt = 12;
TYPE
  Currency = Comp;
  SeriesPmt = ARRAY[1..Max_Pmt] OF Currency;

VAR
  scale_currency : Real;

(* Interfaced only for use by other units
   Conversion  real ---> currency        *)
FUNCTION ToCurrency(value : Real) : Currency;

  (* Set number of decimal  for currency type  *)
PROCEDURE Set_Dec_Prec(value : Byte);

PROCEDURE WriteCurrency(width : Byte; value : Currency);
(*  width = total length ;
   number of decimals fixed by Set_Dec_Prec *)

(*-I-------------------- Financial functions -----------------------------
   Interest Rate is expressed as a decimal number, not as a percent.
   The Rate period must match the payment period.                     *)

  (* Straight line depreciation - Amortissement linéaire                *)
FUNCTION Sln(InitialValue, Residue : real; Time : Byte) : Currency;
  (* Sum of the year digits depreciation - Amortissement dégressif      *)
FUNCTION Syd(InitialValue, Residue : real; Period, Time : Byte) : Currency;
  (* Number of compounding periods - Durée de capitalisation            *)
FUNCTION Cterm(Rate : Real; FutureValue, PresentValue : real) : Real;
  (* Number of payments - Nombre de périodes                            *)
FUNCTION Term(Payment : real; Rate : Real; FutureValue : real) : Real;
  (* Payment - Remboursement                                            *)
FUNCTION Pmt(Principal : real; Rate : Real; Term : Byte) : Currency;
  (* Periodic interest Rate - Taux d'intérêt                            *)
FUNCTION Rate(FutureValue, PresentValue : real; Term : Byte) : Real;
  (* Present value - Valeur actualisée                                  *)
FUNCTION Pv(Payment : real; Rate : Real; Term : Byte) : Currency;
  (* Net present value  - Valeur actualisée d'une série                 *)
FUNCTION Npv(Rate : Real; Series : SeriesPmt) : Currency;
  (* Future value - Valeur à terme                                      *)
FUNCTION Fv(Payment : real; Rate : Real; Term : Byte) : Currency;

  (*  II - Conversion : anglo-saxon measure unit <--> metric measure unit ---*)

  (* ° Celsius to ° Fahrenheit  *)
FUNCTION CelsToFahr(value : Real) : Real;
  (* ° Fahrenheit to ° Celsius  *)
FUNCTION FahrToCels(value : Real) : Real;
  (*  US Gallons  to litres  *)
FUNCTION GalToL(value : Real) : Real;
  (*  Litres to US gallons   *)
FUNCTION LToGal(value : Real) : Real;
  (*  Inch  to cm            *)
FUNCTION InchToCm(value : Real) : Real;
  (*  Cm    to inch          *)
FUNCTION CmToInch(value : Real) : Real;
  (*  Pounds to kilograms       *)
FUNCTION LbToKg(value : Real) : Real;
  (*  Kilograms to pounds       *)
FUNCTION KgToLb(value : Real) : Real;

  (* III ------------------ Percentage  calculation -----------------------*)

  (* Compute value2 % from value1  *)
FUNCTION Percent(value1, value2 : Real) : Real;
  (* Per cent deviation between value1 and value2 . Result is lower than 1  *)
FUNCTION DeltaPercent(value1, value2 : Real) : Real;

IMPLEMENTATION

VAR
  decimal_currency : Word;

  FUNCTION Power(number, exponent : Real) : Real;
  BEGIN
    IF number > 0.0 THEN
      Power := Exp(exponent * ln(number))
    ELSE
      Power := 0.0
  END;

  PROCEDURE Set_Dec_Prec(value : Byte);
  BEGIN
    decimal_currency := value;
    scale_currency := Power(10, decimal_currency);
  END;

  FUNCTION ToCurrency(value : Real) : Currency;
  BEGIN
    ToCurrency := value * scale_currency;
  END;

  PROCEDURE WriteCurrency(width : Byte; value : Currency);
  BEGIN
    WriteLn(value / scale_currency:width:decimal_currency);
  END;
  (*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*)
  FUNCTION Sln(InitialValue, Residue : real; Time : Byte) : Currency;
  BEGIN
    Sln := (ToCurrency(InitialValue) - ToCurrency(Residue)) / Time;
  END;

  FUNCTION Syd(InitialValue, Residue : real; Period, Time : Byte) : Currency;
  BEGIN
    Syd := (ToCurrency(InitialValue) - ToCurrency(Residue)) *
    ((Period + 1 - Time) / (Period * (Period + 1) / 2));
  END;

  FUNCTION Cterm(Rate : Real; FutureValue, PresentValue : real) : Real;
  BEGIN
    Cterm := (ln(ToCurrency(FutureValue) / ToCurrency(PresentValue)) /
              ln(1 + Rate));
  END;

  FUNCTION Term(Payment : real; Rate : Real; FutureValue : real) : Real;
  BEGIN
    Term := (ln(1 + ToCurrency(FutureValue) * (Rate / ToCurrency(Payment))) /
             ln(1 + Rate));
  END;

  FUNCTION Pmt(Principal : real; Rate : Real; Term : Byte) : Currency;
  BEGIN
    Pmt := ToCurrency(Principal) * (Rate / (1 - Power(1 + Rate, - Term)));
  END;

  FUNCTION Rate(FutureValue, PresentValue : real; Term : Byte) : Real;
  BEGIN
    Rate := Power((FutureValue) / (PresentValue), 1 / Term) - 1;
  END;

  FUNCTION Pv(Payment : real; Rate : Real; Term : Byte) : Currency;
  BEGIN
    Pv := (ToCurrency(Payment) * (1 - Power(1 + Rate, - Term)) / Rate);
  END;

  FUNCTION Npv(Rate : Real; Series : SeriesPmt) : Currency;
  VAR
    i, number : Byte;
    N : Currency;
  BEGIN
    N := 0; i := 1; number := Max_Pmt;
    REPEAT
      IF Series[i] = 0 THEN number := i;
      Inc(i);
    UNTIL (i = Max_Pmt) OR (Series[i] = 0);

    FOR i := 1 TO number DO
      N := N + (ToCurrency(Series[i]) / Power(1 + Rate, i));
    Npv := N;
  END;

  FUNCTION Fv(Payment : real; Rate : Real; Term : Byte) : Currency;
  BEGIN
    Fv := ToCurrency(Payment) * (Power(1 + Rate, Term) - 1) / Rate;
  END;
  (*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*)
  FUNCTION CelsToFahr(value : Real) : Real;
  BEGIN
    CelsToFahr := 9 / 5 * value + 32;
  END;

  FUNCTION FahrToCels(value : Real) : Real;
  BEGIN
    FahrToCels := 5 / 9 * (value - 32);
  END;

  FUNCTION GalToL(value : Real) : Real;
  BEGIN
    GalToL := value * 3.785411784;
  END;

  FUNCTION LToGal(value : Real) : Real;
  BEGIN
    LToGal := value / 3.785411784;
  END;

  FUNCTION InchToCm(value : Real) : Real;
  BEGIN
    InchToCm := value * 2.54;
  END;

  FUNCTION CmToInch(value : Real) : Real;
  BEGIN
    CmToInch := value / 2.54;
  END;

  FUNCTION LbToKg(value : Real) : Real;
  BEGIN
    LbToKg := value * 0.45359237;
  END;

  FUNCTION KgToLb(value : Real) : Real;
  BEGIN
    KgToLb := value / 0.45359237;
  END;
  (*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*)
  FUNCTION Percent(value1, value2 : Real) : Real;
  BEGIN
    Percent := (value1 * value2) / 10000;
  END;

  FUNCTION DeltaPercent(value1, value2 : Real) : Real;
  BEGIN
    IF value2 = 0.0 THEN DeltaPercent := 0
    ELSE DeltaPercent := (value1 - value2) / value2;
  END;

BEGIN
  Set_Dec_Prec(2);

END.


{ ------------------------------   DEMO PROGRAM  ------------ }
program demobus;
{$N+}  (* Necessary *)
{$IFNDEF CPU87}
{$E+}  (* if no coprocessor is present, emulation is used  *)
{$ENDIF}

(* Demonstration program for use of business unit *)

uses business,crt;

const
 S : SeriesPmt = (1000,2000,5000,2000,0,0,0,0,0,0,0,0);

var
 R1,R2 :real;

 begin
  clrscr;

   Set_Dec_Prec(3);

  Writeln('Demo business unit');writeln;

  WriteCurrency (10,Sln(100000,30000,10));
  WriteCurrency (10,Syd(100000,12000,10,10));
  Writeln (Cterm(0.03,200000,100000):2:2);
  Writeln (Term(200,0.075,10000):2:2);
  WriteCurrency (10,Pmt(300000,0.03,20));
  Writeln (Rate(2159,1000,10):2:4);
  WriteCurrency (10,Pv(1000,0.03,20));
  WriteCurrency (8,Npv(0.08,S));
  WriteCurrency (10,Fv(1000,0.03,20));

  R1 := 15.8;  R2 := 60.4;
  writeln(CelsToFahr(R1):2:2);
  writeln(FahrToCels(R2):2:2);
  writeln(InchToCm(R1):2:2);
  writeln(CmToInch(R2):2:2);
  writeln(LbToKg(R1):2:2);
  writeln(KgToLb(R2):2:2);
  writeln(GalToL(R1):2:2);
  writeln(LToGal(R2):2:2);

  writeln(Percent(350,22):2:2 );
  writeln(DeltaPercent(4,8):1:2);
  writeln(DeltaPercent(8,4):1:2);

  delay(2500);
 end.