
We all like the "Object Inspector" for its ease of use and all the
information it can provide. Wouldn't it be great to have your own possibly
non-visual object inspector available at run time? -- so you can find out
which properties and methods a given object (or component) may have and
what type these properties are. Try the following function:

procedure ObjectInspector(
  Obj   : TObject;
  Items : TStrings );
var
  n        : integer;
  PropList : TPropList;
begin
  n := 0;
  GetPropList(
    Obj.ClassInfo,
    tkProperties + [ tkMethod ],
    @PropList );
  while( (Nil <> PropList[ n ]) and
         (n < High(PropList)) ) do
  begin
    Items.Add(
      PropList[ n ].Name + ': '  +
      PropList[ n ].PropType.Name );
    Inc( n );
  end;
end;


For example, let's say you want to get information about a listbox named
ListBox1 and then store the information in the same ListBox1:

ObjectInspector( ListBox1, ListBox1.Items );
