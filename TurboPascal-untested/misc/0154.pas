{
Given the time of year, I offer the following pascal function,
(my translation of M. Cooper's WINDCHILL public domain C code):

Calculates windchill, given temperature (Fahrenheit) and windspeed (mph)

---------------------------------------------------------------------------
NOTE:

 I have converted Mr. Kolding's original function so that it accepts and
 returns real parameters.  I have also offered a Metric equivalent.

  - Kerry (SWAG Support Team)
}

Function WindChill(FahrenheitTemp, Mph_WindSpeed : Real) : Real;
begin
  WindChill := 0.0817 *
               (3.71 * Sqrt(Mph_WindSpeed) + 5.81 - 0.25 * Mph_WindSpeed) *
               (FahrenheitTemp - 91.4) + 91.4;
end;

Function MetricWindChill(CelciusTemp, Kph_WindSpeed : Real) : Real;
Var
  FahrenheitTemp,
  Mph_WindSpeed  : Real;
begin
  { Convert Celcius to Fahrenhiet - VERY exact :) }
  FahrenheitTemp := (CelciusTemp * 492 / 273.16) + 32;
  { Convert Kph to Mph }
  Mph_WindSpeed  := Kph_WindSpeed * 1.609;

  { Use exact same formula as above }
  MetricWindChill :=
    0.0817 * (3.71 * Sqrt(Mph_WindSpeed) + 5.81 - 0.25 * Mph_WindSpeed) *
    (FahrenheitTemp - 91.4) + 91.4;
end;


begin
  { Room Temperature Test: }
  Writeln('68°F + 0 Mph Wind Speed: ', WindChill(68, 0) : 0 : 2);
  Writeln('20°C + 0 Kph Wind Speed: ', MetricWindChill(20, 0) : 0 : 2);

end.