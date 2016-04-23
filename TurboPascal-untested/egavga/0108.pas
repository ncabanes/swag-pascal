{
AG> Does anyone out there know how to set the screen display for 28 rows, in
AG> VGA mode?  I've seen this in a couple of programs, and really like it.

Here goes a small assembly routine to switch the screen to 28-line mode. }

       MOV   AX,1202          ;set up 400 scan lines
       MOV   BL,30
       INT   10
       MOV   AX,0003          ;set up normal text mode
       INT   10
       MOV   AX,1111          ;load ega character set
       MOV   BL,00
       INT   10

