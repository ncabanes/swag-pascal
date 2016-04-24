(*
  Category: SWAG Title: JOYSTICK ROUTINES
  Original name: 0015.PAS
  Description: Joystick Pin Descriptions
  Author: BRYAN WILLIAMS
  Date: 05-26-95  23:18
*)

{
> Does anyone have any PURE Turbo Pascal 7 source code to read the
> joystick port and does anyone have the pinouts for this port?  I'm
> contemplating making a user interface but need the information about
> the port and if I can program for it.  Thanks...

 1  -  +5V to Joystick A (& to Joystick B via pin 9)
 2  -  + to Button 1 on Joystick A
 3  -  X Coordinate on Joystick A
 4  -  Joystick A to ground
 5  -  Joystick B to ground
 6  -  Y Coordinate on Joystick A
 7  -  + to Button 2 on Joystick A
 8  -  Ground
 9  -  +5V to Joystick B
 10 -  + to Button 1 on Joystick B
 11 -  X Coordinate on Joystick B
 12 -  not used for joysticks
 13 -  Y Coordinate on Joystick B
 14 -  + to Button 2 on Joystick B
 15 -  not used for joysticks

 Pin ID:
 		1   2   3   4   5   6   7   8

 	         9   10  11  12  13  14  15

