>Can anyone tell me how I can delete a Record from a File?

Two ways.

1) Mark the Record With a value that tells your Program that
   Record is classified as deleted. (Most DB Programs work this
   way)

2) Read the WHOLE File in, one Record at a time. Copy these
   Records into the new File. While you are copying, ignore any
   Record(s) you want to delete.

   Once the copy is Complete, delete the old File and rename the
   new to the old Filename...

You could also open the File as unTyped :-), and use blockRead to read big
chunks Until you've read (recSize * number of Records beFore bad one) Bytes,
and blockWrite to Write them out to the temp File.  This might be faster,
depending on the number of Records and how big they are.

> How would I pack a File of Records to save space?

    if you have seen other posts by me about packing Database Type
Files, you will see I normally recommend against it.

I usually go With a "Deleted" indicator and Records marked as
deleted are re-used. It is my personnal experience that such Files
normally grow in size Until they reach a balanced state. A state in
which the File does not grow anymore and where balance is reached
between Additions and Deletions.

if you Really want to pack it then,

    1- Build a list of deleted Records
    2- take the last Record in the File
    3- Keep a note that that Record is now empty
    4- OverWrite the FIRST DELETED Record's space With it
    5- Repeat steps 2-4 Until all deleted Records have been filled.
    6- Seek to the first Record marked empty, this should be the last
       one you moved.
       or you could simply seek to Record_COunt since the File should
       now contain no empty space all valid Records should be at the
       head of the File and thus seeking to Record_Count ensures you
       of being positionned at the very end.
    7- Truncate the File there by using the Truncate command.
    8- Be sure to close and re-open the File beFore any more processing
       so that Directory and FAT are updated.


> Could someone please give me an example of a good way (the best way?) to
> delete Records from a Typed File?  My only guess, after looking at all
> of the TP documentation, and my one TP book, is that I will have to read
> the File, and Write a new File, excluding the "deleted" Record.  This
> will require another (identical) Type statment, and File Variable, etc.,
> and will require me to then rename the smaller File...
>
> Isn't there a more efficient way????

YES THERE IS!!!

Modify your Record to this:

Type
  My_Record = Record
    Deleted : Boolean;
    < Rest of your usual stuff >
  end;

    Now if you use index Files, create an index File With the DELETED
field as the key to that index.

Pseudo code ahead:

    Adding a Record:
        1- Set index to DELETED
        2- Go to first Record
        3- Is it deleted
        4- Yes, use it as our new Record
            4a Change the Deleted field to False;
            4b Write our new Record to this one overwriting it.
        5- No, Add a new phisical Record to the File,
            5a Remember to Set Deleted to False on this one
            5b Write our Record to the new Record.

    Deleting a Record:
        1- Go to Record,
        2- Read it in
        3- Set the deleted field to True.
            { This allows UnDeleting a Record With it's original data}

    Listing Records:
        Remember to skip deleted Records.

you will soon find that using this management method your applications
will perForm at speeds vastly faster than others. Simply because the
File is never moved, truncated etc.. Eliminating fragentation on the
disk. You will also find that as you open new databases, they will
quickly grow and then attain a stable size where new Records are mostly
reusing deleted Records.

    This is how my dBase applications are handled. Our last project
While I was at the Justice Departement was re-written to use this
principle of management instead of using dBase's Pack and delete
routines. The efficiency was greatly augmented both in speed and in disk
occupation. We no longer needed to perForm unfragmentation routines
periodically and we also could reverse any error our users might have
commited.

    By adding additionnal info such as deletion date, user ID that
requested the delete etc... we were able to offer options that were not
available beFore. An added benefit was that we didn't need to reindex
the whole database. Affected Index Files were open during operations and
were thus opdated on the fly. So our Deleted index was allways uptodate.
Generating a message when physical space was added to the database, we
were able to perForm defragementation only when Really needed. and those
operations were greatly shortened in time because 98% of the database
was allready defragmentated.

It's the sensible way to do it, and it can be done in any language.

{------------------------------------------------------------------------}

>   Can someone tell me how to search through a Typed File.
>   Example:
>      Type Dummy = Record
>                     Name : String
>                     Age  : Integer
>                   end;
>           DummyFile = File of Dummy;

>   How could I find a Record that has AGE = 20 ?

Do something like this:

Var
  PersonRecord : Dummy;

Procedure searchForAge(PersonsAge: Integer);
begin
   ... Open the File ...
   Seek(DummyFile, 0);        {start at beginning of File}
   PersonRecord.Age:= 1000;   {Init to unused value}
   While not(Eof) and (PersonRecord.Age <> PersonsAge) do
   begin
       Read(DummyFile, PersonRecord);
   end;
   ... Close the File ...
end;


This might work:
 Type
   rec = Record
     age: Integer;
     etc...
   end;
 Var
   f: File of rec;
   r: rec;
 begin
   assign(f, 'FileNAME.EXT');
   reset(f, sizeof(rec));           (* have to indicate Record size *)

   While not eof(f) do begin
     blockread(f, r, 1);            (* read one rec from f into r *)
     if r.age = 20 then
       (* do something interesting *)
   end;
   close(f);
 end.

The trick is to inForm the runtime library of the size of each Record in the
File; you do this in the call to reset.  Blockread takes a File, an unTyped
buffer, and the number of Records to read.





>I know that this is probably as common as the "I want to Write a BBS",
>and "*.MSG structures" :) but haven't seen anything lately (and I've
>been reading this For quite some time) about tips on searching Records
>in a File.  Any tips/routines on fast searching, or ways to set up the
>Record For fast searching?  Thanks.

   Well, you're kinda restricting yourself by saying, "in a File".  That means
you have a File of some Type, and you're pretty-much confined to the ways
appropriate For that File Type.  However, there are some things you can do
which will make processing the data faster and more efficient:
 1. For Text Files:
   a. use large buffers (SetTextBuf Procedure)
   b. establish an Index For the Records on the File, and use random i/o to
access specific Records.  Thgis does not imply reading all the Records each
time you "search it", but you must have some "key" or order in that File from
which you can assign and index key.  This is a large subject, and to go
further, I'd have to know more about your File.
   c. have the File (be of) fixed Records, sort on some key field, and use a
binary search/random read scheme to search For Records.  Also pretty
Complicated in Implementation...
  2. Random Files:
    There are many options here, and are mostly dependant on the File order and
data content/Record size.

   Finally,  suggest you read the entire File into memory (using Heap, Pointer
access, etc.), and do all your work in memory.  The above ideas are appropriate
For very large Files, but anything under 450K can be stored in you system
memory and used there, I'll bet.  Once in memory, you can even sort the data in
some fashion and use some fancy searching techniques, too.




