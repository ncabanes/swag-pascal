{
Although, I can not gaurentee this is correct, but it WILL stop Undel
from PCTools, Undel from nortons, and undelete from dos. (tested) Although
I don't have the time to play around with a sector editor:
}

{$A+,B-,D+,E+,F-,G-,I-,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+}
{$M 16384,0,655360}
Uses crt,dos;
Const
  Product = 'WipeFile';
  Version = '1.00a';
  Release = 'Gamma';
  Author  = 'John Stephenson';

Procedure WipeFile(fn: string);
Var
  size,
  total: longint;
  loop,towrite,numwritten: word;
  f: file;
  buffer: array[1..1024] of byte;
begin
  assign(f,fn);
  setfattr(f,0);
  if doserror = 0 then begin
    { DOS will normally keep the rest of the file name, and just truncate
      it with a null. But when the full filename is renamed then that can't
      be done. Then it renames it to ~ so that undelete will just show
      a question mark, and same with a sector editor on the hd }
    rename(f,'~~~~~~~~.~~~');
    rename(f,'~');

    { Randomize a buffer for later use when we erase the file }
    for loop := 1 to sizeof(buffer) do buffer[loop] := random(256);

    { Then we must completely rewrite the file, starting from byte one
      to the filesize, completely erasing all sector data. Very easily
      done, using a random buffer to write with. }
    reset(f,1);
    size := filesize(f);
    total := 0;
    repeat
      { Figure out how much to write }
      towrite := sizeof(buffer);
      if towrite+total > size then towrite := size - total;

      blockwrite(f,buffer,towrite,numwritten);
      inc(total,numwritten);
    until total = size;

    { Now we seek to the first byte of the file, and truncate it there,
      leaving it a measly 0 bytes }
    Seek(f,0);
    Truncate(f);

    { Now we will close up the file, and delete it }
    close(f);
    erase(f);
  end;
end;

var
  loop: byte;
  fn: pathstr;
begin
  if paramcount = 0 then begin
    textattr := lightcyan;
    writeln(product+' v'+version+' '+release+' by '+author+#10);
    textattr := lightgray;
    writeln('Completely erases file contents, and filename from FAT and');
    writeln('from the actual disk. Very throughly done!'#10);
    writeln('Summary of action: ■ Un-attributes file.');
    writeln('                   ■ Renames FAT file name.');
    writeln('                   ■ Rewrites file contents with a random buffer');
    writeln('                   ■ Truncates file to 0 bytes.');
    writeln('                   ■ Erases file.');
    halt(1);
  end;
  randomize;
  for loop := 1 to paramcount do begin
    Fn := paramstr(loop);
    write('Wiping: ',fn,'...');
    wipefile(fn);
    writeln(' Done!');
  end;
end.
