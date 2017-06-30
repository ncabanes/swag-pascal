(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0179.PAS
  Description: Percentage Status Bar
  Author: CHRIS EVANS
  Date: 05-31-96  09:17
*)


{ Original compiler directives:
  A+,B+,D+,E+,F-,G+,I+,L+,N+,O-,P-,Q-,R-,S+,T-,V+,X+}
{$M 5000,0,0}
Uses dos, crt;
var ctr, {dd,} cc : integer;

Procedure Statbar(fc, bc : char; ft, bk : integer; cn, en, xs, ys : integer;
          tf : boolean);
var percentage : integer;
begin
     percentage := round(cn / en * 100 / 2); {/2 changed for shorter bars.}
     Gotoxy(xs,ys);
     textcolor(ft);
     For Ctr := 1 to percentage do write(fc);
     textcolor(bk);
     For Ctr := 1 to 50 - percentage do write(bc);
     if tf = true then
        begin
             write(#32, percentage * 2,'%');
        end;
end;

begin
     textbackground(1); clrscr; textcolor(11);
     gotoxy(1,2); Writeln('    Microsoft Scandisk ');
     gotoxy(5,3); For Ctr := 1 to 70 do Write('_');
     gotoxy(5,23); For Ctr := 1 to 70 do Write('_');
     {the below is in my mtbwin.inc ... you can convert it to gotoxy etc..
     button(5, 21, 15, 9, 5,'< Paused >');
     button(18, 21, 15, 9, 5,'< More Info >');
     button(34, 21, 15, 9, 5,'< Exit >');}
     textcolor(7);
     gotoxy(1,5); Writeln('    ScanDisk is now checking the following areas of drive c:');
     writeln;          {√ X}
     cc := 1;
     {the part that controls the starbar/action(s)... }
     Repeat
           Statbar('#','-', 14, 14, cc, 1000, 25, 24, true);
           inc(cc, 1);
           Gotoxy(11, 7); {Pipe('√'); forecolor(7);}
           Case cc of
                150 : Writeln('    DoubleSpace file header          ');
                250 : Writeln('    Directory structure              ');
                330 : Writeln('    File system                      ');
                430 : Writeln('    DoubleSpace file allocation table');
                500 : Writeln('    Compression structure            ');
                750 : Writeln('    Volume signatures                ');
                850 : Writeln('    Boot sector                      ');
               1000 : Writeln('    Surface scan                     ');
           end;
{           for dd := 1 to 34 do write(#8,#32,#8);}
     until cc = 1000
end.

