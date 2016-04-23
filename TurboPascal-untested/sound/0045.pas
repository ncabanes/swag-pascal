{
Could somebody tell me how to program the FM-voices of my sound-blaster ?

Here's a .sbi player for you...
}
program SBIread;
uses Crt;
const SBIREG : array[1..11] of Word =
  ($20,$23,$40,$43,$60,$63,$80,$83,$E0,$E3,$C0);
var
  FromF: file;
  I: integer;
  FN: string;
  NumRead, NumWritten: Word;
  buf: array[1..2048] of Char;
  ch: char;
  IsSBI: boolean;
  SBIName: string;
procedure Bit;
begin
  Delay(1); {something fancier was suggested, but this works fine}
end;                                                                           

function CheckSoundCard: boolean;
var Temp, Temp2: byte;
begin
  port[$388]:=$4; repeat until Port[$22E] > 127;
  port[$389]:=$60; repeat until Port[$22E] > 127;
  port[$389]:=$80; repeat until Port[$22E] > 127;
  Temp:=port[$388];
  port[$388]:=$2; repeat until Port[$22E] > 127;
  port[$389]:=$FF; repeat until Port[$22E] > 127;
  port[$388]:=$4; repeat until Port[$22E] > 127;
  port[$389]:=$21; repeat until Port[$22E] > 127;
  Delay(1);
  Temp2:=port[$388];
  port[$388]:=$4; repeat until Port[$22E] > 127;
  port[$389]:=$60; repeat until Port[$22E] > 127;
  port[$389]:=$80; repeat until Port[$22E] > 127;
  If ((temp and $E0)=$00) and ((temp2 and $E0)=$c0) then
    CheckSoundCard:=True else CheckSoundCard:=False;
end;
procedure ClearCard;
var CP: byte;
begin
  For CP:=0 to 255 do begin
    port[$388]:=CP;
    port[$389]:=0;
  end;
end;
procedure Sounder(A,B: byte);
begin
  port[$388]:=A; Bit;
  port[$389]:=B; Bit;
end;
begin
  Writeln('SBI file player');
  if not CheckSoundCard then begin
    writeln('Soundcard not detected!');
    halt(1);
  end;
  FN:=ParamStr(1);
  If Pos('.',FN)=0 then FN:=FN+'.SBI';
  Assign(FromF, FN);
  Reset(FromF, 1);
  BlockRead(FromF,buf,SizeOf(buf),NumRead);
  Close(FromF);
  If (buf[1]='S') and (buf[2]='B') and (buf[3]='I') and (ord(buf[4])=26)
    then IsSBI:=True else IsSBI:=False;
  If IsSBI=False then Writeln('Not a SBI file!') else begin
    SBIName:='';
    I:=4;
    repeat
      i:=i+1;
      if (ord(buf[i])<>0) then SBIName:=SBIName+buf[i];
    until ord(buf[i])=0;
    Writeln('Name of file      : ',FN);
    Writeln('Name of instrument: ',SBIName);
    ClearCard;
    for i:=1 to 11 do Sounder(SBIreg[i],ord(buf[i+36]));
    Sounder($A0,$58);
    Sounder($B0,$31);
    Delay(900);
    ClearCard;
  end;
end.
