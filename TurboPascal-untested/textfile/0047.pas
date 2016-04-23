UNIT PoetryU;
 
INTERFACE 
 
VAR 
  Vowels, 
  Conson  : SET OF CHAR; 
 
FUNCTION NumWords( S : STRING ) : INTEGER; 
FUNCTION GetWord( S : STRING; WhichWord : INTEGER ) : STRING; 
FUNCTION Word_Syll( S : STRING ) : INTEGER;
FUNCTION Sent_Syll( S : STRING ) : INTEGER; 
FUNCTION UCase( S : STRING ) : STRING; 
 
IMPLEMENTATION 


FUNCTION UCase( S : STRING ) : STRING; 
VAR 
  Count : INTEGER; 

Begin 
  FOR Count := 1 TO Length( S ) DO
    S[ Count ] := UpCase( S[ Count ] ); 
 
  UCase := S; 
End; 
 
FUNCTION RightStr( S : STRING; Index : BYTE ) : STRING; 
Begin 
  RightStr := Copy( S, Index, Length( S ) ); 
End; 
 
{ This function returns the number of words within a given string. } 
FUNCTION NumWords( S : STRING ) : INTEGER;
VAR 
  Words, 
  Count : INTEGER; 
 
Begin 
  Words := 0;
  Count := 0; 
 
  S := UCase( S ); 
 
  WHILE Count <> Length( S ) DO 
  Begin
    INC( Count ); 
 
    IF S[Count] IN ['A'..'Z'] THEN 
    Begin 
      INC( Words ); 
 
      WHILE (S[Count] IN ['A'..'Z', '''']) AND (Count < Length( S )) DO 
        INC( Count ); 
    End; 
  End; 
 
  NumWords := Words;
End; 

{ This function will return a word (1st, 2nd, 3rd, etc) from a sentence. 
  Note that it converts the word to uppercase. } 
FUNCTION GetWord( S : STRING; WhichWord : INTEGER ) : STRING; 
VAR 
  WC, 
  Count : INTEGER; 
  Temp  : STRING; 
 
Begin 
  WC    := 0;
  Count := 0; 
  Temp  := ''; 
 
  IF WhichWord > NumWords( S ) THEN 
  Begin 
    GetWord := ''; 
    Exit; 
  End; 
 
  S := UCase( S );
 
  WHILE Count < Length( S ) DO
  Begin 
    INC( Count ); 
 
    IF S[Count] IN ['A'..'Z'] THEN 
    Begin 
      INC( WC ); 
 
      IF WC = WhichWord THEN 
        WHILE (S[Count] IN ['A'..'Z']) AND (Count <= Length( S )) DO 
        Begin 
          Temp := Temp + S[Count]; 
          INC( Count );
        End 
      ELSE 
        WHILE (S[Count] IN ['A'..'Z']) AND (Count <= Length( S )) DO 
          INC( Count ); 
    End; 
  End;
 
  GetWord := Temp; 
End; 
 
{ This function will return the number of syllables in a given word. 
  It is in no way a fool-proof function, but will work for a lot of words. }
FUNCTION Word_Syll( S : STRING ) : INTEGER; 
VAR 
  Count, 
  SylCount : INTEGER; 
 
Begin 
  { No syllables! } 
  SylCount := 0; 
 
  S := UCase( S ); 
 
  { If it starts with a vowel, there is a good chance an extra syllable is in
    there. } 
  IF (S[1] IN Vowels) AND (Length( S ) > 3) THEN
    SylCount := 1; 
 
  IF (Pos( 'IO', S ) > 0) THEN 
    INC( SylCount ); 
  IF (Pos( 'EO', S ) > 0) THEN 
    INC( SylCount ); 
  IF (Pos( 'IA', S ) > 0) THEN 
    INC( SylCount ); 
  IF (Pos( 'ISM', S ) > 0) THEN 
    INC( SylCount );
  IF ((Pos( 'UA', S ) > 0) AND (Pos( 'QUA', S ) = 0)) THEN 
    INC( SylCount ); 
  IF (Pos( 'TION', S ) OR (Pos( 'SION', S )) <> 0) THEN 
    DEC( SylCount ); 
 
  FOR Count := 1 TO (Length( S ) - 1) DO 
    IF (S[Count] IN Conson) AND (S[Count + 1] IN Vowels) THEN 
      INC( SylCount ); 
 
  IF (S[Length( S )] = 'E') AND (Pos( 'BLE', RightStr( S, 3 )) = 0) AND
     (Pos( 'IE',  RightStr( S, 2 )) = 0) AND 
     (Pos( 'TLE', RightStr( S, 3 )) = 0) THEN
    DEC( SylCount ); 
 
  { A word must have at least 1 syllable!! } 
  IF SylCount < 1 THEN 
    SylCount := 1; 
 
  Word_Syll := SylCount; 
End; 
 
{ This function will count the number of syllables in a given sentence. } 
FUNCTION Sent_Syll( S : STRING ) : INTEGER; 
VAR
  Count, 
  SylCount : INTEGER; 
  Temp     : STRING; 
 
Begin 
  SylCount := 0; 
 
  FOR Count := 1 TO NumWords( S ) DO 
    INC( SylCount, Word_Syll( GetWord( S, Count ) ) ); 
 
  Sent_Syll := SylCount; 
End; 
 
PROCEDURE InitVowels; 
Begin 
  Vowels := ['A', 'E', 'I', 'O', 'U', 'Y']; 
End; 
 
PROCEDURE InitConson; 
VAR 
  Ch : CHAR; 
 
Begin 
  Conson := []; 
 
  FOR Ch := 'A' TO 'Z' DO 
    IF NOT (Ch IN Vowels) THEN 
      Conson := Conson + [ Ch ]; 
End; 
 
BEGIN 
  InitVowels; 
  InitConson; 
END. 

{ -------------------------  DEMO ----------------------- }


USES Crt, PoetryU;
 
CONST 
  TEST = 'These are a few interesting functions, man.'; 
 {TEST = 'antidisestablishmentarianism';} 
 
VAR 
  AWord : STRING; 
 
BEGIN 
  ClrScr; 
 
  AWord := GetWord( TEST, NumWords( TEST ) ); 
 
  WriteLn( 'The last word is : ', AWord ); 
  WriteLn( '# of syllables   : ', Word_Syll( AWord ) ); 
  WriteLn( 'Total # of words : ', NumWords( TEST ) ); 
  WriteLn( 'Total syllables  : ', Sent_Syll( TEST ) );
END.
