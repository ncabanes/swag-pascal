
Hi

> Well i am a very simple programmer, don't know much at the moment, but
> what i want is information on how to change a value in the Win95 system
> registry by clicking on a button. For example, how do i change the filename
> if the background in 95, by clicking on a button.

In the button's OnClick event, and don't forget 'Registry' in your
"uses" clause;

VAR
  Reg : TRegistry
  KeyName : string;
  Background : string;
Begin
  KeyName := '\Control Panel\Desktop'
  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;
  Reg.OpenKey(KeyName,false);

{this finds the current name}
  Background := Reg.ReadString('Wallpaper');

{this writes a new one}
  Reg.WriteString('Wallpaper',Background);

  Reg.CloseKey;
  Reg.Free;
End;
