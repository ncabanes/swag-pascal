{

Here's another Unit from me, This time it's a 
 Unix to DelphiTimeDate and ViceVersa Conversion Routines...

Andre Jakobs
  MicroBrain Technologies Inc.
    The Netherlands

unit U_DateTime;
{
 written by Andre Jakobs  from  MicroBrain Technologies Inc.


This Unit Converts UNIX timestamps and Delphi timestamps

Unix stores the TimeDate in a four byte long-integer(DoubleWord), As
the number of seconds since 1-januari-1970 0:0:0 .....

Delphi stores the TimeDate in TDateTime (a Float), where the integer
part of TDateTime type is the Number of days since 1-januari-0001 0:0:0
and the floating-point part the fractional Part of the day}

interface

const
    UnixStartDate : tdatetime = 719163.0;

function DelphiDateTimeToUnix(ConvDate:TdateTime):longint;
function UnixToDelphiDateTime(USec:longint):TDateTime;

implementation

(*-----------------------------------------------------------*)
(*         D e l p h i D a t e T i m e T o U N I X           *)
(*-----------------------------------------------------------*)
function DelphiDateTimeToUnix(ConvDate:TdateTime):longint;
{Converts Delphi TDateTime to Unix seconds,
   ConvDate = the Date and Time that you want to convert
   example:   UnixSeconds:=DelphiDateTimeToUnix(Now);}
begin
  Result:=round((ConvDate-UnixStartDate)*86400);
 end;

(*-----------------------------------------------------------*)
(*         U N I X T o D e l p h i D a t e T i m e           *)
(*-----------------------------------------------------------*)
function UnixToDelphiDateTime(USec:longint):TDateTime;
{Converts Unix seconds to Delphi TDateTime,
   USec = the Unix Date Time that you want to convert
   example:  DelphiTimeDate:=UnixToDelphiTimeDate(693596);}
begin
  Result:=(Usec/86400)+UnixStartDate;
 end;

end.

