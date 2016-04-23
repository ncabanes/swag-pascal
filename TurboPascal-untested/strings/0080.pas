
(******************************************************************************
 RealStr.PAS - Routine which formats a double, real or single number to a
               requested number of significant digits.
 Author      - Richard Mullen    CIS 76566,1325
 Date        - 7/5/90, Released to public domain
******************************************************************************)
{$O+}
{$F+}
{$R+}    { Range checking on               }
{$B-}    { Boolean complete evaluation off }
{$S-}    { Stack checking off              }
{$I-}    { I/O checking off                }
{$V-}    { Relaxed variable checking       }
{$N+}         { Numeric coprocessor             }
{$E+}         { Numeric coprocessor emulation   }

UNIT RealStr;

INTERFACE

function  Real_To_Str  (SigDigits : word; Number : double) : string;

                       { SigDigits should be between 2 and 15 for doubles }
                       {                             2 and 11 for reals   }
                       {                             2 and  7 for singles }

IMPLEMENTATION

(*****************************************************************************)

function  Real_To_Str  (SigDigits : word; Number : double) : string;
var
  i             : integer;
  ErrorCode     : integer;
  E_Value       : integer;
  E_Position    : word;
  Exponent      : string[4];
  SDigits       : word;
  TempString    : string;

begin
(*
   if SigDigits > 15 then SigDigits := 15;      { 15 for double, 11 for real, }
   if SigDigits < 2 then SigDigits  := 2;       {  7 for single               }
*)
   str (Number, TempString);
   delete (TempString, 3, 1);                        { Delete decimal point   }
   E_Position := pos ('E', TempString);
   val (copy (TempString, E_Position + 1, 5), E_Value, ErrorCode);
   Real_To_Str := '';
   if ErrorCode <> 0 then exit;                      { E_Value = exponent     }
   delete (TempString, E_Position, 6);               { Delete exponent string }
                                                     {  from TempString       }
   if SigDigits + 2 < E_Position then
      begin                                          {  Round TempString      }
      insert ('0', TempString, 2);                   { Insert 0 for overflow  }   E_Position := pos ('E', TempString);
      if TempString[SigDigits + 3] >='5' then                                {}
         inc (TempString[SigDigits + 2]);                                    {}
      for i := SigDigits + 2 downto 2 do                                     {}
         if TempString [i] = chr (ord ('9') + 1) then                        {}
            begin                                                            {}
            TempString [i] := '0';                                           {}
            inc (TempString [i - 1]);                                        {}
            end;                                                             {}
      if TempString[2] = '0' then delete (TempString, 2, 1) { <-- no overflow }
      else inc (E_Value);                                   { <-- overflow    }
      end;                                                                   {}
                                                     { Delete extra precision }
   delete (TempString, SigDigits + 2, length (TempString));

   i := length (TempString);                           { Remove all trailing  }
   while (TempString[i] = '0') AND (i > 2) do          {  zeros, leaving only }
      begin                                            {  significant digits  }
      delete (TempString, i, 1);                                             {}
      dec (i);                                                               {}
      end;                                                                   {}

   SDigits := length (TempString) - 1;         { Number of significant digits }

   if (E_Value >= SigDigits) OR (SDigits - E_Value - 1 > SigDigits) then
      begin                                             { Scientific notation }
      if SDigits > 1 then insert ('.', TempString, 3);                       {}
      str (E_Value, Exponent);                                               {}
      TempString := Tempstring + ' E' + Exponent;                            {}
      end                                                                    {}
   else
      begin
      if E_Value >= 0 then                             { Exponent is positive }
         begin                                         { |Number|, >= 1, can  }
         for i := 1 to E_Value - SDigits + 1 do        {  be displayed with   }
            TempString := TempString + '0';            {  no exponent         }
         if E_Value < SDigits - 1 then insert ('.', TempString, E_Value + 3);
         end
      else
         begin                                         { Exponent is negative }
         for i := 1 to - E_Value - 1 do                { |Number|, < 1,  can  }
            insert ('0', TempString, 2);               {  be displayed with   }
         insert ('0.', TempString, 2);                 {  no exponent         }
         end;                                          { Add '0.' to number   }
      end;

   Real_To_Str := TempString;
end;

(************************   No initialization   ******************************)
end.