
I have a unit which many people might find very handy.  It allows you to
use dynamic arrays in pascal so you can create new arrays, resize
arrays, and delete arrays.  The usage is a little different, and always
need a variable to store a value into, and access is a bit slower than
normal arrays, but it gets the job done.  I think the main slow down is
the function calls, as the speed is comparable to a normal array access
if you call a function that accesses the array.

Here's dynarray.pas:
-----------------------cut here-------------------------------
unit dynarray;

{ dynarray - a unit to allow use of dynamic arrays written by
  Jonathan Anderson.  I release this to the public domain, so
  use it for whatever you want, but please give me credit for
  my work.  Thanks. }

(*************************************************************)
INTERFACE
(*************************************************************)

function getsize(var arr) : word;
   { Returns the number of elements in arr }

function getesize(var arr) : word;
   { Returns the size of an element in arr }

function getmemsize(var arr) : word;
   { Returns the total memory space taken up by arr (not including
     the four bytes for the pointer) }

procedure initarray(var arr : pointer; size : word; esize : word);
   { Initializes a dynamic array arr with size elements of esize
     bytes each.  Arr will be null if there is not enough memory. }

function resizearray(var arr : pointer; size : word) : boolean;
   { Resizes a dynamic array arr to size number of elements.
     When an array is enlarged, it retains all old data plus new
     uninitialized elements.  (These may not be zero)
     When an array is shortened, elements are truncated off the end
     while the remaining elements are intact.
     resizearray returns true if successful, false if otherwise. }

procedure donearray(var arr : pointer);
   { Frees the memory used by arr }

procedure setval(var arr; index : word; var value);
   { Copies value into the element at index in arr.  Value must be
     a variable.  Sorry, but I couldn't figure out how to do it
     otherwise with variable length elements. }

function getval(var arr; index : word; var value) : pointer;
   { Copies the element at index in arr to value.  Returns a pointer
     to value so it can be used as a function.  Example:
        writeln(integer(getval(arr^, index, x)^));
     This will store the at index in arr into x and write it to the
     screen.  Typecasting is needed to tell writeln that what getval
     points to is an integer.  This also assumes that values stored
     in arr are 2 bytes long. }

(*************************************************************)
IMPLEMENTATION
(*************************************************************)

procedure setsize(var arr; size : word); assembler;
asm
   mov ax, word ptr (arr+2)         { set ax to the segment of arr }
   mov es, ax
   mov di, word ptr arr             { set di to the offset of arr }
   mov ax, size
   mov word ptr [es:di], ax         { set the 1st word of arr to its
size }
end;

procedure setesize(var arr; esize : word); assembler;
asm
   mov ax, word ptr (arr+2)         { set ax to the segment of arr }
   mov es, ax
   mov di, word ptr arr             { set di to the offset of arr }
   mov ax, esize
   mov word ptr [es:di+2], ax       { set the 2nd word of arr to the }
end;                                { element size }

function getsize(var arr) : word; assembler;
asm
   mov ax, word ptr (arr+2)         { set ax to the segment of arr }
   mov es, ax
   mov di, word ptr arr             { set di to the offset of arr }
   mov ax, word ptr [es:di]         { return 1st word in arr (size) }
end;

function getesize(var arr) : word; assembler;
asm
   mov ax, word ptr (arr+2)         { set ax to the segment of arr }
   mov es, ax
   mov di, word ptr arr             { set di to the offset of arr }
   mov ax, word ptr [es:di+2]       { return 2nd word in arr (e. size) }
end;

function getmemsize(var arr) : word;
begin
   getmemsize := getsize(arr)*getesize(arr)+4;
        { (number of elements)x(element size) + (four bytes for storing
           size and element size) }
end;

procedure initarray(var arr : pointer; size : word; esize : word);
begin
   if (MaxAvail >= size*esize+4) and (longint(size)*esize+4 <= 65535)
then
   { make sure there's enough memory and the array isn't larger than 64K
}
      begin
         getmem(arr, size*esize+4);    { allocate the memory }
         setsize(arr^, size);          { set the array size }
         setesize(arr^, esize);        { set the element size }
      end
   else     { if array too big or not enough memory, set arr to nil }
      arr := nil;
end;

function resizearray(var arr : pointer; size : word) : boolean;
var
   p, q : pointer;       { temporary variables for intermediate storage
}
   x : word;             { temporary variable }
begin
   if (MaxAvail >= size*getesize(arr^)+4) and
      (longint(size)*getesize(arr^)+4 <= 65535) then
        { if there's enough memory and new array < 64K }
      begin
         getmem(p, size*getesize(arr^)+4);  { allocate memory for new
array }
         setsize(p^, size);                 { set new size }
         setesize(p^, getesize(arr^));      { set new element size }
         x := getmemsize(arr^);             { set x to old mem size }
         if getmemsize(p^) < x then         { if new array is smaller, }
            x := getmemsize(p^);            { set x to new mem size }
         move(arr^, p^, x);                 { copy x elements to new
array }
         setsize(p^, size);              { set new size (destroyed in
copy) }
         freemem(arr, getmemsize(arr^));    { free mem from old array }
         arr := p;                         { set arr to new array }
         resizearray := true;              { return true on success }
      end
   else
   { array too big or not enough memory, return false but leave arr
intact }
      resizearray := false;
end;

procedure donearray(var arr : pointer);
begin
   freemem(arr, getmemsize(arr^));      { free memory from arr }
end;

procedure setval(var arr; index : word; var value);
begin
   move(value, ptr(seg(arr),ofs(arr)+index*getesize(arr)+4)^,
getesize(arr));
   { copy value to array element.  Pascal is strong typed, so we have
     to access specific element periphrastically. }
end;

function getval(var arr; index : word; var value) : pointer;
begin
   move(ptr(seg(arr),ofs(arr)+index*getesize(arr)+4)^, value,
getesize(arr));
   { copy array element to value.  Pascal is strong typed, so we have
     to access specific element periphrastically. }
   getval := @value;     { return pointer to value }
end;

end.
--------------------cut here--------------------------

And here's a program to show how to use it:
--------------------cut here--------------------------
program testarray;

uses dynarray;

var
   array1 : pointer;
   x : byte;

procedure getit(var a; size:word);
var
   i:word;
   b:byte;
begin
   for i:=0 to size-1 do
      begin
         write('Enter value ',i,': ');
         readln(b);
         setval(a,i,b);
      end;
end;

procedure showit(var a; size : word);
var
  i:word;
  b:byte;
begin
   for i:=0 to size-1 do
      writeln('Value ',i,': ', byte(getval(a,i,b)^));
end;

begin
   write('Enter number of elements: ');
   readln(x);
   initarray(array1, x, 1);  { initializes array1 as an array[0..x-1] of
}
                             { byte sized elements }
   getit(array1^, getsize(array1^));
   showit(array1^, getsize(array1^));
   donearray(array1);
end.
--------------------cut here----------------------

I hope you enjoy it.
--
Jonathan Anderson
sarlok@geocities.com
