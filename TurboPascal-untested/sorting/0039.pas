{
IAN LIN

My pride and joy, this baby sorts FAST! This is For anyone who wants an
example of code For sorting linked lists.
}

{$A+,B-,D+,E-,F-,G+,I-,L+,N-,O-,R-,S+,V-,X-}
{$M 4096,0,655360}

Procedure Theend; {could you think of a better name???}
begin
  Writeln('Assassin Technologies, NetRunner.');
  {members: Ian Lin, Martin Young, William Parslow, Scott Rogers; just a new
   Programming group, that's all.}
  halt; {duh, kinda obvious you need to end the Program. :) }
end;

Type
  prec  = ^rec;
  dType = String[96]; {put what you want here, it's fast anyhow}
  rec   = Record
    d : dType;
    n : prec;       {"next" field"}
 end;

Var
  max, c : Word;    {maximum # of elements; Counter}
  list,
  list2,
  node,
  node2  : prec;    {first and second lists, temporary Pointers to nodes in the lists}
  ram    : Pointer; {save heap state For use With mark/release}

begin
  max := memavail div sizeof(dType); {this takes too long but is THE maximum}
  max := 675;          {I picked this at random--it sorts in 2 seconds or so}
  Exitproc := @Theend; {just to be fancy}
  randomize;
  mark(ram);
  new(list);           {create list}
  list^.d := Char(random(10) + 48); {put something in it}
  node := list;
  For c := 2 to max do
  begin
    new(node^.n);
    node := node^.n;
    node^.n := nil;
    node^.d := Char(random(10) + 48);
  end;

  new(list2);         {begin NEW sorted list}
  list2^.n := list;   {steal the first node of list For list2}
  list := list^.n;
  list2^.n^.n := nil;
  While list <> nil do
  begin               {now steal 'em all and add them in order}
    node  := list;    {point node to first node in LIST}
    list  := list^.n; {advance LIST Pointer one node, first node is now seperate}
    node2 := list2;   {ready to use NODE2 to find the correct entry point}
    While (node2^.n <> nil) and (node^.d > node2^.n^.d) do
      node2 := node2^.n; {advance NODE2 as needed Until it marks the
                          right place For NODE to be inserted}
    node^.n  := node2^.n;{insert NODE into the new list, in the correct order}
    node2^.n := node;    {connect node to the previous nodes in new list, if any}
  end;
  list := list2^.n;      {point LIST back to the top of the list, now in order}

  node := list;          {the rest is just to display it}
  Write('List: ');
  While node <> nil do
  begin                  {as usual (at least With me), NIL is the end}
    Write(node^.d);
    node := node^.n;
  end;
  Writeln;
  release(ram);          {give all heap RAM back}
end.
