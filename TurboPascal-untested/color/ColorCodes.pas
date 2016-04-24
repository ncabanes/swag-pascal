(*
  Category: SWAG Title: TEXT/GRAPHICS COLORS
  Original name: 0021.PAS
  Description: Color Codes
  Author: MICHAEL HOENIE
  Date: 05-26-94  06:18
*)

{
 ├─>I would like to implement color codes into my on-line doors.  You know
 ├─>the type that Wildcat or PCB have.  The @ codes.  Does anyone have a
 ├─>routine that would (I assume) read in a file bite by bite and when it
 ├─>comes across the @ char it would read the next 3 bits and determine what
 ├─>action to take?

Hi Larry! Sure do have one for 'ya!

Try this one out for size. It can be optimized to be smaller, but as an
example, this one works for sure! You'll have to incorporate it into your
code to dump out to the modem (no problem I hope!)

Give this a try: }

  type
    string255=string[255];

  procedure outgoing(stream:string255; ret:integer);
  var
    _retval:integer;
    out,out1:string[5];
  begin
    for _retval:=1 to length(stream) do
      begin
        out:=copy(stream,_retval,1);
        case out[1] of
          '@':begin { COLOR CODE    ---> @X1F or other }
                out1:=copy(stream,_retval+2,1);
                case out1[1] of
                  '0':textbackground(0);
                  '1':textbackground(1);
                  '2':textbackground(2);
                  '3':textbackground(3);
                  '4':textbackground(4);
                  '5':textbackground(5);
                  '6':textbackground(6);
                  '7':textbackground(7);
                  '8':textbackground(8);
                  '9':textbackground(9);
                  'A':textbackground(10);
                  'B':textbackground(11);
                  'C':textbackground(12);
                  'D':textbackground(13);
                  'E':textbackground(14);
                  'F':textbackground(15);
                end;
                out1:=copy(stream,_retval+3,1);
                case out1[1] of
                  '0':textcolor(0);
                  '1':textcolor(1);
                  '2':textcolor(2);
                  '3':textcolor(3);
                  '4':textcolor(4);
                  '5':textcolor(5);
                  '6':textcolor(6);
                  '7':textcolor(7);
                  '8':textcolor(8);
                  '9':textcolor(9);
                  'A':textcolor(10);
                  'B':textcolor(11);
                  'C':textcolor(12);
                  'D':textcolor(13);
                  'E':textcolor(14);
                  'F':textcolor(15);
                end;
                _retval:=_retval+3;
              end;
          else write(out[1]);
        end;
      end;
    if ret=2 then writeln;
  end;


