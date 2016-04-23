
                    +------------------------------+
                    | Programming the PC Joystick  |
                    +------------------------------+

                       Written for the PC-GPE by
                     Steve McGowan and Mark Feldman


+------------------+-------------------------------------------------------
| Programming Info |
+------------------+

All joystick programming is done via port 201h.

                      +---+---+---+---+---+---+---+---+
                      | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
                      +-------------------------------+
                        |   |   |   |   |   |   |   |
Joystick B, Button 2 ---+   |   |   |   |   |   |   +--- Joystick A, X Axis
Joystick B, Button 1 -------+   |   |   |   |   +------- Joystick A, Y Axis
Joystick A, Button 2 -----------+   |   |   +----------- Joystick B, X Axis
Joystick A, Button 1 ---------------+   +--------------- Joystick B, Y Axis

Reading the status of the joystick buttons is fairly simple. Just read the
byte from the joystick port and check the status of the appropriate bit. A
clear bit (0) means the button is pressed, a set bit (1) means it is not
pressed. Note that the button's are not hardware debounced. Each time a
button is pressed it's bit may "bounce" between 0 and 1 a couple of times.

Reading the position of the stick positions is a bit more complicated. You
must first write a dummy byte (any value will do) to the joystick port. This
will set each axis bit to 1. You must then time how long the bit takes to
drop back to 0, this time is roughly proportional to the position of
the joystick axis (see Steve McGowan's discussion below).

AT computers also have a BIOS call which supports the joystick. I have come
across numerous machines which apparently did not support this call. My own
machine supports reading the joystick buttons apparently can't read the
stick position values, so I do not advise using this call for any serious
games. In any case here is info on the call:

Joystick Support BIOS Call

Int 15h

To call:
  AH = 84h
  DX = 00h Read switch settings
       01h Read joystick position

Returns:
    PC, PCjr : Carry flag set, AH = 80h
       PC XT : Carry flag set, AH = 86h
  All others : DX = 00h on calling
                 AL = Switch settings (bits 4 - 7)
                 Carry flag set on error
               DX = 01h on calling
                 AX = A(X) value
                 BX = A(Y) value
                 CX = B(X) value
                 DX = B(Y) value

+-----------------+----------------------------------------------------------
| Hardware Pinout |
+-----------------+

The joystick connects to a 15 pin female plug :

                     __________________________
                     \ 8  7  6  5  4  3  2  1 /
                      \ 9  10 11 12 13 14 15 /
                       ----------------------

                  +-------------------------------+
                  | Pin #  Joystick               |
                  +-------------------------------+
                  |  1     +5v                    |
                  |  2     Joystick A, Button 1   |
                  |  3     Joystick A, X Axis     |
                  |  4     Gnd                    |
                  |  5     Gnd                    |
                  |  6     Joystick A, Y Axis     |
                  |  7     Joystick A, Button 2   |
                  |  8     +5v                    |
                  |  9     +5v                    |
                  |  10    Joystick B, Button 1   |
                  |  11    Joystick B, X Axis     |
                  |  12    Gnd                    |
                  |  13    Joystick B, Y Axis     |
                  |  14    Joystick B, Button 2   |
                  |  15    +5v                    |
                  +-------------------------------+


+--------------------------------------------------+-------------------------
| Misc notes on Joystick handling by Steve McGowan |
+--------------------------------------------------+

With a polling loop on a 486-66 I got x/y values between 8 and 980. When
I centered the stick the value was usually a value around 330.

NOTE: a Gravis Game Pad it only put out 3 values, 8(min), 330(center),
and 980(max). Every joystick I have tried has been non-linear.

The "speed compensation" that some games require is due to the fact that
the game designer did not anticipate the range of values that could
come back on faster machines. On a 486-25 you may see max values of 360,
I saw 980, on a Pentium the max value could be well over 2000. If you
had used a unsigned byte value you probably would have been in good
shape on an AT, or 386 but you would be in big trouble with faster machines.

Because the joystick logic returns a non linear value, if you base your
scaling only on the 4 corners then the center will be off (biased towards
a corner). If you just use the center value and a single scaling factor
(i.e. of the center is at 330 then full throw should be at 660), then the
stick will saturate (660) half way to the full throw position (980).
That is why most joystick setup programs make the distinction between
hitting the 4 corners and centering the stick.

Joystick position vs. loop count

     x,y--------------------
     8,8|      330,8       | 980,8
        |                  |
        |                  |    delta 330
        |                  |
   8,330|      330,330     | 980,330 (y centered)
        |                  |
        |                  |    delta 650
        |                  |
   8,980|      330,980     | 980,980
        --------------------
            (x centered)

For the best effect you basically need 2 scale factors, depending on whether
you are above or below the center value. I think the curve is actually an
exponential (charging capacitor) but a straight line approximation should
do fine.

The 10% dead zone in the center is a good idea. The centering mechanism of
joysticks vary in repeatablity, they don't always come back to the same place.
I have a cheap one that (1 time in 8) does not return to the X center if I
just let it snap to center. It hangs on the high side.

I would recommend disabling interrupts while polling. An interrupt
in the middle of your polling loop will really throw off the results. And
any DMA that takes place will also give you bad values.

Joysticks are noisy, so holding the stick in a fixed position will return
values that vary +-5% easily. I added a smoothing function to my joystick
code where I throw away single values that are not continuous. It helped
a lot with the noise and the DMA.

I use protected mode and the interrupt disable() call doesn't actually work
because it only disables interrupts for the process not the processor.
The smoothing trick can help here too.

If I turn on my machine and start the polling loop immediately, it will
put out a centered value of 330,330 but after warming up for 10 minutes
the value changes to 285,285. This variance also needs to be absorbed in
your center dead zone. If after warming up the 'center' value is outside your
dead zone then the cursor will drift (to the left and/or up). Make
sure your game has a "center joystick" command to get around joystick
interfaces with lousy temperature compensation.

You must wait for all of the axis bits to settle before initiating
another read, otherwise strange results may come out. So, instead of
reading X, then Y, in two separate loops (which take twice as much time)
Read both X and Y simultaneously, polling until both bits settle. This
can be extended for two joysticks, assuming that they are both attached.
The respective X/Y bits never come true if there is no joystick attached.


+-----------------------------+----------------------------------------------
| A Simple Demo Joystick Unit |
+-----------------------------+

{
  JOY.PAS - By Mark Feldman
            e-mail address : u914097@student.canberra.edu.au
                             myndale@cairo.anu.edu.au


  A simple Pascal Joystick Unit.
}


unit Joy;

Interface

{ Define constants for use as JoystickButton and JoystickPosition parameters }
const JoystickAButton1 = $10;
      JoystickAButton2 = $20;
      JoystickBButton1 = $40;
      JoystickBButton2 = $80;
      JoystickAAxisX   = $01;
      JoystickAAxisY   = $02;
      JoystickBAxisX   = $04;
      JoystickBAxisY   = $08;

function JoystickButton(buttonnum : byte) : boolean;
function JoystickPosition(axisnum : byte) : word;

Implementation

const JOYSTICKPORT = $201;

{ Button returns true is button is pressed }
function JoystickButton(buttonnum : byte) : boolean;
begin
  JoystickButton := (Port[JOYSTICKPORT] and buttonnum) = 0;
end;

{ Returns position value of joystick. The value returned is highly
  dependent on machine speed. Changing the setting of the computer's
  Turbo speed button will affect the value returned.
  Returns $FFFF if the joystick is not connected
}
function JoystickPosition(axisnum : byte) : word;
var count : word;
begin
  asm
    mov word ptr count, 0
    cli          { Disable interrupts so they don't interfere with timing }
    mov dx, JOYSTICKPORT   { Write dummy byte to joystick port }
    out dx, al
    @joystickloop:
    inc count              { Add one to count }
    cmp count, $FFFF       { Check for time out }
    je @done
    in al, dx              { Get joystick port value }
    and al, axisnum        { Test the appropriate bit }
    jne @joystickloop
    @done:
    sti                    { Enable interrupts again }
  end;
  JoystickPosition := count;
end;

end.


+-------------+--------------------------------------------------------------
| References  |
+-------------+

Title : Flights of Fantasy
Author : Christopher Lampton
Publishers : The Waite Group
ISBN : 1-878739-18-2

Title : DOS and BIOS Functions Quick Reference
Publishers : Que Corporation
ISBN : 0-88022-426-6

</PRE>
<P><P><A HREF="index.html"><IMG SRC="contents.gif"></A>
</BODY>
</HTML>