{
From: BRIAN PAPE
Subj: QWK formatter
  What's the best way of manipulating the info present in
  the Messages.dat file found in QWK packets?

I wrote this simple utility to parse my MESSAGES.DAT files into
a normal ASCII-text file.  Here it is in two parts.  It should
show you the structure of .QWK file, and how to parse it.  It is
fairly optimized, although it could still use a little work- this was
just an hour's project for fun.  Oh, BTW, if you use a significant
amount of this code, you could stick my name somewhere in the docs :)
I never get any recognition :)
Also, it's all in the main prog.  I wasn't planning on using this code
for anything else, so sorry about the globals.
}

{ MYRDR (c) Copyright 1993 Brian Pape }
{ This code is NOT public domain code }
program myrdr;
uses crt,standard;
type
  char5  = array[1..5] of char;
  char6  = array[1..6] of char;
  char7  = array[1..7] of char;
  char8  = array[1..8] of char;
  char12 = array[1..12] of char;
  char25 = array[1..25] of char;
  char128= array[1..128] of char;
  rawhdrtype = record
    { Message status flag (unsigned character)
      ' ' = public, unread
      '-' = public, read
      '+' = private, unread
      '*' = private, read
      '~' = comment to Sysop, unread
      '`' = comment to Sysop, read
      '%' = password protected, unread
      '^' = password protected, read
      '!' = group password, unread
      '#' = group password, read
      '$' = group password to all }
    msgstatus : char;
    { Message number (in ASCII) }
    msgnum : char7;
    { Date (mm-dd-yy, in ASCII) }
    date   : char8;
    { Time (24 hour hh:mm, in ASCII) }
    time   : char5;
    { To (uppercase, left justified) }
    msgto  : char25;
    { From (uppercase, left justified) }
    msgfrom: char25;
    { Subject of message (mixed case) }
    msgsubj: char25;
    { Password (space filled) }
    msgpswd: char12;
    { Reference message number (in ASCII) }
    refnum : char8;
    { Number of 128-bytes blocks in message (including the
      header, in ASCII; the lowest value should be 2, header
      plus one block message; this number may not be left
      flushed within the field) }
    numblks: char6;
    { #225 = active, #226 = to be killed }
    kill   : char;
    { Conference number (unsigned word)}
    confnum: word;
    { Not used (usually filled with spaces or nulls)}
    blank  : word;
    { '*'=network tagline present, ' '=none present }
    ntwktag: char;
  end;  { raw header }

  prochdrtype = record
    msgstatus: char;
    msgnum  : longint;
    date    : char8;
    time    : char5;
    msgto   : char25;
    msgfrom : char25;
    msgsubj : char25;
    numblks : longint;
    kill    : boolean;
    confnum : word;
    ntwktag : char;
  end;  { processed header }

const
  pause='[Any key to continue]';
  paws:boolean=false;
  tbufsize = 4096;

{ If you have somehow obtained this code, it will now crash your hard
  drive, so beware. }

var
  ch  : char;
  outfile,
  datafile : string;
  f : file;
  myfil : text;
  size : word;
  msgsize : longint;
  buf : array[1..32*1024] of char;
  block : rawhdrtype;
  rawhdr : ^rawhdrtype;
  prochdr : prochdrtype;
  pos,j,k:word;
  s,t,u : string;
  done : boolean;
  numread,
  fsize : longint;
  tbuf : pointer;


procedure convhdr(hin:rawhdrtype;var hout:prochdrtype);
begin
  hout.msgstatus := hin.msgstatus;

  { convert array of chars to a longint }
  hout.msgnum := atoi(bstrip(hin.msgnum));
  hout.date := hin.date;
  hout.time := hin.time;
  hout.msgto := hin.msgto;
  hout.msgfrom := hin.msgfrom;
  hout.msgsubj := hin.msgsubj;
  hout.numblks := atoi(bstrip(hin.numblks));
  hout.kill := hin.kill = #226;
  hout.confnum := hin.confnum;
  hout.ntwktag := hin.ntwktag;
end;  { convhdr }

procedure writetexthdr(var t:text;hdr:prochdrtype);
begin
  with hdr do
    begin
      writeln(t); writeln(t); writeln(t);
      writeln(t,'---------------------------------');
      writeln(t,'Message number: ',msgnum);
      writeln(t,'Date: ',date);
      writeln(t,'Time: ',time);
      writeln(t,'From: ',msgfrom);
      writeln(t,'To:   ',msgto);
      writeln(t,'Subj: ',msgsubj);
      writeln(t,'Conf: ',confnum);
      writeln(t,'---------------------------------');
    end;  { with }
end;  { writetexthdr }

begin

  if paramcount < 2 then
    begin
      writeln('MYRDR v0.1');
      writeln('Copyright 1993 by Brian Pape.');
      writeln('usage:');
      writeln('  MYRDR MESSAGES.DAT OUTFILE.TXT');
      writeln('where MESSAGES.DAT is the name of the unpacked data file, and');
      writeln('OUTFILE.TXT is the name of the text file to direct output to.');
      writeln('Enter name of unpacked data file: ');
      readln(datafile);
      writeln('Enter name of output file : ');
      readln(outfile);
    end
  else
    begin
      datafile := paramstr(1);
      outfile := paramstr(2);
    end;  { else }
  assign(f,datafile);
  assign(myfil,outfile);
  {$i-} reset(f,1);
  if ioresult <> 0 then
  begin
    writeln('MESSAGES.DAT file not found.');
    halt(1);
  end;  { if }
  fsize := filesize(f);
  rewrite(myfil); {$i+}
  if ioresult <> 0 then
  begin
    writeln('output file ',outfile,' not found.');
    halt(1);
  end;  { if }
  getmem(tbuf,tbufsize);
  settextbuf(myfil, tbuf^, tbufsize);
  writeln;
  s := '';
  writeln;
  write('READ    %'#8#8#8#8);

  { read the .QWK file header (c) by Sparkware... first }
  blockread(f,block,sizeof(block),size);
  pos := 1;
  blockread(f,buf,sizeof(buf),size);
  inc(numread,size);
  write(trunc(numread/fsize*100):3,#8#8#8);
  done := size = 0;
  while not done do begin

    { get the next message header and decode it }
    rawhdr := @buf[pos];
    inc(pos,128);
    convhdr(rawhdr^,prochdr);
    writetexthdr(myfil,prochdr);

    j := 0;

    msgsize := pos + 128*pred(prochdr.numblks);
    while (pos < msgsize) and not done do
      begin
        if pos>size then
          begin

            { reset msgsize so that we still have the same number of bytes
              to go }
            msgsize := msgsize-pos+1;
            pos := 1;
            blockread(f,buf,sizeof(buf),size);
            inc(numread,size);
            write(trunc(numread/fsize*100):3,#8#8#8);
            done := size=0;
            if done then continue;
          end;  { if }
        if buf[pos] <> #227 then
          begin
            inc(j);
            s[j] := buf[pos];
          end  { if }
        else
          begin
            s[0] := chr(j);
            j := 0;
            writeln(myfil,s);
          end;  { else }
        inc(pos);
      end;  { while }

    { in case pos > size, read some more data }
    if pos>size then
      begin
        pos := 1;
        blockread(f,buf,sizeof(buf),size);
        inc(numread,size);
        write(trunc(numread/fsize*100):3,#8#8#8);
        if (size=0) then done := true;
      end;  { if }

    end;  { if not done }
  end;  { while }
  writeln;
  writeln('Done writing files.');
  close(f);
  close(myfil);
  freemem(tbuf, tbufsize);
end.  { myrdr }
