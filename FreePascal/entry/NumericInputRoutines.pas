(*
  Category: SWAG Title: INPUT AND FIELD ENTRY ROUTINES
  Original name: 0030.PAS
  Description: Numeric Input Routines
  Author: LEE BARKER
  Date: 02-21-96  21:03
*)


var i : word;

{ Simple error checking }
function Getnbr1 (msg:string) : word;
  var w : word;
  begin
    repeat
      write(msg);
      {$I-} readln(w); {$I+}
    until ioresult=0;
    Getnbr1 := w;
  end;

{ fancier error checking }
function Getnbr2 (msg:string) : word;
  var x : longint;
      s : string;
      {w : word;}
      i : integer;
  begin
    repeat
      write(msg);
      readln(s);
      val(s,x,i);
    until (i=0) and (x>=0) and (x<=65535);
    getnbr2 := x;
  end;

begin
  i := getnbr1('Please enter a number? '); writeln(i);
  i := getnbr2('Please enter a number? '); writeln(i);
end.

