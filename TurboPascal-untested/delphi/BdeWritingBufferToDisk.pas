(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0120.PAS
  Description: BDE: Writing Buffer to Disk
  Author: SWAG SUPPORT TEAM
  Date: 02-21-96  21:04
*)


Product: Delphi and the Borland Database Engine
Number: ?????
Versions: 1.x, 2.x
OS: WINDOWS 3.x, WINDOWS 95, WINDOWS NT
DATE: December 7, 1995
TITLE: Using DbiUseIdleTime and DbiSaveChanges.

General:
=======

Changes made to a table are not written directly to disk until 
the table is closed.  A power failure or system crash can 
result in a loss of data, and an inconvenience.  To avoid this 
loss of data, two direct Database Engine calls can be made, 
both of which have the similar effects. These functions are 
DbiUseIdleTime and DbiSaveChanges.

DbiSaveChanges(hDBICur):
=======================

DbiSaveChanges saves to disk all the updates that are in the 
buffer of the table associated with the cursor (hDBICur). It 
can be called at any point. For example, one may want to make 
save changes to disk every time a record is updated (add 
dbiProcs to uses clause):

procedure TForm1.Table1AfterPost(DataSet: TDataSet); 
begin      
  DbiSaveChanges(Table1.handle);
end;

This way, one does not have to worry about losing data if a 
power failure or system crash occurs after a record update.

DbiSaveChanges can also be used to make a temporary table 
(created by DbiCreateTempTable) permanent.

This function does NOT apply to SQL tables.

DbiUseIdleTime:
==============

DbiUseIdleTime can be called when the "Windows Message Queue" 
is empty. It allows the Database Engine to save "dirty buffers" 
to disk. In other words, it does what DbiSaveChanges does, but 
performs the operation on ALL the tables that have been 
updated. This operation however, will not necessarily occur 
after every record update, because it can only be executed when 
there is an idle period.

In Delphi, it can be used in this fashion (add dbiProcs to uses clause):

procedure TForm1.FormCreate(Sender: TObject);
begin
     Application.onIdle := UseIdle;
end;

procedure Tform1.UseIdle(Sender: TObject; var Done: Boolean);
begin
     DbiUseIdleTime;
end;


USAGE NOTES:
===========

Using both DbiUseIdleTime and DbiSaveChanges (after every 
record modification) is redundant and will result in 
unnecessary function calls. If the application is one that 
perfroms a great deal of record insertions or modifications in 
a small period of time, it is recommended that the client 
either call DbiUseIdleTime during an idle period, or call 
DbiSaveChanges after a group of updates.

If not very many updates are being performed on the table, the
client may choose to call DbiSaveChanges after every post or
set up a timer and call DbiUseIdleTime when a timer even is generated.

