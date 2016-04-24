(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0127.PAS
  Description: Multilist implementation of a digraph
  Author: WILLIAM HOBDAY
  Date: 08-30-97  10:08
*)

Unit Graph;  { see test program at the end of this unit !! }

(***************************************************************************)
(*   Name: Graph                                                           *)
(*   Written by: William Hobday                                            *)
(*   Last Modified: September 6, 1991                                      *)
(*                                                                         *)
(*   Description:   This unit is an multilist implementation of a digraph. *)
(*   Each header node contains two lists: one conatining the arcs          *)
(*   emanating from the vertex, and the other terminating at that vertex.  *)
(*   The unit consists of the following documented procedures and          *)
(*   functions:                                                            *)
(*                        NewGraph : Graph                                 *)
(*                        NewVrtx( graph,name ) : vrtx                     *)
(*                        FirstSuccessor( name ) : name                    *)
(*                        NextSuccessor( name,name ) : name                *)
(*                        Adjacent( vrtx,vrtx ) : boolean                  *)
(*                        ArcWeight( vrtx,vrtx ) : weight                  *)
(*                        WtdJoin( vrtx,vrtx,weight )                      *)
(*                        RemoveArc( vrtx,vrtx )                           *)
(*                        PrintGraph( graph )                              *)
(*                        PrintArc( vrtx,vrtx )                            *)
(*                                                                         *)
(***************************************************************************)

Interface

type  Vertex = ^Vertexpointer;
      Arc = ^Arcpointer;

      Arcpointer = record
            Weight: integer;
            Vertex1,
            Vertex2: char;
            Emanate,
            Terminate: Arc
         end;

      Vertexpointer = record
            Name: char;
            Emanate,
            Terminate: Arc;
            Next: Vertex;
            Visited : boolean
         end;


Function NewGraph : Vertex;
Function NewVrtx( var G : Vertex; Name: Char ): Vertex;
Function FirstSuccessor( G : Vertex; Name : char ) : char;
Function NextSuccessor( G : Vertex; Name : char; Successor : char ) : char;
Function GetVertex ( G : Vertex; Name : char ) : Vertex;
Function Adjacent( V1,V2 : Vertex ): boolean;
Function ArcWeight( V1,V2 : Vertex ): integer;
Procedure WtdJoin( V1,V2 : Vertex; Weight : integer );
Procedure RemoveArc( var V1,V2 : Vertex );
Procedure PrintGraph( G : Vertex );
Procedure PrintArc( V1,V2 : Vertex );


Implementation

(***************************************************************************)
(*   Name: NewGraph                                                        *)
(*                                                                         *)
(*   Purposse: This Function returns a pointer to a new empty graph        *)
(*   Input: None                                                           *)
(*   Ouput: A pointer to a new graph                                       *)
(***************************************************************************)

Function NewGraph : Vertex;

begin
   NewGraph := nil
end;



(***************************************************************************)
(*   Name: NewVertex                                                       *)
(*                                                                         *)
(*   Purpose: Adds a new unconnected vertex to the graph                   *)
(*   Uses: NewV - New vertex to be created                                 *)
(*         Temp - Used to search for end of list                           *)
(*   Input: G - Pointer to Graph                                           *)
(*          Name - Name of new vertex                                      *)
(*   Output: Pointer to newly created vertex                               *)
(***************************************************************************)

Function NewVrtx( var G : Vertex; Name : char ) : Vertex;

var NewV,Temp: Vertex;

begin
   new( NewV );
   NewV^.Name := Name;
   NewV^.Emanate := nil;
   NewV^.Terminate := nil;
   NewV^.Next := nil;
   NewV^.Visited := false;
   if G = nil
      then G := NewV
      else begin
              Temp := G;
              while Temp^.Next <> nil do
                 Temp := Temp^.Next;
              Temp^.Next := NewV
           end;
   NewVrtx := NewV
end;



(***************************************************************************)
(*   Name: GetVertex                                                       *)
(*                                                                         *)
(*   Purpose: Given a graph and a vertex name it returns a pointer to the  *)
(*            vertex. Returns nil if vvertex doesn't exist.                *)
(*   Input: G - the graph                                                  *)
(*          Name - Name of vertex to find                                  *)
(*   Output: pointer to vertex found                                       *)
(***************************************************************************)

Function GetVertex( G : Vertex; Name : char) : Vertex;

begin
   while ( G <> nil ) and ( G^.Name <> Name ) do
      G := G^.Next;
   GetVertex := G
end;



(***************************************************************************)
(*   Name: First Successor                                                 *)
(*                                                                         *)
(*   Purpose: Returns the first successor of the given vertex if it exists *)
(*   otherwise it returns a nul(ASCII 0).                                  *)
(*   Input: Name - Name of vertex from which the 1st successor is taken    *)
(*   Output: FirstSuccessor - name to the 1st successor of vertex          *)
(***************************************************************************)

Function FirstSuccessor ( G : Vertex; Name : char ) : char;

var V : Vertex;

begin
   V := GetVertex( G,Name );
   if V = nil
      then FirstSuccessor := #0
      else if V^.Emanate = nil
              then FirstSuccessor := #0
              else FirstSuccessor := V^.Emanate^.Vertex2
end;



(***************************************************************************)
(*   Name: NextSuccessor                                                   *)
(*                                                                         *)
(*   Purpose: Given a vertex and a successor, this returns the next        *)
(*            successor.  Returns the first successor if input parameters  *)
(*            are identical.  Returns nul if does not exist.               *)
(*   Input: G - pointer to list of vertices                                *)
(*          V - Name of vertex from which to find next successor           *)
(*          Name - Name of vertex next successor is to follow              *)
(*   Output: NextSuccessor - Name of the next successor                    *)
(***************************************************************************)

Function NextSuccessor( G : Vertex; Name : char; Successor : char ) : char;

var TempArc : Arc;
    V : Vertex;

begin
   V := GetVertex( G,Name );
   if v <> nil
      then if V^.Name = Successor
              then NextSuccessor := FirstSuccessor( G,Successor )
              else begin
                      TempArc := V^.Emanate;
                      while ( TempArc^.Vertex2 <> Successor ) and ( TempArc <> nil ) do
                         TempArc :=  TempArc^.Emanate;
                      if TempArc = nil
                         then NextSuccessor := #0
                         else if TempArc^.Emanate <> nil
                                 then NextSuccessor := TempArc^.Emanate^.Vertex2
                                 else NextSuccessor := #0
                   end
      else NextSuccessor := #0
end;



(***************************************************************************)
(*   Name: Adjacent                                                        *)
(*                                                                         *)
(*   Purpose: Boolean function which returns true if given vertices are    *)
(*            adjacent.                                                    *)
(*   Input: V1,V2 - Vertices to check for arc                              *)
(*   Output: Adjacent - Result of function                                 *)
(***************************************************************************)

Function Adjacent( V1,V2 : Vertex ) : boolean;

var TempArc : Arc;

begin
   if ( V1^.Emanate = nil )  or ( V2^.Emanate = nil ) or ( V1 = nil ) or ( v2 =nil)
      then Adjacent := false
      else begin
              TempArc := V1^.Emanate;
              while (TempArc <> nil) and (V2^.Name <> TempArc^.Vertex2) do
                 TempArc := TempArc^.Emanate;
              if TempArc^.Vertex2 = V2^.Name
                 then Adjacent := true
                 else Adjacent := false
           end;
end;



(***************************************************************************)
(*   Name: ArcWeight                                                       *)
(*                                                                         *)
(*   Purpose: Returns the weight of the arc between V1 and V2 providing    *)
(*            that it exists.  Returns a Zero otherwise.                   *)
(*   Input: V1,V2 - vertices to check for arc                              *)
(*   Output: ArcWeight - the weight of the arc if it exists                *)
(***************************************************************************)

Function ArcWeight( V1,V2 : Vertex ) : integer;

var TempV : Arc;

begin
   if ( V1^.Emanate = nil ) or ( V2^.Terminate = nil ) or ( not Adjacent( V1,V2 ) )
      then ArcWeight := 0
      else begin
              TempV := V1^.Emanate;
              while (V2^.Name <> TempV^.Vertex2) do
                 TempV := TempV^.Emanate;
              ArcWeight := TempV^.Weight
           end;
end;



(***************************************************************************)
(*   Name: WtdJoin                                                         *)
(*                                                                         *)
(*   Purpose: Creates a weighted arc between V1 and V2 of weight Weight    *)
(*   Input: V1,V2 - Vertices to connect                                    *)
(*          Weight - the weight of the new arc                             *)
(*   Output: None                                                          *)
(***************************************************************************)

Procedure WtdJoin( V1,V2 : Vertex; Weight : Integer );

var NewArc, Temp : Arc;

begin
   if not Adjacent( V1,V2 )
      then begin
              New( NewArc );
              NewArc^.Weight := Weight;
              NewArc^.Vertex1 := V1^.Name;
              NewArc^.Vertex2 := V2^.Name;
              NewArc^.Emanate := nil;
              NewArc^.Terminate := nil;
              Temp := V1^.Emanate;
              if Temp = nil
                 then V1^.Emanate := NewArc
                 else begin
                         while Temp^.Emanate <> nil do
                            Temp := Temp^.Emanate;
                         Temp^.Emanate := NewArc;
                      end;
              Temp := V2^.Terminate;
              if Temp = nil
                 then V2^.Terminate := NewArc
                 else begin
                         while Temp^.Terminate <> nil do
                            Temp := Temp^.Terminate;
                         Temp^.Terminate := NewArc;
                      end
           end
end;



(***************************************************************************)
(*   Name: RemoveArc                                                       *)
(*                                                                         *)
(*   Purpose: Removes the Arc from V1 to V2 if it exists                   *)
(*   Input: V1,V2 - Vertices of arc to be removed                          *)
(*   Output: None                                                          *)
(***************************************************************************)

Procedure RemoveArc( var V1,V2 : Vertex );

var Temp,Temp2 : Arc;

begin
   if Adjacent( V1,V2 )
      then begin
              Temp := V1^.Emanate;
              if Temp^.Vertex2 = V2^.Name
                 then V1^.Emanate := Temp^.Emanate
                 else begin
                         while Temp^.Emanate^.Vertex2 <> V2^.Name do
                            Temp := Temp^.Emanate;
                         Temp2 := Temp^.Emanate;
                         Temp^.Emanate := Temp2^.Emanate
                      end;
              Temp := V2^.Terminate;
              if Temp^.Vertex1 = V1^.Name
                 then V2^.Terminate := Temp^.Terminate
                 else begin
                         while Temp^.Terminate^.Vertex1 <> V1^.Name do
                            Temp := Temp^.Terminate;
                         Temp2 := Temp^.Terminate;
                         Temp^.Terminate := Temp2^.Terminate
                      end
           end
end;



(***************************************************************************)
(*   Name: PrintGraph                                                      *)
(*                                                                         *)
(*   Purpose: Prints an adjacency matrix for the graph                     *)
(*   Input: G - First Vertex in linked vertex list of graph                *)
(*   Output: Copy of the adjacency matrix for the graph                    *)
(***************************************************************************)

Procedure PrintGraph( G: Vertex );

var Temp,Temp2 : Vertex;
    Count,Loop : integer;

begin
   if G = nil
      then writeln('The Graph does not exist!')
      else begin
              Count := 0;
              Temp := G;
              write('    ');
              while Temp <> nil do
                 begin
                    write(Temp^.Name,' ');
                    Temp := Temp^.Next;
                    inc(Count)
                 end;
              writeln;
              write('  ┌─');
              for Loop := 1 to Count do
                 write('──');
              writeln;
              Temp := G;
              while Temp <> nil do
                 begin
                    Temp2 := G;
                    write(Temp^.Name,' │');
                    while Temp2 <> nil do
                       begin
                          if adjacent( Temp,Temp2 )
                             then write(' 1')
                             else write(' 0');
                          Temp2 := Temp2^.Next;
                       end;
                    Temp := Temp^.Next;
                    writeln
                 end
           end
end;



(***************************************************************************)
(*   Name: PrintArc                                                        *)
(*                                                                         *)
(*   Purpose: Prints the name and weight of the arc between V1 and V2      *)
(*   Input: V1,V2 - Vertices of the arc to be printed                      *)
(*   Output: Name and weight of the arc                                    *)
(***************************************************************************)

Procedure PrintArc( V1,V2 : Vertex );

begin
   if Adjacent( V1,V2 )
      then writeln( V1^.Name,' ',V2^.Name,' ',ArcWeight( V1,V2 ))
      else writeln('PrintArc Error --- Arc ',V1^.Name,',',V2^.Name,' does not exist ---');
end;

end.

{ ----------------  DEMO  -----------  CUT HERE --------- }

Program Testgraph;

uses graph,crt;

var A,B,C,D,E,F,Ga,H,I,J,temp : Vertex;
    sh : arc;
    ch : char;
    x: integer;
    G: Vertex;

begin
   clrscr;
   G := NewGraph;
   ch := 'A';
   A := NewVrtx(G,CH);
   ch := 'B';
   B := NewVrtx(G,CH);
   ch := 'C';
   C := NewVrtx(g,ch);
   ch := 'D';
   D := NewVrtx(g,ch);
   ch := 'E';
   E := NewVrtx(G,CH);
   ch := 'F';
   F := NewVrtx(G,CH);
   ch := 'G';
   Ga := NewVrtx(g,ch);
   ch := 'H';
   H := NewVrtx(g,ch);
   ch := 'I';
   I := NewVrtx(g,ch);
   ch := 'J';
   J := NewVrtx(g,ch);
   WtdJoin(A,B,1);
   wtdjoin(B,A,1);
   wtdjoin(B,C,2);
   wtdjoin(C,B,2);
   WtdJoin(C,D,3);
   wtdjoin(D,C,3);
   wtdjoin(E,F,2);
   wtdjoin(F,E,2);
   WtdJoin(F,Ga,3);
   wtdjoin(Ga,F,3);
   wtdjoin(H,I,5);
   wtdjoin(I,H,5);
   WtdJoin(A,E,4);
   wtdjoin(E,A,4);
   wtdjoin(E,H,3);
   wtdjoin(H,E,3);
   WtdJoin(H,J,2);
   wtdjoin(J,H,2);
   wtdjoin(B,F,4);
   wtdjoin(F,B,4);
   WtdJoin(F,I,1);
   wtdjoin(I,F,1);
   wtdjoin(C,Ga,5);
   wtdjoin(Ga,C,5);
   WtdJoin(D,Ga,4);
   wtdjoin(Ga,D,4);
   wtdjoin(Ga,I,5);
   wtdjoin(I,Ga,5);
   WtdJoin(I,J,6);
   wtdjoin(J,I,6);
   wtdjoin(C,F,1);
   wtdjoin(F,C,1);
   wtdjoin(H,F,3);
   wtdjoin(F,H,3);
   wtdjoin(B,E,7);
   WtdJoin(e,B,7) ;
   writeln(FirstSuccessor(G,'F')^.name);
   writeln(NextSuccessor(G,f,'C')^.name);
   PrintGraph(G);
{   while G <> nil do
      begin
         writeln('Vertix ',G^.Name);
         sh:=g^.emanate;
         while sh<>nil do
            begin
               write(sh^.vertex1,',',sh^.vertex2,' ',sh^.weight,'   ');
               sh := sh^.emanate;
            end;
         Writeln;
         G := G^.Next
      end}
end.

