(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0022.PAS
  Description: Clock Ticks
  Author: STEVE ROGERS
  Date: 08-25-94  09:12
*)

{
PN>Hi, Steve. I know this has been asked before, but am thinking
  >of using TicksSinceMidnight which is at memory location $0040:006C
  >as you say. Ny question is to what kind of type (size) variable should
  >I assign this to, and how many bytes are reserved for this number?
  >$0040:006C ..  $0040:006D  ????
  >word? longint? integer?
                                           .
  60 * 60 * 24 = 86400 seconds per day.   . .  a longint is needed.
}
  var
    TickSinceMidnight : longint ABSOLUTE $0040:$006c;
{
  BTW, that second $ is important :)


  >I appreciate your help. I'm going to try to get a 10ths seconds
  >counter going by test-running the number of ticks in a second. Or words
  >to that effect.

  There are approximately 18.2 ticks per second (thanks, Spock :)
}

