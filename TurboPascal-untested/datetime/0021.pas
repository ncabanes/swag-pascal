===========================================================================
 BBS: The Beta Connection
Date: 06-07-93 (00:10)             Number: 773
From: CYRUS PATEL                  Refer#: 744
  To: STEPHEN WHITIS                Recvd: NO  
Subj: DATE CALCULATIONS              Conf: (232) T_Pascal_R
---------------------------------------------------------------------------
SW>Does anyone know where I can find an algorithm, or better yet TP
SW>5.5 code, to calculate the day of the week for a give date?

Here's TP source for day of the week...

Const
   CurrentYear = 1900;

Type
   DateStr: String[8];


Procedure ConvDate(DateStr: DateRecord;
                   Var Month, Day, Year: Word);

 {this converts the date from string to numbers for month, day, and year}

  Var
    ErrorCode: Integer;

  Begin
    Val(Copy(DateStr, 1, 2), Month, ErrorCode);
    Val(Copy(DateStr, 4, 2), Day, ErrorCode);
    Val(Copy(DateStr, 7, 2), Year, ErrorCode);
    Year := Year + CurrentYear
  End;


Function Dow(DateStr: DateRecord): Byte;

   {this returns the Day Of the Week as follows:
         Sunday is 1, Monday is 2, etc...  Saturday is 7}

  Var
    Month, Day, Year, Y1, Y2: Word;

  Begin
    ConvDate(DateStr, Month, Day, Year);
    If Month < 3 then
      Begin
      Month := Month + 10;
      Year := Year - 1
      End
    else
      Month := Month - 2;
    Y1 := Year Div 100;
    Y2 := Year Mod 100;
    Dow := ((Day + Trunc(2.6 * Month - 0.1) + Y2 + Y2 Div 4 + Y1 Div 4 - 2 *
           Y1 + 49) Mod 7) + 1
  End;


Here's an example of how to use it...

Begin
   Case Dow('06/06/93') of
     1: Write('Sun');
     2: Write('Mon');
     3: Write('Tues');
     4: Write('Wednes');
     5: Write('Thurs');
     6: Write('Fri');
     7: Write('Satur')
   End;
   WriteLn('day')
End.


SW>And I just know I've run across an algorithm or code to do this
SW>before, but it was a while back, and I've looked in the places I
SW>thought it might have been.  Any ideas?

You might want to take a look at Dr. Dobbs from a few months back
(earlier this year), they had an whole issue related to dates

Cyrus
---
 ■ SPEED 1·30 #666 ■ 2!  4!  6!  8!  It's time to calculate!  2 24 720 40,32
 * Midas Touch of Chicago 312-764-0591/0761 DUAL STD
 * PostLink(tm) v1.06  MIDAS (#887) : RelayNet(tm) Hub
