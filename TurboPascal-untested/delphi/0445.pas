
From: "Eric Lawrence" <deltagrp@keynetcorp.net>

>>How can I save an entire stringgrid with all cells to a file?

--------------------------------------------------------------------------------

Procedure SaveGrid;
var f:textfile;
x,y:integer;
begin
assignfile (f,'Filename');
rewrite (f);
writeln (f,stringgrid.colcount);
writeln (f,stringgrid.rowcount);
For X:=0 to stringgrid.colcount-1 do
        For y:=0 to stringgrid.rowcount-1 do
writeln (F, stringgrid.cells[x,y]);
closefile (f);
end;

Procedure LoadGrid;
var f:textfile;
temp,x,y:integer;
tempstr:string;
begin
assignfile (f,'Filename');
reset (f);
readln (f,temp);
stringgrid.colcount:=temp;
readln (f,temp);
stringgrid.rowcount:=temp;
For X:=0 to stringgrid.colcount-1 do
        For y:=0 to stringgrid.rowcount-1 do begin
        readln (F, tempstr);
        stringgrid.cells[x,y]:=tempstr;
        end;
closefile (f);

