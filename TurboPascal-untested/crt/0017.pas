>Actually James you are in correct.  Here is some code that will change the
>blinking characters to a enhanced back ground...
> 
>Procedure HighBackGround;
>VAR
>  R: Registers;  {You must use the Dos Unit.}
>BEGIN
>  WITH R DO
>  BEGIN
>    R.AH:=$10;
>    R.AL:=$03;
>    BL:=0;
>     {0 for intense back ground}
>     {1 for blink}
>  END;
>  Intr($10,R);
>END;
> 
>Hope this helps,
>  

  This solution is correct, but only for EGA or higher monitors.  

  To get high intensity background colors on a CGA card, you need to
  access the Color Graphics Mode Control Register, port $3d8.

  The bit meanings are as follows:

  bit

  7,6   unused
  5     blink mode 0 = disable blink 1 = enable blink
  4     graphics resolution 0 = 320x200 1 = 640x200
  3     video enable 0 = disable 1 = enable
  2     color mode 0 = color 1 = bw
  1     monitor mode 0 = alphanumeric 1 = graphics
  0     char. size 0 = 40x25 1 = 80x25

  The simplist answer to your problem is, in TP, 

    port[$3d8] := $9

  This sets 80x25 color alphanumeric mode with high intensity
  background colors.  If you need other modes, set the bits
  accordingly.  

  One word of caution:  register $3d8 is write only, so you can't
  use the read-or-write method of bit setting.  You'll need to look
  into the BIOS data area to find out the current video mode if
  necessary.
