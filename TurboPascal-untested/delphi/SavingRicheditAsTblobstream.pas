(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0344.PAS
  Description: Saving Richedit as tBlobStream
  Author: MIKE BARDILL
  Date: 01-02-98  07:33
*)

From: Mike Bardill <rrmike@minster.york.ac.uk>


Saving a TRichEdit to a file and storing the file is a perfectly good way
of saving the data to the table, but the same can be achieved without an
intermediate file by using a TBlobStream. The example below is for reading
a TRichEdit from a table, but a similar approach 'in reverse' with a
bmWrite will save into the table.


--------------------------------------------------------------------------------


procedure ReadRichEditFromTable(Table : TTable; var RichEdit : TRichEdit);
var
  BlobStream : TBlobStream;
begin
  try
    BlobStream := TBlobStream.Create(Table.FieldByName('BODY') as TBlobField, bmRead);
    if (not Table.FieldByName('BLOBFieldName').IsNull) then
    begin
      RichEdit.Lines.LoadFromStream (BlobStream);
    end;
  finally
    BlobStream.Free;
  end;
end;

