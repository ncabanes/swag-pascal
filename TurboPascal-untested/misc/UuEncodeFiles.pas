(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0059.PAS
  Description: UU Encode files
  Author: PAUL ROBINSON
  Date: 11-26-93  16:59
*)

{
   Pascal program to UUDECODE files which were processed
   with UUENCODE.  Or it will DECODE files which were
   processed by ENCODE

   Paul Robinson  TDARCOS@MCIMAIL.COM
   Tansin A. Darcos & Company
   June 26, 1993
}

var inf,outf:text;
    open:boolean;
    ch:char;
    buflen,tag:char;
    tagfiller:array[1..80] of char;
    buf:string[80]  absolute buflen;
    tag3:array[1..3] of char absolute tag;
    tag6:array[1..6] of char absolute tag;
    outfn:string[80];
    bp,n:integer;

function dec(c:char):byte;
begin
   dec := (ord(c) - ord(' ')) and 63
end;

procedure short(msg:string);
begin
   writeln(msg);
   close(inf);
   if open then
      close(outf);
   halt(1);
end;


procedure skip;
begin
   while buf[bp] = ' ' do
     begin
        bp := bp+1;
        if bp>=length(buf) then
          short('Error 01 Bad begin line');
     end;
   while buf[bp] <> ' ' do
     begin
        bp := bp+1;
        if bp>=length(buf) then
          short('Error 02 Bad begin line');
     end;
   while buf[bp] = ' ' do
     begin
        bp := bp+1;
        if bp>=length(buf) then
          short('Error 03 Bad begin line');
     end;
    while (buf[bp] <> ' ') do
     begin
        outfn := outfn+buf[bp];
        bp := bp+1;
     end;
end;



{  output a group of 3 bytes (4 input characters).
   the input chars are pointed to by bp.
   n is used to tell us not to output all of them
   at the end of the file.
}

procedure outdec(bp,n:integer);
var c1,c2,c3:byte;
begin
   c1 := (DEC(buf[bp]) shl 2)  or (dec(buf[bp+1]) shr 4);
   c2 := (dec(buf[bp+1]) shl 4) or (dec(buf[bp+2]) shr 2);
   c3 := (dec(buf[bp+2]) shl 6) or dec(buf[bp+3]);
   if n >= 1 then
     write(outf,chr(c1));
   if n >= 2 then
     write(outf,chr(c2));
   if n >= 3 then
     write(outf,chr(c3));
end;

procedure decode;
begin
   if eof(inf) then
     short('Premature EOF');
   repeat
   readln(inf,buf);
   if length(buf)>0 then
     begin
       n := dec(buf[1]);
       if n > 0 then
         begin
            bp := 2;
            while n>0 do
            begin
               outdec(bp, n);
               bp := bp+4;
               n := n-3;
            end;
         end;
    end;
    until length(buf)<2;
end;



begin
   if (paramcount <1) or ((paramcount >=1) and (paramstr(1)='/?'))  then
     begin
        writeln('Pascal UUDECODER by Paul Robinson - TDARCOS@MCIMAIL.COM');
        writeln('Usage: DECODE filename');
        halt(0);
     end;
   assign(inf,paramstr(1));
   open := false;

   {$I-} reset(inf); {$I+}
   if IORESULT <> 0 then
     short('File '+paramstr(1)+' cannot be opened.');
   if not eof(inf) then
      readln(inf,buf)
   else
      short('Empty file');
   while tag6 <> 'begin ' do
      if not eof(inf) then
         readln(inf,buf)
      else
        short('No begin line');
    bp := 6;
    buf := buf+' ';

{
    format is 'begin nnn filename'
    skip spaces before the nnn
    skip the nnn
    skip spaces after the nnn
}
    skip;
    assign(outf,outfn);
{$I-}     rewrite(outf);  {$I+}
    if IORESULT = 0 then
       open := true
    else
       short('Cannot create file '+outfn);

    decode;
    readln(inf,buf);
    if tag3 <> 'end' then
      short('Warning: no end line');
    close(inf);
    if open then
      close(outf);
end.

