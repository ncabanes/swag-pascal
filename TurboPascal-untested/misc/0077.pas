 {$A+,B-,D-,E-,F-,I+,N-,O-,R-,S-,V+}

program TestStringComp;
uses
  TpTimer;         (* TurboPower's public domain TpTimer unit.              *)

                   (* Run-Length-Encoded string compression.                *)
  function fustRLEcomp(stIn : string) : string;
  var
    byCount,
    byStInSize,
    byStTempPos : byte;
    woStInPos : word;
    stTemp : string;
  begin
    fillchar(stTemp, sizeof(stTemp), 0);
    byCount  := 1;
    byStTempPos := 1;
    woStInPos := 1;
    byStInSize := ord(stIn[0]);
    repeat
      if (woStInPos < byStInSize)
      and (stIn[woStInPos] = stIn[succ(woStInPos)])
      and (byCount < $7F) then
        inc(byCount)
      else
        if (byCount > 3) then
          begin
            stTemp[byStTempPos]       := #0;
            stTemp[(byStTempPos + 1)] := chr(byCount);
            stTemp[(byStTempPos + 2)] := stIn[woStInPos];
            inc(stTemp[0], 3);
            inc(byStTempPos, 3);
            byCount := 1
          end
        else
          begin
            move(stIn[succ(woStInPos - byCount)],
                 stTemp[byStTempPos], byCount);
            inc(stTemp[0], byCount);
            inc(byStTempPos, byCount);
            byCount := 1
          end;
      inc(woStInPos, 1)
    until (woStInPos > byStInSize);
    fustRLEcomp := stTemp
  end;


                   (* Run-Length-Encoded string expansion.                  *)
  function fustRLEexp(stIn : string) : string;
  var
    byStInSize,
    byStTempPos : byte;
    woStInPos : word;
    stTemp : string;
  begin
    fillchar(stTemp, sizeof(stTemp), 0);
    byStInSize := ord(stIn[0]);
    byStTempPos := 1;
    woStInPos := 1;
    repeat
      if (stIn[woStInPos] <> #0) then
        begin
          stTemp[byStTempPos] := stIn[woStInPos];
          inc(woStInPos, 1);
          inc(byStTempPos, 1);
          inc(stTemp[0], 1)
        end
      else
        begin
          fillchar(stTemp[byStTempPos], ord(stIn[succ(woStInPos)]),
                   stIn[(woStInPos + 2)]);
          inc(byStTempPos, ord(stIn[succ(woStInPos)]));
          inc(stTemp[0], ord(stIn[succ(woStInPos)]));
          inc(woStInPos, 3)
        end
    until (woStInPos > byStInSize);
    fustRLEexp := stTemp
  end;


                   (* 8 bit into 7 bit string compression.                  *)
  function fustComp87(stIn : string) : string;
  var
    stTemp : string;
    byLoop, byTempSize, byOffset : byte;
  begin
    if (stIn[0] < #255) then
      stIn[succ(ord(stIn[0]))] := #0;
    fillchar(stTemp, sizeof(stTemp), 0);
    byTempSize := ord(stIn[0]) shr 3;
    if ((ord(stIn[0]) mod 8) <> 0) then
      inc(byTempsize, 1);
    byOffset := 0;
    for byLoop := 1 to byTempSize do
      begin
        stTemp[(byOffset * 7) + 1] :=
          chr( ( (ord(stIn[(byOffset * 8) + 1]) and $7F) shl 1) +
               ( (ord(stIn[(byOffset * 8) + 2]) and $40) shr 6) );
        stTemp[(byOffset * 7) + 2] :=
          chr( ( (ord(stIn[(byOffset * 8) + 2]) and $3F) shl 2) +
               ( (ord(stIn[(byOffset * 8) + 3]) and $60) shr 5) );
        stTemp[(byOffset * 7) + 3] :=
          chr( ( (ord(stIn[(byOffset * 8) + 3]) and $1F) shl 3) +
               ( (ord(stIn[(byOffset * 8) + 4]) and $70) shr 4) );
        stTemp[(byOffset * 7) + 4] :=
          chr( ( (ord(stIn[(byOffset * 8) + 4]) and $0F) shl 4) +
               ( (ord(stIn[(byOffset * 8) + 5]) and $78) shr 3) );
        stTemp[(byOffset * 7) + 5] :=
          chr( ( (ord(stIn[(byOffset * 8) + 5]) and $07) shl 5) +
               ( (ord(stIn[(byOffset * 8) + 6]) and $7C) shr 2) );
        stTemp[(byOffset * 7) + 6] :=
          chr( ( (ord(stIn[(byOffset * 8) + 6]) and $03) shl 6) +
               ( (ord(stIn[(byOffset * 8) + 7]) and $7E) shr 1) );
        if (byOffset < 31) then
          stTemp[(byOffset * 7) + 7] :=
            chr( ( ( ord(stIn[(byOffset * 8) + 7]) and $01) shl 7) +
                 ( ord(stIn[(byOffset * 8) + 8]) and $7F) )
        else
          stTemp[(byOffset * 7) + 7] :=
            chr( ( ord(stIn[(byOffset * 8) + 7]) and $01) shl 7);
        inc(byOffset, 1)
      end;
    stTemp[0] := chr(((ord(stIn[0]) div 8) * 7) + (ord(stIn[0]) mod 8) );
    fustComp87 := stTemp
  end;


                   (* 7 bit into 8 bit string expansion.                    *)
  function fustExp78(stIn : string) : string;
  var
    stTemp : string;
    byOffset, byTempSize, byLoop : byte;
  begin
    fillchar(stTemp, sizeof(stTemp), 0);
    byTempSize := ord(stIn[0]) div 7;
    if ((ord(stIn[0]) mod 7) <> 0)then
      inc(byTempSize, 1);
    byOffset := 0;
    for byLoop := 1 to byTempSize do
      begin
        stTemp[(byOffset * 8) + 1] :=
          chr( ord(stIn[(byOffset * 7) + 1]) shr 1);
        stTemp[(byOffset * 8) + 2] :=
          chr( ( ( ord(stIn[(byOffset * 7) + 1]) and  $01) shl 6) +
               ( ( ord(stIn[(byOffset * 7) + 2]) and $FC) shr 2) );
        stTemp[(byOffset * 8) + 3] :=
          chr( ( ( ord(stIn[(byOffset * 7) + 2]) and $03) shl 5) +
               ( ord(stIn[(byOffset * 7) + 3]) shr 3) );
        stTemp[(byOffset * 8) + 4] :=
          chr( ( ( ord(stIn[(byOffset * 7) + 3]) and $07) shl 4) +
               ( ord(stIn[(byOffset * 7) + 4]) shr 4) );
        stTemp[(byOffset * 8) + 5] :=
          chr( ( ( ord(stIn[(byOffset * 7) + 4]) and $0F) shl 3) +
               ( ord(stIn[(byOffset * 7) + 5]) shr 5) );
        stTemp[(byOffset * 8) + 6] :=
          chr( ( ( ord(stIn[(byOffset * 7) + 5]) and $1F) shl 2) +
               ( ord(stIn[(byOffset * 7) + 6]) shr 6) );
        stTemp[(byOffset * 8) + 7] :=
          chr( ( ( ord(stIn[(byOffset * 7) + 6]) and $3F) shl 1) +
               ( ord(stIn[(byOffset * 7) + 7]) shr 7) );
        if (byOffset < 31) then
          stTemp[(byOffset * 8) + 8] :=
            chr( (ord(stIn[(byOffset * 7) + 7]) and $7F) );
        inc(byOffset, 1)
      end;
    stTemp[0] :=
      chr( ( (ord(stIn[0]) div 7) * 8) + (ord(stIn[0]) mod 7) );
    if (stTemp[ord(stTemp[0])] = #0) then
      dec(stTemp[0], 1);
    fustExp78 := stTemp
  end;


var
  loStart, loStop : longint;

  stMy1,
  stMy2,
  stMy3 : string;

                   (* Main program execution block.                         *)
BEGIN

                   (* Test string 1.                                        *)
  stMy1 := '12345678901111111111123456789022222222221234567890' +
           '33333333331234567890444444444412345678905555555555' +
           '12345678906666666666123456789077777777771234567890' +
           '88888888881234567890999999999912345678900000000000' +
           '1234567890AAAAAAAAAA1234567890BBBBBBBBBB1234567890' +
           'CCCCC';

                   (* Test string 2.                                        *)
{ stMy1 := '12345678901234567890123456789012345678901234567890' +
           '12345678901234567890123456789012345678901234567890' +
           '12345678901234567890123456789012345678901234567890' +
           '12345678901234567890123456789012345678901234567890' +
           '12345678901234567890123456789012345678901234567890' +
           '12345'; }

                   (* Test string 3.                                        *)
{ stMy1 := '11111111111111111111111111111111111111111111111111' +
           '11111111111111111111111111111111111111111111111111' +
           '11111111111111111111111111111111111111111111111111' +
           '11111111111111111111111111111111111111111111111111' +
           '11111111111111111111111111111111111111111111111111' +
           '11111'; }

  loStart := ReadTimer;
  stMy2 := fustComp87(fustRLEcomp(stMy1));
  loStop := ReadTimer;
  writeln(' Time to compress = ', ElapsedTimeString(loStart, loStop), ' ms');
  loStart := ReadTimer;
  stMy3 := fustRLEexp(fustExp78(stMy2));
  loStop := ReadTimer;
  writeln(' Time to expand   = ', ElapsedTimeString(loStart, loStop), ' ms');
  writeln;
  writeln(stMy1);
  writeln;
  writeln(stMy2);
  writeln;
  writeln(stMy3);
  writeln;
  if (stMy1 <> stMy3) then
    writeln(' Conversion Error')
  else
    writeln(' Conversion Match')
END.


