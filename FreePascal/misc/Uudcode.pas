(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0058.PAS
  Description: UUDCODE.PAS
  Author: BOB SWART
  Date: 11-21-93  09:50
*)

{
From: BOB SWART
Subj: UUDECODE.PAS
Here is my version of UUDECODE.PAS (also fully compatible):
}

{
  UUDeCode 3.0
  Borland Pascal (Objects) 7.0.
  Copr. (c) 9-29-1993 DwarFools & Consultancy drs. Robert E. Swart
                      P.O. box 799
                      5702 NP  Helmond
                      The Netherlands
  Code size: 4832 bytes
  Data size: 1330 bytes
  .EXE size: 3337 bytes
  ----------------------------------------------------------------
  This program uudecodes files.
}

Const
  SP = Byte(' ');

  Type
  TTriplet = Array[0..2] of Byte;
  TKwartet = Array[0..3] of Byte;

var f: Text;
    g: File of Byte;
    FileName: String[12];
    Buffer: String;
    Kwartets: record
                lengte: Byte;
                aantal: Byte;
                kwart: Array[1..64] of TKwartet;
              end absolute Buffer;
    Trip: TTriplet;
    i: Integer;

    FUNCTION UpperStr(S : STRING) : STRING;
    VAR sLen : BYTE ABSOLUTE S;
        I    : BYTE;
    BEGIN
    FOR I := 1 TO sLEN DO S := UpCase(S[i]);
    UpperStr := S;
    END;

    procedure Kwartet2Triplet(Kwartet: TKwartet; var Triplet: TTriplet);
    begin
      Triplet[0] :=  ((Kwartet[0] - SP) SHL 2) +
                    (((Kwartet[1] - SP) AND $30) SHR 4);
      Triplet[1] := (((Kwartet[1] - SP) AND $0F) SHL 4) +
                    (((Kwartet[2] - SP) AND $3C) SHR 2);
      Triplet[2] := (((Kwartet[2] - SP) AND $03) SHL 6) +
                     ((Kwartet[3] - SP) AND $3F)
    end {Kwartet2Triplet};


begin
  writeln('UUDeCode 3.1 (c) 1993 DwarFools & Consultancy' +
                              ', by drs. Robert E. Swart'#13#10);
  if ParamCount = 0 then
  begin
    writeln('Usage: UUDeCode infile [outfile]');
    Halt
  end;

  if UpperStr(ParamStr(1)) = UpperStr(ParamStr(2)) then
  begin
    writeln('Error: infile = outfile');
    Halt(1)
  end;

  Assign(f,ParamStr(1));
  FileMode := $40;
  reset(f);
  if IOResult <> 0 then
  begin
    writeln('Error: could not open file ',ParamStr(1));
    Halt(2)
  end;
  repeat
    readln(f,Buffer) { skip }
  until eof(f) or (Copy(Buffer,1,5) = 'begin');
  if Buffer[11] = #32 then FileName := Copy(Buffer,12,12)
  else
    if Buffer[10] = #32 then FileName := Copy(Buffer,11,12)
                        else FileName := ParamStr(2);
  {$IFDEF DEBUG}
  writeln(FileName);
  {$ENDIF}

  if UpperStr(ParamStr(1)) = UpperStr(FileName) then
  begin
    writeln('Error: input file = output file');
    Halt(1)
  end;

  Assign(g,FileName);
  if ParamCount > 1 then
  begin
    FileMode := $02;
    reset(g);
    if IOResult = 0 then
    begin
      writeln('Error: file ',FileName,' already exists.');
      Halt(3)
    end
  end;
  rewrite(g);
  if IOResult <> 0 then
  begin
    writeln('Error: could not create file ',FileName);
    Halt(4)
  end;

  while (not eof(f)) and (Buffer <> 'end') do
  begin
    FillChar(Buffer,SizeOf(Buffer),#32);
    readln(f,Buffer);
    if Buffer <> 'end' then
    begin
      for i:=1 to (Kwartets.aantal-32) div 3 do
      begin
        Kwartet2Triplet(Kwartets.kwart[i],Trip);
        write(g,Trip[0],Trip[1],Trip[2])
      end;
      if ((Kwartets.aantal-32) mod 3) > 0 then
      begin
        Kwartet2Triplet(Kwartets.kwart[i+1],Trip);
        for i:=1 to ((Kwartets.aantal-32) mod 3) do write(g,Trip[i-1])
      end
    end
  end;
  close(f);
  close(g);

  if ParamCount > 1 then
    writeln('UUDeCoded file ',FileName,' created.');
  writeln
end.

