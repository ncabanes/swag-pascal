{
 Could somebody post some source code on how to read in a config File?  and
 also have it ignore lines that start With the semicolon. Sorta like this
 one:

Sure do, here is mine.  I have to include quite a couple of other Functions as
they are used in the readcfg.  I included one 'block' as an example in which
you read in a particular keyWord (named: 'keyWord') and find the parammeter
which follows.  You can duplicate this block as many times as you like.
Although it scans the whole File again, it's pretty fast as it does it in
memory.
}
Function Trim(S : String) : String;
  {Return a String With leading and trailing white space removed}
Var
  I : Word;
  SLen : Byte Absolute S;
begin
  While (SLen > 0) and (S[SLen] <= ' ') do
    Dec(SLen);
  I := 1;
  While (I <= SLen) and (S[I] <= ' ') do
    Inc(I);
  Dec(I);
  if I > 0 then
    Delete(S, 1, I);
  Trim := S;
end;


{******************************************************}
Function StrUpper(Str: String): String; Assembler;
 Asm
      jmp   @Start    { Jump over Table declared in the Code Segment }

  @Table:
    { Characters from ASCII 0 --> ASCII 96 stay the same }
  DB 00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21
  DB 22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43
  DB 44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65
  DB 66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87
  DB 88,89,90,91,92,93,94,95,96
    { Characters from ASCII 97 "a" --> ASCII 122 "z" get translated }
    { to Characters ASCII 65 "A" --> ASCII 90 "Z" }
  DB 65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86
  DB 87,88,89,90
    { Characters from ASCII 123 --> ASCII 127 stay the same }
  DB 123,124,125,126,127
    { Characters from ASCII 128 --> ASCII 165 some changes
     #129 --> #154, #130 --> #144, #132 --> #142, #134 --> #143
      #135 --> #128, #145 --> #146, #148 --> #153, #164 --> #165}

  DB 128,154,144,131,142,133,143,128,136,137,138,139,140,141,142,143
  DB 144,146,146,147,153,149,150,151,152,153,154,155,156,157,158,159
  DB 160,161,162,163,165,165
    { Characters from ASCII 166 --> ASCII 255 stay the same }
  DB 166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181
  DB 182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197
  DB 198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213
  DB 214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229
  DB 230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245
  DB 246,247,248,249,250,251,252,253,254,255

  @Start:
      push  DS                { Save Turbo's Data Segment address    }
      lds   SI,Str            { DS:SI points to Str[0]               }
      les   DI,@Result        { ES:DI points to StrUpper[0]          }
      cld                     { Set direction to Forward             }
      xor   CX,CX             { CX = 0                               }
      mov   BX,ofFSET @Table  { BX = offset address of LookUpTable   }
      lodsb                   { AL = Length(Str); SI -> Str[1]       }
      mov   CL,AL             { CL = Length(Str)                     }
      stosb                   { Move Length(Str) to Length(StrUpper) }
      jcxz  @Exit             { Get out if Length(Str) is zero       }

  @GetNext:
      lodsb                   { Load next Character into AL          }
      segcs XLAT              { Translate Char using the LookupTable }
                              { located in Code Segment at offset BX }
      stosb                   { Save next translated Char in StrUpper}
      loop  @GetNext          { Get next Character                   }

  @Exit:
      pop   DS                { Restore Turbo's Data Segment address }
end {StrUpper};
{-----------------------------------------------------------------}
Function MCS(element,line:String):Integer;

{Returns the position of an element in a line.
 Returns zero if no match found.
 Example: line:='abcdefg'
 i:=MCS('bc',line) would make i=2
 MCS is not Case sensitive}

begin
  MCS:=pos(StrUpper(element),StrUpper(line));
end;

Function getparameter(element,line:String;pos:Integer):String;
{This Function is called With 'pos' already indexed after the command Word in
a line.  It searches For the Word(s) after the command Word in the rest of
the line, up to the end of the line or Until a ; is encountered}

Var
  n,b,e,l:Byte;

begin
   n:=pos+length(element);
   {places n-index just after keyWord}

   While (line[n]=' ') do
     inc(n); {increment line[n] over spaces}
   b:=n; l:=length(line);
   While (n<=l)  do
   begin
     if line[n]<>';' then
     begin
       inc(n);
       e:=n;
     end
     else
     begin
       e:=n;
       n:=l+1;
     end;
   end;
   getparameter:=trim(copy(line,b,e-b));

end;

Procedure ReadCfg(name:String);  {'name' is Filename to read in}
Type
  Line     = String[80];
  Lines    = Array[0..799] of Line;
  LinesP   = ^Lines;
Var
  TextBuf  : LinesP;
  TextFile : Text;
  Index,Number:Integer;
  buffer:Array[1..2048] of Char;
  s:line;
  s1:line;
  n:Byte;
  i:Integer;
begin
  assign( TextFile, name );
  reset( TextFile );
  SetTextBuf(TextFile,Buffer);
  Index := 0;
  new(TextBuf);

  While  not eof( TextFile)  do
  {Read the Text File into heap memory}
  begin
    readln( TextFile,s);
    if s[1]<>';' then if s<>'' then
    begin
      TextBuf^[Index]:=s;
      inc( Index )
    end;
  end;
  close( TextFile );

{********begin of  "find a keyWord" block***********}
  Number := Index -1;
  For Index := 0 to Number do
  begin
    s:=( TextBuf^[ Index ]);
    n:=MCS('BoardNo',s);
    if n > 0 then
    begin
      s1:=getparameter('KeyWord',s,n);
      {do other things With found 'keyWord'}
    end;
  end;
{end of "find a keyWord" block}

  dispose( TextBuf);  {release heap memory}
end;
