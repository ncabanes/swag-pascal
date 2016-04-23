{
>Okay, I've got the need to load about 3000 Records, at 73 Bytes a piece,
>into active memory.  It'd be preferred to have it as an Array of
>Records, which is what I'm using now (only at 1000 Records though).

>When I do this I get Structure too Large.  Is there any way that I can
>load all of these Records into memory, For sorting, editing, deleting
>and adding new entries (which is easy With an Array).

}
Const
     MaxItems  = 3000 ;

Type TItem =
     Record
          { 73 Bytes Record }
          Dum  : Array[1..73] of Byte ;
     end ;
     PItem = ^TItem ;

     TItemArray = Array[1..MaxItems] of PItem ;

Var  i    : Integer ;
     Arr  : TItemArray ;

begin
     For i:=1 to MaxItems Do New(Arr[i]) ;

     { Now, can use all those items in memory }

     For i:=1 to MaxItems Do Dispose(Arr[i]) ;
end.

{

note that the set of data will occupy :

3000*4 Bytes in DS            12000 Bytes
3000*80 Bytes in the heap    240000 Bytes
                             ------
                             252000 Bytes of memory...

The '80' in the second line is due to the fact that TP 6's heap manager
allocates heap space by multiples of 8 Bytes, thus 73 Bytes result in
80 Bytes allocs. Reducing it to 72 Bytes would save 8*3000=24000 Bytes.

Anyway, this is not Real safe Programming, and you should prefer using a
File, unleast you are Really sure that :
- you won't have more than 3000 Records,
- any machine your Program will run onto has enough memory.
}