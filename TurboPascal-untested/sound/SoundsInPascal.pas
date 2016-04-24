(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0026.PAS
  Description: Sounds In Pascal
  Author: JOERGEN DORCH
  Date: 08-27-93  21:41
*)

{
JOERGEN DORCH

 About Sounds i Pascal - Here's how I do it:
}

Function Frequency(Octave, NoteNum : Integer) : Integer;
Const
  Silence = 32767;
Var
  Oct : Integer;

  Function Power(X, Y : Real) : Real;
  begin
    Power := Exp(Y * Ln(X));
  end;

begin
  Oct := Octave - 3;
  if NoteNum > 0 then
    Frequency := Round(440 * Power(2, Oct + ((NoteNum - 10) / 12)))
  else
    Frequency := Silence;
end;

{
Where Octave is in the range [0..6] and NoteNum in the range [1..12],
that is C = 1, C# = 2, D = 3 etc.
}
