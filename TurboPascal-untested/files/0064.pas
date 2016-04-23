
Uses Crt,Dos,Strings;

VAR
    filename : pChar;
    fname    : String;

  { test to see if file exists }
  function FileExists(FileName:pchar):boolean;
  inline(
    $5A/
    $58/
    $1E/
    $8E/$D8/
    $B8/$00/$43/
    $CD/$21/
    $1F/
    $72/$08/
    $B8/$01/$00/
    $F6/$C1/$10/
    $74/$02/
    $31/$C0);

BEGIN
  fname := Paramstr(1);
  WriteLn(FileExists(strPCopy(Filename,fname)));
END.
