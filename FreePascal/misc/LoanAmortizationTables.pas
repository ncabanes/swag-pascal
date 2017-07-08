(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0079.PAS
  Description: Loan Amortization Tables
  Author: GAYLE DAVIS
  Date: 01-27-94  17:29
*)

program Amortization_Table;

Uses Crt;

var Month                 : 1..12;
    Starting_Month        : 1..12;
    Balance               : real;
    Payment               : real;
    Interest_Rate         : real;
    Annual_Accum_Interest : real;
    Year                  : integer;
    Number_Of_Years       : integer;
    Original_Loan         : real;


procedure Calculate_Payment; (* **************** calculate payment *)
var Temp  : real;
    Index : integer;
begin
   Temp := 1.0;
   for Index := 1 to 12*Number_Of_Years do
      Temp := Temp * (1.0 + Interest_Rate);
   Payment := Original_Loan*Interest_Rate/(1.0 - 1.0/Temp);
end;

procedure Initialize_Data; (* ******************** initialize data *)
begin
   Writeln('   Pascal amortization program');
   Writeln;
   Write('Enter amount borrowed                         ');
   Readln(Original_Loan);
   Balance := Original_Loan;
   Write('Enter interest rate as percentage (i.e. 13.5) ');
   Readln(Interest_Rate);
   Interest_Rate := Interest_Rate/1200.0;
   Write('Enter number of years of payoff               ');
   Readln(Number_Of_Years);
   Write('Enter month of first payment (i.e. 5 for May) ');
   Readln(Starting_Month);
   Write('Enter year of first payment (i.e. 1994)       ');
   Readln(Year);
   Calculate_Payment;
   Annual_Accum_Interest := 0.0; (* This is to accumulate Interest *)
end;

procedure Print_Annual_Header; (* ************ print annual header *)
begin
   Writeln;
   Writeln;
   Writeln('Original loan amount = ',Original_Loan:10:2,
           '   Interest rate = ',1200.0*Interest_Rate:6:2,'%');
   Writeln;
   Writeln('Month    payment  interest    princ   balance');
   Writeln;
end;

procedure Calculate_And_Print; (* ************ calculate and print *)
var Interest_Payment : real;
    Principal_Payment : real;
begin
   if Balance > 0.0 then begin
      Interest_Payment := Interest_Rate * Balance;
      Principal_Payment := Payment - Interest_Payment;
      if Principal_Payment > Balance then begin  (* loan payed off *)
         Principal_Payment := Balance;              (* this month *)
         Payment := Principal_Payment + Interest_Payment;
         Balance := 0.0;
      end
      else begin  (* regular monthly payment *)
         Balance := Balance - Principal_Payment;
      end;
      Annual_Accum_Interest := Annual_Accum_Interest+Interest_Payment;
      Writeln(Month:5,Payment:10:2,Interest_Payment:10:2,
              Principal_Payment:10:2,Balance:10:2);
   end; (* of if Balance > 0.0 then *)
end;

procedure Print_Annual_Summary; (* ********** print annual summary *)
begin
   Writeln;
   Writeln('Total interest for ',Year:5,' = ',
            Annual_Accum_Interest:10:2);
   Writeln;
   Annual_Accum_Interest := 0.0;
   Year := Year + 1;
end;

begin   (* ******************************************* main program *)
   Clrscr;
   Initialize_Data;
   repeat
      Print_Annual_Header;
      for Month := Starting_Month to 12 do begin
         Calculate_And_Print;
      end;
      Print_Annual_Summary;
      Starting_Month := 1;
   until Balance <= 0.0;
end. (* of main program *)
