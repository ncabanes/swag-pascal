{
(* Here is the code snippet I want to donate to SWAG. It works both in TP
and in Delphi.
   The date is incremented correctly for all leap years, and I have not
been able to
   find any bugs, but there are no guarantees :-). *)
}


function IncrementDate( ADate : STRING ) : STRING;
     (* ADate must take the form of mm/dd/yyyy *)
     (* The common mm/dd/yy form will not work!*)

 var
   LeapYear             : BOOLEAN;

   ecode,                               (* an error code (not used here) *)
   dd, mm, yy           : INTEGER;

   AString, DateString  : STRING;

 begin
         (* Crude error trap *)
   AString := ADate;
   if Length( AString ) <> 10 then
      Halt( 1 );
   if Copy( AString, 3, 1 ) <> '/' then
      Halt( 1 );
   if Copy( AString, 6, 1 ) <> '/' then
      Halt( 1 );

         (* Break ADate into its components *)
   AString := Copy( ADate, 1, 2 );
   Val( AString, mm, ecode );
   AString := Copy( ADate, 4, 2 );
   Val( AString, dd, ecode );
   AString := Copy( ADate, 7, 4 );
   Val( AString, yy, ecode );

   LeapYear := False;
   if yy mod 400 = 0 then        (* this is why the year must be "yyyy" *)
      LeapYear := True
   else if( yy mod 4 = 0 ) and ( yy mod 100 <> 0 ) then
      LeapYear := True;

         (* Increment date and adjust month and year as necessary *)
   case mm of
      1, 3, 5, 7, 8, 10 :
         if dd < 31 then
            Inc( dd )
         else
          begin
            dd := 1;
            Inc( mm );
          end;
      2 :
         case dd of
            1..27 :
               Inc( dd );
            28 :
               if LeapYear = False then
                begin
                  dd := 1;
                  mm := 3;
                end
               else
                Inc( dd );
            29 :
             begin
               dd := 1;
               mm := 3;
             end;
          end;(*case*)
      4, 6, 9, 11 :
         if dd < 30 then
            Inc( dd )
         else
          begin
            dd := 1;
            Inc( mm );
          end;
      12 :
       begin
         if dd < 31 then
            Inc( dd )
         else
          begin
            dd := 1;
            mm := 1;
            Inc( yy );
          end;
       end;
    end;(*case*)

         (* Add month to DateString *)
   Str( mm, AString );
   if Length( AString ) < 2 then
      DateString := '0'+AString+'/'
   else
      DateString := AString+'/';
         (* Add day to DateString *)
   Str( dd, AString );
   if Length( AString ) < 2 then
      DateString := DateString+'0'+AString+'/'
   else
      DateString := DateString+AString+'/';
         (* Add year to DateString *)
   Str( yy, AString );
      DateString := DateString+AString;

   IncrementDate := DateString;
end;
