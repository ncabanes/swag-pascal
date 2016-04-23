{
HELGE HELGESEN

> but i don't know how to change the user information
> (Like users City/State For instance).

Let's see... I'm not sure if it works if the user you want to
modify is on-line, but if he isn't, this should work.

First, locate the user in the index Files. It's organized as
this. if the name is less than 25 Chars, it's filled up With
spaces.
}

Type
  TUserIndex = Record
    RecNo : Word;
    Name  : Array[1..25] of Char;
  end;

{
The first letter of name is used as extention to the index Files.
To find me, you have to look into the File "PCBNDX.H". It's
stored as FIRSTNAME LASTNAME. (The path to the user indexes are
located in line 28 of "PCBOARD.DAT".)

When you have found the Record no, simply seek to the Record in
the File specified in line 29 of "PCBOARD.DAT". The layout looks
like this:

    Offset   Type   Length  Description
    ------  ------  ------  -----------
       0    str       25    Full Name
      25    str       24    City
      49    str       12    PassWord
      61    str       13    Business / Data Phone Number
      74    str       13    Home / Voice Phone Number
      87    str        6    Last Date On (format:  YYMMDD)
      93    str        5    Last Time On (format HH:MM)
      98    Char       1    Expert Mode (Y or N)
      99    Char       1    Default Transfer Protocol (A-Z, 0-9)
     100    bitmap     1    Bit Flags (see below)
     101    str        6    Date of Last DIR Scan (most recent File found)
     107    Char       1    Security Level (0-255)
     108    int        2    Number of Times On
     110    Char       1    Page Length (# lines displayed before prompt)
     111    int        2    Number of Files Uploaded
     113    int        2    Number of Files Downloaded
     115    bdReal     8    Total Bytes Downloaded Today
     123    str       30    Comment Field #1 (user comment)
     153    str       30    Comment Field #2 (sysop comment - user can't see)
     183    int        2    Elapsed Time On (in minutes)
     185    str        6    Registration Expiration Date (YYMMDD)
     191    Char       1    Expired Registration - Security Level
     192    Char       1    Last Conference In (used For v14.x compatibility)
     193    bitmap     5    Conference Registration Flags (conf 0-39)
     198    bitmap     5    Expired Registration Conference Flags (conf 0-39)
     203    bitmap     5    User Selected Conference Flags (conf 0-39)
     208    bdReal     8    Total Bytes Downloaded
     216    bdReal     8    Total Bytes Uploaded
     224    Char       1    Delete Flag (Y or N)
     225    bsReal     4    Last Message Read Pointer (conference 0)
     229    bsReal     4    Last Message Read Pointer (conference 1)
     ...    bsReal     4    (continued each conference)
     381    bsReal     4    Last Message Read Pointer (conference 39)
     385    long       4    Record Number of USERS.INF Record
     389    bitmap     1    Bit Flags 2 (see below)
     390    str        8    Reserved (do not use)
     398    int        2    Last Conference In (used instead of offset 192)

So all you have to do is to read the Record, make the
modifications and Write it back.

Just remember to open the Files in shared mode! (FileMode:=66;).
}
