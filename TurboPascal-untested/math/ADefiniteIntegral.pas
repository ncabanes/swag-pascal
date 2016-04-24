(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0065.PAS
  Description: A definite Integral
  Author: GLENN GROTZINGER
  Date: 02-22-94  11:40
*)

program integration; uses crt;

  { program below demonstrates Pascal code used to compute a definite }
  { integral.  Useful for many calculus-related functions such as     }
  { finding areas of irregular shapes when a functional relation is   }
  { known.  You may freely use this code, but do please give me the   }
  { credits.                                                          }

  { A negative area as an answer, is the result of incorrectly defining
  the lower and upper bounds for a function.  For example, using the
  function

    6 - 6x^5, a perfectly justifiable lower bound would be 0, while - 5
    would not be.  a perfectly justifiable upper bound would be 1, while
    6 would not be.  The non-justifiable bounds used as examples, are not
    defined in the function used, so a negative area would result in this
    case

  { Tutorial: this program uses Simpson's rule as a method of finding  }
  { the area under a graphed curve.  A lower and an upper limit is set }
  { where the area is calculated.  The area is cut up into a number of }
  { rectangles dictated by the 'number of divisions'.  The more you    }
  { divide up this area, the more accurate an approximation becomes.   }

  var
    lower, upper, divisions, sum, width, counter, x, left, right, middle,
      c: real;

  procedure formula;

    { procedure set apart from rest of program for ease of changing the }
    { function if need be.   The function is defined as: f(x) =         }
    { <expression>, expression being set in a Pascal-type statement     }

    begin
      c := 6 - ( 6 * x * x * x * x * x ); { current function set: 6 - 6x^5 }
    end;

  begin

    clrscr;
    { read in lower bound }

    writeln('Input lower limit.');
    readln(lower);

    { read in upper bound }

    writeln('Input upper limit.');
    readln(upper);

    { read in the number of divisions.. The higher you make this number, }
    { the more accurate the results, but the longer the calculation...   }

    Writeln('number of divisions?');
    readln(divisions);

    { set the total sum of the rectangles to zero }

    sum := 0;

    { determine width of each rectangle }

    width := (upper - lower) / (2 * divisions);

    { initalize counter for divisions loop }

    counter := 1;

    clrscr;
    writeln('Working...');

    { start computations }

    repeat

      { define left, right, and middle points along each rectangle }

      left := lower + 2 * (counter - 1) * width;
      right := lower + 2 * counter * width;
      middle := (left + right) / 2;

      { compute functional values at each point }

      x := left;
      formula;
      left := c;
      x := middle;
      formula;
      middle := c;
      x := right;
      formula;
      right := c;

      { calculate particular rectangle area and increment the area to the }
      { sum of the areas.                                                 }

      sum := (width * (left + 4 * middle + right)) / 3 + sum;

      { write sum to screen as a "working" status }

      writeln;
      write(sum:0:9);
      gotoxy(1,2);

      { increment counter }

      counter := counter + 1;

    { stop loop when all areas of rectangles are computed }

    until counter = divisions;

    { output results }

    clrscr;
    writeln('The area under the curve is ', sum:0:9, '.');
                                          { ^^^^^^^^ }
  end.                                    { format code used to eliminate }
                                          { scientific notation in answer }
