(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0045.PAS
  Description: Clear keyboard buffer
  Author: MARTIN RICHARDSON
  Date: 09-26-93  08:47
*)

{****************************************************************************
 * Procedure ..... ClearKBBuffer
 * Purpose ....... To clear the keyboard buffer of pending keystrokes
 * Parameters .... None
 * Returns ....... N/A
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 ****************************************************************************}
PROCEDURE ClearKBBuffer;
BEGIN
     WHILE KEYPRESSED DO IF ReadKey = #0 THEN;
END;

