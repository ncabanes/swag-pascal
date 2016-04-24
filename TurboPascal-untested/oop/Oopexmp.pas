(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0008.PAS
  Description: OOP-EXMP.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

{
  I am trying to teach myself about Object orientated Programming and about
'inheritence'. This is my code using Records.

Have a look at 'Mastering Turbo Pascal 6' by tom Swan, pg. 584 and on.
Briefly, without Objects, code looks like this:
}

DateRec = Record
  Month: Byte;
  day:   Byte;
  year:  Word;
end;

Var
  today: DateRec;

begin
  With today do
  begin
   month:= 6;
   day  := 6;
   year := 1992;
  end;
...
more code..
end.

With Objects, code looks like this:

Type
  DateObj = Object
    month: Byte;                   {note data and methods are all}
    day:   Byte;                   {part of the Object together  }
    year:  Word;
    Procedure Init(MM, DD, YY: Word);
    Function StringDate: String;
  end;

Var
  today: DateObj;

Procedure DateObj.Init(MM, DD, YY: Word); {always need to initialise}
begin
  Month:= MM;
  Day  := DD;
  year := YY;
end;

Function DateObj.StringDate: String;
Var
  MStr, Dstr, YStr: String[10];
begin
  Str(Month, MStr);
  Str(Day, DStr);
  Str(Year, YStr);
  StringDate := MStr + '/' + DStr + '/' + YStr
end;

begin         {begin main Program code}
  today.Init(6,6,1992);
  Writeln('The date is ', today.StringDate)
  Readln
..
other code..
end.

Hope this helps.  Read all the example code you can, and try the Turbo-
vision echo (not yet on Fidonet, but nodes were listed on here
recently).  You can fidonet sysop Pam Lagier at TurboCity BBS 1:208/2
For a node list.

