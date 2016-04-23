{
> ..Well.. I am back at writing a chat door for the third time.. and am
> havin trouble with wrapping the text.  It seems that when it wraps the
> text to the next line it won't remove the text on the previous line,
> and sometimes it won't wrap at all..  I don't have very dependable code
> for this purpose so any help code is appreciated.. (I am using RMdoor
> 4.2 right now..anybody seen anything better??).

Hope this helps...
}
{$R-,S-,I+,D+,F-,V+,B-,N-,L+ }
{$M 2048,0,0 }

PROGRAM WordWrap(INPUT,OUTPUT);
USES CRT;

CONST
   FKeyCode          = #0;
   Space             = ' ';
   Hyphen            = '-';
   BackSpace         = ^H;
   CarriageReturn    = ^M;
   MaxWordLineLength = 80;

VAR
   WordLine  : STRING[MaxWordLineLength];
   Index1    : BYTE;
   Index2    : BYTE;
   InputChar : CHAR;

BEGIN
  WordLine  := '';
  Index1    := 0;
  Index2    := 0;
  InputChar := Space;

  AssignCRT(INPUT);
  AssignCRT(OUTPUT);
  Reset(INPUT);
  ReWrite(OUTPUT);
  Writeln('Enter text (ENTER to stop) : ');

  InputChar := READKEY;

  {Do the job.}
  WHILE (InputChar <> CarriageReturn) DO
    BEGIN
      CASE InputChar OF
        BackSpace: {write destructive backspace & remove char from WordLine}
          BEGIN
            Write(OUTPUT,BackSpace,Space,BackSpace);
            Delete(WordLine,(LENGTH(WordLine) - 1),1)
          END;
        FKeyCode: {user pressed a function key, so dismiss it}
          BEGIN
            InputChar := READKEY; {function keys send two-char scan code!}
            InputChar := Space
          END
        ELSE {InputChar contains a valid char, so deal with it}
          BEGIN
            Write(OUTPUT,InputChar);
            WordLine := (WordLine + InputChar);
            IF (Length(WordLine) >= (MaxWordLineLength - 1)) THEN
             {we have to do a word-wrap}
              BEGIN
                Index1 := (MaxWordLineLength - 1);
                WHILE ((WordLine[Index1] <> Space)
                  AND (WordLine[Index1] <> Hyphen) AND (Index1 <> 0))
                    DO Index1 := (Index1 - 1);
                      IF (Index1 = 0)
                        THEN  {whoah, no space was found to split line!}
                          Index1 := (MaxWordLineLength - 1); {forces split}
                      Delete(WordLine,1,Index1);
                      FOR Index2 := 1 TO LENGTH(WordLine) DO
                        Write(OUTPUT,BackSpace,Space,BackSpace);
                      Writeln(OUTPUT);
                      Write(OUTPUT,WordLine)
              END
          END
      END; {CASE InputChar}
      {Get next key from user.}
      InputChar := READKEY
    END; {WHILE (InputChar <> CarriageReturn)}

  {Wrap up the program.}
  Writeln(OUTPUT);
  Writeln(OUTPUT);
  Close(INPUT);
  Close(OUTPUT)
END.
