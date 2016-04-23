{I found a few errors and made a few improvements with my INI file
handler I posted this earlier.}

{$A+,B-,D-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S+,T-,V-,X+}

{INI  Version 1.2   Copr. 1996 Brad Zavitsky
 FREEWARE: Swag/Commercial use fine

Thanks to Andrew Eigus for his great EnhDos unit from which I got
Pas2Pchar

Version Info
1.1
====
  o Fixed error, needed StrNew instead of StrCopy
  o Added support for TP6- users.

1.2
====
  o  Better memory detection: now find paragraph size
  o  Optimized memory testing
  o  Entries will not be added if the entry or value is blank
  o  Fixed bug in split
  o  Added a comment delimeter set
  o  Added comments to source code
  o  Optimized space/tab stripping for memory
  o  Made FName a constant
  o  Made list global
}

unit INI; {031496}

interface

{$IFDEF VER70}
uses Strings;
{$ENDIF}

type
  CSet = set of Char;
  TEntry = string[32];
  {Linked list to store INI entries and values}
  PEntryList = ^TEntryList;
  TEntryList = record
     Entry,
     Value: PChar;
     Next: PEntrylist;
  end;

const
  {If these characters precede a line, it will be counted as a comment}
  CommentDelim: CSet = [';','[','#'];

var
  List: PEntryList; {Holds entries and values}


{Load the ini file into a linked list; this must be done before 
attempting
to get any entries
Returns:
  0 = Everything is fine
  1 = Error opening (ie.. File not found)
  2 = Not enough memory (remember to call freeini to get rid of already
      stored variables}
function LoadINI(const FName: string): Integer;
{Frees the memory allocated from LoadINI}
procedure FreeINI;
{Gets the value from a specified entry}
function GetEntry(Entry: TEntry; const Default: string): string;

implementation

var
  S,E,V: string; {Temporary strings, E=Entry, V=Value}
  Temp: PChar;   {Used to store a string as a PChar for StrComp}
  T: Text;       {INI text file}
  LNew: PEntryList; {New link}

{Pascal string to ASCIIZ; Thanks to Andrew Eigus}
function Pas2PChar(const S : string) : PChar; assembler;
asm
  les di,S
  mov al,byte ptr [es:di]
  cmp al,0
  je  @@1
  push di
  sub ah,ah
  cld
  inc al
  stosb
  add di,ax
  dec di
  sub al,al
  stosb
  pop di
@@1:
  inc di
  mov dx,es
  mov ax,di
end; { Pas2PChar }

{ASCIIZ to Pascal}
function PChar2Pas(P: PChar): string;
var
  IDX: Integer;
begin
  Idx := 0;
  while P[IDX] <> #0 do
  begin
    PChar2Pas[succ(Idx)] := P[IDX];
    inc(Idx);
  end;
  PChar2Pas[0] := Chr(Idx);
end;

{Fast uppercase function}
function UpperCase(const S: string): string; assembler;
asm
  push ds
  lds si, s
  les di, @result
  lodsb
  stosb
  xor ch, ch
  mov cl, al
  jcxz @empty
@upperloop:
  lodsb
  cmp al, 'a'
  jb @cont
  cmp al, 'z'
  ja @cont
  sub al, ' '
@cont:
  stosb
  loop @upperloop
@empty:
  pop ds
end;

{Removes all instances of DELCHAR from the right side of S}
function CutRight(const S: string; DelChar: Char): string;
var
  Len: Byte;
begin
  CutRight := S;
  Len := Ord(S[0]);
  while S[Len] = DelChar do Dec(Len);
  CutRight[0] := Chr(Len);
end;

{Removes all instances of DELCHAR from the left side of S}
function CutLeft(const S: string; DelChar: Char): string;
var
  Cnt: Byte;
begin
  Cnt := 1;
  while S[Cnt] = DelChar do Inc(Cnt);
  CutLeft := Copy(S, Cnt, Length(S)-pred(Cnt));
end;

{Splits a INI string into 2 parts: the entry and value}
procedure Split(const S: string; var E,V: string);
var
  len: Byte;
begin
  Len := Pos('=',S);
  if Len <> 0 then
  begin
    V := Copy(S, succ(Len), succ(Length(S)-Len));
    E := S;
    E[0] := chr(pred(Len));
    V := CutLeft(V, #32);
    V := CutLeft(V, #9);
    V := CutRight(V, #32);
    V := CutRight(V, #9);
    E := CutRight(E, #32);
    E := CutRight(E, #9);
  end else
  begin      {Invalid entry}
    E := '';
    V := '';
  end;
end;

{String unit emulation}
{$IFNDEF VER70}
function StrNew(S: PChar): PChar;
var
  I,
  L: Word;
  P: PChar;
begin
  StrNew := nil;
  if (S<>nil) and (S^ <> #0) then
  begin
    L := 0;
    while S[L] <> #0 do inc(L);
    inc(L);
    GetMem(P,L);
    if P <> nil then for I := 0 to L do P[I] := S[I];
    StrNew := P;
  end;
end;

procedure StrDispose(S: PChar);
var
  L: Word;
begin
  L := 0;
  while S[L] <> #0 do inc(L);
  if S <> nil then FreeMem(S,succ(L));
end;

function StrComp(Str1, Str2: PChar): Integer;
var
  L1,
  L2: Word;
begin
  StrComp := 1;
  L1 := 0;
  while Str1[L1] <> #0 do inc(L1);
  l2 := 0;
  while Str2[L2] <> #0 do inc(L2);
  if L1 <> L2 then exit;
  for L1 := 0 to L2 do if Str1[L1] <> Str2[L1] then exit;
  StrComp := 0;
end;

{$ENDIF}

{Calculates the amount of memory that would be actually allocated;
 Counts it in 16byte paragraphs}
function MemUsed(M: Word): Word;
var
  R: Byte;
begin
  MemUsed := succ(M shr 4) shl 4;
end;

function LoadINI(const FName: string): Integer;
begin
  assign(T, FName);
  reset(T);
  if IOResult <> 0 then {Exit if there is a file error}
  begin
    LoadINI := 1;
    Exit;
  end;

  while not Eof(T) do
  begin
    Readln(T, S);
    S := uppercase(S);
    S := CutLeft(S, #32); {Remove spaces and tabs}
    S := CutLeft(S, #9);
    {Make sure string is not a comment}
    if not (S[1] in CommentDelim) and (Length(S) > 0) then
    begin
      Split(S, E, V); {Split string into entry and value}

      {When low on memory, start checking to make sure we have enough}
      if MaxAvail < 300 then if MaxAvail < MemUsed(SizeOf(TEntryList)) +
        MemUsed(succ(Length(V)))+ MemUsed(Succ(Length(E))) then
      begin
        LoadINI := 2;
        {FreeINI;}
        CLose(T);
        Exit;
      end;

      if (V <> '') and (E <> '') then
      begin
        {Add new link to list}
        New(LNew);
        {Allocate new copies on the stack; we don't want the PChar's
         pointing to E and V}
        Lnew^.Entry := StrNew(Pas2Pchar(E));
        Lnew^.Value := StrNew(Pas2Pchar(V));
        Lnew^.Next := List;
        List := LNew;
      end;
    end;
  end;

  LoadINI := 0;
  close(T);
end;

procedure FreeINI;
begin
  while List <> nil do
  begin
    StrDispose(List^.Entry);
    StrDispose(List^.Value);
    LNew := List;
    List := List^.Next;
    Dispose(Lnew);
  end;
end;

function GetEntry(Entry: TEntry; const Default: string): string;
var
  NotFound: Boolean;
begin
  NotFound := True;
  LNew := List;
  Entry := uppercase(Entry);
  {Make this a PCHAR so we can use StrComp on it}
  Temp := Pas2Pchar(Entry);
  while (LNew <> nil) and NotFound do
  begin
    if StrComp(Lnew^.Entry, Temp) = 0 then
    begin
      NotFound := False;
      GetEntry := PChar2Pas(LNew^.Value);
    end;
    Lnew := LNew^.Next;
  end;
  {Return Default uppercase, to provide consistancy}
  if NotFound then GetEntry := uppercase(Default);
end;

end.
