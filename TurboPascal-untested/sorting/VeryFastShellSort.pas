(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0052.PAS
  Description: Very FAST Shell Sort
  Author: IAN LIN
  Date: 11-26-94  05:06
*)

{$A+,B-,D+,E-,F-,G+,I-,L+,N-,O-,R+,S+,V-,X+,M 4096,0,655360
NSORT version 3. Uses Shell sort instead of Insertion sort. Damn fast, still
handles all that can fit into conventional memory.
}

uses dos;

type
 pstring=^string;
 prec=^rec;
 rec=record
  s:pstring;
  n:prec;
 end;

const
 rsize=sizeof(rec);

var
 linet,linec:longint; {line total, current}
 list,start,lstptr,next:prec;
 {list,
  start of sorting zone,
  list stroller,
  next item to be swapped}
 infile,outfile,tmpline:string; {file names, input line}
 textf:text; {input/output file variable}
 tbuf:array [1..8192] of char; {text file buffer}

procedure progress;
var
 ctr,indicator:byte; {show graphically, how many blocks}
begin
 inc(linec); {increase current line}
 indicator:=100*linec div linet; {get %}
 write(indicator:5,'%  ');
 indicator:=indicator div 5; {get 1/20th portion}
 for ctr:=1 to 20 do
  if ctr<=indicator then write('o') {o=5% done, .=5% remaining}
  else write('.');
 write(^m); {only carriage return: not new line too}
end;

procedure TheEnd; far;
begin
 exitproc:=nil;
 case exitcode of
  1:writeln('Input file not found');
  2:writeln('Can''t open input file');
  3:writeln('Out of memory');
  4:writeln('Can''t create output file');
  5:writeln('Can''t finish output file');
  6:writeln('Insufficient disk space');
 end;
 writeln('NSort version 3.');
 writeln('NetRunner of Assassin Technologies. Lum''s Place 613 531 1911');
end;

procedure checkfit;
var
 f:file;
 size:longint;
 drive:string[1];
begin
 if infile<>outfile then begin
  assign(f,infile);
  reset(f,1);
  size:=filesize(f);
  drive:=fexpand(outfile);
  dec(drive[1],byte('A')-1);
  if size>diskfree(byte(drive[1])) then halt(6);
 end;
end;

procedure showhelp;
begin
 writeln('Heavy duty sorter. Syntax: NSORT infile outfile | /s');
 writeln('/s= use input name as output.');
 writeln('Batch file exit codes:');
 writeln('1 Input file not found');
 writeln('2 Can''t open input file');
 writeln('3 Out of memory');
 writeln('4 Can''t create output file');
 writeln('5 Can''t finish output file');
 writeln('6 Insufficient disk space');
 halt;
end;

procedure swap(var p1,p2:pstring);
var tmpptr:pstring;
begin
 tmpptr:=p1;
 p1:=p2;
 p2:=tmpptr;
end;

Function upstr(s:string):string;
var c:byte;
begin
 if length(s)>0 then for c:=1 to length(s) do s[c]:=upcase(s[c]);
 upstr:=s;
end;

Function fexist(fn:pathstr):boolean;
var f:file; it:word;
begin
 assign(f,fn);
 getfattr(f,it);
 fexist:=doserror=0;
 doserror:=0;
end;

function malloc(var p; ram:word):boolean;
begin
 if (maxavail>=ram) then begin
  if ram=0 then pointer(p):=nil {0 is OK but not an allocation}
  else getmem(pointer(p),ram); {allocate if RAM > 0}
  malloc:=true
 end
 else begin {not enough RAM}
  malloc:=false;
  pointer(p):=nil
 end
end;

begin
 exitproc:=@TheEnd; {set exit procedure}
 linec:=0; {init}
 linet:=0;

 if paramcount=0 then showhelp; {show online help, no cmd line}

 {set input/output files}

 infile:=upstr(paramstr(1));
 outfile:=upstr(paramstr(2));
 if outfile='/S' then outfile:=infile; {/s as output file = same name}

 if not fexist(infile) then halt(1); {stop if input doesn't exist}

 checkfit; {if output file too large/not enough space, this finds it}

 assign(textf,infile); {set input file}
 settextbuf(textf,tbuf); {set text buffer for speed}

 reset(textf);
 if ioresult<>0 then halt(2); {stop if error opening file}

 list:=nil;

 {input file processing}

 while not eof(textf) do begin
  readln(textf,tmpline); {get input}
  inc(linet); {total line count, setup in loop}
  if list=nil then begin {if list doesn't exist yet}
   if not malloc(pointer(list),rsize) then halt(3); {allocate linked list rec}
   next:=list; {next used to advance linked list}
  end
  else begin {current piece of list is not 1st}
   if not malloc(pointer(next^.n),rsize) then halt(3); {alloc linked list node}
   next:=next^.n; {advance placeholder}
  end;
  if not malloc(pointer(next^.s),length(tmpline)+1) then halt(3); {allocate
line}  move(tmpline,next^.s^,length(tmpline)+1);
  next^.n:=nil; {set list end = nil}
 end;
 close(textf); {close input file}

 {sorting begins here}

 start:=list;
 while start<>nil do begin
  next:=start;
  lstptr:=start;
  while lstptr<>nil do begin
   if lstptr^.s^ < next^.s^ then next:=lstptr;
   lstptr:=lstptr^.n; {advance list pointer}
  end;
  swap(start^.s,next^.s);
  progress;
  start:=start^.n; {advance start zone boundary, gradual reduction}
 end;
 writeln;

 {file output after complete sorting}

 lstptr:=list;
 assign(textf,outfile);
 rewrite(textf);
 if ioresult<>0 then halt(4);
 while lstptr<>nil do begin
  writeln(textf,lstptr^.s^);
  if ioresult<>0 then begin
   close(textf);
   halt(5);
  end;
  lstptr:=lstptr^.n;
 end;
 close(textf);
end.

