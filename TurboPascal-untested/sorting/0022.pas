Turbo Pascal Optimization Contest # 51.

No tangible prizes, just some bragging rights, and a brain workout.

Assignment:  Write conversion routines similar to VAL and STR that can
             handle a radix (base) of any number.  For example, below is
             a straight Pascal Procedure to convert a String of any base
             to a LongInt.  Can you improve the speed of this routine,
             and Write a correspondingly fast routine to convert from a
             LongInt to a String of any base?

Rules:       No rules.  BAsm is allowed, as long as the Functions are
             readily Compilable without the use of TAsm.

Judging:     Code will be tested on a 386-40 on March 10th, by being
             placed into a loop With no output, like this:

               StartTiming;
               For Loop := 1 to 10000000 { ten million } do
                 { Execute the test, no output }
               WriteLn(StopTiming);

Ready, set, code!  Here's the sample...

(* This Function converts an ASCIIZ String S in base Radix to LongInt I
 * With no verification of radix validity.   The calling Programmer is
 * responsible For insuring that the radix range is 2 through 36.  The
 * calling Programmer is also responsible For insuring that the passed
 * String contains only valid digits in the specified Radix. No checking
 * is done on the individual digits of a given String.  For bases 11-36
 * the letters 'A'-'Z' represent the corresponding values.
 *)

Procedure StrtoLong(Var I : LongInt; S : PChar; Radix : Integer);
  begin
    I        := 0;
    While S[0] <> #0 do
      begin
        Case S[0] of '0'..'9' : I := I * Radix + (ord(S[0])-48);
                     'A'..'Z' : I := I * Radix + (ord(S[0])-54);
                     'a'..'z' : I := I * Radix + (ord(S[0])-86);
        Inc(s);
      end;
  end;

