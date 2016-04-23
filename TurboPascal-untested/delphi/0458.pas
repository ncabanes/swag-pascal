Unit MKString32; {Delphi32 Only!}

///////////////////////////////////////////////////////////////////////////////
// MKString32 Coded in Part by G.E. Ozz Nixon Jr. of www.warpgroup.com       //
// ========================================================================= //
// Original Source for DOS by Mythical Kindom's Mark May (mmay@dnaco.net)    //
// Re-written and distributed with permission!                               //
// See Original Copyright Notice before using any of this code!              //
// Many new commands have beed added, and we have optimized the code to use  //
// Windows API calls when applicable, along with support for french days     //
// And we merged all the stray MK* units into this string unit!              //
///////////////////////////////////////////////////////////////////////////////

Interface

Uses
   Windows, {api calls!}
   SysUtils,
   Crc32;

Type
   DateTime=Record
      Year,
      Month,
      Day,
      DOW,
      Hour,
      Min,
      Sec,
      Sec100:Word;
   End;

   MKDateTime=Record
      Year,
      Month,
      Day,
      Hour,
      Min,
      Sec:Word;
   End;

   MKDateType=Record
      Year,
      Month,
      Day:Word;
   End;

Function  LoCase(Ch: Char): Char;
Function  padright(st:string;ch:char;l:integer):string;
Function  PadLeft(St:String;Ch:Char;L:Integer): String;
function  striplead(st:string;ch:char):string;
Function  StripTrail(St:String;Ch:Char):String;
Function  StripBoth(St:String;Ch:Char):String;
Function  Upper(St:String):String;
Function  Lower(St:String):String;
Function  Proper(St:String):String;
Function  WWrap(St:String;Max:Integer;var LeftOver:String):String;
function  ExtractWord(Str : String; N : Integer) : String;
Function  WordCount(Str : String) : Integer;
Function  CommaStr(Const Number:LongInt):String;
Function  Long2Str(Const Number:LongInt):String;
Function  Bin2Str(Number: Byte): String;
Function  Str2Bin(St: String): Byte;
Function  Str2Long(St: String): LongInt;
Function  Long2Hex(Const Number:LongInt):String;
Function  Word2Hex(Const Number:Word):String;
Function  Byte2Hex(Const Number:Byte):String;
Function  Hex2Byte(Const Str:String):Byte;
Function  Hex2Word(Const Str:String):Word;
Function  Hex2Long(Const Str:String):Longint;
Function  DateStr(DosDate: LongInt): String;
Function  TimeStr(DosDate: LongInt): String;
Procedure AddBackSlash(Var InPath: String);
Function  WithBackSlash(InPath: String): String;
Function  FormattedDate(DT: DateTime; Mask: String;French:boolean): String;
Function  FormattedDosDate(DosDate: LongInt; Mask:String;French:boolean): String;
Function  DOWStr(Dow:Word;French:Boolean):String;
Function  DOWShortStr(DOW:Word;French:Boolean):String;
Function  ReformatDate(ODate: String; Mask: String;French:Boolean): String;
Function  LongDate(DStr: String): LongInt;
Function  TimeStr2Word(TS: String): Word;
Function  Word2TimeStr(CTime: Word): String;
Function  MonthStr(MonthNo:Word;French:Boolean):String;
Function  PChar2Str(Str:PChar):String; {Convert asciiz to string}
Function  Str2PChar(Str:String):PChar; {Convert string to asciiz}
Function  MKDateToStr(MKD: String): String; {Convert YYMMDD to MM-DD-YY}
Function  StrToMKDate(Str: String): String; {Convert MM-DD-YY to YYMMDD}
Function  CleanChar(InChar: Char): Char;
Function  CleanStr(Str:String):String;
Function  IsNumeric(Str: String): Boolean;
Function  PosLastChar(Ch: Char; St: String): Word;
Function  Min(Const A,B:Longint):Longint;
Function  Max(Const A,B:Longint):Longint;
Function  Str2Real(Str:string):real;
function  Real2Str(Number:real;Decimals:byte):string;
Procedure SetLFlag(Var L: LongInt; Bit: Byte; Setting: Boolean);
Function  GetLFlag(L: LongInt; Bit: Byte): Boolean;
Procedure SetWFlag(Var L: Word; Bit: Byte; Setting: Boolean);
Function  GetWFlag(L: Word; Bit: Byte): Boolean;
Procedure SetBFlag(Var L: Byte; Bit: Byte; Setting: Boolean);
Function  GetBFlag(L: Byte; Bit: Byte): Boolean;
Function  StrCRC(Str: String): LongInt;
Function  NameCRC(Str: String): LongInt;
Procedure UpdateWordFlag(Var Flag: Word; Mask: Word; Setting: Boolean);
Function  DTToUnixDate(DT: DateTime): LongInt;
Procedure UnixToDt(SecsPast: LongInt; Var DT: DateTime);
Function  GregorianToJulian(DT: DateTime): LongInt;
Function  ValidDate(DT: DateTime): Boolean;
Function  ToUnixDate(FDate: LongInt): LongInt;
Function  ToUnixDateStr(FDate: LongInt): String;
Function  FromUnixDateStr(S: String): LongInt;
Procedure JulianToGregorian(JulianDN : LongInt; Var Year, Month,
  Day : Integer);
Function  DaysAgo(DStr: String): LongInt;
Function  Flag2Str(Number: Byte): String;
Function  Str2Flag(St: String): Byte;
Function  ValidMKDate(DT: MKDateTime): Boolean;
Procedure DT2MKDT(Var DT: DateTime; Var DT2: MKDateTime);
Procedure MKDT2DT(Var DT: MKDateTime; Var DT2: DateTime);
Procedure Str2MKD(St: String; Var MKD: MKDateType);
Function  MKD2Str(MKD: MKDateType): String;
Function  GetDosDate: LongInt;
Function  GetDOW: Word;
Function  GetResultCode: Integer;
Function  TimeOut(Time:DWord):Boolean;
Function  CurrentTimerTick:DWord;

Const
   CommaChar:Char=',';
   DecodeHEXTable='123456789ABCEDF';
   EncodeHEXTable='0'+DecodeHEXTable;

Implementation

Const
   C1970 = 2440588;
   D0 =    1461;
   D1 =  146097;
   D2 = 1721119;

function Real2Str(Number:real;Decimals:byte):string;
var Temp : string;
begin
    Str(Number:20:Decimals,Temp);
    repeat
       If copy(Temp,1,1)=' ' then delete(Temp,1,1);
    until copy(temp,1,1)<>' ';
    If Decimals=255 {Floating} then begin
       While Temp[1]='0' do Delete(Temp,1,1);
       If Temp[Length(temp)]='.' then Delete(temp,Length(temp),1);
    end;
    Result:= Temp;
end;

Function Str2Real(Str:string):real;
var
  code : integer;
  Temp : real;
begin
    If length(Str)=0 then Result:=0
    else begin
       If Copy(Str,1,1)='.' Then Str:='0'+Str;
       If (Copy(Str,1,1)='-') and (Copy(Str,2,1)='.') Then Insert('0',Str,2);
       If Str[length(Str)]='.' then Delete(Str,length(Str),1);
       val(Str,temp,code);
       if code=0 then Result:=temp
       else Result:=0;
    end;
end;

Function Min(Const A,B:Longint):Longint; {min}
Begin
   If A<B then Result:=A
   Else Result:=B;
End;

Function Max(Const A,B:Longint):Longint;  {max}
Begin
   If A>B then Result:=A
   Else Result:=B;
End;

Function LoCase(Ch:Char):Char;
Begin
   Result:=Char(CharLower(PChar(Ch))); {WIN32API}
End;

Procedure AddBackSlash(Var InPath: String);
Begin
  If Length(InPath) > 0 Then Begin
    If InPath[Length(InPath)] <> '\' Then InPath:=InPath+'\';
  End;
End;

Function WithBackSlash(InPath:String):String;
Begin
   AddBackSlash(InPath);
   Result:=InPath;
End;

Function Bin2Str(Number: Byte): String;
  Var
    Temp2: Byte;
    i: Word;
    TempStr: String[8];

  Begin
  Temp2 := $80;
  For i := 1 to 8 Do
    Begin
    If (Number and Temp2) <> 0 Then
      TempStr[i] := '1'
    Else
      TempStr[i] := '0';
    Temp2 := Temp2 shr 1;
    End;
  TempStr[0] := #8;
  Bin2Str := TempStr;
  End;


Function Str2Bin(St: String): Byte;
  Var
    i: Word;
    Temp1: Byte;
    Temp2: Byte;

  Begin
  St := StripBoth(St,' ');
  St := PadLeft(St,'0',8);
  Temp1 := 0;
  Temp2 := $80;
  For i := 1 to 8 Do
    Begin
    If St[i] = '1' Then
      Inc(Temp1,Temp2);
    Temp2 := Temp2 shr 1;
    End;
  Str2Bin := Temp1;
  End;

Function Str2Long(St:String):LongInt;
Var
   Err:Integer;
   Temp:LongInt;

Begin
   St:=StripBoth(St,' ');
   If Length(St)=0 then Result:=0
   Else Begin
      Val(St,Temp,Err);
      If Err=0 Then Result:=Temp
      Else Result:=0;
   End;
End;

Function DateStr(DosDate:LongInt):String;
Var
   W1,W2,W3:Word;

Begin
   DecodeDate(FileDateToDateTime(DosDate),W3,W1,W2);
   Result:=PadLeft(Long2Str(W1),' ',2)+'-'+
            PadLeft(Long2Str(W2),' ',2)+'-'+
            PadLeft(Copy(Long2Str(W3),3,2),' ',2);
End;

Function TimeStr(DosDate:LongInt):String;
Var
   W1,W2,W3,W4:Word;

Begin
   DecodeTime(FileDateToDateTime(DosDate),W1,W2,W3,W4);
   Result:=PadLeft(Long2Str(W1),' ',2)+':'+
            PadLeft(Long2Str(W2),' ',2)+':'+
            PadLeft(Long2Str(W3),' ',2);
End;

Function Byte2Hex(Const Number:Byte):String;
Begin
   Result:=EncodeHEXTable[(Number shr 4)+1]+
      EncodeHEXTable[(Number And $F)+1];
End;

Function Word2Hex(Const Number:Word):String;
Begin
   Result:=Byte2Hex(Number Shr 8)+Byte2Hex(Number And $FF);
End;

Function Long2Hex(Const Number:LongInt):String;
Type
   WordRec=Record
      Lo:Word;
      Hi:Word;
   End;

Begin
   Result:=Word2Hex(WordRec(Number).Hi)+Word2Hex(WordRec(Number).Lo);
End;

Function Hex2Byte(Const Str:String):Byte;
Begin
   Result:=Str2Long('H'+Str);
End;

Function Hex2Word(Const Str:String):Word;
Begin
   Result:=Str2Long('H'+Str);
End;

Function Hex2Long(Const Str:String):LongInt;
Begin
   Result:=Str2Long('H'+Str);
End;

Function Long2Str(Const Number:LongInt):String;
Var
   TempStr:String;

Begin
  Str(Number,TempStr);
  Result:=TempStr;
End;

Function CommaStr(Const Number:LongInt):String;
Var
   StrPos:Byte;
   NumberStr:String;

Begin
   NumberStr:=Long2Str(Number);
   StrPos:=Length(NumberStr)-2;
   While StrPos>1 Do Begin
      Insert(CommaChar,NumberStr,StrPos);
      StrPos:=StrPos-3;
   End;
   Result:=NumberStr;
End;

Function wordcount(str:string):integer;
var
   count : integer;
   i : integer;
   len : integer;

begin
  len := length(str);
  count := 0;
  i := 1;
  while i <= len do
    begin
    while ((i <= len) and ((str[i] = #32) or (str[i] = #9) or (Str[i] = ';'))) do
      inc(i);
    if i <= len then
      inc(count);
    while ((i <= len) and ((str[i] <> #32) and (str[i] <> #9) and (Str[i] <> ';'))) do
      inc(i);
    end;
  wordcount := count;
  end;


function extractword(str : string; n : integer) : string;
  Var
    count : integer;
    i : integer;
    len : integer;
    done : boolean;
    retstr : string;

  Begin
  retstr := '';
  len := length(str);
  count := 0;
  i := 1;
  done := false;
  While (i <= len) and (not done) do
    Begin
    While ((i <= len) and ((str[i] = #32) or (str[i] = #9) or (Str[i] = ';'))) do
      inc(i);
    if i <= len then
      inc(count);
    if count = n then
      begin
      retstr:='';
      If (i > 1) Then
        If Str[i-1] = ';' Then
          RetStr := ';';
      while ((i <= len) and ((str[i] <> #32) and (str[i] <> #9) and (Str[i] <> ';'))) do
        begin
        retstr:=RetStr+str[i];
        inc(i);
        end;
      done := true;
      end
    Else
      while ((i <= len) and ((str[i] <> #32) and (str[i] <> #9) and (Str[i] <> ';'))) do
        inc(i);
    End;
  extractword := retstr;
  End;


Function WWrap(St:String; Max:Integer;var leftOver:String):String;
  Var
    TempStr: String;
    TempPos: Integer;

  Begin
  LeftOver:='';
  TempStr := St;
  If Length(TempStr) > Max Then Begin
    TempPos := Max;
    While ((TempStr[TempPos]<>' ') And (TempPos>(Max-20))
      And (TempPos>1)) Do
      Dec(TempPos);
    If (Length(TempStr)>TempPos) Then
      LeftOver:=Copy(TempStr,TempPos + 1,Length(TempStr) - TempPos);
    TempStr:=Copy(TempStr,1,TempPos);
  End;
  Result:=TempStr;
End;


Function Proper(St:String):String;
Var
   TempStr:String;
   i:Integer;
   NextUp:Boolean;

Begin
   TempStr:=St;
   i:=1;
   NextUp:=True;
   TempStr:=St;
   While i<=Length(TempStr) Do Begin
      If Not (TempStr[i] in ['A'..'Z','a'..'z']) then NextUp:=True
      Else Begin
         If NextUp Then Begin
            NextUp:=False;
            TempStr[i]:=UpCase(TempStr[i]);
         End
         Else TempStr[i] := LoCase(TempStr[i]);
      End;
      Inc(I);
   End;
   Result:=TempStr;
End;

Function PadLeft(St:String;Ch:Char;L:Integer): String;
Var
   TempStr:String;
   I:Integer;

Begin
   I:=Length(St);
   If I>=L Then Result:=Copy(St,1,L)
   Else Begin
      Setlength(TempStr,L);
      FillChar(TempStr[I+1],L-I,Ch);
      Move(St[1],TempStr[1],I);
      Result:=TempStr;
   End;
End;


Function padright(st:string;ch:char;l:integer):string;
Var
   TempStr:String;
   I:Integer;

Begin
   I:=Length(St);
   If I>=L Then Result:=Copy(St,1,L)
   Else Begin
      Setlength(TempStr,L);
      FillChar(TempStr[1],L-I,Ch);
      Move(St[1],TempStr[(L-I)+1],I);
      Result:=TempStr;
   End;
end;

Function Upper(St:String):String;
Begin
   Result:=AnsiUppercase(St);
End;

Function Lower(St:String):String;
Begin
   Result:=AnsiLowercase(St);
End;

function striplead(st:string;ch:char):string;
var
   Tempstr:string;

begin
   Tempstr:=st;
   While ((TempStr[1]=Ch) and (Length(TempStr)>0)) do
      Delete(TempStr,1,1);
   Result:=TempStr;
end;

Function StripTrail(St:String;Ch:Char):String;
Var
   TempStr:String;

Begin
   TempStr:=St;
   While ((TempStr[Length(TempStr)]=Ch) and (Length(TempStr)>0)) do
      Delete(TempStr,Length(TempStr),1);
   Result:=TempStr;
End;

Function StripBoth(St:String;Ch:Char):String;
Begin
   Result:=StripTrail(StripLead(St,Ch),Ch);
End;

Function FormattedDate(DT:DateTime;Mask:String;French:Boolean):String;
  Var
    DStr: String[2];
    MStr: String[2];
    MNStr: String[3];
    YStr: String[4];
    HourStr: String[2];
    MinStr: String[2];
    SecStr: String[2];
    TmpStr: String;
    CurrPos: Word;
    i: Word;

  Begin
  TmpStr := Mask;
  Mask := Upper(Mask);
  DStr := Copy(PadLeft(Long2Str(Dt.Day),'0',2),1,2);
  MStr := Copy(PadLeft(Long2Str(Dt.Month),'0',2),1,2);
  YStr := Copy(PadLeft(Long2Str(Dt.Year),'0',4),1,4);
  HourStr := Copy(PadLeft(Long2Str(Dt.Hour),' ', 2),1,2);
  MinStr := Copy(PadLeft(Long2Str(Dt.Min), '0',2),1,2);
  SecStr := Copy(PadLeft(Long2Str(Dt.Sec), '0',2),1,2);
  MNStr := MonthStr(Dt.Month,French);
  If (Pos('YYYY', Mask) = 0) Then
    YStr := Copy(YStr,3,2);
  CurrPos := Pos('DD', Mask);
  If CurrPos > 0 Then
    For i := 1 to Length(DStr) Do
      TmpStr[CurrPos + i - 1] := DStr[i];
  CurrPos := Pos('YY', Mask);
  If CurrPos > 0 Then
    For i := 1 to Length(YStr) Do
      TmpStr[CurrPos + i - 1] := YStr[i];
  CurrPos := Pos('MM', Mask);
  If CurrPos > 0 Then
    For i := 1 to Length(MStr) Do
      TmpStr[CurrPos + i - 1] := MStr[i];
  CurrPos := Pos('HH', Mask);
  If CurrPos > 0 Then
    For i := 1 to Length(HourStr) Do
      TmpStr[CurrPos + i - 1] := HourStr[i];
  CurrPos := Pos('SS', Mask);
  If CurrPos > 0 Then
    For i := 1 to Length(SecStr) Do
      TmpStr[CurrPos + i - 1] := SecStr[i];
  CurrPos := Pos('II', Mask);
  If CurrPos > 0 Then
    For i := 1 to Length(MinStr) Do
      TmpStr[CurrPos + i - 1] := MinStr[i];
  CurrPos := Pos('NNN', Mask);
  If CurrPos > 0 Then
    For i := 1 to Length(MNStr) Do
      TmpStr[CurrPos + i - 1] := MNStr[i];
  FormattedDate := TmpStr;
  End;

Function FormattedDosDate(DosDate: LongInt; Mask:String;French:Boolean): String;
Var
   DT:DateTime;

Begin
   DecodeDate(FileDateToDateTime(DosDate),DT.Year,DT.Month,DT.Year);
   DecodeTime(FileDateToDateTime(DosDate),DT.Hour,DT.Min,DT.Sec,DT.Sec100);
   FormattedDosDate:=FormattedDate(DT, Mask,French);
End;

Function DOWStr(Dow:Word;French:Boolean):String;
Begin
   If French then Begin
   Case DOW Of
      0:Result:='Dimanche';
      1:Result:='Lundi';
      2:Result:='Mardi';
      3:Result:='Mercredi';
      4:Result:='Jeudi';
      5:Result:='Vendredi';
      6:Result:='Samedi';
   Else Result:='?????';
   End;
   End
   Else Begin
   Case DOW Of
      0:Result:='Sunday';
      1:Result:='Monday';
      2:Result:='Tuesday';
      3:Result:='Wednesday';
      4:Result:='Thursday';
      5:Result:='Friday';
      6:Result:='Saturday';
   Else Result:='?????';
   End;
   End;
End;

Function DOWShortStr(DOW:Word;French:Boolean):String;
Begin
   Result:=Copy(DOWStr(Dow,French),1,3);
End;

Function ReformatDate(ODate: String; Mask: String;French:Boolean): String;
Var
   DT: DateTime;

Begin
   DT.Year:=Str2Long(Copy(ODate,7,2));
   DT.Month:=Str2Long(Copy(ODate,1,2));
   DT.Day:=Str2Long(Copy(ODate,4,2));
   If DT.Year < 80 Then Inc(DT.Year,2000)
   Else Inc(DT.Year,1900);
   Result:=FormattedDate(DT,Mask,French);
End;

Function Word2TimeStr(CTime: Word): String;
Begin
   Result:=PadLeft(Long2Str(Hi(CTime)),'0',2)+':'+
       PadLeft(Long2Str(Lo(CTime)),'0',2);
End;

Function TimeStr2Word(TS: String):Word;
Begin
   Result:=Str2Long(Copy(TS,4,2))+(Str2Long(Copy(TS,1,2)) shl 8);
End;

Function MonthStr(MonthNo:Word;French:Boolean):String;
Begin
   Case MonthNo of
      01:Result:='Jan';
      02:Result:='Feb';
      03:Result:='Mar';
      04:If French then Result:='Avr'
         Else Result:='Apr';
      05:If French then Result:= 'Mai'
         Else Result:='May';
      06:Result:='Jun';
      07:Result:='Jul';
      08:If French then Result:='Auo'
         Else Result:='Aug';
      09:Result:='Sep';
      10:Result:='Oct';
      11:Result:='Nov';
      12:Result:='Dec';
      Else Result := '???';
   End;
End;

Function PChar2Str(Str:PChar):String; {Convert asciiz to string}
Begin
   Result:=Strpas(Str);
End;

Function Str2PChar(Str:String):PChar; {Convert string to asciiz}
Begin
   Result:=PChar(Str);
End;

Function MKDateToStr(MKD: String): String; {Convert YYMMDD to MM-DD-YY}
  Begin
  MKDateToStr := Copy(MKD,3,2) + '-' + Copy(MKD,5,2) + '-' +
    Copy(MKD,1,2);
  End;


Function StrToMKDate(Str: String): String; {Convert MM-DD-YY to YYMMDD}
Begin
   StrToMKDate:=Copy(Str,7,2)+Copy(Str,1,2)+Copy(Str,4,2);
End;

Function CleanChar(InChar:Char):Char;
Const
    CtlChars:String[32]='oooooooooXoollo><|!Pg*|^v><-^v';
    HiChars1:String[64]='CueaaaageeeiiiAAEaaooouuyOUcLYPfarounNao?--//!<>***|||||||||||||';
    HiChars2:String[64]='|--|-+||||=+|=++-=--==-||||*****abcnEduto0nd80En=+><fj/~oo.vn2* ';

Begin
   Case InChar of
      #0..#31:CleanChar:=CtlChars[Ord(InChar)+1];
      #128..#191:CleanChar:=HiChars1[Ord(InChar)-127];
      #192..#255:CleanChar:=HiChars2[Ord(InChar)-191];
   Else
      CleanChar:=InChar;
   End;
End;

Function CleanStr(Str:String):String;
Var
   I:Integer;

Begin
   I:=1;
   While (I<=Length(Str)) do Begin
      Str[I]:=CleanChar(Str[I]);
      Inc(I);
   End;
   Result:=Str;
End;

Function IsNumeric(Str:String):Boolean;
Var
   I:Integer;

Begin
   I:=1;
   While (I<=Length(Str)) do Begin
      If Not (Str[i] in ['0'..'9']) Then Begin
         Result:=False;
         Exit;
      End;
      Inc(I);
   End;
   Result:=True;
End;

Function LongDate(DStr:String):LongInt;
Var
   DT: DateTime;
   DosDate: TDateTime;

Begin
   DT.Year:=Str2Long(Copy(DStr,7,2));
   If Dt.Year<80 Then Inc(DT.Year,2000)
   Else Inc(DT.Year,1900);
   DT.Month:=Str2Long(Copy(DStr,1,2));
   DT.Day:=Str2Long(Copy(DStr,4,2));
   DT.Hour:=0;
   DT.Min:=0;
   DT.Sec:=0;
   DosDate:=EncodeDate(DT.Year,DT.Month,DT.Day);
   LongDate:=DateTimeToFileDate(DosDate);
End;

Function PosLastChar(Ch:Char;St:String):Word;
Var
   I:Integer;

Begin
   I:=Length(St);
   While ((i>0) and (st[i]<>ch)) Do Dec(i);
   Result:=I;
End;

Function DaysAgo(DStr: String): LongInt;
Var
    ODate: DateTime;
    CDate: DateTime;

  Begin
  DecodeDate(Now,CDate.Year,CDate.Month,CDate.Day);
  CDate.Hour := 0;
  CDate.Min := 0;
  CDate.Sec := 0;
  ODate.Year := Str2Long(Copy(DStr,7,2));
  If ODate.Year < 80 Then
    Inc(ODate.Year, 2000)
  Else
    Inc(ODate.Year, 1900);
  ODate.Month := Str2Long(Copy(DStr,1,2));
  ODate.Day := Str2Long(Copy(DStr, 4, 2));
  ODate.Hour := 0;
  ODate.Min := 0;
  ODate.Sec := 0;
  DaysAgo := GregorianToJulian(CDate) - GregorianToJulian(ODate);
  End;


Function NameCRC(Str: String): LongInt;
  Var
    L: LongInt;

  Begin
  L := StrCrc(Str);
  If ((L >= 0) and (L < 16)) Then
    Inc(L,16);
  NameCrc := L;
  End;


Function StrCRC(Str: String): LongInt;
  Var
    Crc: LongInt;
    i: Word;

  Begin
  i := 1;
  Crc := $ffffffff;
  While i <= Length(Str) Do
    Begin
    Crc := UpdC32(Ord(UpCase(Str[i])),Crc);
    Inc(i);
    End;
  StrCrc := Crc;
  End;


Procedure SetLFlag(Var L: LongInt; Bit: Byte; Setting: Boolean);
  Var
    Mask: LongInt;

  Begin
  Mask := 1;
  Mask := Mask Shl (Bit - 1);
  If Setting Then
    L := L or Mask
  Else
    L := (L and (Not Mask));
  End;


Function GetLFlag(L: LongInt; Bit: Byte): Boolean;
  Var
    Mask: LongInt;

  Begin
  Mask := 1;
  Mask := Mask Shl (Bit - 1);
  If (L and Mask) = 0 Then
    GetLFlag := False
  Else
    GetLFlag := True;
  End;


Procedure SetWFlag(Var L: Word; Bit: Byte; Setting: Boolean);
  Var
    Mask: Word;

  Begin
  Mask := 1;
  Mask := Mask Shl (Bit - 1);
  If Setting Then
    L := L or Mask
  Else
    L := (L and (Not Mask));
  End;


Function GetWFlag(L: Word; Bit: Byte): Boolean;
  Var
    Mask: Word;

  Begin
  Mask := 1;
  Mask := Mask Shl (Bit - 1);
  If (L and Mask) = 0 Then
    GetWFlag := False
  Else
    GetWFlag := True;
  End;


Procedure SetBFlag(Var L: Byte; Bit: Byte; Setting: Boolean);
  Var
    Mask: Byte;

  Begin
  Mask := 1;
  Mask := Mask Shl (Bit - 1);
  If Setting Then
    L := L or Mask
  Else
    L := (L and (Not Mask));
  End;


Function GetBFlag(L: Byte; Bit: Byte): Boolean;
  Var
    Mask: Byte;

  Begin
  Mask := 1;
  Mask := Mask Shl (Bit - 1);
  If (L and Mask) = 0 Then
    GetBFlag := False
  Else
    GetBFlag := True;
  End;


Function GregorianToJulian(DT: DateTime): LongInt;
Var
  Century: LongInt;
  XYear: LongInt;
  Month: LongInt;

  Begin
  Month := DT.Month;
  If Month <= 2 Then
    Begin
    Dec(DT.Year);
    Inc(Month,12);
    End;
  Dec(Month,3);
  Century := DT.Year Div 100;
  XYear := DT.Year Mod 100;
  Century := (Century * D1) shr 2;
  XYear := (XYear * D0) shr 2;
  GregorianToJulian :=  ((((Month * 153) + 2) div 5) + DT.Day) + D2
    + XYear + Century;
  End;


Procedure JulianToGregorian(JulianDN : LongInt; Var Year, Month,
  Day : Integer);

  Var
    Temp,
    XYear: LongInt;
    YYear,
    YMonth,
    YDay: Integer;

  Begin
  Temp := (((JulianDN - D2) shl 2) - 1);
  XYear := (Temp Mod D1) or 3;
  JulianDN := Temp Div D1;
  YYear := (XYear Div D0);
  Temp := ((((XYear mod D0) + 4) shr 2) * 5) - 3;
  YMonth := Temp Div 153;
  If YMonth >= 10 Then
    Begin
    YYear := YYear + 1;
    YMonth := YMonth - 12;
    End;
  YMonth := YMonth + 3;
  YDay := Temp Mod 153;
  YDay := (YDay + 5) Div 5;
  Year := YYear + (JulianDN * 100);
  Month := YMonth;
  Day := YDay;
  End;


Procedure UnixToDt(SecsPast: LongInt; Var Dt: DateTime);
Var
  DateNum: LongInt;
  Year,Month,Day:Integer;

Begin
  Datenum := (SecsPast Div 86400) + c1970;
  Year:=DT.Year;
  Month:=DT.Month;
  Day:=DT.Day;
  JulianToGregorian(DateNum,Year,Month,Day);
  DT.Year:=Year;
  DT.Month:=Month;
  DT.Day:=Day;
  SecsPast := SecsPast Mod 86400;
  DT.Hour := SecsPast Div 3600;
  SecsPast := SecsPast Mod 3600;
  DT.Min := SecsPast Div 60;
  DT.Sec := SecsPast Mod 60;
  End;


Function DTToUnixDate(DT: DateTime): LongInt;
   Var
     SecsPast, DaysPast: LongInt;

  Begin
  DaysPast := GregorianToJulian(DT) - c1970;
  SecsPast := DaysPast * 86400;
  SecsPast := SecsPast + (LongInt(DT.Hour) * 3600) + (DT.Min * 60) + (DT.Sec);
  DTToUnixDate := SecsPast;
  End;

Function ToUnixDate(FDate: LongInt): LongInt;
  Var
      DT: DateTime;

  Begin
  DecodeDate(FileDateToDateTime(FDate),DT.Year,DT.Month,DT.Day);
  DecodeTime(FileDateToDateTime(FDate),DT.Hour,DT.Min,DT.Sec,DT.Sec100);
  ToUnixDate := DTToUnixDate(Dt);
  End;


Function ToUnixDateStr(FDate: LongInt): String;
  Var
  SecsPast: LongInt;
  S: String;

  Begin
  SecsPast := ToUnixDate(FDate);
  S := '';
  While (SecsPast <> 0) And (Length(s) < 255) DO
    Begin
    s := Chr((secspast And 7) + $30) + s;
    secspast := (secspast Shr 3)
    End;
  s := '0' + s;
  ToUnixDateStr := S;
  End;


Function FromUnixDateStr(S: String): LongInt;
  Var
    DT: DateTime;
    secspast, datenum: LONGINT;
    n: WORD;
    Year,Month,Day:Integer;

  Begin
  SecsPast := 0;
  For n := 1 To Length(s) Do
    SecsPast := (SecsPast shl 3) + Ord(s[n]) - $30;
  Datenum := (SecsPast Div 86400) + c1970;
  Year:=DT.Year;
  Month:=DT.Month;
  Day:=DT.Day;
  JulianToGregorian(DateNum, Year,Month,day);
  DT.Year:=Year;
  DT.Month:=Month;
  DT.Day:=Day;
  SecsPast := SecsPast Mod 86400;
  DT.Hour := SecsPast Div 3600;
  SecsPast := SecsPast Mod 3600;
  DT.Min := SecsPast Div 60;
  DT.Sec := SecsPast Mod 60;
  FromUnixDateStr := DateTimeToFileDate(StrToDateTime(PadLeft(Long2Str(DT.Month),' ',2)+'/'+
     PadLeft(Long2Str(DT.Day),' ',2)+'/'+PadLeft(Copy(Long2Str(DT.Year),3,2),' ',2)+' '+
     PadLeft(Long2Str(DT.Hour),' ',2)+':'+PadLeft(Long2Str(DT.Min),' ',2)+':'+
     PadLeft(Long2Str(DT.Sec),' ',2)));
  End;


Function ValidDate(DT: DateTime): Boolean;
  Const
    DOM: Array[1..12] of Byte = (31,29,31,30,31,30,31,31,30,31,30,31);

  Var
    Valid: Boolean;

  Begin
  Valid := True;
  If ((DT.Month < 1) Or (DT.Month > 12)) Then
    Valid := False;
  If Valid Then
    If ((DT.Day < 1) Or (DT.Day > DOM[DT.Month])) Then
      Valid := False;
  If ((Valid) And (DT.Month = 2) And (DT.Day = 29)) Then
    If ((DT.Year Mod 4) <> 0) Then
      Valid := False;
  ValidDate := Valid;
  End;

Procedure UpdateWordFlag(Var Flag: Word; Mask: Word; Setting: Boolean);
  Begin
  If Setting Then
    Flag := Flag or Mask
  Else
    Flag := Flag and (Not Mask);
  End;

Function Flag2Str(Number: Byte): String;
  Var
    Temp2: Byte;
    i: Word;
    TempStr: String[8];

  Begin
  Temp2 := $01;
  For i := 1 to 8 Do Begin
    If (Number and Temp2) <> 0 Then TempStr[i] := 'X'
    Else TempStr[i] := '-';
    Temp2 := Temp2 shl 1;
  End;
  TempStr[0] := #8;
  Flag2Str := TempStr;
  End;

Function Str2Flag(St: String): Byte;
  Var
    i: Word;
    Temp1: Byte;
    Temp2: Byte;

  Begin
  St := StripBoth(St,' ');
  St := PadLeft(St,'-',8);
  Temp1 := 0;
  Temp2 := $01;
  For i := 1 to 8 Do Begin
    If Uppercase(Copy(St,i,1)) = 'X' Then Inc(Temp1,Temp2);
    Temp2 := Temp2 shl 1;
  End;
  Str2Flag := Temp1;
  End;

Procedure DT2MKDT(Var DT: DateTime; Var DT2: MKDateTime);
  Begin
  DT2.Year := DT.Year;
  DT2.Month := DT.Month;
  DT2.Day := DT.Day;
  DT2.Hour := DT.Hour;
  DT2.Min := DT.Min;
  DT2.Sec := DT.Sec;
  End;

Procedure MKDT2DT(Var DT: MKDateTime; Var DT2: DateTime);
  Begin
  DT2.Year := DT.Year;
  DT2.Month := DT.Month;
  DT2.Day := DT.Day;
  DT2.Hour := DT.Hour;
  DT2.Min := DT.Min;
  DT2.Sec := DT.Sec;
  End;

Function  ValidMKDate(DT: MKDateTime): Boolean;
  Var
    DT2: DateTime;

  Begin
  MKDT2DT(DT, DT2);
  ValidMKDate := ValidDate(DT2);
  End;


Procedure Str2MKD(St: String; Var MKD: MKDateType);
  Begin
  FillChar(MKD, SizeOf(MKD), #0);
  MKD.Year := Str2Long(Copy(St, 7, 2));
  MKD.Month := Str2Long(Copy(St, 1, 2));
  MKD.Day := Str2Long(Copy(St, 4, 2));
  If MKD.Year < 80 Then
    Inc(MKD.Year, 2000)
  Else
    Inc(MKD.Year, 1900);
  End;

Function MKD2Str(MKD: MKDateType): String;
  Begin
  MKD2Str := PadLeft(Long2Str(MKD.Month),'0',2) + '-' +
             PadLeft(Long2Str(MKD.Day), '0',2) + '-' +
             PadLeft(Long2Str(MKD.Year Mod 100), '0', 2);
  End;

Function CurrentTimerTick:DWord;      {use this to use Timeout!}
Begin
   CurrentTimerTick:=GetTickCount;
End;

Function TimeOut(Time:DWord):Boolean;
Begin
  TimeOut:=Time-GetTickCount<0;
End;

Function GetResultCode: Integer;
Begin
   GetResultCode:=0; {expand on this later!}
End;

Function GetDosDate: LongInt;
Begin
   GetDosDate:=DateTimeToFileDate(Now);
End;

Function GetDOW: Word;
Begin
   GetDOW:=DayOfWeek(Now);
End;

End.
