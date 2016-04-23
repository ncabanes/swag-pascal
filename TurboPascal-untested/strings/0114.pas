
{ This function will format all integers in Pascal to be formatted with
a punctuation between any 3 digits. Eq: 1234567890 will look like:
1.234.567.890 If you prefer to use a comma instead of punctuation, just
replace the '#46' with '#44' or any other delimiter of your own choice.
}

Function NFormat (FNumber : Longint) : String;
   var TempStr : String; OrgLen : Byte;
      begin
      Str (FNumber, TempStr); OrgLen := Length (TempStr);
      Case OrgLen of
          4 : TempStr := Copy(TempStr, 1, 1) + #46 + Copy(TempStr,2,3);
          5 : TempStr := Copy(TempStr, 1, 2) + #46 + Copy(TempStr,3,3);
          6 : TempStr := Copy(TempStr, 1, 3) + #46 + Copy(TempStr,4,3);
          7 : TempStr := Copy(TempStr, 1, 1) + #46 + Copy(TempStr,2,3)
                                             + #46 + Copy(TempStr,5,3);
          8 : TempStr := Copy(TempStr, 1, 2) + #46 + Copy(TempStr,3,3)
                                             + #46 + Copy(TempStr,6,3);
          9 : TempStr := Copy(TempStr, 1, 3) + #46 + Copy(TempStr,4,3)
                                             + #46 + Copy(TempStr,7,3);
         10 : TempStr := Copy(TempStr, 1, 1) + #46 + Copy(TempStr,2,3)
                                             + #46 + Copy(TempStr,5,3)
                                             + #46 + Copy(TempStr,8,3);
         end;
      NFormat := TempStr;
      end;

(* TEST THE FUNCTION ABOVE *)

BEGIN

Writeln(NFormat(1):15);
Writeln(NFormat(12):15);
Writeln(NFormat(123):15);
Writeln(NFormat(1234):15);
Writeln(NFormat(12345):15);
Writeln(NFormat(123456):15);
Writeln(NFormat(1234567):15);
Writeln(NFormat(12345678):15);
Writeln(NFormat(123456789):15);
Writeln(NFormat(1234567890):15);
Readln;

END.

