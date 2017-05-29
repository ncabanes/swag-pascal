(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0033.PAS
  Description: File encrypting with password
  Author: PETER RADICS
  Date: 05-30-97  18:17
*)


(************** A very easy file encrypting program ******
- uses password feature
- Programmed by OtherSide Computing Magazine Hungary
- Fixed and sent to SWAG by Peter Radics (pradics@bigfoot.com)
- Public Domain
*****************************Hope you'll enjoy ***********)

uses crt;
var
    rf,wf:file;
    rfn,rfw,code:string;
    o,m:byte;
    c:char;

begin
  textcolor(7);
  write('[1] for Coding  [2] for Decoding : ');
  c:=readkey;
  while (c<>'1') and (c<>'2') do c:=readkey;
  writeln(c);
  write('Enter input file name : ');readln(rfn);
  write('Enter output file name : ');readln(rfw);
  write('Enter code word : ');readln(code);
  if length(code)=0 then begin writeln('You must enter a code word!');halt;end;
      case c of
   '1':writeln('Coding...');
   '2':writeln('Decoding...');
  end;
  assign(rf,rfn);assign(wf,rfw);reset(rf,1);rewrite(wf,1);
  m:=1;
  while not eof(rf) do begin
        blockread(rf,o,1);
        o:=o xor ord(code[m]);
        if m<length(code) then m:=m+1
                          else m:=1;
        blockwrite(wf,o,1);
       end;
  close(rf);close(wf);
    writeln('Ready');
end.
