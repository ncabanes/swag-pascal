
  {
    This procedure will draw a line from an origin point for a
    specified length at a specified angle using the current linestyle.
    Must be in graphics mode.
  }


Procedure Azimuth(OrigX,OrigY,Length:integer;Angle:real);

                 { OrigX and OrigY - starting point coordinates }
                 { Length          - length of the line         }
                 { Angle           - self explainatory          }

var A,B:real;

begin
  Angle:=(Angle*pi)/180.0;    { convert angle in degrees to radians }

  moveto(OrigX,OrigY);        { move to the starting point          }

  A:=Length*sin(Angle);       { get there from here                 }
  B:=Length*cos(Angle);

  linerel(round(B),round(A)); { draw line to calculated endpoint    }
end;
