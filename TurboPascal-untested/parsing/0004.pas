{*****************************************************************************
 * Function ...... IsSwitch()
 * Purpose ....... To test for the presence of a switch on the command line
 * Parameters .... sSwitch     Switch to scan the command line for
 * Returns ....... .T. if the switch was found
 * Notes ......... Uses functions Command and UpperCase
 * Author ........ Martin Richardson
 * Date .......... September 28, 1992
 *****************************************************************************}
FUNCTION IsSwitch( sSwitch: STRING ): BOOLEAN;
BEGIN
     IsSwitch := (POS( '/'+sSwitch, UpperCase(Command) ) <> 0) OR
                 (POS( '-'+sSwitch, UpperCase(Command) ) <> 0);
END;
