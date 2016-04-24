(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0047.PAS
  Description: One Month Calendar
  Author: KEITH MERCATILI
  Date: 11-26-94  04:59
*)

{
A couple of weeks ago, my computer science had to write a computer program
to generate a calendar.  Now my assignment is to incorporate the use of
appropriate enumeration and subrange data types, and corresponding procedures
to support these, into the program as a way of improving it.  Here is the
program that I would like some suggestions on.. Thanks in advance:
}
program OneMonthCalendar ( INPUT, OUTPUT ) ;
 
var
    Month : INTEGER ;  (* The month number;  a value in the range 1 - 12 *) 
    PrevMonthDays : INTEGER ;  (* The number of days in the previous month *) 
    CurrMonthDays : INTEGER ;  (* The number of days in the desired month *) 
    StartDay : INTEGER ;  (* A value indicating the day of the week on    *)
                          (* which the month begins;  0 = Sunday, 1 =    *)
                          (* Monday, etc *) 
    Date : INTEGER ;  (* The data currently being generated *) 
 
(*----------------------------------------------------------*)
(*----------------------------------------------------------*)
 
procedure ReadData
    ( var MonthNumber : INTEGER (* out - The month number *) ;
      var PreviousMonthDays : INTEGER (* out - Number of days in the previous 
                                        month *) ;
      var CurrentMonthDays : INTEGER (* out - Number of days in the desired 
                                        month *) ;
      var StartingDay : INTEGER (* out - The day of the week on which the
                                         desired month begins *) ) ;
    begin (* procedure *)
     Read ( MonthNumber ) ;
     Read ( PreviousMonthDays ) ;
     Read ( CurrentMonthDays ) ;
     Read ( StartingDay ) ;
     ReadLn;
    end  (* ReadData *) ;

(*----------------------------------------------------------*)
 
procedure WriteHeading
    (  Month : INTEGER (* in - The month number *) ) ;
 
    begin (* procedure *)
     WriteLn;
     WriteLn ( 'Month ', Month:2);
     WriteLn ( '+----------------------+');
     WriteLn ( '|  S  M  T  W  T  F  S |');
     WriteLn ( '+----------------------+');
    end  (* WriteHeading *) ;

  (*----------------------------------------------------------*)

  procedure WriteTrailing;
   
       
   
      begin (* procedure *)
       WriteLn ('+----------------------+');
      end  (* WriteTrailing *) ;
   
(*----------------------------------------------------------*)
 
procedure IncrementDate

    ( var Date : INTEGER (* in out - The date value to be incremented *) ;
       DateLimit : INTEGER (* in - The number of days in the month
                                   corresponding to the given date value *)
                          );
    begin (* procedure *)
     if Date < DateLimit then begin
         Date := Date + 1 ;
     end else begin
          Date := 1
     end  (* if *) ;
    end  (* IncrementDate *) ;
 
(*----------------------------------------------------------*)
 
procedure OneDayCalendar
    (  Date : INTEGER (* in - The date value for the day *) ) ;
 
    begin (* procedure *)
     Write ( Date:3 ) ;
    end  (* OneDayCalendar *) ;
 
(*----------------------------------------------------------*)
 
procedure OneWeekCalendar
    ( var Date : INTEGER (* in out - The date value *) ;
       MonthsLastDate : INTEGER (* in - The date value of the last day   *)
                       (* in the month corresponding to the    *)
                       (* given date value *) ) ;
 
    var
       Day : INTEGER ;(* Counting variable *) 
       
    begin (* procedure *)
     Write ('|');
     for Day := 1 to 7 do begin
        OneDayCalendar ( Date ) ;
        IncrementDate ( Date, MonthsLastDate ) ;
       (* Day's value represents the number of dates outputed *)
     end  (* for *) ;
     WriteLn (' |');
    end  (* OneWeekCalendar *) ;

(*----------------------------------------------------------*)
 
procedure DetermineSundayDate
    (  PreviousMonthDays : INTEGER (* in - The number of days in the    *)
                          (* previous month *) ;
       StartingDay : INTEGER (* in - A value representing the day of the *)
                    (* week on which the desired month begins *) ;
      var SundayDate : INTEGER (* out - The date of the Sunday for the    *)
                      (* first week in the calendar *) ) ;
 
    begin (* procedure *)
     SundayDate := PreviousMonthDays - StartingDay;
     IncrementDate (SundayDate, PreviousMonthDays);
    end  (* DetermineSundayDate *) ;

(*----------------------------------------------------------*)
 
procedure GenerateCalendar
    (  Date : INTEGER (* in - The starting date *) ;
       PreviousMonth : INTEGER (* in - The number of days in the previous
                                       month *) ;
       CurrentMonth : INTEGER (* in - The number of days in the current
                                      month *) ) ;
 
    var
        PreviousSunday : INTEGER ;  (* The date of the previous sunday *)

    begin (* procedure *)
      OneWeekCalendar ( Date, PreviousMonth ) ;
      PreviousSunday := Date;
      while Date >= PreviousSunday do begin
         PreviousSunday := Date;
         OneWeekCalendar ( Date, CurrentMonth ) ;
      end  (* while *) ;
    end  (* GenerateCalendar *) ;

(*=======================================================================*)

begin (* main program *)
    WriteLn ('One Month Calendar - Version 4');  WriteLn;
    while NOT EOF do begin
       ReadData ( Month, PrevMonthDays, CurrMonthDays, StartDay ) ;
       WriteHeading (Month);
       DetermineSundayDate (PrevMonthDays, StartDay, Date);
       GenerateCalendar (Date, PrevMonthDays, CurrMonthDays);
       WriteTrailing;
       (* EOLN is true *)
    end  (* while *) ;
end (* OneMonthCalendar *).


