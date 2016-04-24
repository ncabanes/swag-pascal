(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0046.PAS
  Description: Binary Tree module
  Author: SWAG SUPPORT TEAM
  Date: 08-30-97  10:08
*)

Unit Tree; { see test program at the end !! }

(***************************************************************************)
(*   Unit Name: Tree                                                       *)
(*                                                                         *)
(*   Description:   This unit implements a tree based data structure using *)
(*   pointers to connect the nodes.  Each node of the tree consists of     *)
(*   pointers to its parent, brother, and son.  In addition each node      *)
(*   contains a label field.  The following functions are used and         *)
(*   documented:                                                           *)
(*                   NewTree : tree                                        *)
(*                   AddTreeNode(node,label)                               *)
(*                   DeleteTreeNode(node)                                  *)
(*                   Parent(node):node                                     *)
(*                   FirstChild(node):node                                 *)
(*                   NextSibling(node):node                                *)
(*                   PrintTree(tree)                                       *)
(*                                                                         *)
(***************************************************************************)

Interface

type TreeNode = ^TreePointer;
     TreePointer = record
           Name: char;
           Parent,
           Brother,
           Son: TreeNode;
        end;


Function NewTree( Name : char ) : TreeNode;
Function Root( Tree : TreeNode ) : TreeNode;
Function Parent( Node: TreeNode ) : TreeNode;
Function NextSibling( Node: TreeNode ) : TreeNode;
Function FirstChild( Node: TreeNode ) : TreeNode;
Procedure AddTreeNode( Node: TreeNode; Name: char );
Procedure DeleteTreeNode( Node: TreeNode );
Procedure PrintTree( Tree : TreeNode );


Implementation

(***************************************************************************)
(*    Name: NewTree                                                        *)
(*                                                                         *)
(*    Purpose:  This function creates a new empty tree                     *)
(*    Input:   None                                                        *)
(*    Ouput:   Pointer to new tree                                         *)
(***************************************************************************)

Function NewTree( Name : char ) : TreeNode;

var Root : TreeNode;

begin
   New(root);
   Root^.Name := Name;
   Root^.Parent := nil;
   Root^.Brother := nil;
   Root^.Son := nil;
   NewTree := Root
end;



(***************************************************************************)
(*   Name: Root                                                            *)
(*                                                                         *)
(*   Purpose: Returns the root of the given tree                           *)
(*   Input: Tree - pointer of the first node of tree                       *)
(*   Output: pointer to the first nodee of the tree (I.E. the root)        *)
(***************************************************************************)

Function Root( Tree : TreeNode ) : TreeNode;

begin
   Root := Tree;
end;



(***************************************************************************)
(*   Name: AddTreeNode                                                     *)
(*                                                                         *)
(*   Purpose: This function creates a new tree node with the given value   *)
(*            as a son of the given node                                   *)
(*   Input: Parent of node to be inserted                                  *)
(*          Value for new node                                             *)
(*   Output: Pointer to the new node                                       *)
(***************************************************************************)

Procedure AddTreeNode( Node: TreeNode; Name: char );

var NewNode: TreeNode;

begin
   if Node <> nil
      then begin
              New(NewNode);
              NewNode^.Name := Name;
              NewNode^.Parent := Node;
              NewNode^.Brother := nil;
              NewNode^.Son := nil;
              if Node^.Son <> nil
                 then begin
                         Node := Node^.Son;
                         while Node^.Brother <> nil do
                            Node := Node^.Brother;
                         Node^.Brother := NewNode
                      end
                 else Node^.Son := NewNode
           end
      else writeln('AddTreeNode Error --- Given node does not exist ---');
end;



(***************************************************************************)
(*   Name: Parent                                                          *)
(*                                                                         *)
(*   Purpose: Returns the parent of the given node if it exists otherwise  *)
(*            it returns a nil pointer.                                    *)
(*   Input: Pointer to given node                                          *)
(*   Output: Pointer to parent of given node                               *)
(***************************************************************************)

Function Parent( Node: TreeNode ) : TreeNode;

begin
   Parent := Node^.Parent
end;



(***************************************************************************)
(*   Name: FirstChild                                                      *)
(*                                                                         *)
(*   Purpose: Returns pointer to left most child of given node if it       *)
(*            exists otherwise returns nil                                 *)
(*   Input: Pointer to given node                                          *)
(*   Output: Pointer to firstchild of given node                           *)
(***************************************************************************)

Function FirstChild( Node: TreeNode ) : TreeNode;

begin
   FirstChild := Node^.Son
end;



(***************************************************************************)
(*   Name: NextSibling                                                     *)
(*                                                                         *)
(*   Purpose: Returns pointer to the first sibling of the given node if it *)
(*            otherwise it returns nil                                     *)
(*   Input: Pointer to given node                                          *)
(*   Output: Pointer to first sibling                                      *)
(***************************************************************************)

Function NextSibling( Node: TreeNode ) : TreeNode;

begin
   NextSibling := Node^.Brother
end;



(***************************************************************************)
(*   Name: DeleteTreeNode                                                  *)
(*                                                                         *)
(*   Purpose: Removes a leaf node from the tree                            *)
(*   Input: Pointer to node to be deleted                                  *)
(*   Output: None                                                          *)
(***************************************************************************)

Procedure DeleteTreeNode( Node: TreeNode );

var N,M: TreeNode;

begin
   if Node <> nil
      then if Node^.Son = nil
              then begin
                      N := Node^.Parent;
                      if N^.Son = Node
                         then if Node^.Brother = nil
                                then N^.Son := nil
                                else N^.Son := Node^.Brother
                         else begin
                                 N := N^.Son;
                                 while N^.Brother <> Node do
                                    N := N^.Brother;
                                 M := N^.Brother;
                                 N^.Brother := M^.Brother
                              end
                   end
end;




(***************************************************************************)
(*   Name: PrintTree                                                       *)
(*                                                                         *)
(*   Purpose:  To print a preorder traversal of the given tree             *)
(*   Uses: Level - depth in tree                                               *)
(*   Input: Pointer to root of tree                                        *)
(*   Output: Printout of tree in preorder                                  *)
(***************************************************************************)

Procedure PrintTree( Tree : TreeNode );

var Level: integer;



   (************************************************************************)
   (*   Name: Traverse                                                     *)
   (*                                                                      *)
   (*   Purpose: a recursive procedure that prints the tree in preorder    *)
   (*   Input: Level - how far to indent data output                       *)
   (*          Node - Node to traverse                                     *)
   (*   Output: Node data                                                  *)
   (************************************************************************)

   Procedure Traverse( Node : TreeNode; var Level : integer );

   var Loop : integer;

   begin
      if Node <> nil
         then with Node^ do
                 begin
                    for Loop := 1 to Level do
                        write('  ');
                    writeln( Name );
                    inc( Level );
                    Traverse( Son,Level );
                    dec( Level );
                    Traverse( Brother,Level );
                 end
   end;

begin
   Level := 0;
   writeln('      Level');
   writeln('0 1 2 3 4 5 6 7 8');
   writeln('─────────────────');
   Traverse( Tree,Level )
end;

end.

Program testtree;

uses tree,crt;

var root : t;
    n,m: TreePointer;
    x: integer;

Begin
   x:=999;
   root:=NewTree(x);
   x:=123;
   AddTreeNode(root^,x);
   x:=456;
   AddtreeNode(root^,x);
   x:=567;
   AddtreeNode(root^,x);
   x:=765;
   addtreenode(Firstchild(root^),x);
   x:=678;
   addtreenode(Firstchild(root^),x);
   x:=159;
   addtreenode(Firstchild(Firstchild(root^)),x);
   x:=259;
   addtreenode(Firstchild(Firstchild(root^)),x);
   x:=359;
   addtreenode(Firstchild(Firstchild(root^)),x);
   x:=169;
   addtreenode(Firstchild(Firstchild(root^))^.brother,x);
   x:=269;
   addtreenode(Firstchild(Firstchild(root^))^.brother,x);
   x:=369;
   addtreenode(Firstchild(Firstchild(root^))^.brother,x);
   x:=789;
   addtreenode(Firstchild(root^),x);
   x:=888;
   addtreenode(firstchild(root^)^.brother,x);
   x:=777;
   addtreenode(firstchild(root^)^.brother,x);
   x:=555;
   addtreenode(firstchild(root^)^.brother^.brother,x);
   x:=444;
   addtreenode(firstchild(root^)^.brother^.brother,x);
   clrscr;
   writeln('Tree:');
   printtree(root);
end.

