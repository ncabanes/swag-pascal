(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0017.PAS
  Description: TIME2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

{ PW>question, I want to declare Type Time as (Hour,Min).  Where hour and
 PW>minute are predeifed Types 0..23 and 0..59 respectively.  I then take
 PW>the Type Time and use it as a field in a Record.  How would I promt a
 PW>user to enter the time?  Ie. Enter (date,min): ???  Is there a way to do
 PW>this without reading a String and then Formatting it and changing it to
 PW>Integers?
}
   It can be done, but it's probably not worth the efFort to process it that
way. I do this a lot, and I allow entering the Time as hh:mm or hhmm, where
it's simply a String.  then, I parse out the ":", if it exists, and do a couple
of divide and mod operations to then convert it to seconds - and store it that
way.  I also have a routine which will Format seconds into time.  I do this
enough (I'm in the race timing business), that I've found it easy to do this
throughout my system - and keep all data in seconds.  I have a
parsing/conversion routine and a conversion/display routine in my global Unit.
Something like this:

Var S     : String;
    I,T,N : Word;

  Write ('Enter Time as hh:mm '); readln (S);
  if Pos(':',S) > 0 then Delete (S,Pos(':',S),1); Val (S,I,N);
  T := ((I div 100) * 3600) + ((I mod 100) * 60);

   There should be some error-checking in this, but I'm sure you can figure it
out...

