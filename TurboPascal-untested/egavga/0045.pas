 {
 Anivga is the best set of Graphics routines i've seen For the PC since
 i stopped using my old 4,7 Mhz MSX (which had smooth sprites &
 scrolling) and the one With the most extra's.

Well, here is >ONE< solution For you.  It is one I have used in a
streetfighter Type game a friend and I have been working on (the friend
is an artist who has been doing the pics While I'm doing the software).
It turns out, using an index-to-index copy during vertical retrace is
fast enough to get at least (and I mean at LEAST--I've been able to over
Double this rate) 18.2 frames per second on a 16bit VGA card.

The code (in pascal, although the Program itself is written in C++, the
theory works With TP6.0) would look something like this:
}

Type
  ScreenRec = Array[0..63999] of Byte;
  ScreenPtr = ^ScreenRec;

Var
  VGAScreen : ScreenRec Absolute $A000:$0000; {I think thats how you do
                                               it, been a While since I
                                               had to do things this way}

Procedure VS_PutPixel(x, y: Integer; c:Byte; VS: ScreenPtr);

begin
  VS^[(y*320)+x] := c; {Again, this may be off slightly--my original
                        pascal Implementation used a member Variable in
                        an Object}
end;

Procedure VS_Write(VS: ScreenPtr);

Var
  X : Integer;
  Y : Integer;

begin
  {Wait For a retrace--see a VGA manual For how to do this, it takes
  monitoring two ports.  if you are already in a retrace, wait For it to
  end and another one to begin}
  For Y := 0 to 199 do
    For X := 0 to 319 do
      VGAScreen[(Y*320)+X] := VS^[(Y*320)+X];
end;

{
With this method, you even have time in the nexted For loops (!) to do a
Comparison.  One I typically use (For emulating multiple planes) is if
VS^[(Y*320)+X] <> 0...  That lets me copy multiple screens.  to give you
an idea of how fast this is, on my 386/25, I can do this during a timer
interrupt (18.2 times a second) without any problems, and still have
time to do full collision detection and multisprite animation with
scrolling backgrounds and Soundblaster Sound.  During the retrace
period, you can move quite a bit of inFormation into the VGA card,
because memory accesses are MUCH faster (the screen is also not being
updated).  This is CompLETELY flicker free using this technique (if
smaller sections are chaging, you MIGHT consider only copying parts of
the screen).

}