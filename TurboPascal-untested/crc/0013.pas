{
Program/utility which can be used to check the 'sorted' File and the data
File. It produces the Byte CheckSum of the Files (which must be identical),
and can check the sortorder of the File (when given the option -s)...
}
{$A+,B-,D-,F-,G+,I-,L-,N-,O-,R-,S+,V-,X-}
{$M 16384,0,655360}
{ Here is the Program CHECKSUM that you can run to check the master data
  File For TeeCee's String sorting contest. if you have a slow machine I
  suggest you set the Program running and go to bed!! :-)

  Code size: 5952 Bytes
  Data size:  924 Bytes
  .EXE size: 6304 Bytes
}
Uses
  Crt;

Const
  Version = 'CheckSum 1.0 (c) 1992 DwarFools & Consultancy, '+
                                  'by drs. Robert E. Swart'#13#10;
  Usage   = 'Usage: CheckSum dataFile [-s]'#13#10 +
   '       Options: -s to check the sortorder of the Strings'#13#10;
  MaxStr  = 30;
  Error     : LongInt = 0;
  Records   : LongInt = 0;
  CheckSum  : Byte = 0;     { Byte CheckSum of all Bytes in data File xor'ed }
  Sortorder : Boolean = False; { Assume option -s is not given }

Var
  Str      : String[MaxStr];
  len      : Byte Absolute Str;
  ByteStr  : Array [0..MaxStr] of Byte Absolute Str;
  PrevStr,
  UpperStr : String[MaxStr];
  f        : File;
  i        : Integer;

begin
  Writeln(Version);
  if ParamCount = 0 then
  begin
    Writeln(Usage);
    Halt;
  end;

  assign(f, ParamStr(1)); { Change this to your chosen File name }
  reset(f, 1);
  if Ioresult <> 0 then
  begin
    Writeln('Error: could not open ', ParamStr(1));
    Writeln(Usage);
    Halt(1);
  end;

  if (ParamCount = 2) and ((ParamStr(2) = '-s') or (ParamStr(2) = '-S')) then
      Sortorder := True;

  Writeln('Strings x 1000 checked:');
  While not eof(f) do
  begin
    BlockRead(f, len, 1);
    BlockRead(f, Str[1], len);
    For i := 0 to len do
      CheckSum := CheckSum xor ByteStr[i];

    if Sortorder then
    begin
      UpperStr[0] := Str[0];
      For i := 1 to len do
        UpperStr[i] := UpCase(Str[i]);
      if Records > 0 then
      begin
        if PrevStr > UpperStr then
        begin
          Inc(Error);
          Writeln;
          Writeln('Error: ',PrevStr,' > ',UpperStr);
        end;
        PrevStr := UpperStr;
      end;
    end;
    Inc(Records);
    if (Records mod 1000) = 0 then
    begin
      GotoXY(1, WhereY);
      Write(Records div 1000:3);
    end;
  end;
  close(f);
  Writeln;
  Write(Records,' Strings checked, ');
  if Sortorder then
    Writeln(Error, ' Errors found, ');
  Writeln('Byte CheckSum = ', CheckSum);
end.
