{
There are a number of reasons why a program might need to query the
structure of a table used in the application. One reason is a prelude to
creating TField components at run-time that represent the fields in the
table. The information gleaned from the structure of the table form the
basis of the TField components to be created.

The example below demonstrates how to iterate through the fields available
in a TTable or TQuery. The example extracts information about the available
fields and displays the information in a TListBox, but the same methodology
can be used to provide information necessary for the dynamic building of
TField descendants. The example uses a TTable as the data set, but a TQuery
can be used in the same manner as both TTable and TQuery components incorp-
orate the Field-Defs property the same way.
}

procedure TForm1.Button1Click(Sender: TObject);
var
  i: Integer;
  F: TFieldDef;
  D: String;
begin
  Table1.Active := True;
  ListBox1.Items.Clear;
  with Table1 do begin
    for i := 0 to FieldDefs.Count - 1 do begin
      F := FieldDefs.Items[i];
      case F.DataType of
        ftUnknown: D := 'Unknown';
        ftString: D := 'String';
        ftSmallint: D := 'SmallInt';
        ftInteger: D := 'Integer';
        ftWord: D := 'Word';
        ftBoolean: D := 'Boolean';
        ftFloat: D := 'Float';
        ftCurrency: D := 'Currency';
        ftBCD: D := 'BCD';
        ftDate: D := 'Date';
        ftTime: D := 'Time';
        ftDateTime: D := 'DateTime';
        ftBytes: D := 'Bytes';
        ftVarBytes: D := '';
        ftBlob: D := 'BLOB';
        ftMemo: D := 'Memo';
        ftGraphic: D := 'Graphic';
      else
        D := '';
      end;
      ListBox1.Items.Add(F.Name + ', ' + D);
    end;
  end;
  Table1.Active := False;
end;
 
 
 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


DISCLAIMER: You have the right to use this technical information
subject to the terms of the No-Nonsense License Statement that
you received with the Borland product to which this information
pertains.
