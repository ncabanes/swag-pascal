
Some time ago I had to write some data marshalling tools, and I had to
perform byte swapping in both Delphi and C++  (we had to talk to a Sun
box). Here is the code that will perform byte swapping on any type (single,
double, extended, etc)

procedure PerformByteSwapping(DataPtr : Pointer;NoBytes : integer);
var
  i : integer;
  dp : PChar;
  tmp : char;
begin
  // Perform a sanity check to make sure that the function was called
properly
  if (NoBytes > 1) then
  begin
    Dec(NoBytes);
    dp := PChar(DataPtr);
    // we are now safe to perform the byte swapping
    for i := NoBytes downto (NoBytes div 2 + 1) do
    begin
      tmp := Pchar(Integer(dp)+i)^;
      Pchar(Integer(dp)+i)^ := Pchar(Integer(dp)+NoBytes-i)^;
      Pchar(Integer(dp)+NoBytes-i)^ := tmp;
    end;
  end;
end;

The way to use this function is as follows::
j : integer;
x : double;
y : extended;

PerformByteSwapping(@i,SizeOf(i)); //to swap an integer
PerformByteSwapping(@x,SizeOf(x)); //to swap a double
PerformByteSwapping(@y,SizeOf(y)); //to swap an extended.
The function works very well, and has been tested thoroughly.

On the C side I could follow a more elegant approach - such as this::
//first define a macro that will enable easy usage ::
#define SwapBytes(x) PerformByteSwapping((char *)&(x),sizeof((x)))

int PerformByteSwapping(char *DataPtr, int NumBytes)
{
  char tmp;
  char *OtherEnd;

  /* Perform a sanity check to make sure that the function was called
properly*/
  if ((NumBytes <= 1) || !DataPtr)
        return(0);
        OtherEnd = &DataPtr[NumBytes-1];
  do
  {
    tmp = *DataPtr;
    *DataPtr++ = *OtherEnd;
    *OtherEnd-- = tmp;
  } while (DataPtr < OtherEnd);
  return(1);
}

//the macro makes things easier ... eg
int i;
double x;
SwapBytes(i); //with macro substitution things are easier to code and
become more readable
SwapBytes(x);

P.S. If anyone  gets this message please acknowledge, as my messages did
not make it to the list lately.
I hope this helps. Cheers.

teo@partnership-group.com.au
