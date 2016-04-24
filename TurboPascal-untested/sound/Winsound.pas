(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0016.PAS
  Description: WINSOUND.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{
Fellow Windows voyeurs,

A While ago people were asking how to obtain Sound through
the PC speaker without using the multimedia DLL (or a
speaker driver For that matter.)  Below is a basic example
of how to do this.
}
  Procedure SoundStart;
  Var
    Pitch : Integer;
  begin
  OpenSound;
  For Pitch:= 80 to 84 do
    begin
    SetVoicenote (1, Pitch, 100, 1);
    SetVoiceAccent (1, 15, 255, s_Legato, Pitch);
    end;
  StartSound;
  WaitSoundState (S_QueueEmpty);
  StopSound;
  CloseSound
  end;

{
Please reference your Windows API reference manual For
the SetVoicenote() and SetVoiceAccent() synopsys.

Microsoft supports the calls in Windows 3.0, however
documentation in 3.1 suggests that it will no longer
support them.  My interpretation is that For the
future these calls will be supported, however will not
be enhanced or Extended.  Their reasoning is probably
based on there drive to sell their multimedia kits.
}

