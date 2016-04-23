There are basically three ways you can do it, all of them using
Interrupt 10h (video interrupt). First, set up something in your Var
like this:

  Var
    Regs : Registers;

Function 0 sets the mode, which will also clear the screen.  This is
useful if you want to set mode and clear screen at the same time.
It would look like this;

  REGS.AH := 0;
  REGS.AL := x; { where x is the mode you want (get a good Dos
                  reference manual For these) }
  inTR($10,REGS);

The other two options are Really inverses of each other...scroll
Window up and scroll Window down.  The advantage of these is that it
doesn't clear the border color (set mode does).  The disadvantage is
there are a lot more parameters to set.  For these, AH = 6 For scroll up
and 7 For scroll down.  AL = 0 (this Forces a clear screen), CH = the
upper row, CL = the left column, DH = the lower row, DL = the right
column, and BH = the color attribute (Foreground and background).  As I
said, it's a bit more Complicated, but you can set the screen color at
the same time if you want to (if not, you'll need to get the current
attribute first and store it in BH).  You'll also have to know the
current screen mode (40 or 80 columns, 25, 35, 43, or 50 lines).

As you can see, clearing the screen without using Crt is a bit more
Complicated, but you can set a lot of options at the same time as well.
It's up to you.

Just as an after-note, I'm currently working on a way to use
page-switching in Crt mode, writing directly to the video memory.  I'm
sick of not being to switch pages without loading Graph (waste of space
and memory, just to switch pages).
