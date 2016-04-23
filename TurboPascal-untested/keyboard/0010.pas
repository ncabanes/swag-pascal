{
> I need help on reading the keyboard in a specific way, I need to read it
>as a whole not a key at a time. I need to do this For the games I make, Iha
>to ba able to hold down one key to perform a Function and then hold down
>another key and scan both keys at the same time but to perform 2 different
>Functions. For instance, if I hold down the left arrow key to make aCharact
>run I should be able to hold down the space bar to make him fire agun at th
>same time.

 by Sean Palmer, 1993, released to public domain
}

Unit keyScan;  {for now, ignores extended codes ($E0 prefix)}

Interface

Type
  scanCode = (
    kNone, kEsc, k1, k2, k3, k4, k5, k6, k7, k8, k9, k0, kMinus, kEqual,
    kBack, kTab, kQ, kW, kE, kR, kT, kY, kU, kI, kO, kP, kLBracket,
    kRBracket, kEnter, kCtrl, kA, kS, kD, kF, kG, kH, kJ, kK, kL, kColon,
    kQuote, kTilde, kLShift, kBackSlash, kZ, kX, kC, kV, kB, kN, kM, kComma,
    kPeriod, kSlash, kRShift, kPadStar, kAlt, kSpace, kCaps, kF1, kF2, kF3,
    kF4, kF5, kF6, kF7, kF8, kF9, kF10, kNum, kScroll, kHome, kUp, kPgUp,
    kPadMinus, kLf, kPad5, kRt, kPadPlus, kend, kDn, kPgDn, kIns, kDel,
    kSysReq, kUnknown55, kUnknown56, kF11, kF12);

Const
  kPad7 = kHome;
  kPad8 = kUp;
  kPad9 = kPgUp;
  kPad4 = kLf;
  kPad6 = kRt;
  kPad1 = kend;
  kPad2 = kDn;
  kPad3 = kPgDn;
  letters = [kQ..kP, kA..kL, kZ..kM];
  numbers = [k1..k0, kPad1..kPad3, kPad4..kPad6, kPad7..kPad9];
  FunctionKeys = [kF1..kF10, kF11..kF12];
  keyPad = [kPadStar, kNum..kDel];

Var
 keyboard : set of scanCode;
 lastKeyDown : scanCode;

Implementation
Uses Dos;

Const
  normChar : Array [scanCode] of Char = (
  {00} #0,^[,'1','2','3','4','5','6','7','8','9','0','-','=',^H,^I,
  {10} 'q','w','e','r','t','y','u','i','o','p','[',']',^M,#0,'a','s',
  {20} 'd','f','g','h','j','k','l',';','''','`',#0,'\','z','x','c','v',
  {30} 'b','n','m',',','.','/',#0,'*',#0,' ',#0,#0,#0,#0,#0,#0,
  {40} #0,#0,#0,#0,#0,#0,#0,'7','8','9','-','4','5','6','+','1',
  {50} '2','3','0','.',#0,#0,#0,#0,#0);
  shiftChar : Array [scanCode] of Char = (
  {00} #0,^[,'!','@','#','$','%','^','&','*','(',')','_','+',^H,^I,
  {10} 'Q','W','E','R','T','Y','U','I','O','P','{','}',^M,#0,'A','S',
  {20} 'D','F','G','H','J','K','L',':','"','~',#0,'|','Z','X','C','V',
  {30} 'B','N','M','<','>','?',#0,'*',#0,' ',#0,#0,#0,#0,#0,#0,
  {40} #0,#0,#0,#0,#0,#0,#0,'7','8','9','-','4','5','6','+','1',
  {50} '2','3','0','.',#0,#0,#0,#0,#0);

Function ascii(k : scanCode) : Char;
begin
  if [kLShift, kRShift] * keyboard <> [] then
    ascii := shiftChar[k]
  else
    ascii := normChar[k];
end;

Var
  oldKeyInt : Pointer;

Procedure keyISR; interrupt;
Var
  k : scanCode;
  b : Byte;
begin
  Asm
   in al, $60;
   mov b, al;
   and al, $7F;
   mov k, al;
   pushF;
   call [oldKeyInt];      {allow BIOS to process also}
  end;
  memW[$40 : $1A] := memW[$40 : $1C];  {clear BIOS keyboard buffer}
  if shortint(b) >= 0 then
  begin
    keyboard := keyboard + [k];
    lastKeyDown := k;
  end
  else
  if b <> $E0 then
    keyboard := keyboard - [k]
  else ;
end;

Procedure keybegin;
begin
  keyboard := [];
  lastKeyDown := kNone;
  getIntVec(9, oldKeyInt);
  setIntVec(9, @KeyISR);
end;

Var
  ExitSave:Pointer;

Procedure keyend;
begin
  setIntVec(9, oldKeyInt);
  ExitProc := ExitSave;
end;


begin
  keybegin;
  ExitSave := ExitProc;
  ExitProc := @keyend;
end.
