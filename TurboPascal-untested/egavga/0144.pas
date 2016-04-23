{
>  Checksums are not too secure. CRCs are better. In case a word
>  checksum is enough for you...

> I'm still not for sure on what this program is suppose to do for me.
> What ever you are talking about above? I have no idea. Well
> I hope to hear from you again, and maybe you can explain on what this
> can do for me and how to use it in my program.

Ok. I hope the following examples will make things more clear
to you. Here are two programs. The first one (checksum.pas)
reads a word checksum stored in offset 12h of its own EXE
header. Then it calculates the checksum of its own compiled
code. If both values are the same it prints 'Yes!' else it
prints 'No!'. The second program (writecsum.pas) is a
"utility" that calculates the checksum word for the compiled
code of program checksum.exe and writes it to its header at
offset 12h. For your benefit, both programs use only Pascal
code. For obvious reason the checksum calculation skips the
header itself.

   1) Compile both programs into exe files.
   2) Run checksum.exe (it will respond 'No!' because its header
      does not contain the correct checksum).
   3) Run writecsum.exe (this will write the correct checksum into
      the header of checksum.exe)
   4) Run checksum.exe (it will respond 'Yes!')
   5) If the code of checksum.exe is messed in a way that
      its checksum is changed it will again respond 'No!'

{-------------------------------------------------}
{ This program prints 'Yes!' only if the checksum }
{ word stored in offset 12h of the EXE header is  }
{ the same as the one calculated by the program   }
{ on its own compiled code past the EXE header... }
{ -Jose- (1:163/513.3)                            }
{-------------------------------------------------}
program checksum;
uses dos;
type
  arr256 = array[0..255] of byte;
var
  f : file;
  numread : word;
  block   : arr256;
  csum    : word;
  headercsum : word;
function cmem(var block:arr256; siz:word): word;
var
  r : registers;
begin
  r.ax:= $121C;
  r.ds:= seg(block);
  r.si:= ofs(block);
  r.cx:= siz;
  r.dx:= 0;
  Intr($2F,r);
  cmem:= r.dx;
end;
begin
  if lo(dosversion) < 3 then begin
    writeln('Dos must be 3+...');
    halt;
  end;
  assign(f,paramstr(0));
  reset(f,1);
  seek(f,$12);  {seek checksum word in exe header}
  blockread(f,headercsum,2);
  seek(f,$1B);  {skip exe header...}
  csum:= 0;
  repeat        {calculate checksum word}
    blockread(f,block,sizeof(block),numread);
    inc(csum,cmem(block,numread));
  until eof(f) or (numread < sizeof(block));
  if headercsum = csum then
    writeln('Yes! (',csum,')')
  else begin
    writeln('No!');
    writeln(headercsum);
    writeln(csum);
  end;
end.

{-----------------------------------------------}
{ This program writes the checksum word of      }
{ checksum.exe in offset $12 of the EXE header  }
{ of the same program -Jose- (1:163/513.3)      }
{-----------------------------------------------}
program writcsum;
uses DOS;
type
  arr256 = array[0..255] of byte;
var
  f : file;
  csum    : word;
  block   : arr256;
  numread : word;
function cmem(var block:arr256; siz:word): word;
var
  r : registers;
begin
  r.ax:= $121C;
  r.ds:= seg(block);
  r.si:= ofs(block);
  r.cx:= siz;
  r.dx:= 0;
  Intr($2F,r);
  cmem:= r.dx;
end;
begin
  if lo(dosversion) < 3 then begin
    writeln('Dos must be 3+...');
    halt;
  end;
  assign(f,'checksum.exe');
  {$I-} reset(f,1); {$I+}
  if ioresult <> 0 then begin
    writeln('Cannot find file checksum.exe');
    halt;
  end;
  seek(f,$1B); {skip header...}
  csum:= 0;
  repeat       {calculate checksum word}
    blockread(f,block,sizeof(block),numread);
    inc(csum,cmem(block,numread));
  until eof(f) or (numread < sizeof(block));
  seek(f,$12); {seek checksum word in exe header}
  blockwrite(f,csum,sizeof(csum));
  close(f);
end.
