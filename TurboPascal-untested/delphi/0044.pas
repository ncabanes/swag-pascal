
Here is my most straight forward explanation of how to
connect your Delphi application to an Access 2.0 database.  With this 
method, I have connected to Access 2.0 databases, and been able to read and 
write records to my hearts content.  NOTE: You MUST have the proper ODBC 
drivers.  If you don't, this will not work!

REQUIRED DRIVERS:
      ODBCJT16.DLL   dated 11/18/94 or later
      ODBCINST.DLL   dated 08/17/94 or later
      ODBCCTL16.DLL  dated 11/18/94 or later
      MSAJT200.DLL      dated 11/18/94 or later
      MSJETERR.DLL   dated 11/18/94 or later
      MSJETINT.DLL      dated 11/18/94 or later

To the best of my knowledge, these are all of the drivers that are above and 
beyond your base ODBC drivers.  You should be able to obtain these from MS 
on their FTP/WWW site, however I do not know exact directories.  My company
is a MS Solutions Provider, and we obtained these drivers on one of the many 
CDs we received from MS.

Now for the meat of this posting:

To access a database via ODBC, you must first create an ODBC connection to 
the database.
   1) Open Control Panel, and then select ODBC.
   2) When the Data Sources dialog appears, select Add.
   3) If you have installed all of the drivers properly, you should see the 
following Access drivers:
         Access Data (*.mdb)
         Access Files(*.mdb)
         Microsoft Access Driver (*.mdb)
   4) The one you MUST choose is the third one, Microsoft Access Driver.  
Choosing any of the others will not work.
   5) You will then be presented with the ODBC Microsoft Access 2.0 Setup 
dialog.  Fill this in with the information regarding the database to which 
you wish to connect.
   6) Save the settings and then exit all the way out of Control Panel.

After having made a proper connection to the database with ODBC, the rest is 
quite simple.
   7) Open BDE Config.
   8) Choose New ODBC Driver.
   9) Give your SQL link a name
   10) From the Default ODBC Driver combo box, you must choose the Microsoft 
Access Driver, just the same as you did in the ODBC setup.  Do not choose 
Access Data/Files drivers.
   11) If everything is setup properly, the name of your database should 
appear in the Default Data Source Name combo box.  Select it now.
   12) Select OK, you will be back to the main dialog for BDE Config.  
Select the aliases tab.
   13) Create a new alias, using the SQL link that you just created (it will 
start with ODBC_) as your Alias Type.
   14) Now save and exit from BDE Config.

You should now be able to get to you Access 2.0 database with both read and 
write instructions.

And finally...
I must say that having got to Access, via ODBC, you will probably wish you 
hadn't.  It is sssllllooowww.  Anytime we start adding layers, it gets
slower and slower.  Normally, I would recommend staying away from VB like 
the plague (I'm an old C++ hacker of many years, and the term BASIC makes me 
shudder).  However, at this point in time, the best way to use Access 
databases is through either Access or VB.  Microsoft is very close-mouthed 
about the structure of Access databases, and there is no indication that 
they are planning to change ("You either use VB/Access or we'll make you pay 
through the ODBC monster!").  Sorry, I digress.  My recommendation, if you 
absolutely MUST use Access, then use VB.  Otherwise, migrate your database 
to a more open system (Paradox,dBase/FoxPro,anything you can get a native 
engine), and use Delphi.

I hope this helps those who are still having problems accessing Access 
databases via ODBC.  If I've left anything out, I would appreciate 
commentary (no flames please...whine whine ;)

Good Luck!
Lance Leverich
PDA, Inc.
lancel@pdainc.com
(913) 469-8700 ext.4110

