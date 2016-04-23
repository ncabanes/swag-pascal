unit TrimStr;
{$B-}
{
     File: TrimStr
   Author: Bob Swart [100434,2072]
  Purpose: routines for removing leading/trailing spaces from strings,
           and to take parts of left/right of string (a la Basic).
  Version: 2.0

  LTrim()    - Remove all spaces from the left side of a string
  RTrim()    - Remove all spaces from the right side of a string
  Trim()     - Remove all extraneous spaces from a string
  RightStr() - Take a certain portion of the right side of a string
  LeftStr()  - Take a certain portion of the left side of a string
  MidStr()   - Take the middle portion of a string

}
interface
Const
  Space = #$20;

  function LTrim(Const Str: String): String;
  function RTrim(Str: String): String;
  function Trim(Str: String):  String;
  function RightStr(Const Str: String; Size: Word): String;
  function LeftStr(Const Str: String; Size: Word): String;
  function MidStr(Const Str: String; Size: Word): String;

implementation

  function LTrim(Const Str: String): String;
  var len: Byte absolute Str;
      i: Integer;
  begin
    i := 1;
    while (i <= len) and (Str[i] = Space) do Inc(i);
    LTrim := Copy(Str,i,len)
  end {LTrim};

  function RTrim(Str: String): String;
  var len: Byte absolute Str;
  begin
    while (Str[len] = Space) do Dec(len);
    RTrim := Str
  end {RTrim};

  function Trim(Str: String): String;
  begin
    Trim := LTrim(RTrim(Str))
  end {Trim};

  function RightStr(Const Str: String; Size: Word): String;
  var len: Byte absolute Str;
  begin
    if Size > len then Size := len;
    RightStr := Copy(Str,len-Size+1,Size)
  end {RightStr};

  function LeftStr(Const Str: String; Size: Word): String;
  begin
    LeftStr := Copy(Str,1,Size)
  end {LeftStr};

  function MidStr(Const Str: String; Size: Word): String;
  var len: Byte absolute Str;
  begin
    if Size > len then Size := len;
    MidStr := Copy(Str,((len - Size) div 2)+1,Size)
  end {MidStr};
end.
