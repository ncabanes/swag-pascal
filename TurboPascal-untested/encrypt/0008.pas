Unit endecode;
 { Simple encryption/decryption routines.                  }

Interface

Type
  stArray = Array[0..255] of Byte;

Function Key(Var s): LongInt;
Function EncryptStr(key : LongInt; s: String): String;
Function DecryptStr(key : LongInt; s: String): String;

Implementation

Function MakeCodeStr(key : LongInt; Var s): String;
  {--------------------------------------------------------}
  { Creates a "randomly" Constructed String of a similar   }
  { length as the String which is to be encrypted. A       }
  { LongInt key is used to permit "passWord" Type          }
  { encryption. This key may be passed as a literal or     }
  { some passWord used to calculate it. Using this key,    }
  { the last Character of the String to be encrypted and   }
  { the length of the String, a "code String" is produced. }
  { This code String is then xord With the original String }
  { to produce the encrypted String. The last Character    }
  { however must be treated differently so that it can be  }
  { easily decoded in order to reproduce the coded String  }
  { used For decoding. This is done by xoring it With the  }
  { length of the String. to decrypt a String the last     }
  { Character must be decoded first and then the key coded }
  { String produced in order to decrypt each Character.    }
  {--------------------------------------------------------}

  Var
    x   : Word;
    len : Byte Absolute s;
    st  : Array[0..255] of Byte Absolute s;

  begin
    RandSeed := (key * len) div st[len];
    {This ensures that no two code Strings will be similar UNLESS they are
     of identical length, have identical last Characters and the same
     key is used.}
    MakeCodeStr[0] := chr(len);
    For x := 1 to len do
      MakeCodeStr[x] := chr(32 + Random(95));
      {Keeping the Character between 32 and 127 ensures that the high bit
       is never set on the original encrypted Character and thereFore allows
       this to be used as flag to indicate that the coded Char was < #32.
       This will then permit the encrypted String to be printed without fear
       of having embedded control codes play havoc With the Printer.}
  end;

Function Key(Var s): LongInt;
  { Creates a key For seeding the random number generator. st can be a
    passWord }
  Var
    x     : Byte;
    temp  : LongInt;
    c     : Array[1..64] of LongInt Absolute s;
    len   : Byte Absolute s;
  begin
    temp  := 0;
    For x := 1 to len div 4 do
      temp := temp xor c[x];
    Key := Abs(temp);
  end;

Function EncryptStr(key : LongInt; s: String): String;
  Var
    cnt,x          : Byte;
    len            : Byte Absolute s;
    st             : Array[0..255] of Byte Absolute s;
    CodeStr        : stArray;
    temp           : String Absolute CodeStr;
  begin
    temp           := MakeCodeStr(key,st);
    EncryptStr[0]  := chr(len);
    EncryptStr[len]:= chr(st[len]);
    For x := 1 to len-1 do begin
      cnt := st[x] xor CodeStr[x];
      inc(cnt,128 * ord(cnt < 32));
      EncryptStr[x]:= chr(cnt);
    end;  { For }
    cnt := st[len] xor (len and 127);
    inc(cnt,128 * ord(cnt < 32));
    EncryptStr[len]:= chr(cnt);
  end;

Function DecryptStr(key : LongInt; s: String): String;
  Var
    cnt,x        : Byte;
    st           : stArray Absolute s;
    len          : Byte Absolute s;
    CodeStr      : stArray;
    temp         : String Absolute CodeStr;
    ch           : Char;
  begin
    cnt          := st[len] and 127;
    st[len]      := cnt xor len;
    temp         := MakeCodeStr(key,st);
    DecryptStr[0]:= chr(len);
    DecryptStr[len]:= chr(st[len]);
    For x := 1 to len-1 do begin
      cnt        := st[x];
      dec(cnt,128 * ord(st[x] > 127));
      DecryptStr[x] := chr(cnt xor CodeStr[x]);
    end;  { For }
  end;

end.
