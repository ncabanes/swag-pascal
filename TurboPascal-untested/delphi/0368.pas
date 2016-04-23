
I'm trying to add a delay of a few seconds into a formless DLL written in
Delphi

Using the VCL TTimer seems to be precluded because it is a component,
and its create method is looking for that all familiar Sender:TComponent, =20=

The following function should work in both 16 and 32 bit environment

Procedure GoSleep(SleepFor: DWord);
var
StartTicks: LongInt;
Begin
  {$IfDef Win16}
    StartTicks := GetTickCount + SleepFor;
    While GetTickCount < StartTicks Do
      Begin
        //Optional
        Application=ProcessMessages;
      End;
  {$Else}
    Sleep(SleepFor);
  {$EndIf}
End;
