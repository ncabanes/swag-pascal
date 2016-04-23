--------------------------------------------------------------------------------
Here's a function that will check if a given string exist in a string list.
You can use it when you want to add only the unique strings to any object
with a string list property such as list boxes, memos, etc.

function StrIsInList(
  sl             : TStrings;
  s              : string;
  bCaseSensitive : boolean )
    : boolean;
var
  n : integer;
begin
  Result := False;
  if( not bCaseSensitive )then
    s := LowerCase( s );  
  for n := 0 to ( sl.Count - 1 ) do
  begin
    if( ( bCaseSensitive and
        ( s = LowerCase(
                sl.Strings[ n ] ) ) )
         or ( s = sl.Strings[ n ] )
      )then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

//
// example on how to use StrIsInList()
//
procedure
  TForm1.Button1Click(Sender: TObject);
begin
  if( not StrIsInList( ListBox1.Items,
                    Edit1.Text, False ) ) then
    ListBox1.Items.Add( Edit1.Text );
end;
