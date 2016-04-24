(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0242.PAS
  Description: Simple Lightning effect
  Author: NELSON CHU
  Date: 11-29-96  08:21
*)

{ [ Simple lightning effect ]
      By Nelson Chu, 1994

 This is the lightning effect used in my action puzzle game Mixed World.
 Feel free to change this program. If you have any improvement, please
 send me a copy too. Internet e-mail: eg_cshaa@stu.ust.hk

 Sorry that I just encode the .PAL file to be included here. I was too
 lazy to write a set-pal routine to set it on the fly.}

{$A+,R-,S-,N-,L-,O-,D-,X+,G+}
uses graphic, crt;
{Unit GRAPHIC to be found in GRAPHICS.SWG }
var pal : paltype;

procedure Lightning;  { a fractal effect }
var aa : integer;
    a,x,y : byte;

 procedure process( x, y, intensity, dx :integer);
 var part_int, d : byte;

   procedure add(x:word; y, int:byte);
   begin if screen^[y,x]<int then screen^[y,x]:=int; end;

 begin
  while (intensity>0) and (y<200) and (x>1) and (x<319) do
  begin

   add( x+1, y, (intensity-3)*20+50);
   add( x,   y, (intensity)*20+50);
   add( x-1, y, (intensity-2)*20+50);

   if ((random(4)=0)and(y>170)) or
      ((random(4)=0)and(abs(dx)>5))or
       (random(20)=0) then dec(intensity);

   inc(y,1); {go next row every time}

   if dx>0 then dec(x,random(dx)) else inc(x,random(-dx));

   if (abs(dx)<2) then begin dec(x,random(5)+1); dx:=-2; end;
   if (abs(dx)>5) then begin inc(x,random(5)+1); dx:=+2; end;


   if ((y>33)and(random(3)=0)) or (intensity<4) then {split}
   begin
    part_int:=random(10);
    repeat d:=random(10); until d<>0;
    process( x, y, (intensity*part_int) div 10 - y div 20, -random(d));
    process( x, y, (intensity*(10-part_int)) div 10 - y div 20, random(d));
   end;
  end;
 end;

begin
blacken(0,255);
aa:=random(20);{this is for delay}
repeat

 repeat delay(120); dec(aa); until (aa<=0); {do a variable delay}
 repeat aa:=random(6)-3; until abs(aa)>1; {get a good starting direction}

 process( random(100)+110, 0, 10, aa ); {get our discharge ready}

 vsync;   Setpal(pal,0,255);
 vsync;   setcolor(0,20,20,20); {sky suddenly brighten...}
 vsync;   setcolor(0,0,0,0);
{ repeat until keypressed;}
 vsync;   fadeout(pal,0,255,0);

 clearscreen(screen);
until keypressed;
end;

procedure message;
begin
write(
 'This is what you should do in order to enjoy this LIGHTNING demo :)'#13#13#10+
 ' 1. If it''s now daytime or somebody is with you, wait until it is not.'#13#10+
 '    Press Ctrl-C to quit.'#13#10);
write(
 ' 2. Close all curtains/doors so that no light can enter your room.'#13#10+
 ' 3. Sit back and press ENTER...');

readln;
end;

procedure message2;
begin
write('It should be with sounds too. But this is for SWAG... :P');
end;

begin
randomize;
message;
setcrtmode($13);
loadpal('light1.pal', pal, true);
lightning;
setcrtmode($3);
message2;
end.

{ Cut the following out and decode it with XX34. }

*XX3402-000768-220596--72--85-42191------LIGHT1.PAL--1-OF--1
+++++++++++++++++++++++-+++-+++-++2-++2-++20++20++20++20++21++21++21+E21
+E62+E62+E62+E62+E63+EA3+EA3+EA4+EA4+EA4+EA4+EA5+EE5+EE5+EE5+EE6+EE6+EE6
+UE6+UI7+UI7+UI7+UI8+UI8+UM8+UM8+UM9+UM9+UM9+UM9+kMA+kQA+kQA+kQA+kQB+kQB
+kQB+kUC+kUC+kUC+kUC+kUD-+UD-+YD-+YD-+YE-+YE-+YE-+YF-+cF-+cF-+cF-+cG-+cG
-+cG-EcG-EgH-EgH-EgH-EgH-EgI-EgI-EgI-EkJ-EkJ-EkJ-EkJ-UkK-UoK-UoK-UoK-UoL
-UoL-UoL-UoL-UsM-UsM-UsM-UsN-ksN-ksN-kwN-kwO-kwO-kwO-kwO-kwP-l+P-l+P-l+P
-l+Q-l+Q0-+Q0-2R0-2R0-2R0-2R0-2S0-2S0-2S0-6S0-6T0-6T0-6T0-6T0F6U0FAU0FAU
0FAV0FAV0FAV0FAV0FEW0FEW0FEW0FEW0FEX0VEX0VEX0VIX0VIY0VIY0VIY0VIZ0VMZ0VMZ
0VMZ0VMa0VMa0lMa0lMa0lQb0lQb0lQb0lQb0lQc0lQc0lUc0lUd0lUd0lUd0lUd1-Ue1-Ye
1-Ye1-Ye1-Yf1-Yf1-Yf1-Yf1-cg1-cg1-cg1-ch1Fch1Fch1Fgh1Fgi1Fgj1Fkj1Fkj1Foj
1Foj1Fsk1Fsk1Fsk1Vwk1Vwk1W+l1W+l1W+l1W2l1W2l1W6m1W6m1WAm1mAm1mAm1mEn1mEn
1mIn1mIn1mMn1mMn1mMo1mQo20Qo20Uo20Uo20Yp20Yp20Yp20Yp20cq20cq20cq20cq20cr
20gr20gr20gr20gs2Ggs2Gks2Gks2Gkt2Gkt2Gkt2Got2Gou2Gou2Gou2Gou2Gsv2Gsv2Wsv
2Wsw2Www2Www2Www2Wwx2Wwx2X+x2X+x2X+y2X+y2X+y2n2y2n2z3n6z51Ez6HIz7XQz8nUz
A1czBHgzCXozDnwz
***** END OF BLOCK 1 *****


