unit StrPlus;

{---------------------------------------------------------------------------}
{ Extra string manipulation - by Michael Dales                              }
{                                                                           }
{ Defines a standard null terminated string, called cString and several     }
{ manipulation functions. Nothing brilliant, but it all works. Using this   }
{ along with the strings unit gives you just about all atring functions you }
{ could ever need. Just like christmas eh? :-)                              }
{                                                                           }
{ Email comments to: 9402198d@udcf.gla.ac.uk                                }
{ URL: http://www.gla.ac.uk/Clubs/WebSoc/~9402198d/index.html               }
{---------------------------------------------------------------------------}

interface

uses Strings;

const StringSize = 512;         {Size of string type}

type cString = array[0..StringSize] of Char; {New string type}

{BlankString - Empties a string}
procedure BlankString(var S:cString);

{IsLetter - Returns true if C is alphabetic}
function IsLetter(C:Char):Boolean;

{StripTo - Strip all characters in S up to C}
procedure StripTo(C:Char; var S:cString);

{StripFrom - Strip all characters in S from C}
procedure StripFrom(C:Char; var S:cString);

{RemoveFirstChar - Remove the first character from S}
procedure RemoveFirstChar(var S:cString);

{RemoveLeadingSpaces - Removes any spaces at the start of S}
procedure RemoveLeadingSpaces(var S:cString);

{GetFirstWord - Gets first all letter word from S}
procedure GetFirstWord(S:cString;var Out:cString);

{GetFirstBlock - Gets the first block of text (letters & symbols) from S}
procedure GetFirstBlock(S:cString;var Out:cString);

{RemoveFirstWord - Removes first word from S}
procedure RemoveFirstWord(var S:cString);

{RemoveFirstWord - Removes first block of text from S}
procedure RemoveFirstBlock(var S:cString);

{AddChar - Adds character C to the end of S}
procedure AddChar(var S:cString; C:Char);

{---------------------------------------------------------------------------}
implementation
{---------------------------------------------------------------------------}

   {IsLetter - Returns true if C is alphabetic}

function IsLetter(C:Char):Boolean;
begin
     IsLetter:=(UpCase(C)>='A') and (UpCase(C)<='Z');
end;


    {BlankString - Empties a string}

procedure BlankString(var S:cString);
begin
     FillChar(S,SizeOf(S),#0);
end;

    {StripFrom - Strip all characters in S from C}

procedure StripFrom(C:Char; var S:cString);
var temp   : cString;
    reslen : integer;
begin
     if (StrLen(S)>0) and (StrRScan(S,C)<>nil) then
     begin
          StrCopy(temp,StrRScan(S,C));
          reslen:=StrLen(S)-StrLen(temp);
          StrLCopy(temp,S,reslen);
          StrCopy(S,temp);
     end;
end;

    {StripTo - Strip all characters in S up to C}

procedure StripTo(C:Char; var S:cString);
var pos  : word;
    temp : cString;
begin
     if (StrScan(S,C)<>nil) then        {If we find C in S then}
     begin
          StrCopy(temp,StrScan(S,C));   {Get rest of string}
          StrCopy(S,temp);              {Put it in S}
     end;
end;

    {RemoveFirstChar - Remove the first character from S}

procedure RemoveFirstChar(var S:cString);
var temp : cString;
begin
     if StrLen(S)>1 then                {If data in string then}
     begin
          StrCopy(temp,S+1);            {Get string from second character}
          StrCopy(S,temp);              {Put string in S}
     end else
         if StrLen(S)=1 then
         begin
              S[0]:=#0;
         end;
end;

    {RemoveLeadingSpaces - Removes any spaces at the start of S}

procedure RemoveLeadingSpaces(var S:cString);
begin
     while S[0]=' ' do RemoveFirstChar(S);
end;

    {GetFirstWord - Gets first all letter word from S}

procedure GetFirstWord(S:cString;var out:cString);
var n    : integer;
    temp : array[0..255] of char;
begin
     RemoveLeadingSpaces(S);            {Find start of word}
     n:=0;
     FillChar(temp,SizeOf(temp),#0);    
     while IsLetter(S[n]) do            {While still letters do}
     begin
          temp[n]:=S[n];                {Copy character}
          inc(n);
     end;
     StrCopy(out,temp);                 {Out set to word}
end;

    {GetFirstBlock - Gets the first block of text (letters & symbols) from S}

procedure GetFirstBlock(S:cString;var out:cString);
var n,a     : integer;
    temp    : array[0..255] of char;
    isspace : boolean;
begin
     IsSpace:=false;
     RemoveLeadingSpaces(S);
     if s[0]<>#0 then
     begin
          n:=0;
          repeat
                IsSpace:=s[n]=' ';
                inc(n);
          until IsSpace or (n=StrLen(s));
          FillChar(temp,SizeOf(temp),#0);
          if IsSpace then n:=Pred(n);
          for a:=0 to Pred(n) do temp[a]:=s[a];
          StrCopy(out,temp);
     end else
         BlankString(out);
end;


    {RemoveFirstWord - Removes first word from S}

procedure RemoveFirstWord(var S:cString);
begin
     RemoveLeadingSpaces(S);            {Get to word}
     while IsLetter(S[0]) do RemoveFirstChar(S);
     RemoveLeadingSpaces(S);
end;

    {RemoveFirstWord - Removes first block of text from S}

procedure RemoveFirstBlock(var S:cString);
var temp : boolean;
    n    : integer;
begin
     RemoveLeadingSpaces(S);
     temp:=false;
     n:=0;
     repeat
           temp:=(s[n]=' ');
           inc(n);
     until temp or (pred(n)=StrLen(S));
     if temp then
        StripTo(' ',S)
     else
         StrCopy(S,#0);
     RemoveLeadingSpaces(S);
end;

    {AddChar - Adds character C to the end of S}

procedure AddChar(var S:cString; C:Char);
var temp : array[0..1] of char;
begin
     temp[0]:=c;
     temp[1]:=#0;
     StrCat(S,temp);
end;

end.