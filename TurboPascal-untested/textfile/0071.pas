{
Hi. This is a little program I made. It will make a plain text file into a
nice, fancy one. It will make plain text like... ABCDEF to fancy letters like
... ÆßÇδΣƒ. Hope you like it. Bye.
}
Program TextChanger;
Uses
  Crt, Dos;
Procedure TranslateFile (A, B : String);
  Var
    C, D, E : Integer;
    TxtToTranslate : Array [1..80] of String[80];
    L : Array [1..80] of Integer;
    Temp : Integer;
    Temp1 : String;
    OpenUp, OpenUp1 : Text;
    Hi : Char;
    YN : Integer;
  Procedure CFF (Fart : String);
    Var
      DirInfo : SearchRec;
      Choice : Char;
    Begin
      FindFirst(Fart, Archive, DirInfo);
      If DosError = 0 then
        Begin
          ClrScr;
          Writeln ('There''s a file with the same name (',Fart,'). Do you');
          Write ('want to overwrite it (Y/N) [N]? ');
          Choice := Readkey;
          If (Choice <> 'Y') and (Choice <> 'y')
            then halt;
          ClrScr;
        End;
    End;
  Begin
    ClrScr;
    CFF(B);
    C := 0;
    YN := 0;
    D := 0;
    E := 0;
    Temp := 0;
    TextColor(10);
    Writeln;
    Write ('Converting text...');
    Assign (OpenUp, B);
    ReWrite (OpenUp);
    Assign (OpenUp1, A);
    Reset (OpenUp1);
    Repeat
      E := E + 1;
      Read (OpenUp1, Hi);
      Case Hi of
        'a'      : Temp := 224;
        'A'      : Temp := 146;
        'B', 'b' : Temp := 225;
        'C'      : Temp := 128;
        'c'      : Temp := 135;
        'D', 'd' : Temp := 235;
        'E'      : Temp := 228;
        'e'      : Temp := 238;
        'F', 'f' : Temp := 159;
        'G', 'g' : Temp := 103;
        'H', 'h' : Temp := 215;
        'I', 'i' : Temp := 179;
        'J'      : Temp := 245;
        'j'      : Temp := 251;
        'K', 'k' : Temp := 107;
        'L', 'l' : Temp := 156;
        'M', 'm' : Temp := 109;
        'N', 'n' : Temp := 20;
        'O', 'o' : Temp := 237;
        'Q', 'q' : Temp := 113;
        'R', 'r' : Temp := 226;
        'S', 's' : Temp := 115;
        'U', 'u' : Temp := 117;
        'V', 'v' : Temp := 31;
        'W', 'w' : Temp := 119;
        'X', 'x' : Temp := 120;
        'Y', 'y' : Temp := 157;
        'Z', 'z' : Temp := 122;
      End;
      If ((Hi = 'P') or (Hi = 'p')) and ((Hi = 'T') or (Hi = 't'))
        then Temp := 158
        else if (Hi = 'P') or (Hi = 'p')
          then Temp := 112
          else if (Hi = 'T') or (Hi = 't')
            then Temp := 194;
      Case Hi of
        ';'  : Temp := ord(';');
        '.'  : Temp := ord('.');
        '''' : Temp := ord('''');
        ','  : Temp := ord(',');
        '('  : Temp := ord('(');
        ':'  : Temp := ord(':');
        '\'  : Temp := ord('\');
        '/'  : Temp := ord('/');
        '|'  : Temp := ord('|');
        '-'  : Temp := ord('-');
        '+'  : Temp := ord('+');
        '{'  : Temp := ord('{');
        '}'  : Temp := ord('}');
        '['  : Temp := ord('[');
        ']'  : Temp := ord(']');
        '~'  : Temp := ord('~');
        '`'  : Temp := ord('`');
        '"'  : Temp := ord('"');
        '_'  : Temp := ord('_');
        '='  : Temp := ord('=');
        '!'  : Temp := ord('!');
        '?'  : Temp := ord('?');
        '@'  : Temp := ord('@');
        '#'  : Temp := ord('#');
        '$'  : Temp := ord('$');
        '%'  : Temp := ord('%');
        '^'  : Temp := ord('^');
        '&'  : Temp := ord('&');
        '*'  : Temp := ord('*');
        '1'  : Temp := ord('1');
        '2'  : Temp := ord('2');
        '3'  : Temp := ord('3');
        '4'  : Temp := ord('4');
        '5'  : Temp := ord('5');
        '6'  : Temp := ord('6');
        '7'  : Temp := ord('7');
        '8'  : Temp := ord('8');
        '9'  : Temp := ord('9');
        '0'  : Temp := ord('0');
        ' '  : Temp := ord(' ');
      End;
      Temp1 := Chr(Temp);
      If EOLN(OpenUp1)
        then Writeln (OpenUp, Temp1)
        else Write (OpenUp, Temp1);
      Temp1 := ' ';
      Temp := 0;
    Until EOF(OpenUp1);
    Close (OpenUp1);
    Close (OpenUp);
  End;
Procedure CheckForFile (A : String);
Var
  OpenUp : Text;
Begin
  {$I-}
  Assign (OpenUp, A);
  Reset (OpenUp);
  Close (OpenUp);
  {$I+}
  If IOResult <> 0 then
    Begin
      TextColor(Red + Blink);
      Write ('WARNING!!!: ');
      TextColor(2);
      Writeln (A,' was not found!!! Maybe you spelled the filename wrong?');
      Writeln ('or you thought the file was there, but it''s not. Well, this program can''t');
      Writeln ('convert a file that doesn''t exist. Well, try again.');
      Writeln;
      Halt;
    End;
  End;
Begin
  ClrScr;
  If (ParamCount <> 2) and (ParamCount <> 1) then
    Begin
      TextColor(10 + blink);
      Write ('TeXt ChAnGeR!!! ');
      TextColor(2);
      Writeln ('-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-');
      Writeln;
      TextColor(10);
      Writeln ('Arrgh!!! You didn''t enter this in correctly!!! This is how you do it:');
      TextColor(2);
      Writeln ('TC <File to be changed> [new filename to be saved as]');
      Textcolor(10);
      Writeln;
      Writeln ('Purpose:');
      TextColor(2);
      Writeln ('  This program takes some text and makes all the letters more fancy. This');
      Writeln ('is freeware. I just made this program out of boredom. Well, enjoy!!!');
      Writeln ('  If no filename is specified to be saved as, the new document will be');
      Writeln ('saved as ''TC.TXT''');
      Writeln;
      Writeln;
      TextColor(1);
      Write('B');
      TextColor(2);
      Write('a');
      TextColor(3);
      Write('c');
      TextColor(4);
      Write('k ');
      TextColor(5);
      Write('t');
      TextColor(6);
      Write('o ');
      TextColor(7);
      Write('t');
      TextColor(8);
      Write('h');
      TextColor(9);
      Write('e ');
      TextColor(10);
      Write('D');
      TextColor(11);
      Write('O');
      TextColor(12);
      Write('S ');
      TextColor(13);
      Write('p');
      TextColor(14);
      Write('r');
      TextColor(15);
      Write('o');
      TextColor(1);
      Write('m');
      TextColor(2);
      Write('p');
      TextColor(3);
      Write('t');
      TextColor(4);
      Write('.');
      TextColor(5);
      Write('.');
      TextColor(6);
      Writeln('.');
      Halt;
    End;
  CheckForFile (ParamStr(1));
  If ParamCount = 1
    then TranslateFile(ParamStr(1), 'TC.TXT');
  If ParamCount = 2
    then TranslateFile(ParamStr(1), ParamStr(2));
  ClrScr;
  TextColor(10);
  Write ('Good');
  Write ('-');
  TextColor(10);
  Writeln('Bye!!!');
End.
