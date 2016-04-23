
> I am currently trying to create a calendar that will ask the
> user to input a year and month.  The program should print out that
> particular month.  I believe I have a design I would like to follow,
> but I cant figure out the formula to figure out the first day of the
> month for any year between 1900-2000.

I have something more general from my class. Here it is:

  A. Take the last two digits of the year
  B. Add a quarter of this number (neglect the remainder)
  C. Add the day of the month
  D. Add according to the month:
     Jan 1    Feb 4    March 4    April 0    May 2    June 5
     July 0   Aug 3    Sept  6    Oct   1    Nov 4    Dec  6
  E. Add for century
       18th 4                   20th 0
       19th 2                   21st 6
  F. Divide total by 7
  G. The remainder gives day of week:
     Sunday       1
     Monday       2
     Tuesday      3
     Wednesday    4
     Thursday     5
     Friday       6
     Saturday     0

This should work for any day between the years 1700-2099. Maybe you
could figure out the exact formula you needed from this.

