{
I have a game I would like to make a PD project.  It's a war game, based on
older style equipment, i.e., no nukes and such.  I haven't worked on it in
several years, though.  I would like to make it multi node, or multi player
somehow.  I think it would make a perfect object of discussion.  It's written
in Pascal and was originally started in 4.0.  It needs to be re-written into
objects and the code updated througout.  (My programming habits have changed
significally, I may make less errors now, but, when I do, they are really
stupid.)

Coordinating movements will be a challenge in a multi node system.

the logic would need to be changed, i.e., the movement directions, to
accomodate ASCII characters that would represent the playing peices..

Here is code for a grid system I wrote...
}

Program FillGrid;

{ example of filling a hex sided grid with data about itself and it's
  neighbors.

 Written By:  Herbert Brown and released to the public domain (1993)
 please give credit were credit is due.. }

uses
  dos,
  crt;  { only for debugging }

const
  MaxRows    = 7;
  MaxColumns = 5;
  MaxHex     = 32;   { only used for array and testing }

type
  grid = record
    id, nw, ne,
    w, e, se, sw,
    TerrainRec   : Longint;  { can be used as a reference to a database}
  end;

var
  GridVar     : Array [1..MaxHex] of grid;
  gridCounter : Longint;
  RowCounter,
  ColCounter,
  EndColumn   : Longint;
  OddRow,
  finished    : Boolean;
  CurrentGrid : grid;
  x           : integer;


procedure getit(ColCounter, RowCounter, GridCounter, MaxColumns,
                MaxRows : Longint; Var CurrentGrid : grid);

begin
  CurrentGrid.id := gridcounter;

  { The 9 possible cases tested Middle tested first for speed because there
    are more of these in large maps }

  {middle}
  if ((colcounter > 1) and (colcounter < EndColumn)) then
  if (rowcounter <> 1) and (rowcounter <> maxrows) then
  begin
    CurrentGrid.nw := (gridcounter-MaxColumns);
    CurrentGrid.w  := (gridcounter-1);
    CurrentGrid.sw := (gridcounter+MaxColumns)-1;
    CurrentGrid.se := gridcounter+maxColumns;
    CurrentGrid.e  := gridcounter+1;
    CurrentGrid.ne := (gridcounter-MaxColumns)+1;
    exit;
  end;

  {leftedge}
  if (colcounter = 1) and (rowcounter <> 1) then
  if (rowcounter <> maxrows) then
  begin
    if oddrow then
      CurrentGrid.nw := (gridcounter-MaxColumns)
    else
      CurrentGrid.nw := 0;   { }
    CurrentGrid.w  := 0;
    if oddrow then
      CurrentGrid.sw := (gridcounter+MaxColumns)-1
    else
      CurrentGrid.sw := 0;
    CurrentGrid.se  := gridcounter+maxColumns;
    CurrentGrid.e   := gridcounter+1;
    CurrentGrid.ne  := (gridcounter-MaxColumns)+1;
    exit;
  end;

  {rightedge}
  if (colcounter = EndColumn) and (rowcounter <> 1) then
  if (rowcounter <> maxrows) then
  begin
    CurrentGrid.nw := (gridcounter-MaxColumns);
    CurrentGrid.w  := (gridcounter-1);
    CurrentGrid.sw := (gridcounter+MaxColumns)-1;
    if oddrow then
      CurrentGrid.se := gridcounter+maxColumns
    else
      CurrentGrid.se := 0;
    CurrentGrid.e  := 0;
    if oddrow then
      CurrentGrid.ne := (gridcounter-MaxColumns)+1
    else
      CurrentGrid.ne := 0;
    exit;
  end;

  {toprow}
  if (rowcounter = 1) and (colcounter <> 1) then
  if (colcounter <> maxcolumns) then
  begin
    CurrentGrid.nw := 0;
    CurrentGrid.w  := (gridcounter-1);
    CurrentGrid.sw := (gridcounter+MaxColumns)-1;
    CurrentGrid.se := gridcounter+maxColumns;
    CurrentGrid.e  := gridcounter+1;
    CurrentGrid.ne := 0;
    exit;
  end;

  {BottomRow}
  if (rowcounter = maxrows) and (colcounter <> 1) then
  if (colcounter <> maxcolumns)  then
  begin
    CurrentGrid.nw := (gridcounter-MaxColumns);
    CurrentGrid.w  := (gridcounter-1);
    CurrentGrid.sw := 0;
    CurrentGrid.se := 0;
    CurrentGrid.e  := gridcounter+1;
    CurrentGrid.ne := (gridcounter-MaxColumns)+1;
    exit;
  end;


  {TopLeftCorner}
  if (colcounter = 1) and (rowcounter = 1) then
  begin
    CurrentGrid.nw := 0;  { Can't leave edge! }
    CurrentGrid.w  := 0;
    CurrentGrid.sw := 0;
    CurrentGrid.se := gridcounter+maxColumns;
    CurrentGrid.e  := gridcounter+1;
    CurrentGrid.ne := 0;
    exit;
  end;

  {toprightcorner}
  if (rowcounter = 1) and (colcounter = maxcolumns) then
  begin
    CurrentGrid.nw := 0;
    CurrentGrid.w  := (gridcounter-1);
    CurrentGrid.sw := (gridcounter+MaxColumns)-1;
    CurrentGrid.se := 0;
    CurrentGrid.e  := 0;
    CurrentGrid.ne := 0;
    exit;
  end;

  {bottomleftCorner}
  if (colcounter = 1) and (rowcounter = maxrows) then
  begin
    CurrentGrid.nw := 0;
    CurrentGrid.w  := 0;
    CurrentGrid.sw := 0;
    CurrentGrid.se := 0;
    CurrentGrid.e  := gridcounter+1;
    CurrentGrid.ne := (gridcounter-MaxColumns)+1;
    exit;
  end;

  {BottomRightCorner}
  if (colcounter = maxcolumns) and (rowcounter = maxrows) then
  begin
    CurrentGrid.nw := (gridcounter-MaxColumns);
    CurrentGrid.w  := (gridcounter-1);
    CurrentGrid.sw := 0;
    CurrentGrid.se := 0;
    CurrentGrid.e  := 0;
    CurrentGrid.ne := 0;
    exit;
  end;

end;

begin
  clrscr;
  { fill the record array out for debugging or "watch" purposes
    this loop was only used for debugging }
  for x := 1 to MaxHex do
  begin
    GridVar[x].id := 0;
    gridvar[x].nw := 0;
    gridvar[x].ne := 0;
    gridvar[x].w  := 0;
    gridvar[x].e  := 0;
    gridvar[x].se := 0;
    gridvar[x].sw := 0;
    gridVar[x].TerrainRec:=0;
  end;

  fillchar(CurrentGrid,sizeof(currentgrid),0);
  GridCounter := 1;
  RowCounter:=1;
  ColCounter:=1;
  Oddrow:=False;
  Finished := False;
  EndColumn := MaxColumns;

  while not finished do
  begin { while }
    getit(ColCounter,RowCounter,GridCounter,MaxColumns,MaxRows,CurrentGrid);
    gridvar[gridcounter]:=CurrentGrid;  { <- can be stored to a vitual array or
                                         data base file here }
    Inc(ColCounter);    { next grid id }
    Inc(gridCounter);
    if colcounter = EndColumn+1 then
    begin
      Oddrow := not oddrow;
      ColCounter:=1;
      if rowcounter = MaxRows then
        finished := True;
      inc(rowcounter);  { next row }
      if not oddrow then
        EndColumn := MaxColumns
      else
        EndColumn := MaxColumns - 1;
    end;
  end;
end.
