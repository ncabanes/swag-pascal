(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0245.PAS
  Description: Least Squares method interpolation
  Author: ALEKSANDAR DLABAC
  Date: 03-04-97  13:18
*)

 Program Interpolation;
{
             ██████████████████████████████████████████████████
             ███▌▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██  Least squares method interpolation  ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██           Aleksandar Dlabac          ██▐███▒▒
             ███▌██    (C) 1995. Dlabac Bros. Company    ██▐███▒▒
             ███▌██    ------------------------------    ██▐███▒▒
             ███▌██      adlabac@urcpg.urc.cg.ac.yu      ██▐███▒▒
             ███▌██      adlabac@urcpg.pmf.cg.ac.yu      ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▐███▒▒
             ██████████████████████████████████████████████████▒▒
               ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
}

{
    Interpolation is a technique used to calculate estimated function of
which we have some experimental points. Firstly, we have to choose order of
interpolation. Order of interpolation represents the order of estimated
function. For example, if order is 5 function will be in form of:

    F(x) = a5*x^5 + a4*x^4 + a3*x^3 + a2*x^2 + a1*x + a0

    This program (procedure Interpolate) returns coefficients a0..an, where
n is order. We have to determine the order considering positions of points.
}
   Uses Crt, Graph;

   Type Row    = array [0..10] of real;     { Maximal order               }
        Matrix = array [0..10] of Row;      { is 10.                      }
        Data   = array [1..200] of integer; { Data for interpolation      }
        Coeff  = array [0..10] of real;     { Coefficients (also max. 10) }

   Const Order = 5;  { Order of interpolated curve. Should be smaller than  }
                     { number of points. For orders greater than 6-7 system }
                     { (of equations) becomes unstable, so curve could be   }
                     { wrong. Also, for higher orders real type should be   }
                     { changed to extended, and $N switch should be on.     }

   Var Gd, Gm, I, J : integer;
       R            : real;
       InversionOK  : Boolean;
       Mat          : Matrix;
       X, Y         : Data;
       C, YM        : Coeff;

   Function Power (Base,Pow:integer) : real;
     Var Temp : real;
       Begin
         If (Base<0) and (Pow mod 2=1) then
           Temp:=-Exp (Pow*Ln (-Base))
                     else
           Temp:=Exp (Pow*Ln (Abs (Base)));
         Power:=Temp
       End;

   Procedure MatrixInversion (Var A:Matrix; N:integer);
     Var I, J, K : integer;
         Factor  : real;
         Temp    : Row;
         B       : Matrix;
       Begin
         InversionOK:=False;
         For I:=0 to N do
           For J:=0 to N do
             If I=J then
               B [I,J]:=1
                    else
               B [I,J]:=0;
         For I:=0 to N do
           Begin
             For J:=I+1 to N do
               If Abs (A [I,I])<Abs (A [J,I]) then
                 Begin
                   Temp:=A [I];
                   A [I]:=A [J];
                   A [J]:=Temp;
                   Temp:=B [I];
                   B [I]:=B [J];
                   B [J]:=Temp
                 End;
             If A [I,I]=0 then Exit;
             Factor:=A [I,I];
             For J:=N downto 0 do
               Begin
                 B [I,J]:=B [I,J]/Factor;
                 A [I,J]:=A [I,J]/Factor
               End;
             For J:=I+1 to N do
               Begin
                 Factor:=-A [J,I];
                 For K:=0 to N do
                   Begin
                     A [J,K]:=A [J,K]+A [I,K]*Factor;
                     B [J,K]:=B [J,K]+B [I,K]*Factor
                   End
               End
           End;
         For I:=N downto 1 do
           Begin
             For J:=I-1 downto 0 do
               Begin
                 Factor:=-A [J,I];
                 For K:=0 to N do
                   Begin
                     A [J,K]:=A [J,K]+A [I,K]*Factor;
                     B [J,K]:=B [J,K]+B [I,K]*Factor
                   End
               End
           End;
         A:=B;
         InversionOK:=True
       End;

   Procedure Interpolate (X,Y:Data; var A:Coeff);
     Var I, J, K : integer;
       Begin
         For I:=0 to Order do
           For J:=0 to Order do
             Mat [I,J]:=0;
         For I:=0 to Order do
           For J:=0 to Order do
             For K:=1 to 10 do
               Mat [I,J]:=Mat [I,J]+Power (X [K],I+J);
         MatrixInversion (Mat,Order);
         For I:=0 to Order do
           Begin
             YM [I]:=0;
             A [I]:=0
           End;
         For I:=0 to Order do
           For J:=1 to 10 do
             YM [I]:=YM [I]+Y [J]*Power (X [J],I);
         For I:=0 to Order do
           For J:=0 to Order do
             A [I]:=A [I]+Mat [I,J]*YM [J];
       End;

     Begin
       DetectGraph (Gd,Gm);
       InitGraph (Gd,Gm,'');
       X [1]:=100;  Y [1]:=100;
       X [2]:=150;  Y [2]:=180;
       X [3]:=200;  Y [3]:=250;
       X [4]:=250;  Y [4]:=270;
       X [5]:=300;  Y [5]:=300;
       X [6]:=350;  Y [6]:=320;
       X [7]:=400;  Y [7]:=290;
       X [8]:=450;  Y [8]:=230;
       X [9]:=500;  Y [9]:=130;
       X [10]:=550; Y [10]:=90;
       Interpolate (X,Y,C);
       SetFillStyle (SolidFill,Red);
       For I:=1 to 10 do                        {< Draws red points (input }
         Bar (X [I]-1,Y [I]-1,X [I]+1,Y [I]+1); {< values - X & Y).        }
       SetColor (Green);
       For I:=10 to 55 do                       {< Draws calculated curve. }
         Begin
           R:=0;
           For J:=0 to Order do
             R:=R+C [J]*Power (I*10,J);
           If I=10 then
             MoveTo (I*10,Round (R))
                   else
             LineTo (I*10,Round (R))
         End;
       Repeat Until ReadKey<>#0;
       CloseGraph
     End.
