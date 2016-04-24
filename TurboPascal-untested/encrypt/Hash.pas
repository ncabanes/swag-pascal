(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0009.PAS
  Description: HASH.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:40
*)

Unit Hash;

{***************************************************************************
 *                                                                         *
 *                     Copyright 1989 Trevor J Carlsen                     *
 *                           All rights reserved                           *
 *                   Rovert Software Consulting Services                   *
 *                                PO Box 568                               *
 *                   Port Hedland Western Australia 6721                   *
 *                 Telephone  (091) 732026 or (091) 732569                 *
 *                                                                         *
 ***************************************************************************}

Interface

Uses Strings,
     sundry;

Function hashcode(st : String; Var nwd : Word): Word;

Implementation

Function MakeCodeStr(key : LongInt; st : String): String;
  Var
    x   : Word;
    len : Byte Absolute st;
  begin
    RandSeed := (key * len) div ord(st[len]);
    MakeCodeStr[0] := st[0];
    For x := 1 to len do
      MakeCodeStr[x] := chr(Random(255));
  end;

Function Key(st: String): LongInt;
  Var
    len    : Byte Absolute st;
    x,y    : Byte;
    temp   : LongInt;
    tempst : Array[0..3] of Byte;

  Procedure makekey(Var k; Var s : LongInt);
    Var t : LongInt Absolute k;
      rec : Record
              Case Byte of
               1 :(b : LongInt; c : Word);
               2 :(d : Word ; e : LongInt);
               3 :(r : Real);
              end;
    begin
      RandSeed := t;
      rec.r := random;
      s := s xor rec.b xor rec.e;
    end;

  begin
    temp := 0;
    For x := 1 to len-3 do begin
      For y := 0 to 3 do
        tempst[y] := Byte(st[x + y]);
      makekey(tempst,temp);
    end;
    Key := temp;
  end;

Function EncryptStr(key : LongInt; st : String): String;
  Var
    len          : Byte Absolute st;
    cnt,x        : Byte;
    temp,CodeStr : String;
  begin
    CodeStr := MakeCodeStr(key,st);
    temp[0] := st[0];
    temp[len] := st[len];
    For x := 1 to len-1 do begin
      cnt := ord(st[x]) xor ord(CodeStr[x]);
      temp[x] := chr(cnt);
      end;
    cnt := ord(st[len]) xor len;
    temp[len] := chr(cnt);
    EncryptStr := temp;
  end;

Function hashcode(st : String; Var nwd : Word): Word;
  Var k   : LongInt;
      len : Byte Absolute st;
      s   : String;
  begin
    k := key(st) * nwd;
    st := StUpCase(st);
    s := CompressStr(st);
    move(s[1],nwd,2);
    if len < 4 then st := st + '!@#$';
    {-Force String to a minimum length}
    st := EncryptStr(k,st);
    st := EncryptStr(Key(st),st);
    hashcode := key(st) shr 16;
  end;  {hash}

end.


{
> Procedure Hash(p : Pointer; numb : Byte; Var result: LongInt);

> ... Is this the way that you were referring to storing passWords?
> if so could further explain the usage of this Procedure? Thanx!!

Yes, but I take issue With the Word "store".  Storing the passWord hash is not
storing the passWord as the passWord cannot be determined by examining the hash
- even if the hash algorithm is known.

to use the Procedure -

When the passWord is first created, calculate its hash and store that value
somewhere - either in a File or in the exe.

then when the passWord is used just -

  Hash(@passWord,length(passWord),EnteredHash);
  if PwdHash = EnteredHash then PassWord_Entered_is_Correct.
}
