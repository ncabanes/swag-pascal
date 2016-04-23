program CAT;

{$I-}

uses
   dos,
   files, { see end for this unit }
   crt;

type
   arraybuf = array[1..65535] of byte;
   buffer = ^arraybuf;
   chksum = file of searchrec;

procedure error(mess:string);
var
   code:integer;
begin
   code:= ioresult;
   writeln('ERROR:  ', mess);
   {writeln('ERROR CODE:  ', code);}
   halt(1);
end;

procedure delete(drive:char; var success:boolean);
   procedure recurse(tree:directory_tree; var success:boolean);
   var
      info:searchrec;
      buffer:text;
      success2:boolean;
      d:string[79];
   begin
      if tree <> nil then begin
      success2:= true;
      d:= tree^.dir;
         begin
            recurse(tree^.lower_dir, success2);
            tree:= tree^.next;
            success:= success and success2;
            recurse(tree, success2);
            success:= success and success2;
         end;
      chdir(d);
      findfirst('*.*', anyfile, info);
      while (doserror = 0) and (success) do
         begin
            if (info.name <> '.') and (info.name <> '..') then
               begin
                  assign(buffer, info.name);
                  case info.attr of
                     $10: rmdir(info.name);
                     $20: erase(buffer);
                  else
                     success:= false;
                  end;
               end;
            findnext(info);
         end;
   end;
   end;
var
   tree:directory_tree;
begin
   tree:= nil;
   chdir(drive+':\');
   fill_dirtree(drive+':\', tree);
   success:= true;
   recurse(tree, success);
end;

function DriveExist(drive:char):boolean;
var
   fileinfo:searchrec;
begin
   findfirst(drive+':\*.*', anyfile, fileinfo);
   if doserror = 3 then
      driveexist:= false
   else
      driveexist:= true;
end;

procedure work(max,done:longint);
begin
   write(100*(done/max):4:1, '% complete.');
   gotoxy(1, wherey);
end;

procedure help;
begin
   writeln('The Concatinator   Version 1.0   Copyright 1996 by Jack Neely');
   writeln('A large file disk storage and retrieval program.');
   writeln;
   writeln('Usage:   CAT s <storage drive> <filename>');
   writeln('         CAT r <storage dirve> <path>');
   writeln;
   writeln('Commands: ''s'' = Store   ''r'' = Retrive');
   writeln('Storage drive must be the disk drive to store or that a large file is');
   writeln('stored apon.  Specify a path where the file will be placed when');
   writeln('retriving a file.  Specify a filemane when storing a large file.');
   writeln;
   writeln('You can use this program to store those large files that are larger');
   writeln('than a single disk onto multiple disks.  Anything on the disk prior');
   writeln('to storage will be erased.  A checksum file will also be stored on the');
   writeln('first disk of each set.');
   writeln;
   writeln('The author can be reached at hneely@ac.net');
   writeln;
   halt(0);
end;

function num(d:char):word;
begin
   num:= ord(upcase(d)) - 64;
end;

function strn(a:integer):string;
var
   s:string;
   i:integer;
begin
   str(a, s);
   if length(s) < 4 then
      for i:= 1 to 4 - length(s) do
         s:= '0' + s;
   strn:= s;
end;

function return(s:string; b:boolean):integer;
var
   str:string;
   i, c:integer;
begin
   str:= '';
   if b then
      for i:= 1 to 4 do
         str:= str + s[i]
   else
      for i:= 5 to 8 do
         str:= str + s[i];
   val(str, i, c);
   return:= i;
end;

procedure store(filename:string; drive:char);
var
   input, output:file;
   fileinfo, test:searchrec;
   filedata:chksum;
   c, full, disk:longint;
   diskdone:boolean;
   fset, disknum:word;
   success:boolean;
   data:buffer;
   buffersize, readcount, writecount:word;
   ch:char;
begin
   findfirst(filename, anyfile, fileinfo);
   if doserror <> 0 then
      error('File not found: ' + filename);
   new(data);
   c:= 0;
   disknum:= 0;
   diskdone:= true;
   if not DriveExist(drive) then error(drive+': does not exist.');
   randomize;
   fset:= random(9999);
   writeln('This is file set number ', fset, '.');
   assign(input, filename);
   reset(input, 1);
   while c < fileinfo.size do
      begin
         if diskdone then
            begin
               if disknum <> 0 then
                  close(output);
               clreol;
               disk:= 0;
               disknum:= disknum + 1;
               write('Insert disk ', disknum, ' and press [ENTER].');
               readln;
               diskdone:= false;
               buffersize:= sizeof(arraybuf);
               full:= disksize(num(drive));
               if disknum = 1 then
                  begin
                     writeln('Approximately ', (1+(fileinfo.size div disksize(num(drive)))), ' of these disks are needed.');
                     write('Continue? (Y/N)');
                     ch:= readkey;
                     if not ((ch = 'y') or (ch = 'Y')) then
                        halt(0);
                     writeln;
                  end;
               if disksize(num(drive)) <> diskfree(num(drive)) then
                  begin
                     findfirst(drive+':\*.cat', anyfile, test);
                     if return(test.name, true) = fset then
                        error('This disk is of this same set.');
                     delete(drive, success);
                     if not success then
                        error('Some existing file(s) on destination disk could not be removed.');
                  end;
                  assign(output, drive+':\'+strn(fset)+strn(disknum)+'.cat');
                  rewrite(output, 1);
               if disknum = 1 then
                  begin
                     assign(filedata, drive+':\check.sum');
                     rewrite(filedata);
                     write(filedata, fileinfo);
                     close(filedata);
                     full:= diskfree(num(drive));
                  end;
            end;
         if full - disk < buffersize then
            begin
               buffersize:= full - disk;
               diskdone:= true;
            end;
         blockread(input, data^, buffersize, readcount);
         if ioresult <> 0 then
            error('Errors on source disk.');
         blockwrite(output, data^, readcount, writecount);
         if ioresult <> 0 then
            error('Errors on target disk.');
         c:= c + readcount;
         disk:= disk + readcount;
         work(fileinfo.size, c);
         if readcount <> writecount then error('Unable to write to disk');
      end;
   clreol;
   close(input);
   close(output);
   dispose(data);
end;

procedure retrive(drive:char; path:string);
var
   setnum, disknum:word;
   diskdone, complete:boolean;
   newfile, store:file;
   cs:chksum;
   fileinfo, data:searchrec;
   d:buffer;
   c:longint;
   buffersize, readcount, writecount:word;
begin
   complete:= false;
   chdir(path);
   new(d);
   c:= 0;
   if ioresult <> 0 then
      error(path+' does not exist.');
   diskdone:= true;
   disknum:= 0;
   while not complete do
      begin
         if diskdone then
            begin
               clreol;
               disknum:= disknum + 1;
               if disknum > 1 then
                  close(store);
               diskdone:= false;
               write('Insert disk ', disknum, ' and press [ENTER].');
               readln;
               buffersize:= sizeof(arraybuf);
               if disknum = 1 then
                  begin
                     assign(cs, drive+':\check.sum');
                     reset(cs);
                     if ioresult <> 0 then error('No check sum file.');
                     read(cs, fileinfo);
                     close(cs);
                     assign(newfile, fileinfo.name);
                     rewrite(newfile, 1);
                     findfirst(drive+':\*.cat', archive, data);
                     if doserror = 18 then
                        begin
                           close(newfile);
                           erase(newfile);
                           error('Disk does not contain storage data.');
                        end;
                     assign(store, drive+':\'+data.name);
                     reset(store, 1);
                     setnum:= return(data.name, true);
                     if return(data.name, false) <> disknum then
                        begin
                           close(newfile);
                           erase(newfile);
                           error('Wrong disk.');
                        end;
                     writeln('File set number is: ', setnum);
                  end
               else
                  begin
                     findfirst(drive+':\*.cat', archive, data);
                     if doserror = 18 then
                        begin
                           close(newfile);
                           erase(newfile);
                           error('Disk does not contain storage data.');
                        end;
                     assign(store, drive+':\'+data.name);
                     reset(store, 1);
                     if setnum <> return(data.name, true) then
                        begin
                           close(newfile);
                           erase(newfile);
                           error('Disk is of a different set.');
                        end;
                     if disknum <> return(data.name, false) then
                        begin
                           close(newfile);
                           erase(newfile);
                           error('Wrong disk.');
                        end;
                  end;
            end;
         blockread(store, d^, buffersize, readcount);
         if ioresult <> 0 then
            begin
               close(newfile);
               erase(newfile);
               error('Errors on source disk.');
            end;
         blockwrite(newfile, d^, readcount, writecount);
         if ioresult <> 0 then
            begin
               close(newfile);
               erase(newfile);
               error('Errors on target disk.');
            end;
         c:= c + readcount;
         if writecount <> readcount then
            begin
               close(newfile);
               erase(newfile);
               error('Unable to write to disk.');
            end;
         if buffersize <> readcount then
            diskdone:= true;
         if fileinfo.size = c then complete:= true;
         work(fileinfo.size, c);
      end;
   clreol;
   close(newfile);
   close(store);
   dispose(d);
end;

var
   c1, c2:string;

begin
   if paramcount = 0 then
      help;
   if paramcount <> 3 then
      error('Incorect number of parameters.');
   c1:= paramstr(1);
   c2:= paramstr(2);
   case c1[1] of
      's', 'S' : store(paramstr(3), c2[1]);
      'r', 'R' : retrive(c2[1], paramstr(3));
   else
      error('Incorect parameters.');
   end;
   writeln('Complete!');
end.

{ ---------------  CUT ---------------- }

unit files;

interface

uses
   dos;

type
   filetype = string[12];
   {searchrec = record    This is how searchrec is defined in the DOS unit.
      Fill: array[1..21] of Byte;
      Attr: Byte;
      Time: Longint;
      Size: Longint;
      Name: string[12];
   end;  }
   filestack = ^ node;
   node = record
      fileinfo:searchrec;
      next:filestack;
   end;
   directory_tree = ^dnode;
   dnode = record
      dir:string;
      lower_dir:directory_tree;
      next:directory_tree;
   end;

procedure fill_filestack(var stack:filestack);
   {Fills stack of type filestack with all the file enteries in the
   current directory.  Includes directoies and hidden file types.}

procedure push_filestack(var stack:filestack; item:searchrec);
   {Pushes in alfa order a new node on a filestack.}

procedure fill_dirtree(dir:string; var tree:directory_tree);
   {Fills a tree sturcture with the directory structure using dir string
   as the root.}

implementation

procedure push_filestack(var stack:filestack; item:searchrec);
var
   temp:filestack;

   procedure insert(var stack, prev:filestack);
   begin
      if (stack = nil) then
         begin
            temp^.next:= stack;
            stack:= temp;
         end
      else
         if temp^.fileinfo.name > stack^.fileinfo.name then
            insert(stack^.next, stack)
         else
            if temp^.fileinfo.name < stack^.fileinfo.name then
               begin
                  if prev = stack then
                     begin
                        temp^.next:= stack;
                        stack:= temp;
                     end
                  else
                     begin
                        temp^.next:= stack;
                        prev^.next:= temp;
                     end;
               end;
   end;
begin
   new(temp);
   temp^.fileinfo:= item;
   insert(stack, stack);
end;

procedure fill_filestack(var stack:filestack);
var
   dirinfo:searchrec;
begin
   findfirst('*.*', anyfile, dirinfo);
   while doserror <> 18 do
      begin
         push_filestack(stack, dirinfo);
         findnext(dirinfo);
      end;
end;

procedure push(var head:directory_tree; item:string);
var
   temp:directory_tree;
begin
   new(temp);
   temp^.dir:= item;
   temp^.next:= head;
   head:= temp;
   head^.lower_dir:= nil;
end;

procedure fill_dirtree(dir:string; var tree:directory_tree);
procedure fill_dirlist(var head:directory_tree; directory:string; s:integer);
var
   place:directory_tree;
   dirinfo:searchrec;
   found:boolean;
begin
   writeln(directory);
   chdir(directory);
   findfirst('*.*', 16, dirinfo);
   while doserror = 0 do
      begin
         if (dirinfo.attr = 16) and ((dirinfo.name <> '..') and (dirinfo.name <> '.'))then
            begin
               push(head, fexpand(dirinfo.name));
               found:= true;
            end;
            findnext(dirinfo);
         end;
      if found then
         begin
            place:= head;
            while place <> nil do
               begin
                  fill_dirlist(place^.lower_dir, place^.dir, s+3);
                  place:= place^.next;
               end;
         end;
end;

var
   temp:directory_tree;
begin
   tree:= nil;
   fill_dirlist(tree, dir, 0);
   new(temp);
   temp^.dir:= dir;
   temp^.lower_dir:= tree;
   temp^.next:= nil;
   tree:= temp;
end;

end.