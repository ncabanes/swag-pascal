(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0009.PAS
  Description: Learning about TSR's
  Author: SEAN PALMER
  Date: 08-27-93  21:31
*)

{
SEAN PALMER

>I don't know if he is or not...but I'd like to see a simple and verbose
>explanation on how to make a TSR...pref. using the KEEP Procedure...

OK. I'll Write up one right quick. This isn't gonna be tested (hard to
test a TSR While keeping your mail Program in memory...)
}

Program TSRTest;

Uses
  Dos;

Var
  oldInt : Procedure;  {hook For old keyboard interrupt handler}

Procedure newInt; interrupt;  { interrupt keyWord makes Procedure far }
                              { also saves/restores all regs and }
                              { ends With an iRet instruction }
                              { sets up DS correctly also but }
                              { Uses caller's stack }
Var
  i : Word;
  b : Boolean;
begin
  b := port[$60] < $80;   {see if it's a press}

  oldInt;     {call old interrupt handler For keystrokes (BIOS)}

  if b then
    For i := 0 to $3FFF do   {change screen colors as example}
      mem[$B800 : i * 2] := succ(mem[$B800 : i * 2]) and $EF;
end;

begin
  getIntVec(9, @oldInt);  { keep previous keyboard hooks }
  setIntVec(9, @newInt);  { patch in our keyboard interrupt handler }
  keep(0);  { returns Exit code of 0 (normal termination) }
            { and stays resident }
end.

{
 All it does is sit in memory, and every time you press a key,
 it gets called, and it changes the screen colors.

 That's about as simple as you're gonna get, now verbosity was never my
 strong point. if you don't understand something, ask.

 DJ Murdoch's TPU2TPS For TP 6.0 lets you make VERY small tsr's, but this
 will link in about 1k worth of the system Unit plus some stuff from the
 Dos Unit which will make it about 1.5k.

 If you wanna Write TSR's the best bet is to learn assembly.
}

