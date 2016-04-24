(*
  Category: SWAG Title: FILE COPY/MOVE ROUTINES
  Original name: 0020.PAS
  Description: Simple File Copy
  Author: IAN LIN
  Date: 11-02-93  17:51
*)

{
From: IAN LIN
To just copy files, use buffers on the heap. Just make an array type that's
almost 64k in size. Use as many of these as needed that can fit in RAM and
blockread the data in. After you blockread all you can, close the file if
it's been fully read in. If it hasn't then don't close the input file yet.
Next you open the output file and dump everything in each buffer with
blockwrite. If you're done now, close both files, otherwise keep reading
all you can at once from the input file and blockwriting it to the output
file. }

type
 pbuf=^buf;
 buf=record
  n:pbuf;
  b:array [1..65530] of byte;
 end;
var
 buffer,bufp:pbuf;
 bufc:byte;
 outf,f:file;
begin
 bufp:=new(buffer);
 assign(f,'IT');
 reset(f,1);
 blockread(f,bufp^,sizeof(bufp^);
 assign(outf,'OTHER');
 rewrite(outf,1);
 blockwrite(outf,bufp^,sizeof(bufp^);
 close(f);
 close(outf);
end.

This is just an example so don't expect it to be very useful. :)

For text files, if you want to modify them, you may want to use linked
lists which point to a line at a time. Remove unwanted lines from the list,
and then write it to the output file.

