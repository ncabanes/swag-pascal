
(*
  A unit to implement FULL ANSI output.  Useful for a BBS or DOOR program
  where you would want to send string out over the modem.  Simply call
  your modem routine to :

             SENDSTRING(port,ANSIGoToXY(1,1))

  Would reposition the cursor on the remote terminal.  Get the idea ??

  The thing will EVEN play ANSI music !!

  Gayle Davis 1/24/94

1) Added allowance for "esc[M " as a valid music prefix.  It is used
   occasionally.

2) Changed the effect of "esc[0m" from "NormVideo" to "textattr:=7",
   which is what "esc[0m" literally means.  NormVideo just restores
   startup colors, which could be anything.

3) Added "HighVideo" line to take effect *immediately* when "esc[1m"
   ("Bold") is encountered.  Otherwise, "esc[1m" by itself would not
   activate "Bold".

4) Changed "{blink on}" from "5 : textattr := textattr +  blink;"
.                            "5 : textattr := textattr or blink;"
.                                                      ^^
   The "blink ON" was turning blink OFF when blink was turned ON
   with blink already ON.

5) Added "textattr and blink" to preserve blink status in the
   "{general foregrounds}" subroutine.

6) Changed default tempo assignment from "Min1:=120" to "Min1:=120/4"
   in order to be consistent with the way the unit deals with tempo.

7) Added an initialization line of "TextAttr:=7;" to allow for the
   fact that some ANSI artists assume that the screen is normal white
   on black to start with.  (My screen is NOT that color!)

DAVID DANIEL ANDERSON
09/08/94

*)

UNIT AnsiIO;

INTERFACE

   USES
      CRT,
      Graph3;  { GRAPH3.TPU is included in the BORLAND distribution diskettes }

   FUNCTION ANSIClrScr : string;
   FUNCTION ANSIClrEol : string;
   FUNCTION ANSIGotoXY(X, Y : word) : string;
   FUNCTION ANSIUp(Lines : word) : string;
   FUNCTION ANSIDown(Lines : word) : string;
   FUNCTION ANSIRight(Cols : word) : string;
   FUNCTION ANSILeft(Cols : word) : string;
   FUNCTION ANSIColor(Fg, Bg : integer) : string;
   FUNCTION ANSIMusic(s : string) : string;
   PROCEDURE ANSIWrite(s : string);
   PROCEDURE ANSIWriteLn(s : string);

IMPLEMENTATION

   CONST
      ColorArray : array[0..7] of integer = (0,4,2,6,1,5,3,7);

   VAR
      Bold, TruncateLines : boolean;
      Vari, Octave, Numb : integer;
      Test, Dly, Intern, DlyKeep : longInt;
      Flager, ChartoPlay : char;
      Typom, Min1, Adder : real;

{****************************************************************************}
{***                                                                      ***}
{***       Function that returns the ANSI code for a Clear Screen.        ***}
{***                                                                      ***}
{****************************************************************************}
   FUNCTION ANSIClrScr : string;
      BEGIN
         ANSIClrScr := #27+'[2J';
      END;

{****************************************************************************}
{***                                                                      ***}
{***    Function that returns the ANSI code for a Clear to End of Line.   ***}
{***                                                                      ***}
{****************************************************************************}
   FUNCTION ANSIClrEol : string;
      BEGIN
         ANSIClrEol := #27+'[K';
      END;

{****************************************************************************}
{***                                                                      ***}
{***   Function that returns the ANSI code to move the cursor to (X,Y).   ***}
{***                                                                      ***}
{****************************************************************************}
   FUNCTION ANSIGotoXY(X, Y : word) : string;
      VAR
         XStr, YStr : string;

      BEGIN
         str(X,XStr);
         str(Y,YStr);
         ANSIGotoXY := #27+'['+YStr+';'+XStr+'H';
      END;

{****************************************************************************}
{***                                                                      ***}
{***  Function that returns the ANSI code to move the cursor up "Lines"   ***}
{***                         number of lines.                             ***}
{***                                                                      ***}
{****************************************************************************}
   FUNCTION ANSIUp(Lines : word) : string;
      VAR
         LinesStr : string;

      BEGIN
         str(Lines,LinesStr);
         ANSIUp := #27+'['+LinesStr+'A';
      END;

{****************************************************************************}
{***                                                                      ***}
{***  Function that returns the ANSI code to move the cursor down "Lines" ***}
{***                        number of lines.                              ***}
{***                                                                      ***}
{****************************************************************************}
   FUNCTION ANSIDown(Lines : word) : string;
      VAR
         LinesStr : string;

      BEGIN
         str(Lines,LinesStr);
         ANSIDown := #27+'['+LinesStr+'B';
      END;

{****************************************************************************}
{***                                                                      ***}
{***     Function that returns the ANSI code to move the cursor "Cols"    ***}
{***                         positions forward.                           ***}
{***                                                                      ***}
{****************************************************************************}
   FUNCTION ANSIRight(Cols : word) : string;
      VAR
         ColsStr : string;

      BEGIN
         str(Cols,ColsStr);
         ANSIRight := #27+'['+ColsStr+'C';
      END;

{****************************************************************************}
{***                                                                      ***}
{***     Function that returns the ANSI code to move the cursor "Cols"    ***}
{***                        positions backward.                           ***}
{***                                                                      ***}
{****************************************************************************}
   FUNCTION ANSILeft(Cols : word) : string;
      VAR
         ColsStr : string;

      BEGIN
         str(Cols,ColsStr);
         ANSILeft := #27+'['+ColsStr+'D';
      END;


{****************************************************************************}
{***                                                                      ***}
{***    Function that returns the ANSI code to change the screen color    ***}
{***             to an "Fg" foreground and a "Bg" background.             ***}
{***                                                                      ***}
{****************************************************************************}
   FUNCTION ANSIColor(Fg, Bg : integer) : string;
      VAR
         FgStr, BgStr, Temp : string;

      BEGIN
         str(ColorArray[Fg mod 8] + 30, FgStr);
         str(ColorArray[Bg mod 8] + 40, BgStr);
         Temp := #27+'[';
         if Bg > 7 then
            Temp := Temp+'5;'
         else
            Temp := Temp+'0;';
         if Fg > 7 then
            Temp := Temp+'1;'
         else
            Temp := Temp+'2;';
         ANSIColor := Temp+FgStr+';'+BgStr+'m';
      END;

{****************************************************************************}
{***                                                                      ***}
{*** Function that returns an ANSI code representing a music string ("s") ***}
{***                                                                      ***}
{****************************************************************************}
   FUNCTION ANSIMusic(s : string) : string;

      BEGIN
         ANSIMusic := #27+'[MF'+s+#14;
      END;

{****************************************************************************}
{***                                                                      ***}
{***  Procedure that simulates BASIC's "PLAY" procedure.  Will also work  ***}
{***      with ANSI codes.  Taken from PC Magazine Volume 9 Number 3      ***}
{***                                                                      ***}
{****************************************************************************}
   PROCEDURE Play(SoundC : string);
      FUNCTION IsNumber(ch : char) : boolean;
         BEGIN
            IsNumber := (CH >= '0') AND (CH <= '9');
         END;

   {Converts a string to an integer}
      FUNCTION value(s : string) : integer;
         VAR
            ss, sss : integer;
         BEGIN
            Val(s, ss, sss);
            value := ss;
         END;

   {Plays the selected note}
      PROCEDURE sounder(key : char; flag : char);
         VAR
            old, New, new2 : Real;
         BEGIN
            adder := 1;
            old := dly;
            New := dly;
            intern := Pos(key, 'C D E F G A B')-1;
            IF (flag = '+') AND (key <> 'E') AND (key <> 'B') {See if note}
               THEN Inc(intern);                              {is sharped }
            IF (flag = '-') AND (key <> 'F') AND (key <> 'C')
               THEN Dec(intern);                              {or a flat. }
            WHILE SoundC[vari+1] = '.' DO
               BEGIN
                  Inc(vari);
                  adder := adder/2;
                  New := New+(old*adder);
               END;
            new2 := (New/typom)*(1-typom);
            sound(Round(Exp((octave+intern/12)*Ln(2)))); {Play the note}
            Delay(Trunc(New));
            Nosound;
            Delay(Trunc(new2));
         END;

   {Calculate delay for a specified note length}
      FUNCTION delayer1 : integer;
         BEGIN
            numb := value(SoundC[vari+1]);
            delayer1 := Trunc((60000/(numb*min1))*typom);
         END;

   {Used as above, except reads a number >10}

      FUNCTION delayer2 : Integer;
         BEGIN
            numb := value(SoundC[vari+1]+SoundC[vari+2]);
            delayer2 := Trunc((60000/(numb*min1))*typom);
         END;

      BEGIN                           {Play}
         SoundC := SoundC+' ';
         FOR vari := 1 TO Length(SoundC) DO
            BEGIN                     {Go through entire string}
               SoundC[vari] := Upcase(SoundC[vari]);
               CASE SoundC[vari] OF
{Check to see}    'C','D','E',
{if char is a}    'F','G','A',
{note}            'B' : BEGIN
                           flager := ' ';
                           dlykeep := dly;
                           chartoplay := SoundC[vari];
                           IF (SoundC[vari+1] = '-') OR
                              (SoundC[vari+1] = '+') THEN
{Check for flats & sharps}    BEGIN
                                 flager := SoundC[vari+1];
                                 Inc(vari);
                              END;
                           IF IsNumber(SoundC[vari+1]) THEN
                              BEGIN
                                 IF IsNumber(SoundC[vari+2]) THEN
                                    BEGIN
                                       test := delayer2;
{Make sure # is legal}                 IF numb < 65 THEN
                                          dly := test;
                                       Inc(vari, 2);
                                    END
                                 ELSE
                                    BEGIN
                                       test := delayer1;
{Make sure # is legal}                 IF numb > 0 THEN
                                          dly := test;
                                       Inc(vari);
                                    END;
                              END;
                           sounder(chartoplay, flager);
                           dly := dlykeep;
                        END;
{Check for}       'O' : BEGIN
{octave change}            Inc(vari);
                           CASE SoundC[vari] OF
                              '-' : IF octave > 1 THEN Dec(octave);
                              '+' : IF octave < 7 THEN Inc(octave);
                              '1','2','3',
                              '4','5','6',
                              '7' : octave := value(SoundC[vari])+4;
                           ELSE Dec(vari);
                           END;
                        END;
{Check for a}     'L' : IF IsNumber(SoundC[vari+1]) THEN
{change in length}         BEGIN
{for notes}                   IF IsNumber(SoundC[vari+2]) THEN
                                 BEGIN
                                    test := delayer2;
                                    IF numb < 65 THEN
{Make sure # is legal}                 dly := test;
                                    Inc(vari, 2);
                                 END
                              ELSE
                                 BEGIN
                                    test := delayer1;
                                    IF numb > 0 THEN
{Make sure # is legal}                 dly := test;
                                    Inc(vari);
                                 END;
                           END;
{Check for pause} 'P' : IF IsNumber(SoundC[vari+1]) THEN
{and it's length}          BEGIN
                              IF IsNumber(SoundC[vari+2]) THEN
                                 BEGIN
                                    test := delayer2;
                                    IF numb < 65 THEN
{Make sure # is legal}                 Delay(test);
                                    Inc(vari, 2);
                                 END
                              ELSE
                                 BEGIN
                                    test := delayer1;
                                    IF numb > 0 THEN
{Make sure # is legal}                 Delay(test);
                                    Inc(vari);
                                 END;
                           END;
{Check for}       'T' : IF IsNumber(SoundC[vari+1]) AND
{tempo change}             IsNumber(SoundC[vari+2]) THEN
                           BEGIN
                              IF IsNumber(SoundC[vari+3]) THEN
                                 BEGIN
                                    min1 := value(SoundC[vari+1]+
                                            SoundC[vari+2]+SoundC[vari+3]);
                                    Inc(vari, 3);
                                    IF min1 > 255 THEN
{Make sure # isn't too big}            min1 := 255;
                                 END
                              ELSE
                                 BEGIN
                                    min1 := value(SoundC[vari+1]+
                                            SoundC[vari+2]);
                                    IF min1 < 32 THEN
{Make sure # isn't too small}          min1 := 32;
                                 END;
                              min1 := min1/4;
                           END;
{Check for music} 'M' : BEGIN
{type}                     Inc(vari);
                           CASE Upcase(SoundC[vari]) OF
{Normal}                      'N' : typom := 7/8;
{Legato}                      'L' : typom := 1;
{Staccato}                    'S' : typom := 3/4;
                           END;
                        END;
               END;
            END;
      END;

{****************************************************************************}
{***                                                                      ***}
{***    Procedure to process string "s" and write its contents to the     ***}
{***          screen, interpreting ANSI codes as it goes along.           ***}
{***                                                                      ***}
{****************************************************************************}
   PROCEDURE ANSIWrite(s : string);
      VAR
         SaveX, SaveY : byte;
         MusicStr : string;
         MusicPos : integer;

   {*** Procedure to process the actual ANSI sequence ***}
      PROCEDURE ProcessEsc;
         VAR
            DeleteNum : integer;
            ts : string[5];
            Num : array[0..10] of shortint;
            Color : integer;

         LABEL
            loop;

      {*** Procedure to extract a parameter from the ANSI sequence and ***}
      {*** place it in "Num" ***}
         PROCEDURE GetNum(cx : byte);
            VAR
               code : integer;
            BEGIN
               ts := '';
               WHILE (s[1] in ['0'..'9']) and (length(s) > 0) DO
                  BEGIN
                     ts := ts + s[1];
                     Delete(s,1,1);
                  END;
               val(ts,Num[cx],code)
            END;

         BEGIN
            IF s[2] <> '[' THEN exit;
            Delete(s,1,2);
            IF (UpCase(s[1]) = 'M') and (UpCase(s[2]) in ['F','B',#32]) THEN
{| Added allowance for "esc[M " as a valid music prefix in line above. DDA|}

{play music}   BEGIN
                  Delete(s,1,2);
                  MusicPos := pos(#14,s);
                  Play(copy(s,1,MusicPos-1));
                  DeleteNum := MusicPos;
                  Goto Loop;
               END;
            fillchar(Num,sizeof(Num),#0);
            GetNum(0);
            DeleteNum := 1;
            WHILE (s[1] = ';') and (DeleteNum < 11) DO
               BEGIN
                  Delete(s,1,1);
                  GetNum(DeleteNum);
                  DeleteNum  := DeleteNum + 1;
               END;
            CASE UpCase(s[1]) of
{move up}      'A' : BEGIN
                        if Num[0] = 0 THEN
                           Num[0] := 1;
                        WHILE Num[0] > 0 DO
                           BEGIN
                              GotoXY(wherex,wherey - 1);
                              Num[0] := Num[0] - 1;
                           END;
                        DeleteNum := 1;
                     END;
{move down}    'B' : BEGIN
                        if Num[0] = 0 THEN
                           Num[0] := 1;
                        WHILE Num[0] > 0 DO
                           BEGIN
                              GotoXY(wherex,wherey + 1);
                              Num[0] := Num[0] - 1;
                           END;
                        DeleteNum := 1;
                     END;
{move right}   'C' : BEGIN
                        if Num[0] = 0 THEN
                           Num[0] := 1;
                        WHILE Num[0] > 0 DO
                           BEGIN
                              GotoXY(wherex + 1,wherey);
                              Num[0] := Num[0] - 1;
                           END;
                        DeleteNum := 1;
                     END;
{move left}    'D' : BEGIN
                        if Num[0] = 0 THEN
                           Num[0] := 1;
                        WHILE Num[0] > 0 DO
                           BEGIN
                              GotoXY(wherex - 1,wherey);
                              Num[0] := Num[0] - 1;
                           END;
                        DeleteNum := 1;
                     END;
{goto x,y}     'H',
               'F' : BEGIN
                        if (Num[0] = 0) THEN
                           Num[0] := 1;
                        if (Num[1] = 0) THEN
                           Num[1] := 1;
                        GotoXY(Num[1],Num[0]);
                        DeleteNum := 1;
                     END;
{save current} 'S' : BEGIN
{position}              SaveX := wherex;
                        SaveY := wherey;
                        DeleteNum := 1;
                     END;
{restore}      'U' : BEGIN
{saved position}        GotoXY(SaveX,SaveY);
                        DeleteNum := 1;
                     END;
{clear screen} 'J' : BEGIN
                        if Num[0] = 2 THEN
                           ClrScr;
                        DeleteNum := 1;
                     END;
{clear from}   'K' : BEGIN
{cursor position}       ClrEOL;
{to end of line}        DeleteNum := 1;
                     END;
{change}       'M' : BEGIN
{colors and}            DeleteNum := 0;
{attributes}            WHILE (Num[DeleteNum] <> 0) or (DeleteNum = 0) DO
                           BEGIN
                              CASE Num[DeleteNum] of
{all attributes off}             0 : BEGIN
{ie. normal white on black}             textattr:=7;
{| Changed above line from "NormVideo", which only resets attributes to
   whatever the cursor attribute at startup was.  Changed to textattr:=7
   since "esc[0..m" actually equals "textattr:=7". DDA|}

                                        Bold := false;
                                     END;
{bold on}                        1 : BEGIN
                                        Bold := true;
                                        HighVideo;
{| Added "HighVideo" line, since "esc[1m" by itself would not otherwise
   activate "Bold". DDA|}

                                     END;
{blink on}                       5 : textattr := textattr or blink;
{| Changed from "textattr+blink", which would turn blink off if it was
   already on. DDA|}

{reverse on}                     7 : textattr := ((textattr and $07) shl 4) +
                                     ((textattr and $70) shr 4);
{invisible on}                   8 : textattr := 0;
{general foregrounds}            30..
                                 37 : BEGIN
                                         color := ColorArray[Num[DeleteNum]
                                                  - 30];
                                         IF Bold THEN
                                            color := color + 8;
                                         textcolor((textattr and blink)+color);
{| Added "textattr and blink" to preserve blink status. DDA|}

                                      END;
{general backgrounds}            40..
                                 47 : textbackground(
                                      ColorArray[Num[DeleteNum] - 40]);
                              END;
                              DeleteNum := DeleteNum + 1;
                           END;
                        DeleteNum := 1;
                     END;
{change text}  '=',
{modes}        '?' : BEGIN
                        Delete(s,1,1);
                        GetNum(0);
                        if UpCase(s[1]) = 'H' THEN
                           BEGIN
                              CASE Num[0] of
                                 0 : TextMode(bw40);
                                 1 : TextMode(co40);
                                 2 : TextMode(bw80);
                                 3 : TextMode(co80);
                                 4 : GraphColorMode;
                                 5 : GraphMode;
                                 6 : HiRes;
                                 7 : TruncateLines := false;
                              END;
                           END;
                        if UpCase(s[1]) = 'L' THEN
                           if Num[0] = 7 THEN
                              TruncateLines := true;
                        DeleteNum := 1;
                     END;
            END;
loop:       Delete(s,1,DeleteNum);
         END;

      BEGIN
         WHILE length(s) > 0 DO
            BEGIN
               if s[1] = #27 THEN
                  ProcessEsc
               else
                  BEGIN
                     Write(s[1]);
                     Delete(s,1,1);
                  END;
            END;
      END;

{****************************************************************************}
{***                                                                      ***}
{***         Procedure that calls ANSIWrite, then line feeds.             ***}
{***                                                                      ***}
{****************************************************************************}
   PROCEDURE ANSIWriteLn(s : string);
      BEGIN
         ANSIWrite(s);
         WriteLn;
      END;

   BEGIN
      Octave := 4;
      ChartoPlay := 'N';
      Typom := 7/8;
      Min1 := 120/4;
{| Added "/4" to be consistent with the part of the "Play" procedure
   that reads and sets the tempo. DDA|}

      TruncateLines := false;
      TextAttr:=7;
{| Added above line to account for the fact that some ANSI artists just
   assume that the screen is normal white on black to start with.  DDA|}

   END.
