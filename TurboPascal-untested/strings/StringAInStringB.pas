(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0102.PAS
  Description: String A in String B
  Author: SWAG SUPPORT GROUP
  Date: 11-26-94  05:04
*)

{ Good'ol'times, when I could make my database programs in Clipper... Now I'm
stuck with TP...:) Well, anyway, I remember a small symbol, $, which, when
placed between two different strings checked if the first existed "in" the
second. That's what this does. Checks if A exists in B. Upper/Lower case
ignored (although it can be easily changed to take that into account).
Useful to search by text keywords in databases. Returns True if A exists in B,
false if it doesn't.
Portuguese freeware, by Luis Evaristo Fonseca, Thunderball Software 1994
}

{****************************************************************************}
function upstring(a:string):string;
var aux:string;
    i:integer;                          {converts a string to uppercase}
begin
  aux:='';
  for i := 1 to Length(a) do
  begin
      aux[0]:=chr(ord(aux[0])+1);
      aux[i]:=upcase(a[i]);
  end;
  upstring:=aux;
end;

{****************************************************************************}

function a_in_b(a,b:string):boolean;
var conta,conta2,conta3:integer;
    a1,b1:string;
    aux:boolean;
begin
    aux:=false;                         {tests if a is in b, returns true if}
    if length(a)<=length(b) then        {it is, false if it doesn't}
    begin
        a1:=upstring(a);
        b1:=upstring(b);
        for conta:=1 to length(b) do
        begin
            if b1[conta]=a1[1] then
            begin
                aux:=true;
                for conta2:=1 to length(a) do
                begin
                    if (a1[conta2]<>b1[conta2+conta-1]) then
                       aux:=false;
                end;
                if aux=true then
                    exit;
            end;
        end;
    end;
    a_in_b:=aux;
end;


