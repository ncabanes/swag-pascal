{


The IndexDefs property of the TTable component contains information about
the indexes for the table used by the TTable. The IndexDefs property
itself has various properties that allow for the extraction of information
about specific indexes. The two properties in the IndexDefs object are:
 
  Count: type Integer; available only at run-time and read-only; indicates
         the number ofentries in the Items property (i.e., the number of
         indexes in the table).
  Items: type TIndexDef; available only at run-time and read-only; an
         array of TIndexDef objects, one for each index in the table.
         
The Count property of the IndexDefs object is used as the basis for a
loop program construct to iterate through the Items property entries to
extract specific information about each index. Each IndexDef object con-
tained in the Items property consists of a number of properties that pro-
vide various bits of information that describe each index. All of the
properties of the IndexDef object are available only at run-time and are
all read-only. These properties are:
 
  Expression: type String; indicates the expression used for dBASE multi-
              field indexes.
  Fields:     type String; indicates the field or fields upon which the
              index is based.
  Name:       type String; name of the index.
  Options:    type TIndexOptions; characteristics of the index (ixPrimary,
              ixUnique, etc.).
 
Before any index information (Count or Items) can be accessed, the Update
method of the IndexDefs object must be called. This refreshes or init-
ializes the IndexDef object's view of the set of indexes.
 
Examples
========
 
Here is a simple For loop based on the Count property of the IndexDefs
object that extracts the name of each index (if any exist) for the table
represented by the TTable component Table1:
}

  procedure TForm1.ListBtnClick(Sender: TObject);
  var
    i: Integer;
  begin
    ListBox1.Items.Clear;
    with Table1 do begin
      if IndexDefs.Count > 0 then begin
        for i := 0 to IndexDefs.Count - 1 do
          ListBox1.Items.Add(IndexDefs.Items[i].Name)
      end;
    end;
  end;
 
Below is an example showing how to extract information about indexes at
run-time, plugging the extracted values into a TStringGrid (named SG1).
 
  procedure TForm1.FormShow(Sender: TObject);
  var
    i: Integer;
    S: String;
  begin
    with Table1 do begin
      Open;
      {Refresh IndexDefs object}
      IndexDefs.Update;
      if IndexDefs.Count > 0 then begin
        {Set up columns and rows in grid to match IndexDefs items}
        SG1.ColCount := 4;
        SG1.RowCount := IndexDefs.Count + 1;
        {Set grid column labels to TIndexDef property names}
        SG1.Cells[0, 0] := 'Name';
        SG1.ColWidths[0] := 200;
        SG1.Cells[1, 0] := 'Fields';
        SG1.ColWidths[1] := 200;
        SG1.Cells[2, 0] := 'Expression';
        SG1.ColWidths[2] := 200;
        SG1.Cells[3, 0] := 'Options';
        SG1.ColWidths[3] := 300;

        {Loop through IndexDefs.Items}
        for i := 0 to IndexDefs.Count - 1 do begin
          {Fill grid cells for current row}
          SG1.Cells[0, i + 1] := IndexDefs.Items[i].Name;
          SG1.Cells[1, i + 1] := IndexDefs.Items[i].Fields;
          SG1.Cells[2, i + 1] := IndexDefs.Items[i].Expression;
          if ixPrimary in IndexDefs.Items[i].Options then
            S := 'ixPrimary, ';
          if ixUnique in IndexDefs.Items[i].Options then
            S := S + 'ixUnique, ';
          if ixDescending in IndexDefs.Items[i].Options then
            S := S + 'ixDescending, ';
          if ixCaseInsensitive in IndexDefs.Items[i].Options then
            S := S + 'ixCaseInsensitive, ';
          if ixExpression in IndexDefs.Items[i].Options then
            S := S + 'ixExpression, ';
          if S > ' ' then begin
            {Get rid of trailing ", "}
            System.Delete(S, Length(S) - 1, 2);
            SG1.Cells[3, i + 1] := S;
          end;
        end;
      end;
    end;
  end;
 
Special Considerations
======================
 
There are idiosyncracies associated with extracting information about
indexes for different table types that Delphi can access.
 
dBASE Tables
------------
 
With dBASE indexes, which properties of Fields and Expression will be
filled will depend on the type of index, simple (single-field) or
complex (based on multiple fields or a dBASE expression). If the index
is a simple one, the Fields property will contain the name of the field
in the table on which the index is based and the Expression property will
be blank. If the index is a complex one, the Expression property will
show the expression on which the index is based (e.g., "Field1+Field2")
and the Fields property will be blank.
 
Paradox Tables
--------------
 
With Paradox primary indexes, the Name property will be blank, the Fields
property will contain the field(s) on which the index is based, and the
Options property will contain ixPrimary. With secondary indexes, the Name
property will contain the name of the secondary index, the Fields prop-
erty will contain the field(s) on which the index is based, and the
Options property may or may not have values.
 
The Fields property for indexes based on more than one field will show
the field names separated by semi-colons. Indexes based on only a single
field will show the name of only that one field in the Fields property.

InterBase Tables
----------------
 
For both index types, single- or multiple-field, the Expression property
will be blank. For single-field indexes, the Fields property will contain
the field on which the index is based. For multi-field indexes, the Fields
property will show all of the multiple fields that comprise the index,
each separated by a semi-colon. 
 
Indexes designated as PRIMARY when the CREATE TABLE command is issued will
have "RDB$PRIMARYn" in the Name property, where n is a number character
uniquely identifying the primary index within the database metadata.
Secondary indexes will show the actual name of the index.
 
Foreign key constraints also result in an index being created by the sys-
tem. These indexes appear in the IndexDefs property, and will have the
name "RDB$FOREIGNn" where n is a number character that uniquely identifies
the index within the database metadata.

The Fields property for indexes based on more than one field will show
the field names separated by semi-colons. Indexes based on only a single
field will show the name of only that one field in the Fields property.

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


DISCLAIMER: You have the right to use this technical information
subject to the terms of the No-Nonsense License Statement that
you received with the Borland product to which this information
pertains.
