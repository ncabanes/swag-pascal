unit SCDates;
{
VANITY PART

This Unit was originally created by Simon Carter (sc4vb@geocities.com)
To return the difference of two dates by various methods.

This code is provided as freeware with no warranty implied or expressed.
If you change anything with this unit then please inform me via E-mail with relevant fixes
If you use this unit in your application then please put my name and E-mail in credits.

Thanks to the following people for their input via Delphi-l or Delphi-talk
Mitchell R. Peek
Gentleman Jersey Dan
Mustafa Bicak
Robert Penz

Released to Public Domain on 22 May 1997
Release history

22/05/97       Simon Carter             Created

}
interface

uses
Sysutils;

Type
    EInvalidPeriod = Class(Exception);

{DateDiff
Purpose of this function is to calculate the difference between two dates and
return various types of information.}
Function DateDiff(Period: Word; Date2, Date1: TDatetime):Longint;

implementation
Function DateDiff(Period: Word; Date2, Date1: TDatetime):Longint;
Var
Year, Month, Day, Hour, Min, Sec, MSec: Word;  //These are for Date 1
Year1, Month1, Day1, Hour1, Min1, Sec1, MSec1: Word; //these are for Date 2
Begin
     //Decode Dates Before Starting
     //This is probably ineficient but it will save doing it for each
     //different Period.
     DecodeDate(Date1, Year, Month, Day);
     DecodeDate(Date2, Year1, Month1, Day1);
     DecodeTime(Date1, Hour, Min, Sec, MSec);
     DecodeTime(Date2, Hour1, Min1, Sec1, MSec1);

     //Default Return will be 0
     Result := 0;

     //Once Decoded Select Type of DateDiff To Return via Period Parameter
     Case Period of
          1:  //Seconds
          Begin
               //first work out days then * days by 86400 (mins in day)
               //Then minus the difference in hours * 3600
               //then minus the difference in minutes * 60
               //Then get the difference in seconds
               Result := (((((Trunc(Date1) - Trunc(Date2))* 86400) - ((Hour1 - Hour)* 3600))) - ((Min1 - Min) * 60)) - (Sec1 - Sec);
          end;
          2: //Minutes
          Begin
               //first work out days then * days by 1440 (mins in day)
               //Then minus the difference in hours * 60
               //then minus the difference in minutes
               Result := (((Trunc(Date1) - Trunc(Date2))* 1440) - ((Hour1 - Hour)* 60)) - (Min1 - Min);
          End;
          3: //hours
          Begin
               //First work out in days then * days by 24 to get hours
               //then clculate diff in Hours1 and Hours
               Result := ((Trunc(Date1) - Trunc(Date2))* 24) - (Hour1 - Hour);
          End;
          4: //Days
          Begin
               //Trunc the two dates and return the difference
               Result := Trunc(Date1) - Trunc(Date2);
          End;
          5: //Weeks
          Begin
               //Trunc the two dates and divide
               //result by seven for weeks
               Result := (Trunc(Date1) - Trunc(Date2)) div 7;
          end;
          6: //Months
          Begin
               //Take Diff in Years and * 12 then add diff in months
               Result := ((Year - Year1) * 12) + (Month - Month1);
          End;
          7: //Years
          Begin
               //Take Difference In Years and Return result
               Result := Year - Year1;
          End
          Else //Invalid Period *** Raise Exception ***
          Begin
               Raise EInvalidPeriod.Create('Invalid Period Assigned To DateDiff');
               Result := 0;
          end;
     End;
End;
end.
