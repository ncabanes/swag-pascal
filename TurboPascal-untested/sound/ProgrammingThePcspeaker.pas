(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0056.PAS
  Description: Programming the PC-Speaker
  Author: LOU DUCHEZ
  Date: 11-26-94  04:55
*)

{
>I want to build on Infared Controller (thru RC5 coding) to controll my
>tv, stereo, ect thru my PC. I know how to programm the computer to do so,
>but I need to access my PC-Speaker directly !!!
>Does anyone know the Port Adress or Mem Adress for accessing the PC-Speaker

Here's some BASM code of mine; check the comments:
From: ljduchez@en.com (Lou DuChez)
}

asm
  mov al, 182       { prepare timer to start generating sound }
  out 43h, al
  mov ax, toneout   { TONEOUT = word: 1193180 / frequency }
  out 42h, al       { send low byte to port 42h }
  mov al, ah
  out 42h, al       { send high byte to port 42h }
  in al, 61h        { get current value of port 61h }
  or al, 3          { set lowest two bits of 61h "on" -- activate speaker }
  out 61h, al       { rewrite to port 61h }
end;

{ This code turns off the speaker: }

asm
  in al, 61h        { set lowest two bits of 61h "off" -- deactive speaker }
  and al, 252       { this line turns the lowest two bits "off" }
  out 61h, al
end;

{
> If I know this adress, all you have to do is buy a IR-Led ($1,00) and your
> computer is the biggest enhanced remote controller.
}

{
From: -deneb- <NWIEFFER@norton.ctech.ac.za>

> I want to build on Infared Controller (thru RC5 coding) to controll my
> tv, stereo, ect thru my PC. I know how to programm the computer to do so,
> but I need to access my PC-Speaker directly !!!
> Does anyone know the Port Adress or Mem Adress for accessing the PC-Speaker

Well .... it's not half as easy as it could be ...

There are a few way to fiddle with the speaker ...

 1.  Via the 8254 Programmable Interval Timer (PIT). (Port $40-$47)
 2.  Via the 8255 Programmable Peripheral Interface. (Port $60-$67)

 ( on the original PC, XT and earlier 286's these were seperate IC's,
   but now all of that stuff is combined into 1 along with the DMA
   controler, etc.)

With option 1 you can tell the timer to drive the speaker at a
certain frequency ... and that's about it,
or with option 2 you can waggle the speaker bit up and down as you
like ...

For your application, I think option 2 would be the 1 to choose.
So here goes ...
}

{ This should push the output high }
x:=Port[$61];
x:=(x and $FC) or 2;
Port[$61]:=x;

{ And this should push it low }
x:=Port[$61];
x:=x and $FC
Port[$61]:=x;

{
And hear's what is actually does ...

Port $61 is the 8255 port B.
If bit 0 of port B is 0, then the speaker does exactly what bit 1
does ... that's what I'm doing above.

In this mode the port can go like this ...

Port B bit 1 : 1    0    1    0
Speaker port : High Low  High Low


If bit 0 of port B is 1, then the speaker is conected to the PIT,
in which case Bit 1 acts as the switch ... it either connects it to
the PIT, or it switches it off.

And in this mode the port goes somthing like this ...

Port B bit 1 : 1    0    1    0
Speaker Port : Beep Off  Beep Off
}

