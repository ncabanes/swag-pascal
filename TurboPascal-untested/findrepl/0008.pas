{
> I need help on making a Search Procedure in TURBO PASCAL.
> what I want it to do is to open the contents in a Text File
> search For a given String. and diplay that Record or line With that
> given String!!!

Here is a Program that will search a Text File and display the lines
of Text With the search String in it.
}

Program Search;
Type
  BigString = String[132];
Var
  FileName: String[14];
  FileVar: Text;
  LineNumber: Integer;
  OneLine, Temporary, SubString: BigString;

{ Make all Chars in S upper case}
Procedure UpperCase(Var S: BigString);
Var
  I: Integer;
begin
  For I := 1 to Length(S) do
    S[I] := Upcase(S[I]);
end;

begin
  Write('Search what Text File? ');
  Readln(FileName);
  Assign(FileVar, FileName);
  Repeat
    Writeln;
    Reset(FileVar);
    Write('Search for? (Enter to quit) ');
    Readln(SubString);
    if Length(SubString) > 0 then
    begin
      UpperCase(SubString);
      LineNumber := 0;
      While not Eof(FileVar) do
      begin
        Readln(FileVar, OneLine);
        Inc(LineNumber);
        Temporary := OneLine;
        UpperCase(Temporary);
        if Pos(SubString, Temporary) >0
          Then Writeln(LineNumber:3, ': ', OneLine)
      end
    end
  Until Length(SubString) = 0
end.
