
From: ksudar@erols.com

>Does anyone know how to carry out a word count for the delphi richedit
>component ??
Someone posted this a few weeks ago.. I tried it and it seems to work.

--------------------------------------------------------------------------------

function GetWord: boolean;
var s: string; {presume no word>255 chars}
     c: char;
begin
result:= false;
s:= ' ';
while not eof(f) do
        begin
        read(f, c);
        if not (c in ['a'..'z','A'..'Z'{,... etcetera}]) then break;
        s:=s+c;
        end;
result:= (s<>' ');
end;
procedure GetWordCount(TextFile: string);
begin
        Count:= 0;
        assignfile(f, TextFile);
        reset(f);
        while not eof(f) do if GetWord then inc(Count);
        closefile(f);
end;
