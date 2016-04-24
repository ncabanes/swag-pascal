(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0036.PAS
  Description: Conversion to Base 36
  Author: TIM MCKAY
  Date: 11-02-93  05:14
*)

(*
From: TIM MCKAY
Subj: RE: COVERTING TO BASE 36

 JF> Can someone please show me how I would convert a base 10 number to
 JF> base 36? (The one used by RIP)
*)

program convertbase;

  const B: integer = 36;       { B = the base to convert to }
          S: string  = '';       { S = the string representation of the
                                     result }
                                             done: boolean = false;

  var   X, I, F: integer;      { X = the original base 10 number
                                 I = the integer portion of the result
                                 F = the fractional portion of the
                                     result }
                                             R: real;               { R = the
intermediate real result }

  begin
    readln(X);                 { Get original base 10 number }
    R:=X;
    while (not done) do begin  { This loop continues to divide the     }
          R:= R/B;                 { result by the base until it reaches 0 }
          I:= int (R);             { The integer portion of the result is  }
          R:= I;                   { reassigned to R                    }
          F:= frac(R) * B;         { The fractional portion is converted to}
          if f<10 then begin       { an integer remainder of the original  }
            S:=chr(f+$30) + S;     { base and converted to a character to  }
          end else begin           { be added to the string representation }
         S:=chr(f+$37) + S;
      end;
      if R<=0 then done:=true; { When R reaches 0 then you're done     }
          end;
    writeln(S);
  end.


