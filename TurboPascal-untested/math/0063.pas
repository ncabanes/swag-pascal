{
   Any navigators out there?  I need formulas or source code to calculate
   the distance between two points given the latitude and longitude
   of each point.  I'm trying to write some support software for my
   Sony Pyxis GPS (global positioning system). }


 Procedure Dist( Var xlat1,xlon1,xlat2,xlon2,xdist,ydist,distance : Real);
 {
 Returns the distance ( in km ) between two points on a tangent plane
 on the earth.
 }
  Const
   Km = 111.19;
   C1 = 0.017453292;
  Var
   Xmlat,
   cosm,
   Adist   : Real;

  Begin { Dist }
 { Calculate cos of mean latitude }
   Xmlat := (xlat1+xlat2)/2;
   cosm  := cos(xmlat*C1);
 { Calculate Y (N-S) distance }
   ydist := (xlat2-xlat1)*km;
 { Calculate X (E-W) distance }
   xdist := (xlon2-xlon1)*km*cosm;
 { Calculate total distance }
   adist := xdist*xdist + ydist*ydist;
   If adist >= 0 then
      distance := sqrt(adist)
   Else
      distance := 0;
  End; { Dist }

This is one I use in some wind calculations for an aircraft fitted with
GPS and LORAN-C.

Note that all Latitude And Longitudes are in Degrees with minutes and
seconds converted to decimal degrees.
