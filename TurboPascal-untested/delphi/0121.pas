
Q:  How do I pass a variable to a query?

A:  First, you must write a query that uses a variable.

Select Test."FName", Test."Salary Of Employee"
From Test
Where Test."Salary of Employee" > :val

Note:  If you just write the field name as 
"Salary of Employee" you will get a Capability Not
Supported error.  It must be Test."Salary of Employee".

In this can the variable name is "val", but it can be whatever 
you want (of course).  Then, you go to the TQuery's params 
property and set the "val" parameter to whatever the 
appropriate type is. In our example here we will call it an 
integer.

Next, you write the code that sets the parameter's value.  
We will be setting the value from a TEdit box.

procedure TForm1.Button1Click(Sender: TObject);
begin
  with Query1 do
  begin
    Close;
    ParamByName('val').AsInteger := StrToInt(Edit1.Text);
    Open;
  end;
end;


Note:  you may want to place this code in a try..except 
block as a safety precaution.

If you want to use a LIKE in your query, you can do
it this way:

Note:  This next section uses the customer table from
the \delphi\demos\data directory.  It can also be 
referenced by using the DBDEMOS alias.

SQL code within the TQuery.SQL property:

  SELECT * FROM CUSTOMER
  WHERE Company LIKE :CompanyName


Delphi code:

procedure TForm1.Button1Click(Sender: TObject);
begin
  with Query1 do
  begin
    Close;
    ParamByName('CompanyName').AsString := Edit1.Text + '%';
    Open;
  end;
end;

An alternate way of referencing a parameter 
(other then ParamByName) is params[TheParameterNumber].  

The way that this line:

    ParamByName('CompanyName').AsString := Edit1.Text + '%';

can be alternately written is:

    Params[0].AsString := Edit1.Text + '%';


The trick to the wildcard is in the concatenating of the
percentage sign at the end of the parameter.
