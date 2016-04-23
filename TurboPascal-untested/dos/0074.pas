{
  Coded By Frank Diacheysn Of Gemini Software

  FUNCTION WHEREISDOS

  Input......: None
             :
             :
             :
             :


  Output.....: 2-Character String, Explained Further Below.
             :
             :
             :
             :

  Example....: IF Chars[1] = 'O' THEN
             :   WriteLn('DOS Is Resident In ROM')
             : ELSE
             :   WriteLn('DOS Is Resident In RAM');
             : IF Chars[2] = 'H' THEN
             :   WriteLn('DOS Is Loaded Into High Memory (HMA)')
             : ELSE
             :   WriteLn('DOS Is Loaded Into Conventional Memory');

  Description: Returns The Status Of Where DOS Is Loaded Using The Following:
             : Chars[1] = 'O' (Resident In ROM)
             : Chars[1] = 'A' (Resident In RAM)
             : Chars[2] = 'H' (Loaded In High Memory)
             : Chars[2] = 'C' (Loaded in Conventional Memory)

}
FUNCTION WHEREISDOS:STRING;
VAR Chars : ARRAY [1..2] OF CHAR;
BEGIN
  Regs.AH := $33;
  Regs.AL := $06;
  Intr( $33,Regs );
  IF (Regs.DH AND $04)=$04 THEN Chars[1] := 'O' ELSE Chars[1] := 'A';
  IF (Regs.DH AND $08)=$08 THEN Chars[2] := 'H' ELSE Chars[2] := 'C';
  WHEREISDOS := Chars[1]+Chars[2];
END;
