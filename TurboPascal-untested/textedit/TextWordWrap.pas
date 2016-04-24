(*
  Category: SWAG Title: TEXT EDITING ROUTINES
  Original name: 0009.PAS
  Description: Text Word Wrap
  Author: MIKE COPELAND
  Date: 02-03-94  07:05
*)


{
   Here's some code I found in this echo a number of years ago - I don't
recall who should get credit for it.  I put it into my own program,
which uses some other Units, and I hope I've sanitized it enough to make
it generic...

Uses a FASTWRITE routine that can be found in SWAG G.D. 02/01/94 }


program WordWrap;
uses CRT;
const
   FKeyCode          = #00;
   Space             = ' ';
   Hyphen            = '-';
   BackSpace         = #08;
   C_R               = #13;
   MaxWordLineLength = 60;
   MAXLINES          = 6;  { Maximum # of lines in "box" }
var
   WordLine  : string[MaxWordLineLength];
   Index1    : byte;
   Index2    : byte;
   InputChar : char;
   LINE      : byte;               { current output line }
   LC        : byte;                        { Line Count }
   I         : Word;
   S1        : string;
   LA        : array[1..MAXLINES] of string[MaxWordLineLength];
begin
  WordLine := ''; Index1 := 0; Index2 := 0; InputChar := Space;
  ClrScr; Write ('Enter text (',MAXLINES:0,' line maximum): ');
  for I := 1 to MAXLINES do  { clear storage array }
    LA[I] := '';
  InputChar := ReadKey;
  LC := 1; LINE := 6; gotoXY (1,20);               { work area }
  while LC <= MAXLINES do
    begin
      case InputChar of
        #13      : begin                { C/R - terminate line }
                     S1 := WordLine;
                     Writeln (S1); LA[LC] := S1; Inc(LC);
                     gotoXY (1,20); ClrEol; WordLine := ''
                   end;
        BackSpace:
          begin
            Write(BackSpace,Space,BackSpace);
            if Length(WordLine) > 0 then Dec(WordLine[0])
          end;
        FKeyCode:                         { flush function key }
          begin
            InputChar := ReadKey; InputChar := Space
          end
        else                                      { valid char }
          begin
            Write(InputChar); WordLine := WordLine+InputChar;
            if (Length(WordLine) >= (MaxWordLineLength - 1)) then
              begin                  { have to do a word-wrap }
                Index1 := MaxWordLineLength-1;
                while ((WordLine[Index1] <> Space) and
                       (WordLine[Index1] <> Hyphen) and
                       (Index1 <> 0))
                  do Dec(Index1);
                if (Index1 = 0) then  {no space was found to split!}
                  Index1 := (MaxWordLineLength-1);    {forces split}
                S1 := Copy(WordLine,1,Index1);
                Delete(WordLine,1,Index1);
                for Index2 := 1 TO LENGTH(WordLine) do
                  Write(BackSpace,Space,BackSpace);
                FastWrite (1,LINE,LONORM,S1); Inc(LINE);
                LA[LC] := S1; Inc(LC);
                gotoXY (1,20) ClrEol; Write(WordLine)
              end
          end
      end;                                          {case InputChar}
      InputChar := ReadKey                  {Get next key from user}
    end;                       {while (InputChar <> CarriageReturn)}
end.

