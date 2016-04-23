{
 I wrote routines to add and multiply any amount of bytes one at a time,
 but then had no way to test them out:)
}
program Really_Big_Math;

type ReallyBigNumber = array[0..100] of byte;
    {Byte [0] is the length, [1] is least significant}

procedure ShiftRBN(var A:ReallyBigNumber;N:byte);
var Index:Byte;
begin
  if n<>0 then begin
    for Index :=(A[0] + N) downto N+1 do A[Index] := A[Index - N];
    for Index := 1 to N do A[Index] := 0;
    Inc(A[0],N);
  end;
end;

procedure ByteAdd(A,B:Byte; var C,S:byte);
var temp:word;
begin
  temp := A+B+C;
  C    := temp div 256;
  S    := temp mod 256;
end;

Procedure ByteMult(A,B:Byte;var C,P:byte);
var temp:word;
begin
  temp:=A*B+C;
  C:=temp div 256;
  P:=temp mod 256;
end;


Procedure Sum(N1,N2:ReallyBigNumber;var S:ReallyBigNumber);
var WorkArray : ReallyBigNumber;
    L,Index,
    Carry     : byte;

begin
  Carry := 0;WorkArray[0] := 0;
  if N1[0] = 0 then for Index := 1 to 100 do N1[Index] := 0;
  if N2[0] = 0 then for Index := 1 to 100 do N2[Index] := 0;
  if N1[0] > N2[0] then L := N1[0] else L := N2[0];
  for Index := 1 to L do begin
   ByteAdd(N1[Index],N2[Index],Carry,WorkArray[Index]);
   inc(WorkArray[0]);
  end;
  if Carry <> 0 then inc(WorkArray[0]);
  WorkArray[L+1]:= Carry;
  S := WorkArray;
end;

procedure Product(N1,N2:ReallyBigNumber;var PR:ReallyBigNumber);
var C1,C2,L1,L2,
    Carry        :Byte;
    TProduct,
    WorkRBN      :ReallyBigNumber;
begin
  WorkRBN[0] := 0;
  L1 := N1[0];L2 := N2[0];
  for C1 := 1 to L1 do begin
    Carry:=0;TProduct[0]:=0;
    for C2 := 1 to L2 do begin
      ByteMult(N1[C1],N2[C2],Carry,TProduct[C2]);
      inc(TProduct[0]);
    end;
    if Carry<>0 then begin
      TProduct[C2+1] := Carry;
      inc(TProduct[0]);
    end;
    ShiftRBN(TProduct,C1-1);
    Sum(TProduct,WorkRBN,WorkRBN)
  end;
  PR := WorkRBN;
end;

procedure STR2RBN(S:String; var R:ReallyBigNumber);

var Index,
    SLen      : Byte;
    Value,
    RBNTen,
    RBNPlus   : ReallyBigNumber;

 function Ch2Val(C:Char):Byte;
 begin
   Ch2Val := ord(C) - 48;
 end;

begin
  SLen := Length(S);
  RBNTen[0] := 1; RBNTen[1] := 10;      {To Multiply Value by Ten}
  RBNPlus[0] := 1; RBNPlus[1] := 0;     {To add to Value}
  Value[0] := 1; Value[1] := Ch2Val(S[1]);
  if SLen > 1 then
    for Index := 2 to SLen do begin     (***THANKS DJ!!***)
      RBNPlus[1] := Ch2Val(S[Index]);
      Product(RBNTen,Value,Value);
      Sum(RBNPlus,Value,Value);
    end;
  R := Value;
end;

procedure RBN2Real(RBN:ReallyBigNumber;var RR:Real);
var RValue:Real;
begin
  RValue:=0;
  repeat
    RValue := RValue * 256;
    RValue := RValue + RBN[RBN[0]];
    dec(RBN[0]);
  until RBN[0] < 1;
  RR := RValue;
end;

var AA,BB,SS,PP: ReallyBigNumber;
    StA,StB    : String;
    RealP,RealS    : Real;

begin
  Writeln('Input A');
  Readln(StA);
  Writeln('Input B');
  Readln(StB);
  STR2RBN(StA,AA);
  STR2RBN(StB,BB);
  Sum(AA,BB,SS);
  Product(AA,BB,PP);
  RBN2Real(SS,RealS);
  RBN2Real(PP,RealP);
  Writeln('Sum =',RealS);
  Writeln('Product =',RealP);
end.
