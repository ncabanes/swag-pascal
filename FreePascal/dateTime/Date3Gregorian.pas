(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0004.PAS
  Description: DATE3.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

Program Gregorian;              { Julian day to Gregorian date      }
Uses    Crt;                    { Turbo/Quick Pascal                }
Type    String3         = String[3];
        String9         = String[9];
Const   MonthName       : Array [1..12] of String3 =
                          ('Jan','Feb','Mar','Apr','May','Jun',
                           'Jul','Aug','Sep','Oct','Nov','Dec');
        DayName         : Array [1..7] of String9 =
                          ('Sunday','Monday','Tuesday','Wednesday',
                           'Thursday','Friday','Saturday');
Var     Day, JulianDay, F       : Real;
        Month                   : Byte;
        Year                    : Integer;
        A, B, C, D, E, G, Z     : LongInt;
        LeapYear                : Boolean;

Function DayofWeek( Month : Byte; Day : Real; Year : Integer ): Byte;
        Var     iVar1, iVar2    : Integer;
        begin
                iVar1 := Year MOD 100;
                iVar2 := TRUNC( Day ) + iVar1 + iVar1 div 4;
                Case Month of
                        4, 7    : iVar1 := 0;
                        1, 10   : iVar1 := 1;
                        5       : iVar1 := 2;
                        8       : iVar1 := 3;
                        2,3,11  : iVar1 := 4;
                        6       : iVar1 := 5;
                        9,12    : iVar1 := 6;
                        end; {Case}
                iVar2 := ( iVar1 + iVar2 ) MOD 7;
                if ( iVar2 = 0 ) then iVar2 := 7;
                DayofWeek := Byte( iVar2 );
        end; {DayofWeek}

Function DayofTheYear( Month : Byte; DAY : Real ): Integer;
        Var     N       : Integer;
        begin
                if LeapYear  then N := 1  else N := 2;
                N := 275 * Month div 9
                     - N * (( Month + 9 ) div 12)
                     + TRUNC( Day ) - 30;
                DayofTheYear := N;
        end; {DayofTheYear}

begin   {Gregorian}
        ClrScr;
        WriteLn('Gregorian dates v0.0 Dec.91 Greg Vigneault');
        WriteLn('[Enter Julian day values]');

        Repeat  WriteLn;
                Write('Enter (positive) Julian day number: ');
                ReadLn( JulianDay );
        Until   ( JulianDay >= 706.0 );

        JulianDay := JulianDay + 0.5;
        Z := TRUNC( JulianDay );   F := FRAC( JulianDay );

        if ( Z < 2299161 )
        then    A := Z
        else    begin   G := TRUNC( ( Z - 1867216.25 ) / 36524.25);
                        A := Z + 1 + G - G div 4;
                end; {if}

        B := A + 1524;  C := TRUNC( ( B - 122.1 ) / 365.25 );
        D := TRUNC( 365.25 * C );  E := TRUNC( ( B - D ) / 30.6001 );

        Day := B - D - TRUNC( 30.6001 * E ) + F;

        if ( E < 13.5 )
        then Month := Byte( E - 1 )
        else if ( E > 13.5 ) then Month := Byte( E - 13 );

        if ( Month > 2.5 )
        then Year := Integer( C - 4716 )
        else if ( Month < 2.5 ) then Year := Integer( C - 4715 );

        if ((Year MOD 100)<>0) and ((Year MOD 4)=0)
                then    LeapYear := True
                else    LeapYear := False;

        Write(#10,'Gregorian '); if LeapYear then Write('LeapYear ');
        WriteLn('date is ',DayName[DayofWeek(Month,Day,Year)],
                ', ',MonthName[ Month ],' ',Day:2:2,',',Year:4,
                 ' (day of year= ',DayofTheYear(Month,Day),')',#10);
end. {Gregorian}
