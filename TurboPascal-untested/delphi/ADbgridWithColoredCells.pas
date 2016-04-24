(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0418.PAS
  Description: A Dbgrid with colored cells ?
  Author: ED HILLMANN
  Date: 01-02-98  07:34
*)


Ed_P._Hillmann@mail.amsinc.com (Ed Hillmann)

I don't know if this helps, but I could color individual cells in a DBGrid without having to make a new DBGrid component. This is what I just tested.... 
I created a form, dropped a TTable component it, and pointed it to the EMPLOYEE.DB database in the DBDEMOS database. I dropped a Datasource and DBGrid on the form so that it showed on the form.

I thought a simple test would be, for the employee number in the EMPLOYEE.DB table, check if it's an odd number. If it's an odd number, then turn that cell green.

Then, the only code I attached was to the DBGrid's OnDrawColumnCell event, which looks as follows....



--------------------------------------------------------------------------------

procedure TForm1.DBGrid1DrawColumnCell(Sender: TObject; const Rect:
TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  holdColor: TColor;
begin
  holdColor := DBGrid1.Canvas.Brush.Color; {store the original color}
  if Column.FieldName = 'EmpNo' then {only do for the cell displaying
EmpNo}
    if (Column.Field.AsInteger mod 2 <> 0) then begin
      DBGrid1.Canvas.Brush.Color := clGreen;
      DBGrid1.DefaultDrawColumnCell(Rect, DataCol, Column, State);
      DBGrid1.Canvas.Brush.Color := holdColor;
    end;
end;

--------------------------------------------------------------------------------
This uses the DefaultDrawColumnCell method that is defined with the TCustomDBGrid component, of which TDBGrid is a child. This turned each cell green of an employee whose emp no was odd. 

