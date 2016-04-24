(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0084.PAS
  Description: Simulate Phone Ringing
  Author: BJORN FELTEN
  Date: 01-28-94  08:55
*)

{
 > I stumbled across the correct sequence

 Well, why don't we let some more people stumble in on our little secret? :)

Something like this might do the trick. The brute delay code 'asm hlt end',
that simply waits for the next interrupt (should be the timer IRQ) to occur,
may not work on some machines -- especially when running some multitaskers.
If so it can be changed to 'delay(50)' or something like that.
}

program Ring;
uses crt;
var i:word;
begin
  for i:=0 to 6 do
  begin
      sound(523); asm hlt end;
  Delay(50);
      sound(659); asm hlt end;
  Delay(50);
  end;
  nosound
end.

{ Or, for those of you that don't like the crt unit, here's the same thing in
  BASM: }

program Ring;
begin
  asm
    mov   al,0B6h
    out   43h,al
    in    al,61h
    or    al,3
    out   61h,al
    mov   cx,7
    mov   dx,42h
@the_loop:
    mov   al,0E9h
    out   dx,al
    mov   al,8
    out   dx,al
    hlt
    mov   al,12h
    out   dx,al
    mov   al,7
    out   dx,al
    hlt
    loop  @the_loop
    in    al,61h
    and   al,0FCh
    out   61h,al
  end;
end.


