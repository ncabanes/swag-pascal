(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0059.PAS
  Description: Disable Password from CMOS
  Author: KISS L. KAROLY
  Date: 05-30-97  18:17
*)

{
Hello . My name is Kiss L. Karoly. I am from Rumania.
I love programing!!!

THE FOLLOWING SMALL PROCEDURE DISABLES THE PASSWORD FROM CMOS }

PROCEDURE OUTPASSWORD;
BEGIN
ASM
   XOR AX,AX
   MOV AL,11H
   OUT 70H,AL
   MOV AL,074H
   OUT 71H,AL
   XOR AX,AX
   MOV AL,2FH
   OUT 70H,AL
   MOV AL,0C4H
    OUT 71H,AL
END;

