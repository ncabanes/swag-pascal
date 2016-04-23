{
DAVID SOLLY

From Israel Moshe Harel was heard to say to David Solly

Thank you For taking the time to answer my many questions.  I have to
tell you, though, that I was lucky to have received your letter because
it was addressed to David SALLY and not David SOLLY.

>    Are you familiar With a Hebrew Text processor Program called QText?
> I have been able to obtain version 2.10 as public domain software but I
> am wondering if there has been an update.  Have you ever heard of a

MH>Current version of QText is 5.0 and it is commercial :-(
  >It comes now With a full set of utilities, including FAX support.

Did you know that Q-Text version 2.10 was written in Turbo Pascal 3?  I
wonder if Itschak Maynts (Isaac Mainz?) has continued to use it in his
later versions.  Anyway, I would be interested in obtaining the latest
version of Q-Text.  Can you give me the distributor's address and the
approximate price?  Thank you.

>Most Israeli Printers have a special ROM. You may use downloadable Character
>sets or even Graphic printing if needed. I once used LETTRIX For this purpos
>on a Hebrew-less Printer, and it worked fine (but S L O W . . .).


I have Letrix 3.6.  This was what I was trying to use to print the
Q-Text Files I was writing.  I wrote a Program in Turbo Pascal to
convert the Q-Text Files into Letrix Files.  The printing is slow but
the results are favourable. Another advantage to Letrix Hebrew Files is
that they are written completely in low-ASCII and almost readable
without transliteration if one is at all familiar With Hebrew. It is a
good format For posting Hebrew Text on the Multi-Lingual echo not only
because it is low-ASCII but also because the method of transliteration
is consistent.

Below is my Q-Text File to Letrix File conversion Program.  I hope you
will find it useful.
}

Program QTextLetrix;

{$D-}

Uses
  Crt, Dos;


Var
  InFile,
  TransFile   : Text;
  InFilenm,
  TransFilenm : PathStr;
  Letter, Ans : Char;
  Printable,
  Hebrew,
  Niqud,
  Roman       : Set of Char;
  Nkdm, Rom   : Boolean;

{
   "UpItsCase" is a Function that takes a sting of any length and
   sets all of the Characters in the String to upper case.  It is handy
   For comparing Strings.
}

Function UpItsCase (SourceStr : PathStr) : PathStr;
Var
  i  : Integer;
begin
  For i := 1 to length(SourceStr) do
    SourceStr[i] := UpCase(SourceStr[i]);
  UpItsCase := SourceStr
end; {Function UpItsCase}


Function Exist(fname : PathStr) : Boolean;
Var
  f : File;
begin
{$F-,I-}
  Assign(f, fname);
  Reset(f);
  Close(f);
{$I+}
  Exist := (IOResult = 0) and (fname <> '')
end; {Function exist}

Procedure Help;
begin
  Writeln;
  Writeln ('QTLT (Version 1.0)');
  Writeln ('Hebrew Text File Conversion');
  Writeln ('Q-Text 2.10 File to Letrix(R) 3.6 Hebrew File');
  Writeln;
  Writeln;
  Writeln ('QTLT converts Q-Text Files to Letrix Hebrew format Files.');
  Writeln;
  Writeln ('QTLT expects two parameters on the command line.');
  Writeln ('The first parameter is the name of the File to convert,');
  Writeln ('the second is the name of the new File.');
  Writeln;
  Writeln ('Example:  QTLT  HKVTL.HEB HKVTL.TXT');
  Writeln;
  Writeln ('If no parameters are found, QTLT will display this message.');
  Writeln;
  Halt;
end; {Procedure Help}

{
  "ParseCommandLine" is a Procedure that checks if any data was input
  at the Dos command line.  If no data is there, then the "Help"
  Procedure is executed and the Program is halted.  Otherwise, the
  Mode strig Variable is set equal to the Text on the command line.
}

Procedure ParseCommandLine;
begin
  if (ParamCount = 0) or (ParamCount <> 2) then
    Help
  else
  begin
    InFilenm    := ParamStr(1);
    InFilenm    := UpItsCase(InFilenm);
    TransFilenm := ParamStr(2);
    TransFilenm := UpItsCase(TransFilenm);
  end;
end; {Procedure ParseCommandLine}

Procedure OpenFiles;
begin
  {Open input/output Files}
  If not exist(InFilenm) then
  begin
    Writeln;
    Writeln (InFilenm, ' not found');
    Halt;
  end
  Else
  begin
    Assign (InFile, InFilenm);
    Reset (InFile);
  end;

  If exist (TransFilenm) then
  begin
    Writeln;
    Writeln (TransFilenm, ' already exists!');
    Write ('OverWrite it?  (Y/N) > ');
    Repeat
      Ans := ReadKey;
      Ans := Upcase(Ans);
      If Ans = 'N' then Halt;
    Until Ans = 'Y';
  end;

  Assign (TransFile, TransFilenm);
  ReWrite (TransFile);
  Writeln;
end; {Procedure OpenFiles}



Procedure UseOfRoman;
begin
  Writeln ('QTLT has detected Roman letters in the source Text.');
  Writeln;
  Writeln ('Letrix expects access to a Roman font to print these Characters');
  Writeln ('otherwise Letrix will report an error condition of fail to perform.');
  Writeln;
  Writeln ('Sample Letrix load instruction:  LX Hebrew Roman');
  Writeln;
  Writeln ('Be sure that these instances are enclosed within the proper');
  Writeln ('Letrix font switch codes so they are not printed as Hebrew Character');
  Writeln;
end; {Procedure UseOfRoman}

Procedure Niqudim (Var Letter : Char);
{
   Letrix Uses some standard Characters to represent niqudim
   While Q-Text does not.

   This table ensures that certain Characters do not become
   niqudim when translated to Letrix by inserting the tokens
   which instruct the Letrix Program to use the alternate
   alphabet -- which by default is number 2.
}
begin
  If Not Nkdm then
  begin
    Writeln;
    Writeln ('QTLT has detected Q-Text Characters which Letrix normaly Uses for');
    Writeln ('has transcribed them to print as normal Characters.');
    Writeln;
    Writeln ('Letrix expects access a Roman font to print these Characters');
    Writeln ('otherwise Letrix will report an error condition of fail to perfect');
    Writeln;
    Writeln ('Sample Letrix load instruction:  LX Hebrew Roman');
    Writeln;
    Nkdm := True;
  end; {if not Nkdm}

  Case Letter of

    '!' : Write (TransFile, '\2!\1');
    '@' : Write (TransFile, '\2@\1');
    '#' : Write (TransFile, '\2#\1');
    '$' : Write (TransFile, '\2$\1');
    '%' : Write (TransFile, '\2%\1');
    '^' : Write (TransFile, '\2^\1');
    '&' : Write (TransFile, '\2&\1');
    '*' : Write (TransFile, '\2*\1');
    '(' : Write (TransFile, '\2(\1');
    ')' : Write (TransFile, '\2)\1');
    '+' : Write (TransFile, '\2+\1');
    '=' : Write (TransFile, '\2=\1');

  end; {Case}

end; {Procedure Nikudim}



Procedure QT_Table (Var Letter : Char);
{
  This section reviews each QText letter and matches it With a
  Letrix equivalent where possible
}
begin
  Case Letter of

    #128 : Write (TransFile, 'a');  {Alef}
    #129 : Write (TransFile, 'b');  {Bet }
    #130 : Write (TransFile, 'g');  {Gimmel etc. }
    #131 : Write (TransFile, 'd');
    #132 : Write (TransFile, 'h');
    #133 : Write (TransFile, 'w');
    #134 : Write (TransFile, 'z');
    #135 : Write (TransFile, 'H');
    #136 : Write (TransFile, 'T');
    #137 : Write (TransFile, 'y');
    #138 : Write (TransFile, 'C');
    #139 : Write (TransFile, 'c');
    #140 : Write (TransFile, 'l');
    #141 : Write (TransFile, 'M');
    #142 : Write (TransFile, 'm');
    #143 : Write (TransFile, 'N');
    #144 : Write (TransFile, 'n');
    #145 : Write (TransFile, 'S');
    #146 : Write (TransFile, 'i');
    #147 : Write (TransFile, 'F');
    #148 : Write (TransFile, 'p');
    #149 : Write (TransFile, 'X');
    #150 : Write (TransFile, 'x');
    #151 : Write (TransFile, 'k');
    #152 : Write (TransFile, 'r');
    #153 : Write (TransFile, 's');
    #154 : Write (TransFile, 't');

  end; {Case of}

end; {Procedure QT_Table}


Procedure DoIt;
{
  Special commands requred by Letrix.
  Proportional spacing off, line justification off,
  double-strike on, pitch set to 12 Characters per inch.
}
begin

  Writeln(transFile,'\p\j\D\#12');
  {Transcription loop}
  While not eof(InFile) do
  begin
    Read(InFile, Letter);

    If (Letter in Printable) then
      Write(TransFile, Letter);

    If (Letter in Niqud) then
      Niqudim(Letter);

    If (Letter in Hebrew) then
      QT_Table(Letter);

    If (Letter in Roman) and (Rom = False) then
    begin
      UseOfRoman;
      Rom := True;
    end; {Roman Detection}

  end; {while}

  {Close Files}

  Close (TransFile);
  Close (InFile);

  {Final message}

  Writeln;
  Writeln;
  Writeln('QTLT (Version 1.0)');
  Writeln('Hebrew Text File Conversion');
  Writeln('Q-Text 2.10 Files to Letrix(R) 3.6 Hebrew File');
  Writeln;
  Writeln ('Task Complete');
  Writeln;
  Writeln ('QTLT was written and released to the public domain by David Solly');
  Writeln ('Bibliotheca Sagittarii, Ottawa, Canada (2 December 1992).');
  Writeln;

end; {Procedure DoIt}


begin

  {Initialize Variables}
  Printable := [#10,#12,#13,#32..#127];
  Roman     := ['A'..'Z','a'..'z'];
  Niqud     := ['!','@','#','$','%','^','&','*','(',')','+','='];
  Printable := Printable - Niqud;
  Hebrew    := [#128..#154];
  Rom       := False;
  Nkdm      := False;

ParseCommandLine;
OpenFiles;
DoIt;

end.

{

   Please find below the Turbo Pascal source code For the conversion
Program For making Letrix Hebrew Files into Q-Text 2.10 Files.  I could
not find a way to make this conversion Program convert embedded Roman
Text without making it into a monster.  If you have any suggestions, I
would be thankful to the input.

========================= Cut Here ========================
}

Program LetrixQText;

{$D-}

Uses
  Crt, Dos;

Var
  InFile,
  TransFile   : Text;
  InFilenm,
  TransFilenm : PathStr;
  Letter, Ans : Char;
  Printable,
  HiASCII     : Set of Char;

{
  "UpItsCase" is a Function that takes a sting of any length and
  sets all of the Characters in the String to upper case.  It is handy
  For comparing Strings.
}

Function UpItsCase (SourceStr : PathStr): PathStr;
Var
  i  : Integer;
begin
  For i := 1 to length(SourceStr) do
    SourceStr[i] := UpCase(SourceStr[i]);
  UpItsCase := SourceStr
end; {Function UpItsCase}


Function Exist(fname : PathStr) : Boolean;
Var
  f : File;
begin
  {$F-,I-}
  Assign(f, fname);
  Reset(f);
  Close(f);
  {$I+}
  Exist := (IOResult = 0) and (fname <> '')
end; {Function exist}

Procedure Help;
begin
  Writeln;
  Writeln ('LTQT (Version 1.0)');
  Writeln ('Hebrew Text File Conversion');
  Writeln ('Letrix(R) 3.6 File to Q-Text 2.10 File');
  Writeln;
  Writeln;
  Writeln ('LTQT converts Letrix Hebrew format Files to  Q-Text format Files.')
  Writeln;
  Writeln ('LTQT expects two parameters on the command line.');
  Writeln ('The first parameter is the name of the File to convert,');
  Writeln ('the second is the name of the new File.');
  Writeln;
  Writeln ('Example:  LTQT  HKVTL.TXT HKVTL.HEB');
  Writeln;
  Writeln ('If no parameters are found, LTQT will display this message.');
  Writeln;
  Halt;
end; {Procedure Help}

{
  "ParseCommandLine" is a Procedure that checks if any data was input
  at the Dos command line.  If no data is there, then the "Help"
  Procedure is executed and the Program is halted.  Otherwise, the
  Mode strig Variable is set equal to the Text on the command line.
}
Procedure ParseCommandLine;
begin
  if (ParamCount = 0) or (ParamCount <> 2) then
    Help
  else
  begin
    InFilenm := ParamStr(1);
    InFilenm := UpItsCase(InFilenm);
    TransFilenm := ParamStr(2);
    TransFilenm := UpItsCase(TransFilenm);
  end;
end; {Procedure ParseCommandLine}

Procedure OpenFiles;
begin
  {Open input/output Files}
  If not exist(InFilenm) then
  begin
    Writeln;
    Writeln (InFilenm, ' not found');
    Halt;
  end
  Else
  begin
    Assign (InFile, InFilenm);
    Reset (InFile);
  end;

  If exist (TransFilenm) then
  begin
    Writeln;
    Writeln (TransFilenm, ' already exists!');
    Write ('OverWrite it?  (Y/N) > ');
    Repeat
      Ans := ReadKey;
      Ans := Upcase(Ans);
      If Ans = 'N' then Halt;
    Until Ans = 'Y';
  end;

  Assign (TransFile, TransFilenm);
  ReWrite (TransFile);
  Writeln;

end; {Procedure OpenFiles}



Procedure LT_Table (Var Letter : Char);
{
  This section reviews each Letrix letter and matches it With a
  Q-Text equivalent where possible
}
begin
  Case Letter of

    'a' : Write (TransFile, #128);
    'b', 'B','v' : Write (TransFile, #129);  {Vet, Bet}
    'g' : Write (TransFile, #130);
    'd' : Write (TransFile, #131);
    'h' : Write (TransFile, #132);
    'V', 'o', 'u', 'w' : Write (TransFile, #133); {Vav, Holem male, Shuruq}
    'z' : Write (TransFile, #134);
    'H' : Write (TransFile, #135);
    'T' : Write (TransFile, #136);
    'y', 'e' : Write (TransFile, #137); {Yod}
    'C', 'Q', 'W' : Write (TransFile, #138); {Khaf-Sofit}
    'c', 'K' : Write (TransFile, #139); {Khaf, Kaf}
    'l' : Write (TransFile, #140);
    'M' : Write (TransFile, #141);
    'm' : Write (TransFile, #142);
    'N' : Write (TransFile, #143);
    'n' : Write (TransFile, #144);
    'S' : Write (TransFile, #145);
    'i' : Write (TransFile, #146);
    'F' : Write (TransFile, #147);
    'p', 'P', 'f' : Write (TransFile, #148); {Fe, Pe}
    'X' : Write (TransFile, #149);
    'x' : Write (TransFile, #150);
    'k' : Write (TransFile, #151);
    'r' : Write (TransFile, #152);
    's' : Write (TransFile, #153);
    't' : Write (TransFile, #154);
    'A' : Write (TransFile, '-');

    {Niqudim and unused letters}

    'D','E', 'G', 'I', 'J', 'j', 'O', 'q', 'R', 'U', 'Y', 'Z' :
       Write(TransFile, '');
  else
    Write(TransFile, Letter);

  end; {Case of}

end; {Procedure LT_Table}


Procedure DoIt;
begin
  {Transcription loop}
  While not eof(InFile) do
  begin
    Read(InFile, Letter);

    If (Letter in Printable) then
      LT_Table(Letter);

    If (Letter in HiASCII) then
      Write(TransFile, Letter);
  end; {while}

  {Close Files}

  Close (TransFile);
  Close (InFile);

  {Final message}

  Writeln;
  Writeln;
  Writeln('LTQT Version 1.0');
  Writeln('Hebrew Text File Conversion');
  Writeln('Letrix(R) 3.6 File to Q-Text 2.10 File');
  Writeln;
  Writeln;
  Writeln ('Letrix Hebrew File to Q-Text File conversion complete.');
  Writeln;
  Writeln('Special Note:');
  Writeln;
  Writeln ('Q-Text does not support either dagesh or niqudim (vowels).');
  Writeln ('Letters containing a dagesh-qol are reduced to their simple form.');
  Writeln ('Holam male and shuruq are transcribed as vav.  Roman letters used');
  Writeln ('to represent niqudim are ignored.  All other symbols are transcribed'
  Writeln ('without change.');
  Writeln;
  Writeln ('There is no foreign language check -- Anything that can be transcribe
  Writeln ('into Hebrew Characters will be.');
  Writeln;
  Writeln ('LTQT was written and released to the public domain by David Solly');
  Writeln ('Bibliotheca Sagittarii, Ottawa, Canada (8 December 1992).');
  Writeln;

end; {Procedure DoIt}


begin
  {Initialize Variables}
  Printable := [#10,#12,#13,#32..#127];
  HiASCII   := [#128..#154];

  ParseCommandLine;
  OpenFiles;
  DoIt;
end.

