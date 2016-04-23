{
Robert Rothenburg

Here's some routines I wrote while playing around with some compression
algorithms.  Since they're written in Pascal, they're probably not too
fast but they work.


Of course they're need some tweaking.
}
(* NoFrills Bit-Input/Output Routines                        *)
(* Insert "n" bits of data into a Buffer or Pull "n" bits of *)
(* data from a buffer.  Useful for Compression routines      *)


unit BitIO;

interface

const
  BufferSize = 32767;        (* Adjust as appropriate *)

type
  Buffer  = array [0..BufferSize] of byte;
  BufPtr  = ^Buffer;
  BuffRec = record  (* This was used for I/O by some *)
    Block : BufPtr; (* other units involved with the *)
    Size,           (* compression stuff. Not so     *)
    Ptr   : word;   (* Important?                    *)
    Loc   : byte
  end;

var
  InBuffer,
  OutBuffer : BuffRec;
  InFile,
  OutFile   : file;

procedure InitBuffer(var x : BuffRec);        (* Initialize a buffer *)
procedure GetBits(var b : word; num : byte);  (* Get num bits from   *)
                                              (* InBuffer            *)
procedure PutBits(b : word; num : byte);      (* Put num bits into   *)
                                              (* OutBuffer           *)
function Log2(x : word) : byte;               (* Self-explanatory... *)

implementation

const
  Power : array [1..17] of longint =
    (1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536);

procedure InitBuffer(var x : BuffRec);
begin
  with x do
  begin
    Loc  := 8;
    Ptr  := 0;
    Size := 0;
    New(Block);
    FillChar(Block^, BufferSize, #0);
  end;
end;

procedure GetBits(var b : word; num : byte);
var
  Size : word;
begin
  with InBuffer do
  begin
    b := 0;
    repeat
      b := (b SHL 1);
      if (Block^[Ptr] AND Power[Loc]) <> 0 then
        b := b OR 1;
      dec(Loc);
      if Loc = 0 then
      begin
        Loc := 8;
        inc(Ptr);
      end;
      dec(num);
    until (num = 0);
  end;
end;

procedure PutBits(b : word; num : byte);
var
  i : byte;
begin
  with OutBuffer do
  repeat
    if Loc = 0 then
    begin
      inc(Ptr);
      Loc := 8;
    end;
    if (b AND Power[num]) <> 0 then
    begin
      Block^[Ptr] := Block^[Ptr] OR Power[Loc];
      dec(Loc);
    end
    else
      dec(Loc);
    dec(num)
  until num = 0;
  OutBuffer.Size := succ(OutBuffer.Ptr);
end;

function Log2(x : word) : byte;
var
  i : byte;
begin
  i := 17;
  while x<Power[i] do
    dec(i);
  Log2 := i;
end;

end.
