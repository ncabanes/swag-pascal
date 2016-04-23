{
MARK OUELLET

Compile for Protected Mode in BP 7.x}

{$A+,B-,D+,E+,F-,G+,I+,L+,N-,P-,Q-,R-,S+,T-,V+,X+,Y+}
{$M 16384,0}

type
        MyElement = longint;

const
        Chunk    = 65520 div sizeof(MyElement);
  ChunkCnt = 10;
        Limit    : longint = Chunk * ChunkCnt - 1;

type
        HeapArrPtr = ^HeapArr;
        HeapArr    = array [0..(Chunk - 1)] of MyElement;
        BigHeapArr = array [0..(ChunkCnt - 1)] of HeapArrPtr;

var
        MyHeap : BigHeapArr;
  Index  : longint;

begin
        for Index := 0 to ChunkCnt-1 do
          new(MyHeap[Index]);
  for Index := 0 to Limit do
          MyHeap[Index div Chunk]^[Index mod Chunk] := Index;
  for Index := 0 to Limit do
          writeln(Index:10,MyHeap[Index div Chunk]^[Index mod Chunk]:10);
  for Index := 0 to ChunkCnt-1 do
    dispose(MyHeap[Index]);
end.

{
I just tested it and it stored 163,800 Longintegers on the heap. The
nice thing is you could make this into an Object with SET and GET
methods and treat it as a 163800 element array.
}
