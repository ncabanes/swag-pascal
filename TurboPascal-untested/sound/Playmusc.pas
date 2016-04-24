(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0006.PAS
  Description: PLAYMUSC.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{ Here is a Unit that plays music. It came out of this echo recently. }


Unit Music;

Interface

Uses
  Crt;
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
Var
  N : Byte;
begin
  Freq_Val[1] := 1;
  For N := 2 To 12 Do
    Freq_Val[N] := Freq_Val[N-1] * 1.0594630944;
  Oct_Val[0] := 32.70319566;
  For N := 1 To 8 Do
    Oct_Val[N] := Oct_Val[N-1] * 2;
end;

Procedure PlayTone(Octave : Byte; Note : Byte; Duration : Word);
begin
  If Note = R Then
    NoSound
  Else
    Sound(Round(Oct_Val[Octave] * Freq_Val[Note]));
  Delay(Duration*8);
  NoSound;
end;

Procedure ToneOn(Octave : Byte; Note : Byte);
begin
  If Note = R Then
    NoSound
  Else
    Sound(Round(Oct_Val[Octave] * Freq_Val[Note]));
end;

begin
  Set_Frequencies;
  NoSound;
end.

{
  This does not include the actual values of the tones, but it is still
very helpful (more so than if you had the actual freqencies). If you still
want the tones, just substitute the value For the tone into the Procedures
that play the tone.
}
