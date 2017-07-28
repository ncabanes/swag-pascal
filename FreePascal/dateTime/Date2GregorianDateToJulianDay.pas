(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0003.PAS
  Description: DATE2.PAS
  Author: GREG VIGNEAULT
  Date: 05-28-93  13:37
*)

{DF> I need an accurate method of converting back and Forth between
  > Gregorian and Julian dates.

 if you mean the True Julian day, as used in astronomy ...
}

Program JulianDate;                 { Gregorian date to Julian day  }

Uses    Crt;                        { Turbo/Quick Pascal            }
Var     Month, Year, greg       : Integer;
        Day, JulianDay          : Real;
        LeapYear, DateOkay      : Boolean;
begin
    ClrScr;
    WriteLn( 'Julian Dates v0.1 Dec.20.91 G.Vigneault' );
    WriteLn( '[Enter Gregorian calendar values]');
    WriteLn;
    { A.D. years entered normally, B.C. years as negative }
    Write( 'Enter Year (nnnn For A.D., -nnnn For B.C.): ' );
    ReadLn( Year );
    LeapYear := False;      { assume not }
    if ((Year MOD 4)=0)     { possible LeapYear? }
        then if ((Year MOD 100)<>0)  { LeapYear if not century }
             or ((Year MOD 100)=0) and ((Year MOD 400)=0)
             then LeapYear := True;
    Repeat
        Write( 'Enter Month (1..12): ' );
        ReadLn( Month );
    Until ( Month < 13 ) and ( Month > 0 );

    WriteLn('Julian Days begin at Greenwich mean noon (12:00 UT)');
    DateOkay := False;
    Repeat
    Write( 'Enter Day (1.0 <= Day < 32.0): ' );
    ReadLn( Day );          {may be decimal to include hours}
    if ( Day >= 1.0 ) and ( Day < 32.0 )
        then Case Month of
                1,3,5,7,8,10,12 : if Day < 32.0 then DateOkay := True;
                4,6,9,11        : if Day < 31.0 then DateOkay := True;
                2               : if ( Day < 29.0 ) or
                                     ( Day < 30.0 ) and LeapYear
                                  then DateOkay := True
                                  else  WriteLn('not a leapyear!');
                end; {Case}
        if not DateOkay then Write( #7 );       { beep }
        Until DateOkay;

        (* here is where we start calculation of the Julian Date *)

        if Month in [ 1, 2 ]
        then    begin
                        DEC( Year );
                        inC( Month, 12 )
                end;

        { account For Pope Gregory's calendar correction, when }
        { the day after Oct.4.1582 was Oct.15.1582 }

        if ( Year < 1582 ) or
           ( Year = 1582 ) and ( Month < 10 ) or
           ( Year = 1582 ) and ( Month = 10 ) and ( Day <= 15 )
        then    greg := 0       { Oct.15.1582 or earlier }
        else    begin           { Oct.16.1582 or later }
                        greg := TRUNC( Year div 100 );
                        greg := 2 - greg + TRUNC( greg div 4 );
                end;

        if ( Year >= 0 )         { circa A.D. or B.C. ? }
                then  JulianDay := inT( 365.25 * Year )         {AD}
                else  JulianDay := inT( 365.25 * Year - 0.75 ); {BC}

        JulianDay := JulianDay
                   + inT( 30.6001 * ( Month + 1 ) )
                   + Day
                   + 1720994.5
                   + greg;

        WriteLn;
        WriteLn( 'Equivalent Julian date is : ', JulianDay:8:2 );
        WriteLn;
end. {JulianDate}

