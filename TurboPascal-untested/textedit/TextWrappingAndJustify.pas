(*
  Category: SWAG Title: TEXT EDITING ROUTINES
  Original name: 0007.PAS
  Description: Text Wrapping and Justify
  Author: SWAG SUPPORT TEAM
  Date: 08-17-93  08:51
*)

Uses CRT;
var
  S : string;

function Wrap(var st: string; maxlen: byte; justify: boolean): string;
  { returns a string of no more than maxlen characters with the last   }
  { character being the last space before maxlen. On return st now has }
  { the remaining characters left after the wrapping.                  }
  const
    space = #32;
  var
    len      : byte absolute st;
    x,
    oldlen,
    newlen   : byte;

  function JustifiedStr(s: string; max: byte): string;

    { Justifies string s left and right to length max. If there is more }
    { than one trailing space, only the right most space is deleted. The}
    { remaining spaces are considered "hard".  #255 is used as the char }
    { used for padding purposes. This will enable easy removal in any   }
    { editor routine.                                                   }

    const
      softSpace = #255;
    var
      jstr      : string;
      len       : byte absolute jstr;
    begin
      jstr := s;
      while (jstr[1] = space) and (len > 0) do   { delete all leading spaces }
        delete(jstr,1,1);
      if jstr[len] = space then
        dec(len);                                { Get rid of trailing space }
      if not ((len = max) or (len = 0)) then begin
        x := pos('.',jstr);     { Attempt to start padding at sentence break }
        if (x = 0) or (x =len) then       { no period or period is at length }
          x := 1;                                    { so start at beginning }
        if pos(space,jstr) <> 0 then repeat        { ensure at least 1 space }
          if jstr[x] = space then                      { so add a soft space }
            insert(softSpace,jstr,x+1);
          x := succ(x mod len);  { if eoln is reached return and do it again }
        until len = max;        { until the wanted string length is achieved }
      end; { if not ... }
      JustifiedStr := jstr;
    end; { JustifiedStr }


  begin  { Wrap }
    if len <= maxlen then begin                       { no wrapping required }
      Wrap := st;
      len  := 0;
    end else begin
      oldlen := len;                { save the length of the original string }
      len    := succ(maxlen);                        { set length to maximum }
      repeat                     { find last space in st before or at maxlen }
        dec(len);
      until (st[len] = space) or (len = 0);
      if len = 0 then                   { no spaces in st, so chop at maxlen }
        len := maxlen;
      if justify then
        Wrap := JustifiedStr(st,maxlen)
      else
        Wrap := st;
      newlen :=  len;          { save the length of the newly wrapped string }
      len := oldlen;              { and restore it to original length before }
      Delete(st,1,newlen);              { getting rid of the wrapped portion }
    end;
  end; { Wrap }

begin
  S :=
'By far the easiest way to manage a database is to create an '+
'index file. An index file can take many forms and its size will depend '+
'upon how many records you want in the db. The routines that follow '+
'assume no more than 32760 records.';

while length(S) <> 0 do
  writeln(Wrap(S,75,true));
Readkey;
end.

Whilst this is tested and known to work on the example string, no further
testing than that has been done.  I suggest you test it a great deal more
before being satisfied that it is OK.


