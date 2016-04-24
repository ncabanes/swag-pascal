(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0008.PAS
  Description: TREEHITE.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:54
*)

{
Authors: Chet Kress and Jerome Tonneson

>Help !!! I need a Function or Procedure in standard pascal that will
>calculate the height of a binary tree. It must be able to calculate the
>height of the tree if the tree is either balanced, unbalanced or full.
>The Procedure must be recursive.

Here are the only two Functions you will need.
}

Function Max(A, B : Integer) : Integer;
begin {Max}
  If A > B then
    Max := A;
  else
    Max := B;
end; {Max}

Function Height (Tree : TreeType) : Integer;
begin {Height}
  If Tree = Nil then
    Height := 0
  else
    Height := Max(Height(Tree^.Right), Height(Tree^.Left)) + 1;
end; {Height}

