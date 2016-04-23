{
Note : Functions beginning with "__" come from the ECO Library - Kerry.

FLOOR A.C. NAAIJKENS

The Norton-like bar along with the copying won't compile

{$I-}
function __copyfil(show : boolean; x1, x2, y, f, b : byte;
                   fs : longint; src, targ : string) : byte;
{
 return codes:
  0 successful
  1 source and target the same
  2 cannot open source
  3 unable to create target
  4 error during copy
  5 cannot allocate buffer
}
const
  bufsize = 16384;

type
  fbuf = array[1..bufsize] of char;
  fbf  = ^fbuf;

var
  source,
  target   :    file;
  bread,
  bwrite   :    word;
  filebuf  :    ^fbf;
  tr       : longint;
  nr       :    real;

begin
  if memavail > bufsize then
    new(filebuf)
  else
  begin
    __copyfil := 5;
    exit
  end;
  if src = targ then
  begin
    __copyfil := 1;
    exit
  end;
  assign(source, src);
  reset(source,1);
  if ioresult <> 0 then
  begin
    __copyfil := 2;
    exit
  end;
  assign(target, targ);
  rewrite(target,1);
  if ioresult <> 0 then
  begin
    __copyfil := 3;
    exit
  end;
  if show then
    __write(x1 + 2 , y, f, b, __rep(x2 - x1 - 3, '░'));
  tr := 0;
  repeat
    blockread(source, filebuf^, bufsize, bread);
    tr := tr + bread;
    nr := tr / fs;
    nr := nr * (x2 - x1 - 3);
    if show then
      __write(x1 + 2, y, f, b, __rep(trunc(nr), '█'));
    blockwrite(target, filebuf^, bread, bwrite);
  until (bread = 0) or (bread <> bwrite);
  if show then
    __write(x1 + 2, y, f, b, __rep((x2 - x1 - 3), '█'));
  close(source);
  close(target);
  if bread <> bwrite then
    __copyfil := 4
  else
    __copyfil := 0;
end;
{$I-}

