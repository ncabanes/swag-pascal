{*****************************************************************************
 * Function ...... RND()
 * Purpose ....... To generate a random number
 * Parameters .... i          Max value for number range
 * Returns ....... A random number between 1 and i
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... May 13, 1992
 *****************************************************************************}
{ FUNCTION to generate a random number between 1 and i }
FUNCTION RND( i: LONGINT ): LONGINT;
BEGIN
     RND := RANDOM( i ) + 1;
END;

