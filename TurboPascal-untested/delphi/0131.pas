{
Since Delphi's TDateTime data type stores dates in
number of days since 1/1/0001, all you need to do is
subtract the TDateTime of the first day of the month
in question from the TDateTime of the first day of the
following month.

The following function will return an integer representing
the number of days in any given month:
}

function daysHathTheMonth(whichMonth, whichYear:integer):integer;
var
   beginDate, endDate :TDateTime;
   beginMonth,endMonth,beginYear,endYear:word;
begin
   beginMonth := whichMonth;
   beginYear := whichYear;
   endMonth := whichMonth + 1;
   endYear := whichYear;
   if beginMonth > 11 then
      begin
          {the month in question is December, so the following
               TDateTime would be January 1st of the following year}
           beginMonth := 12;
           endMonth := 1;
           endYear := whichYear + 1;
      end;
   beginDate := encodeDate(beginYear,beginMonth,01);
   endDate := encodeDate(endYear,endMonth,01);
   daysHathTheMonth:= strToInt(floatToStr(endDate - beginDate));
end;
==============================================================

To test it, just call:
 showMessage(intToStr(daysHathTheMonth(04,1996)));

You can easily add a case statement in order to be able to
pass the function a string such as 'Feb', etc. if you
want, but I find integers/words more convenient since
all of Delphi's Date and Time Routines use them.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 Carl Steinhilber         csteinhilber@graphicmedia.com
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

