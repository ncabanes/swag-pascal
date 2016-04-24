(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0271.PAS
  Description: vk_numlock Tip
  Author: RICK WHEAT
  Date: 05-30-97  18:17
*)

{
Greetings, Folks!

Here's a small routine you might find useful.  I'm using it to
automatically turn on Num Lock for users of a small billing system here at
the Home.
}

procedure TFrmMain.SetNumlockTrue(Sender: TObject);
var
  CurrentState : Integer;
  KeyState : TKeyBoardState;
begin
  CurrentState := GetKeyState(vk_numlock);
  GetKeyboardState(KeyState);
  If CurrentState = 0 then
    begin
      KeyState[vk_numlock] := 1;
      SetKeyboardState(KeyState);
    end;
end;

