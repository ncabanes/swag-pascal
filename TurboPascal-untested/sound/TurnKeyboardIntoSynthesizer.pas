(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0063.PAS
  Description: Turn Keyboard into Synthesizer!
  Author: CHRISTOPHER CHANDRA
  Date: 05-26-95  22:59
*)

{
You need to reprogram the Keyboard Interrupt. Here is an example that I made.
It is a multiple keys - beep synthetizer, so you can do musical chords on
your keyboard. Try hitting several keys at once, btw..

Q = C 2 = C# W=D, etc.. just try it, you'll get the idea.
and I hope you can learn something from the code.

Multiple keys - Beep Synthetizer
by Christopher J. Chandra - PUBLIC DOMAIN CODE

}

uses dos,crt;

const do0=131; do1=262; do2=522; do3=1047; do4=2093; do5=4186;
      dk0=139; dk1=277; dk2=554; dk3=1109; dk4=2217; dk5=dk4*2;
      re0=147; re1=293; re2=587; re3=1175; re4=2349; re5=re4*2;
      rk0=156; rk1=311; rk2=622; rk3=1245; rk4=2489; rk5=rk4*2;
      mi0=165; mi1=329; mi2=659; mi3=1319; mi4=2637; mi5=mi4*2;
      fa0=174; fa1=349; fa2=698; fa3=1397; fa4=2794;
      fk0=185; fk1=370; fk2=740; fk3=1480; fk4=2960;
      so0=196; so1=392; so2=784; so3=1568; so4=3136;
      sk0=208; sk1=415; sk2=831; sk3=1661; sk4=3322;
      la0=220; la1=440; la2=880; la3=1760; la4=3520;
      lk0=233; lk1=466; lk2=932; lk3=1865; lk4=3729;
      ti0=247; ti1=494; ti2=988; ti3=1976; ti4=3951;
      sil=32767;           {silence}

      scale1 : array[0..11] of integer =
(do1,re1,mi1,fa1,so1,la1,ti1,do2,re2,mi2,fa2,so2);
      scales1: array[0..11] of integer =
(sil,dk1,rk1,sil,fk1,sk1,lk1,sil,dk2,rk2,sil,fk2);
      scale2 : array[0..11] of integer =
(do2,re2,mi2,fa2,so2,la2,ti2,do3,re3,mi3,fa3,so3);
      scales2: array[0..11] of integer =
(sil,dk2,rk2,sil,fk2,sk2,lk2,sil,dk3,rk3,sil,fk3);
      scale3 : array[0..11] of integer =
(do3,re3,mi3,fa3,so3,la3,ti3,do4,re4,mi4,fa4,so4);
      scales3: array[0..11] of integer =
(sil,dk3,rk3,sil,fk3,sk3,lk3,sil,dk4,rk4,sil,sil);
      scale4 : array[0..11] of integer =
(do4,re4,mi4,fa4,so4,la4,ti4,do5,re5,mi5,sil,sil);
      scales4: array[0..11] of integer =
(sil,dk4,rk4,sil,fk4,sk4,lk4,sil,dk5,rk5,sil,sil);

var keys: array[0..127] of boolean;
    oldkey:procedure;
    cnt,del:byte;

{$F+}
procedure newkey; interrupt;   { new keyboard handler }
begin
  keys[port[$60] and $7f] :=        { key is down if high bit of 60h is }
      (port[$60] and $80) = $00;    {   "off" -- record current status }
  port[$20] := $20;               { End-of-Interrupt instruction }
end;
{$F-}

begin
 clrscr;
 getintvec($09,@oldkey);
 setintvec($09,@newkey);
 for cnt:=0 to 127 do keys[cnt]:=false;
 repeat
  del:=30;
 {for cnt:=0 to 15 do
  begin
   gotoxy(1,1+cnt);writeln(cnt+00:3,' ',keys[cnt+00]:5,' ',
                           cnt+16:3,' ',keys[cnt+16]:5,' ',
                           cnt+32:3,' ',keys[cnt+32]:5,' ',
                           cnt+48:3,' ',keys[cnt+48]:5,' ',
                           cnt+64:3,' ',keys[cnt+64]:5,' ',
                           cnt+80:3,' ',keys[cnt+80]:5,' ',
                           cnt+96:3,' ',keys[cnt+96]:5,' ',
                           cnt+112:3,' ',keys[cnt+112]:5,' ');
  end;}

  for cnt:=0 to 11 do
  begin
   if keys[16+cnt] then
   begin
    if keys[42] then sound(scale1[cnt]) else sound(scale2[cnt]);
    delay(del);
    nosound
   end;
   if keys[2+cnt] then
   begin
    if keys[42] then sound(scales1[cnt]) else sound(scales2[cnt]);
    delay(del);
    nosound
   end;
   if keys[44+cnt] then
   begin
    if keys[42] then sound(scale4[cnt]) else sound(scale3[cnt]);
    delay(del);
    nosound
   end;
   if keys[30+cnt] then
   begin
    if keys[42] then sound(scales4[cnt]) else sound(scales3[cnt]);
    delay(del);
    nosound
   end;
  end;

 until keys[1];
 setintvec($09,@oldkey);
end.

