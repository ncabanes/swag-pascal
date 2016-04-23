
Filling dblistboxs and dbcomboboxs

Most of Delphi's data aware components will  populate 
themselves after they are wired up to a open dataset.  However 
DbListboxs and DbComboboxs do not display this characteristic.  
These two components are not for displaying your datasets, but 
filling them.  Use of these components is straight forward.  
When you update your table, the value of the DbListbox or 
DbCombobox will be posted in the appropriate field.

Filling the DbCombobox or DbListbox the same as filling normal 
comboboxs or listboxes.  The lines of text in a listbox or 
combobox are really a tstring list.  The "Items" property of 
the given component holds this list.  Use the "Add" method for 
adding items to a tstring. If you want to use data  types other 
than strings they must be converted at run time. If your list 
has a blank line at the end, consider setting the 
"IntegralHeight" property to True.


Filling a DbListbox with 4 lines programmatically might look 
similar to this:

     DbListbox1.items.add('line one');
     DbListbox1.items.add('line two');
     DbListbox1.items.add('line three');
     DbListbox1.items.add('line four');

Filling a DbListbox at design time requires using the object 
inspector.  By double clicking on the components "Items" 
property, you can bring up the "String List Editor" and input 
the desired rows.

Unfortunately, if a combobox is filled this way, there is not 
default value.  Setting a DbComboboxs "text" property will 
achieve this result.  (the "text" property is not available in 
the object inspector, so it must be set programmatically).
Setting the default value to the first value in the
DbCombobox's list looks like this:

DbCombobox1.text := DbCombobox1.items[0];

Often it is useful to fill a DBListBox from a dataset.  This 
can be done using loop:

procedure TForm1.FormCreate(Sender: TObject);
begin
  with table2 do begin
    open;
    while not EOF do
    begin
      DBlistbox1.items.add(FieldByName('name').AsString); 
      next;
    end;
  end;
end;
