{
There's a problem here. You can append the binary data but that won't make
code from both EXE files work. Either the first one will work, ignoring
the code from the second one, or the whole thing will turn into trash.

However, if you still want to try it, go ahead. Here are 3 untested by
compiling file copying programs that will only append IT2.EXE to the end of
IT.EXE. You'll be required to make or copy files called IT.EXE and IT2.EXE
for the use of this simple demonstration program.
}

Program BCopy1;
uses objects;
var
 f,f2:tdosstream;
begin
 f.init ('IT.EXE',stopen);
 f.seek (f.getsize);
 f2.init ('IT2.EXE',stopen);
 f.copyfrom(f2,f2.getsize);
 f.done;
 f2.done;
end.

Program BCopy2;
var
 f,f2:file;
 blocks:longint;
 bytes:word;
 buffer:array [1..2048] of byte;
begin
 assign(f,'IT.EXE');
 assign(f2,'IT2.EXE');
 reset(f,1);
 reset(f2,1);
 seek(f,filesize(f));
 bytes:=filesize(f2);
 blocks:=bytes div 2048;
 bytes:=bytes mod 2048;
 while blocks>0 do begin
  blockread(f2,buffer,sizeof(buffer));
  blockwrite(f,buffer,sizeof(buffer));
  dec(blocks);
 end;
 if bytes>0 then begin
  blockread(f2,buffer,bytes);
  blockwrite(f,buffer,bytes);
 end;
 close(f);
 close(f2);
end.

Program BCopy3;
uses dos;
begin
 swapvectors;
 exec(getenv('comspec'),'/c copy /b it.exe+it2.exe it.exe');
 swapvectors;
end.

