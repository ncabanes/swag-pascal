(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0112.PAS
  Description: Strnig Patterns
  Author: WILLIAM ARTHUR BARATH
  Date: 05-26-95  23:31
*)

Unit USPat; {String pattern a-la Messy-DOS}
{ (C) 1994 William Arthur Barath.   Permission granted for free use in
  Commercial and Non-Commercial software. }

{ written oct 17/94 for TOMMY by WSEM at the request of Weird Al}
{ For use in UFO's text/file scanner.  Fast enough? }

Interface

Type pString = ^String;
Var SpatStr:pString;

Procedure UpCaseStr(Var s:String);
{call to convert a VAR ARG string to upper case.  Don't use w/ PCHAR!}
Procedure SetSPat(Var s:String);
{call to set the pattern to test against with each following call to
 Spat.  This sets a global pointer to the given string and converts that
 string to a format that can be read optimally fast, which saves passing
 the pattern arguement to the SPat PROC via the stack, which saves many
 many clock cycles and memory R\W accesses. 'S' *must* be a string of at
 least 12 characters, or a typecast region of memory of at least 13 bytes
 formatted as a Pascal-style STRING or ugly things may happen.}
Function SPat(Var s:String):Boolean;
{tests the given VAR ARG string against the string pattern pointed to by
 the Public SpatStr global pointer.  Passing a VAR ARG takes much less
 time since only a 4-byte pointer is pushed onto the stack prior to calling
 this PROC, as opposed to a full STRING, which may be 256 bytes and would 
be
 pushed a single char at a time... yawn...}
Function UCSPat(Var s:String):Boolean;
{tests the given VAR ARG string against the string pattern pointed to by
 the Public SpatStr global pointer.  Passing a VAR ARG takes much less
 time since only a 4-byte pointer is pushed onto the stack prior to calling
 this PROC, as opposed to a full STRING, which may be 256 bytes and would 
be
 pushed a single char at a time... yawn... Works with UPCASE'd data}

Implementation

Procedure UpCaseStr(Var s:String);assembler;
{up to 15 times faster than Borland's ASM demo code}
asm Push ds;Lds si,s;Xor ch,ch;Lodsb;Mov cl,al;Jcxz @Done;Mov dx,'az';
Mov ah,'a'-'A';Mov bx,-1;@Loop: Lodsb;Cmp al,dh;Jb @Upper;Cmp al,dl;
ja @Upper;Sub al,ah;Mov [si+bx],al;@Upper: Loop @Loop;@Done: Pop ds;end;

Procedure SetSPat(Var s:String);
{I'd write this in ASM as well, but it isn't likely to enter a loop so
 speed isn't really critical, and it may be useful to edit this to alter
 the personality of the pattern matching algorhythm.}
Type str12 = String[12];
Var l,p:Word;pat:Str12;
Begin
  If s[0]=#0 then s:='*.*';
   UpCaseStr(s);p:=1;
   For l:=1 to 12 do Case s[p] of
     '*':If l=9 then Begin Dec(l);Inc(p);end else pat[l]:='?';
     '.':If l=9 then Begin pat[l]:='.';Inc (p);end else pat[l]:=' ';
     Else Begin pat[l]:=s[p];If Char(p)<s[0] then Inc(p);end;
   end;
  Pat[0]:=Char(l);
  s:=pat;SPatStr:=@s;
end;

Function SPat(Var s:String):Boolean;assembler;
asm
  Push ds           {do this or die... :-) }
    Lds si,SpatStr  {location of the pattern string}
    Les di,s        {location of the test string}
    Lodsb
    Mov cl,es:[di]  {length of the test string}
    xor ch,ch
    Jcxz @BadMatch  {if the test string is NULL then never match}
    Inc di
@Search:
    Mov ah,es:[di]
    Cmp ah,'a'
    Jb  @Search2
    Cmp ah,'z'
    Ja  @Search2
    Sub ah,'a'-'A'  {convert the test string char to CAPS}
@Search2:
    Lodsb           {read and advance a char in pattern}
    Cmp ah,al
    Jz  @Match2     {if the characters are = }
    Cmp al,'?'
    Jnz @BadMatch   {pattern didn't match}
@Match:
    Cmp ah,'.'      {if '?' tries to match a dot, we try the next}
    jz  @search2    {char, which should be either '.' or '?'}
@Match2:
    Inc di          {advance to the next test string char}
    Loop @Search    {test for # of chars in test string}
    Mov al,True
    Jnz @Done       {return 'True'}
@BadMatch:
    xor ax,ax       {return 'False'}
@Done:
  Pop ds            {do this or die... :-) }
end;
Function UCSPat(Var s:String):Boolean;assembler;
asm
  Push ds           {do this or die... :-) }
    Lds si,SpatStr  {location of the pattern string}
    Les di,s        {location of the test string}
    Mov cl,[di]     {length of the test string}
    xor ch,ch
    Jcxz @Bad       {if the test string is NULL then never match}
    Inc cx          {use length+1, so when we hit 0 we know we're done}
    CMPSB           {sneaky way to INC DI and INC SI with one byte :-) }
    Mov dx,'?.'
    Mov bx,-1       {offset to last character.  faster than using immed. 
data}
@Search:
    REPZ CMPSB      {compare bytes until one doesn't match or CX = 0}
    Jcxz @Good      {when we hit 0, we're done.  Last comparison was 
garbage}
    cmp dh,[si+bx]  {If last pattern byte <> '?' then match is bad}
    Jnz @Bad
    cmp dl,[di+bx]  {If last test byte <> '.' then check next chars}
    Jnz @Search
    Dec di          {otherwise, make sure remaining pattern chars}
    Inc cx          {are '?'.  Otherwise, pattern should fail}
    Jmp @Search
@Good:
    Inc ch          {change the exit condition in ch from 0 to 1}
@Bad:
    Mov al,ch
  Pop ds            {do this or die... :-) }
end;
end.



