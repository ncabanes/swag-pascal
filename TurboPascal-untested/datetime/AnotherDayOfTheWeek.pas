(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0022.PAS
  Description: Another Day of the Week
  Author: KELLY SMALL
  Date: 06-22-93  09:13
*)

===========================================================================
 BBS: The Beta Connection
Date: 06-07-93 (18:50)             Number: 823
From: KELLY SMALL                  Refer#: 744
  To: STEPHEN WHITIS                Recvd: NO  
Subj: DATE CALCULATIONS              Conf: (232) T_Pascal_R
---------------------------------------------------------------------------
 SW│ Does anyone know where I can find an algorithm, or better yet TP
 SW│ 5.5 code, to calculate the day of the week for a give date?

Give this a whirl:

function LeapYearOffset(M,Y:Word):Integer;
  Begin
  if ((Y mod 400 = 0) or ((Y mod 100 <> 0) and (Y mod 4 = 0)))
        and (M > 2)
    then LeapYearOffset := 1
    else LeapYearOffset := 0
  End;

Function DaysinMonth(dMonth,dYear:Word):Byte;
  Begin
  case dMonth of
    1,3,5,7,8,10,12 : DaysInMonth := 31;
    4,6,9,11        : DaysInMonth := 30;
    2               : DaysInMonth := 28 + LeapYearOffset(3,dYear)
    End;
  End;

Function FindDayOfWeek(Day, Month, Year: Integer) : Byte;
var
  century, yr, dw: Integer;
begin
  if Month < 3 then
  begin
    Inc(Month, 10);
    Dec(Year);
  end
  else
     Dec(Month, 2);
  century := Year div 100;
  yr := year mod 100;
  dw := (((26 * month - 2) div 10) + day + yr + (yr div 4) +
    (century div 4) - (2 * century)) mod 7;
  if dw < 0 then FindDayOfWeek := dw + 7
  else FindDayOfWeek := dw;
end;

      ⌠/elly
      ⌡mall

---
 ■ JABBER v1.2 #18 ■ Bigamy: too many wives. Monogamy: see Bigamy
                                            ■ KMail 2.94  The Wish Book BBS (60
2)258-7113 (6+ nodes, ring down)
 * The Wish Book 602-258-7113(6 lines)10+ GIGs/The BEST board in Arizona!
 * PostLink(tm) v1.06  TWB (#1032) : RelayNet(tm)

