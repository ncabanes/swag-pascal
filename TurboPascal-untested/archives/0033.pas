{
  Copyright (c) 1994-95 by Piotr Warezak and Rafal Wierzbicki, Lodz, Poland

  function check_if_packed(var f:file);
       function checks if the assigned and opened file is compressed
       with WWPACK.

       Function returns byte:

            WWPACK version (when packed) and compression command:
                       3.00     3.01    3.02    3.03    3.04
                PR        9        9      14      17      21
                P        10       12      15      18      22
                PU       11       13      16      19      23
                PP      n/a      n/a     n/a      20      24

            or:
                0  -  not packed with WWPACK
                1  -  not an EXE file
                2  -  unrecognized WWPACK version
                3  -  error while reading the file
}

FUNCTION check_if_packed(var f:FILE):BYTE;
var start,size,old_position:LONGINT;
    header:ARRAY [1..16]OF word;
    buf:ARRAY [1..75] OF BYTE;
    ver:word;
BEGIN
  {$I-}
  ver:=0;

  {***  store old FilePosition  ***}
  old_position:=FilePos(f);
  Seek(f,0); size:=FileSize(f);
  IF IOResult<>0 THEN
    BEGIN
      check_if_packed:=3; Seek(f,old_position); ver:=IOResult; Exit;
    END;

  {***  check if EXE file ***}
  IF size<32 THEN
    BEGIN
      check_if_packed:=1; Seek(f,old_position); Exit;
    END;
  BlockRead(f,header,32);
  IF (header[1]<>Ord('M')+256*Ord('Z')) AND (header[1]<>Ord('Z')+256*Ord('M'))
THEN    BEGIN
      check_if_packed:=1; Seek(f,old_position); Exit;
    END;
  IF IOResult<>0 THEN
    BEGIN
      check_if_packed:=3; Seek(f,old_position); ver:=IOResult; Exit;
    END;

  {***  jump to the begin of the code (jump to CS:IP address)  ***}
  start:=LONGINT(header[12])*16+header[11]+header[5]*16;
  IF start>=65536*16 THEN dec(start,65536*16);
  IF start+74<size THEN
    BEGIN

      {***  read first 75 bytes of the code  ***}
      Seek(f,start-2); BlockRead(f,buf[1],75);
      IF IOResult<>0 THEN
        BEGIN
          check_if_packed:=3; Seek(f,old_position); ver:=IOResult; Exit;
        END;

      {***  check if WWPACK 3.00/3.01 PR code  ***}
      IF (buf[3]=$be) AND (buf[6]=$ba) AND (buf[9]=$bf) AND (buf[12]=$b9) THEN
        BEGIN
          IF buf[2]=9 THEN ver:=9
          ELSE
            BEGIN
              check_if_packed:=2;
              Seek(f,old_position);
              Exit;
            END;
        END;

      {***  check if WWPACK 3.02/3.03/3.04 PR code  ***}
      IF (buf[3]=$be) AND (buf[6]=$bf) AND (buf[9]=$b9) AND (buf[12]=$8c) AND
         (buf[13]=$cd) AND (buf[14]=$81) AND (buf[15]=$ed) AND (buf[18]=$8b)
AND         (buf[19]=$dd)
      THEN
        BEGIN
          buf[2]:=buf[2]+14; ver:=buf[2];
          IF (ver<>14) AND (ver<>17) AND (ver<>21) THEN
            BEGIN
              check_if_packed:=2; Seek(f,old_position); Exit;
            END;
        END;

      {***  check if WWPACK 3.0x P/PU/PP code  ***}
      IF (buf[3]=$b8) AND (buf[6]=$8c) AND (buf[7]=$ca) AND (buf[8]=$03) AND
         (buf[9]=$d0) AND (buf[10]=$8c) AND (buf[11]=$c9) AND (buf[12]=$81)
AND         (buf[16]=$51)
      THEN
        BEGIN
          ver:=buf[2];
          IF (ver<10) OR (ver>24) OR (ver=14) OR (ver=17) OR (ver=21) THEN
            BEGIN
              check_if_packed:=2; Seek(f,old_position); Exit;
            END;
        END;
    END;

  {***  restore old FilePosition and return WWPACK's version  ***}
  check_if_packed:=ver; Seek(f,old_position);
END;

