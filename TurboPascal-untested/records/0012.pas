{
> What is the best way to Find a record in a file of Records?
> Can one seek to the specified record, or do you need to
> read each record in the file and check a field for the
> proper value?

If you want a search on one field, you better create a sorted index-file where
you can search on a btree-kind of way.

Something like this:
}
RecFile : Record =
             Deleted: Boolean;
             Name   : String[15];
             Descrip: String[25];
             RText  : Array[0..39] of String[82];
          End;

IdxFile : Record =
             Name : String[15];  {same as in RecFile}
             Recnum : Word;      {record.no. in RecFile}
          End;

Var Rfile : File of RecFile;
    Ifile : File of IdxFile;
{
If you keep your index-file sorted, you can search quikly for a name in the
index and a Seek(Rfile, Ifile.Recnum) gives you the record.
}
