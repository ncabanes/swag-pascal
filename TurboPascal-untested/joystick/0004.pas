
Anyone know how to read the Joystick....

if you are using an AT (286 or later), here's the easy way.
Use Intr ($15, Regs), and load AH With the $84, then load
DX With 1 to get the joystick status' and 0 to get the
button status.  if you use DX=1, it returns:

AX x of joystick A
BX y of joystick A
CX x of joystick B
DX y of joystick B

if you use DX=0:

AL button status, bit #
   4 joystick A,button 1
   5 joystick A,button 2
   6 joystick B,button 1
   7 joystick B,button 2
