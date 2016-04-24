(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0108.PAS
  Description: Fast Char Deletion
  Author: N.HARTKAMP
  Date: 05-26-95  23:01
*)

{
From: <hartkamp@mail.rz.uni-duesseldorf.de>
Might be that FUNCTION CREMOVE is of interest for anyone.
}
FUNCTION CRemove(INP, Del : STRING) : STRING;
VAR DeleteChar : SET OF CHAR;
    Bytes      : ARRAY[0..31] OF BYTE ABSOLUTE DeleteChar;
    BytePos    : BYTE;
    BitShift   : BYTE;
    DelChar    : CHAR;
    i          : BYTE;
    S          : STRING;
BEGIN
  FillChar(Bytes, SizeOf(Bytes), #0);
  FOR i := 1 TO BYTE(Del[0]) DO BEGIN
    DelChar := Del[i];
    BytePos := BYTE(DelChar) DIV 8;
    BitShift:= BYTE(DelChar) MOD 8;
    Bytes[BytePos] := Bytes[BitShift] OR (1 SHL BitShift);
  END;
  S := '';
  FOR i := 1 TO BYTE(Inp[0]) DO
    IF NOT (Inp[i] IN DeleteChar) THEN S := S + Inp[i];
  CRemove := S;
END;

VAR S : STRING;

BEGIN
  S := '══T??$h$ßßßi═ß????s$ %i%s? ???═a% ?T═e%st.???ßßß%ß.%ßßßß.';
  Writeln('the test string: ');
  Writeln(S);
  Write('press <RETURN>'); Readln;
  Writeln('the test string with cremove: ');
  writeln(CREMOVE(S, '%$═?ß'));
  Writeln('Ok...');
END.


