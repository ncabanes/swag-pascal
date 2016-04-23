
Implementing SQL with spaces or special characters in field/column names

Implementing SQL statements in Delphi's TQuery component (or the
SQL query facilities of Database Desktop, Visual dBASE or Paradox
for Windows) requires special syntax for any columns that contain
spaces or special characters.

Using the Biolife.DB table of from Delphi's demo data to
illustrate, and without the use of any special syntax
requirements, a SQL Select statement might be formed as follows,

SELECT
 Species No,
 Category,
 Common_Name,
 Species Name,
 Length (cm),
 Length_In,
 Notes,
 Graphic
FROM
 BIOLIFE

While appearing normal, the space in the species number and name
columns and the column expressing length in centimeters - as well
as the parentheses present - cause syntax errors.

Two changes must be taken to correct the syntax of the above SQL
statement.  First, any columns containing spaces or special
characters must be surrounded by single (apostrophe) or double
quotes.  Secondly, a table reference and a period must precede
the quoted column name.  This second requirement is particularly
important since a quoted string alone is interpreted as a string
expression to be yielded as a column value.  A properly formatted
statement follows:

SELECT
 BIOLIFE."Species No",
 BIOLIFE."Category",
 BIOLIFE."Common_Name",
 BIOLIFE."Species Name",
 BIOLIFE."Length (cm)",
 BIOLIFE."Length_In",
 BIOLIFE."Notes",
 BIOLIFE."Graphic"
FROM
 "BIOLIFE.DB" BIOLIFE

The above example uses the table alias BIOLIFE as the table
reference that precedes the column name.  This reference may take
the form of an alias name, the actual table name, or a quoted
file name when using dBASE or Paradox tables.  The following
SQL statements would serve equally well.

Note: This SQL statement may be used provided that the necessary
alias is already opened.  In the case of the TQuery this means the
alias is specified in the DatabaseName property.

SELECT
 BIOLIFE."Species No",
 BIOLIFE.Category,
 BIOLIFE.Common_Name,
 BIOLIFE."Species Name",
 BIOLIFE."Length (cm)",
 BIOLIFE.Length_In,
 BIOLIFE.Notes,
 BIOLIFE.Graphic
FROM
 BIOLIFE

If an alias is not available then the entire path to the table
can be specified as in this example:

SELECT
 "C:\DELPHI\DEMOS\DATA\BIOLIFE.DB"."Species No",
 "C:\DELPHI\DEMOS\DATA\BIOLIFE.DB"."Category",
 "C:\DELPHI\DEMOS\DATA\BIOLIFE.DB"."Common_Name",
 "C:\DELPHI\DEMOS\DATA\BIOLIFE.DB"."Species Name",
 "C:\DELPHI\DEMOS\DATA\BIOLIFE.DB"."Length (cm)",
 "C:\DELPHI\DEMOS\DATA\BIOLIFE.DB"."Length_In",
 "C:\DELPHI\DEMOS\DATA\BIOLIFE.DB"."Notes",
 "C:\DELPHI\DEMOS\DATA\BIOLIFE.DB"."Graphic"
FROM
 "C:\DELPHI\DEMOS\DATA\BIOLIFE.DB"

Finally, two facilities that automatically handle this special
formatting exist.  The first is the Visual Query Builder that is
a part of the Client/Server version of Delphi.  The Visual Query
Builder performs this formatting automatically as the query is built.
The other facility is Database Desktop's Show SQL feature, available
when creating or modifying a QBE-type query.  After selecting
Query|Show SQL from the main menu, the displayed SQL text may be
cut and pasted where needed.

