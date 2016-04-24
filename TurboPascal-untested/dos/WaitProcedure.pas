(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0073.PAS
  Description: WAIT Procedure
  Author: FRANK DIACHEYSN
  Date: 08-24-94  17:54
*)

{
  Coded By Frank Diacheysn Of Gemini Software

  PROCEDURE WAIT

  Input......: Secs = Long Integer Value For The Number Of SECONDS
             :        (NOT Milliseconds) To Delay
             :
             :
             :

  Output.....: None
             :
             :
             :
             :

  Example....: Wait(5);   (Wait 5 Seconds)
             :
             :
             :
             :

  Description: Works Exactly Like The CRT Unit's Delay Procedure, Except
             : This Procedure Works With Seconds, Not Milliseconds
             :
             :
             :

}
PROCEDURE Wait( Secs:LONGINT );
VAR MS : WORD;
BEGIN
  Secs := Secs * 1000;
  ASM
    MOV AX, 1000;
    MUL Secs;
    MOV CX, DX;
    MOV DX, AX;
    MOV AH, $86;
    INT $15;
  END;
END;

