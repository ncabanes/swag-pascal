program MSGNUM;
uses dos,crt;
const version='v1.5';
var sto,
    sfrom,
    daystosave,
    top,
    bottom,
    mtop,
    mbottom,
    keep      :word;
    drv       :byte;
    st,
    path      :string;
    msg,
    save      :array[1..10240] of boolean;
    date      :array[1..10240] of word;

Function CurrentDrive:char;
var pthstr:pathstr;
begin
   pthstr:=fexpand('');
   CurrentDrive:=pthstr[1];
end;

function mchr(n:byte;ch:char):string;
var a:byte;s:string;
begin
  s:='';
  for a:=1 to n do s:=s+ch;
  mchr:=s;
end;

function FDayOfYear(l:longint):word;
var t:datetime;
begin
   unpacktime(l,t);
   t.month:=t.month-1;
   FDayOfYear:=((t.year-1990)*365)
   + (t.year-1988 div 4)
   + (t.month*30) + t.day
   + (  ord(t.month>=1))
   - (2*ord(t.month>=2))
   + (  ord(t.month>=3))
   + (  ord(t.month>=5))
   + (  ord(t.month>=7))
   + (  ord(t.month>=8))
   + (  ord(t.month>=10));
end;

Function TodaysDate:word;
var y,m,d,temp:word;dt:datetime;l:longint;
begin
      getdate(y,m,d,temp);
      dt.year:=y;
      dt.month:=m;
      dt.day:=d;
      packtime(dt,l);
      todaysdate:=fdayofyear(l);
end;

procedure initvars;
var a:word;
begin
   sto:=1;
   sfrom:=1;
   daystosave:=2;
   keep:=100;
   bottom:=1;
   mbottom:=1;
   mtop:=1;
   top:=1;
   path:='';
   for a:=1 to 10240 do
   begin
      msg[a]:=FALSE;
      save[a]:=FALSE;
      date[a]:=0;
   end;
end;

procedure getparams;
var a,b,code:word;parama,temp:string;past:boolean;
begin
   If (paramcount<1) or (paramstr(1)='?') then
   begin
      writeln;
      writeln(' MSGNUM ',version,' -  A Message base renumbering system for
FIDOnet and compatible');      writeln(' message systems.  This is a brute
force handler that is s-l-o-w. But it');      writeln(' uses file handlers
instead of FCBs like RENUM, so is safer. Syntax:');      writeln;
      writeln('    MSGNUM  [switches] [path]');
      writeln;
      writeln(' Switches:');
      writeln;
      writeln('    /Sxx-yy    Save messages xx to yy - keeps those messages
exactly as');      writeln('               they were before, and does NOT
renumber THEM');      writeln('    /Dxx       Messages less than xx days old
will be saved even if they');      writeln('               exceed the /L
paramater');      writeln('    /Kxx       Keeps xx messages in the base, even
if they are older than the');      writeln('               number of days
specified in the /D paramater.');      writeln;
      writeln(' Path MUST be specified.  The path refers to the subdir of the
base to be');      writeln(' renumbered.');
      writeln;
      writeln(' Default is:  MSGNUM /S1-1 /D2 /K100 [path]');
      halt;
   end
   else
   begin
      for a:=1 to paramcount do
      begin
         parama:=paramstr(a);
         If parama[1]='/' then
         begin
            Case upcase(parama[2]) of
            'S':begin
                   past:=FALSE;
                   temp:='';
                   for b:=3 to length(parama) do
                   begin
                      If parama[b]='-' then
                      begin
                         past:=TRUE;
                         val(temp,sfrom,code);
                         temp:='';
                      end
                      else
                      begin
                         temp:=temp+parama[b];
                      end;
                   end;
                   val(temp,sto,code);
                end;
            'D':begin
                   temp:='';
                   for b:=3 to length(parama) do
                   begin
                      temp:=temp+parama[b];
                   end;
                   val(temp,daystosave,code);
                end;
            'K':begin
                   temp:='';
                   for b:=3 to length(parama) do
                   begin
                      temp:=temp+parama[b];
                   end;
                   val(temp,keep,code);
                end;
            end;
         end
         else
         begin
            If path='' then
               for b:=1 to length(parama) do path:=path+parama[b];
            If path[length(path)]<>'\' then path:=path+'\';
            path:=fexpand(path);
         end;
      end;
   end;
end;

procedure readfilesin;
var s:searchrec;
    tempword:word;
    tempint:integer;
begin
   Findfirst(path+'*.msg',AnyFile,s);
   While DosError=0 do
   begin
      val(copy(s.name,1,length(s.name)-4),tempword,tempint);
      msg[tempword]:=TRUE;
      save[tempword]:=(tempword>=sfrom) and (tempword<=sto);
      date[tempword]:=FDayOfYear(s.time);
      If tempword<bottom then bottom:=tempword;
      If tempword>top then top:=tempword;
      Findnext(s);
   end;
end;

procedure findkeep;
var count:word;td:word;
begin
   count:=1;
   mtop:=top;
   mbottom:=top+1;
   td:=todaysdate;
   repeat
      dec(mbottom);
      If (msg[mbottom]) and (not save[mbottom]) and (mbottom>bottom) then
         inc(count);
   until ((count>=keep) and (date[mbottom]+daystosave<=td)) or
(mbottom<=bottom);end;

procedure deleteunwanted;
var a,
    todayyear,
    y,
    m,
    d,
    temp    :word;
    tempstr :string[12];
    f       :file;
begin
   Write('Erasing  No Files!  ');
   for a:=1 to (mbottom-1) do
   begin
      If (msg[a]) and (not save[a]) then
      begin
         str(a,tempstr);
         tempstr:=tempstr+'.MSG';
         assign(f,tempstr);
         Write(mchr(12,#8),mchr(12-length(tempstr),#32)+tempstr);
         erase(f);
         msg[a]:=FALSE;
      end;
   end;
   Writeln(mchr(70-wherex,#32),' ...Done.');
end;

procedure renameexisting;
var a,count:word;
    tempstr,countstr:string[12];
    f:file;
begin
   a:=mbottom;
   count:=0;
   Write('Renaming '+mchr(28,#32));
   repeat
      If (msg[a]) and (not save[a]) then
      begin
         tempstr:='';
         str(a,tempstr);
         tempstr:=tempstr+'.MSG';
         assign(f,tempstr);
         inc(count);
         while save[count] do inc(count);
         str(count,countstr);
         countstr:=countstr+'.MSG';
         Write(mchr(28,#8),tempstr,' to
',countstr,mchr(24-length(tempstr)-length(countstr),#32));         If
(countstr<>tempstr) then rename(f,countstr);      end;
      inc(a);
   until a>top;
   writeln(mchr(70-wherex,#32),' ...Done.');
end;

begin
   initvars;
   getparams;
   getdir(0,st);
   chdir(copy(path,1,length(path)-1));
   writeln(' Renumbering directory '+copy(path,1,length(path)-1));
   readfilesin;
   findkeep;
   write(' Deleting Unwanted files.... ');
   deleteunwanted;
   write(' Renaming Remaining files... ');
   renameexisting;
   chdir(st);
end.
