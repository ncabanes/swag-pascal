(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0046.PAS
  Description: Handling teh PAC file format
  Author: TIM GORDON
  Date: 01-02-98  07:34
*)

Program Tpac; { TPAC v1.7 by Tim Gordon 18/06/97 }
{ Updated and Commented for September Computer Project  14/09/97 }
{ Updated for submission to SWAG 20/09/97 }

{----------------------------------------------------------------------------}
{- TPAC v1.7   Public Domain Release  By Tim Gordon -------------------------}
{----------------------------------------------------------------------------}

{ A Quick note on the PAC File format :-

 <- PAC File header/version ->
 <- 1st File header (Name/size) ->
 <- 1st File Contents - >
 <- 2nd File header ->
 ...

}

uses crt,dos;

type
    FileHeaderType = record { Header for individual files in PAC File }
                   Fname : string[12]; { name of file }
                   Fsize : longint; { size of file }
    end;

const
     PacHeader : string = 'TPAC'; { Pac File header }
     PacVersion : string = '1.7'; { Pac file version }

var
   extractfile : array[1..10] of string[12]; { List of file specs to extract }
   buf         : array[1..10240] of byte; { Input Buffer }
   Header      : string[4]; { PAC File Header }
   version     : string[3]; { PAC File Version }
   x           : integer; { Counter }
   Fileheader  : fileheadertype; { File Header }

procedure DrawPercentage(x1,y1 : integer;num : real);
{ Draw Percentage Complete as a Bar }
{ ▓▓▓▓░░░░░░░░ }
var
   yy,z    : integer;
   percentage : byte;
begin
     num := num / 100;
     percentage := round(num*11);
     { Work out percentage out of 11 }
     textbackground(black);
     textcolor(lightgray);
     gotoxy(x1,y1);
     write('(');
     for z := 1 to percentage do write('▓');
     for yy := percentage to 10 do write('░');
     { Draw up percentage }
     write(')');
end;

Procedure DisplayHelp;
{ Show Command Line Help }
begin
     writeln('Usage : ');
     writeln(' TPAC.EXE [pac_file] [option]... [filename]');
     writeln;
     writeln('Valid Options are :');
     writeln(' -a    Add Files');
     writeln(' -e    Extract Files');
     writeln(' -x    Extract Files (too)');
     writeln(' -l    View Files');
     writeln(' -?    This Help');
     halt; { Halt program }
end;

Function WildCardMatch(filename : string;Wildcard : string) : boolean;
{ Check if filename matches with wildcard - where wildcard can contain
  *'s and ?'s.
  Eg. timothy.tim = tim*.t?? = *t?y.*im = *.*
  and timothy.tim <> h*.??h
}
var
   MainPart       : string[8]; { Actual name of file - before the '.' }
   Extention      : string[3]; { last part of filename }
   x              : integer; { counter }
   Wild_MP        : string[8]; { Wildcard Main Part }
   Wild_Ex        : string[3]; { Wildcard Extention }
begin
     wildcardmatch := false; { Default }
     if wildcard = '' then exit; { Wont match if there isn't a filespec! }
     { First... Convert to caps! }
     for x := 1 to 12 do filename[x] := upcase(filename[x]);
     for x := 1 to 12 do wildcard[x] := upcase(wildcard[x]);
     { Check if our file names are complete }
     if pos('.',filename) = 0 then
        filename := filename + '.???';
     if pos('.',wildcard) = 0 then
        wildcard := wildcard + '.   ';
     { Now, Split our filename into its main part, and extention }
     mainpart := copy(filename,1,pos('.',filename)-1);
     extention := copy(filename,pos('.',filename)+1,3);
     wild_mp := copy(wildcard,1,pos('.',wildcard)-1);
     wild_ex := copy(wildcard,pos('.',wildcard)+1,3);
     { And Check that they are the right length }
     while length(mainpart) < 8 do
           mainpart := mainpart + ' ';
     while length(extention) < 3 do
           extention := extention + ' ';
     { Remeber - an asterisk fills a string out with ?s }
     if pos('*',wild_mp) = 0 then
      while length(wild_mp) < 8 do
       wild_mp := wild_mp + ' '
     else
      while length(wild_mp) < 8 do
       wild_mp := wild_mp + '?';
     if pos('*',wild_ex) = 0 then
      while length(wild_ex) < 3 do
       wild_ex := wild_ex + ' '
     else
      while length(wild_ex) < 3 do
       wild_ex := wild_ex + '?';
     { Now to organize our asterisks... }
     while pos('*',wild_mp) <> 0 do
      wild_mp[pos('*',wild_mp)] := '?';
     while pos('*',wild_ex) <> 0 do
      wild_ex[pos('*',wild_ex)] := '?';
     { Now we need to check if they are compatible :) }
     for x := 1 to 8 do
         if wild_mp[x] = '?' then
            wild_mp[x] := mainpart[x];
     for x := 1 to 3 do
         if wild_ex[x] = '?' then
            wild_ex[x] := extention[x];
     if (mainpart = wild_mp) and
        (extention = wild_ex) then
        wildcardmatch := true;
end;

Function CheckHeader(fname : string) : boolean;
{ Check if 'fname' is a valid PAC file }
var
   infile : file;
begin
     if fsearch(fname,getenv('name')) = '' then
     begin
          checkheader := false;
          exit;
     end;
     assign(infile,fname);
     reset(infile,1);
     blockread(infile,header,sizeof(header));
     blockread(infile,version,sizeof(version));
     close(infile);
     { Read in header/version }
     if (header = pacheader) and (version = pacversion) then
        checkheader := true
     else
         checkheader := false;
     { Validate }
     if (version <> pacversion) and (header = pacheader) then
     begin
          writeln('Version Mismatch!');
          writeln('Expected Version : ',pacversion);
          writeln('Version Received : ',version);
     end;
     { Show Error/wotever }
end;

Procedure Extractfiles(pacfilename : string);
var
   outfile : file; { Output File }
   pacfile : file; { .PAC File }
   extractit : boolean; { Used insead of ifs+elses }
   numread,
   numwrote  : word; { amount of file read/written }
   xpos,ypos : integer; { x/y positions on screen - for neatness }
begin
     extractit := false;
     writeln('Searching Archive : ',pacfilename);
     assign(pacfile,pacfilename);
     reset(pacfile,1);
     blockread(pacfile,header,sizeof(header));
     blockread(pacfile,version,sizeof(version));
     { Read header/version }
     if (header <> pacheader) or
        (version <> pacversion) then
     begin
          writeln('Major Stuff-up! : Header/version mismatch!');
          close(pacfile);
          halt;
     end;
     { validate header/version }
     repeat
           extractit := false;
           blockread(pacfile,fileheader,sizeof(fileheader));
           for x := 1 to 20 do
               if wildcardmatch(fileheader.fname,extractfile[x]) then
                  extractit := true;
           if extractit then
           begin
                writeln('Extracting: ',fileheader.fname:12,' ');
                xpos := wherex;
                ypos := wherey;
                assign(outfile,fileheader.fname);
                rewrite(outfile,1);
           end;
           if extractit then
           for x := 1 to fileheader.fsize div 10240 do
           begin
                blockread(pacfile,buf,sizeof(buf),numread);
                blockwrite(outfile,buf,numread,numwrote);
           end
           else
               seek(pacfile,filepos(pacfile)+fileheader.fsize);
           if extractit then
           begin
                blockread(pacfile,buf,(fileheader.fsize mod 10240),numread);
                blockwrite(outfile,buf,numread);
                close(outfile);
           end;
     until eof(pacfile);
     close(pacfile);
end;

procedure Addfiles(pacfilename : string);
var
   Infile : file;
   Pacfile : file;
   numread,
   numwrote  : word;
   DirInfo   : SearchRec;
   x,y       : integer;
   xpos,ypos : integer;
begin
     assign(pacfile,pacfilename);
     for x := 1 to length(pacfilename) do pacfilename[x] := upcasE(pacfilename[x]);
     if fsearch(pacfilename,getenv('name')) = '' then
     begin
          rewrite(pacfile,1);
          header := pacheader;
          version := pacversion;
          blockwrite(pacfile,header,sizeof(header));
          blockwrite(pacfile,version,sizeof(version));
          writeln('Creating PAC: ',pacfilename);
     end
     else
     begin
          writeln('Updating PAC: ',pacfilename);
          reset(pacfile,1);
          seek(pacfile,filesize(pacfile));
     end;
     FindFirst('*.*', Archive, DirInfo);
     while DosError = 0 do
     begin
          for x := 1 to 10 do
              if wildcardmatch(dirinfo.name,extractfile[x]) then
               if dirinfo.name <> pacfilename then
                 begin
                      x := 10;
                      assign(infile,dirinfo.name);
                      reset(infile,1);
                      fileheader.fname := dirinfo.name;
                      fileheader.fsize := filesize(infile);
                      blockwrite(pacfile,fileheader,sizeof(fileheader));
                      write('Adding: ',fileheader.fname:12,' ');
                      xpos := wherex;
                      ypos := wherey;
                      y := 0;
                      repeat
                                 drawpercentage(xpos,ypos,round(filepos(infile) / fileheader.fsize*100));
                                 {writeln(round(filepos(infile) / fileheader.fsize*100));}
                            blockread(infile,buf,sizeof(buf),numread);
                            blockwrite(pacfile,buf,numread,numwrote);
                            inc(Y);
                      until (numread <> numwrote) or (numread = 0);
                      gotoxy(xpos,ypos);
                      {write('[',filepos(infile) / fileheader.fsize*100:3:0,'%],Done.');}
                      writeln;
                      close(infile);
                 end;
          FindNext(DirInfo);
     end;
     close(pacfile);
end;

procedure ListFiles(pacfilename : string);
var
   pacfile : file;
   numread,
   numwrote : word;
   y         : integer;
   totalsize : longint;
   numfiles  : integer;
begin
     numfiles := 0;
     totalsize := 0;
     y := 1;
     writeln('Searching Archive : ',pacfilename);
     assign(pacfile,pacfilename);
     reset(pacfile,1);
     blockread(pacfile,header,sizeof(header));
     blockread(pacfile,version,sizeof(version));
     if (header <> pacheader) or
        (version <> pacversion) then
     begin
          writeln('Major Stuff-up! : Header/Version Mismatch!');
          close(pacfile);
          halt;
     end;
     writeln(' Filename                             Size');
     writeln('------------------------------------------');
     repeat
           inc(y);
           if y = 24 then
           begin
                write('Press any key to continue.');
                readln;
                y := 1;
           end;
           blockread(pacfile,fileheader,sizeof(fileheader));
           writeln(fileheader.fname:12,fileheader.fsize:24,' bytes');
           seek(pacfile,filepos(pacfile)+fileheader.fsize);
           inc(totalsize,fileheader.fsize);
           inc(numfiles);
           { Move past current file in pacfile, to next file header }
     until eof(pacfile);
     writeln('------------------------------------------');
     writeln(numfiles:12,' Files',totalsize:18,' bytes');
     close(pacfile);
end;

Procedure RunProgram;
var
   PacFileName : string;
   param        : string;
begin
     PacFilename := paramstr(1);
     if pos('.',Pacfilename) = 0 then
        Pacfilename := Pacfilename + '.pac';
     param := paramstr(2);
     param[2] := upcase(param[2]);
     if (param[1] <> '-') and (param[1] <> '/') then
     begin
          writeln('And... what am I supposed to do now???');
          halt;
     end;
     if (param[2] = 'E') or (param[2] = 'X') then
     begin
          if fsearch(Pacfilename,getenv('name')) = '' then
          begin
               writeln('PAC File : ',Pacfilename,' isn''t there, stupid!');
               halt;
          end;
          if paramcount < 3 then
          begin
               writeln('No FileSpec... Assuming *.*');
               for x := 1 to 10 do extractfile[x] := '';
               extractfile[1] := '*.*';
          end
          else
          begin
               for x := 1 to 10 do extractfile[x] := '';
               for x := 1 to paramcount-2 do
                   extractfile[x] := paramstr(x+2);
          end;
          ExtractFiles(Pacfilename); { procedure uses "extractfile" var }
     end;
     if param[2] = 'A' then
     begin
          if paramcount < 3 then
          begin
               writeln('No Filespec... Assuming *.*');
               for x := 1 to 10 do extractfile[x] := '';
               extractfile[1] := '*.*';
          end
          else
          begin
               for x := 1 to 10 do extractfile[x] := '';
               for x := 1 to paramcount-2 do
                   extractfile[x] := paramstr(x+2);
          end;
          AddFiles(Pacfilename);
     end;
     if param[2] = 'L' then
     begin
          if fsearch(Pacfilename,getenv('name')) = '' then
          begin
               writeln('PAC File : ',Pacfilename,' isn''t there, stupid!');
               halt;
          end;
          ListFiles(Pacfilename);
     end;
end;

{- Main Program -------------------------------------------------------------}

begin
     textbackground(black);
     clrscr;
     writeln('TPAC v1.7 by Tim Gordon  (This one uses wildcards!)');
     writeln('---------------------------------------------------');
     if paramstr(1) = '-?' then
        displayhelp; { Displays Help if -? parameter is used }
     if paramcount = 0 then
        displayhelp; { Displays help if no parameters were used }
     RunProgram; { Run Main program }
end.
