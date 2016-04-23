UNIT Strings;

INTERFACE

USES
   CRT,         {Import TextColor,TextBackGround}
   DOS;         {Import FSplit,PathStr,NameStr,ExtStr,DirStr}

TYPE
   TDir = (L,R);


FUNCTION  Str2Int(Str: String; (* Converts String to Integer *)
                  VAR Code: Integer): Integer;
FUNCTION  Int2Str(I: Integer): String; (* Converts Integer to String *)
FUNCTION  StripSlash(Str: String): String; (* String trailing '\' *)
FUNCTION  AddSlash(Str: String): String; (* Add trailing '\' *)
FUNCTION  PadStr(Str: String; (* Pad String with characters *)
                 Ch: Char; (* Character to pad with *)
                 Num: Byte; (* Number of places to pad to *)
                 Dir: TDir): String; (* Direction to pad in *)
FUNCTION  UpCaseStr(Str: String): String; (* Convert string to uppercase *)
FUNCTION  LowCaseStr(Str: String): String; (* Convert string to lowercase *)
FUNCTION  NameForm(Str: String): String; (* Convert string to Name format *)
FUNCTION  StripExt(Str: String): String; (* Strip Extension from filename *)
FUNCTION  AddExt(Str,Ext: String): String; (* Add Extension to filename *)
FUNCTION  ExtractFName(Str: String): String; (* Extract Filename *)
FUNCTION  ExtractFExt(Str: String): String; (* Extract file extension *)
PROCEDURE Pipe(Str: String); (* Write string allowing for pipe codes *)


IMPLEMENTATION


FUNCTION  Str2Int(Str: String;
                  VAR Code: Integer): Integer;
VAR I: Integer;

BEGIN
   VAL(Str,I,Code);
   Str2Int := I;
END;


FUNCTION  Int2Str(I: Integer): String;
VAR S: String;

BEGIN
   STR(I,S);
   Int2Str := S;
END;


FUNCTION  StripSlash(Str: String): String;

BEGIN
   IF Str[Length(Str)] = '\' THEN
    StripSlash := COPY(Str,1,Length(Str)-1);
END;


FUNCTION  AddSlash(Str: String): String;

BEGIN
   IF Str[Length(Str)] <> '\' THEN
    AddSlash := Str + '\';
END;


FUNCTION  PadStr(Str: String;
                 Ch: Char;
                 Num: Byte;
                 Dir: TDir): String;
VAR
   TempStr: String;
   B: Byte;

BEGIN
   TempStr := '';
   IF Length(Str) < Num THEN
    BEGIN
       FOR B := Length(Str) TO Num DO TempStr := TempStr + Ch;
       CASE Dir OF
          L: PadStr := TempStr + Str;
          R: PadStr := Str + TempStr;
       END;
    END
   ELSE
    BEGIN
       FOR B := 1 TO Num DO TempStr := TempStr + Str[B];
       PadStr := TempStr;
    END;
END;


FUNCTION  UpCaseStr(Str: String): String;
VAR
   TempStr: String;
   B: Byte;

BEGIN
   TempStr := Str;
   FOR B := 1 TO Length(Str) DO TempStr[B] := UpCase(TempStr[B]);
   UpCaseStr := TempStr;
END;


FUNCTION  LowCaseStr(Str: String): String;
VAR
   TempStr: String;
   B: Byte;

BEGIN
   TempStr := Str;
   FOR B := 1 TO Length(Str) DO IF TempStr[B] IN ['A'..'Z'] THEN
    TempStr[B] := CHR(ORD(TempStr[B])+32);
   LowCaseStr := TempStr;
END;


FUNCTION  NameForm(Str: String): String;
VAR
   TempStr: String;
   Pos: Byte;

BEGIN
   TempStr := Str;
   TempStr[1] := UpCase(TempStr[1]);
   FOR Pos := 2 TO Length(TempStr) DO
    IF TempStr[Pos] = #32 THEN
     TempStr[Pos+1] := UpCase(TempStr[Pos+1])
    ELSE
     IF TempStr[Pos] IN ['A'..'Z'] THEN
      TempStr[Pos] := CHR(ORD(TempStr[Pos])+32);
   NameForm := TempStr;
END;


FUNCTION  StripExt(Str: String): String;
VAR DotPos: Byte;

BEGIN
   DotPos := POS('.',Str);
   IF DotPos > 1 THEN StripExt := COPY(Str,1,DotPos-1)
   ELSE StripExt := Str;
END;


FUNCTION  AddExt(Str,Ext: String): String;
VAR DotPos: Byte;

BEGIN
   DotPos := POS('.',Str);
   IF (DotPos > 1) AND (DotPos < 10) THEN AddExt := COPY(Str,1,DotPos) + Ext
   ELSE IF DotPos = 0 THEN AddExt := Str + '.' + Ext;
END;


FUNCTION  ExtractFName(Str: String): String;
VAR
   Path: PathStr;
   Dir: DirStr;
   Name: NameStr;
   Ext: ExtStr;

BEGIN
   Path := Str;
   FSplit(Path,Dir,Name,Ext);
   ExtractFName := Name+Ext;
END;


FUNCTION  ExtractFExt(Str: String): String;
VAR
   Path: PathStr;
   Dir: DirStr;
   Name: NameStr;
   Ext: ExtStr;

BEGIN
   Path := Str;
   FSplit(Path,Dir,Name,Ext);
   ExtractFExt := Ext;
END;


PROCEDURE Pipe(Str: String);
VAR
   StrPos, Err: Integer;
   Col: Byte;

BEGIN
   StrPos := 1;
   IF Length(Str) < 1 THEN Exit;
   REPEAT
      IF (Str[StrPos] = '|') THEN
       BEGIN
          Val(Copy(Str,StrPos+1,2),Col,Err);
          IF (Err = 0) AND (Col IN [0..23]) THEN
             IF Col IN [0..15] THEN TextColor(Col)
             ELSE TextBackGround(Col-16);
          Inc(StrPos,3);
       END
      ELSE
       BEGIN
          Write(Str[StrPos]);
          Inc(StrPos);
       END;
   UNTIL (StrPos > Length(Str));
END;


BEGIN
END.
