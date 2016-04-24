(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0001.PAS
  Description: ALLNOTES.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{
> Anyone out there ever bothered to fing out what numbers make which note,
> eg. does any know if Sound(3000) makes an A, a C, D#, or what?  I'd like
> to know as many as possible, hopefully With the middle C on a piano as
> one of them.
}

Const
  Notes : Array[1..96] Of Word =
  { C    C#,D-  D    D#,E-  E     F    F#,G-  G    G#,A-  A    A#,B-  B  }
  (0033, 0035, 0037, 0039, 0041, 0044, 0046, 0049, 0052, 0055, 0058, 0062,
   0065, 0069, 0073, 0078, 0082, 0087, 0093, 0098, 0104, 0110, 0117, 0123,
   0131, 0139, 0147, 0156, 0165, 0175, 0185, 0196, 0208, 0220, 0233, 0247,
   0262, 0277, 0294, 0311, 0330, 0349, 0370, 0392, 0415, 0440, 0466, 0494,
   0523, 0554, 0587, 0622, 0659, 0698, 0740, 0784, 0831, 0880, 0932, 0987,
   1047, 1109, 1175, 1245, 1329, 1397, 1480, 1568, 1661, 1760, 1865, 1976,
   2093, 2217, 2349, 2489, 2637, 2794, 2960, 3136, 3322, 3520, 3729, 3951,
   4186, 4435, 4699, 4978, 5274, 5588, 5920, 6272, 6645, 7040, 7459, 7902);

{
Each line represents one octave, starting With octave 0.  Middle C is 523Hz and
Middle A is 440 (middle A is what all other note calculations are besed on;
each note it the 12th root of 2 times the previous one.)  You should be able to
arrange the Array into two dimensions if you want to access it using an octave
and note #.
}

{
Here are the notes..

    C0      16.35    C2      65.41    C4     261.63    C6    1046.50
    C#0     17.32    C#2     69.30    C#4    277.18    C#6   1108.73
    D0      18.35    D2      73.42    D4     293.66    D6    1174.66
    D#0     19.45    D#2     77.78    D#4    311.13    D#6   1244.51
    E0      20.60    E2      82.41    E4     329.63    E6    1328.51
    F0      21.83    F2      87.31    F4     349.23    F6    1396.91
    F#0     23.12    F#2     92.50    F#4    369.99    F#6   1479.98
    G0      24.50    G2      98.00    G4     392.00    G6    1567.98
    G#0     25.96    G#2    103.83    G#4    415.30    G#6   1661.22
    A0      27.50    A2     110.00    A4     440.00    A6    1760.00
    A#0     29.14    A#2    116.54    A#4    466.16    A#6   1864.66
    B0      30.87    B2     123.47    B4     493.88    B6    1975.53
    C1      32.70    C3     130.81    C5     523.25    C7    2093.00
    C#1     34.65    C#3    138.59    C#5    554.37    C#7   2217.46
    D1      36.71    D3     146.83    D5     587.33    D7    2349.32
    D#1     38.89    D#3    155.56    D#5    622.25    D#7   2489.02
    E1      41.20    E3     164.81    E5     659.26    E7    2637.02
    F1      43.65    F3     174.61    F5     698.46    F7    2793.83
    F#1     46.25    F#3    185.00    F#5    739.99    F#7   2959.96
    G1      49.00    G3     196.00    G5     783.99    G7    3135.96
    G#1     51.91    G#3    207.65    G#5    830.61    G#7   3322.44
    A1      55.00    A3     220.00    A5     880.00    A7    3520.00
    A#1     58.27    A#3    233.08    A#5    932.33    A#7   3729.31
    B1      61.74    B3     246.94    B5     987.77    B7    3951.07
}                                                       C8    4186.01



