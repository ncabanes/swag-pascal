(*
  Category: SWAG Title: TEXT EDITING ROUTINES
  Original name: 0006.PAS
  Description: Word Wrap #3
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  14:08
*)

Var
  S : String;

Function Wrap(Var st: String; maxlen: Byte; justify: Boolean): String;
  { returns a String of no more than maxlen Characters With the last   }
  { Character being the last space beFore maxlen. On return st now has }
  { the remaining Characters left after the wrapping.                  }
  Const
    space = #32;
  Var
    len      : Byte Absolute st;
    x,
    oldlen,
    newlen   : Byte;

  Function JustifiedStr(s: String; max: Byte): String;

    { Justifies String s left and right to length max. if there is more }
    { than one trailing space, only the right most space is deleted. The}
    { remaining spaces are considered "hard".  #255 is used as the Char }
    { used For padding purposes. This will enable easy removal in any   }
    { editor routine.                                                   }

    Const
      softSpace = #255;
    Var
      jstr      : String;
      len       : Byte Absolute jstr;
    begin
      jstr := s;
      While (jstr[1] = space) and (len > 0) do   { delete all leading spaces }
        delete(jstr,1,1);
      if jstr[len] = space then
        dec(len);                                { Get rid of trailing space }
      if not ((len = max) or (len = 0)) then begin
        x := pos('.',jstr);     { Attempt to start padding at sentence break }
        if (x = 0) or (x =len) then       { no period or period is at length }
          x := 1;                                    { so start at beginning }
        if pos(space,jstr) <> 0 then Repeat        { ensure at least 1 space }
          if jstr[x] = space then                      { so add a soft space }
            insert(softSpace,jstr,x+1);
          x := succ(x mod len);  { if eoln is reached return and do it again }
        Until len = max;        { Until the wanted String length is achieved }
      end; { if not ... }
      JustifiedStr := jstr;
    end; { JustifiedStr }


  begin  { Wrap }
    if len <= maxlen then begin                       { no wrapping required }
      Wrap := st;
      len  := 0;
    end else begin
      oldlen := len;                { save the length of the original String }
      len    := succ(maxlen);                        { set length to maximum }
      Repeat                     { find last space in st beFore or at maxlen }
        dec(len);
      Until (st[len] = space) or (len = 0);
      if len = 0 then                   { no spaces in st, so chop at maxlen }
        len := maxlen;
      if justify then
        Wrap := JustifiedStr(st,maxlen)
      else
        Wrap := st;
      newlen :=  len;          { save the length of the newly wrapped String }
      len := oldlen;              { and restore it to original length beFore }
      Delete(st,1,newlen);              { getting rid of the wrapped portion }
    end;
  end; { Wrap }

begin
  S :=
'By Far the easiest way to manage a database is to create an '+
'index File. An index File can take many Forms and its size will depend '+
'upon how many Records you want in the db. The routines that follow '+
'assume no more than 32760 Records.';

While length(S) <> 0 do
  Writeln(Wrap(S,60,True));
end.
{
Whilst this is tested and known to work on the example String, no further
testing than that has been done.  I suggest you test it a great deal more
beFore being satisfied that it is OK.
}
