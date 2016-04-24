(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0070.PAS
  Description: High Precision BCD Math
  Author: SWAG SUPPORT TEAM
  Date: 08-24-94  13:17
*)

unit AJCBCD;

interface

uses Objects, Strings;

const
  DigitSize = SizeOf(Byte);
  bpw_Fixed = 0;
  bpw_Variable = 1;
  bpz_Blank = True;
  bpz_NotBlank = False;
  MaxBCDSize = 100;
  st_Blanks25 = '                         ';
  st_Blanks = st_Blanks25
            + st_Blanks25
            + st_Blanks25
            + st_Blanks25
            + st_Blanks25
            + st_Blanks25
            + st_Blanks25
            + st_Blanks25
            + st_Blanks25
            + st_Blanks25
            + st_Blanks25;

type
  PBCDArray = ^TBCDArray;
  TBCDArray = array[1..MaxBCDSize] of byte;

  TBCDSign = (BCDNegative, BCDPositive);

  PBCD = ^TBCD;
  TBCD = object(TObject)
    BCDSize:  Integer;
    Sign:  TBCDSign;
    Value:  PBCDArray;
    Precision: Byte;
    constructor InitBCD(AVal: PBCD);
    constructor InitReal(AVal: Real; APrec: Byte; ASize: Integer);
    constructor InitPChar(AVal: PChar; APrec: Byte; ASize: Integer);
    destructor Done; virtual;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    function GetValue: PBCDArray;
    function GetSign: TBCDSign;
    function GetPrecision: Byte;
    function GetBCDSize: Integer;
    procedure SetValueBCD(AVal: PBCD);
    procedure SetValueReal(AVal: Real);
    procedure SetValuePChar(AVal: PChar);
    procedure SetSign(ASign: TBCDSign);
    procedure SetPrecision(APrec: Byte);
    procedure SetBCDSize(ASize: Integer);
    procedure AddBCD(AVal: PBCD);
    procedure AddReal(AVal: Real);
    procedure AddPChar(AVal: PChar);
    procedure SubtractBCD(AVal: PBCD);
    procedure SubtractReal(AVal: Real);
    procedure SubtractPChar(AVal: PChar);
    procedure MultiplyByBCD(AVal: PBCD);
    procedure MultiplyByReal(AVal: Real; APrec: Byte);
    procedure MultiplyByPChar(AVal: PChar; APrec: Byte);
    procedure DivideByBCD(AVal: PBCD);
    procedure DivideByReal(AVal: Real; APrec: Byte);
    procedure DivideByPChar(AVal: PChar; APrec: Byte);
    procedure AbsoluteValue;
    procedure Increment;
    procedure Decrement;
    procedure ShiftLeft(ShiftAmount: Byte);
    procedure ShiftRight(ShiftAmount: Byte);
    function BCD2Int: LongInt;
    function BCD2Real: Real;
    function PicStr(picture: string;
                    Width: Integer; BlankWhenZero: Boolean): String;
    function StrPic(dest: PChar; picture: string;
                    Width: Integer; BlankWhenZero: Boolean;
                    Size: Integer): PChar;
    function CompareBCD(AVal: PBCD): Integer;
    function CompareReal(AVal: Real): Integer;
    function ComparePChar(AVal: PChar): Integer;
  end;

const

  RBCD:  TStreamRec = (ObjType:  60000;
                       VmtLink:  Ofs(TypeOf(TBCD)^);
                       Load:     @TBCD.Load;
                       Store:    @TBCD.Store);

var
  BCDZero:  PBCD;

implementation

{BCDAdd is a subroutine that adds the value in BCD2 to the value in   }
{BCD1.  It is a simple magnitude addition, as if the two numbers have }
{the same sign.  BCDAdd makes the following assumptions:              }
{  1) the calling routine will manage the proper sign of the result   }
{     of the addition.                                                }
{  2) the BCDSize of the two operands are equal                       }
{  3) the Precision of the two operands are equal                     }
procedure BCDAdd(BCD1, BCD2: PBCD);
var
  i:  integer;
  Carry:  Byte;
begin
  Carry := 0;
  for i := BCD1^.BCDSize downto 1 do
    begin
      BCD1^.Value^[i] := BCD1^.Value^[i] + BCD2^.Value^[i] + Carry;
      if BCD1^.Value^[i] > 9 then
        begin
          dec(BCD1^.Value^[i], 10);
          Carry := 1;
        end
      else
        Carry := 0;
    end;
end;

{BCDSubtraction is a subroutine that subtracts the value in BCD2 from  }
{the value in BCD1.  It is a simple magnitude subtraction, without     }
{regard to the sign of the operands.  BCDSubtract makes the following  }
{assumptions:                                                          }
{  1) the calling routine will manage the proper sign of the result    }
{     of the subtraction.                                              }
{  2) the BCDSize of the two operands are equal                        }
{  3) the Precision of the two operands are equal                      }
{  4) the magnitude of the value in BCD2 is less than or equal to the  }
{     magnitude of the value in BCD1 so that the routine can perform   }
{     a simple byte by byte subtraction                                }
procedure BCDSubtract(BCD1, BCD2: PBCD);
var
  i:  integer;
  Borrow:  Byte;
begin
  Borrow := 0;
  for i := BCD1^.GetBCDSize downto 1 do
    begin
      BCD1^.Value^[i] := BCD1^.Value^[i] + 10 - BCD2^.Value^[i] - Borrow;
      if BCD1^.Value^[i] >  9 then
        begin
          dec(BCD1^.Value^[i], 10);
          Borrow := 0;
        end
      else
        Borrow := 1;
    end;
end;

constructor TBCD.InitBCD(AVal: PBCD);
begin
  inherited Init;
  BCDSize := AVal^.GetBCDSize;
  GetMem(Value, BCDSize*DigitSize);
  Precision := AVal^.GetPrecision;
  SetValueBCD(AVal);
end;

constructor TBCD.InitReal(AVal: Real; APrec: Byte; ASize: Integer);
begin
  inherited Init;
  if ASize > MaxBCDSize then
    BCDSize := MaxBCDSize
  else
    BCDSize := ASize;
  GetMem(Value, ASize*DigitSize);
  Precision := APrec;
  SetValueReal(AVal);
end;

constructor TBCD.InitPChar(AVal: PChar; APrec: Byte; ASize: Integer);
begin
  inherited Init;
  if ASize > MaxBCDSize then
    BCDSize := MaxBCDSize
  else
    BCDSize := ASize;
  GetMem(Value, ASize*DigitSize);
  Precision := APrec;
  SetValuePChar(AVal);
end;

destructor TBCD.Done;
begin
  FreeMem(Value, BCDSize*DigitSize);
  inherited Done;
end;

constructor TBCD.Load(var S: TStream);
begin
  S.Read(BCDSize, SizeOf(BCDSize));
  S.Read(Sign, SizeOf(Sign));
  GetMem(Value, BCDSize*DigitSize);
  S.Read(Value^, BCDSize*DigitSize);
  S.Read(Precision, SizeOf(Precision));
end;

procedure TBCD.Store(var S: TStream);
begin
  S.Write(BCDSize, SizeOf(BCDSize));
  S.Write(Sign, SizeOf(Sign));
  S.Write(Value^, BCDSize*DigitSize);
  S.Write(Precision, SizeOf(Precision));
end;

function TBCD.GetValue: PBCDArray;
var
  WrkValue:  PBCDArray;
begin
  GetMem(WrkValue, BCDSize*DigitSize);
  Move(Value^, WrkValue^, BCDSize*DigitSize);
  GetValue := WrkValue;
end;

function TBCD.GetSign: TBCDSign;
begin
  GetSign := Sign;
end;

function TBCD.GetPrecision: Byte;
begin
  GetPrecision := Precision;
end;

function TBCD.GetBCDSize:  Integer;
begin
  GetBCDSize := BCDSize;
end;

procedure TBCD.SetValueBCD(AVal: PBCD);
var
  SaveSize:  Integer;
  SavePrecision:  Byte;
begin
  if AVal = nil then exit;

  FreeMem(Value, BCDSize*DigitSize);

  SaveSize := GetBCDSize;
  SavePrecision := GetPrecision;

  Value := AVal^.GetValue;
  BCDSize := AVal^.GetBCDSize;
  Precision := AVal^.GetPrecision;

  if Precision > SavePrecision then
    begin
      SetBCDSize(SaveSize);
      SetPrecision(SavePrecision);
    end
  else
    begin
      SetPrecision(SavePrecision);
      SetBCDSize(SaveSize);
    end;

    SetSign(AVal^.GetSign);
end;

procedure TBCD.SetSign(ASign: TBCDSign);
var
  i:  integer;
begin
  Sign := BCDPositive;
  if ASign = BCDPositive then exit;

  {allow negative sign only if value is non-zero}
  for i := GetBCDSize downto 1 do
    if Value^[i] <> 0 then
      begin
        Sign := BCDNegative;
        exit;
      end;
end;

procedure TBCD.SetValueReal(AVal: Real);
var
  i, BCDIndex:  integer;
  ValStr: String;
begin
  FillChar(Value^, BCDSize*DigitSize, #0);

  Str(abs(AVal):BCDSize:Precision, ValStr);
  BCDIndex := BCDSize;
  for i :=length(ValStr) downto 1 do
    if ValStr[i] in ['0'..'9'] then
      begin
        Value^[BCDIndex] := ord(ValStr[i]) - ord('0');
        dec(BCDIndex);
      end;

  if AVal < 0.0 then
    SetSign(BCDNegative)
  else
    SetSign(BCDPositive);
end;

procedure TBCD.SetValuePChar(AVal: PChar);
var
  i, BCDIndex:  integer;
  SavePrec: Byte;
  SaveSign: TBCDSign;
begin
  if AVal = nil then exit;

  SaveSign := BCDPositive;
  SavePrec := Precision;
  Precision := 0;

  FillChar(Value^, BCDSize*DigitSize, #0);

  if StrLen(AVal) = 0 then exit;

  BCDIndex := BCDSize;
  for i := StrLen(AVal) downto 0 do
    case AVal[i] of
      '0'..'9':     begin
                      Value^[BCDIndex] := ord(AVal[i]) - ord('0');
                      dec(BCDIndex);
                    end;
      '(',')','-':  begin
                      SaveSign := BCDNegative;
                    end;
      '.':          begin
                      Precision := BCDSize - BCDIndex;
                    end;
    end;  {case}

  SetPrecision(SavePrec);
  SetSign(SaveSign);
end;

procedure TBCD.SetPrecision(APrec: Byte);
begin
  if APrec = Precision then exit;
  if APrec < Precision then
    ShiftRight(Precision - APrec)
  else
    ShiftLeft(APrec - Precision);
  Precision := APrec;
end;

procedure TBCD.SetBCDSize(ASize: Integer);
var
  SaveSize:  Integer;
  WrkVal:  PBCDArray;
begin
  if ASize = GetBCDSize then exit;

  if ASize > MaxBCDSize then ASize := MaxBCDSize;

  GetMem(WrkVal, ASize*DigitSize);
  FillChar(WrkVal^, ASize*DigitSize, #0);

  if ASize < GetBCDSize then
    Move(Value^[(GetBCDSize-ASize)+1], WrkVal^, ASize*DigitSize)
  else if ASize > GetBCDSize then
    Move(Value^, WrkVal^[(ASize-GetBCDSize)+1], GetBCDSize);

  FreeMem(Value, GetBCDSize*DigitSize);
  Value := WrkVal;
  BCDSize := ASize;
end;

procedure TBCD.AddBCD(AVal: PBCD);
var
  WrkValue:  PBCD;
begin
  WrkValue := new(PBCD, InitBCD(AVal));
  WrkValue^.SetPrecision(Precision);
  WrkValue^.SetBCDSize(BCDSize);
  if GetSign <> AVal^.GetSign then
    if AVal^.GetSign = BCDNegative then
      begin
        WrkValue^.AbsoluteValue;
        BCDSubtract(@Self, WrkValue);
        Dispose(WrkValue, Done);
        exit;
      end
    else
      {AVal^.GetSign = BCDPositive}
      begin
        AbsoluteValue;
        BCDSubtract(WrkValue, @Self);
        SetValueBCD(WrkValue);
        Dispose(WrkValue, Done);
        exit;
      end;

  BCDAdd(@Self, WrkValue);
  Dispose(WrkValue, Done);
end;

procedure TBCD.AddReal(AVal: Real);
var
  WrkValue: PBCD;
begin
  WrkValue := new(PBCD, InitReal(AVal, GetPrecision, GetBCDSize));
  AddBCD(WrkValue);
  Dispose(WrkValue, Done);
end;

procedure TBCD.AddPChar(AVal: PChar);
var
   WrkValue: PBCD;
begin
  WrkValue := new(PBCD, InitPChar(AVal, GetPrecision, GetBCDSize));
  AddBCD(WrkValue);
  Dispose(WrkValue, Done);
end;

procedure TBCD.SubtractBCD(AVal: PBCD);
var
  WrkValue:  PBCD;
  SaveSign:  TBCDSign;
begin
  if AVal = nil then exit;

  WrkValue := new(PBCD, InitBCD(AVal));
  WrkValue^.SetPrecision(GetPrecision);
  WrkValue^.SetBCDSize(GetBCDSize);
  if GetSign <> AVal^.GetSign then
    begin
      WrkValue^.SetSign(Sign);
      BCDAdd(@Self, WrkValue);
      Dispose(WrkValue, Done);
      exit;
    end;

  SaveSign := Sign;
  AbsoluteValue;
  WrkValue^.AbsoluteValue;
  if CompareBCD(WrkValue) < 0 then
    begin
      BCDSubtract(WrkValue, @Self);
      SetValueBCD(WrkValue);
      if SaveSign = BCDNegative then
        SetSign(BCDPositive)
      else
        SetSign(BCDNegative);
    end
  else
    begin
      BCDSubtract(@Self, WrkValue);
      SetSign(SaveSign);
    end;

  Dispose(WrkValue, Done);
end;

procedure TBCD.SubtractReal(AVal: Real);
var
  WrkValue: PBCD;
begin
  WrkValue := new(PBCD, InitReal(AVal, GetPrecision, GetBCDSize));
  SubtractBCD(WrkValue);
  Dispose(WrkValue, Done);
end;

procedure TBCD.SubtractPChar(AVal: PChar);
var
  WrkValue: PBCD;
begin
  WrkValue := new(PBCD, InitPChar(AVal, GetPrecision, GetBCDSize));
  SubtractBCD(WrkValue);
  Dispose(WrkValue, Done);
end;

procedure TBCD.MultiplyByBCD(AVal: PBCD);
var
  NewSign:  TBCDSign;
  WrkValue:  PBCD;
  HighDigit, i, j:  integer;
  SavePrec:  Byte;
begin
  if AVal = nil then exit;

  if GetSign = AVal^.GetSign then
    NewSign := BCDPositive
  else
    NewSign := BCDNegative;
  AbsoluteValue;

  SavePrec := Precision;
  WrkValue := new(PBCD, InitReal(0, 0, GetBCDSize + AVal^.GetBCDSize));
  Precision := 0;
  i := 1;
  while (i < AVal^.GetBCDSize) and (AVal^.Value^[i] = 0) do
    inc(i);
  HighDigit := i;

  for i := AVal^.GetBCDSize downto HighDigit do
    begin
      if AVal^.Value^[i] <> 0 then
        for j := 1 to AVal^.Value^[i] do
          WrkValue^.AddBCD(@Self);
      ShiftLeft(1);
    end;

  WrkValue^.Precision := SavePrec + AVal^.GetPrecision;
  WrkValue^.SetPrecision(SavePrec);
  Precision := SavePrec;
  SetValueBCD(WrkValue);
  SetSign(NewSign);
end;

procedure TBCD.MultiplyByReal(AVal: Real; APrec: Byte);
var
  WrkVal:  PBCD;
begin
  WrkVal := new(PBCD, InitReal(AVal, APrec, GetBCDSize));
  MultiplyByBCD(WrkVal);
  Dispose(WrkVal, Done);
end;

procedure TBCD.MultiplyByPChar(AVal: PChar; APrec: Byte);
var
  WrkVal:  PBCD;
begin
  WrkVal := new(PBCD, InitPChar(AVal, APrec, GetBCDSize));
  MultiplyByBCD(WrkVal);
  Dispose(WrkVal, Done);
end;

procedure TBCD.DivideByBCD(AVal: PBCD);
var
  NewSign:  TBCDSign;
  WrkVal, WrkDiv, WrkQuo:  PBCD;
  HighDigit, i, j, IterationCount:  integer;
  TempPrec, QuotientPrec:  Byte;
begin
  if AVal = nil then exit;

  if AVal^.CompareReal(0.0) = 0 then exit;  {avoid zero divide}

  if GetSign = AVal^.GetSign then
    NewSign := BCDPositive
  else
    NewSign := BCDNegative;

  WrkVal := new(PBCD, InitBCD(@Self));
  WrkVal^.AbsoluteValue;

  WrkQuo := new(PBCD, InitReal(0, 0, GetBCDSize));

  i := 1;
  while (i < WrkVal^.GetBCDSize) and (WrkVal^.Value^[i] = 0) do
    inc(i);
  HighDigit := i;
  WrkVal^.SetPrecision(WrkVal^.GetPrecision+(HighDigit-1));
  TempPrec := WrkVal^.GetPrecision;
  WrkVal^.Precision := 0;

  WrkDiv := new(PBCD, InitBCD(AVal));
  WrkDiv^.AbsoluteValue;
  i := 1;
  while (i < WrkDiv^.GetBCDSize) and (WrkDiv^.Value^[i] = 0) do
    inc(i);
  HighDigit := i;
  WrkDiv^.ShiftLeft(HighDigit - 1);
  WrkDiv^.Precision := 0;

  QuotientPrec := TempPrec - AVal^.GetPrecision;
  IterationCount := WrkVal^.GetBCDSize - QuotientPrec + GetPrecision;

  for i := 1 to IterationCount do
    begin
      while CompareBCD(WrkDiv) > 0 do
        begin
          WrkVal^.SubtractBCD(WrkDiv);
          inc(WrkQuo^.Value^[WrkQuo^.GetBCDSize]);
        end;
      WrkDiv^.ShiftRight(1);
      WrkQuo^.ShiftLeft(1);
    end;

  WrkQuo^.Precision := QuotientPrec;
  SetValueBCD(WrkQuo);
  SetSign(NewSign);

  Dispose(WrkVal, Done);
  Dispose(WrkQuo, Done);
  Dispose(WrkDiv, Done);
end;

procedure TBCD.DivideByReal(AVal: Real; APrec: Byte);
var
  WrkVal:  PBCD;
begin
  WrkVal := new(PBCD, InitReal(AVal, APrec, GetBCDSize));
  DivideByBCD(WrkVal);
  Dispose(WrkVal, Done);
end;

procedure TBCD.DivideByPChar(AVal: PChar; APrec: Byte);
var
  WrkVal: PBCD;
begin
  WrkVal := new(PBCD, InitPChar(AVal, APrec, GetBCDSize));
  DivideByBCD(WrkVal);
  Dispose(WrkVal, Done);
end;

procedure TBCD.AbsoluteValue;
begin
  SetSign(BCDPositive);
end;

procedure TBCD.Increment;
begin
  AddReal(1);
end;

procedure TBCD.Decrement;
begin
  SubtractReal(1);
end;

procedure TBCD.ShiftLeft(ShiftAmount: Byte);
var
  i:  integer;
begin
  if ShiftAmount = 0 then exit;
  for i := 1 to (BCDSize - ShiftAmount) do
    Value^[i] := Value^[i+ShiftAmount];
  for i := ((BCDSize - ShiftAmount) + 1) to BCDSize do
    Value^[i] := 0;
end;

procedure TBCD.ShiftRight(ShiftAmount: Byte);
var
  i:  integer;
begin
  if ShiftAmount = 0 then exit;
  for i := BCDSize downto (ShiftAmount + 1) do
    Value^[i] := Value^[i - ShiftAmount];
  for i := ShiftAmount downto 1 do
    Value^[i] := 0;
end;

function TBCD.BCD2Int: LongInt;
var
  i:  integer;
  wrkLongInt:  LongInt;
begin
  BCD2Int := 0;
  if Precision = GetBCDSize then exit;

  wrkLongInt := 0;
  i := 1;
  repeat
    wrkLongInt := wrkLongInt * 10;
    wrkLongInt := wrkLongInt + Value^[i];
    inc(i);
  until i = (GetBCDSize - GetPrecision);
  if GetSign = BCDNegative then
    BCD2Int := -wrkLongInt
  else
    BCD2Int := wrkLongInt;
end;

function TBCD.BCD2Real: Real;
var
  i:  integer;
  wrkIntegerPart, wrkFractionPart:  real;
begin
  BCD2Real := 0.0;
  wrkIntegerPart := 0;
  wrkFractionPart := 0;

  if GetPrecision < GetBCDSize then
    begin
      i := 1;
      repeat
        wrkIntegerPart := wrkIntegerPart * 10.0;
        wrkIntegerPart := wrkIntegerPart + Value^[i];
        inc(i);
      until i = (GetBCDSize - GetPrecision + 1);
    end;

  if Precision > 0 then
    begin
      i := GetBCDSize;
      repeat
        wrkFractionPart := wrkFractionPart + Value^[i];
        wrkFractionPart := wrkFractionPart / 10.0;
        dec(i);
      until i = (GetBCDSize - GetPrecision);
    end;

  if GetSign = BCDNegative then
    BCD2Real := -(wrkIntegerPart + wrkFractionPart)
  else
    BCD2Real := (wrkIntegerPart + wrkFractionPart);
end;

function TBCD.PicStr(picture: string;
                     Width: Integer; BlankWhenZero: Boolean): String;

var
   integer_str, decimal_str, pic_str, val_str:  string;
   decimal_encountered, significant_digits_encountered:  boolean;
   number_of_digits, number_of_integer_digits, number_of_decimal_digits,
   sub_pic, sub_val, i:  integer;

begin    {pic}
  decimal_encountered := false;
  number_of_digits := 0;
  number_of_integer_digits := 0;
  for i := 1 to length(picture) do
    if upcase(picture[i]) in ['$', '-', '9', 'Z'] then
      begin
        inc(number_of_digits);
        if not decimal_encountered then
          inc(number_of_integer_digits);
      end
    else if picture[i] = '.' then
       decimal_encountered := true;
  number_of_decimal_digits := number_of_digits - number_of_integer_digits;

  integer_str := '';
  for i := (GetBCDSize - GetPrecision) downto 1 do
    integer_str := char(ord('0')+Value^[i]) + integer_str;
  if length(integer_str) > number_of_integer_digits then
    delete(integer_str, 1, length(integer_str)-number_of_integer_digits)
  else
    while length(integer_str) < number_of_integer_digits do
      integer_str := '0' + integer_str;

  decimal_str := '';
  for i := (GetBCDSize - GetPrecision + 1) to GetBCDSize do
    decimal_str := decimal_str + char(ord('0')+Value^[i]);
  if length(decimal_str) > number_of_decimal_digits then
    delete(decimal_str, number_of_decimal_digits+1, 255)
  else
    while length(decimal_str) < number_of_decimal_digits do
      decimal_str := decimal_str + '0';

  val_str := integer_str + decimal_str;

  pic_str := copy(st_Blanks, 1, length(picture));

  significant_digits_encountered := false;
  sub_pic := 1;
  sub_val := 1;
  while sub_pic <= length(picture) do
    begin
      if val_str[sub_val] in ['1'..'9']then
        significant_digits_encountered := true;
      if upcase(picture[sub_pic]) in ['(', ')'] then
        if Sign = BCDNegative then
          begin
            pic_str[sub_pic] := upcase(picture[sub_pic]);
            sub_pic := sub_pic + 1;
          end
        else
          begin
            pic_str[sub_pic] := ' ';
            sub_pic := sub_pic + 1;
          end
      else if upcase(picture[sub_pic]) in ['Z', '$', '-'] then
        begin
          if significant_digits_encountered then
            pic_str[sub_pic] := val_str[sub_val]
          else
            pic_str[sub_pic] := ' ';
          sub_pic := sub_pic + 1;
          sub_val := sub_val + 1;
        end
      else if picture[sub_pic] = '.' then
        begin
          pic_str[sub_pic] := '.';
          sub_pic := sub_pic + 1;
          significant_digits_encountered := true;
        end
      else if picture[sub_pic] = '9' then
        begin
          pic_str[sub_pic] := val_str[sub_val];
          if pic_str[sub_pic] = ' ' then pic_str[sub_pic] := '0';
          sub_pic := sub_pic + 1;
          sub_val := sub_val + 1;
          significant_digits_encountered := true;
        end
      else if picture[sub_pic] = ',' then
        begin
          if pic_str[sub_pic - 1] = ' ' then
            pic_str[sub_pic] := ' '
          else
            pic_str[sub_pic] := ',';
          sub_pic := sub_pic + 1;
        end
      else
        begin
          pic_str[sub_pic] := upcase(picture[sub_pic]);
          sub_pic := sub_pic + 1;
        end;
    end;

  if Sign = BCDNegative then
    begin
      sub_pic := 0;
      while (sub_pic < length(picture)) and
            (picture[sub_pic + 1] in ['(', '-', ',']) do
        sub_pic := sub_pic + 1;
      while (sub_pic > 0) and
            (pic_str[sub_pic] <> ' ') do
        sub_pic := sub_pic - 1;
      if (sub_pic > 0) and
         (picture[sub_pic] <> '(') then
        pic_str[sub_pic] := '-';
    end;

  sub_pic := 0;
  while (sub_pic < length(picture)) and
        (picture[sub_pic + 1] in ['(', '$', ',']) do
    sub_pic := sub_pic + 1;

  while (sub_pic > 0) and
        (pic_str[sub_pic] <> ' ') do
    sub_pic := sub_pic - 1;

  if (sub_pic > 0) and
     (picture[sub_pic] <> '(') then
    pic_str[sub_pic] := '$';

  if (BlankWhenZero) and (pic_str = BCDZero^.PicStr(picture, bpw_Fixed, false)) then
    pic_str := copy(st_Blanks, 1, length(picture));

  if Width = bpw_fixed then
    PicStr := pic_str
  else
    begin
      if pic_str[1] = ' ' then
        begin
          sub_pic := 1;
          while (sub_pic < length(pic_str)) and
                (pic_str[sub_pic] = ' ') do
            inc(sub_pic);
          if pic_str[sub_pic] <> ' ' then dec(sub_pic);
          delete(pic_str, 1, sub_pic);
        end;
      if pic_str[length(pic_str)] = ' ' then
        begin
          sub_pic := length(pic_str);
          while (sub_pic > 1) and
                (pic_str[sub_pic] = ' ') do
            dec(sub_pic);
          if pic_str[sub_pic] <> ' ' then inc(sub_pic);
          delete(pic_str, sub_pic, 255);
        end;
      PicStr := pic_str;
    end;
end;

function TBCD.StrPic(dest: PChar; picture: string;
                     Width: Integer; BlankWhenZero: Boolean;
                     Size: Integer): PChar;
var
  WrkStr:  array[0..300] of char;
begin
  if dest = nil then
    begin
      StrPic := nil;
      exit;
    end;

  StrPCopy(WrkStr, PicStr(picture, Width, BlankWhenZero));
  StrLCopy(dest, WrkStr, Size);
  StrPic := dest;
end;

function TBCD.CompareBCD(AVal: PBCD): Integer;
var
  i:  integer;
  BCD1, BCD2: PBCD;
begin
  if AVal = nil then exit;

  if GetSign < AVal^.GetSign then
    begin
      CompareBCD := -1;
      exit;
    end
  else if GetSign > AVal^.GetSign then
    begin
      CompareBCD := +1;
      exit;
    end;

  BCD1 := new(PBCD, InitBCD(@Self));
  BCD2 := new(PBCD, InitBCD(AVal));
  if GetBCDSize > AVal^.GetBCDSize then
    BCD2^.SetBCDSize(GetBCDSize)
  else
    BCD1^.SetBCDSize(AVal^.GetBCDSize);

  CompareBCD := 0;
  for i := 1 to BCD1^.GetBCDSize do
    begin
      if BCD1^.Value^[i] < BCD2^.Value^[i] then
        begin
          if BCD1^.GetSign = BCDNegative then
            CompareBCD := +1
          else
            CompareBCD := -1;
          Dispose(BCD1, Done);
          Dispose(BCD2, Done);
          exit;
        end
      else if BCD1^.Value^[i] > BCD2^.Value^[i] then
        begin
          if BCD1^.GetSign = BCDNegative then
            CompareBCD := -1
          else
            CompareBCD := +1;
          Dispose(BCD1, Done);
          Dispose(BCD2, Done);
          exit;
        end;
    end;
end;

function TBCD.CompareReal(AVal: Real): Integer;
var
  WrkVal: PBCD;
begin
  WrkVal := new(PBCD, InitReal(AVal, GetPrecision, GetBCDSize));
  CompareReal := CompareBCD(WrkVal);
  Dispose(WrkVal, Done);
end;

function TBCD.ComparePChar(AVal: PChar): Integer;
var
  WrkVal: PBCD;
begin
  WrkVal := new(PBCD, InitPChar(AVal, GetPrecision, GetBCDSize));
  ComparePChar := CompareBCD(WrkVal);
  Dispose(WrkVal, Done);
end;

begin
  BCDZero := new(PBCD, InitReal(0.0, 2, 3));
  RegisterType(RBCD);
end.

{ DOCUMENTATION }

AJCBCD - Binary Coded Decimal (BCD) Unit


This unit was written using Borland International's Borland Pascal v7.0, and
the Object Windows Library (OWL)/Turbo Vision (TV) library objects provided
with that product.



I have not copyrighted this program, and donate it to the public domain.  All
portions of this program may be used, modified, and/or distributed, in whole
or in part.


I wrote this unit to provide myself with some reusible functions that would
provide support for BCD math similar to what I've grown accustomed to with
the COBOL Packed Decimal (COMP-3) data type.  Note that in true "Packed
Decimal", two decimal digits are "packed" into each data byte.  I chose not
to implement my BCD support in that manner.  I may be less efficient in terms
of space, but I simply placed a single decimal digit in each byte.

I am just a "hobby" programmer, having written nothing for anyone byt myself.
Therefore, this unit may not be "elegant"; and, there are certainly better
ways of implementing some of the routines that I coded (like perhaps coding
some in assembler which I'm NOT very good at).  However, it has met my own
needs, and I'm actually a little proud of what I accomplished here
(especially in being able to figure out algorithms to multiply and divide!).
By the way, let me admit one thing right up front...I have NOT tested ALL of
the routines in this unit (in particular, the Divide routine).  I clearly
marked all of the routines that have not been fully tested.  You can assume
that all other routines HAVE been tested, because I used them in a real
application.

This might not be the best BCD routines available, but they might actually be
usefull to someone else--besides, it's free!  I am open to suggestions,
comments, or enhancements (although, I can't promise quick turn around because
I have a real job, plus I teach, plus I have a family--then I code for fun
--in that order <grin>).  My CompuServe ID is 71331,501.

This unit exports some constants (described below).  But, the big deal in
this unit is the Binary Coded Decimal object that this unit defines.  This
object (TBCD) allows you to allocate a BCD data type of any number of digits.
This object then provides methods for adding, subtracting, multiplying,
and dividing to/from/by other numbers.  It also has methods for altering
the number of digits stored as well as the precision (number of places after
the decimal place).


Constants
---------
DigitSize - Stores the size, in bytes, of each individual digit (currently
            one byte).

bpw_Fixed - Passed to the PicSTR and STRPic methods (see the description of
            PicSTR for an explanation of how to use this constant).

bpw_Variable - See bpw_Fixed above.

bpz_Blank - See bpw_Fixed above.

bpz_NotBlank - See bpw_Fixed above.

MaxBCDSize - Limits the maximum number of BCD digits that can be allocated
             for a BCD object.  Arbitrarily set to 100.

st_Blanks25 - A string constant containing 25 blanks.  Used just as a
              convenience in building the st_Blanks constant (see below).

st_Blanks - A String constant containing 255 blanks.  Used simply as a
            convenient reference/resource for lots of blanks (sort of like
            the "SPACES" constant in COBOL).

RBCD - TStreamRec used for registering the TBCD object type for use with
       streams.


Var
---
BCDZero - A PBCD object that is initialized to a value of zero in the unit's
          initialization section.  Used as a convenience whenever you need
          a BCD object with a value of zero.


Type
----
TBCDArray - An array of "MaxBCDSize" (100) bytes.  Allocated by the TBCD
            object to store the BCD value.  Each byte stores an individual
            digit of the value.

TBCDSign - An enumerated data type used by the TBCD object to represent the
           sign of the BCD value.  Valid values are "BCDNegative" and
           "BCDPositive".




TBCD
-----------------------------------------------------------------------------
 TObject       TBCD
┌──────┐      ┌─────────────────────────────────┐
│      │      │ BCDSize                         │
├──────┤      │ Sign                            │
│ Init │      │ Value                           │
│*Done │      │ Precision                       │
│ Free │      ├─────────────────────────────────┤
└──────┘      │ InitBCD         MultiplyByBCD   │
              │ InitReal        MultiplyByReal  │
              │ InitPChar       MultiplyByPChar │
              │ Done            DivideByBCD     │
              │ Load            DivideByReal    │
              │ Store           DivideByPChar   │
              │ GetValue        AbsoluteValue   │
              │ GetSign         Increment       │
              │ GetPrecision    Decrement       │
              │ GetBCDSize      ShiftLeft       │
              │ SetValueBCD     ShiftRight      │
              │ SetValueReal    BCD2Int         │
              │ SetValuePChar   BCD2Real        │
              │ SetSign         PicStr          │
              │ SetPrecision    StrPic          │
              │ SetBCDSize      CompareBCD      │
              │ AddBCD          CompareReal     │
              │ AddReal         ComparePChar    │
              │ AddPChar                        │
              │ SubtractBCD                     │
              │ SubtractReal                    │
              │ SubtractPChar                   │
              └─────────────────────────────────┘

Fields ---------------------------------------------------------------------

BCDSize:  Integer;                                                Read Only

The size, in number of digits, of the BCD number.  Count represents the
available space for digits, and does NOT include the decimal point, or sign.


Sign:  TBCDSign;                                                  Read Only

The mathmatical sign of the current value (i.e., indicates whether the
current value is positive or negative).


Value:  PBCDArray;                                                Read Only

A pointer to a TBCDArray (an array of bytes) used to store the value of the
BCD number.  Even though TBCDArray is defined with "MaxBCDSize" entries, only
BCDSize bytes are actually allocated from memory.  Therefore, you must be
sure to be careful never to read or write to subscript values greater than
BCDSize.  If you need to change the number of digits allocated you should use
the SetBCDSize method.  The BCD value is stored in the array with the lowest
order digit in the BCDSize position and the highest order digit in the 1st
position.  For example, if BCDSize is 5, Precision is 2, and the value being
stored is 2.35, then a 5-byte array would be allocated on the heap, and the
array values would be (in order from position 1 to 5) (0, 0, 2, 3, 5).


Precision:  Byte;                                                 Read Only

This value represents the number of digits after the decimal point.  Keep in
mind that there is no actual decimal point stored.


Methods ---------------------------------------------------------------------

InitBCD

constructor InitBCD(AVal: PBCD);

Sets BCDSize, Sign, and Precision to the same values as the BCD object
referred to by AVal.  It then calls SetValueBCD passing AVal in order to
allocate a TBCDArray for Value, and copies the AVal^.Value into this object's
Value array.


InitReal

constructor InitReal(AVal:  Real; APrec: byte; ASize: Integer);

Sets BCDSize to ASize, Precision to APrec, then calls SetValueReal(AVal) in
order to allocate a Value array and initialize it with the value in AVal.


InitPChar  ** Not yet tested **

constructor InitPChar(AVal:  PChar; APrec: byte; ASize: Integer);

Sets BCDSize to ASize, Precision to APrec, then calls SetValuePChar(AVal)
in order to allocate a Value array and initialize it with the value in AVal.


Done

destructor Done; virtual;

Frees the memory allocated for the Value array and calls "inherited Done".


Load

constructor Load(var S: TStream);

constructs and loads a BCD object from the stream S by first loading BCDSize,
Sign, the Value array, and last the Precision.


Store

procedure Store(var S: TStream);

Stores the BCD object on the stream S by storing the BCDSize, Sign, Value
array, and the Precision.


GetValue

function GetValue: PBCDArray;

Allocates a new TBCDArray of size BCDSize and copies the value in Value into
the new array, then returns a pointer to the new array.  Note that it will
be the calling routine's responsibility for disposing the array pointed to by
the returned pointer (use GetBCDSize to determine how much memory to free).
FreeMem should be used for this disposal, not Dispose.


GetSign

function GetSign: TBCDSign;

Returns the sign of the BCD value.  The sign is returned as a TBCDSign
value; either "BCDNegative", or "BCDPositive".


GetPrecision

function GetPrecision:  Byte;

Returns a byte value equal to the Precision (number of decimal places) of the
BCD number.


GetBCDSize

function GetBCDSize:  Inteteger;

Returns an integer value representing the number of BCD digits allocated in
the Value array.


SetValueBCD

procedure SetValueBCD(AVal: PBCD);

If Value is not nil, then the current Value array is freed.  Next, a new array
of size BCDSize is allocated on the heap, by calling AVal^.GetValue.  Next,
the copied value array is adjusted from the size and precision of AVal to
the BCDSize and Precision of this BCD object (if different).  Lastly, the
sign of the value is copied by calling AVal^.GetSign.


SetValueReal

procedure SetValueReal(AVal:  Real);

The current value array is initialized to all zero digits.  AVal is converted
to a string, and that string is copied digit by digit into the array.  If
AVal is less than zero then Sign is set to BCDNegative, otherwise it is set
to BCDPositive.


SetValuePChar  ** Not Tested Yet **

procedcure SetValuePChar(AVal: PChar);

The current value array is initialized to all zero digits.  AVal is copied
into the array digit by digit.  This routine validity checking to verify that
the string actually represents a numeric value.  The only character values
that are processed are:  1) numbers (0-9), 2) period (locates decimal point),
and 3) minus sign or parentheses to determine that the sign is negative.
Examples:  "(123.45)" would be interpreted as negative 123.45; "123.45" would
be interpreted as positive 123.45; "-123.45" would be interpreted as negative
123.45.  Likewise, "555-55-5555" would be interpreted as a negative
555555555; and "I'll have 2" would be interpreted as a positive 2.  If there
are no number characters in the string at all, then the resulting value is
zero.


SetSign

procedure SetSign(ASign: TBCDSign);

Sets Sign to ASign (either BCDNegative or BCDPositive).  Regardless of the
value of ASign, if the Value of the BCD is zero, then SetSign forces Sign to
be BCDPositive (in otherwords, BCD never stores a negative zero).


SetPrecision

procedure SetPrecision(APrec: Byte);

Sets Precision to APrec.  It also shifts the value array left or right,
depending on whether the precision is being increased or decreased.  If the
decimals are shifted left, dropping high order digits (hopefully zeros), and
padding zeros on the right.  If the precision is being decreased, the digits
are shifted to the right, padding the high order digits with zeros, and
dropping low order digits.  Note that the size of the value array is NOT
changed by this method.


SetBCDSize

procedure SetBCDSize(ASize: Integer);

Sets BCDSize to ASize.  It also allocates a new value array of the new size,
and copies value from the original value array to the new one.  The value
is copied right justified (in otherwords, high order digits are dropped
or padded with zeros depending on whether the new size is larger or smaller
than the old size).  The original value array is freed, and Value is set to
point to the new value array.


AddBCD

procedure AddBCD(AVal: PBCD);

Adds AVal^.Value to Self.Value.  This is a "signed add".  By that I mean that the
signs of the two operands ARE taken into account when adding the two values
together.  The result is stored in the Value array.  Mathmatically, it might
be represented by the following formula:  "Self := Self + AVal;"


AddReal

procedure AddReal(AVal: Real);

Converts AVal to a temporary PBCD object and calls AddBCD to add that
temporary BCD number to Self.


AddPChar  ** Not yet tested **

procedure AddPChar(AVal: PChar);

Converts AVal to a temporary PBCD object and calls AddBCD to add that
temporary BCD number to Self.


SubtractBCD

procedure SubtractBCD(AVal: PBCD);

Subtracts AVal^.Value from Self.Value.  This is a "signed subtract".  By that
I mean that the signs of the two operands ARE taken into account when
subtracting the two values.  The result is stored in the Value array.
Mathmatically, it might be represented by the following formula:
"Self := Self - AVal;"


SubtractReal  ** Not yet tested **

procedure SubtractReal(AVal: Real);

Converts AVal to a temporary PBCD object and calls SubtractBCD to subtract
that temporary BCD number from Self.


SubtractPChar  ** Not yet tested **

procedure SubtractPChar(AVal: PChar);

Converts AVal to a temporary PBCD object and calls SubtractBCD to subtract
that temporary BCD number from Self.


MultiplyByBCD

procedure MultiplyByBCD(AVal: PBCD);

Multiplies Self.Value by AVal^.Value.  This is a "signed multiply".  By that
I mean that the signs of the two operands ARE taken into account when
multiplying the two values.  The result is stored in the Value array.
Mathmatically, it might be represented by the following formula:
"Self := Self * AVal;"


MultiplyByReal  ** Not yet tested **

procedure MultiplyByReal(AVal: Real);

Converts AVal to a temporary PBCD object and calls MultiplyByBCD to
multiply Self by that temporary BCD number.


MultiplyByPChar  ** Not yet tested **

procedure MultiplyByPChar(AVal: PChar);

Converts AVal to a temporary PBCD object and calls MultiplyByBCD to
mulitiply Self by that temporary BCD number.


DivideByBCD  ** Not yet tested **

procedure DivideByBCD(AVal: PBCD);

Divides Self.Value by  AVal^.Value.  This is a "signed divide".  By that
I mean that the signs of the two operands ARE taken into account when
dividing the two values.  The result is stored in the Value array.
Mathmatically, it might be represented by the following formula:
"Self := Self/AVal;"


DivideByReal  ** Not yet tested **

procedure DivideByReal(AVal:  Real);

Converts AVal to a temporary PBCD object and calls DivideByBCD to divide
Self by that temporary BCD number.


DivideByPChar  ** Not yet tested **

procedure DivideByPChar(AVal:  Real);

Converts AVal to a temporary PBCD object and calls DivideByBCD to divide
Self by that temporary BCD number.


AbsoluteValue

procedure AbsoluteValue;

Calls SetSign to set Sign to BCDPositive, regardless of its current value.


Increment  ** Not yet tested **

procedure Increment;

Adds 1 Value.


Decrement  ** Not yet tested **

procedure Decrement;

Subtracts 1 from Value.


ShiftLeft

procedure ShiftLeft(ShiftAmount: Byte);

Shifts all of the digits left by ShiftAmount, dropping high order digits, and
padding the low order digits with zeros.  The Precision of the number is NOT
altered.  In effect, ShiftLeft multiplies Value by a power of 10.


ShiftRight

procedure ShiftRight(ShiftAmount: Byte);

Shifts all of the digits right by ShiftAmount, dropping low order digits, and
padding the high order digits with zeros.  The Precision of the number is NOT
altered.  In effect, ShiftRight divides Value by a power of 10.


BCD2Int  ** Not yet tested **

function BCD2Int: LongInt;

Converts the BCD value (and it's sign) to a LongInt data value.  Decimal
positions are simply truncated, not rounded.  Range checking is not performed.
If the number of significant digits of the BCD number (not counting decimal
positions) is too large for a LongInt number, high order digits are lost,
and the resulting LongInt value will probably be meaningless.


BCD2Real  ** Not yet tested **

function BCD2Real:  Real;

Converts the BCD value (and it's sign) to a Real data value.  Range checking
is not performed.  If the number of significant digits of the BCD number is
too loarge for a Real number, the results are unpredictable, and will
probably be meaningless.


PicStr

function PicStr(picture: string;
                Width: Integer; BlankWhenZero: Boolean): string;

PicStr converts the BCD number into a formatted Pascal string.  If you are
familiar with the used of Edit Numeric Formatting in Cobol, then you're a
long ways toward understanding how to use this routine.

First, let's get the simple parameters out of the way...

Width indicates whether or not insignificant leading and trailing blanks
should be removed from the resulting string.  If Width is equal to 0 then the
length of the resulting string will always equal the length of Picture,
regardless of any leading or trailing blanks in the result string.  If Width
is equal to 1, then any leading and/or trailing blanks will be removed from
the resulting string before returning.  For your convenience, two constants
have been defined for use with this parameter:  bpw_Fixed = 0 and
bpw_Variable = 1.

BlankWhenZero indicates whether the entire result string should be forced to
completely blank, regardless of any formatting characters in Picture, if the
formatted value is logically equal to zero.  The BCD value itself is NOT used
to make this determination.  The determination is made by comparing the
result string to the string from formatting BCDZero (zero value) with the
same Picture string.  If the two strings are equal, then this result string
is considered to be equal to zero.  If BlankWhenZero is true, then such zero
valued results are forced to all blanks.  If BlankWhenZero is false, the
the result string is left to whatever it becomes based on the Picture string.
If BlankWhenZero is true, and Width = bpw_Fixed, then the result string is
a string of blanks equal in length to the length of Picture.  If Width =
bpw_Variable, the the result will be an empty strint ('').  For example, if
the BCD number = 0.0023, and the formatted result is "0.00%", BlankWhenZero =
false would result in "0.00%", while BlankWhenZero = true would result in a
blank or empty string depending on Width.  For your convenience, two constants
have been defined for use with this parameter:  bpz_Blank = true, and
bpz_NotBlank = false.

Now, the more complicated part...picture...

The "picture" parameter is a string that provides a template for formatting
the value of the BCDnumber.  The possible template characters are...
  '9' - Fills with a digit from the value (or zero if no digit position
        available in the BCD number)
  'Z' - Just like '9', except that insignificant zeros (i.e., leading zeros)
        are left blank.
  'z' - Exactly the same as a capital "Z"
  '$' - Just like 'Z', except that the right most unused (blank)
        dollar-sign position is filled with a '$'.  COBOL afficianados will
        recognize this as a "floating dollar sign".
  '-' - Just like 'Z', except that if the BCD number value is negative, then
        the right most unused (blank) dash position is filled with a '-'.
        COBOL afficianoados will recognize this as a "floating negative sign".
  '(' - If the template contains a parenthesis, and the BCD number value is
        negative, then the result string is surrounded with parenthesis.
  ')' - If the template contains a parenthesis, and the BCD number value is
        negative, then the result string is surrounded with parenthesis.
  '.' - Indicates the decimal point position, and is included in the result
        string.  If the template does not contain a period, then the decimal
        position is assumed to be at the right end of the template, no
        decimal point is included in the result string, and no decimal place
        values are included in the result string.
  ',' - If any significant (non-zero) value positions precede the comma
        position, then a comma is inserted at this position in the result
        string.  This would normally be used to format commas to separate
        thousands positions in large numbers.
  ANY other characters are simply inserted into the result string in their
  relative position.

Some examples might help...

    Value         Picture String         Fixed Result       Variable Result
    123.45          '$$$$$9.99'           '  $123.45'        '$123.45'
    123456.78       '$$$$$9.99'           '123456.78'        '123456.78'
    123456.78       '$$$$$$9.99'          '$123456.78'       '$123456.78'
    123456.78       '$,$$$,$$9.99'        '$123,456.78'      '$123,456.78'
    123.45          '9999'                '0123'             '0123'
    -1234.6         '---,--9.99'          ' -1,234.60'       '-1,234.60'
    -10.15          '(99.99)'             '(10.15)'          '(10.15)'
    10.15           '(99.99)'             ' 10.15 '          '10.15'
    75              'z9.999%'             '75.000%'          '75.000%'

Got the idea?  I hope so.  I have developed a similar stand-alone routine
for formatting inteter and real numbers, and find it to be a VERY handy way
to nicely format my number values for presentation on the screen or on a
paper report.


StrPic  ** Not yet tested **

function StrPic(dest: PChar; picture: string;
                Width: Integer; BlankWhenZero: Boolean): PChar;

Calls PicStr(picture, Width, BlankWhenZero) to get a formatted Pascal string.
This string is converted to an null terminated string.  StrLCopy is used to
copy that null terminated string to Dest, limited by Size.  See PicStr for an
explanation of the use of picture, Width, and BlankWhenZero.  StrPic returns
a pointer to dest.


CompareBCD

function CompareBCD(AVal: PBCD): Integer;

Compares the signed values of Self and AVal.  CompareBCD returns -1 if Self
is less than AVal, returns +1 of Self is greater than AVal, and returns 0 if
the two values are equal.


CompareReal  ** Not yet tested **

function CompareReal(AVal: Real): Integer;

Converts AVal to a temporary PBCD object and calls CompareBCD to perform the
actual comparison with that temporary BCD number.  CompareReal returns the
value returned by CompareBCD.

ComparePChar  ** Not yet tested **


function ComparePChar(AVal: PChar): Integer;

Converts AVal to a temporary PBCD object and calls CompareBCD to perform the
actual comparison with that temporary BCD number.  ComparePChar returns the
value returned by CompareBCD.
