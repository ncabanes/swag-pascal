(*
  Category: SWAG Title: SEARCH/FIND/REPLACE ROUTINES
  Original name: 0013.PAS
  Description: STSEARCH.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:46
*)

┌─┬───────────────        Andy Stewart        ───────────────┬─╖
│o│ Can someone tell/show me how to write a procedure that   │o║
│o│ will take a string input and search for it in a textfile │o║
╘═╧══════════════════════════════════════════════════════════╧═╝
{ Simple example for a straight forward search routine }
var
  f    : text;
  buf  : array[0..maxint] of char;
  line : word;
  pattern,s,t : string;

{ Corrected version of routine from turbo techniques }
function uppercase (strg:string):string; assembler;
ASM
   push     ds
   lds      si,strg
   les      di,@result
   cld
   lodsb
   stosb
   xor      ch,ch
   mov      cl,al
   jcxz     @done
 @more:
   lodsb
   cmp      al,'a'
   jb       @no
   cmp      al,'z'
   ja       @no
   sub      al,20h
 @no:
   stosb
   loop     @more
 @done:
   pop      ds
END;

{ If you want the above routine in pascal
function uppercase (strg : string) : string;
  var i : integer;
  begin
    for i := 1 to length(strg) do strg[i] := upcase(strg[i]);
    uppercase := strg;
  end;
}

procedure search4pattern;
  begin
    readln(f,s);
    inc(line);
    t := uppercase(s);
    if pos(pattern,t) > 0
    then writeln(line:5,' ',s);
  end;

begin
  Line := 0;
  if paramcount < 2 then exit;
  pattern := paramstr(2);
  pattern := uppercase(pattern);
  assign(f,paramstr(1));
  settextbuf(f,buf);
  {$I-} reset(f); {$I+}
  if ioresult = 0
  then begin
         while not eof(f) do search4pattern;
         close(f);
       end
  else writeln('File not found');
end.
---
 ■ Tags τ Us ■ Abandon the search for truth: settle on a good fantasy.
 * Suburban Software - Home of King of the Board(tm) - 708-636-6694
 * PostLink(tm) v1.05  SUBSOFT (#715) : RelayNet(tm) Hub

                                                                            
