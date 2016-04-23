Unit sundry;

Interface

Uses
  Dos,
  sCrt,
  Strings;

Type
  LongWds = Record
              loWord,
              hiWord : Word;
            end;
  ica_rec = Record
              Case Integer of
                0: (Bytes   : Array[0..15] of Byte);
                1: (Words   : Array[0..7] of Word);
                2: (Integers: Array[0..7] of Integer);
                3: (strg    : String[15]);
                4: (longs   : Array[0..3] of LongInt);
                5: (dummy   : String[13]; chksum: Integer);
                6: (mix     : Byte; wds : Word; lng : LongInt);
            end;
{-This simply creates a Variant Record which is mapped to 0000:04F0
  which is the intra-applications communications area in the bios area
  of memory. A Program may make use of any of the 16 Bytes in this area
  and be assured that Dos and the bios will not interfere With it. This
  means that it can be effectively used to pass values/inFormation
  between different Programs. It can conceivably be used to store
  inFormation from an application, then terminate from that application,
  run several other Programs, and then have another Program use the
  stored inFormation. As the area can be used by any Program, it is wise
  to incorporate a checksum to ensure that the intermediate applications
  have not altered any values. It is of most use when executing child
  processes or passing values between related Programs that are run
  consecutively.}

  IOproc = Procedure(derror:Byte; msg : String);

Const
  ValidChars : String[40] = ' ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-'+#39;
  HexChars : Array[0..15] of Char = '0123456789ABCDEF';

Var
  ica : ica_rec Absolute $0000:$04f0;
  FilePosition : LongInt;
(*  OldRecSize   : Word; *)
  TempStr      : String;

Procedure CheckIO(Error_action : IOproc; msg : String);

Function CompressStr(Var n): String;
  {-Will Compress 3 alpha-numeric Bytes into 2 Bytes}

Function DeCompress(Var s): String;
  {-DeCompresses a String Compressed by CompressStr}

Function NumbofElements(Var s; size : Word): Word;
  {-returns the number of active elements in a set}

Function PrinterStatus : Byte;
  {-Gets the Printer status}

Function PrinterReady(Var b : Byte): Boolean;

Function TestBbit(n,b: Byte): Boolean;
Function TestWbit(Var n; b: Byte): Boolean;
Function TestLbit(n: LongInt; b: Byte): Boolean;

Procedure SetBbit(Var n: Byte; b: Byte);
Procedure SetWbit(Var n; b: Byte);
Procedure SetLbit(Var n: LongInt; b: Byte);

Procedure ResetBbit(Var n: Byte; b: Byte);
Procedure ResetWbit(Var n; b: Byte);
Procedure ResetLbit(Var n: LongInt; b: Byte);

Function right(Var s; n : Byte): String;
Function left(Var s; n : Byte): String;
Function shleft(Var s; n : Byte): String;
Function nExtStr(Var s1; s2 : String; n : Byte): String;
Procedure WriteAtCr(st: String; col,row: Byte);
Procedure WriteLnAtCr(st: String; col,row: Byte);
Procedure WriteLNCenter(st: String; width: Byte);
Procedure WriteCenter(st: String; width: Byte);
Procedure GotoCR(col,row: Byte);

  {-These Functions and Procedures Unit provides the means to do random
    access reads on Text Files.  }

Function Exist(fn : String) : Boolean;

Function Asc2Str(Var s; max: Byte): String;

Procedure DisableBlink(State:Boolean);

Function Byte2Hex(numb : Byte) : String;

Function Numb2Hex(Var numb) : String;

Function Long2Hex(long : LongInt): String;

Function Hex2Byte(HexStr : String) : Byte;

Function Hex2Word(HexStr : String) : Word;

Function Hex2Integer(HexStr : String) : Integer;

Function Hex2Long(HexStr : String) : LongInt;

{======================================================================}


Implementation

Procedure CheckIO(error_action : IOproc;msg : String);
  Var c : Word;
  begin
    c := Ioresult;
    if c <> 0 then error_action(c,msg);
  end;


{$F+}
Procedure ReportError(c : Byte; st : String);
  begin
    Writeln('I/O Error ',c);
    Writeln(st);
    halt(c);
  end;
{$F-}

Function StUpCase(Str : String) : String;
Var
  Count : Integer;
begin
  For Count := 1 to Length(Str) do
    Str[Count] := UpCase(Str[Count]);
  StUpCase := Str;
end;



Function CompressStr(Var n): String;
  Var
    S      : String Absolute n;
    InStr  : String;
    len    : Byte Absolute InStr;
    Compstr: Record
              Case Byte of
                0: (Outlen  : Byte;
                    OutArray: Array[0..84] of Word);
                1: (Out     : String[170]);
             end;
    temp,
    x,
    count : Word;
  begin
    FillChar(InStr,256,32);
    InStr := S;
    len   := (len + 2) div 3 * 3;
    FillChar(CompStr.Out,171,0);
    InStr := StUpCase(InStr);
    x := 1; count := 0;
    While x <= len do begin
      temp  := pos(InStr[x+2],ValidChars);
      inc(temp,pos(InStr[x+1],ValidChars) * 40);
      inc(temp,pos(InStr[x],ValidChars) * 1600);
      inc(x,3);
      CompStr.OutArray[count] := temp;
      inc(count);
    end;
    CompStr.Outlen := count shl 1;
    CompressStr := CompStr.Out;
  end;  {-CompressStr}

Function DeCompress(Var s): String;
  Var
    CompStr : Record
                clen : Byte;
                arry : Array[0..84] of Word;
              end Absolute s;
    x,
    count,
    temp    : Word;
  begin
    With CompStr do begin
      DeCompress[0] := Char((clen shr 1) * 3);
      x := 0; count := 1;
      While x <= clen shr 1 do begin
        temp := arry[x] div 1600;
        dec(arry[x],temp*1600);
        DeCompress[count] := ValidChars[temp];
        temp := arry[x] div 40;
        dec(arry[x],temp*40);
        DeCompress[count+1] := ValidChars[temp];
        temp := arry[x];
        DeCompress[count+2] := ValidChars[temp];
        inc(count,3);
        inc(x);
      end;
    end;
  end;

Function NumbofElements(Var s; size : Word): Word;
 {-The Variable s can be any set Type and size is the Sizeof(s)}
  Var
    TheSet : Array[1..32] of Byte Absolute s;
    count,x,y : Word;
  begin
    count := 0;
    For x := 1 to size do
      For y := 0 to 7 do
        inc(count, 1 and (TheSet[x] shr y));
    NumbofElements := count;
  end;

Function PrinterStatus : Byte;
   Var regs   : Registers; {-from the Dos Unit                         }
   begin
     With regs do begin
       dx := 0;            {-The Printer number   LPT2 = 1             }
       ax := $0200;        {-The Function code For service wanted      }
       intr($17,regs);     {-$17= ROM bios int to return Printer status}
       PrinterStatus := ah;{-Bit 0 set = timed out                     }
     end;                  {     1     = unused                        }
   end;                    {     2     = unused                        }
                           {     3     = I/O error                     }
                           {     4     = Printer selected              }
                           {     5     = out of paper                  }
                           {     6     = acknowledge                   }
                           {     7     = Printer not busy              }

Function PrinterReady(Var b : Byte): Boolean;
  begin
    b := PrinterStatus;
    PrinterReady := (b = $90) {-This may Vary between Printers}
  end;

Function TestBbit(n,b: Byte): Boolean;
  begin
    TestBbit := odd(n shr b);
  end;

Function TestWbit(Var n; b: Byte): Boolean;
  Var t: Word Absolute n;
  begin
    if b < 16 then
      TestWbit := odd(t shr b);
  end;

Function TestLbit(n: LongInt; b: Byte): Boolean;
  begin
    if b < 32 then
      TestLbit := odd(n shr b);
  end;

Procedure SetBbit(Var n: Byte; b: Byte);
  begin
    if b < 8 then
      n := n or (1 shl b);
  end;

Procedure SetWbit(Var n; b: Byte);
  Var t : Word Absolute n; {-this allows either a Word or Integer}
  begin
    if b < 16 then
      t := t or (1 shl b);
  end;

Procedure SetLbit(Var n: LongInt; b: Byte);
  begin
    if b < 32 then
      n := n or (LongInt(1) shl b);
  end;

Procedure ResetBbit(Var n: Byte; b: Byte);
  begin
    if b < 8 then
      n := n and not (1 shl b);
  end;

Procedure ResetWbit(Var n; b: Byte);
  Var t: Word Absolute n;
  begin
    if b < 16 then
      t := t and not (1 shl b);
  end;

Procedure ResetLbit(Var n: LongInt; b: Byte);
  begin
    if b < 32 then
      n := n and not (LongInt(1) shl b);
  end;

Function right(Var s; n : Byte): String;
  Var
    st : String Absolute s;
    len: Byte Absolute s;
  begin
    if n >= len then right := st else
    right := copy(st,len+1-n,n);
  end;

Function shleft(Var s; n : Byte): String;
  Var
    st   : String Absolute s;
    stlen: Byte Absolute s;
    temp : String;
    len  : Byte Absolute temp;
  begin
    if n < stlen then begin
      move(st[n+1],temp[1],255);
      len := stlen - n;
      shleft := temp;
    end;
  end;

Function left(Var s; n : Byte): String;
  Var
    st  : String Absolute s;
    temp: String;
    len : Byte Absolute temp;
  begin
    temp := st;
    if n < len then len := n;
    left := temp;
  end;

Function nExtStr(Var s1;s2 : String; n : Byte): String;
  Var
    main   : String Absolute s1;
    second : String Absolute s2;
    len    : Byte Absolute s2;
  begin
    nExtStr := copy(main,pos(second,main)+len,n);
  end;

Procedure WriteAtCr(st: String; col,row: Byte);
  begin
    GotoXY(col,row);
    Write(st);
  end;


Procedure WriteLnAtCr(st: String; col,row: Byte);
  begin
    GotoXY(col,row);
    Writeln(st);
  end;

Function Charstr(ch : Char; by : Byte) : String;
Var
  Str : String;
  Count : Integer;
begin
  Str := '';
  For Count := 1 to by do
    Str := Str + ch;
  CharStr := Str;
end;


Procedure WriteLnCenter(st: String; width: Byte);
  begin
    TempStr := CharStr(' ',(width div 2) - succ((length(st) div 2)));
    st      := TempStr + st;
    Writeln(st);
  end;

Procedure WriteCenter(st: String; width: Byte);
  begin
    TempStr := CharStr(' ',(width div 2)-succ((length(st) div 2)));
    st      := TempStr + st;
    Write(st);
  end;

Procedure GotoCR(col,row: Byte);
  begin
    GotoXY(col,row);
  end;

Function Exist(fn : String): Boolean;
  Var
    f         : File;
    OldMode   : Byte;
  begin
    OldMode := FileMode;
    FileMode:= 0;
    assign(f,fn);
    {$I-}  reset(f,1); {$I+}
    if Ioresult = 0 then begin
      close(f);
      Exist := True;
    end
    else
      Exist := False;
    FileMode:= OldMode;
  end; {-Exist}

Function Asc2Str(Var s; max: Byte): String;
  Var stArray : Array[0..255] of Byte Absolute s;
      st      : String;
      len     : Byte Absolute st;
  begin
    move(stArray[0],st[1],255);
    len := max;
    len := (max + Word(1)) * ord(pos(#0,st) = 0) + pos(#0,st)-1;
    Asc2Str := st;
  end;


Procedure DisableBlink(state : Boolean);
   { DisableBlink(True) allows use of upper eight colors as background }
   { colours. DisableBlink(False) restores the normal mode and should  }
   { be called beFore Program Exit                                     }
Var
   regs : Registers;
begin
  With regs do
  begin
    ax := $1003;
    bl := ord(not(state));
  end;
  intr($10,regs);
end;  { DisableBlink }

Function Byte2Hex(numb : Byte) : String;
  begin
    Byte2Hex[0] := #2;
    Byte2Hex[1] := HexChars[numb shr  4];
    Byte2Hex[2] := HexChars[numb and 15];
  end;

Function Numb2Hex(Var numb) : String;
  { converts an Integer or a Word to a String. Using an unTyped
    argument makes this possible. }
  Var n : Word Absolute numb;
  begin
    Numb2Hex := Byte2Hex(hi(n))+Byte2Hex(lo(n));
  end;

Function Long2Hex(long : LongInt): String;
  begin
    With LongWds(long) do { Type casting makes the split up easy}
      Long2Hex := Numb2Hex(hiWord) + Numb2Hex(loWord);
  end;

Function Hex2Byte(HexStr : String) : Byte;
  begin
    Hex2Byte := pos(UpCase(HexStr[2]),HexChars)-1  +
               ((pos(UpCase(HexStr[1]),HexChars))-1) shl  4 { *  16}
  end;

Function Hex2Word(HexStr : String) : Word;
  { This requires that the String passed is a True hex String  of 4
    Chars and not in a Format like $FDE0 }
  begin
    Hex2Word := pos(UpCase(HexStr[4]),HexChars)-1  +
               ((pos(UpCase(HexStr[3]),HexChars))-1) shl  4 + { *  16}
               ((pos(UpCase(HexStr[2]),HexChars))-1) shl  8 + { * 256}
               ((pos(UpCase(HexStr[1]),HexChars))-1) shl 12;  { *4096}
  end;

Function Hex2Integer(HexStr : String) : Integer;
  begin
    Hex2Integer := Integer(Hex2Word(HexStr));
  end;

Function Hex2Long(HexStr : String) : LongInt;
  Var Long : LongWds;
  begin
    Long.hiWord := Hex2Word(copy(HexStr,1,4));
    Long.loWord := Hex2Word(copy(HexStr,5,4));
    Hex2Long := LongInt(Long);
  end;

begin
  FilePosition := 0;
end.
