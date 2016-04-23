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