{
CHRIS PRIEDE

> Can anyone give me any samples of TSR routines?

    My old example of a generic keyboard TSR has mysteriously
disappeared, so I had to write a new one. This is as simple TSR as it
can be: no stack switching, no DOS reentrancy check. In the form
presented here it simply beeps when you press Shift-Esc. Set your own
hotkey and rewrite TsrMain to turn it into something useful.

    Use Crt unit for screen writes and don't try to access files. Since
it uses foreground program's stack, you shouldn't use deeply nested or
recursive function calls, or declare large local variables. This is more
on demo side, but will get you started.
}

program GenericKeyboardTSR;
{$M 0, 0, 512}      { reduce memory size }
{$S-,R-}         { can't use stack or range checking in TSR }


uses
  Dos, Crt;

Const
  RtShift       = $01;
  LtShift       = $02;
  AnyShift      = RtShift + LtShift;
  Ctrl          = $04;
  Alt           = $08;

  HotKey        = $01;      { Hotkey scan code, Esc }
  HotShiftState = AnyShift; { Hotkey shift state }
  FakeFlags     = 0;        { Fake flags for interrupt call }

type
  IntProc = procedure(Flags : word);

var
  OldInt09 : IntProc;
  Popped   : boolean;


procedure Enable; Inline($FB);      { inline macro -- STI }

procedure TsrMain;      { TSR main procedure, executed on hotkey }
begin
  Sound(400);           { Make noise (replace with something useful) }
  Delay(100);
  NoSound;
end;

procedure NewInt09; interrupt;
begin
  Enable;               { Allow other interrupts }
  if (not Popped) and (Port[$60] = HotKey) and  { if not in TSR already }
     (Mem[$40 : $17] and $0F = HotShiftState) then { and hotkey detected }
  begin
    Popped := true;     { set Popped to avoid re-entry }
    Port[$61] := Port[$61] or $80;      { reset keyboard }
    Port[$61] := Port[$61] and not $80;
    Port[$20] := $20;   { signal end of interrupt }
    TsrMain;            { run TSR main procedure }
    Popped := false;    { clear Popped and return }
  end
  else
    OldInt09(FakeFlags); { call old handler }
end;


begin           { installation }
  Popped := false;
  GetIntVec($09, pointer(@OldInt09)); { Install int. handler}
  SetIntVec($09, @NewInt09);
  Keep(0);    { stay resident }
end.
