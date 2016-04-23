Type Fijo=Record                {estructura de un n▀ de coma fija}
            Mantisa,
            Decimal:Integer
          End;

Var Var1,                       {variables de ejemplo}
    Var2:Fijo;

Const Decimal_Max=100;            {2 decimales}
      Decimal_Stellen=2;

Function Strg(NumF:Fijo):String;
{convierte un n▀ de coma fija en una cadena}
Var Decimal_Str,                  {cadena para formar los decimales}
    Mantisa_Str:String;            {cadena para formar la mantisa}
    i:Word;
Begin
  If NumF.Decimal < 0 Then       {parte decimal sin signo}
    NumF.Decimal:=-NumF.Decimal;
  Str(NumF.Decimal:Decimal_Stellen,Decimal_Str);
                                {generar cadena decimal}
  For i:=0 to Decimal_Stellen do  {y sustituir blancos por 0en}
    If Decimal_Str[i] = ' ' Then Decimal_Str[i]:='0';
  Str(NumF.Mantisa,Mantisa_Str);     {generar cadena de mantisa}
  Strg:=Mantisa_Str+','+Decimal_Str; {componer cadena}
End;

Procedure Convert(RZahl:Real;Var NumF:Fijo);
{convierta real RZahl en n▀ coma fija NumF}
Begin
  NumF.Mantisa:=Trunc(RZahl);
    {determinar parte mantisa}
  NumF.Decimal:=Trunc(Round(Frac(RZahl)*Decimal_Max));
    {determinar parte decimal y guardar como n▀ entero}
End;

Procedure Adjust(Var NumF:Fijo);
{devuelve el número de coma fija en formato legal}
Begin
  If NumF.Decimal > Decimal_Max Then Begin
    Dec(NumF.Decimal,Decimal_Max); {si parte decimal ha rebasado positivo}
    Inc(NumF.Mantisa);            {reponer y reducir mantisa}
  End;
  If NumF.Decimal < -Decimal_Max Then Begin
    Inc(NumF.Decimal,Decimal_Max); {si parte decimal ha rebasado negativo}
    Dec(NumF.Mantisa);            {reponer y aumentar mantisa}
  End;
End;

Procedure Add(Var Summe:Fijo;NumF1,NumF2:Fijo);
{Suma NumF1 y NumF2 y deposita resultado en ab}
Var Resultado:Fijo;
Begin
  Resultado.Decimal:=NumF1.Decimal+NumF2.Decimal;
    {sumar parte decimal}
  Resultado.Mantisa:=NumF1.Mantisa+NumF2.Mantisa;
    {sumar mantisa}
  Adjust(Resultado);
    {pasar resultado a formato correcto}
  Summe:=Resultado;
End;

Procedure Sub(Var Diferencia:Fijo;NumF1,NumF2:Fijo);
{resta NumF1 de NumF2 y deposita resultado en ab}
Var Resultado:Fijo;
Begin
  Resultado.Decimal:=NumF1.Decimal-NumF2.Decimal;
    {restar parte decimal}
  Resultado.Mantisa:=NumF1.Mantisa-NumF2.Mantisa;
    {restar mantisa}
  Adjust(Resultado);
    {pasar resultado a formato correcto}
  Diferencia:=Resultado;
End;

Procedure Mul(Var Producto:Fijo;NumF1,NumF2:Fijo);
{multiplica NumF1 y NumF y deposita el resultado en ab}
Var Resultado:LongInt;
Begin
  Resultado:=Var1.Mantisa*Decimal_Max + Var1.Decimal;
    {formar primer factor}
  Resultado:=Resultado * (Var2.Mantisa*Decimal_Max + Var2.Decimal);
    {formar segundo factor}
  Resultado:=Resultado div Decimal_Max;
    {compensar factor aux. Decimal_Max}
  Producto.Mantisa:=Resultado div Decimal_Max;
    {extraer mantisa y parte decimal}
  Producto.Decimal:=Resultado mod Decimal_Max;
End;

Procedure Divi(Var Cociente:Fijo;NumF1,NumF2:Fijo);
{divide NumF1 entre NumF2 y deposita el resultado en ab}
Var Resultado:LongInt;           {resultado intermedio}
Begin
  Resultado:=NumF1.Mantisa*Decimal_Max + NumF1.Decimal;
    {formar contador}
  Resultado:=Resultado * Decimal_Max div
(NumF2.Mantisa*Decimal_Max+NumF2.Decimal);
    {dividir por el divisor, antes disponer de m▌s decimales}
  Cociente.Mantisa:=Resultado div Decimal_Max;
    {extraer parte decimal y mantisa}
  Cociente.Decimal:=Resultado mod Decimal_Max;
End;

Begin
  WriteLn;
  Convert(-10.2,Var1);          {cargar dos números de demo}
  Convert(25.3,Var2);

  {c▌lculos propios para demostración:}

  Write(Strg(Var1),'*',Strg(Var2),'= ');
  Mul(Var1,Var1,Var2);
  WriteLn(Strg(Var1));

  Write(Strg(Var1),'-',Strg(Var2),'= ');
  Sub(Var1,Var1,Var2);
  WriteLn(Strg(Var1));

  Write(Strg(Var1),'/',Strg(Var2),'= ');
  Divi(Var1,Var1,Var2);
  WriteLn(Strg(Var1));

  Write(Strg(Var1),'+',Strg(Var2),'= ');
  Add(Var1,Var1,Var2);
  WriteLn(Strg(Var1));
End.
