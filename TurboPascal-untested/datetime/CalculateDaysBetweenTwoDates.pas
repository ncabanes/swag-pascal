(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0048.PAS
  Description: Calculate Days between two Dates
  Author: MICHAEL HOENIE
  Date: 11-26-94  04:59
*)

{
Allright... I checked around a lot of DATE and TIME routines, and came up
with this, taken from about three different routines. This routine works,
as far as I know, and I've implemented it successfully into my own code.
If anyone knows that this routine has a bug in it, please let me know.

This procedure uses the Julian calander mathmatical equasions to convert
two dates and give the # of days inbetween. If anyone knows a faster way
of writing this procedure, please let me know.
}

type
  string80=string[80];

var
  _retval:integer;

procedure check_date(stream1,stream2:string80);
var
  internal1,internal2:longint;
  JNUM:real;
  cd,month,day,year: integer;
  out:string[25];

    function Jul( mo, da, yr: integer): real;
    var
      i, j, k, j2, ju: real;
    begin
         i := yr;     j := mo;     k := da;
         j2 := int( (j - 14)/12 );
         ju := k - 32075 + int(1461 * ( i + 4800 + j2 ) / 4 );
         ju := ju + int( 367 * (j - 2 - j2 * 12) / 12);
         ju := ju - int(3 * int( (i + 4900 + j2) / 100) / 4);
         Jul := ju;
    end;

begin
  out:=copy(stream1,1,2);
  if copy(out,1,1)='0' then delete(out,1,1);
  val(out,month,cd);
  out:=copy(stream1,4,2);
  if copy(out,1,1)='0' then delete(out,1,1);
  val(out,day,cd);
  out:=copy(stream1,7,2);
  if copy(out,1,1)='0' then delete(out,1,1);
  val(out,year,cd);
  jnum:=jul(month,day,year);
  str(jnum:10:0,out);
  val(out,internal1,cd);
  out:=copy(stream2,1,2);
  if copy(out,1,1)='0' then delete(out,1,1);
  val(out,month,cd);
  out:=copy(stream2,4,2);
  if copy(out,1,1)='0' then delete(out,1,1);
  val(out,day,cd);
  out:=copy(stream2,7,2);
  if copy(out,1,1)='0' then delete(out,1,1);
  val(out,year,cd);
  jnum:=jul(month,day,year);
  str(jnum:10:0,out);
  val(out,internal2,cd);
  _retval:=internal1-internal2;
end;

begin
  check_date('01-01-95','01-01-94');
  writeln('The # of days inbetween is = ',_retval);
end.

