(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0116.PAS
  Description: Fixed Point Math Unit
  Author: DIMITRI SMITS
  Date: 08-30-96  09:35
*)

(*

    This unit has been typed from the top of my head, so test
    it first with the examples in my previous message to Eli.
    As a matter of fact, this is a Unit that is based upon
    my explanations to Eli, so it somewhat NEEDS it ;)

    But I tested it though, just before posting it ;)

    This unit may be published in the next SWAGs (at least I
    think something like this belongs at least in the MISC SWAG
    becos it doesn't have one yet (I think).)
    but include the other mail too! (the previous one)

    If any questions, direct them to

    Gongo/Insecabilis
       dsmits@zorro.ruca.ua.ac.be
    or 2:292/8013.12 (fido)
*)

    Unit FixP;

    {
        (c) 1996 by Dimitri Smits aka Gongo/Insecabilis
        Released to the public Domain on june 22 '96
        You may use this in any production you want
        just notice me of the result, always happy to
        see such stuff ;) ... not needed to credit me,
        just greet me (either in the documentation or
        in the demo/game/softpackage ;)
    }

    INTERFACE

    TYPE fp = LONGINT;
        { 16.16 fixed point, signed
            So all numbers -32768.0000 <= x < 32767.9999
            should be sufficiently supported (although mul             and div
might lose some precision, or give odd results            for large numbers
(integer part)}
    FUNCTION fp_add ( fp1,fp2: fp): fp;
    { Not really needed, but when going to
      overloading functions in C++ or so, this method is needed ;)
     in other words, just here to make things complete }
    { an fp3 := fp1 + fp2  is enough :) }

    FUNCTION fp_sub ( fp1,fp2: fp): fp;
   { same as with fp_add, only + is - now }

    FUNCTION fp_mul ( fp1,fp2: fp): fp;
    FUNCTION fp_div ( fp1,fp2: fp): fp;

    FUNCTION fp2float (fpt : fp) : REAL;
    FUNCTION float2fp (fl : REAL) : fp;

    IMPLEMENTATION

    FUNCTION fp_add (fp1,fp2 : fp) : fp;
        BEGIN
           fp_add := fp1 + fp2;
        END;

    FUNCTION fp_sub (fp1,fp2 : fp) : fp;
        BEGIN
           fp_sub := fp1 - fp2;
        END;

    FUNCTION fp_mul (fp1,fp2 : fp) : fp;
        BEGIN
             IF abs(fp1) > abs(fp2) THEN
               fp_mul := (fp1 SHR 8 * fp2) SHR 8
             ELSE
               fp_mul := (fp2 SHR 8 * fp1) SHR 8;
            {16-bit precision needed, not 32 =)}
        END;

    FUNCTION fp_div (fp1,fp2 :fp) : fp;
        BEGIN
            fp_div := (fp1 SHL 8) DIV (fp2 SHR 8);
            { May lose some precision there}
        END;

    FUNCTION fp2Float (fpt : fp) : REAL;
        BEGIN
            fp2Float := fpt / 65536;
        END;

    FUNCTION float2fp (fl : REAL) : fp;
        BEGIN
            float2fp := ROUND (fl * 65536);
        END;

BEGIN
END.

