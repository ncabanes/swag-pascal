Program BannerC;

{$V-}

{ Written by Scott R. Houck

  This program produces banners which can be sent to the screen
  or to a file.  If sent to a file, the output may be appended to
  to an existing file if desired.

  The syntax is as follows:

    BANNER [/B=banner] [/I=infile] [/O=outfile [/A]] [/C=char]

  where

    banner  = a character string of maximum length 10
    infile  = an input file containing the banner(s)
    outfile = an output file to which the banner(s) will be written
    char    = character to be used in printing the banner
                (default = the character being printed)

         /A = append to file if it already exists


  NOTES:

    1.  Options may be specified in any order, but there must be
        at least one space between each one.  Do not put spaces
        on either side of the equals sign.

    2.  You may use PRN for the filename if you want to send the
        output to the printer. If you choose to do this, do not
        use the /A option.

    3.  To indicate a space in the banner when using the /B option, use
        the carat symbol (^).  Example:  BANNER /O=DISKFILE /B=JOHN^DOE
        However, this is not necessary if you are using the /I option.

    4.  Valid characters are 0-9, A-Z, and !"#$%&'()*+,-./:;<=>?@[\]
        Any other characters will be printed as a space.

    6.  All lower case letters are converted to upper case.

    7.  Three blank lines are written before the banner is output.

    8.  Note that /B and /I are mutually exclusive and will produce a
        syntax error if used together.

    9.  If all options are omitted or if the command line does not contain
        either /B or /I, the command syntax is printed.

   10.  /A will produce a syntax error if used without /O.

   11.  You may not use < or > with the /B option because DOS would
        interpret it as redirection of standard input and output.

}

USES DOS,CRT;

Type
  str13 = string[13];
  str80 = string[80];
  char_pattern = array[1..10] of integer;

Const
  bit_value: array[1..10] of integer = (1,2,4,8,16,32,64,128,256,512);

  char_def:  array[#32..#94] of char_pattern = (

    {32:' '}   ($000,$000,$000,$000,$000,$000,$000,$000,$000,$000),
    {33:'!'}   ($030,$078,$0FC,$0FC,$078,$078,$030,$000,$030,$030),
    {34:'"'}   ($1CE,$1CE,$1CE,$1CE,$000,$000,$000,$000,$000,$000),     
    {35:'#'}   ($0CC,$0CC,$0CC,$3FF,$0CC,$0CC,$3FF,$0CC,$0CC,$0CC),     
    {36:'$'}   ($030,$1FE,$3FF,$330,$3FF,$1FF,$033,$3FF,$1FE,$030),
    {37:'%'}   ($1C3,$366,$36C,$1D8,$030,$060,$0CE,$19B,$31B,$20E),
    {38:'&'}   ($1E0,$330,$330,$1C0,$1E0,$331,$31A,$31C,$1FA,$0E1),     
    {39:'''}   ($070,$0F8,$078,$010,$020,$000,$000,$000,$000,$000),
    {40:'('}   ($004,$018,$030,$060,$060,$060,$060,$030,$018,$004),
    {41:')'}   ($080,$060,$030,$018,$018,$018,$018,$030,$060,$080),
    {42:'*'}   ($000,$000,$000,$084,$048,$2FD,$048,$084,$000,$000),
    {43:'+'}   ($000,$000,$078,$078,$3FF,$3FF,$078,$078,$000,$000),
    {44:','}   ($000,$000,$000,$000,$000,$070,$0F8,$078,$010,$020),
    {45:'-'}   ($000,$000,$000,$000,$3FF,$3FF,$000,$000,$000,$000),     
    {46:'.'}   ($000,$000,$000,$000,$000,$000,$000,$078,$0FC,$078),
    {47:'/'}   ($001,$003,$006,$00C,$018,$030,$060,$0C0,$180,$100),
    {48:'0'}   ($078,$0FC,$186,$303,$303,$303,$303,$186,$0FC,$078),
    {49:'1'}   ($030,$0F0,$0B0,$030,$030,$030,$030,$030,$3FF,$3FF),
    {50:'2'}   ($1FE,$3FF,$203,$003,$003,$018,$060,$0C0,$3FF,$3FF),
    {51:'3'}   ($3FF,$3FE,$00C,$018,$038,$00E,$006,$203,$3FF,$1FE),
    {52:'4'}   ($01C,$03C,$06C,$0CC,$18C,$3FF,$3FF,$00C,$00C,$00C),
    {53:'5'}   ($3FF,$3FF,$300,$300,$3FE,$3FF,$003,$203,$3FF,$1FE),
    {54:'6'}   ($1FE,$3FF,$301,$300,$3FE,$3FF,$303,$303,$3FF,$1FE),
    {55:'7'}   ($3FF,$3FF,$006,$00C,$018,$030,$060,$0C0,$300,$300),
    {56:'8'}   ($1FE,$3FF,$303,$303,$1FE,$1FE,$303,$303,$3FF,$1FE),
    {57:'9'}   ($1FE,$3FF,$303,$303,$3FF,$1FF,$003,$003,$3FF,$1FE),
    {58:':'}   ($000,$000,$000,$078,$0FC,$078,$000,$078,$0FC,$078),
    {59:';'}   ($000,$038,$07C,$038,$000,$038,$07C,$03C,$004,$008),
    {60:'<'}   ($000,$000,$003,$00C,$030,$0C0,$030,$00C,$003,$000),
    {61:'='}   ($000,$000,$000,$3FF,$3FF,$000,$3FF,$3FF,$000,$000),
    {62:'>'}   ($000,$000,$0C0,$030,$00C,$003,$00C,$030,$0C0,$000),
    {63:'?'}   ($1FE,$3FF,$303,$006,$00C,$018,$018,$000,$018,$018),     
    {64:'@'}   ($1FE,$303,$33B,$36B,$363,$363,$366,$37C,$300,$1FE),     
    {65:'A'}   ($1FE,$3FF,$303,$303,$303,$3FF,$3FF,$303,$303,$303),
    {66:'B'}   ($3FE,$3FF,$303,$303,$3FE,$3FE,$303,$303,$3FF,$3FE),
    {67:'C'}   ($1FE,$3FF,$301,$300,$300,$300,$300,$301,$3FF,$1FE),
    {68:'D'}   ($3FE,$3FF,$303,$303,$303,$303,$303,$303,$3FF,$3FE),
    {69:'E'}   ($3FF,$3FF,$300,$300,$3E0,$3E0,$300,$300,$3FF,$3FF),
    {70:'F'}   ($3FF,$3FF,$300,$300,$3E0,$3E0,$300,$300,$300,$300),
    {71:'G'}   ($1FE,$3FF,$300,$300,$31F,$31F,$303,$303,$3FF,$1FF),
    {72:'H'}   ($303,$303,$303,$303,$3FF,$3FF,$303,$303,$303,$303),
    {73:'I'}   ($3FF,$3FF,$030,$030,$030,$030,$030,$030,$3FF,$3FF),
    {74:'J'}   ($0FF,$0FF,$018,$018,$018,$018,$318,$318,$3F8,$1F0),
    {75:'K'}   ($303,$306,$318,$360,$3E0,$330,$318,$30C,$306,$303),
    {76:'L'}   ($300,$300,$300,$300,$300,$300,$300,$300,$3FF,$3FF),
    {77:'M'}   ($303,$3CF,$37B,$333,$333,$303,$303,$303,$303,$303),
    {78:'N'}   ($303,$383,$343,$363,$333,$333,$31B,$30B,$307,$303),
    {79:'O'}   ($1FE,$3FF,$303,$303,$303,$303,$303,$303,$3FF,$1FE),
    {80:'P'}   ($3FE,$3FF,$303,$303,$3FF,$3FE,$300,$300,$300,$300),
    {81:'Q'}   ($1FE,$3FF,$303,$303,$303,$303,$33B,$30F,$3FE,$1FB),
    {82:'R'}   ($3FE,$3FF,$303,$303,$3FF,$3FE,$318,$30C,$306,$303),
    {83:'S'}   ($1FE,$3FF,$301,$300,$3FE,$1FF,$003,$203,$3FF,$1FE),
    {84:'T'}   ($3FF,$3FF,$030,$030,$030,$030,$030,$030,$030,$030),
    {85:'U'}   ($303,$303,$303,$303,$303,$303,$303,$303,$3FF,$1FE),
    {86:'V'}   ($303,$303,$186,$186,$186,$186,$0CC,$0CC,$078,$030),
    {87:'W'}   ($303,$303,$303,$303,$333,$333,$333,$37B,$1CE,$186),
    {88:'X'}   ($303,$186,$0CC,$078,$030,$078,$0CC,$186,$303,$303),
    {89:'Y'}   ($303,$186,$0CC,$078,$030,$030,$030,$030,$030,$030),
    {90:'Z'}   ($3FF,$3FE,$00C,$018,$030,$030,$060,$0C0,$1FF,$3FF),
    {91:'['}   ($0FE,$0FE,$0C0,$0C0,$0C0,$0C0,$0C0,$0C0,$0FE,$0FE),
    {92:'\'}   ($200,$300,$180,$0C0,$060,$030,$018,$00C,$006,$002),
    {93:']'}   ($0FE,$0FE,$006,$006,$006,$006,$006,$006,$0FE,$0FE),
    {94:'^'}   ($000,$000,$000,$000,$000,$000,$000,$000,$000,$000)    );

Var
  character: char;
  banner: str13;
  Param: array[1..4] of str80;
  InfileName, OutfileName: str80;
  Infile, Outfile: text;
  Slash_A, Slash_B, Slash_C, Slash_I, Slash_O: boolean;

{----------------------------------------------------------------------}

Procedure Beep;

begin
  Sound(350);
  Delay(300);
  NoSound;
end;

{----------------------------------------------------------------------}

Procedure UpperCase(var AnyStr: str80);

var
  i: integer;

begin
  For i := 1 to length(AnyStr) do AnyStr[i] := UpCase(AnyStr[i]);
end;

{----------------------------------------------------------------------}

Function Exist(filename: str80): boolean;

var
  tempfile: file;

begin
  Assign(tempfile,filename);
  {$I-}
  Reset(tempfile);
  {$I+}
  Exist := (IOresult = 0);
  Close(tempfile);
end;

{----------------------------------------------------------------------}

Procedure Print_Syntax;

begin
  Writeln('The syntax is as follows:'^J);
  Writeln('  BANNER [/B=banner] [/I=infile] [/O=outfile [/A]] ',
          '[/C=char]'^J);
  Writeln('where'^J);
  Writeln('  banner  = character string of maximum length 10');
  Writeln('  infile  = input file containing banner text');
  Writeln('  outfile = output file to which the banner(s) will be ',
          'written');
  Writeln('  char    = character to be used in printing the banner');
  Writeln('              (default = the character being printed)'^J);
  Writeln('       /A = append to file if it already exists'^J);
  Writeln('Note that /B and /I are mutually exclusive.');
  Writeln('Use a carat (^) for a space if using /B.');
  Writeln('Valid characters are 0-9, A-Z, and ',
          '!"#$%&''()*+,-./:;<=>?@[\]');
end;

{----------------------------------------------------------------------}

Procedure Parse;

var
  n, b, c, i, o: integer;
  ch1, ch2, ch3: char;

  {*} procedure Error;
        begin
          Beep;
          Print_Syntax;
          Halt;
        end;

begin  { Parse }

  Slash_A := false;
  Slash_B := false;    b := 0;
  Slash_C := false;    c := 0;
  Slash_I := false;    i := 0;
  Slash_O := false;    o := 0;

  If ParamCount = 0 then
    begin
      Print_Syntax;
      Halt;
    end;

  If ParamCount > 4 then Error;

  For n := 1 to ParamCount do
    begin
      Param[n] := ParamStr(n);
      UpperCase(Param[n]);
      ch1 := Param[n][1];
      ch2 := Param[n][2];
      ch3 := Param[n][3];
      If (ch1 <> '/') or not (ch2 in ['A','B','C','I','O']) then Error;
      If ch2 = 'A' then
        Slash_A := true;
      If ch2 = 'B' then
        begin
          Slash_B := true;
          b := n;
        end;
      If ch2 = 'C' then
        begin
          Slash_C := true;
          c := n;
        end;
      If ch2 = 'I' then
        begin
          Slash_I := true;
          i := n;
        end;
      If ch2 = 'O' then
        begin
          Slash_O := true;
          o := n;
        end;
      If (ch2 in ['B','C','I','O']) and (ch3 <> '=') then Error;
      If (ch2 = 'A') and (length(ch2) > 2) then Error;
    end;

  If Slash_B and Slash_I then Error;
  If not Slash_B and not Slash_I then Error;
  If Slash_A and not Slash_O then Error;
  If Slash_B then
    begin
      banner := Param[b];
      Delete(banner,1,3);
    end;
  If Slash_C then character := Param[c][4];
  If Slash_I then
    begin
      InfileName := Param[i];
      Delete(InfileName,1,3);
    end;
  If Slash_O then
    begin
      OutfileName := Param[o];
      Delete(OutfileName,1,3);
    end;

end;

{----------------------------------------------------------------------}

Procedure Heading(message: str13);

var
  i, j, k: integer;

begin

  If Slash_O
    then Writeln(Outfile,^M^J^M^J^M^J)
    else Writeln(^J^J^J);

  For i := 1 to 10 do
    begin
      For j := 1 to length(message) do
        begin
          If not (message[j] in [#32..#94]) then message[j] := #32;
          For k := 10 downto 1 do
            If char_def[message[j],i] and bit_value[k] = bit_value[k]
              then
                begin
                  If not Slash_C then character := message[j];
                  If Slash_O
                    then Write(Outfile,character)
                    else Write(character);
                end
              else
                begin
                  If Slash_O
                    then Write(Outfile,' ')
                    else Write(' ');
                end;
              If Slash_O
                then Write(Outfile,'  ')
                else Write('  ');
        end;
      If Slash_O
        then Writeln(Outfile)
        else Writeln;
    end;

end;

{----------------------------------------------------------------------}

Begin  { Banner }

  Parse;

  If Slash_O then
    begin
      Assign(Outfile,OutfileName);
      If Slash_A and Exist(OutfileName)
        then Append(Outfile)
        else Rewrite(Outfile);
    end;

  If Slash_I then
    begin
      Assign(Infile,InfileName);
      Reset(Infile);
      While not Eof(Infile) do
        begin
          Readln(Infile,banner);
          UpperCase(banner);
          Heading(banner);
        end;
      Close(Infile);
    end

  else Heading(banner);

  If Slash_O then Close(Outfile);

End.
