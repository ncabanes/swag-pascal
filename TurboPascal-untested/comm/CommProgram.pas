(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0088.PAS
  Description: Comm Program
  Author: RUSSELL SCHULZ
  Date: 05-26-95  23:31
*)

{
From: russell@alpha3.ersys.edmonton.ab.ca (Russell Schulz)

using my tpserio from simtel and genericf from rnr123 on simtel:
}

program uushell;  { accept a login and shell to uucico }

{
Russell Schulz - russell@alpha3.ersys.edmonton.ab.ca (940423)

Copyright 1994 Russell Schulz

this code is not in the Public Domain

permission is granted to use these routines in any application regardless
of commercial status as long as the author of these routines assumes no
liability for any damages whatsoever for any reason.  have fun.
}

{$M 16384,65536,65536}

{$define consoleoverride}
{$undef consoleoverride}

{$define autoanswer}
{$undef autoanswer}

uses dos,crt,genericf;

const
  version='v0.2';
  defaultidpwfn='c:\etc\idpw';
  defaultmsg='Authorized use only -- all others disconnect now';
  defaultuucicocmd='uucico.exe';
  defaultuucicoparams='-r_0_-u%A';

var
  console: boolean;
  port: integer;
  shadow: integer;
  eightbitclean: boolean;
  highcolor: integer;
  lowcolor: integer;
  readlnecho: boolean;
  idleminutes: integer;
  minstart: integer;
  minlastinput: integer;
  minutestorun: integer;
  didtimeout: boolean;

  speed: longint;
  delaytime: integer;

  idpwfn: string;
  msg: string;
  msgfn: string;

  uucicocmd: string;
  uucicoparams: string;

  verbose: boolean;

{$undef debug}
{$define debug}

{$undef timeout}
{$define timeout}

{$undef timeoutreturnscr}
{$define timeoutreturnscr}

{$i serio.pas}

procedure usage;

begin
  writeln('uushell [-?] [-p port] [-s speed] [-d delaytime]');
  writeln('  [-f file] [-m messagefile] [-c command] [-a arguments]');
  writeln('  [-v]');
  writeln;
  writeln('  -p 0=COM1, 1=COM2');
  writeln('  -s 2400=2400, 9600=9600');
  writeln('  -d delay delaytime/1000 seconds');
  writeln('  -f file of id-space-password, one set per line');
  writeln('  -m first line of this file will be shown to callers');
  writeln('  -c command (default: ',defaultuucicocmd,')');
  writeln('     the extension is necessary.  if no path is given,');
  writeln('     the PATH environment variable will be searched');
  writeln('  -a arguments (default: ',defaultuucicoparams,')');
  writeln('     underscores (_) will be changed to spaces');
  writeln('     %A will be changed to the id');
  writeln('  -v verbose');
  writeln;
  writeln('russell@alpha3.ersys.edmonton.ab.ca (941106)');
  halt(1);
end;

procedure execp(cmd,cmdline: string);

var
  path: string;
  success: boolean;
  ncmd: string;
  nbase: string;
  npath: string;
  el: string;
  at: integer;

function indir(cmd,dir: string): boolean;

var
  fileinfo: searchrec;

begin
  findfirst(dir+'\'+cmd,archive,fileinfo);
  indir := (doserror=0);
end;

begin
  success := false;

  ncmd := crepl(cmd,'/','\');
  nbase := ncmd;

{strip path from nbase}

  repeat
    at := pos(':',nbase);
    if at<>0 then
      nbase := copy(nbase,at+1,255);
  until at=0;

  repeat
    at := pos('\',nbase);
    if at<>0 then
      nbase := copy(nbase,at+1,255);
  until at=0;

{chop off path.  if trailing \, chop, unless root or drive:root (then add .)}

  npath := '';
  if nbase<>ncmd then
    begin
      success := true;  {so as to not look further than given path}
      npath := copy(ncmd,1,length(ncmd)-length(nbase));
      if npath='\' then
        npath := npath+'.';
      if pos(':\',npath)<>0 then
        if copy(npath,length(npath)-1,2)=':\' then
          npath := npath+'.';
      if copy(npath,length(npath),1)='\' then
        npath := copy(npath,1,length(npath)-1);
    end;

{if an explicit path, use it -- otherwise, just try '.'}

  if npath='' then
    npath := '.';

{if no extension, try com then exe}

  if pos('.',nbase)=0 then
    begin
      if indir(nbase+'.com',npath) then
        begin
          success := true;
          exec(npath+'\'+nbase+'.com',cmdline);
        end
      else if indir(nbase+'.exe',npath) then
        begin
          success := true;
          exec(npath+'\'+nbase+'.exe',cmdline);
        end
    end
  else if indir(nbase,npath) then
    begin
      success := true;
      exec(npath+'\'+nbase,cmdline);
    end;

  if not success then
    begin

{not found in explicit path (or ., if no explicit path).  try $PATH}

      path := getenv('PATH');
      while not success and (path<>'') do
        begin
          if copy(path,length(path),255)<>';' then
            path := path+';';
          at := pos(';',path);
          el := copy(path,1,at-1);
          path := copy(path,at+1,255);
          if pos('.',nbase)=0 then
            begin
              if indir(nbase+'.com',el) then
                begin
                  success := true;
                  exec(el+'\'+nbase+'.com',cmdline);
                end
              else if indir(nbase+'.exe',el) then
                begin
                  success := true;
                  exec(el+'\'+nbase+'.exe',cmdline);
                end;
            end
          else
            begin
              if indir(nbase,el) then
                begin
                  success := true;
                  exec(el+'\'+nbase,cmdline);
                end;
            end;
        end;
    end;
end;

procedure sendch(c: char);

begin
  xwrites(c);
  if xkeypressed then
    write(xreadkey);
  if xkeypressed then
    write(xreadkey);
  if xkeypressed then
    write(xreadkey);
  if xkeypressed then
    write(xreadkey);
  if xkeypressed then
    write(xreadkey);
  delay(50);
end;

procedure outstrnocr(s: string);

var
  i: integer;
  echo: string;
  anecho: boolean;

begin
  if verbose then
    begin
      writeln('writing: ',s);
      writeln;
    end;

  echo := '';
  for i := 1 to length(s) do
    begin
      xwrites(s[i]);

      if s[i]<>#13 then
        delay(4*delaytime);

      delay(delaytime);
      repeat
        anecho := xkeypressed;
        if anecho then
          echo := echo+xreadkey;
        delay(delaytime);
      until not anecho;
    end;

  if verbose then
    if echo<>'' then
      writeln('echo: ',echo);
end;

procedure outstr(s: string);

begin
  outstrnocr(s+#13);
end;

procedure initmsg;

var
  msgf: text;

begin
  msg := defaultmsg;

  if msgfn<>'' then
    begin
      assign(msgf,msgfn);
      {$I-}
      reset(msgf);
      {$I+}
      if ioresult<>0 then
        begin
          writeln('! could not open message file ',msgfn);
          writeln('! using default message');
        end
      else
        begin
          if not eof(msgf) then
            readln(msgf,msg);
          close(msgf);
        end;
    end;
end;

procedure initialize;

var
  i: integer;
  code: word;
  s: string;

begin
  speed := 2400;
  port := 0;
  delaytime := 500;
  idpwfn := defaultidpwfn;
  msgfn := '';
  uucicocmd := defaultuucicocmd;
  uucicoparams := defaultuucicoparams;
  verbose := false;

{$ifdef com2}
  port := 1;
{$endif}

  i := 1;
  while i<=paramcount do
    begin
      if paramstr(i)='-p' then
        begin
          inc(i);
          if i<=paramcount then
            val(paramstr(i),port,code)
          else
            usage;
        end
      else if paramstr(i)='-s' then
        begin
          inc(i);
          if i<=paramcount then
            val(paramstr(i),speed,code)
          else
            usage;
        end
      else if paramstr(i)='-d' then
        begin
          inc(i);
          if i<=paramcount then
            val(paramstr(i),delaytime,code)
          else
            usage;
        end
      else if paramstr(i)='-f' then
        begin
          inc(i);
          if i<=paramcount then
            idpwfn := paramstr(i)
          else
            usage;
        end
      else if paramstr(i)='-m' then
        begin
          inc(i);
          if i<=paramcount then
            msgfn := paramstr(i)
          else
            usage;
        end
      else if paramstr(i)='-c' then
        begin
          inc(i);
          if i<=paramcount then
            uucicocmd := paramstr(i)
          else
            usage;
        end
      else if paramstr(i)='-a' then
        begin
          inc(i);
          if i<=paramcount then
            uucicoparams := paramstr(i)
          else
            usage;
        end
      else if paramstr(i)='-v' then
        begin
          verbose := true;
        end
      else
        usage;
      inc(i);
    end;

  portengage;
  portspeed(speed);
  console := false;

  shadow := 0;

  if verbose then
    shadow := 1;

  outstr('ATV1E1');

  initmsg;
end;

procedure initmodem;

var
  s: string;

begin

  writeln('Initializing modem...');

  delay(1000);

  outstr('AT');
  outstr('ATZ');
  outstr('AT');

{$ifdef autoanswer}
  outstr('ATS0=1');
{$endif}

end;

procedure shutdown;

var
  s: string;

begin
  writeln('Restoring modem settings...');

  outstr('AT');
  outstr('AT');
  outstr('ATS0=0');
  outstr('AT');
  outstr('AT');

  portdisengage;
end;

procedure hangup;

begin
  delay(2000);
  outstrnocr('+++');
  delay(2000);

  outstr('AT');
  outstr('ATH');
end;

function verify(id,pw: string): boolean;

var
  result: boolean;
  s: string;
  idpwf: text;
  i: integer;

begin
  result := false;

  assign(idpwf,idpwfn);

{$I-}
  reset(idpwf);
{$I+}
  if ioresult<>0 then
    begin
      writeln('! could not open id+password file ',idpwfn);
      writeln('! no logins will succeed');
    end
  else
    begin
      while not eof(idpwf) do
        begin
          readln(idpwf,s);
          if chopfirstw(s)=id then
            if s=pw then
              result := true;
        end;
      close(idpwf);
    end;

  verify := result;
end;

function expandparams(oldparams: string; id: string): string;

var
  result: string;

begin
  result := ununderscore(oldparams);

  result := srepl(result,'%A',id);

  expandparams := result;
end;

procedure getlogin;

var
  expandedparams: string;
  id: string;
  pw: string;

begin
  console := false;
  shadow := 1;
  xwriteln;
  xwritelns('authorized use only.');
  xwriteln;
  xwrites('login: ');
  readlnecho := true;
  xreadlns(id,80,false);
  xwriteln;
  xwrites('password: ');
  readlnecho := false;
  xreadlns(pw,80,false);
  xwriteln;

  if verbose then
    writeln('id: ',id,' pw: ',pw);

  if not verify(id,pw) then
    begin
      xwriteln;
      xwritelns('sorry');
    end
  else
    begin
      writeln('disengaging communications port...');
      portdisengage;
      writeln('running uucico for ',id);
      expandedparams := expandparams(uucicoparams,id);
      writeln(uucicocmd,' ',expandedparams);
      execp(uucicocmd,expandedparams);
      writeln('engaging communications port...');
      portengage;
      portspeed(speed);
    end;

  if not verbose then
    shadow := 0;

end;

procedure getcalls;

var
  done: boolean;
  ch: char;
  str: string;
  currmitoday: integer;

begin
  write('Waiting for call...');
  currmitoday := mitoday;

  done := false;
  str := '';
  while not done do
    begin

      minlastinput := mitoday;

      if currmitoday<>mitoday then
        begin
          write('.');
          currmitoday := mitoday;
        end;

      console := true;
      if keypressed then
        begin
          ch := readkey;

          if verbose then
            writeln(ch);

          if ch='q' then
            begin
              done := true;
              writeln;
              writeln('Quit...');
            end
          else if ch='a' then
            begin
              write('Answering...');
              outstr('ATA');
            end
          else if ch='p' then
            begin
              write('Pausing...');
              ch := readkey;
              write('Waiting...');
            end
          else
            begin
              writeln;
              if (ord(ch)<32) or (ord(ch)>126) then
                writeln('unknown key ',ord(ch))
              else
                writeln('unknown key ',ch);
            end;
        end;

      console := false;
      if xkeypressed then
        begin
          ch := xreadkey;

          if verbose then
            writeln(ch);

          if (ch<>#13) and (ch<>#10) then
            str := str+ch
          else
            begin
              if verbose then
                writeln('got: ',str);

              if str='RING' then
                begin
                  write('Ring...');
{$ifndef autoanswer}
                  outstr('ATA');
{$endif}
                end;
              if copy(str,1,7)='CONNECT' then
                begin
                  writeln;
                  writeln('Connected at: ',str);
                  minlastinput := mitoday;
                  getlogin;
                  minlastinput := mitoday;
                  hangup;
                  initmodem;
                  write('Waiting for call...');
                end;
              str := '';
            end;
        end;
    end;

  writeln;
end;

begin
  writeln('uushell ',version);
  writeln;

  console := true;
  port := 0;
  shadow := 0;
  eightbitclean := true;
  highcolor := 0;
  lowcolor := 0;
  idleminutes := 2;
  minutestorun := -1;
  didtimeout := false;

  minstart := mitoday;
  minlastinput := minstart;

  initialize;
  initmodem;
  getcalls;
  shutdown;
end.

