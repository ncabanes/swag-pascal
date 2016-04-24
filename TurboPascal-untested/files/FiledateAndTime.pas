(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0047.PAS
  Description: Filedate and Time
  Author: GREG ESTABROOKS
  Date: 02-03-94  10:57
*)

{
ET>How can I change the file's date and time without opening that file??
ET>I appreciate (some) example source code, so I can look how it is done.
ET>Thanks.

 In order to change a files date/timestamp you'll have open the file
 whether you use the TP SetFTime routine or use Int 21h Function 5701
 BUT by Opening it for reading you can change it to whatever you want.
 If you open it for writing then the TimeStamp will automatically be
 changed to whatever the time was when you closed it.

 Here's a little demo that changes the files timestamp to whatever the
 current time is:
 (NOTE this does not test for existance of the file before settingthe time.)}

{*******************************************************************}
PROGRAM SetFileDateAndTimeDemo; { Jan 8/93, Greg Estabrooks.        }
USES CRT,                       { IMPORT Clrscr,Writeln.            }
     DOS;                       { IMPORT SetFTime,PackTime,DateTime,}
                                { GetTime,GetDate.                  }
VAR
   Hour,Min,Sec,Sec100 :WORD;   { Variables to hold current time.   }
   Year,Mon,Day,DayoW  :WORD;   { Variables to hold current date.   }
   F2Change :FILE;              { Handle for file to change.        }
   NewTime  :LONGINT;           { Longint Holding new Date/Time.    }
   FTime    :DateTime;          { For use with packtime.            }
BEGIN
  Clrscr;                       { Clear the screen.                 }
  GetTime(Hour,Min,Sec,Sec100); { Get Current System Time.          }
  GetDate(Year,Mon,Day,DayoW);  { Get Current System Date.          }
  FTime.Year := Year;           { Assign new year.                  }
  FTime.Month:= Mon;            { Assign new month.                 }
  FTime.Day := Day;             { Assign New Day.                   }
  FTime.Hour:= Hour;            { Assign New hour.                  }
  FTime.Min := Min;             { Assign New Minute.                }
  FTime.Sec := Sec;             { Assign New Seconds.               }
  PackTime(FTime,NewTime);      { Now covert Time/Date to a longint.}
  Assign(F2Change,ParamStr(1)); { Assign file handle to file to change.}
  Reset(F2Change);              { Open file for reading.            }
  SetFTime(F2Change,NewTime);   { Now change to our time.           }
  Close(F2Change);              { Close File.                       }
END.{SetFileDateAndTimeDemo}
{*******************************************************************}

