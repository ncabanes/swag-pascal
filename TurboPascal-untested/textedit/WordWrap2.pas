(*
  Category: SWAG Title: TEXT EDITING ROUTINES
  Original name: 0005.PAS
  Description: Word Wrap #2
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  14:08
*)

{
>    P.S.  A pre-made Unit to do a Word-wrap Function might also be nice.
}

Unit WordWrap;

Interface

Uses
  Crt;

Type
  Strn80 = String[80];

Const
  MaxWordLineLength : Byte = 80;

Var
  WordLine  : Strn80;
  Index1    : Byte;
  Index2    : Byte;

Procedure ResetWrapStrn;
Procedure WrapStrn (InputStrn: Strn80);

Implementation

Procedure ResetWrapStrn;
begin
  Index1 := 0;
  Index2 := 0;
  Wordline := '';
end;

Procedure WrapStrn (InputStrn: Strn80);
Var
  Count : Byte;
  InputChar : Char;
begin
  For Count := 1 to Length (InputStrn) do
  begin
    InputChar := InputStrn[Count];
    Case InputChar OF
      ^H: {Write destructive backspace & remove Char from WordLine}
          begin
            Write(^H,' ',^H);
            DELETE(WordLine,(LENGTH(WordLine) - 1),1)
          end;
      #0: {user pressed a Function key, so dismiss it}
          begin
            InputChar := ReadKey; {Function keys send two-Char scan code!}
            InputChar := ' '
          end;
      #13: { it is an enter key.. reset everything and start on a new line}
          begin
            Writeln;
            Index1 := 0; Index2 := 0; Wordline := '';
          end;
      else {InputChar contains a valid Char, so deal With it}
      begin
        Write(InputChar);
        WordLine := (WordLine + InputChar);
        if (LENGTH(WordLine) >= (MaxWordLineLength - 1)) then
        {we have to do a Word-wrap}
        begin
          Index1 := (MaxWordLineLength - 1);
          While ((WordLine[Index1] <> ' ') and (WordLine[Index1] <> '-')
                  and (Index1 <> 0)) DO
            Index1 := (Index1 - 1);
          if (Index1 = 0) then {whoah, no space was found to split line!}
            Index1 := (MaxWordLineLength - 1); {forces split}
          DELETE(WordLine,1,Index1);
          For Index2 := 1 to LENGTH(WordLine) DO
            Write(^H,' ',^H);
          Writeln;
          Write(WordLine)
        end
      end
    end; {CASE InputChar}
  end;
end;

begin {WordWrap}
{Initialize the Program.}
WordLine  := '';
Index1    := 0;
Index2    := 0;
end.

