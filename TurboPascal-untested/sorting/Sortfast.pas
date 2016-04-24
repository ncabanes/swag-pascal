(*
  Category: SWAG Title: SORTING ROUTINES
  Original name: 0030.PAS
  Description: SORTFAST.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{
> I might share With you a sorting Procedure which I developed For
> 'those Arrays we were talking about:
> ...
> Exeperimentally I used it on 1485 Strings, which took about 3 sec
> on my 386DX40.  Could you advise on some method to do it even
> faster?

I'll share With you a little sort routine which I use often in my Programs
whenever I need a fast and efficient routine With very low overhead... It Uses
considerably less code than your example, and should outperForm it. (It would
be even faster if it was all coded in Assembly!-- hint hint DJ) :-)
}

Procedure Sort_It( totalItems : Word );

  Function Is_Less( TemPtr1, TemPtr2 : Pointer ) : Boolean;
  begin
    Is_Less := ( YourStruct(TemPtr1^).Item < YourStruct(TemPtr2^).Item );
  end;

Var
  I,J : Word;
  Cur : Word;

begin
  For I := 1 to Pred(totalItems) do
  begin
    Cur := I;

    For J := I + 1 to totalItems do
      if Is_Less( Item[J], Item[Cur] ) then
        ExchangeLongInts( LongInt(Item[J]), LongInt(Item[Cur]) );
  end; { For }

end; { Proc }

{
There's a couple things I should explain: The "ExchangeLongInts" Procedure is
from the TurboPower Opro's OpInline Unit. All it does is exchange two LongInt
Types without you having to use a temporary Variable. It's fast and convenient,
but not the only possible solution here. (I'm Typecasting the Pointer into a
LongInt For a 4-Byte swap.)

"totalItems" is the total number of items in your Array to sort.

"Item" is the actual Array; Item : Array[1..xx] of Pointer_to_Record;

"YourStruct" used in the "Is_Less" Function is Typecasting the actual structure
or Record that "Item" is referring to. It's the only portion of the code which
looks at your actual data. to reverse the sort order, simply change the "<" to
">". to change what is being sorted, just change the ".Item" to something else
like ".Name" or ".Zip" or whatever else might be contained in your structure.

This routine is simple, has a minimum amount of code, Uses very little stack,
works only With Pointers and you are only sorting memory addresses; it never
actually move any of your physical data. (if you did, then it would be slow.)

It'll sort several thousand items in only a couple seconds even on slower
machines, and is super on small volume runs. I would imagine that it would
(90 min left), (H)elp, More? start loosing steam around 1,000 to 2,000 items, but For me, it's the best
choice when memory is at a premium and the Arrays are fairly small.
}


