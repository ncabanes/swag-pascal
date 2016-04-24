(*
  Category: SWAG Title: ANSI CONTROL & OUTPUT
  Original name: 0004.PAS
  Description: Direct ANSI Display
  Author: DUSTIN NULF
  Date: 05-28-93  13:33
*)

{
DUSTIN NULF

I've run into that familiar problem in trying to view Ansi colored pictures and
using the Crt Unit at the same time.  The Crt Unit
doesn't translate the Ansi codes and displays them literally.  Now,
I've created an Ansi interpreter Procedure that reads each line in
an ansi File and calls the appropriate TextColor/TextBackground Procedures,
according to what ansi escape String was found.  This
is groovy and all, but I just found out something new today With:
}
Assign(Output,'');
ReWrite(Output);
{
...and that it translates all the ansi codes For me already!  Now,
the big question is, what are the advantages and disadvantages
of using this Assign method vs. the Ansi interpreter method?  Is
this Assign method slower/faster, take up more memory, more disk
space, etc.  Any information would be highly appreciated! :)
}

