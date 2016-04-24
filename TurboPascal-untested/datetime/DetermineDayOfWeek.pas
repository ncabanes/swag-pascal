(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0061.PAS
  Description: Determine Day of week
  Author: BRAD PRENDERGAST
  Date: 08-30-97  10:08
*)

{ ***********************************************************************
  *  Program : Dayweek.PAS                                              *
  *  Compilation: Turbo Pascal 7.0                                      *
  *  Written By: Brad Prendergast                                       *
  *  Date: 1995                                                         *
  *  Descriprion:                                                       *
  *    This program is a short little utility to determine the day of   *
  *    the week a particular day falls on.  All input must be integers. *
  *    There is no error checking configured into this program.         *
  ***********************************************************************}

PROGRAM Day;

  USES Crt;

  PROCEDURE Figure_Day;

    CONST
      con : ARRAY [0..6] OF STRING= ('Sunday', 'Monday', 'Tuesday',
                                     'Wednesday', 'Thursday', 'Friday',
                                     'Saturday' );
    VAR
      f,
      m,
      y,
      d,
      tot : INTEGER;

  BEGIN
    WRITELN;
    TextColor ( LightBlue);
    WRITE ( 'Enter month   (i.e. MM)  : ');
    TextColor ( Magenta );
    READLN ( m );
    TextColor ( LightBlue );
    WRITE ( 'Enter the day (i.e. DD)  : ');
    TextColor ( Magenta );
    READLN ( d );
    TextColor ( LightBlue );
    WRITE ( 'Enter Year    (i.e. YYYY): ');
    TextColor ( Magenta );
    READLN ( y );
    TextColor ( LightGreen );
    IF m < 3 THEN
      F := 365 * y + d + 31 * (m - 1) + trunc ((y - 1) / 4) -
           trunc (0.75 * trunc ((y - 1) / 100) + 1)
    ELSE
    f := 365 * y + d + 31 * (m - 1) - trunc (0.4 * m + 2.3) +
         trunc (y / 4) - trunc (0.75 * trunc (y / 100) + 1);
    tot := f MOD 7;

    WRITELN ( 'Day of week : ', con[tot] );
  END;

BEGIN
  Clrscr;
  Figure_Day;
  READLN;
END.
