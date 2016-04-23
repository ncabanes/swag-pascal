{
NORBERT IGL

>> if you already have the DAC Programming, simply Write out each
>> Byte to the DAC PORT (Write $10, then the data For Direct Mode)
>> Then Delay after each Byte, depending on the Sampling rate.
>> You'll have to play around With the Delay's.

  Just found a piece of source in my Files.... (:-)),
  but i don't know the original author ( RedFox ? )
  and i translated the (orig.) german remarks....
}

Uses
  Crt;
Const
  ResetPort  = $226;
  ReadPort   = $22A;
  WritePort  = $22C;
  StatusPort = $22C;
  DataDaPort = $22E;

  { N.I.: Note: Use SB_Port (prev. Msg) to get the correct address.... }

  AD_Null       = $80;
  OK            = 0000;
  NichtGefunden = 1000;
  DirectDAC     = $10;
  SpeakerOn     = $D1;
  SpeakerOff    = $D3;

Var
  DSPResult   : Word;
  DSPReadWert : Byte;

  loop : Word;
  w    : Word;
  m    : Word;


Procedure WriteToDSP(Command : Byte);
begin
  Repeat Until (port[StatusPort] and $80) = 0;
  port[WritePort] := Command;
end;

Procedure ReadFromDSP;
begin
  Repeat Until (port[DataDaPort] and $80) = $80;
  DSPReadWert := port[ReadPort];
end;

Procedure ResetDSP;
Var
  MaxVersuch : Byte;
begin
  MaxVersuch:=100;
  Repeat
    port[ResetPort] := 1;
    Delay(10);
    port[ResetPort] := 0;
    ReadFromDSP;
    dec(MaxVersuch);
  Until (DSPReadWert = $AA) or (MaxVersuch = 0);

  if MaxVersuch = 0 then
    DSPResult := NichtGefunden
  else
    DSPResult := OK;
end;


begin
  ClrScr;

  ResetDSP;

  if DSPResult <> OK then
  begin
    Writeln(' Soundeblaster not found !');
    Writeln(' Wrong SB-address ?');
  end
  else
  begin
    Writeln(' Demo : direct output to the SoundblasterCard !');
    Writeln('  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌  creates a square');
    Writeln('  │  │  │  │  │  │  │  │  │  │  │  waveform With an');
    Writeln('──┘  └──┘  └──┘  └──┘  └──┘  └──┘  64`er amplitude ');
    Writeln;
    Writeln(' RedFox (14.11.91) ');

    WriteToDSP(SpeakerOn);               { Speaker on }

    m := 5000;                           { dynamc Wait (Init) }

    For loop := 1 to 600 do              { 600 samples }
    begin
      dec(m, 10);
      if m < 20 then
        m := 500;
      WriteToDSP(DirectDAC);             { command to SB  }
      WriteToDSP(AD_Null + 32);          { now the sample }

      { rising edge    }
      For w := 1 to m do begin end;      { dynamc wait    }

      WriteToDSP(DirectDAC);             { command to SB  }
      WriteToDSP(AD_Null - 32);          { falling edge   }

      For w := 1 to m do begin end;      { wait again     }
    end;
    WriteToDSP(SpeakerOff);              { speaker off }
  end;
end.
