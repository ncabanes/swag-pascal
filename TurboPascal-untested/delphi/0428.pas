Robert Vivrette - 76416.1373@compuserve.com

Many professional applications  will display data in grid  fields and allow
you to  sort on any  one of the  columns simply by  clicking on the  column
header. Although  what is proposed here  is not the best  way to accomplish
this, it is a fairly simple way to mimic the same behavior.

The key hurdle in  this problem is the DBGrid itself. It  has no OnClick or
OnMouseDown events, so  it really was not designed to  capture this kind of
input. It does  provide an OnDoubleClick, but this  really doesn't work too
well. What we need is a way to make the column headers clickable. Enter the
THeaderControl component.

THeaderControl is  a component that  comes in Delphi  2.0 and provides  the
basic  functions that  we want.  It  can  detect clicks  on its  individual
panels, and  the panels even go  up and down when  pressed (like a button).
The key is to  connect the THeaderControl to the DBGrid. Here  is how it is
done:

First, start a new application. Drop  a THeaderControl on the form. It will
automatically align to the  top edge of the form. Now drop  a DBGrid on the
form  and set  its Align  property  to  alClient. Next,  add a  TTable, and
TDataSource component. Set the Tables  DatabaseName property to DBDEMOS and
its TableName to EVENTS.DB. Set  the DataSource's DataSet property to point
at Table1 and the DBGrid's DataSource property to point to DataSource1. Set
Table's Active property to False in case it has been turned on. Now the fun
begins!

Now we need to setup the THeaderControl component to look like the DBGrid's
column headers. his  will be done in code in  the Form's FormCreate method.
DoubleClick on Form1's OnCreate event and enter the following code:



--------------------------------------------------------------------------------


procedure TForm1.FormCreate(Sender: TObject);
var
  TheCap : String;
  TheWidth,a : Integer;
begin
  DBGrid1.Options := DBGrid1.Options - [dgTitles];
  HeaderControl1.Sections.Add;
  HeaderControl1.Sections.Items[0].Width := 12;
  Table1.Exclusive := True;
  Table1.Active := True;
  For a := 1 to DBGrid1.Columns.Count do
    begin
      with DBGrid1.Columns.Items[a-1] do
        begin
          TheCap := Title.Caption;
          TheWidth := Width;
        end;
      with HeaderControl1.Sections do
        begin
          Add;
          Items[a].Text := TheCap;
          Items[a].Width := TheWidth+1;
          Items[a].MinWidth := TheWidth+1;
          Items[a].MaxWidth := TheWidth+1;
        end;
      try
        Table1.AddIndex(TheCap,TheCap,[]);
      except
        HeaderControl1.Sections.Items[a].AllowClick := False;
      end;
    end;
  Table1.Active := False;
  Table1.Exclusive := False;
  Table1.Active := True;
end;


--------------------------------------------------------------------------------


Since  the THeaderControl  will be  taking the  place of  the Grid's column
headers, we first remove (set to False) the dgTitles option in the DBGrid's
Options property.  Then, we add a  column to the HeaderControl  and set its
width to  12. This will  be a blank  column that is  the same width  as the
Grid's status area on the left.

Next we need to  make sure the Table is opened for  Exclusive use (no other
users can be using it). I will explain why in just a bit.

Now we  add the HeaderControl  sections. For  each  one we add,  we will be
giving it  the same text  as the caption  of that column  in the DBGrid. We
loop through the DBGrid columns, and for each one we copy over the column's
caption and  width. We also  set the HeaderControl's  MinWidth and MaxWidth
properties to  the same as the  column width. This will  prevent the column
from being  resized. If you  need resizeable columns,  you will need  a bit
more code, and I wanted to keep this short and sweet.

Now comes  the interesting part. We  are going to create  an index for each
column in the DBGrid. The name of the index will be the same as the columns
title.  This step  is in  a try..finally  structure because  there are some
fields that cannot be indexed (Blobs & Memos for example). When it tries to
index  on  these  fields,  it  will  generate  an  exception. We catch this
exception and  turn off the ability  to click that column.  This means that
non-indexed columns will not respond to mouse clicks. The creation of these
indexes is why we had to open the table in Exclusive mode. After we are all
done, we close the table, set Exclusive off and reopen then table.

One last  step. When the HeaderControl  is clicked, we need  to turn on the
correct  index for  the  Table.  The HeaderControl's  OnSectionClick method
should be as follows:



--------------------------------------------------------------------------------


procedure TForm1.HeaderControl1SectionClick(
                HeaderControl: THeaderControl;
                Section: THeaderSection);
begin
  Table1.IndexName := Section.Text;
end;


--------------------------------------------------------------------------------


That's it!  When the column is  clicked, the Table's IndexName  property is
set to the same as the HeaderControl's caption.

Pretty  simple, huh?  There is  a lot  of room  for improvement however. It
would be nice if clicking on a  column a second time would reverse the sort
order. Also,  column resizing would  be a nice  added touch. I  am going to
leave these to you folks!

Improvements
The Graphical Gnome <rdb@ktibv.nl>

The improvement over the previous version  is in the usage of the fieldname
as indexname instead of the caption.

This improves the flexibility. Changes are indicated as italics



--------------------------------------------------------------------------------



procedure TfrmDoc.FormCreate(Sender: TObject);
Var
   TheCap    : String;
   TheFn     : String;
   TheWidth  : Integer;
   a         : Integer;
begin
     Dbgrid1.Options := DBGrid1.Options - [DGTitles];
     Headercontrol1.sections.Add;
     Headercontrol1.Sections.Items[0].Width := 12;
     For a := 1 to DBGRID1.Columns.Count do
     begin
        with DBGrid1.Columns.Items[ a - 1 ] do
        begin
           TheFn    := FieldName;
           TheCap   := Title.Caption;
           TheWidth := Width;
        end;
        With Headercontrol1.Sections DO
        BEGIN
          Add;
          Items[a].Text     := TheCap;
          Items[a].Width    := TheWidth + 1;
          Items[a].MinWidth := TheWidth + 1;
          Items[a].MaxWidth := TheWidth + 1;
        END; (* WITH Headercontrol1.Sections *)
        try (* except *)
           { Use indexes with the same name as the fieldname }
           (DataSource1.Dataset as TTable).IndexName := TheFn;   { Try to set the index name }
        except
           HeaderControl1.Sections.Items[a].AllowClick := False; { Index not Available }
        end; (* EXCEPT *)
     END; (* FOR *)
END; (* PROCEDURE *)


--------------------------------------------------------------------------------


Use the fieldname property of the DBGrid to set an index with the same name
as the fieldname.



--------------------------------------------------------------------------------


procedure TfrmDoc.HeaderControl1SectionClick(HeaderControl: THeaderControl;
  Section: THeaderSection);
begin
     (DataSource1.Dataset as TTable).IndexName :=
           DBGrid1.Columns.Items[ Section.Index - 1 ].FieldName;

end;
