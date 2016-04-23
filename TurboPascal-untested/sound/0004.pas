{
> Does anyone have a "musical scale" of all the values With the Sound
> Function? A friend is writing a "happy birthday" Program and wants to
> get a list of all the notes without actually testing them (G)

{ Here's a handy Unit that takes a lot of work out of playing music. }
{ I think it originally came from this echo.                         }

Unit Music;
Interface
Uses Crt;
Const
   e_note = 15;       { Eighth Note      }
   q_note = 30;       { Quarter Note     }
   h_note = 60;       { Half Note        }
   dh_note = 90;      { Dotted Half Note }
   w_note = 120;      { Whole Note       }
   R = 0;             { Rest             }
   C = 1;             { C                }
   Cs = 2;            { C Sharp          }
   Db = 2;            { D Flat           }
   D = 3;             { D                }
   Ds = 4;            { D Sharp          }
   Eb = 4;            { E Flat           }
   E = 5;             { Etc...           }
   F = 6;
   Fs = 7;
   Gb = 7;
   G = 8;
   Gs = 9;
   Ab = 9;
   A = 10;
   As = 11;
   Bb = 11;
   B = 12;

Procedure PlayTone(Octave : Byte; Note : Byte; Duration : Word);
Procedure ToneOn(Octave   : Byte; Note     : Byte);

Implementation

Var
   Oct_Val  : Array [0..8] Of Real;
   Freq_Val : Array [C..B] Of Real;

Procedure Set_Frequencies;
Var N : Byte;
begin
   Freq_Val[1] := 1;
   For N := 2 To 12 Do
      Freq_Val[N] := Freq_Val[N-1] * 1.0594630944;
   Oct_Val[0] := 32.70319566;
   For N := 1 To 8 Do
      Oct_Val[N] := Oct_Val[N-1] * 2;
end;

Procedure PlayTone(Octave : Byte;
                   Note : Byte;
                   Duration : Word);
begin
   If Note = R Then
      NoSound
   Else
      Sound(Round(Oct_Val[Octave] * Freq_Val[Note]));
   Delay(Duration*8);
   NoSound;
end;

Procedure ToneOn(Octave : Byte;
                 Note   : Byte);
begin
   If Note = R Then NoSound
   Else Sound(Round(Oct_Val[Octave] * Freq_Val[Note]));

end;

begin
Set_Frequencies;
NoSound;
end.


{
Someone else: Here they are:

Const
    C     =  2093;
    C#    =  2217;
    D     =  2349;
    D#    =  2489;
    E     =  2637;
    F     =  2794;
    F#    =  2960;
    G     =  3136;
    G#    =  3322;
    A     =  3520;
    A#    =  3729;
    H     =  3951;

The next C is 2*2093, the C below is 2093 div 2 etc. pp.
}

{

Here's an octive:
  C = 262;
  CSHARP = 277;
  D = 294;
  DSHARP = 311;
  E = 330;
  F = 349;
  FSHARP = 370;
  G = 392;
  GSHARP = 415;
  A = 440;
  ASHARP = 466;
  B = 494;
  CC = 523;
}