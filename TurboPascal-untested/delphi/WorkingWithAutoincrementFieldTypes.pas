(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0122.PAS
  Description: Working With Auto-increment Field Types
  Author: SWAG SUPPORT TEAM
  Date: 02-21-96  21:04
*)


In Delphi applications, the use of tables containing fields that
autoincrement, or change automatically in some manner unknown to
the application, can be problematic.  Paradox, InterBase, Sybase
and Informix tables all provide means of inserting or updating
field values automatically, without intervention from the front-
end application.  Not every table operation is affected by this
mechanism, however.  So, this document will attempt to provide a
guideline for dealing with issues relating to the use of such
field types in Paradox 5.0, Informix 5.x, MS/Sybase SQL Server
4.x, InterBase 4.0 and Local InterBase tables.

For each table type, a different mechanism provides this
behind-the-scenes behavior.  Paradox tables support an
Autoincrement field type.  When new records are added to such
tables, the Borland Database Engine determines the highest
current value in that column, adds one, and updates the new row
with the new value.

For Informix tables, this behavior is provided by an
Informix-specific field type called Serial.  Serial columns
differ from Paradox Autoincrement fields in that their values may
be changed, while Autoincrement columns are read-only.

InterBase and MS/Sybase SQL Server tables do not support a special
type for this kind of behavior, but may employ triggers to
accomplish the same task.  Triggers are specialized procedures
that reside on the database server and automatically execute in
response to events such as table inserts, updates and deletes.
The use of tables with associated triggers can be particularly
problematic, since triggers are capable of doing much more than
just incrementing column values.

The three areas that are affected by these field types are simple
inserts, batchmoves, and table linking.


Handling Update and/or Append BatchMoves
-----------------------------------------------------------------
Paradox Tables

Since the Autoincrement field type is a read-only type,
attempting to perform a batchmove operation with such a column in
the destination table may cause an error.  To circumvent this,
the TBatchMove components Mappings property must be set to match
source table fields to the target destination fields excluding
the destination table's Autoincrement field.

Informix Tables

Batch moving rows to Informix tables with Serial columns will not
cause an error in and of itself.  However, caution should be used
since Serial columns are updateable and are often used as primary
keys.

InterBase Tables
MS/Sybase SQL Server Tables

Triggers on InterBase and SQL Server tables may catch any
improper changes made to the table, but this depends strictly
upon the checks placed in the trigger.  Here again, caution
should be used since trigger-updated columns are often used as
primary keys.


Linking Tables via MasterSource & MasterFields
-----------------------------------------------------------------

Paradox Tables
Informix Tables

If the MasterFields and MasterSource properties are used to
create linked tables in a master-detail relationship and one of
the fields in the detail table is an Autoincrement or Serial
field, then the matching field in the master table must be a Long
Integer field or a Serial field.  If the master table is not a
Paradox table then the master table's key field may be any integer
type it supports.


InterBase Tables
MS/Sybase SQL Server Tables

Linking with these tables types presents no particular problems
relating to trigger-modified fields.  The only necessity is
matching the appropriate column type between the two tables.


Simple Inserts/Updates
-----------------------------------------------------------------

Paradox Tables

Since Paradox Autoincrement fields are read-only, they are not
typically targeted for update when inserting new records.
Therefore, the Required property for field components based on
Autoincrement fields should always be set to False.  This can be
accomplished from within Delphi, using the Fields Editor to
define field components at design time by double clicking on the
TQuery or TTable component or at runtime with a statement similar
to the following.

Table1.Fields[0].Required := False;

    or

Table1.FieldByName('Fieldname').Required := False;


Informix Tables

Although Informix Serial fields are updateable, if their
autoincrement feature is to be used, then the Required property
of field components based on them should be set to False.  Do
this in the same manner described for Paradox Tables.


InterBase Tables
MS/Sybase SQL Server Tables

Handling inserts on these trigger-modified table types requires a
number of steps for smooth operation.  These additional steps are
particularly necessary if inserts are accomplished via standard
data-aware controls, such as DBEdits and DBMemos.

Inserting rows on trigger-modified InterBase and SQL Server
tables may often yield the error message 'Record/Key Deleted'.
This error message appears despite that the table is properly
updated on the server.  This will occur if:

   1.  The trigger updates the primary key.  This is not only
       likely when a trigger is used, but is probably the most
       common reason for using a trigger.

   2a. Other columns in the table have bound default values.
       This is accomplished with the DEFAULT clause at table
       creation in the case of InterBase. or with the
       sp_bindefault stored procedure in SQL Server.

                            or

   2b. Blob type fields are updated when a new row is inserted.

                            or

   2b. Calculated fields are defined in an InterBase table.


The fundamental cause for this is that when the record (or
identifying key) is changed at the server, the BDE no longer has
means of specifically identifying the record for re-retrieval.
That is, the record no longer appears as it did when it was
posted, therefore the BDE assumes that the record has been
deleted (or the key changed).

Firstly, the field components of trigger-modified fields must
have their Required property set to False.  Do this in the same
manner described for Paradox Tables.

Secondly, to avoid the spurious error, order the table by an
index that does not make use of fields updated by the trigger.
This will also prevent the newly entered record from disappearing
immediately after insertion.

Lastly, if requirement 1 above holds but neither 2a, 2b nor 2c
hold, then code similar to the following should be used for the
table component's AfterPost event handler.

procedure TForm1.Table1AfterPost(DataSet: TDataset);
begin
  Table1.Refresh
end;

A Refresh of the table is necessary to re-retrieve the values
changed by the server.

If criteria 2a, 2b or 2c cannot be avoided, then the table should
be updated without using Delphi's data-aware controls.  This can
be accomplished using a TQuery component targeted at the same
table.  Once the query has posted the update, any table components
using the same table should be Refreshed.

