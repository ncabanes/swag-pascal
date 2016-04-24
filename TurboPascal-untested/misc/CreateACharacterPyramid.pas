(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0178.PAS
  Description: Create a Character Pyramid
  Author: CLIF PENN
  Date: 05-31-96  09:17
*)

{
>I need to do two programs and I am unsure of what to do with them.  If
>anyone could help me with the code or the steps necessary to write the
>programs it would be greatly appreciated.  Thank you.  Here's what I
>need to do:

>First program: A program that reads a char. from "A" to "Z" as input
>to produce output in the shape of a pyramid composed of the letters up
>to and including the letter that is input.  Example:
>                                            A
>                                         ABA
>                                      ABCBA
>                                    ABCDCBA

Here is one way to do the pyramid of characters. }

Program Char_Pyramid;
{ <clifpenn@airmail.net   4/16/96   12:30 AM   Borland Turbo v 6.0
  From a single character input in ['A'..'Z'] a pyramid of chars is
  formed as follows:
                       A                             A
  ch1 := 'C' gives    ABA      ch1 := 'D' gives     ABA      etc.
                     ABCBA                         ABCBA
                                                  ABCDCBA   }
USES CRT;
Label Finis;

CONST
Esc = Chr(27);

VAR
ch1, ch2:Char;
s, s1, s2:String;
fld:Integer;

BEGIN
     Repeat
           ClrScr;
           Write('Input a letter, (Esc to quit): ');
           fld := 40;
           s1 := '';
           s2 := '';

           Repeat
                 ch1 := UpCase(ReadKey);
           Until ch1 in [Esc, 'A'..'Z'];

           If ch1 = Esc then Goto Finis;

           Begin
                Writeln(ch1);
                For ch2 := 'A' to  ch1 Do
                Begin
                     s1 := s1 + ch2 ;  (* forward string segment *)
                     s := s1 + s2 ;    (* forward + reversed chars *)
                     Writeln(s:fld);   (* centered on screen *)
                     Inc(fld);
                     s2 := ch2 + s2;   (* next reversed str segment *)
                End;
           End;
           Write('Press enter to continue');
           Readln;
Finis:
     Until ch1 = Esc;
END.




