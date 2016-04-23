{
 MH> the output something like "12,345,678,910"
 KH>                            ^^^^12 Gigs huh?
 MH> Would anyone be able to tell me how to format the output like that?
 KH>
 KH> The only way I can think of is writing a procedure to do so. It's a
 KH> real  pain in the *ss if you know what I mean. I had to write a program
}
type
 st14=string[14];
Function Commas(n:longint):st14;
var
 stopat, {stop bound at left of string}
 npos:byte; {numeric position in string}
 tmp:st14; {temporary}
begin
 str(n,tmp); {convert to string}
 npos:=length(tmp); {set length for counter}
 if tmp[1]='-' then stopat:=2 else stopat:=1; {set stop bound, compensate
                                              for negatives}
 while npos>stopat do begin {while commas needed}
  {insert a comma if needed}
  if (length(tmp)-npos=2) or (pos(',',tmp)-npos=3)
   then insert(',',tmp,npos);
  dec(npos); {always decrease string position until StopAt bound reached}
 end;
 commas:=tmp; {result=temporary string}
end;
