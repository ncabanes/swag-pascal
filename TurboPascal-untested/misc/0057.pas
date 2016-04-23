{
From: BOB SWART
Subj: UUENCODE.PAS
Here is my version of UUENCODE.PAS (fully compatible):
}

{$IFDEF VER70}
{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S+,T-,V-,X-}
{$ELSE}
{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,R-,S+,V-,X-}
{$ENDIF}
{$M 8192,0,0}
{
  UUEnCode 3.0
  Borland Pascal (Objects) 7.0.
  Copr. (c) 9-29-1993 DwarFools & Consultancy drs. Robert E. Swart
                      P.O. box 799
                      5702 NP  Helmond
                      The Netherlands
  Code size: 4880 bytes
  Data size: 1122 bytes
  .EXE size: 3441 bytes
  ----------------------------------------------------------------
  This program uuencodes files.
}

Const
  SP = Byte(' ');

Type
  TTriplet = Array[0..2] of Byte;
  TKwartet = Array[0..3] of Byte;

var Triplets: Array[1..15] of TTriplet;
    kwar: TKwartet;
    FileName: String[12];
    i,j: Integer;
    f: File;
    g: Text;


    FUNCTION UpperStr(S : STRING) : STRING;
    VAR sLen : BYTE ABSOLUTE S;
        I    : BYTE;
    BEGIN
    FOR I := 1 TO sLEN DO S := UpCase(S[i]);
    UpperStr := S;
    END;

    procedure Triplet2Kwartet(Triplet: TTriplet; var Kwartet: TKwartet);
    var i: Integer;
    begin
      Kwartet[0] := (Triplet[0] SHR 2);
      Kwartet[1] := ((Triplet[0] SHL 4) AND $30) +
                    ((Triplet[1] SHR 4) AND $0F);
      Kwartet[2] := ((Triplet[1] SHL 2) AND $3C) +
                    ((Triplet[2] SHR 6) AND $03);
      Kwartet[3] := (Triplet[2] AND $3F);
      for i:=0 to 3 do
      begin
        if Kwartet[i] = 0 then Kwartet[i] := $40;
        Inc(Kwartet[i],SP)
      end
    end {Triplet2Kwartet};


begin
  writeln('UUEnCode 3.0 (c) 1993 DwarFools & Consultancy' +
                              ', by drs. Robert E. Swart'#13#10);
  if ParamCount = 0 then
  begin
    writeln('Usage: UUEnCode infile [outfile]');
    Halt
  end;
  if UpperStr(ParamStr(1)) = UpperStr(ParamStr(2)) then
  begin
    writeln('Error: infile = outfile');
    Halt(1)
  end;

  Assign(f,ParamStr(1));
  FileMode := $40;
  reset(f,1);
  if IOResult <> 0 then
  begin
    writeln('Error: could not open file ',ParamStr(1));
    Halt(2)
  end;

  if ParamCount <> 2 then
  begin
    FileName := ParamStr(1);
    i := Pos('.',FileName);
    if i > 0 then Delete(FileName,i,Length(FileName));
    FileName := FileName + '.UUE'
  end
  else FileName := ParamStr(2);

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
      halt(3)
    end
  end;
  rewrite(g);
  if IOResult <> 0 then
  begin
    writeln('Error: could not create file ',FileName);
    Halt(4)
  end;

  writeln(g,'begin 0777 ',ParamStr(1));
  repeat
    FillChar(Triplets,SizeOf(Triplets),#0);
    BlockRead(f,Triplets,SizeOf(Triplets),i);
    write(g,Char(SP+i));
    for j:=1 to (i+2) div 3 do
    begin
      Triplet2Kwartet(Triplets[j],kwar);
      write(g,Char(kwar[0]),Char(kwar[1]),Char(kwar[2]),Char(kwar[3]))
    end;
    writeln(g)
  until (i < SizeOf(Triplets));
  writeln(g,'end');
  close(f);
  close(g);

  if ParamCount > 1 then
    writeln('UUEnCoded file ',FileName,' created.');
  writeln
end.



The basic scheme is to break groups of 3 eight bit characters (24 bits) into 4
six bit characters and then add 32 (a space) to each six bit character which
maps it into the readily transmittable character.  Another way of phrasing this
is to say that the encoded 6 bit characters are mapped into the set:

       !"#$%&'()*+,-./012356789:;<=>?@ABC...XYZ[\]^_

for transmission over communications lines.

As some transmission mechanisms compress or remove spaces, spaces are changed
into back-quote characters (a 96).  (A better scheme might be to use a bias of
33 so the space is not created, but this is not done.)

The advantage of this over just hex encoding is that it put in 6 bits of signal
per byte, instead of just 4.  The target is to get the smallest uncompressed
size, since the assumption is that you've already compressed as much redundancy
as possible out of the original.

