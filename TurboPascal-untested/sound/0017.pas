{  SEE XX34 modules at end of document !!!}

{$R-,F+}

{
  ******************************************************************
  BGSND.PAS

  Background Sound for Turbo Pascal

  Adapted from BGSND.INC for Turbo Pascal 3.0
  by Michael Quinlan
  9/17/85

  This version for Turbo Pascal 6.0
  by Larry Hadley
  3/20/93

  The routines are rather primitive, but could easily be extended.

  The sample routines included implement something similar to the
  BASIC PLAY statement.
  ******************************************************************
}
Unit BGSND;

INTERFACE

Uses
   DOS;

CONST
   BGSVer = '2.0';               { Unit version number }

   BGSPlaying :boolean = FALSE;  { TRUE while music is playing }

VAR
   _BGSNumItems :integer;

procedure BGSPlay(n :integer; VAR items);

procedure _BGSStopPlay;

procedure PlayMusic(s :string);

IMPLEMENTATION

TYPE
   BGSItem = RECORD
                cnt :word;     { count to load into the 8253-5 timer;
                                 count = 1,193,180 / frequency }
                tics:integer;  { timer tics to maintain the sound;
                                 18.2 tics per second }
             end;

   _BGSItemP = ^BGSItem;

VAR
   _BGSNextItem :_BGSItemP;
   _BGSOldInt1C :pointer;
   _BGSDuration :integer;
   ExitSave     :pointer;

procedure _BGSsaveDS; external;      { saves ds as a CS:CONSTANT for use
                                        within the int 1C vector }
procedure _BGSPlayNextItem; external; { used by int 1C vector - selects next
                                        note to play }
procedure _BGSStopPlay; external;

procedure _BGSInt1C; external;        { int1C vector - hooks timer }
{$L BGS.OBJ}

procedure BGSPlay(n :integer; VAR items);
{
  ***************************************************************************
  You call this procedure to play music in the background. You pass the
  number of sound segments, and an array with an element for each sound
  segment. The array elements are two words each; the first word has the
  count to be loaded into the timer (1,193,180 / frequency). The second word
  has the duration of the sound segment, in timer tics (18.2 tics per second).
  ***************************************************************************
}
  VAR
     item_list : array[0..1000] of BGSItem ABSOLUTE items;
  BEGIN
     while BGSPlaying do { wait for previous sounds to finish } ;

     if n > 0 then
     BEGIN
        _BGSNumItems := n;
        _BGSNextItem := Addr(item_list[0]);
        BGSPlaying   := TRUE;
        _BGSPlayNextItem;
        _BGSsaveDS;
        SetIntVec($1C, @_BGSInt1C);
     END;
  END;

procedure BGSErrorExit;
{
 **************************************************************************
 In case there's an "oopsie" ... make sure that Int $1C is clean, and
 music isn't playing.
 **************************************************************************
}
  BEGIN
     ExitProc := ExitSave;
     if BGSPLaying then
     BEGIN
        _BGSStopPlay;
        SetIntVec($1C, _BGSOldInt1C);
     END;
  END;

{
 **************************************************************************

    BASIC PLAY Routines

 **************************************************************************
}

{$R+}

VAR
   MusicArea : array[1..255] of BGSItem; { contains sound segments }

{
  frequency table from:
  Peter Norton's Programmer's Guide to the IBM PC, p. 147
}
CONST
   Frequency : array[0..83] of real =
{    C        C#       D        D#       E        F        F#       G        G#       A        A#       B }
  (32.70,   34.65,   36.71,   38.89,   41.20,   43.65,   46.25,   49.00,   51.91,   55.00,   58.27,   61.74,
   65.41,   69.30,   73.42,   77.78,   82.41,   87.31,   92.50,   98.00,  103.83,  110.00,  116.54,  123.47,
  130.81,  138.59,  146.83,  155.56,  164.81,  174.61,  185.00,  196.00,  207.65,  220.00,  233.08,  246.94,
  261.63,  277.18,  293.66,  311.13,  329.63,  349.23,  369.99,  392.00,  415.30,  440.00,  466.16,  493.88,
  523.25,  554.37,  587.33,  622.25,  659.26,  698.46,  739.99,  783.99,  830.61,  880.00,  932.33,  987.77,
 1046.50, 1108.73, 1174.66, 1244.51, 1378.51, 1396.91, 1479.98, 1567.98, 1661.22, 1760.00, 1864.66, 1975.53,
 2093.00, 2217.46, 2349.32, 2489.02, 2637.02, 2793.83, 2959.96, 3135.96, 3322.44, 3520.00, 3729.31, 3951.07
  );

procedure PlayMusic(s :string);
{
  ***************************************************************************
  Accept a string similar to the BASIC PLAY statement. The following are

  allowed:
    A to G with optional #

    Plays the indicated note in the current octave.
    A # following the letter indicates sharp.
    A number following the letter indicates the length of the note
    (4 = quarter note, 16 = sixteenth note, 1 = whole note, etc.).

    On

    Sets the octave to "n". There are 7 octaves, numbered 0 to 6. Each
    octave goes from C to B. Octave 3 starts with middle C.

    Ln

    Sets the default length of following notes. L1 = whole notes, L2 = half
    notes, etc. The length can be overridden for a specific note by follow-
    ing the note letter with a number.

    Pn

    Pause. n specifies the length of the pause, just like a note.

    Tn

    Tempo. Number of quarter notes per minute. Default is 120.

    Period (.) terminates processing.

    Spaces are allowed between items, but not within items.
  ***************************************************************************
}

   VAR
      i, n,            { i is the offset in the parameter string;
                         n is the element number in MusicArea }
      NoteLength,
      Tempo,
      CurrentOctave :integer;
      cchar         :char;

   function GetNumber:integer;
   {
    **************************************************************************
    get a number from the parameter string
    increments i past the end of the number
    **************************************************************************
   }
      VAR
         n :integer;
      BEGIN
         n := 0;
         WHILE (i <= length(s)) and (s[i] in ['0'..'9']) do
         BEGIN
            n := n*10+(Ord(s[i])-Ord('0'));
            i := i+1;
         end;
         GetNumber := n;
      END;

   procedure GetNote;
   {
    **************************************************************************
    Input is a note letter. convert it to two sound segments -- one for the
    sound then a pause following the sound.
    increments i past the current item
    **************************************************************************
   }
      VAR
         note,
         len  :integer;
         l    :real;

      function CheckSharp(n :integer):integer;
      {
       ************************************************************************
       check for a sharp following the letter. increments i if one found
       ************************************************************************
      }
         BEGIN
            if (i < length(s)) and (s[i] = '#') then
            BEGIN
               i := i + 1;
               CheckSharp := n + 1
            END
            ELSE
               CheckSharp := n;
         END;  { CheckSharp }

      function FreqToCount(f : real) : integer;
      {
        ***********************************************************************
        convert a frequency to a timer count
        ***********************************************************************
      }
         BEGIN
            FreqToCount := Round(1193180.0/f);
         END;  { FreqToCount }

      BEGIN  { GetNote }
         case cchar of
          'A' : note := CheckSharp(9);
          'B' : note := 11;
          'C' : note := CheckSharp(0);
          'D' : note := CheckSharp(2);
          'E' : note := 4;
          'F' : note := CheckSharp(5);
          'G' : note := CheckSharp(7)
         end; { case }

         MusicArea[n].cnt := FreqToCount(Frequency[(CurrentOctave*12)+note]);
         if (s[i] in ['0'..'9']) and (i <= length(s)) then
            len := GetNumber
         else
            len := NoteLength;
         l := 18.2*60.0*4.0/(Tempo*len);
         MusicArea[n].tics := Round(7.0*l/8.0);

         if MusicArea[n].tics = 0 then
            MusicArea[n].tics := 1;
         n := n + 1;
         MusicArea[n].cnt := 0;
         MusicArea[n].tics := Round(l/8.0);

         if MusicArea[n].tics = 0 then
            MusicArea[n].tics := 1;
         n := n + 1;
      END;  { GetNote }

      procedure GetPause;
      {
       ************************************************************************
       input is a pause. convert it to a silent sound segment.
       increments i past the current item
       ************************************************************************
      }
         VAR
            len  :integer;
            l    :real;

         BEGIN  { GetPause }
            MusicArea[n].cnt := 0;
            if (s[i] in ['0'..'9']) and (i <= length(s)) then
               len := GetNumber
            else
               len := NoteLength;
            l := 18.2*60.0*4.0/(Tempo*len);
            MusicArea[n].tics := Round(l);
            if MusicArea[n].tics = 0 then
               MusicArea[n].tics := 1;
            n := n + 1;
         END;  { GetPause }

   BEGIN { PlayMusic }
      NoteLength := 4;
      Tempo := 120;
      CurrentOctave := 3;

      n := 1;
      i := 1;
      while (i <= length(s)) and (s[i]<>'.') do
      BEGIN
         cchar := s[i];
         i := i + 1;
         case cchar of
          'A'..'G' : GetNote;
          'O'      : CurrentOctave := GetNumber;
          'L'      : NoteLength    := GetNumber;
          'P'      : GetPause;
          'T'      : Tempo         := Getnumber
         end; { case }
      END;
      BGSPlay(n-1, MusicArea)
   END; { PlayMusic }

BEGIN { Unit init code }
  ExitSave := ExitProc;
  ExitProc := @BGSErrorExit;

  GetIntVec($1C, _BGSOldInt1C);

  Writeln('BGS v'+BGSVer);
END.

(*   DEMO PROGRAM FOR BACKGROUND SOUND *)

{$M 1024, 0, 0}
Program PlayBG;

Uses
   DOS,
   CRT,
   BGSND;

VAR
   F1              :text;
   play_str, buf,
   fname, progname :string;

Procedure Usage;
   BEGIN
      Writeln('PLAYBG <playfile>');
      Writeln(#10+#13+'Where:');
      Writeln(' <playfile> is the file containing the music you want played in');
      Writeln('            the background');
      Writeln(#10+#13+'The playfile contains a series of notes in ascii format');
      Writeln;
      Halt(1);
   END;

{$I-}
Function Exists(name:string):boolean;
   VAR
      F :file;
   BEGIN
      Assign(f, name);
      Reset(f);
      if IOresult<>0 then
         Exists := FALSE
      ELSE
      BEGIN
         Exists := TRUE;
         Close(f);
      END;
   END;
{$I+}

Function AskYN:boolean;
   VAR
      ch :char;
   BEGIN
      repeat
         ch := ReadKey;
         if ch = #0 then
         BEGIN
            ch := ReadKey;
            ch := #0;
         END;
      until ch in ['y','Y','n','N'];
      Write(ch);
      case ch of
        'Y','y' : AskYN := TRUE;
        'N','n' : AskYN := FALSE;
      END;
   END;

BEGIN
   Writeln('Background Play 1.0');

   if ParamCount<1 then
      Usage;

   fname := ParamStr(1);
   Assign(F1, fname);

   if (fname='') or not(Exists(fname)) then
   BEGIN
      Writeln('Invalid playfile.');
      Halt(2);
   END;

   play_str := '';
   Reset(F1);

   repeat
      ReadLn(F1, buf);
      play_str := play_str+buf;
   until Eof(F1) or (Length(play_str)>=200);

   Close(F1);

   Writeln(play_str);  {debug}
   PlayMusic(play_str);

   Exec(GetEnv('COMSPEC'), '');

   if BGSPlaying then
   BEGIN
       Writeln('Music still playing - wait for it to finish?');
       if Not(AskYN) then
          _BGSStopPlay;
       while BGSPLaying do;
   END;
END.

(*

XX34 Of OBJ CODE FILES.  Extract to separte files and use XX3401 to
create BGS.OBJ and PLAYFIL.ASC.  Here is how to use :

1. Copy first block to BGS.XX.
2. run XX3401 : XX3401 D BGS.XX.  This will create BGS.OBJ.
3. Copy second block to PLAYFIL.XX.
4. run XX3401 : XX3401 D PLAYFIL.XX
5. Write unit code to BGSND.PAS.  Compile.
6. Write demo code to PLAYSND.PAS Compile and run.



*XX3401-000674-210393--68--85-48874---------BGS.OBJ--1-OF--1
U-U+3aIuL4ZWPJlWNrBjRKtYL47bQmt-IooeW0++++-IRL7WPm--QrBZPK7gNL6U63NZ
QbBdPqsUAWskAMS65U-+uF6-RFcKNHdQOK7hL47bQqxpPaFQMaRn9Y3HHJ46+k-+uImK
+U++O6U1+20VZ7M9++F2EJF--2F-J22Xa+Q+G++++UA-2tM9++F1HoF3-2BDF2IVa+Q+
8Bo+-+I-Icl3++lTEYRHHZJBGJF3HJA+13x0FpBCFJVIGJF3HE+ALo75IoxAF2ZCJ131
++lTEYRHF3JGEJF7Hos+0Y75Ip-AEJZ7HYQ+ZN+L+++023x0FpBEH23NHYJMJ2ZIFIp3
+++XY-++++67Lo75IoZCJ131WE++Ad+F+++00Zx0FpBHFJF7HZE6+++tY-A+++6ALo75
IpBIHp-EH23N8E++Pt+F+++00Zx0FpBHEJN3F3A0++-EW+E+E86-YO1T++60+0uA5U++
mpK9v9U++6v+WoM8gEHqsMjsWoM4yei9FUWfysjZLQc4+9UQ+30V+U-EcE++I+vcnzzY
MGHsta54-U+++AhJWymV++-6ck++g9PaEwEy+++aWULaEWO8FE5aEWO9FE8X+++aUno+
R+PYMEk1ta52DU++XII2XA8X++073U6+WyJRmpK9v3-HIJ7KJls4ymuC5U++cE++G8A+
+6Ay++++RGbYMGHsta41DU+++5IMi-k+I820+30V++-E1iV1zwM4++++ukKE1iVozkQT
LptOKJhMWyJRnsmQLU12+pE0l0k4+ED2A+M-+wEz-U23l2Q4+E52GkM-+QFH-U20l4I4
+EH2REM-+gFx-U20l624+E92ZZE0l7Y4+EH2bEM--AGV-U22l8s4+E52i+M-+wGw-U21
lAI4+EJrWU6++5E+
***** END OF XX-BLOCK *****

{-------------------------  CUT HERE -------------------------------}

*XX3401-000047-210393--68--85-51905-----PLAYFIL.ASC--1-OF--1
J1Uk62wo62ks62R4FIN5FoQUI1UUFYN4B0-5EY6o62R4FIN5FoQUFoN4FoN31Ec+
***** END OF XX-BLOCK *****

*)


