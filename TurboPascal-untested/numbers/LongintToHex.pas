(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0035.PAS
  Description: LongInt to HEX
  Author: GREG VIGNEAULT
  Date: 11-02-93  05:52
*)

{
GREG VIGNEAULT

> So to assign the File I will need the HEX in String format.
}

Type
  String8 = String[8];

Var
  MyStr : String8;
  ALong : LongInt;

{ convert a LongInt value to an 8-Character String, using hex digits  }
{ (using all 8 Chars will allow correct order in a sorted directory)  }

Procedure LongToHex(AnyLong : LongInt; Var HexString : String8);
Var
  ch    : Char;
  Index : Byte;
begin
  HexString := '00000000';                  { default to zero   }
  Index := Length(HexString);               { String length     }
  While AnyLong <> 0 do
  begin                                     { loop 'til done    }
    ch := Chr(48 + Byte(AnyLong) and $0F);  { 0..9 -> '0'..'9'  }
    if ch > '9' then
      Inc(ch, 7);                           { 10..15 -> 'A'..'F'}
    HexString[Index] := ch;                 { insert Char       }
    Dec(Index);                             { adjust chr Index  }
    AnyLong := AnyLong SHR 4;               { For next nibble   }
  end;
end;

begin
  ALong := $12345678;                       { a LongInt value   }
  LongToHex(ALong, MyStr);                  { convert to hex str}
  WriteLn;
  WriteLn('$', MyStr);                      { display the String}
  WriteLn;
end.

