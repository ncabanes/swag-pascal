(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0031.PAS
  Description: SOUND Machine
  Author: WIM VAN.VOLLENHOVEN
  Date: 10-28-93  11:38
*)

{===========================================================================
Date: 08-31-93 (22:24)
From: WIM VAN.VOLLENHOVEN
Subj: Sound Module
---------------------------------------------------------------------------
Well.. here is the source code i've found in a pascal toolbox (ECO)
which emulates the play function of qbasic :-)

{
  call: play(string)

        music_string --- the string containing the encoded music to be
                         played.  the format is the same as that of the
                         microsoft basic play statement.  the string
                         must be <= 254 characters in length.

  calls:  sound
          getint  (internal)

  remarks:  the characters accepted by this routine are:

            a - g       musical notes
            # or +      following a - g note, indicates sharp
            -           following a - g note, indicates flat
            <           move down one octave
            >           move up one octave
            .           dot previous note (extend note duration by 3/2)
            mn          normal duration (7/8 of interval between notes)
            ms          staccato duration
            ml          legato duration
            ln          length of note (n=1-64; 1=whole note,4=quarter note)
            pn          pause length (same n values as ln above)
            tn          tempo,n=notes/minute (n=32-255,default n=120)
            on          octave number (n=0-6,default n=4)
            nn          play note number n (n=0-84)

            the following two commands are ignored by play:

            mf          complete note before continuing
            mb          another process may begin before speaker is
                        finished playing note

  important --- setdefaultnotes must have been called at least once before
                this routine is called.
}

unit u_play;
interface

uses
  crt

  ;

const
  note_octave   : integer = 4;     { current octave for note            }
  note_fraction : real    = 0.875; { fraction of duration given to note }
  note_duration : integer = 0;     { duration of note     ^^semi-legato }
  note_length   : real    = 0.25;  { length of note }
  note_quarter  : real    = 500.0; { moderato pace (principal beat)     }



  procedure quitsound;
  procedure startsound;
  procedure errorbeep;
  procedure warningbeep;
  procedure smallbeep;
  procedure setdefaultnotes;
  procedure play(s: string);
  procedure beep(h, l: word);



implementation




  procedure quitsound;
  var i: word;
  begin
    for i := 100 downto 1 do begin sound(i*10); delay(2) end;
    for i := 1 to 800 do begin sound(i*10); delay(2) end;
    nosound;
  end;

  procedure startsound;
  var i: word;
  begin
    for i := 100 downto 1 do begin sound(i*15); delay(2) end;
    for i := 1 to 100 do begin sound(i*15); delay(2) end; nosound;
    delay(100); for i := 100 downto 1 do begin sound(i*10); delay(2) end;
    nosound;
  end;


  procedure errorbeep;
  begin
    sound(2000); delay(75); sound(1000); delay(75); nosound;
  end;


  procedure warningbeep;
  begin
    sound(500); delay(500); nosound;
  end;

  procedure smallbeep;
  begin
    sound(300); delay(50); nosound;
  end;





procedure setdefaultnotes;
begin
   note_octave   := 4;             { default octave                      }
   note_fraction := 0.875;         { default sustain is semi-legato      }
   note_length   := 0.25;          { note is quarter note by default     }
   note_quarter  := 500.0;         { moderato pace by default            }
end;



procedure play(s: string);
const
                                      { offsets in octave of natural notes }
 note_offset   : array[ 'A'..'G' ] of integer = (9,11,0,2,4,5,7);

                                      { frequencies for 7 octaves          }
   note_freqs: array[ 0 .. 84 ] of integer =
{
      c    c#     d    d#     e     f    f#     g    g#     a    a#     b
}
(    0,
     65,  69,  73,  78,  82,  87,  92,  98, 104, 110, 116, 123,
    131, 139, 147, 156, 165, 175, 185, 196, 208, 220, 233, 247,
    262, 278, 294, 312, 330, 350, 370, 392, 416, 440, 466, 494,
    524, 556, 588, 624, 660, 700, 740, 784, 832, 880, 932, 988,
   1048,1112,1176,1248,1320,1400,1480,1568,1664,1760,1864,1976,
   2096,2224,2352,2496,2640,2800,2960,3136,3328,3520,3728,3952,
   4192,4448,4704,4992,5280,5600,5920,6272,6656,7040,7456,7904 );

   quarter_note = 0.25;            { length of a quarter note }

   digits : set of '0'..'9' = ['0'..'9'];

var

   play_freq     : integer;        { frequency of note to be played }
   play_duration : integer;        { duration to sound note }
   rest_duration : integer;        { duration of rest after a note }
   i             : integer;        { offset in music string }
   c             : char;           { current character in music string }
                                   { note frequencies }
   freq          : array[0..6,0..11] of integer absolute note_freqs;
   n             : integer;
   xn            : real;
   k             : integer;

  function getint : integer;
  var n: integer;

  begin { getint }
    n := 0;
    while(s[i] in digits) do begin n := n*10+ord(s[i])-ord('0'); inc(i) end;
    dec(i); getint := n;
  end   { getint };

begin
  s := s + ' ';                   { append blank to end of music string }
  i := 1;                           { point to first character in music }
  while(i < length(s)) do begin      { begin loop over music string }
    c := upcase(s[i]);        { get next character in music string }
    case c of                 { interpret it                       }
       'A'..'G' : begin { a note }
          n         := note_offset[ c ];
          play_freq := freq[ note_octave ,n ];
          xn := note_quarter * (note_length / quarter_note);
          play_duration := trunc(xn * note_fraction);
          rest_duration := trunc(xn * (1.0 - note_fraction));
                                      { check for sharp/flat }
          if s[i+1] in ['#','+','-' ] then
             begin
                inc(i);
                case s[i] of
                   '#',
                   '+' : play_freq :=
                            freq[ note_octave ,succ(n) ];
                   '-' : play_freq :=
                            freq[ note_octave ,pred(n) ];
                   else  ;
                end { case };

             end;

                   { check for note length }

          if (s[i+1] in digits) then
             begin

                inc(i);
                n  := getint;
                xn := (1.0 / n) / quarter_note;

                play_duration :=
                    trunc(note_fraction * note_quarter * xn);

                rest_duration :=
                   trunc((1.0 - note_fraction) *
                          xn * note_quarter);

             end;
                   { check for dotting }

             if s[i+1] = '.' then
                begin

                   xn := 1.0;

                   while(s[i+1] = '.') do
                      begin
                         xn := xn * 1.5;
                         inc(i);
                      end;

                   play_duration :=
                       trunc(play_duration * xn);

                end;

                       { play the note }

          sound(play_freq);
          delay(play_duration);
          nosound;
          delay(rest_duration);
        end   { a note };

       'M' : begin { 'M' commands }
         inc(i);
         c := s[i];
         case c of
           'F' : ;
           'B' : ;
           'N' : note_fraction := 0.875;
           'L' : note_fraction := 1.000;
           'S' : note_fraction := 0.750;
           else ;
         end { case };
       end   { 'M' commands };

       'O' : begin { set octave }
         inc(i);
         n := ord(s[i]) - ord('0');
         if (n < 0) or (n > 6) then n := 4;
         note_octave := n;
       end   { set octave };

       '<' : begin { drop an octave }
         if note_octave > 0 then dec(note_octave);
       end   { drop an octave };

       '>' : begin { ascend an octave }
         if note_octave < 6 then inc(note_octave);
       end   { ascend an octave };

       'N' : begin { play note n }
         inc(i); n := getint;
         if (n > 0) and (n <= 84) then begin
           play_freq     := note_freqs[ n ];
           xn            := note_quarter * (note_length / quarter_note);
           play_duration := trunc(xn * note_fraction);
           rest_duration := trunc(xn * (1.0 - note_fraction));
         end else if (n = 0) then begin
           play_freq     := 0; play_duration := 0;
           rest_duration := trunc(note_fraction * note_quarter *
                                 (note_length / quarter_note));
         end;
         sound(play_freq); delay(play_duration); nosound;
         delay(rest_duration);
       end   { play note n };
       'L' : begin { set length of notes }
         inc(i); n := getint;
         if n > 0 then note_length := 1.0 / n;
       end   { set length of notes };

       'T' : begin { # of quarter notes in a minute }
         inc(i); n := getint;
         note_quarter := (1092.0 / 18.2 / n) * 1000.0;
       end   { # of quarter notes in a minute };

       'P' : begin { pause }
         inc(i); n := getint;
         if (n <  1) then n := 1 else if (n > 64) then n := 64;
         play_freq := 0; play_duration := 0;
         rest_duration := trunc(((1.0 / n) / quarter_note) * note_quarter);
         sound(play_freq); delay(play_duration); nosound;
         delay(rest_duration);
       end   { pause };

       else  { ignore other stuff };
    end { case };
    inc(i);
  end  { interpret music };
  nosound;                         { make sure sound turned off when through }
end;


procedure beep(h, l: word);
begin
  sound(h); delay(l); nosound;
end;

end. { of unit }

