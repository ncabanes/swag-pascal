(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0007.PAS
  Description: PTRARRAY.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:54
*)

DS> Hi, I've recently encountered a problem With not having enough memory
DS> to open a large sized Array [ie: 0..900].  Is there any way to
DS> allocate more memory to the Array as to make larger Arrays

Array of what?  if the total size of the Array (i.e. 901 *
sizeof(whatever_it_is_you're_talking_about)) is less than 64K, it's a snap.
Read your dox on Pointers and the heap.  You'll end up doing something like
this:

Type
  tWhatever : whatever_it_is_you're_talking_about;
  tMyArray : Array[0..900] of tWhatever;
  tPMyArray : ^MyArray;

Var
  PMyArray : tPMyArray;

begin
  getmem(PMyArray,sizeof(tMyArray));

  { now access your Array like this:
    PMyArray^[IndexNo] }

if your Array is >64K, you can do something like this:

Type
  tWhatever : whatever_it_is_you're_talking_about;
  tPWhatever : ^tWhatever;

Var
  MyArray : Array[0..900] of tPWhatever;
  i : Word;

begin
  For i := 0 to 900 do
    getmem(MyArray[i],sizeof(tWhatever));

  { now access your Array like this:
    MyArray[IndexNo]^ }

if you don't have enough room left in your data segment to use this latter
approach (and I'll bet you do), you'll just need one more level of indirection.
Declare one Pointer in the data segment that points to the Array of Pointers on
the heap, which in turn point to your data.

if you're a beginner, this may seem impossibly Complex (it did to me), but keep
at it and it will soon be second nature.

