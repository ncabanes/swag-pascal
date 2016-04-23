

{ *********************************************************************** }
{                                                                         }
{  ExpBox V1.03 explodes a Box on the display using BGI routines.         }
{  You define the final box area, how many steps in the explosion,        }
{  the speed at which the explosion occurs, and where the explosion       }
{  is to start at. You also define the color and pattern of the           }
{  exploding box. You can optionally specifiy a rectangle to follow       }
{  the exploding box to provide more action. The color of the rectangle   }
{  can also be defined.                                                   }
{    Uses the TP graph unit and the CRT unit (only uses the Delay         }
{  function from the CRT unit). If you don't use the CRT unit, then you   }
{  might want to consider using the CRTI unit from the Borland TP4        }
{  library on CompuServe which allows you to remove unwanted functions.   }
{                                                                         }
{      Originally written by Michael Day as 20 November 1988              }
{                  Copyright 1988 by Michael Day                          }
{           This release (V1.03) as of 14 February 1989                   }
{            Released to the public domain by author.                     }
{                                                                         }
{ *********************************************************************** }
{ History:                                                                }
{ V1.01 - Original release                                                }
{ V1.02 - Removed excess unused code                                      }
{ V1.03 - Adjusted number to match new release of SDI                     }

unit ExpBox;
interface

uses graph,CRT;

{ *********************************************************************** }
{--                    External access definitions                      --}
{ *********************************************************************** }

{-------------------------------------------------------------------------}
{Explodes a box on the screen}
{x1,y1,x2,y2=final box size, Step=explosion steps, }
{Speed=delay in ms between explosions, Style=how to explode}
{Color=box color, Pattern=background pattern, }
{RColor=rectangle color (if used) }

procedure ExplodeBox(x1,y1,x2,y2:integer;
                     Speed,Step,Style:word;
                     Color,Pattern,RColor:byte);


{ *********************************************************************** }

implementation


procedure ExpRect(x1,y1,x2,y2:integer; Style:word);
var i,Rc,rx,ry,ix,iy:integer;
begin
   bar(X1, Y1, X2, Y2);
   Rc := (style shr 5) and 7;
   if Rc > 0 then
   begin
     ix := ((x2-x1)shr 1)shr rc;
     iy := ((y2-y1)shr 1)shr rc;
     for i := Rc downto 1 do
     begin
       rx := ((x2-x1)shr(i))-ix;
       ry := ((y2-y1)shr(i))-iy;
       rectangle(succ(X1+rx), succ(Y1+ry), pred(X2-rx), pred(Y2-ry) );
     end;
   end;
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{                         misc special effects                            }
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

{-------------------------------------------------------------------------}
{Explodes a box on the screen}

{Styles: 0=explode from center, 1=explode from top, 2=explode from bottom,}
{3=explode from left, 4=explode from right, 5=explode from top left corner,}
{6=explode bot left corner, 7=explode top right corner, }
{8=explode from bottom right corner. 9 and Above = no explode.}
{if Style bits 5,6,7 are set, then rectangles will be drawn while exploding.}
{a Step value of 0 or 1 will not cause an explode, the value must be larger}
{than 1 to get an explode to happen. Speed sets the delay in ms between}
{explode steps. Color and Pattern set the exploding box color and pattern.}
{RColor sets the rectangle color (when used). If Style bit 4 is on, then }
{sound effects will also be added.}

procedure ExplodeBox(x1,y1,x2,y2:integer;
                     Speed,Step,Style:word;
                     Color,Pattern,RColor:byte);
var si,i,Sx,Sy : integer;
begin
   if Step > 0 then
   begin
     if (Style and $10) = $10 then NoSound;
     Sx := (x2-x1) div Step;
     Sy := (y2-y1) div Step;
     SetFillStyle(Pattern,Color);
     setcolor(RColor);
     for i := pred(Step) downto 1 do
     begin
       case (Style and $f) of
         {center explode}
         0: ExpRect(x1+((Sx*i)shr 1), y1+((Sy*i)shr 1),
                    x2-((Sx*i)shr 1), y2-((Sy*i)shr 1), Style);

         {top explode}
         1: ExpRect(x1, y1, x2, y2-(Sy*i), Style);

         {bot explode}
         2: ExpRect(x1, y1+(Sy*i), x2, y2, Style);

         {left explode}
         3: ExpRect(x1, y1, x2-(Sx*i), y2, Style);

         {right explode}
         4: ExpRect(x1+(Sx*i), y1, x2, y2, Style);

         {top left explode}
         5: ExpRect(x1, y1, x2-(Sx*i), y2-(Sy*i), Style);

         {bot left explode}
         6: ExpRect(x1, y1+(Sy*i), x2-(Sx*i), y2, Style);

         {top right explode}
         7: ExpRect(x1+(Sx*i), y1, x2, y2-(Sy*i), Style);

         {bot right explode}
         8: ExpRect(x1+(Sx*i), y1+(Sy*i), x2, y2, Style);

       end; {case}

       if (Style and $10) = $10 then Sound(i shl 8);
       if (Style and $f) < 9 then delay(Speed);
     end;
     bar(x1,y1,x2,y2);  {draw final box}
     if (Style and $10) = $10 then NoSound; {turn the sound off if was on}
   end;
end;


{ *********************************************************************** }

end.
