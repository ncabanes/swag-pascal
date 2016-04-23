if you want to remove the period, and all Characters after it in
a valid Dos Filename, do the following...

FileName := 'MYFile.TXT';
Name := Copy(FileName, 1, Pos('.', FileName) - 1);

That will do it.  or you can use FSplit to break out all the
different parts of a Filename/path and get it that way.

