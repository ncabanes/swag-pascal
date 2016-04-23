{
Q:  How do I reduce the amount of memory taken from the data
segment?  (or How do I allocate memory dynamically?)

A:
}
Let's say your data structure looks like this:

 type
   TMyStructure = record
     Name: String[40];
     Data: array[0..4095] of Integer;
   end;

That's too large to be allocated globally, so instead of 
declaring a global variable,

 var
   MyData: TMyStructure;

you declare a pointer type,

 type
   PMyStructure = ^TMyStructure;

and a variable of that type,

 var
   MyDataPtr: PMyStructure;

Such a pointer consumes only four bytes of the data segment.

Before you can use the data structure, you have to allocate it 
on the heap:

 New(MyDataPtr);

and now you can access it just like you would global data. The 
only difference is that you have to use the caret operator to 
dereference the pointer:

 MyDataPtr^.Name := 'Lloyd Linklater';
 MyDataPtr^.Data[0] := 12345;

Finally, after you're done using the memory, you deallocate it:

 Dispose(MyDataPtr);
