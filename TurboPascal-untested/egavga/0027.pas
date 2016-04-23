{PK>SetVisualPage are Procedures I spent a lot of time investigating with
PK>Really weird results. In fact I locked up Computer several times and

I hate it when that happens <g>.

PK>then I got frustrated and posted the message hoping there would be some
PK>other way how to go about it. tom Swan's book Mastering Turbo Pascal 6.0

There is: Don't use Graph.TPU and Write all your own routines.  In the
following Program, 3 routines SetVidMode, SetPage, and PutPix
illustrate a Graph.TPU-less example of your original requirement.
}

Program test0124;
Uses Dos;

Const
  VidMode = $10;  {..640x350x16 - Supported By VGA and Most EGA }
Var
  x,y : Integer;
  reg : Registers;

Procedure SetVidMode(VidMode :Integer);
  begin
  reg.ah := $00;
  reg.al := VidMode;
  intr($10,reg);
  end;

Procedure SetPage(Page :Integer);
  begin
  reg.ah := $05;
  reg.al := page;
  intr($10,reg);
  end;

Procedure PutPix(Color,Page,x,y : Integer);
  begin
  reg.ah := $0C;
  reg.al := Color;
  reg.bh := Page;
  reg.cx := x;
  reg.dx := y;
  intr($10,reg);
  end;

begin
SetVidMode(VidMode);
SetPage(0);                                {..set active display page }
For x := 200 to 440 do                     {..use custom PutPix to }
  For y := 100 to 250 do PutPix(3,1,x,y);  {  draw to different page }
Write(^g);
ReadLn;                                    {..press enter to switch }
SetPage(1);                                {  active display page }
ReadLn;
end.

{
There are only a few dozen more routines that you need to have the
Functionality of Graph.TPU - simple stuff like manipulating palettes,
line/circle/polygon algorithms, fill routines, etc., etc....have fun.

PK>list all video modes and number of pages it is capable of working with
PK>and VGA in 640x480 (that's the mode I have) is supposed to handle only
PK>one page. That's is probably the reason why it doesn't work. What is

That would do it.  From my reference, Advanced MS Dos Programming - Ray
Duncan, The best resolution you can get With multiple page support is
640x350 (Mode $10).

About the ClearViewPort conflict, I experienced similar problems - I
went as Far as pixelling out portions of the display to avoid using
ClearViewPort <Sheesh!> - that Graph Unit doesn't make anything easy.
}