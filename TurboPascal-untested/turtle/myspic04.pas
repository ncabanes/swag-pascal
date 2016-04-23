(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Turtle overdraw with coordinate system     │
   └───────────────────────────────────────────────────────────┘ *)

{
    This program work with coordinate system. What you draw in one
    quadrant this is overdraw in other quadrants. It is nice effekt
    and work with mouse and turtle.
    Principe :
    1. Define to coordinate system momental mouse sytuation if you
    turn mouse button.
    2. Overdraw it to other quadrants. Just work with Xsur and Ysur
    and make all combinations. (+x,+y,+c,-y,-x,+y,-x,-y)
    3. If we turn right button then quit the program
}

uses  graph,mys,okor;

var
  k1,k2,k3,k4:kor;
  gd,gm:integer;

begin
  if not inicmys then
  begin
    outtext('Probkem with mouse driver!');
    exit;
  end;
  zmenkurzormysi(kurzor_sipka);
  ukazmys;
  k1.init(0,0,0);
  k2.init(0,0,0);
  k3.init(0,0,0);
  k4.init(0,0,0);
  while stavmysi<>2 do
  begin
    case stavmysi of
    0:begin
        k1.ph;
        k2.ph;
        k3.ph;
        k4.ph;
      end;
    1:begin
        skrymys;
        k1.zmenxy(mysx-x0,y0-mysy);
        k2.zmenxy(x0-mysx,y0-mysy);
        k3.zmenxy(x0-mysx,mysy-y0);
        k4.zmenxy(mysx-x0,mysy-y0);
        ukazmys;
        if not k1.dole then
        begin
          k1.pd;
          k2.pd;
          k3.pd;
          k4.pd;
        end;
      end;
    end;
  end;
  closegraph;
end.
