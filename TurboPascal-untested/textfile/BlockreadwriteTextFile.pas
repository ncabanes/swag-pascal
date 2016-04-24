(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0025.PAS
  Description: BLOCKREAD/WRITE Text file
  Author: JAN DOGGEN
  Date: 11-02-93  06:25
*)

{
JAN DOGGEN

> I have already written the parts that open and read the File and find the
> Record I need to update.  Now I want to replace part of the String of
> Characters which comprise this Record, With the Record remaining in its
> location in the File.

No, if you use a Text File (Var T: Text) it's either read or Write.

 1. if you only replace 'n' Characters With another 'n' Characters, it
 is no big problem, although hardly an elegant solution:
 you can Type it as a File of Byte, then read /Write each String
 using something like:
}

Procedure BlockWriteStr(Var F : File; S : String);
Var
  L, Written : Word;
begin
  L := Length(S) + 1;
  BlockWrite(File(F), S[0], L, Written);
  Assert(L = Written, 'Error writing to disk (disk full ?)');
end;


Procedure BlockReadStr(Var F : File; Var S : String);
Var
  ReadIn : Word;
begin
  BlockRead(File(F), S[0], SizeOf(Byte));
  BlockRead(File(F), S[1], Ord(S[0]), ReadIn);
  Assert(Ord(S[0]) = ReadIn, 'Error reading from disk');
end;

{ Of course, you'll have to remember your FilePos().

 2. if you replace With a different number of Chars, I cannot help
 you, other than suggesting you use an input and output Text File,
 and reWrite the whole thing. Not very elegant either.

 BTW, as I am still in my editor, I might as well copy this too:
}

Function SubstituteStr(Original, Part1, Part2 : String): String;
(* Replaces all <Part1> subStrings in String <Original> With <Part2>.
 *
 * Example:
 *   SubstituteStr('Abracadabra','ra','rom') ==> 'Abromcadabrom'
 * The Function does not work recursively, so:
 *   SubstituteStr('Daaaaaaaar','aa','a') returns 'Daaaar', not 'Dar'.*)
Var
  S       : String;
  P, L, T : Byte;
begin
  if Original = '' then
  begin
    SubstituteStr := '';
    Exit;
  end;

  S := '';
  L := Length(Part1);
  T := 1;
  P := Pos(Part1,Copy(Original,T,255));

  While P <> 0 DO
  begin
    S := S + Copy(Original, T, P - 1) + Part2;
    T := T + P + L - 1;
    P := Pos(Part1, Copy(Original, T, 255));
  end;
  SubstituteStr := S + Copy(Original, T, 255);
end;

Function SubstituteStrX(Original, Part1, Part2 : String) : String;
(* Like SubstituteStr, but now the Function works recursively, so
*   SubstituteStrX('Daaaaaaaar','aa','a') returns 'Dar'. *)
Var
  S       : String;
  P, L, T : Byte;
begin
  if Original = '' then
  begin
    SubstituteStrX := '';
    Exit;
  end;

  S := Original;
  T := 1;
  L := Length(Part1);
  P := Pos(Part1,S);

  While P <> 0 DO
  begin
    S := Copy(S, 1, P - 1) + Part2 + Copy(S, P + L, 255);
    P := Pos(Part1, S);
  end;
  SubstituteStrX := S;
end;

