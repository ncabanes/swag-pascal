(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0014.PAS
  Description: Read Keyboard STATE Keys
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:49
*)

{
>Can someone give me some code to make the lights Num lock/caps
>lock/scroll lock keys to turn on?
}

Program KeySet;
Const
  CapsState   = $40; { Mask For Caps Lock state }
  NumState    = $20; { Mask For Num Lock state }
  ScrollState = $10; { Mask For Scroll Lock state }
Var
  Kb : Byte Absolute $0040:$0017; { Address of keyboard flags }
  I  : Byte;
  S  : String;
begin
  if ParamCount = 0 then
  begin
    WriteLn;
    WriteLn(' Command line options:');
    WriteLn;
    WriteLn(' C toggle Cap lock state');
    WriteLn(' N toggle Num lock state');
    WriteLn(' S toggle Scroll lock state');
    WriteLn(' Add + to turn on and - to turn off');
    Halt(1);
  end;
  For I := 1 to ParamCount Do
  begin
    S := ParamStr(I);
    S[1] := UpCase(S[1]);
    { toggle Caps Lock }
    if S = 'C' then Kb := Kb xor CapsState;
    { toggle Num Lock }
    if S = 'N' then Kb := Kb xor NumState;
    { toggle Scroll Lock }
    if S = 'S' then Kb := Kb xor ScrollState;
    { Set Caps Lock on }
    if S = 'C+' then Kb := Kb or CapsState;
    { Set Num Lock on }
    if S = 'N+' then Kb := Kb or NumState;
    { Set Scroll Lock on }
    if S = 'S+' then Kb := Kb or ScrollState;
    { Set Caps Lock off }
    if S = 'C-' then Kb := Kb and not (CapsState or not Kb);
    { Set Num Lock off }
    if S = 'N-' then Kb := Kb and not (NumState or not Kb);
    { Set Scroll Lock off }
    if S = 'S-' then Kb := Kb and not (ScrollState or not Kb);
  end;

  Write('Caps Lock  : ');
  if (Kb and CapsState) = CapsState then
    WriteLn('ON')
  else
    WriteLn('ofF');

  Write('Num Lock   : ');
  if (Kb and NumState) = NumState then
    WriteLn('ON')
  else
    WriteLn('ofF');

  Write('Scroll Lock: ');
  if (Kb and ScrollState) = ScrollState then
    WriteLn('ON')
  else
    WriteLn('ofF');
end.

{
This Program will toggle, Turn on, or Turn off the Caps Lock, Num
Lock, and Scroll Lock lights. and when its done it tells you the
state of each key.
}

