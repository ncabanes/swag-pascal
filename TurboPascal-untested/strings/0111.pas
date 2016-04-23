{
    Here is a function some of you may find useful, it tries to find
misspellings such as "Hello World" and "Hello Wolrd" by comparing 2 strings
and returning a percent base of 3 tests of how close they match...
Lemme know if you know of a way to improve upon this.
}

{$B-,V-,S-,R-,I-,A+}       { for speed }
 
uses dos, crt;
 
var
   string_a  : string;
   string_b  : string;    { for the 5 line example at the bottom }
 
 
 
 
{------------------------------------------------------------------------}
{ 'InStr' -For use with StrMatcher.                                      }
{                                                                        }
{     InStr is just like POS except you may specify a starting position. }
{                                                                        }
{------------------------------------------------------------------------}
function InStr(index : byte; var string1, string2 : string) : byte;
var
   tempstring : string;
begin
   tempstring := copy(string2, index, length(string2)-index);
   InStr := pos(string1, tempstring) + index - 1;
end;
 
 
 
 
{------------------------------------------------------------------------}
{ 'StrMatcher' -String Matching Procedure, Written by Kevin Currie, '94  }
{                                                                        }
{     StrMatcher accepts two pointers and (w/o case sensitivity) tries   }
{  to determine how well their strings match.  It then returns a percent }
{  value of its tests into a shortint.                                   }
{                                                                        }
{------------------------------------------------------------------------}
function strmatcher(var string1, string2 : string) : shortint;
var
   strn1, strn2, tmpstr1, tmpstr2 : string;
   len1, len2, short : byte;
   stest, which, loop : longint;
   postest1, postest2 : integer;
   perc1, perc2, perc3 : real;
   retval : shortint;
label
   string_match_100,
   string_match_len;
begin
   { ---===> Don't yell at me about the goto's, they are there for speed  }
   {         and clarity.  (It's clearer than a HUGE block under an if)   }
 
   { ---===> UpperCase the strings to see if that is where the difference }
   {         lies, and also to make the other comparisons easier.         }
 
   strn1 := string1;
   len1 := length(string1);                 { I make backup copies        }
   for loop := 1 to len1 do                 { because var is just another }
      strn1[loop] := upcase(strn1[loop]);   { way of saying pointer...    }
   strn2 := string2;                        { In other words if I didn't  }
   len2 := length(string2);                 { I would modify the original }
   for loop := 1 to len2 do                 { strings...                  }
      strn2[loop] := upcase(strn2[loop]);
 
 
   { ---===> See of the capitalized strings match }
   if (strn1 = strn2) then
   begin
      retval := 100;
      goto string_match_100;
   end; {if}
 
   { ---===> Test 1 checks the occurence of chars from string1     }
   {         against the chars in string2                          }
   stest := 0;
   for loop := 1 to len1 do
   begin
      tmpstr1 := strn1[loop];
      if (pos(tmpstr1, strn2) > 0) then inc(stest);
   end; {for}
   perc2 := stest / len1;
   stest := 0;
   for loop := 1 to len2 do
   begin
      tmpstr2 := strn2[loop];
      if (pos(tmpstr2, strn1) > 0) then inc(stest);
   end; {for}
   perc3 := stest / len2;
   perc1 := (perc3 + perc2) / 2;
   if (perc1 < 0) then perc1 := 0;

   { ---===> Test 2 Adds the Values of all the charcters in the    }
   {         string and then takes a percent of 1 vs 2.            }
 
   stest := 0;
   which := 0;
   for loop := 1 to len1 do                { ---===> the shl 4's and the  }
      stest := stest + ord(strn1[loop]);   {         shr 2's below are to }
   stest := stest shl 4;                   {         add some more weight }
   for loop := 1 to len2 do                {         to the difference.   }
      which := which + ord(strn2[loop]);
   which := which shl 4;
   loop := stest shr 2;
   if (which > stest) then loop := which shr 2;
   perc2 := 1 - (abs(stest - which) / loop);
   if (perc2 < 0) then perc2 := 0;
 
   { ---===> Test 3 checks the character position differences between  }
   {         the two strings.                                          }
   {                                                                   }
   {         NOTE:  A string being shorter than another can cause this }
   {                test to fail quite badly so null characters are    }
   {                placed in the shorter string where there are char  }
   {                mismatches until the strings are equal in length.  }
 
   if (len1 = len2) then goto string_match_len;
 
   tmpstr1 := '';
   tmpstr2 := '';
      loop :=  1;
 
   if (len1 > len2) then
   begin
      short := len1 - len2;
      which := 2;
   end else
   begin
      short := len2 - len1;
      which := 1;
   end; {if/else}
 
   while (short <> 0) do
   begin
      if (strn1[loop] = strn2[loop]) then
      begin
         case which of
            1:   tmpstr1 := tmpstr1 + strn2[loop];
            2:   tmpstr1 := tmpstr1 + strn1[loop];
         end; {case}
      end else
      begin
         case which of
            1:
            begin
               tmpstr1 := tmpstr1 + #0;
               tmpstr2 := copy(strn1, loop, (len1-loop)+1);
                 strn1 := concat(tmpstr1, tmpstr2);
               dec(short);
            end; {case1}
            2:
            begin
               tmpstr1 := tmpstr1 + #0;
               tmpstr2 := copy(strn2, loop, (len2-loop)+1);
                 strn2 := concat(tmpstr1, tmpstr2);
               dec(short);
            end; {case2}
         end; {case}
      end; {if/else}
      inc(loop);
   end; {while}
 
   len1 := length(strn1);      { ---===> Reset these after the loop that }
   len2 := length(strn2);      {         makes them the same length.     }
 
 string_match_len: {label}
 
   { ---===> Now that we have the string lengths the same lets check the }
   {         character positions.                                        }
 
   stest := 0;
   for loop := 1 to len1 do
      stest := stest + loop + loop - 1;
   which := stest;
   for loop := 1 to len1 do
   begin
      tmpstr1  := strn1[loop];
      tmpstr2  := strn2[loop];
      postest1 :=  len1 - abs(instr(loop, tmpstr2, strn1));
      postest2 :=  len2 - abs(instr(loop, tmpstr2, strn2));
      stest    := stest - (postest1 + postest2);
   end;
   stest := which - abs(stest);
   which := which + (len1 div 2);
   perc3 := stest / which;
   if (perc3 < 0) then perc3 := 0;
 
   { ---===> Average the results of the 3 tests.         }
   {         They are weighted hence the 80, 10 and 10.  }
 
   retval := trunc(((perc1 * 80) + (perc2 * 10) + (perc3 * 10)));
 
string_match_100: {label}
 
   strmatcher := retval; { ---===> Return Percent Difference. }
end; {StrMatcher}
 
 
 
 
begin       { ---===> Stupid 5 line example. }
   clrscr;
   string_a := 'Hello World';
   string_b := 'Hello Wolrd';
   writeln('String Match Percent:', strmatcher(string_a, string_b):5);
   readln;
end. {main} { ---===> hey, I use C also :-)  }

