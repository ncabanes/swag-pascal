{*****************************************************************************
 * Function ...... Command
 * Purpose ....... To return the command line as a string
 * Parameters .... None
 * Returns ....... The entire command line as one string
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
FUNCTION Command: STRING;
BEGIN
     Command := STRING( PTR(PREFIXSEG, $0080)^ );
END;

