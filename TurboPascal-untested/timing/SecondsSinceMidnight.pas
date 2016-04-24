(*
  Category: SWAG Title: TIMER/RESOLUTION ROUTINES
  Original name: 0038.PAS
  Description: Re: seconds since midnight
  Author: BRIAN PETERSEN
  Date: 02-21-96  21:04
*)

{
I tried this but the two (my original procedure and your code) produce
slightly different values.  Compile this and run in DOS:
}
uses dos;

function timer:real;
var r:registers; h,m,s,t:real;
begin
  r.ax:=44*256;
  msdos(dos.registers(r));
  h:=(r.cx div 256);
  m:=(r.cx mod 256);
  s:=(r.dx div 256);
  t:=(r.dx mod 256);
  timer:=h*3600+m*60+s+t/100;
end;

function timer2:real;
begin
  timer2:=meml[$0040:$006c]/18.2;
end;

begin
  write(^M^J'Ctrl-Break to Quit'^M^J^M^J+
        'Int 21h Version  $0040:$006C Version'^M^J+
        '---------------  -------------------'^M^J);
  repeat
    write(timer2:3:5,'      ',timer:3:5,^M);
  until false=true;
end.

... and tell me if you notice the difference as well.  I tried swapping
the timer and timer2 positions in the write() function to see if it was
just the difference between the time the two functions are executed and
it was not caused by that.

brian.petersen@604.sasbbs.com

{
 BP> Could someone please convert this to BASM?  It returns the number of
 BP> seconds since midnight in the form of a real variable.

 BP> function timer:real;
 BP> var r:registers; h,m,s,t:real;
 BP> begin
 BP>   r.ax:=$2c00;
 BP>   msdos(r);
 BP>   h:=(r.cx div 256);
 BP>   m:=(r.cx mod 256);
 BP>   s:=(r.dx div 256);
 BP>   t:=(r.dx mod 256);
 BP>   timer:=h*3600+m*60+s+t/100;
 BP> end;
}
I think, that's the way it should be optimized (and corrected). Everything
else would be overkill:
    function timer:longint;
    { returns number of 1/100 s since midnight }
    var dostime:record t,s,m,h:byte end;
    begin
      asm
        mov ax, 2c00h
        int 21h
        mov word ptr dostime.m, cx
        mov word ptr dostime.t, dx
      end;
      with dostime do
        timer:=(longint(h*60+m)*60+s)*100+t
    end;


