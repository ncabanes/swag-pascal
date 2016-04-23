{
To the SWAG:
I would like this version of my unit to replace the older version called
'Handling Massive Number functions' in the 'Math' snippet. If it is possible.
}

program BigNum;

{ BigNum v2.0, 16-bit  by Jes R. Klinke

  Implements calculations on integers of arbitrary size.
  All operations necessary for cryptographic applications are provided.

  You may use this unit for whatever you want. But if you make a commercial
  product please at least send me a copy of it.

  New in version 2:
  * Dynamic size
      Each instance of TBigNum has just enough memory allocated to it to
      keep its current value. You don't have to specify a BigNumSize anymore.
  * Negative numbers
      Most of the calculations now support negative values.
  * More efficient calculations
      As each instance of TBigNum keeps track of how many words are actually
      used in it's value, only the necessary calculations are performed.
      This particularly speeds up the multiplication, as lots of
      MUL's with zero words are avoided.

  To do's:
  * 32-bit calculations on 386+ processors for better performance

  Any comment or bug reports are welcome. I am especially interested in
  knowing if there are sufficient demand for a 32-bit version.
  You can reach me at jesk@diku.dk or jesk@dk-online.dk.
  My snail-mail address is Jes Rahbek Klinke
                           Haandvaerkerhaven 3, 2. mf
                           2400 Copenhagen NV
}

uses
  Crt, Dos;

type
  PWordArr = ^TWordArr;
  TWordArr = array [0..999] of Word;

  PBigNum = ^TBigNum;
  TBigNum = object
    Value: PWordArr;
    Alloc, Used: Word;
    Sign: Boolean;
    constructor Init;
    destructor Done;
    procedure Assign(const AValue: TBigNum);
    procedure AssignLong(AValue: LongInt);
    procedure Add(const AValue: TBigNum);
    procedure Subtract(const AValue: TBigNum);
    procedure Multiply(const AValue: TBigNum);
    function Divide(const ADivisor: TBigNum): Boolean;
    function Modulo(const ADivisor: TBigNum): Boolean;
    procedure PowerModulo(const AExponent, AModulo: TBigNum);
    procedure BitwiseOr(const AMask: TBigNum);
    function Compare(const AValue: TBigNum): Integer;
    procedure Mult10;
    procedure Div10;
    procedure Mult2;
    procedure Div2;
    function Str: string;
    function StrHex: string;
    procedure Val(const S: string);
    function AsLong: LongInt;
    procedure Swap(var AValue: TBigNum);
  { procedures working on absolute values only, mainly for internal use. }
    procedure AbsIncrement(By: Word);
    procedure AbsDecrement(By: Word);
    function AbsCompare(const AValue: TBigNum): Integer;
    procedure AbsAdd(const AValue: TBigNum);
    procedure AbsSubtract(const AValue: TBigNum);
    function AbsDivide(const ADivisor: TBigNum): Boolean;
    function AbsModulo(const ADivisor: TBigNum): Boolean;
  private { internal procedures for memory management }
    procedure Realloc(Words: Word; Preserve: Boolean);
    function Critical: Boolean;
    procedure CountUsed;
  end;

constructor TBigNum.Init;
begin
  Alloc := 0;
  Used := 0;
end;

destructor TBigNum.Done;
begin
  FreeMem(Value, Alloc * SizeOf(Word));
end;

procedure TBigNum.Assign(const AValue: TBigNum);
begin
  if Alloc < AValue.Used then
    Realloc(AValue.Used, False);
  Used := AValue.Used;
  Move(AValue.Value^, Value^, Used shl 1);
  FillChar(Value^[Used], (Alloc - Used) shl 1, 0);
  Sign := AValue.Sign;
end;

procedure TBigNum.AssignLong(AValue: LongInt);
begin
  if AValue < 0 then
  begin
    Sign := True;
    AValue := -AValue;
  end
  else
    Sign := False;
  if Alloc < 2 then
    Realloc(2, False);
  Move(AValue, Value^[0], SizeOf(LongInt));;
  Used := 2;
  if Alloc > Used then
    FillChar(Value^[Used], (Alloc - Used) shl 1, 0);
  CountUsed;
end;

procedure TBigNum.Add(const AValue: TBigNum);
var
  MValue: TBigNum;
begin
  if Sign xor AValue.Sign then
    if AbsCompare(AValue) >= 0 then
      AbsSubtract(AValue)
    else
    begin
      MValue.Init;
      MValue.Assign(AValue);
      TBigNum.Swap(MValue);
      AbsSubtract(MValue);
      MValue.Done;
    end
  else
    AbsAdd(AValue);
end;

procedure TBigNum.Subtract(const AValue: TBigNum);
var
  MValue: TBigNum;
begin
  if Sign xor AValue.Sign then
    AbsAdd(AValue)
  else
    if AbsCompare(AValue) >= 0 then
      AbsSubtract(AValue)
    else
    begin
      MValue.Init;
      MValue.Assign(AValue);
      TBigNum.Swap(MValue);
      AbsSubtract(MValue);
      MValue.Done;
      Sign := not Sign;
    end;
end;

procedure TBigNum.Multiply(const AValue: TBigNum);
var
  Needed: Word;
  Result: PWordArr;
  SmallVal, BigVal: PWordArr;
  Small, Big, I: Integer;
  X: Word;
begin
  if Used = 0 then
    Exit;
  if AValue.Used = 0 then
  begin
    Used := 0;
    Exit;
  end;
  Sign := Sign xor AValue.Sign;
  Needed := Used + AValue.Used + 1;
  GetMem(Result, Needed * SizeOf(Word));
  FillChar(Result^, Needed * SizeOf(Word), 0);
  if Used > AValue.Used then
  begin
    SmallVal := AValue.Value;
    Small := AValue.Used;
    BigVal := Value;
    Big := Used;
  end
  else
  begin
    BigVal := AValue.Value;
    Big := AValue.Used;
    SmallVal := Value;
    Small := Used;
  end;
  asm
    PUSH  DS
    CLD
    XOR    DX,DX
@@0:PUSH  DX
    LES    DI,SmallVal
    ADD    DI,DX
    ADD    DI,DX
    MOV    AX,[ES:DI]
    LES    DI,Result
    ADD    DI,DX
    ADD    DI,DX
    LDS    SI,BigVal
    MOV    CX,Big
    PUSH  BP
    MOV    BP,AX
    XOR    DX,DX
@@1:MOV    BX,DX
    LODSW
    MUL    BP
    ADD    BX,AX
    ADC    DX,0
    MOV    AX,[ES:DI]
    ADD    AX,BX
    STOSW
    ADC    DX,0
    LOOP  @@1
    MOV    AX,[ES:DI]
    ADD    AX,DX
    STOSW
    POP    BP
    POP    DX
    INC    DX
    CMP    DX,Small
    JNE    @@0
    POP    DS
  end;
  Realloc(Needed, False);
  Move(Result^, Value^, Needed * SizeOf(Word));
  if Alloc - Needed > 0 then
    FillChar(Value^[Needed], (Alloc - Needed) * SizeOf(Word), 0);
  FreeMem(Result, Needed * SizeOf(Word));
  CountUsed;
end;

{ Note: At first sight, you might think, that Divide and Modulo gives wrong
  results for negative values. This depends on the definition of the quoient
  and remainder.
  The definition used by these routines is:
  Given the divident N and divisor D, the quotient Q and remainder R is then
  defined by the equation
    N = D * Q + R,
  where the absolute value of R is less then the absolute value of D and R
  have the same sign as D.
  This will prove to be very convinient.}

function TBigNum.Divide(const ADivisor: TBigNum): Boolean;
begin
  if Sign xor ADivisor.Sign then
  begin
    Subtract(ADivisor);
    AbsDecrement(1);
    AbsDivide(ADivisor);
    Sign := not Sign;
  end
  else
  begin
    AbsDivide(ADivisor);
  end;
end;

function TBigNum.Modulo(const ADivisor: TBigNum): Boolean;
begin
  if Sign xor ADivisor.Sign then
  begin
    Subtract(ADivisor);
    AbsDecrement(1);
    AbsModulo(ADivisor);
    Add(ADivisor);
    AbsDecrement(1);
  end
  else
  begin
    AbsModulo(ADivisor);
  end;
end;

procedure TBigNum.PowerModulo(const AExponent, AModulo: TBigNum);
var
  Result, A: TBigNum;
  I: Integer;
begin
  if AExponent.Sign then
    RunError(201);
  Result.Init;
  A.Init;
  Result.AssignLong(1);
  A.Assign(Self);
  for I := 0 to AExponent.Used * 16 - 1 do
  begin
    if AExponent.Value^[I shr 4] and (1 shl (I and 15)) <> 0 then
    begin
      Result.Multiply(A);
      Result.Modulo(AModulo);
    end;
    A.Multiply(A);
    A.Modulo(AModulo);
  end;
  Assign(Result);
  A.Done;
  Result.Done;
end;

procedure TBigNum.BitwiseOr(const AMask: TBigNum);
begin
  if AMask.Used > Used then
    Realloc(AMask.Used, True);
  asm
    PUSH  DS
    LES   DI,Self
    LES   DI,[ES:DI.TBigNum.Value]
    LDS   SI,AMask
    MOV   CX,[DS:SI.TBigNum.Used]
    JCXZ  @@1
    LDS   SI,[DS:SI.TBigNum.Value]
    CLD
@@0:LODSW
    OR    AX,[ES:DI]
    STOSW
    LOOP  @@0
@@1:POP   DS
  end;
  CountUsed;
end;

function TBigNum.Compare(const AValue: TBigNum): Integer;
begin
  if Sign xor AValue.Sign then
    if Sign then
      Compare := -1
    else
      Compare := 1
  else
    if Sign then
      Compare := -AbsCompare(AValue)
    else
      Compare := AbsCompare(AValue);
end;

procedure TBigNum.Mult10;
begin
  Realloc(Used + 1, True);
  asm
    LES   DI,Self
    MOV   CX,[ES:DI.TBigNum.Used]
    JCXZ  @@1
    LES    DI,[ES:DI.TBigNum.Value]
    XOR   BX,BX
    CLD
@@0:MOV   AX,[ES:DI]
    MOV   DX,10
    MUL   DX
    ADD   AX,BX
    ADC   DX,0
    STOSW
    MOV   BX,DX
    LOOP  @@0
    MOV   [ES:DI],BX
@@1:
  end;
  CountUsed;
end;

procedure TBigNum.Div10;
begin
  asm
    LES   DI,Self
    MOV   CX,[ES:DI.TBigNum.Used]
    JCXZ  @@1
    LES    DI,[ES:DI.TBigNum.Value]
    MOV   DX,CX
    DEC   DX
    SHL   DX,1
    STD
    ADD   DI,DX
    XOR   DX,DX
@@0:MOV   AX,[ES:DI]
    MOV   BX,10
    DIV   BX
    STOSW
    LOOP  @@0
@@1:
  end;
  CountUsed;
end;

procedure TBigNum.Mult2;
begin
  if Critical then
  begin
    Realloc(Used + 1, True);
    Used := Used + 1;
  end;
  asm
    LES   DI,Self
    MOV   CX,[ES:DI.TBigNum.Used]
    JCXZ  @@1
    LES    DI,[ES:DI.TBigNum.Value]
    CLC
    CLD
@@0:MOV   AX,[ES:DI]
    RCL   AX,1
    STOSW
    LOOP  @@0
@@1:
  end;
  CountUsed;
end;

procedure TBigNum.Div2;
begin
  asm
    LES   DI,Self
    MOV   CX,[ES:DI.TBigNum.Used]
    JCXZ  @@1
    LES    DI,[ES:DI.TBigNum.Value]
    MOV   DX,CX
    DEC   DX
    SHL   DX,1
    ADD   DI,DX
    XOR   DX,DX
    CLC
    STD
@@0:MOV   AX,[ES:DI]
    RCR   AX,1
    STOSW
    LOOP  @@0
@@1:
  end;
  CountUsed;
end;

function TBigNum.Str: string;
var
  M, T: TBigNum;
  Res: string;
  I, Ciffer: Integer;
begin
  if Used = 0 then
  begin
    Str := '0';
    Exit;
  end;
  M.Init;
  T.Init;
  M.Assign(Self);
  T.AssignLong(1);
  I := 0;
  while M.AbsCompare(T) >= 0 do
  begin
    T.Mult10;
    Inc(I);
  end;
  if I <= 1 then
  begin
    if Sign then
      Str := '-' + Char(Byte('0') + M.Value^[0])
    else
      Str := Char(Byte('0') + M.Value^[0]);
  end
  else
  begin
    if Sign then
      Res := '-'
    else
      Res := '';
    T.Div10;
    while I > 0 do
    begin
      Ciffer := 0;
      while (M.AbsCompare(T) >= 0) do
      begin
        M.AbsSubtract(T);
        Inc(Ciffer);
      end;
      Res := Res + Char(Byte('0') + Ciffer);
      Dec(I);
      T.Div10;
    end;
    Str := Res;
  end;
  T.Done;
  M.Done;
end;

function TBigNum.StrHex: string;
const
  HexCif: array [0..15] of Char = '0123456789ABCDEF';
var
  Res: string;
  I: Integer;
  HasBegun: Boolean;
begin
  if Used = 0 then
  begin
    StrHex := '0';
    Exit;
  end;
  HasBegun := False;
  if Sign then
    Res := '-'
  else
    Res := '';
  for I := Used - 1 downto 0 do
  begin
    if HasBegun or (Value^[I] <> 0) then
    begin
      if HasBegun or (Value^[I] shr 12 and $F <> 0) then
      begin
        Res := Res + HexCif[Value^[I] shr 12 and $F];
        HasBegun := True;
      end;
      if HasBegun or (Value^[I] shr 8 and $F <> 0) then
      begin
        Res := Res + HexCif[Value^[I] shr 8 and $F];
        HasBegun := True;
      end;
      if HasBegun or (Value^[I] shr 4 and $F <> 0) then
      begin
        Res := Res + HexCif[Value^[I] shr 4 and $F];
        HasBegun := True;
      end;
      Res := Res + HexCif[Value^[I] and $F];
      HasBegun := True;
    end;
  end;
  StrHex := Res;
end;

procedure TBigNum.Val(const S: string);
var
  I: Integer;
begin
  Used := 0;
  if S[1] = '-' then
  begin
    Sign := True;
    I := 2;
  end
  else
  begin
    Sign := False;
    I := 1;
  end;
  while I <= Length(S) do
  begin
    Mult10;
    AbsIncrement(Byte(S[I]) - Byte('0'));
    Inc(I);
  end;
end;

function TBigNum.AsLong: LongInt;
var
  Res: LongInt;
begin
  if (Used > 2) or (Used = 2) and Critical then
    RunError(215);
  if Used = 2 then
    Res := Value^[1] shl 16 or Value^[0]
  else if Used = 1 then
    Res := Value^[0]
  else
    Res := 0;
  if Sign then
    AsLong := -Res
  else
    AsLong := Res;
end;

procedure TBigNum.Swap(var AValue: TBigNum);
var
  MW: Word;
  MP: PWordArr;
  MB: Boolean;
begin
  MW := Alloc;
  Alloc := AValue.Alloc;
  AValue.Alloc := MW;
  MW := Used;
  Used := AValue.Used;
  AValue.Used := MW;
  MP := Value;
  Value := AValue.Value;
  AValue.Value := MP;
  MB := Sign;
  Sign := AValue.Sign;
  AValue.Sign := MB;
end;

function TBigNum.AbsCompare(const AValue: TBigNum): Integer;
begin
  if Used > AValue.Used then
    AbsCompare := 1
  else if Used < AValue.Used then
    AbsCompare := -1
  else
    asm
      PUSH  DS
      LES    DI,Self
      LES    DI,[ES:DI.TBigNum.Value]
      LDS   SI,AValue
      MOV    CX,[DS:SI.TBigNum.Used]
      LDS    SI,[DS:SI.TBigNum.Value]
      MOV    DX,CX
      DEC    DX
      SHL    DX,1
      ADD    DI,DX
      ADD    SI,DX
      STD
      REPZ  CMPSW
      MOV    @Result,0FFFFh
      JA    @@1
      MOV    @Result,0000h
      JE    @@1
      MOV    @Result,0001h
@@1:  POP    DS
    end;
end;

procedure TBigNum.AbsIncrement(By: Word);
begin
  if (Used = 0) or Critical then
  begin
    Inc(Used);
    Realloc(Used, True);
  end;
  asm
    LES   DI,Self
    MOV   CX,[ES:DI.TBigNum.Used]
    DEC    CX
    LES   DI,[ES:DI.TBigNum.Value]
    CLD
    MOV   AX,[ES:DI]
    ADD   AX,By
    STOSW
    JCXZ  @@1
@@0:MOV   AX,[ES:DI]
    ADC   AX,0
    STOSW
    LOOP  @@0
@@1:
  end;
  CountUsed;
end;

procedure TBigNum.AbsDecrement(By: Word);
begin
  asm
    LES   DI,Self
    MOV   CX,[ES:DI.TBigNum.Used]
    DEC    CX
    LES   DI,[ES:DI.TBigNum.Value]
    CLD
    MOV   AX,ES:[DI]
    SUB   AX,By
    STOSW
    JCXZ  @@1
@@0:MOV   AX,ES:[DI]
    SBB   AX,0
    STOSW
    LOOP  @@0
@@1:
  end;
  CountUsed;
end;

procedure TBigNum.AbsAdd(const AValue: TBigNum);
var
  RealAdds, ExtraAdds: Word;
begin
  if AValue.Used >= Alloc then
    if AValue.Critical or (AValue.Used = Alloc) and (Alloc = Used) and Critical then
      Realloc(AValue.Used + 1, True)
    else
      if AValue.Used > Alloc then
        Realloc(AValue.Used, True)
  else if AValue.Used < Alloc then
    if (Used = Alloc) and Critical then
      Realloc(Used + 1, True);
  RealAdds := AValue.Used;
  ExtraAdds := Alloc - RealAdds;
  asm
    PUSH  DS
    LES    DI,Self
    LES    DI,[ES:DI.TBigNum.Value]
    LDS    SI,AValue
    LDS    SI,[DS:SI.TBigNum.Value]
    MOV    CX,RealAdds
    JCXZ  @@2
    CLD
    CLC
@@0:LODSW
    ADC    [ES:DI],AX
    INC    DI
    INC    DI
    LOOP  @@0
    MOV    CX,ExtraAdds
    JCXZ  @@2
@@1:ADC    WORD PTR [ES:DI],0
    INC    DI
    INC    DI
    LOOP  @@1
@@2:POP    DS
  end;
  CountUsed;
end;

procedure TBigNum.AbsSubtract(const AValue: TBigNum);
begin
  asm
    PUSH  DS
    LES   DI,Self
    MOV   DX,[ES:DI.TBigNum.Used]
    LES   DI,[ES:DI.TBigNum.Value]
    LDS   SI,AValue
    MOV   CX,[DS:SI.TBigNum.Used]
    LDS   SI,[DS:SI.TBigNum.Value]
    SUB    DX,CX
    JCXZ  @@2
    CLD
    CLC
@@0:LODSW
    SBB   [ES:DI],AX
    INC   DI
    INC   DI
    LOOP  @@0
    MOV    CX,DX
    JCXZ  @@2
@@1:SBB   WORD PTR [ES:DI],0
    INC   DI
    INC   DI
    LOOP  @@0
@@2:POP   DS
  end;
  CountUsed;
end;

function TBigNum.AbsDivide(const ADivisor: TBigNum): Boolean;
var
  Bit, Res, Divisor: TBigNum;
  NoRemainder: Boolean;
begin
  if ADivisor.Used = 0 then
    RunError(200);
  Bit.Init;
  Res.Init;
  Divisor.Init;
  Divisor.Assign(ADivisor);
  NoRemainder := False;
  Bit.AssignLong(1);
  Res.AssignLong(0);
  while AbsCompare(Divisor) >= 0 do
  begin
    Bit.Mult2;
    Divisor.Mult2;
  end;
  while (Bit.Value^[0] and 1 = 0) and not NoRemainder do
  begin
    Bit.Div2;
    Divisor.Div2;
    case AbsCompare(Divisor) of
      1:
      begin
        Res.BitwiseOr(Bit);
        AbsSubtract(Divisor);
      end;
      0:
      begin
        NoRemainder := True;
        Res.BitwiseOr(Bit);
        AbsSubtract(Divisor);
      end;
    end;
  end;
  AbsDivide := NoRemainder;
  Assign(Res);
  Divisor.Done;
  Res.Done;
  Bit.Done;
end;

function TBigNum.AbsModulo(const ADivisor: TBigNum): Boolean;
var
  Divisor: TBigNum;
  NoRemainder: Boolean;
  Count: Integer;
begin
  if ADivisor.Used = 0 then
    RunError(200);
  Divisor.Init;
  Divisor.Assign(ADivisor);
  NoRemainder := False;
  Count := 0;
  while AbsCompare(Divisor) >= 0 do
  begin
    Inc(Count);
    Divisor.Mult2;
  end;
  while (Count <> 0) and not NoRemainder do
  begin
    Divisor.Div2;
    case AbsCompare(Divisor) of
      1:
      begin
        AbsSubtract(Divisor);
      end;
      0:
      begin
        NoRemainder := True;
        AbsSubtract(Divisor);
      end;
    end;
    Dec(Count);
  end;
  AbsModulo := NoRemainder;
  Divisor.Done;
end;

procedure TBigNum.Realloc(Words: Word; Preserve: Boolean);
var
  NewValue: PWordArr;
begin
  if Words <= Alloc then
  begin
    if Preserve then
    begin
      FillChar(Value^[Used], (Alloc - Used) shl 1, 0);
    end;
    Exit;
  end;
  if Preserve then
  begin
    GetMem(NewValue, Words * SizeOf(Word));
    Move(Value^, NewValue^, Used shl 1);
    FillChar(NewValue^[Used], (Words - Used) shl 1, 0);
    FreeMem(Value, Alloc * SizeOf(Word));
    Value := NewValue;
    Alloc := Words;
  end
  else
  begin
    FreeMem(Value, Alloc * SizeOf(Word));
    Alloc := Words;
    GetMem(Value, Alloc * SizeOf(Word));
  end;
end;

function TBigNum.Critical: Boolean;
begin
  Critical := (Used > 0) and (Value^[Used - 1] and (1 shl (SizeOf(Word) * 8 - 1)) <> 0);
end;

procedure TBigNum.CountUsed;
begin
  Used := Alloc;
  while (Used > 0) and (Value^[Used - 1] = 0) do
    Dec(Used);
end;

var
  BigA, BigB: TBigNum;
  I: Integer;

begin
  BigA.Init; { Caution: Because of the new dynamic memory allocation }
  BigB.Init; {          you have to use Init and Done. }
  WriteLn('Fibonacci numbers:');
  BigA.Val('0');
  BigB.Val('1');
  for I := 1 to 370 do
  begin
    WriteLn(BigB.Str: 79);
    BigA.Add(BigB);
    BigA.Swap(BigB);
  end;
  WriteLn(BigB.Str: 79);
  WriteLn('Factorials:');
  BigA.Val('1');
  BigB.Val('1');
  for I := 1 to 49 do
  begin
    WriteLn(BigA.Str: 70, ' = ', BigB.Str, '!');
    BigB.AbsIncrement(1);
    BigA.Multiply(BigB);
  end;
  for I := 1 to 49 do
  begin
    WriteLn(BigA.Str: 70, ' = ', BigB.Str, '!');
    BigA.Divide(BigB);
    BigB.AbsDecrement(1);
  end;
  WriteLn(BigA.Str: 70, ' = ', BigB.Str, '!');
  WriteLn('Powers of 2:');
  BigA.Val('1');
  BigB.Val('-2');
  for I := 1 to 250 do
  begin
    WriteLn(BigA.Str: 79);
    BigA.Multiply(BigB);
  end;
  for I := 1 to 250 do
  begin
    WriteLn(BigA.Str: 79);
    BigA.Divide(BigB);
  end;
  WriteLn(BigA.Str: 79);
  BigB.Done;
  BigA.Done;
  Write('Press enter to exit.');
  ReadLn;
end.
