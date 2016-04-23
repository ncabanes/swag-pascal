{*******************************************************************}
Program File_Date_Time_Demo;    { Aug 21/93, Greg Estabrooks.       }
USES CRT,                          { Clrscr,}
     DOS;                          { GetFTime, UnPackTime, DateTime,}

VAR
   FileName :STRING[12];           { Holds the name of file to check}
   F        :FILE;                 { Holds file handle.             }
   FileT    :LONGINT;
   FTime    :DateTime;

BEGIN
  Clrscr;                          { Clear the screen up.           }
  FileName := ParamStr(1);         { Get name of file name.         }
  IF Length(FileName) = 0 THEN     { If no name send error msg.     }
    Writeln('FileName must be specified!',^G)
  ELSE
    BEGIN
      Assign(F,FileName);          { Assign handle to F.            }
      Reset(F);                    { Open File.                     }
      GetFTime(F,FileT);           { Get the Time and Date for file.}
      Close(F);                    { Close The File.                }
      UnPackTime(FileT,FTime);     { Unpack the time+date into fTime}
      Write(' File : ',FileName);  { Display Info for user.         }
      Write(' was last modified on ');
      Write(FTime.Month,'-',FTime.Day,'-',FTime.Year,' at ');
      Write(FTime.Hour,':',FTime.Min,':',FTime.Sec);
    END;{IF}
END.{File_Date_Time_Demo}
{*******************************************************************}
