{
From: Bschor@vms.cis.pitt.edu

> Now the problem. "Seek(F, I)" will only take ONE integer at a time!!
> Naturally I need two. I'm trying to run it so that at each virtual
> "square" a user can define a different message, monster, etc. And the
> file i'm writing to must be able to define between X & Y, [(1,2) for
> example], or both of them togeter [E.G. Two steps to the right, two steps
> forward = (2,2)]. HOW DO I DO THIS???

If I understand the question correctly, you are asking how to map a
two-dimensional structure (a 2-D map of your world) into a 1-dimensional
data structure (a file).  Ah, my ancient Fortran knowledge does come in
useful ...

The following works for arrays of any dimension, though you need to
have the array size fixed.  Suppose you have dimensioned World into R rows,
C columns, and L layers (I'm doing 3-D, just to show how it can be done).
To make it all very clear, I'll define the world as either a 3-D or linear
structure, using the Pascal Variant Record type.
}

CONST
 rows = 30;
 columns = 40;
 layers = 5;
 rooms = 6000; { rows * columns * layers }
TYPE
 rowtype = 1 .. rows;
 columntype = 1 .. columns;
 layertype = 1 .. layers;
 roomnumbertype = 1 .. rooms;
 roomtype = RECORD
 { you define as needed }
 END;
 worldtype = RECORD
 CASE (d3, d1) of
 d3 : (spatial: ARRAY [layertype, rowtype, columntype] OF roomtype);
 d1 : (linear : ARRAY [roomnumbertype] OF roomtype);
 END;
{
     Basically, you determine an order you wish to store the data.  Suppose
you say "Start with the first layer, the first row, the first column.
March across the columns, then move down a row and repeat across the
columns; when you finish a layer, move down to the next layer and repeat".

     Clearly Layer 1, Row 1, Column C maps to Room C.  Since each row has
"columns" columns, then the mapping of Layer 1, Row R, Column C is to
Room (R-1)*columns + C.  The full mapping is --
}
  FUNCTION roomnumber (layer : layertype; row : rowtype;
   column : columntype) : roomnumbertype;

  BEGIN   { roomnumber }
   roomnumber := column + pred(row)*columns + pred(layer)*columns*rows
  END;

{     Note you can also map in the other direction:}

  FUNCTION layer (roomnumber : roomnumbertype) : layertype;

  BEGIN   { layer }
   layer := succ (pred(roomnumber) DIV (columns * rows))
  END;

  FUNCTION row (roomnumber : roomnumbertype) : rowtype;

  BEGIN   { row }
   row := succ ((pred(roomnumber) MOD (columns * rows)) DIV columns)
  END;

  FUNCTION column (roomnumber : roomnumbertype) : columntype;

  BEGIN   { column }
   column := succ (pred(roomnumber) MOD columns)
  END;

{
     Putting it all together, suppose you have a room, "room", with room
number "roomnumber", that you want to put into the world.
}
 VAR world : worldtype;
     room : roomtype;
     roomnumber : roomnumbertype;

 WITH world DO
  BEGIN
   spatial[layer(roomnumber), row(roomnumber), column(roomnumber)] := room
  END;
{
     The above fragment stores a room into the three-dimensional world.
Of course, if you know the room number (which we do), you can also simply
}

 WITH world DO linear[roomnumber] := room
{
     For the original question, note that the "roomnumber" function gives
you the record number for the Seek procedure (you may need to offset by 1,
depending on how Seek is implemented ...).
}
