(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0003.PAS
  Description: MODMUSIC.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

    MOD File DEMO


 ST> I do, however, have the MOD File structures in a Text File.
 ST> NetMail if you want them.

 EW> Hey..  Could you post them here if their not too long?
 EW> All I have For MOD Files is a Program (so so) that plays them
 EW> through the PCSpeaker, and it's *ALL* in Asm, and I'd love
 EW> to be able to convert at least the File reading to pascal,

 The MOD File Format is not overly Complicated in itself, but the music
 encoded therein is very intricate, since the notes use non-standard
 notations For the frequency, and the effects For each note are very
 involved.  I can, however, post a good skeleton For the File structure,
 but if you want the effects commands, we'll have to go to NetMail,
 since it would not be in Pascal.

Type SongNameT = String[20]; {This is the first structure in the File, the
                              full name of the song in the File}
     SampleT = Record        {This structure is Repeated 31 times, and
                              describes each instrument}
        Name     : String[22];
        Len      : Word;     {Length of the sample wave pattern, which is
                              Near the end of the File.  This number is
                              the number of Words, use MUL 2 For Bytes}
        FineTune : Byte;     {0-7 = 0 to +7, 8-F = -8 to -1 offset from
                              normal played notes.  Useful For off-key
                              instruments}
        Volume   : Byte;     {0-64 Normal volume of instrument}
        RepeatAt : Word;     {offset in Words of the start of the pattern
                              Repeat For long notes.}
        RepeatLn : Word;     {Length in Words of the Repeated part of the
                              sample pattern}
        end;

     VoiceT = Record  {This structure is not in the MOD File itself, but
                       should help in organizing all of the voice's
                       Charicteristics}
        Sample  : Byte; {0-31    Which instrument sample to play}
        note    : Word; {12 bits Which note. Non-standard strange numbers}
        Effect  : Byte; {0-F     Effect to use on note}
        EffectC : Byte; {00-FF   Control Variable to effect}
        end;

     SongDataT = Record {This Record, at offset 950, contains inFormation
                         about the song music itself}
        SongLength : Byte; {1-128 Number of patterns (not wave) of
                            sets of musical notes}
        Fill1      : Byte; {Set to 127}
        Patterns   : Array[0..127] of Byte; {0-63 Outline of song}
                     {Tells which score to play where.  Number of
                      patterns is the highest number here}
        Initials   : String[4];             {"M.K.","FLT4", or "FLT8"}
        end;

     PatternDataT = Array[1..4] of Byte; {This structure is Repeated
                       four times For each note in the score (4 voices,
                       4 Bytes each}

     {After this the wave patterns For the samples are placed}

Var Voice  : Array[1.. 4] of VoiceT;  {Four voices}
    Sample : Array[1..31] of SampleT; {31 samples}

Procedure ParseData (Patt : PatternDataT, VoiceNum : Byte);
{Stuffs voice With pattern data beFore playing}
begin
  Voice[VoiceNum].Sample  := (Patt[1] mod 16) shl 4 + (Patt[3] mod 16);
  Voice[VoiceNum].note    := (Patt[2] shl 4) + (Patt[2] div 16);
  Voice[VoiceNum].Effect  := (Patt[3] div 16;
  Voice[VoiceNum].EffectC := Patt[4];
  end;

Anyway, this should help explain how to do something With the File.
if you need inFormation on what the numbers For the notes are or how
to interprit the effects, send NetMail.

