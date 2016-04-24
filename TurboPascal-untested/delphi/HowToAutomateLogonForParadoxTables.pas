(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0114.PAS
  Description: How to automate logon for paradox tables
  Author: SWAG SUPPORT TEAM
  Date: 02-21-96  21:04
*)

{
Password automation

Q:  I have a paradox table that uses a password.  How do I make it so
that the form that uses the table comes up without prompting the user
for the password?  

A:  The table component's ACTIVE property must be set to FALSE (If
it is active before you have added the pasword, you will be prompted).
Then, put this code in the handler for the form's OnCreate event:

  Session.AddPassword('My secret password');
  Table1.Active := True;

Once you close the table, you can remove the password with 
RemovePassword('My secret password'), or you can remove all current
passwords with RemoveAllPasswords.  (Note: This is for Paradox tables
only.)

