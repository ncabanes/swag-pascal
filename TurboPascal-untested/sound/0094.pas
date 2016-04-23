{--Title:       MVFUNCT.PAS
   Author:      Patrick O'Malley AKA Silicom Slim
   Constact:    e-mail: d005530c@dcfreenet.seflin.lib.fl.us
   Language:    Turbo Pascal v6.0
   Description: Functions and procedures to interface with the ProAudio
                Spectrum's mixer and volume controls.
   Status:      Public Domain

  This unit is a primer for programming the ProAudio Spectum basic or 16, it
doesn't seem to matter.
  IMPORTANT TECH NOTE: All settings are in percent! Just a decimal from 0 to
100. Very odd. And sometimes when you set a volume too low, it will just go
to 0. Basically what you enter will result in a volume +-2 percentage points
off what you entered. Doesn't make much difference.
  I have no idea what CrossChannels are. Or the FMSplitChips thing. They don't
seem too interesting anyhow.
  For the unknowing, mixers and volumes are basically the same thing. Setting
the output of a mixer changes it's volume if you play something that uses
that mixer. For example, a cd-rom drive is attached to the internal mixer
input. The volume functions aren't really just for volumes anyhow. They
control the treble, bass, loudness & enhanced switches too.
  Most of the procedures and functions are simple to understand. The
GetFunctionTable procedure is used internally by the unit.

  I'd like to request code re:SoundBlaster mixer/vol stuff. --}

Unit MVFunct;

interface

CONST
{--volume channel select constants--}
{--These constants are used _only_ with the functions/procedures that use a
   call to functiontable.mvset(or get)volumefunction.
    VolMute is strange. It appears in the COMMON.INC file of the PAS-SDK
   but is never explained and doesn't seem to have an effect.
    VolLoudEnh is also odd. It is supposed to be used to set the Loudness
   and Enhanced switches (and it does). The only problem is that using
   a value of 100% turns _both_ on. Doing a 0% turns off only enhanced then.
   Maybe there is some trick I haven't discovered.
    VolBass & VolTreble set the Bass and Treble.
    VolLeft and VolRight are the master volume settings.
    VolMode is some sort of modal setting. No documentation in the PAS-SDK.--}

VolMute    = $40;
VolLoudEnh = $41;
VolBass    = $42;
VolTreble  = $43;
VolLeft    = $44;
VolRight   = $45;
VolMode    = $46;

{--mixer selection constants--}
{--These constants are used when a mixer can either be an input of output
   mixer. For example, the internal connector (hooked to the cd-rom drive)
   can either output sound or input it. So you can select the levels at
   which it does these. For outputting sound levels use pmOUTPUTMIXER. --}
pmOUTPUTMIXER = $00;
pmINPUTMIXER  = $20;

{--left channel selection values--}
{--these constants are used to select which mixer (they are: internal which
   is usually the CD-ROM, external which _can_ be attached to external music
   equiptment, microphone, PCM or digital sound, the internal speaker which
   is re-routed by the pro-audio out it's speakers and the sound-blaster
   emulation mixer. I have no idea what R_ or L_IMIXER is.--}
L_FM = $01;
L_IMIXER = $02;
L_EXT = $03;
L_INT = $04;
L_MIC = $05;
L_PCM = $06;
L_SPEAKER = $07;
L_FREE = $00;
L_SBDAC = $00;

{--right channel selection values--}
{--these constants can be used in places that ask for the channel to, for
   example, change the setting of. they are for the right channel only. --}
R_FM = $08;
R_IMIXER = $09;
R_EXT = $0A;
R_INT = $0B;
R_MIC = $0C;
R_PCM = $0D;
R_SPEAKER = $0E;
R_FREE = $0F;
R_SBDAC = $0F;

{--The following is used for the get/set, on/off procedures--}
Get = True;
Set_ = False;
On = true;
Off = false;


Type tFunctionTable = record
                        MVSetMixerFunction,
                        MVSetVolumeFunction,
                        MVSetFilterFunction,
                        MVSetCrossChannel,
                        MVGetMixerFunction,
                        MVGetVolumeFunction,
                        MVGetFilterFunction,
                        MVGetCrossChannel,
                        MVRealSoundSwitch,
                        MVFMSplitSwitch     : Pointer;
                      end;
Var FunctionTable : tFunctionTable;


Function IsMVSOUNDInstalled : Boolean;
Procedure GetFunctionTable;             {internal, used by MVFUNCT.TPU}
Procedure SetMasterVolume(R,L : Boolean;R_Setting,L_Setting : Word);
Procedure SetMixer(In_Out, Channel_Select : Byte; Mixer_Setting : Word);
Procedure GetMasterVolume(R,L : Boolean; Var R_Setting, L_Setting : Word);
Function GetMixer(In_Out, Channel_Select : Word) : Byte;
Procedure SetFilter(Filter_Setting : Byte);
Function GetFilter : Byte;
Procedure Get_Set_RealSound(Get_Set : Boolean;Var On_Off : boolean);
Procedure SetVolume(Channel,Setting : Word);
Function GetVolume(Channel : Word) : Byte;
Function GetIRQ : Byte;
Function GetDMA : Byte;

implementation

Function IsMVSOUNDInstalled : Boolean;
{Basically this function checks for MVSOUND.SYS, the device driver that is
 required to do the mixer functions that follow. Simple. }
Var edx : Word;
Begin
  IsMVSOUNDInstalled := FALSE;
  asm
    mov  ax, 0bc00h
    mov  bx, 03f3fh
    xor  cx, cx
    xor  dx, dx
    int  2fh
    xor  cx, bx
    xor  dx, cx
    mov  [edx], dx
  end;
  if edx = $4d56 then IsMVSOUNDInstalled := True
  else IsMVSOUNDInstalled := False;
End;    {IsMVSOUNDInstalled func}

Procedure GetFunctionTable;          {used by the unit}
Var FTableSeg, FTableOfs : Word;
Begin
  Asm
    mov  ax, 0bc03h
    int  2fh
    mov  [ftableofs], bx        {function table offset}
    mov  [ftableseg], dx        {function table segment}
  end;
  {--Move the table into the function table of pointers for pascal--}

Move(Mem[ftableseg:ftableofs],Mem[seg(functiontable):ofs(functiontable)],40);
End; {GetFunctionTable proc}

Procedure SetMasterVolume(R,L : Boolean;R_Setting,L_Setting : Word);
{This procedure is actually the SetVolume procedure but is master volume
 channel specific.
 Vars R&L : Boolean tell it which channel (right or left) to change.
 R_&L_Setting are the % (0-100) to set the channel to.
}
Begin
  If R then begin
  asm
    mov  bx, R_Setting
    mov  cx, VolRight
    {$F+}
    call functiontable.mvsetvolumefunction
    {$F-}
  end;
  end;
  if L then begin
  asm
    mov  bx, L_Setting
    mov  cx, VolLeft
    {$F+}
    call functiontable.mvsetvolumefunction
    {$F-}
  end;
  end;
End; {setmastervolume func}

Procedure SetMixer(In_Out, Channel_Select : Byte; Mixer_Setting : Word);
{ This procedure is used to set the I/O volume of one of the mixers.
  In_Out is a constant listed above under mixer selection constants.
  Channel_Select is either the right or left constant from the list above
  under channel selection values.
  Mixer_Setting is the % (0-100) to set the volume to.
}
Begin
  Asm
    mov  bx, Mixer_Setting
    xor  cx, cx
    xor  dx, dx
    mov  cl, In_Out
    mov  dl, Channel_Select
    {$F+}
    call functiontable.MVSetMixerFunction
    {$F-}
  End;
End;    {setmixer proc}

Procedure GetMasterVolume(R,L : Boolean; Var R_Setting, L_Setting : Word);
{ See SetMaster volume for the variable descriptions.
  Basically returns the current master volume.
}
Var Temp : Word;
Begin
  If R then Begin
  Asm
    mov  cx, VolRight
    {$F+}
    call functiontable.mvgetvolumefunction
    {$F-}
    mov  [Temp], bx
  end;
  R_Setting := Temp;
  end;
  If L then Begin
  asm
    mov  cx, VolLeft
    {$F+}
    call functiontable.mvgetvolumefunction
    {$F-}
    mov  [Temp], bx
  end;
  L_Setting := Temp;
  end;
End; {getmastervolume proc}

Function GetMixer(In_Out, Channel_Select : Word) : Byte;
{ See SetMixer for variable descriptions.
  Basically just returns the volume of the selected mixer.
}
Var Temp : Byte;
Begin
  asm
    mov  cx, In_Out
    mov  dx, Channel_Select
    {$F+}
    call functiontable.mvgetmixerfunction
    {$F-}
    mov  [temp], bl
  end;
  GetMixer := Temp;
end;  {getmixersetting proc}

Procedure SetFilter(Filter_Setting : Byte);
{ I'm a little unsure about this function call. Here is what the SDK says:
    0% filters out amything higher than 0khz  (mute)
    100% filters out anything lower than 20khz
  It does mute it, but I can't attach a spectrum analyzer to the speaker
  to test the frequency.
  Filter_Setting is the % to filter?
}
Begin
  Asm
    xor  bx, bx
    mov  bl, Filter_Setting
    {$F+}
    call functiontable.mvsetfilterfunction
    {$F-}
  end;
End; {setfilter proc}

Function GetFilter : Byte;
{ See SetFilter }
Var Temp : Byte;
Begin
  asm
    {$F+}
    call functiontable.mvgetfilterfunction
    {$F-}
    mov [Temp], bl
  end;
  GetFilter := Temp;
End;  {getfilter proc}

Procedure Get_Set_RealSound(Get_Set : Boolean;Var On_Off : boolean);
{ If Get_Set is true then it is gotten, otherwise it is set.
  If On_Off is true then it is turned on, otherwise turned off.

  I added some constants: Get, Set_, On, Off for this procedure. If someone
  wants to make this procedure better, you have my blessing. Yuk.
}
Var ebx, ecx, return : word;
Begin
  if Get_Set then ecx := 0 else ecx := 1;
  if on_off then ebx := 100 else ebx := 0;
  asm
    mov bx, ebx
    mov cx, ecx
    {$F+}
    call functiontable.mvrealsoundswitch
    {$F-}
    mov [return], bx
  end;
  If Get_Set then
    If return = 100 then On_Off := True
    else On_Off := False;
end;   {get_set_realsound}

Function GetIRQ : Byte;
{ Returns the IRQ of the PAS }
Var Res : Byte;
Begin
  asm
    mov  ax, 0bc04h
    int  2fh
    mov  [res], cl
  end;
  GETIRQ := res;
end;   {getirq proc}

Function GetDMA : byte;
{ Returns the DMA of the PAS }
Var res: byte;
Begin
  asm
    mov  ax, 0bc04h
    int  2fh
    mov  [res], bl
  end;
  GetDMA := Res;
End;  {getdma proc}

Procedure SetVolume(Channel,Setting : Word);
{ This procedure will change the setting of a specific channel specified by
  the constants listed under volume channel selection constants.
  Channel is the constant specifying the channel to change
  Setting is the % volume (0-100)
}
Begin
  asm
    mov  bx, Setting
    mov  cx, Channel
    {$F+}
    call functiontable.mvsetvolumefunction
    {$F-}
  end;
End;  {setvolume proc}

Function GetVolume(Channel : Word) : Byte;
{ See setvolume }
Var Res:Byte;
Begin
  asm
    mov  cx, channel
    {$F+}
    call functiontable.mvgetvolumefunction
    {$F-}
    mov  [res], bl
  end;
  GetVolume := Res;
End; {getvolume func}

begin
  if isMVSOUNDInstalled then getfunctiontable
  else begin
         Writeln('MVSOUND.SYS is not installed.');
         Halt(1);
  End;
end.
