{

PB> It's me again.  I need code to detect a SB/SB Compat.  card.  I have
PB> code which will detect the port, but I also need a way of detecting the
PB> SB's IRQ and DMA channel.  Is there any such code available?

This code was just posted about 2 weeks ago (I believe)... }


Program DetectSoundBlaster;

Uses DOS, CRT;

Function hex(a : Word; b : Byte) : String;
Const digit : Array[$0..$F] Of Char = '0123456789ABCDEF';
Var i : Byte;
  xstring : String;
Begin
  xstring:='';
  For i:=1 To b Do
  Begin
    Insert(digit[a And $000F], xstring, 1);
    a:=a ShR 4
  End;
  hex:=xstring
End; {hex}

Procedure SoundPort;
Var xbyte1, xbyte2, xbyte3, xbyte4: Byte;
  xword, xword1, xword2, temp, sbport: Word;
  sbfound, portok: Boolean;

Begin
  ClrScr;
  Write('Sound Blaster: ');
  sbfound:=False;
  xbyte1:=1;
  While (xbyte1 < 7) And (Not sbfound) Do
  Begin
    sbport:=$200 + ($10 * xbyte1);
    xword1:=0;
    portok:=False;
    While (xword1 < $201) And (Not portok) Do
    Begin
      If (Port[sbport + $0C] And $80) = 0 Then
        portok:=True;
      Inc(xword1)
    End;
    If portok Then
    Begin
      xbyte3:=Port[sbport + $0C];
      Port[sbport + $0C]:=$D3;
      For xword2:=1 To $1000 Do {nothing};
      xbyte4:=Port[sbport + 6];
      Port[sbport + 6]:=1;
      xbyte2:=Port[sbport + 6];
      xbyte2:=Port[sbport + 6];
      xbyte2:=Port[sbport + 6];
      xbyte2:=Port[sbport + 6];
      Port[sbport + 6]:=0;
      xbyte2:=0;
      Repeat
        xword1:=0;
        portok:=False;
        While (xword1 < $201) And (Not portok) Do
        Begin
          If (Port[sbport + $0E] And $80) = $80 Then
            portok:=True;
          Inc(xword1)
        End;
        If portok Then
          If Port[sbport + $0A] = $AA Then
            sbfound:=True;
        Inc(xbyte2);
      Until (xbyte2 = $10) Or (portok);
      If Not portok Then
      Begin
        Port[sbport + $0C]:=xbyte3;
        Port[sbport + 6]:=xbyte4;
      End;
    End;
    If sbfound Then
    Begin
      Write('Yes');
      Write(' Port: ');
      Write('$', Hex(sbport, 3));
    End
    Else
      Inc(xbyte1);
  End;
  If Not sbfound Then
    Write('No');
End;{soundport}

Begin
  SoundPort;
End.

