{*****************************************************************************
 * Function ...... IsKeyPressed
 * Purpose ....... To determine if *ANY* key is pressed on the keyboard
 * Parameters .... None
 * Returns ....... TRUE if a key is being pressed
 * Notes ......... Even returns TRUE if a shift/ctrl/alt/caps lock key is 
 *                 pressed.
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION IsKeyPressed: BOOLEAN;
BEGIN
     IsKeyPressed := ((MEM[$40:$17] AND $0F) > 0) OR (MEM[$40:$18] > 0)
                     OR KEYPRESSED;
END;

