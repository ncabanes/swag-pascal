{

Peterborough, Ontario, CANADA

Hi !

  If any of you boys have been reading BYTE magazine, you may have
  noticed an article in the Dec/93 issue on Directory objects (in
  C++ however). I was keenly interested in this article, because it
  showed a quick and easy way to handle directory recursion - which
  was necessary for a project I was doing.

  While the complete code listings weren't given, they were in C so
  I couldn't use them directly anyways, so I just wrote my own
  object in TP. (Works great, btw)

  I've decided to wake this conference up a bit so I'm going to post
  this stuff over the next couple of days. The first installment is
  the SORT unit which implements a binary-tree sorting object for
  the sort method of the directory object. This object is completely
  re-usable and extendable (designed so from the ground up) and
  helps demonstrate more uses for OOP.
----------------------------------------------------------------------
}
Unit SORT;

INTERFACE

TYPE
   comparefunc = function(d1, d2 :pointer):integer;
                             { function returns sort value for data  }
   ptree    = ^treenode;
   treenode = record
      data  :pointer;
      left,
      right :ptree;
   end;
                              { ****** Abstract sort object ******
                                         Must be inherited
                              }
   pSortTree = ^oSortTree;
   oSortTree = OBJECT
      root    :ptree;
      comp    :comparefunc;

      constructor Init(cf :comparefunc);
      destructor  Done;

      procedure   InsertNode(n :pointer);
      procedure   DeleteNode(var Node); virtual; { abstract }
      function    ReadLeftNode:pointer;
   end;

IMPLEMENTATION

constructor  oSortTree.Init(cf :comparefunc);
begin
   FillChar(self, SizeOf(self), #0); { zero out object data }
   comp := cf; { set "compare" function to user defined far-local }
end;

destructor   oSortTree.Done;

   procedure disposetree(var t :ptree);
   begin
      if t=NIL then
         EXIT;
      disposetree(t^.left);
      disposetree(t^.right);
      DeleteNode(t^.data);
      dispose(t);
   end;

begin
   disposetree(root);
end;

procedure    oSortTree.InsertNode(n :pointer);
   { Insert the data pointer in sorted order, as defined by the
     passed "compare" function
   }
   procedure recursetree(var t :ptree);

      procedure PutNode(node :ptree);
      begin
         node^.right := NIL;
         node^.left  := NIL;
         node^.data  := n;
      end;

   begin
      if comp(n, t^.data)>0 then
      begin
         if t^.right<>NIL then
            recursetree(t^.right)
         else
         begin
            New(t^.right);
            PutNode(t^.right);
         end;
      end
      else
      begin
         if t^.left<>NIL then
            recursetree(t^.left)
         else
         begin
            New(t^.left);
            PutNode(t^.left);
         end;
      end;
   end;

begin
   if n<>NIL then
      if root=NIL then
      begin
         New(root);
         root^.left  := NIL;
         root^.right := NIL;
         root^.data  := n;
      end
      else
         recursetree(root);
end;

procedure    oSortTree.DeleteNode(var Node);
   { The calling code must define how to dispose of the data field
     by inheritance }
begin
   Halt(255); {abstract method}
end;

function     oSortTree.ReadLeftNode:pointer;
   { This function is intended to be called one-at-a-time to recover
     data in sorted order. The data is returned as an untyped
     pointer. It is assumed that the calling code will type the
     pointer as required. The data pointer is set to NIL after being
     passed to the caller. }
var
   ln :pointer;

   procedure recurseTree(var t :pTree;var result :pointer);
   begin
      if t^.left<>NIL then
      begin
         recurseTree(t^.left, result);
         if result=NIL then
         begin
            result  := t^.data;
            t^.data := NIL;
         end;
      end
      else
      begin
         if t^.data<>NIL then
         begin
            result  := t^.data;
            t^.data := NIL;
         end
         else
            if t^.right<>NIL then
            begin
               recurseTree(t^.right, result);
               if result=NIL then
               begin
                  dispose(t);
                  t := NIL;
               end
            end
            else
            begin
               dispose(t);
               t := NIL;
               result := NIL;
            end;
      end;
   end;

begin
   if root<>NIL then
   begin
      recurseTree(root, ln);
      ReadLeftNode := ln;
   end
   else
      ReadLeftNode := NIL;
end;

END.
