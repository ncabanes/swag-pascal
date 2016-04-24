(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0193.PAS
  Description: Pascal code for the Skyline problem
  Author: SVETLANA KRYUKOVA
  Date: 11-29-96  08:17
*)

program skyline_problem;

{ Programmed by:  Svetlana Kryukova
  Programmed on:  May 19, 1993
}

{-------------------------------------------------------------------------}
const 
   MaxR = 20;                 { maximum number of rectangleSkyline }
   MaxSkylineSize = 79;       { 4*MaxR - 1, maximum size of the Skyline }

type
   skyline = array [1..MaxSkylineSize] of integer;
   Rectangle = array [1..3] of integer;
   Skylines  = array [1..MaxR] of Rectangle;
   problem_t = record
                Points : Skylines;
                size : integer;
             end;
   solution_t = record
                Points : skyline;
                size : integer;
             end;

{-------------------------------------------------------------------------}
function Base_Case(Buildings: problem_t):boolean;
	{ Precondition: Buildings is some problem, such that 
			Buildings.size >= 0 and Buildings.Points is an
			array of buildings presented by the array of their
			coordinates in the form (x1 y1 x2 y2 ... xn) }
	{ Postcondition: return value Base_Case is true if and only if
			Buildings is a base-case problem 
			(Buildings.size = 1) }
begin
  Base_Case := (Buildings.size = 1);
end;

{-------------------------------------------------------------------------}
procedure Find_Base_Case_Solution(var Buildings: problem_t; 
				  var Skyline : solution_t);
	{ Precondition: Buildings is a base-case problem, such that
			Buildings.size = 1 }
	{ Postcondition: Skyline is a correct solution to the problem 
			Buildings such that 
			Skyline.Points = Buildings.Points[1] }
var
   i : integer;
begin
  for i := 1 to 3 do
     Skyline.Points[i] := Buildings.Points[1][i];
  Skyline.size := 3;
end;

{-------------------------------------------------------------------------}
procedure Split(var Buildings, LeftBuildings, RightBuildings: problem_t);
	{ Precondition : Buildings is an array of buildings, presented by
			 an array of coordinates.  Building.size > 1
	  Postcondition: LeftBuildings and RightBuildings are arrays of 
			 buidings and together they are 
			 some permutation of the array Buildings and
			 |LeftBuildings.size - RightBuildings.size| <= 1 }
var
   i : integer;
begin
 LeftBuildings.size := Buildings.size div 2;
 RightBuildings.size := Buildings.size - Buildings.size div 2; 
	{Assertion :  |LeftBuildings.size - RightBuildings.size| <= 1 }

 for i := 1 to LeftBuildings.size do
      LeftBuildings.Points[i] := Buildings.Points[i];
	{ Assertion: 	for all i such that 1 <= i <= LeftBuildings.size 
			LeftBuildings[i] = Buildings[i] }

 for i := LeftBuildings.size + 1 to Buildings.size do
      RightBuildings.Points[i - LeftBuildings.size] := Buildings.Points[i]; 
	{ Assertion: 	for all i such that 1 <= i <= RightBuildings.size 
			RightBuildings[i] = Buildings[i]+LeftBuildings.size }
end;
   
{-------------------------------------------------------------------------}
procedure Merge(var LeftSkyline, RightSkyline, Skyline : solution_t);
	{ Precondition : LeftSkyline and RightSkyline are two arrays of
			 coordinates presenting two skyline,
	  Postcondition: Skyline is a common skyline for two LeftSkyline
			 and RightSkyline }

var i, 		{ pointSkyline to the first unprocessed abscissa of skyline 1 }
    j, 		{ pointSkyline to the first unprocessed abcsissa of skyline 2 }
    m: integer;
    k : 1..2;
    CurHeightLeftSkyline, CurHeightRightSkyline, CurHeight: integer;

begin
  i := 1;
  j := 1;
  Skyline.size := 0;
  CurHeightLeftSkyline := 0;
  CurHeightRightSkyline := 0;
  CurHeight := 0;
  k := 1;
  while (i <= LeftSkyline.size) and (j <= RightSkyline.size) do
      if LeftSkyline.Points[i] < RightSkyline.Points[j] then 
         begin
           if i < LeftSkyline.size then 
			CurHeightLeftSkyline := LeftSkyline.Points[i+1] 
           else CurHeightLeftSkyline := 0;
           if k = 1 then
               if CurHeightLeftSkyline >= CurHeightRightSkyline then
                   begin
                      Skyline.Points[Skyline.size+1] := LeftSkyline.Points[i];
                      Skyline.Points[Skyline.size+2] := CurHeightLeftSkyline;
                      CurHeight := CurHeightLeftSkyline;
                      Skyline.size := Skyline.size + 2;  
                   end
               else
                   begin
                      k := 2;
                      if CurHeightRightSkyline < CurHeight then
                          begin
                              Skyline.Points[Skyline.size+1] :=
						LeftSkyline.Points[i];
                              Skyline.Points[Skyline.size+2] := 
						CurHeightRightSkyline;
                              CurHeight := CurHeightRightSkyline;
                              Skyline.size := Skyline.size + 2;
                          end; 
                   end
            else if CurHeightLeftSkyline > CurHeight then
               begin
                 Skyline.Points[Skyline.size+1] := LeftSkyline.Points[i]; 
                 Skyline.Points[Skyline.size+2] := CurHeightLeftSkyline;
                 CurHeight := CurHeightLeftSkyline;
                 k := 1;
                 Skyline.size := Skyline.size + 2;
               end;
           i := i + 2;
         end { if LeftSkyline.Points[i] < RightSkyline.Points[j] }
      else if LeftSkyline.Points[i] > RightSkyline.Points[j] then begin
              if j < RightSkyline.size then 
			CurHeightRightSkyline := RightSkyline.Points[j+1] 
              else CurHeightRightSkyline := 0;
              if k = 2 then 
		if CurHeightRightSkyline >= CurHeightLeftSkyline then begin
                         Skyline.Points[Skyline.size+1] :=
					 RightSkyline.Points[j];
                         Skyline.Points[Skyline.size+2] := 
					 CurHeightRightSkyline;
                         CurHeight := CurHeightRightSkyline;
                         Skyline.size := Skyline.size + 2;  
              end else begin
                         k := 1;
                         if CurHeightLeftSkyline < CurHeight then begin
                              Skyline.Points[Skyline.size+1] :=
					 RightSkyline.Points[j];
                              Skyline.Points[Skyline.size+2] := 
					CurHeightLeftSkyline;
                              CurHeight := CurHeightLeftSkyline;
                              Skyline.size := Skyline.size + 2;
                         end; 
              end else if CurHeightRightSkyline > CurHeight then begin
                 Skyline.Points[Skyline.size+1] := RightSkyline.Points[j]; 
                 Skyline.Points[Skyline.size+2] := CurHeightRightSkyline;
                 CurHeight := CurHeightRightSkyline;
                 k := 2;
                 Skyline.size := Skyline.size + 2;
          end;
           j := j + 2;
      end { if LeftSkyline.Points[i] > RightSkyline.Points[j] }
           else begin
                if i < LeftSkyline.size then CurHeightLeftSkyline := 
					LeftSkyline.Points[i+1] 
                else CurHeightLeftSkyline := 0;
                if j < RightSkyline.size then 
			CurHeightRightSkyline := RightSkyline.Points[j+1] 
                else CurHeightRightSkyline := 0;
                if CurHeightLeftSkyline >= CurHeightRightSkyline then begin
                     k := 1;
                     if CurHeightLeftSkyline <> CurHeight then begin
                          Skyline.Points[Skyline.size+1] := 
						LeftSkyline.Points[i];
                          if (i<>LeftSkyline.size) or (j<>RightSkyline.size) 
							then begin
				Skyline.Points[Skyline.size+2] := 
						CurHeightLeftSkyline;
				Skyline.size := Skyline.size + 1
			  end;
                          CurHeight := CurHeightLeftSkyline;
                          Skyline.size := Skyline.size + 1;
                     end;
                end else begin
                     k := 2;
                     if CurHeightRightSkyline <> CurHeight then begin
                          Skyline.Points[Skyline.size+1] := 
					RightSkyline.Points[j];
                          Skyline.Points[Skyline.size+2] := 
					CurHeightRightSkyline;
                          CurHeight := CurHeightRightSkyline;
                          Skyline.size := Skyline.size + 2;
                     end; 
                end;
              i := i + 2;
              j := j + 2;
         end;
  for m := i to LeftSkyline.size do begin
       	Skyline.Points[Skyline.size+1] := LeftSkyline.Points[m]; 
	Skyline.size := Skyline.size + 1;
  end;
  for m := j to RightSkyline.size do begin
       	Skyline.Points[Skyline.size+1] := RightSkyline.Points[m]; 
	Skyline.size := Skyline.size + 1; 
  end;
end;

{-------------------------------------------------------------------------}
procedure Find_Skyline(var Buildings : problem_t;
                       var Skyline : solution_t);
var
   LeftBuildings, RightBuildings : problem_t;
   LeftSkyline, RightSkyline : solution_t;
begin
 if Base_Case(Buildings) then
     Find_Base_Case_Solution(Buildings, Skyline)
  else 
     begin
       Split(Buildings, LeftBuildings, RightBuildings);
       Find_Skyline(LeftBuildings, LeftSkyline);
       Find_Skyline(RightBuildings, RightSkyline); 
       Merge(LeftSkyline, RightSkyline, Skyline);
     end;
end;


{-------------------------------------------------------------------------}
procedure GetProblem(var Buildings : problem_t);
var
    i, j : integer;
begin
  write(output, ' Enter the number of buildings in the City: ');
  readln(input, Buildings.size);
  write(output, 
	' Enter only three coordinates for each building, x1 y x2, ');
  writeln (output, 'representing ');
  writeln (output, '        the building (x1,0),(x1,y),(x2,y) & (x2,0)');
  writeln (output, ' (LIMITATIONS: x in [0..300], y in [0..170])');
  writeln (output);
  for i := 1 to Buildings.size do
     begin
       write(output, ' Enter building#', i:1, ' coordinates: ');
       for j := 1 to 3 do
          read(input, Buildings.Points[i][j]);
     end;
end;

{-------------------------------------------------------------------------}
procedure DisplayProblem (var Buildings: problem_t);
var k : integer;
begin
  writeln('==========================================');
  writeln(' Problem is a collection of ', Buildings.size:0, ' builings :');
  for k := 1 to Buildings.size do 
	writeln('      Rectangle #', k:0, ' has coordinates : ', 
		Buildings.Points[k][1]:0, ' ', Buildings.Points[k][2]:0, ' ',
		Buildings.Points[k][3]:0);
end;

{-------------------------------------------------------------------------}
procedure DisplaySolution (var Skyline: solution_t);
var k : integer;
begin
  writeln('= = = = = = = = = = = = = = = = = = = = = ');
  writeln(' Solution is a skyline of size ', Skyline.size:0);
  for k := 1 to Skyline.size do 
	if (k mod 2) = 1 then writeln('       x', ((k - 1)div 2 + 1):0, ' = ', 
						Skyline.Points[k]:0)
	else writeln('       y', ((k-1) div 2 + 1):0, ' = ', Skyline.Points[k]:0);
end;


{-------------------------------------------------------------------------}
procedure SolveOneProblem;
var
   Buildings : problem_t;
   Skyline : solution_t;
begin
      GetProblem(Buildings);
      DisplayProblem(Buildings); 
      Find_Skyline(Buildings, Skyline);
      DisplaySolution(Skyline);
end;

{-------------------------------------------------------------------------}
begin
   SolveOneProblem;
end.


