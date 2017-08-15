(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0005.PAS
  Description: PIANO.PAS
  Author: JUDY BIRMINGHAM
  Date: 05-28-93  13:57
*)

{
BILL BUCHANAN

> I'm just learning Pascal, and I was 1dering if it's possible 2 play
> music in Pascal?  if so... how?

Here's a little Program that allows you to play the "PIANO" on your keyboard.
No Soundcard needed or anything like that.  This may give you a small idea
on how to create your own Sounds ...

}

{ Note: does not seem to work properly on Free Pascal under WIndows 64 bits }

Program Music;                         {by Judy Birmingham, 9/18/92}
Uses
  Crt;

Const
  {-------------------------------------------------------------------}
  {These values will Vary by the song you choose}
  {I wish I could have made these Variables instead of Constants,
  but I seemed to be locked into using Const, because they define
  Array sizes in the Types declared below.}

  TotalLinesInSong = 4;             {Number of lines in song}
  MaxNotesInPhrase = 9;             {Max number of notes in any line}
  BeatNote         = 4;             {Bottom number in Time Signature}
                                    {Handles cut time (2/2), 6/8 etc.}
  Tempo            = 160;           {Number of beats per minute}
  {-------------------------------------------------------------------}
  {Note frequencies}
  R = 0;                            {Rest = frequency of 0 : silence}
  C = 260;                          {Frequency of middle c          }
  CC = 277;                         {Double letter indicates a sharp}
  D = 294;
  DD = 311;
  E = 330;
  F = 349;
  FF = 370;
  G = 392;
  GG = 415;
  A = 440;
  AA = 466;
  B = 494;

  {Note durations}
  Q  = 1 * (BeatNote/4);                            {Quarter note}
  I  = 0.5 * (BeatNote/4);                          {Eighth note}
  H  = 2 * (BeatNote/4);                            {Half note}
  W  = 4 * (BeatNote/4);                            {Whole note}
  S  = 0.25 * (BeatNote/4);                         {Sixteenth note}
  DQ = 1.5 * (BeatNote/4);                          {Dotted quarter}
  DI = 0.75 * (BeatNote/4);                         {Dotted eighth}
  DH = 3 * (BeatNote/4);                            {Dotted half}
  DS = 0.375 * (BeatNote/4);                        {Dotted sixteenth}

  Beat = 60000/Tempo;       {Duration of 1 beat in millisecs}

Type
  IValues = Array [1..MaxNotesInPhrase] of Integer;
  RValues = Array [1..MaxNotesInPhrase] of Real;
  Phrase  = Record
    Lyric  :  String;
    Notes  : IValues;   {Array of note frequencies}
    Octave : IValues;   {Array of note octaves}
    Rhythm : RValues;   {Array of note durations}
  end;
  Song = Array [1..TotalLinesInSong] of Phrase;

 {Sample song}
Const
  RowRow : Song = (
    (Lyric : 'Row Row Row Your Boat';
    NOTES   :  (C,C,C,D,E,R,0,0,0);
    OCTAVE  :  (1,1,1,1,1,1,0,0,0);
    RHYTHM  :  (DQ,DQ,Q,I,Q,I,R,0,0)
    ),

    (Lyric : 'Gently down the stream';
    NOTES   :  (E,D,E,F,G,R,0,0,0);
    OCTAVE  :  (1,1,1,1,1,1,0,0,0);
    RHYTHM  :  (Q,I,Q,I,DQ,DQ,0,0,0)
    ),

    (Lyric : 'Merrily merrily merrily merrily';
    NOTES :  (C,C,G,G,E,E,C,C,0  );
    OCTAVE : (2,2,1,1,1,1,1,1,0  );
    RHYTHM : (Q,I,Q,I,Q,I,Q,I,0  )
    ),

    (Lyric : 'Life is but a dream.';
    NOTES  : (G,F,E,D,C,R,0,0,0  );
    OCTAVE : (1,1,1,1,1,1,0,0,0  );
    RHYTHM  : (Q,I,Q,I,H,Q,0,0,0  )
    ));

Procedure LYRICS(THE_WORDS : String);
begin
  Writeln(THE_WORDS);
end;

Procedure PLAYNOTE (NOTE, OCT: Integer; DURATION : Real);
begin
  Sound (NOTE * OCT);
  Delay (Round(BEAT * DURATION));
  NoSound;
end;

Procedure PLAYPHRASE(N : Integer; NOTES, OCTAVE : IValues; RHYTHM : RValues);
Var
  INDEX : Integer;
begin
  For INDEX := 1 to N do
    PLAYNOTE (NOTES[INDEX], OCTAVE[INDEX], RHYTHM[INDEX]);
end;

Procedure PLAYSONG (Title : String; Tune : Song);
Var
  Counter : Integer;
begin
  ClrScr;
  GotoXY(11,3);
  Writeln (Title);
  Window (10,5,70,19);
  ClrScr;
  For counter := 1 to TotalLinesInSong do
  begin
    LYRICS(Tune[counter].Lyric);
    PLAYPHRASE(MaxNotesInPhrase, Tune[counter].Notes,
               Tune[counter].Octave, Tune[counter].Rhythm);
  end;
end;

begin
  ClrScr;
  PlaySong('"Row Row Row Your Boat "', RowRow);
end.
