{$A+,B+,D+,E-,F+,G+,I+,L+,N-,O+,P+,Q+,R+,S+,T+,V-,X+,Y+}
{$M 65520,100000,655360}
{
Program compiled and tested With BP 7.0

WARNING since this Program is not using the fastest algorithm to
find it's Anagrams, long Delays can be expected For large
input-Strings.

Test have shown the following results:

  Length of Input       Number of anagrams found

        2                         2
        3                         6
        4                        24
        5                       120
        6                       720
        7                      5040

As can plainly be seen from this, the number of Anagrams For a
String of length N is a direct Function of the number of Anagrams
For a String of N-1. In fact the result is f(N) = N * f(N-1).

You might have recognised the infamous FACTORIAL Function!!!

Type
  MyType = LongInt;

Function NumberOfAnagrams(Var InputLen : MyType) : MyType;

  Var
    Temp : MyType;

  begin
    Temp := InputLen;
    if Temp >1 then
    begin
      Temp := Temp - 1;
      NumberOfAnagrams := InputLen * NumberOfAnagrams(Temp);
    end else
      NumberOfAnagrams := InputLen;
  end;

The above Function has been tested and found to work up to an input
length of 12. After that, Real numbers must be used. As a side note
the Maximum value computable was 1754 With MyType defined as
Extended and Numeric-Coprocessor enabled of course. Oh and BTW, the
parameter is passed as a Var so that the Stack doesn't blow up when
you use Extended Type!!!! As a result, you can't pass N-1 to the
Function. You have to STORE N-1 in a Var and pass that as parameter.
The net effect is that With Numeric Copro enabled, at 1754 it blows
up because of a MATH OVERFLOW, not a STACK OVERFLOW!!!

Based on these findings, I assume the possible anagrams can be
computed a lot faster simply by Realising that the possible Anagrams
For an input length of (N) can be found by finding all anagrams for
an input Length of (N-1) and inserting the additional letter in each
(N) positions in those Strings. Since this can not be done
recursively in memory, the obvious solution would be to to output
the anagrams strating With the first 4 or 5 caracters to a File,
because those can be found quickly enough, and then to read in each
String and apply the following caracters to each and Repeat this
process Until the final File is produced.

Here is an example:

      Anagrams For ABCD

      Output Anagrams For AB to File

        Giving      AB and BA

      read that in and apply the next letter in all possible positions

        Giving
                  abC
                  aCb
                  Cab
                &
                  baC
                  bCa
                  Cba

      Now Apply the D to this and get

                  abcD
                  abDc
                  aDbc
                  Dabc
                &

                  acbD
                  acDb
                  aDcb
                  Dacb

      Etc... YOU GET THE POINT!!!

BTW Expect LARGE Files if you become too enthousiastic With this!!!

  An Input of just 20 caracters long will generate a File of

        2,432,902,008,176,640,000 Anagrams
        That's
          2.4 Quintillion Anagrams

  Remember that each of those are 20 caracters long,
  add Carriage-return and line-feeds and you've got yourself a
  HUGE File ;-)

  In fact just a 10 Caracter input length will generate 3.6 Million
  Anagrams from a 10 Caracter input-String. Again add Cr-LFs and
  you've got yourself a 43.5 MEGAByte File!!!!!! but consider you
  are generating it from the previous File which comes to 3.5 MEG
  For an Input Length of 9 and you've got yourself 45 MEG of DISK in
  use For this job.

}
Uses
  Strings, Crt;

Const
  MaxAnagram = 1000;

Type
  AnagramArray = Array[0..MaxAnagram] of Word;
  AnagramStr   = Array[0..MaxAnagram] of Char;

Var
  Target       : AnagramStr;
  Size         : Word;
  Specimen     : AnagramArray;
  Index        : Word;
  AnagramCount : LongInt;

Procedure working;
Const
  CurrentCursor : Byte = 0;
  CursorArray   : Array[0..3] of Char = '|/-\';
begin
  CurrentCursor := Succ(CurrentCursor) mod 4;
  Write(CursorArray[CurrentCursor], #13);
end;

Procedure OutPutAnagram(Target : AnagramStr;
                        Var Specimen : AnagramArray; Size : Word);
Var
  Index : Word;
begin
  For Index := 0 to (Size - 1) do
    Write(Target[Specimen[Index]]);
  Writeln;
end;

Function IsAnagram(Var Specimen : AnagramArray; Size : Word) : Boolean;
Var
  Index1,
  Index2 : Word;
  Valid  : Boolean;
begin
  Valid  := True;
  Index1 := 0;
  While (Index1<Pred(Size)) and Valid do
  begin
    Index2 := Index1 + 1;
    While (Index2 < Size) and Valid do
    begin
      if Specimen[Index1] = Specimen[Index2] then
        Valid := False;
      inc(Index2);
    end;
    inc(Index1);
  end;
  IsAnagram := Valid;
end;

Procedure FindAnagrams(Target : AnagramStr;
                       Var Specimen : AnagramArray; Size : Word);
Var
  Index : Word;
  Carry : Boolean;
begin
  Repeat
    working;
    if IsAnagram(Specimen, Size) then
    begin
      OutputAnagram(Target, Specimen, Size);
      inc(AnagramCount);
    end;
    Index := 0;
    Repeat
      Specimen[Index] := (Specimen[Index] + 1) mod Size;
      Carry := not Boolean(Specimen[Index]);
      Inc(Index);
    Until (not Carry) or (Index >= Size);
  Until Carry and (Index >= Size);
end;

begin
  ClrScr;
  Write('Enter anagram Target: ');
  readln(Target);
  Writeln;
  AnagramCount := 0;
  Size := Strlen(Target);
  For Index := 0 to MaxAnagram do
    Specimen[Index] := 0;
  For Index := 0 to Size - 1 do
    Specimen[Index] := Size - Index - 1;
  FindAnagrams(Target, Specimen, Size);
  Writeln;
  Writeln(AnagramCount, ' Anagrams found With Source ', Target);
end.
