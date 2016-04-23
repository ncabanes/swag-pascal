{$M 16384,0,0}

Program Demo; { to demonstrate the SBVoice Unit }
              { Copyright 1991 Amit K. Mathur, Windsor, Ontario }

Uses SBVoice;

begin
if SBFound then begin
  if paramcount=1 then begin
    LoadVoice(ParamStr(1),0,0);
    sb_Output(seg(SoundFile),ofs(SoundFile)+26);
    Repeat
     Write('Ha');
    Until StatusWord=0;
  end else
    Writeln('Usage: DEMO [d:\path\]Filename.voc');
  end else
  Writeln('SoundBlaster Init Error.  SoundBlaster v1.00 not Found.');
end.

