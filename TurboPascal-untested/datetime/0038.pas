
{Created by Carlos Beguinge, Sept 12, 1993}
{Program to get the systems date using [GetDate] and allowing you to
  change the date using [SetDate]. Feel free to incorporated into any
  other code, and change it as you wish... Enjoy.}
{P.S. Any changes made to make this code better please post it back to me
  outlining the changes, Thank you.}
 
uses Dos, Crt;
 
const
  days : array [0..6] of String[9] =         {Array of Weekdays set here}
    ('Sunday','Monday','Tuesday',
     'Wednesday','Thursday','Friday',
     'Saturday');
var
  y, m, d, dow, I, Code : Word;              {Setting the variables here}
  changedt, cch : Char;
  flagd, flagm, flagy : boolean;
  ch : String;
 
procedure start(Code: Word); Forward;        {To allow to go forward in a }
                                             {procedure. Used for Error   } 
                                             {Checking.                   }
 
procedure compute;                           {Called from procedure Start }
begin                                        {Moves the numeric string to }
  Val(ch, I, Code);                          {numeric value. then checks  }
    if code <> 0 then                        {for errors. if error true   }
    begin                                    {then Call procedure Start   }
      clrscr;
      Writeln('Error in Date Statement', 'Press any key to Start Again ');
      readln;
      start(Code);
    end;                                     {Else Process Month, Day, and}
    if (flagm = false) then                  {Year.                       }
    begin
      m := I;
      flagm := true;
      write(cch);
      cch :=#0;
    end;
    if (flagd = false) and (cch > #0) then
    begin
      d := I;
      flagd := true;
      write(cch);
      cch :=#0;
      end;
    if (flagy = false) and ( cch > #0) then
    begin
      y := I;
      flagy := true;
      cch :=#13;
    end;
  ch := '';
end;
 
procedure ResetVars;                         {Called from procedure Start }
begin                                        {Resets all variable.        }
  clrscr;
  Code :=0;
  d :=0;
  m :=0;
  y :=0;
  flagd := false;
  flagm := false;
  flagy := false;
  ch :='';
  cch := #0;
end;
 
procedure start;                             {Called from Main Program    }
begin                                        
  ResetVars;                                 {Calls procedure ResetFields }
  while (cch <> #13) do                      {Gets input from the keyboard}
    begin                                    {until a "/" or "Enter is    }
      cch := readkey;                        {pressed.                    }
      while (cch <> #47) and (cch <> #13) do
        begin
          ch := ch + cch;                    {Adds the each numeric charac}
          write(cch);                        {ter to the string variable  }
          cch := readkey;
        end;
      compute;                               {Calls procedure Compute     }
    end;
end;

begin                                        {Main Program which calls    }
  clrscr;                                    {procedure Start             }
  GetDate(y,m,d,dow);
  Writeln('Today is ', days[dow],', ',
          m:0, '/', d:0, '/', y:0);
  Writeln;
  Write('Would you like to change this Date? ');
  readln(changedt);
  if upcase(changedt) ='Y' then
     begin
     start(Code);
     clrscr;
     SetDate(y,m,d);                         {Sets the Date if Changed    }
     Writeln('Today is ', days[dow],', ',
          m:0, '/', d:0, '/', y:0);
     readln;
     end
     else
     begin                                   {Date remains unchanged      }
        Writeln('Today'#39's date Was NOT changed ');
        Writeln('Today is ', days[dow],', ',
           m:0, '/', d:0, '/', y:0);
        readln;
     end;
end.

