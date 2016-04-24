(*
  Category: SWAG Title: TEXT EDITING ROUTINES
  Original name: 0010.PAS
  Description: Justification Routine
  Author: SWAG SUPPORT TEAM
  Date: 02-03-94  16:07
*)

UNIT JUSTIFY;

INTERFACE

PROCEDURE JustifyLine (VAR LINE : STRING; Printwidth : BYTE);

IMPLEMENTATION

PROCEDURE JustifyLine (VAR LINE : STRING; Printwidth : BYTE);
{ justify line to a length of printwidth by putting extra blanks between
  words, from right to left.  The line currently has one blank between words.}

VAR
   blanks,               {# of blanks to be inserted}
   gaps,                 {# of gaps between words}
   n,                    {amount to expand 1 gap}
   dest,                 {new place for moved char}
   source : INTEGER;     {source column of that char}
   len    : BYTE ABSOLUTE Line;

BEGIN {justify}

           IF (LINE > '') AND (len < printwidth) THEN
                  BEGIN
                  {set hard spaces for indents}
                  source := 1;
                  WHILE (LINE [source] = ' ') AND (source < len) DO
                        BEGIN
                        LINE [source] := #0;
                        INC(source);
                        END;

                  {count # of gaps between words}
                  gaps := 0;
                  FOR source := 1 TO len DO
                      IF LINE [source] = ' ' THEN gaps := SUCC (gaps);

                  {find # of blanks needed to stretch the line}
                  blanks := printwidth - len;
                  {shift characters to the right, distributing extra blanks}
                  {between the words (in the gaps)}
                  dest := printwidth;
                  source := len;
                  WHILE gaps > 0 DO
                        BEGIN {expand line}
                        IF LINE [source] <> ' ' THEN
                           BEGIN {shift char}
                           LINE [dest] := LINE [source];   {move char, leave blank}
                           LINE [source] := ' ';
                           END
                        ELSE
                           BEGIN  {leave blanks}
                           {find # of blanks for this gap, skip that many}
                           {(now blank) columns}
                           n := blanks DIV gaps;
                           dest := dest - n;
                           gaps := PRED (gaps);
                           blanks := blanks - n;
                           END;
                        {step to next source and dest characters}
                        source := PRED (source);
                        dest := PRED (dest)
                        END; {expand line}

                 LINE[0] := CHR(printwidth);
                 FOR source := 1 TO len DO
                     IF LINE [source] = #0 THEN LINE [source] := #32;
                 END;

        END; {justify procedure}
END.
