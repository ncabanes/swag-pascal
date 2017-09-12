(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0026.PAS
  Description: Sorting Linked Lists
  Author: LEE BARKER
  Date: 08-25-94  09:10
*)

{
│ I'm looking for a routine to swap two nodes in a double
│ linked list or a complete sort.

There has been a thread on the TP conf area in CIS on quick
sorting a (double) linked list. To swap two nodes, remove one,
then add it in where desired. Quick sample-
}

type
  s5       = string[5];
  ntp      = ^nodetype;
  nodetype = record
               prv,nxt : ntp;
               data    : s5;
             end;
const
  nbr : array[0..9] of string[5] = ('ZERO','ONE','TWO',
        'THREE','FOUR','FIVE','SIX','SEVEN','EIGHT','NINE');
var
  node,root : ntp;
  i : integer;

procedure swap (var n1,n2 : ntp);
  var n : ntp;
  begin
    n := n1;
    n1 := n2;
    n2 := n;
  end;

procedure addnode (var n1,n2 : ntp);
  begin
    swap(n1^.nxt,n2^.prv^.nxt);
    swap(n1^.prv,n2^.prv);
  end;

procedure getnode(i:integer);
  var n : ntp;
  begin
    getmem(n,sizeof(nodetype));
    n^.nxt := n;
    n^.prv := n;
    n^.data := nbr[i];
    if root=nil
    then root := n
    else addnode(n,root);
  end;

begin
  root := nil;
  for i := 0 to 9 do
  begin
    getnode(i);
    node := root;
    writeln;
    writeln('The linked now is-');
    repeat
      writeln(node^.data);
      node := node^.nxt;
    until node = root;
  end;
end.
