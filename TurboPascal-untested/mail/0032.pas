program sort_nodenumbers;
 
(* This is an example which sorts Fidonet node numbers. *)
(* The routine is very slow and basic, but it works. *)
 
(* Made in January/1996 by Teemu Kiviniemi, 2:229/222@fidonet.org *)
 
type node=record
  zone,net,node:word;
 end;
 
const nodecount=1000;
 
var c:word;
 ready:boolean;
    temp:node;
    nodes:array[0..nodecount] of node;
 
procedure swap(var a,b:word);
var temp:word;
begin
 temp:=a;
    a:=b;
    b:=temp;
end;
 
procedure printnumbers;
var b:word;
begin
 for b:=0 to nodecount do
     writeln(nodes[b].zone,':',nodes[b].net,'/',nodes[b].node);
end;
 
begin
    randomize;
    for c:=0 to nodecount do
     begin
         nodes[c].zone:=random(6)+1;
            nodes[c].net:=random(998)+1;
            nodes[c].node:=random(998)+1;
        end;
    writeln('Before sorting:');
    printnumbers;
    { Sort the zones }
    writeln('Zones...');
 repeat
     ready:=true;
        for c:=0 to nodecount-1 do
        if nodes[c].zone> nodes[c+1].zone then
                begin
     swap(nodes[c].zone,nodes[c+1].zone);
                    ready:=false;
                end;
    until ready;
    { Sort the nets }
 writeln('Nets...');
 repeat
     ready:=true;
        for c:=0 to nodecount-1 do
        if (nodes[c].net> nodes[c+1].net) and
      (nodes[c].zone=nodes[c+1].zone) then
                begin
     swap(nodes[c].net,nodes[c+1].net);
                    ready:=false;
                end;
    until ready;
    { Sort the nodes }
    writeln('Nodes...');
 repeat
     ready:=true;
        for c:=0 to nodecount-1 do
        if (nodes[c].node> nodes[c+1].node) and
      (nodes[c].net=nodes[c+1].net) and
      (nodes[c].zone=nodes[c+1].zone) then
                begin
     swap(nodes[c].node,nodes[c+1].node);
                    ready:=false;
                end;
    until ready;
    writeln(#13,#10,'After sorting:');
    printnumbers;
end. === End SORTNODE.PAS ===
 
