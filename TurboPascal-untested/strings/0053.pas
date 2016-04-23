{*****************************************************************************
 * Function ...... RTrim()
 * Purpose ....... To trim a character off the right side of a string
 * Parameters .... s       String to trim
 *                 c       Character to trim from <s>
 * Returns ....... <s> with all characters <c> removed from the right side
 * Notes ......... None
 * Author ........ Martin Richardson
 * Date .......... October 2, 1992
 *****************************************************************************}
FUNCTION RTrim( s: STRING; c: CHAR ): STRING;
BEGIN
      WHILE (LENGTH(s) > 0) AND (s[LENGTH(s)] = c) DO DEC(s[0]);
      RTrim := s;
END;

