{
Here is a program I wrote to see how good my new 387sx co-processor was. It
uses the standard REAL type.
}
program Math_Speed_Test;
{$N-,E-,R-,S-}

uses dos;

var i : longint;
    num1, num2, num3 : real; { or double }
    output : text;
    hou,minu,seco,s100 : word;
    StartClock,
    StopClock : Real;

Procedure ClockOn;

Begin
     GetTime(hou,minu,seco,s100);
     StartClock:=( hou * 3600 ) + ( minu * 60 ) + seco + ( s100 / 100 );
End;

Procedure ClockOff;


Begin
     GetTime(hou,minu,seco,s100);
     StopClock:=( hou * 3600 ) + ( minu * 60 ) + seco + ( s100 / 100 );
     WriteLn(output,'Elapsed Time = ',(StopClock-StartClock):0:2,'s');
End;


begin
     assign(output,'');
     rewrite(output);
     clockon;
{$IFOPT N+}
     writeln(output,'Using 8087 Code');
{$ELSE}
     writeln(output,'Using Software floating point routines');
{$ENDIF}
     for i:=1 to 100000 do
     begin

     num1:=random(60000)/100;
     repeat
     num2:=random(60000)/100;
     until num2>0;
     num3:=num1/num2;

     end;
     clockoff;
     close(output);

end.

And the results.....

Using Software floating point routines
Elapsed Time = 31.03s

Using 8087 Code
Elapsed Time = 8.78s

However, changing REAL to DOUBLE gives

Using 8087 Code
Elapsed Time = 5.50s

I don't want to remove my co-processor, so I can't get the results for
using the emulation library :-). You could compile the program and try it
for yourself.

