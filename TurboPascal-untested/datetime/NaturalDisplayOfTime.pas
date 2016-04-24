(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0057.PAS
  Description: Natural display of time
  Author: DAVID ADAMSON
  Date: 11-25-95  09:26
*)

(*
QT displays the time in natural English.
Example: It's twenty past seven.
*)

{$A+,B-,D-,E-,F-,I-,L-,N-,O-,R-,S-,V-}
{$M 1024,0,0}
program QueryTime;

uses Dos;

const
  QNear: array[0..4] of string[11] = (
    '',' just past',' just after',' nearly',' almost');

                                   {You may wish to change naught to twelve.}
  Numbers: array[0..12] of string[6] = ('naught',
    'one','two','three','four','five','six','seven','eight','nine',
    'ten', 'eleven', 'twelve');

  REXX   : String[30] = 'REXX - Mike Colishaw 1979, 85';
  PASCAL : String[30] = 'Pascal - Brad Zavitsky 1995';
  TWEAKS : String[30] = 'Tweaks - David Adamson 1995';

var
  Hour, Min, Sec, S100: Word;
  Out: string[79];

procedure Tell;
begin
  Writeln('QT displays the time in natural english.');
end;

begin
  Out := '';
  if paramcount > 0 then Tell;                         {Describe the program}
  Writeln;
  GetTime(Hour, Min, Sec, S100);                      {Get the time from DOS}
 {writeln(hour,':', min,':',sec);                    Un-comment for testing }
  if Sec > 29 then inc(Min);               {Where we are in 5 minute bracket}

  Out := 'It''s' + QNear[Min mod 5];              {Start building the result}

  if Min > 32 then Inc(Hour);                            {We are TO the hour}
  inc(Min, 2);                   {Shift minutes to straddle a 5-minute point}

                    {For special case the result for Noon and midnight hours}
  if ((hour mod 12) = 0) and ((min mod 60) <= 4) then
    begin
      if Hour = 12 then Writeln(Out, ' Noon.')
        else Writeln(Out, ' Midnight.');
      Halt;
    end;                                              {We are finished here}

  Dec(Min, Min mod 5);                       {Find the nearest five minutes}
  if Hour > 12 then Dec(Hour, 12);                 {Get rid of 24hour clock}
  case Min of
     5: Out := Out + ' five past ';
    10: Out := Out + ' ten past ';
    15: Out := Out + ' a quarter past ';
    20: Out := Out + ' twenty past ';
    25: Out := Out + ' twenty-five past ';
    30: Out := Out + ' half past ';
    35: Out := Out + ' twenty-five to ';
    40: Out := Out + ' twenty to ';
    45: Out := Out + ' a quarter to ';
    50: Out := Out + ' ten to ';
    55: Out := Out + ' five to ';
    else
      begin
        Out := Out + ' ';
        Min := 0;
      end;
  end; {Case}
  Out := Out + Numbers[Hour];
  if min = 0 then Out := Out + ' o''clock';
  Writeln(Out,'.');
end.

