Program BFT;

(*****************************************************************************)
(*   Name:  BFT                                                              *)
(*   Written by: William Hobday                                              *)
(*   Last modified: March 5, 1989                                            *)
(*                                                                           *)
(*   Purpose: Implements the Bredth First traversal algorithm using the      *)
(*            Graph, Tree, and Q units.  The following program produces BFT  *)
(*            traversals of the following graphs starting from node C:       *)
(*                                                                           *)
(*                    Graph 1                   Graph 2                      *)
(*                                                                           *)
(*                  A - B - C - D              A - B   C                     *)
(*                   \ / \ / \ /                                             *)
(*                    E - F - G                                              *)
(*                     \ / \ /                                               *)
(*                      H - I                                                *)
(*                       \ /                                                 *)
(*                        J                                                  *)
(*                                                                           *)
(*            In case the adjacency graph as well as the corresponding       *)
(*            spanning tree is printed.                                      *)
(*                                                                           *)
(*****************************************************************************)

uses graph,Q,tree,crt; { graph is in math.swg
                         q is in pointers.swg !! }

var A,B,C,D,E,F,G,H,I,J,K,L,M : Vertex;
    Grph1,Grph2: Vertex;



(*****************************************************************************)
(*   Name: Visit                                                             *)
(*                                                                           *)
(*   Purpose: Visits node by adding vertex to tree and placing it in the Q   *)
(*            then marking the node as visited.                              *)
(*   Input: Grph - The graph                                                 *)
(*          VertexQ - the queue                                              *)
(*          Father - the tree node to be added to                            *)
(*          Name - name of the vertex to visit                               *)
(*   Output: the modifed graph and queue                                     *)
(*****************************************************************************)

Procedure Visit( Grph : Vertex; var VertexQ : Queue; Father : TreeNode; Name: char );

begin
   AddTreeNode( Father,Name );
   GetVertex( Grph,Name )^.visited := true;
   EnQueue( VertexQ,Name );
end;



(*****************************************************************************)
(*   Name: SelectFatherNode                                                  *)
(*                                                                           *)
(*   Purpose:  Given a father node it test to see if it the valid one for    *)
(*             when inserting into the tree.                                 *)
(*   Input: Father - node to check                                           *)
(*   Output: pointer to selected node                                        *)
(*****************************************************************************)

Function SelectFatherNode( Father : TreeNode ) : TreeNode;

begin
   if Father^.Son = nil
      then begin
              Father := Father^.Parent;
              if Father^.brother = nil
                 then SelectFatherNode := Firstchild( father )
                 else SelectFatherNode := NextSibling( father )
           end
      else SelectFatherNode := FirstChild( father )
end;



(*****************************************************************************)
(*   Name: SelectGraphNode                                                   *)
(*                                                                           *)
(*   Purpose: Given the graph it selects the next Node that has not been     *)
(*            visited.                                                       *)
(*   Input: Grph - pointer to start of graph                                 *)
(*   Output: pointer to selected node                                        *)
(*****************************************************************************)

Function SelectGraphNode( Grph : Vertex ) : Vertex;

begin
   While (Grph^.visited = True) and (Grph <> nil) do
      Grph := Grph^.Next;
   SelectGraphNode := Grph
end;



(*****************************************************************************)
(*   Name: BFTraverse                                                        *)
(*                                                                           *)
(*   Purpose:  Given a graph and starting vertex this procedure produces a   *)
(*             spanning tree of the Breadth First Traversal of the graph.    *)
(*   Input: Grph - the start of the graph                                    *)
(*          V - the vertex to start traversal at                             *)
(*   Output: The spanning tree produce by the BFT                            *)
(*****************************************************************************)

Procedure BFTraverse( Grph : Vertex; V : Vertex);

var Name,Name2 : char;
    VertexQ: Queue;
    BFTree,Father : TreeNode;

begin
   NewQueue( VertexQ );
   while V <> nil do
         begin
            BFTree := NewTree( V^.Name );
            Father := BFTree;
            V^.Visited := true;
            EnQueue( VertexQ,V^.Name );
            while not empty( VertexQ ) do
               begin
                  Name := DeQueue( vertexQ );
                  Name2 := FirstSuccessor( Grph,Name );
                  while Name2 <> #0 do
                     begin
                        if not GetVertex( Grph,Name2 )^.visited
                           then Visit( Grph,VertexQ,Father,Name2 );
                        Name2 := NextSuccessor( Grph,Name,Name2 );
                     end;
                  Father := SelectFatherNode( Father )
               end;
            writeln('BFT Spanning Tree');
            writeln('─────────────────');
            PrintTree( BFTree );
            writeln('─────────────────');
            writeln;
            V := SelectGraphNode( Grph )
      end
end;




begin
   Grph1 := NewGraph;                                (* Initialize graphs *)
   Grph2 := NewGraph;
   A := NewVrtx(Grph1,'A');                          (* Add Vertices *)
   B := NewVrtx(Grph1,'B');
   C := NewVrtx(Grph1,'C');
   D := NewVrtx(Grph1,'D');
   E := NewVrtx(Grph1,'E');
   F := NewVrtx(Grph1,'F');
   G := NewVrtx(Grph1,'G');
   H := NewVrtx(Grph1,'H');
   I := NewVrtx(Grph1,'I');
   J := NewVrtx(Grph1,'J');
   K := NewVrtx(Grph2,'A');
   L := NewVrtx(Grph2,'B');
   M := NewVrtx(Grph2,'C');
   WtdJoin(A,B,1);                                   (* Join vertices *)
   WtdJoin(A,E,4);
   WtdJoin(B,A,1);
   WtdJoin(B,C,2);
   WtdJoin(B,F,4);
   WtdJoin(B,E,7);
   WtdJoin(C,B,2);
   WtdJoin(C,D,3);
   WtdJoin(C,G,5);
   WtdJoin(C,F,1);
   WtdJoin(D,C,3);
   WtdJoin(D,G,4);
   WtdJoin(E,F,2);
   WtdJoin(E,A,4);
   WtdJoin(E,H,3);
   WtdJoin(E,B,7);
   WtdJoin(F,E,2);
   WtdJoin(F,G,3);
   WtdJoin(F,B,4);
   WtdJoin(F,I,1);
   WtdJoin(F,C,1);
   WtdJoin(F,H,3);
   WtdJoin(G,F,3);
   WtdJoin(G,C,5);
   WtdJoin(G,D,4);
   WtdJoin(G,I,5);
   WtdJoin(H,I,5);
   WtdJoin(H,E,3);
   WtdJoin(H,J,2);
   WtdJoin(H,F,3);
   WtdJoin(I,H,5);
   WtdJoin(I,F,1);
   WtdJoin(I,G,5);
   WtdJoin(I,J,6);
   WtdJoin(J,H,2);
   WtdJoin(J,I,6);
   WtdJoin(K,L,1);
   WtdJoin(L,K,1);
   ClrScr;                                           (* display graph 1 *)
   writeln('                         Graph 1');
   BFTraverse( Grph1,c );
   Window(40,2,80,25);
   writeln('Adjacency Matrix');
   writeln('────────────────');
   writeln;
   PrintGraph( Grph1 );
   delay(5000);
   Window(1,1,80,25);                                (* display graph 2 *)
   ClrScr;
   writeln('                         Graph 2');
   BFTraverse( Grph2,k );
   Window(40,2,80,25);
   writeln('Adjacency Matrix');
   writeln('────────────────');
   writeln;
   PrintGraph( Grph2 )
end.
