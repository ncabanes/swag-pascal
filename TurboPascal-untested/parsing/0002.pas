Program PARSER;

{The Object of this Program is to accept a sentence from the user then to break the
 sentence into its Component Words and to display each Word on a separate line.
}

Uses Crt; {Required by Turbo Pascal}

Const
  maxWord     = 15;
  maxsentence = 15;
  space       = CHR(32);
  first       = 1;

Type
  Strng = Array[1..maxWord] of Char;
  Word  = Record
    body   : Strng;
    length : Integer
  end;

Var
  sentence                 : Array[1..maxsentence] of Word;
  row, col, nextcol, count : Integer;
  demarker                 : Boolean;
  ans                      : Char;

Procedure SpaceTrap;
{ Insures that there is ony 1 space between Words     }
begin
  Repeat
    READ(sentence[row].body[first])
  Until sentence[row].body[first] <> space
end;

Procedure StringWrite(Var phrase : Word);
{Writes only the required length of each Character String.
This is required when using 32 col. mode.}
Var
  letter : Integer;
begin
         For letter := first to phrase.length do
           Write(phrase.body[letter])
       end; {Procedure StringWrite}

     Procedure StringRead;
      Var I : Integer;
      begin
      {
       Intitialize the Variables
      }
        count    := 1;
        row      := first;
        col      := first;
        nextcol  := col + 1;
        demarker := False;
        For I := first to maxsentence do
            sentence[I].length := 1;
        Write('Type a sentence >  ');
        {READLN;} {Clears the buffer of EOLN}
                  {Required by HiSoft Pascal}
            While (not EOLN) and (row < maxsentence) do
                begin
                   READ(sentence[row].body[col]);
                   if sentence[row].body[first] = space then SpaceTrap;
                   if sentence[row].body[col] = space then
                      demarker := True;
                   if (not demarker) and (nextcol < maxWord) then
                       begin
                         col     := col + 1;
                         nextcol := nextcol + 1
                       end
                    else
                      begin
                        sentence[row].length := col;
                        count                := count + 1;
                        row                  := row + 1;
                        col                  := first;
                        nextcol              := col + 1;
                        demarker             := False
                      end; {if...then...else}
        if EOLN then sentence[row].length := col - 1
        {Accounts For the last Word entered less the EOLN marker.}
                end {While loop}
      end; {Procedure StringRead}

     Procedure PrintItOut;
      Var
          subsequent : Integer;
      begin
          subsequent := first + 1;
          Write('Parsing > ');
          StringWrite(sentence[first]);
          WriteLN;
          if count >= subsequent then
              begin
                  For row := subsequent to count do
                      begin
                          Write('          ');
                          StringWrite(sentence[row]);
                          WriteLN
                      end
              end
       end; {Procedure PrintItOut}

     Procedure SongandDance;
      begin
          {PAGE;} {HiSoft Pascal = Turbo Pascal ClrScr}
          ClrScr;
          WriteLN('           Parser');
          WriteLN;
          WriteLN('    Program By David Solly');
          WriteLN;
          WriteLN('   The Object of this Program');
          WriteLN('is to accept a sentence from');
          WriteLN('the user then to break the');
          WriteLN('sentence down into its');
          WriteLN('Component Words and to display');
          WriteLN('each Word on a seperate line.');
          WriteLN;
          WriteLN;
      end; {Procedure SongandDance}

     begin {Main Program}
     SongandDance;
     StringRead;
     WriteLN;
     PrintItOut;
     WriteLN;
     WriteLN('end of Demonstration.');
     READLN(ans);
     end. {Main Program}
