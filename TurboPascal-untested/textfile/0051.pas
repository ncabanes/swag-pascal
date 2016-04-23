{
From: russell@alpha3.ersys.edmonton.ab.ca (Russell Schulz)

>Can Someone tell me how the DOS program MORE works?

dos does the redirection part.  more just reads from stdin -- readln(s);

>I would really like to write a MORE replacement

there are already a bunch of good ones.  ask archie for `less'.

also, with this old code of mine, you can type `l80 filespec.*' or
`dir |l80' as well.  it keeps everything in the lower 640k.
}

program l80;  {less-like program, 80-char limitation}

uses
  dos,crt;

const
  maxlines=24;
  botlinelen=70;
  blankstring='                                                     ';

type
  ptr=^node;
  node=record
         line: string[79];
         next: ptr;
       end;

var
  infile: text;
  ch: char;
  filename: string;
  line: string;
  toplineno: longint;
  prevtoplineno: longint;
  done: boolean;
  head, tail, prev, curr: ptr;
  topline, botline: ptr;
  numlines: longint;
  rep: longint;
  userep: longint;
  searchstr: string;
  dosearch: boolean;
  atend: boolean;
  refresh: boolean;
  scrollno: integer;
  doscroll: boolean;
  newtoplineno: longint;
  msg: string;
  filespec: string;
  temp: integer;
  savepos: pointer;
  i: integer;
  fileinfo: searchrec;

procedure wipeline;

begin
  write(^M,blankstring,^M);
end;

function expand(str: string): string;

var
  work: string[79];
  i,j: integer;

begin
  if (pos(^I,str)=0) and (pos(^J,str)=0) and (pos('_',str)=0) then
    expand := str
  else
    begin
      work := '';
      i := 1;
      while i<=length(str) do
        begin
          if str[i]=^I then
            for j := 1 to 8-(length(work) and 7) do
              work := work+' '
          else
            if (length(str)>i) and (str[i] in ['_',^H,#127]) and
              (str[i+1] in ['_',^H,#127]) and not
              ((str[i]='_') and (str[i+1]='_')) then
              inc(i)
            else
              if str[i]<>^J then
                work := work+str[i];
         inc(i);
        end;
      expand := work;
    end;
end;

function pline(p: ptr): string;

begin
  if p=nil then
    pline := '~'
  else
    pline := p^.line;
end;

procedure add(var head,tail: ptr; line: string);

var
  n: ptr;

begin
  new(n);
  n^.line := expand(line);
  n^.next := nil;
  if head=nil then
    head := n;
  if tail<>nil then
    tail^.next := n;
  tail := n;
  inc(numlines);
end;

function lookup(aline: integer): ptr;

var
  curr: ptr;

begin
  if aline>=numlines then
    lookup := tail
  else if aline<1 then
    lookup := head
  else
    begin
      curr := head;
      while aline>1 do
        begin
          dec(aline);
          curr := curr^.next;
        end;
      lookup := curr;
    end;
end;

function gets(var line: string): boolean;

var
  tmp: integer;
  ch: char;
  valid: boolean;

begin
  valid := true;
  line := '';
  write(^M,'/');
  repeat
    ch := readkey;
    if ch=^I then ch := ' ';
    if ch<>^M then
      if (ch=^H) and (line='') then
        valid := false
      else if ch=^H then
        begin
          if length(line)=1 then line := ''
          else line := copy(line,1,length(line)-1);
          write(ch,' ',ch);
        end
      else if length(line)<botlinelen then
        begin
          line := line+ch;
          write(ch);
        end;
  until (ch=^M) or not valid;
  wipeline;
  gets := valid;
end;

function isin(shortstr,longstr: string): boolean;

begin
  isin := pos(shortstr,longstr)<>0;
end;

function searchf(var curr: ptr; var toplineno: longint): boolean;

var
  tmp: ptr;
  lin: longint;
  found: boolean;
  awrap: boolean;

begin
  found := false;
  awrap := false;
  prevtoplineno := toplineno;
  prev := curr;
  write('/');
  lin := toplineno;
  tmp := curr;
  if tmp<>nil then
    repeat
      if tmp^.next=nil then
        begin
          awrap := true;
          tmp := head;
          lin := 1;
        end
      else
        begin
          tmp := tmp^.next;
          inc(lin);
        end;
      if isin(searchstr,tmp^.line) then
        found := true;
    until found or (tmp=curr);
  if found then
    begin
      curr := tmp;
      toplineno := lin;
      scrollno := toplineno-prevtoplineno;
      if (scrollno>=0) and (scrollno<maxlines)
       and (prevtoplineno+scrollno<=numlines-maxlines+1) then
        begin
          curr := prev;
          toplineno := prevtoplineno;
          doscroll := true;
        end;
    end;
  if awrap then
    msg := '(wrap)';
  searchf := found;
  wipeline;
end;

procedure prtscreen(p: ptr);

var
  lineat: integer;

begin
  atend := false;
  lineat := 1;
  while lineat<=maxlines do
    begin
      inc(lineat);
      if p=nil then
        begin
          writeln('~');
          atend := true;
        end
      else
        begin
          writeln(pline(p));
          if lineat<=maxlines then
            p := p^.next;
        end;
    end;
  if (p=nil) or (p^.next=nil) then atend := true;
  botline := p;
end;

procedure scroll(scrollno: integer);

var
  lineat: integer;

begin
  atend := false;
  lineat := 1;
  while lineat<=scrollno do
    begin
      inc(lineat);
      if botline=nil then
        begin
          writeln('~');
          atend := true;
        end
      else
        begin
          botline := botline^.next;
          writeln(pline(botline));
        end;
      if topline<>nil then
        begin
          topline := topline^.next;
          inc(toplineno);
        end;
    end;
  if botline=nil then atend := true;
end;

function inrange(n: longint): longint;

begin
  if n<1 then inrange := 1
  else if n>numlines then inrange := numlines
  else inrange := n;
end;

procedure showfile(filename: string);

begin
  assign(infile,filename);
  {$I-}
  reset(infile);
  {$I+}
  if IOResult<>0 then
    begin
      writeln('error opening ''',filename,'''');
      halt;
    end;
  head := nil;
  tail := nil;
  numlines := 0;
  searchstr := '';
  msg := '';
  while not eof(infile) do
    begin
      readln(infile,line);
      add(head,tail,line);
    end;
  close(infile);
  toplineno := 1;
  done := false;
  topline := head;
  prev := nil;
  refresh := true;
  doscroll := false;
  while not done do
    begin
      if doscroll then
        scroll(scrollno)
      else if refresh then
        prtscreen(topline);
      refresh := true;
      doscroll := false;
      write(^M,'          ',msg);
      msg := '';
      if atend then
        write(^M,'--END--')
      else
        write(^M,'--L80--');
      rep := 0;
      prevtoplineno := toplineno;
      repeat
        repeat
          ch := readkey;
        until ch in [^M,'j','q',' ','G','0'..'9',^G,'b','u','/','n'];
        if (ch in ['0'..'9']) and (rep<maxlongint div 10) then
          rep := rep*10+ord(ch)-ord('0')
        else if ch=^G then
          begin
            wipeline;
            write('''',filename,''': ');
            newtoplineno := inrange(toplineno+maxlines);
            write('line ',newtoplineno:0,' of ',numlines:0,' ');
            if numlines=0 then
              write('--100%--')
            else
              write('--',100*newtoplineno div numlines:0,'%','--');
          end
        else
          begin
            wipeline;
            if rep=0 then
              userep := 1
            else
              userep := rep;
            case ch of
              'q': done := true;
              ' ':
                begin
                  newtoplineno := inrange(toplineno+maxlines*userep);
                  if newtoplineno=toplineno then
                    refresh := false
                  else
                    begin
                      topline := lookup(newtoplineno);
                      toplineno := newtoplineno;
                    end;
                end;
              ^M,'j':
                begin
                  newtoplineno := inrange(toplineno+userep);
                  if newtoplineno=toplineno then
                    refresh := false
                  else
                    if userep<maxlines then
                      begin
                        doscroll := true;
                        scrollno := userep;
                      end
                    else
                      begin
                        topline := lookup(newtoplineno);
                        toplineno := newtoplineno;
                      end;
                end;
              'G', 'b', 'u':
                begin
                  if ch='G' then
                    begin
                      newtoplineno := rep;
                      if (newtoplineno>numlines-maxlines)
                       or (newtoplineno<1) then
                        newtoplineno := numlines-maxlines+1;
                    end
                  else
                    newtoplineno := inrange(toplineno-maxlines*userep);
                  topline := lookup(newtoplineno);
                  toplineno := newtoplineno;
                end;
              '/', 'n':
                begin
                line := '';
                if (ch='n') or gets(line) then
                  begin
                    dosearch := true;
                    if line='' then
                      if searchstr='' then
                        begin
                          msg := 'no previous string';
                          dosearch := false;
                          refresh := false;
                        end;
                    if line<>'' then
                      searchstr := line;
                    if dosearch then
                      if not searchf(topline,toplineno) then
                        begin
                          msg := 'not found';
                          refresh := false;
                        end;
                  end;
                end;
              end;
          end;
      until ch in [^M, 'j', 'q', ' ', 'G', 'b', '/', 'n', 'u'];
    end;
end;

begin
  if paramcount>0 then
    if paramstr(1)='-?' then
      begin
        writeln('usage: l80 {filename}');
        halt;
      end;

  mark(savepos);

  if paramcount=0 then
    showfile('')
  else
    begin
      for i := 1 to paramcount do
        begin
          filespec := paramstr(i);
          findfirst(filespec,archive,fileinfo);
          temp:=length(filespec);
          repeat
            dec(temp);
          until (filespec[temp]='\') or (filespec[temp]=':') or (temp=1);
          if (pos('\',filespec)=0) and (pos(':',filespec)=0) then
            filespec:=''
          else
            filespec:=copy(filespec,1,temp);
          while doserror=0 do
            begin
              release(savepos);
              showfile(concat(filespec,fileinfo.name));
              findnext(fileinfo);
            end;
        end;
    end;
end.
