(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0081.PAS
  Description: Info on DBASE3 Files
  Author: SWAG SUPPORT TEAM
  Date: 01-27-94  17:36
*)

Unit dbfinfo;
interface
uses
        crt;

var
        dbfile : file;
        currentrec : longint;
        dbfilename : string;
        dbfileok : boolean;
        dberr : integer;


procedure dbwrthd;      {writes the header info}
procedure disprec;      {displays the record data}
procedure dbhdrd;       {reads the header info}
procedure waitforkey;   {waits for key to be hit}

implementation
const
     dbmaxflds = 128;   {max. number of fields }
     dbmaxrecsize = 4000; {max. size of a record }


Type

    DBfileinfo = record      { first 32 bytes of DBF }
        version : byte;
                year : byte;
        month : byte;
                day : byte;
                norecord : longint;
                headlen : integer;
                reclen : integer;
                res : array[1..20] of byte;
                end;

        DBfieldinfo = record            { 32 byte field info }
                name  : array[1..11] of char;
                ftype : byte;
                addr  : longint;
                len   : byte;
                dcnt  : byte;
                res   : array[1..14] of char;
                end;

        dbfldar = array[1..dbmaxflds] of dbfieldinfo;
        dbrecar = array[1..dbmaxrecsize] of char;

var
        dbhead : dbfileinfo;
        dbfield : dbfldar;
        dbnofld : integer;
        dbrecord : dbrecar;


procedure waitforkey;
var
        junk : char;
begin
        writeln;
        write('Hit any key to continue');
        junk := readkey;
end;


{ read rdbase III  header info }
{ blockread error - dberr = h = 0, l = number of records read}
{ bad header - dberr - h = 1, l = version }
procedure dbhdrd;
var
   i : integer;
begin
        blockread(dbfile,dbhead,32,dberr);
        dbfileok := (dberr = 32);
        dbnofld := (dbhead.headlen - 33) div 32;
        if not dbfileok then exit;

        if not ((dbhead.version = $83) or (dbhead.version = $03)) then
        begin
                dbfileok := false;
                dberr := dbhead.version or $100;
                exit;
        end;

        for i := 1 to dbnofld do
        begin
                blockread(dbfile,dbfield[i],32,dberr);
                dbfileok := (dberr = 32);
        if not dbfileok then exit;
    end;

end;

{ writes field titles on screen }
procedure dbwrfldtit(line : integer);
begin
        gotoxy(1,line);
        write('Field Name   Type  Len  Dec');
    gotoxy(40,line);
    writeln('Field Name   Type Len  Dec');
        write('-----------------------------------------------------------------');
end;


{ writes all header info to the screen }
procedure dbwrthd;
var
        line,j,i : integer;

begin
    clrscr;
    gotoxy(29,1);
    write('DBase file ',dbfilename);
    gotoxy(1,3);
    with dbhead do
    begin
        write('Last Time File Updated  - ',month:2,'/',day:2,'/',year:2);
                gotoxy(40,3);
                write('Number of records in file - ',norecord);
                gotoxy(1,4);
                write('Length of each record   - ',reclen);
                gotoxy(40,4);
        end;
        write('Number of fields          - ',dbnofld);
        dbwrfldtit(6);
        line := 8;
        for i := 1 to dbnofld do
        begin
        if odd(i) then gotoxy(1,line) else gotoxy(40,line);
                with dbfield[i] do
                begin
                        for j := 1 to 11 do write(name[j]);
                        write('    ',chr(ftype),'   ',len:3,' ',dcnt:3);
                end;
        if not odd(i) then
        begin
            line := succ(line);
            if line = 24 then
            begin
                 if i < dbnofld then
                 begin
                      line := 3;
                      writeln;
                      write('More ....');
                      waitforkey;
                      clrscr;
                      dbwrfldtit(1);
                      end;
                 end;
            end;
        end;
        waitforkey;
end;

{ read and display a DBase III record }
{ if field data is larger than one line if will be truncated }

procedure dbreadrec(rec : longint);
const
        maxchar = 65;   {maximum characters to display from record}
var
    temp : longint;
        i,j,stoppos,startpos,maxlen : integer;
        linecnt : integer;

begin
        with dbhead do
        begin
             if (rec < 1) or (rec > norecord) then
             begin
                  dberr := 0;
                  dbfileok := false;
                  exit;
             end;
             temp := rec;
             rec := (rec - 1) * reclen + headlen;
             seek(dbfile,rec);
             blockread(dbfile,dbrecord,reclen,dberr);
        end;
        clrscr;
        write('DBASE file ',dbfilename,'   Record No. ',temp);
        if dbrecord[1] = '*' then writeln('    DELETED') else writeln;
        writeln;
        startpos := 2;
        linecnt := 1;
        for i := 1 to dbnofld do
        begin
             with dbfield[i] do
             begin
                  for j := 1 to 11 do write(name[j]);
                  write(' -- ');
                  if len > maxchar then maxlen := maxchar
                  else maxlen := len;
                  stoppos := startpos + maxlen;
                  for j := startpos to stoppos -1 do write(dbrecord[j]);
                  startpos := startpos + len;
                  writeln;
                  linecnt := succ(linecnt);
                  if linecnt = 22 then
                  begin
                       if i < dbnofld then
                       begin
                            linecnt := 1;
                            write('More ....');
                            waitforkey;
                            for j := 3 to 25 do
                            begin
                                 gotoxy(1,j);
                                 clreol;
                            end;
                            gotoxy(1,3);
                       end;
                  end;
             end;
        end;
        waitforkey;
end;

procedure disprec;
var
        rec : string;
        treal : real;
        error : integer;

begin
        repeat
              clrscr;
              writeln('DBASE file -- ',dbfilename);
              writeln;
              write('Total records = ',dbhead.norecord);
              writeln('   Current Record = ',currentrec);
              writeln;
              write('Enter record to display (0 = exit, cr = next, - = previous)? ');
              readln(rec);
              if (rec = '') or (rec[1] = '-') then
              begin
                   if rec = '' then currentrec := succ(currentrec)
                   else
                   currentrec := pred(currentrec);
              end
              else
              begin
                   val(rec,treal,error);
                   if error <> 0 then treal := 0.0;
                   currentrec := trunc(treal);
              end;
              if currentrec = 0 then exit;
              if currentrec < 0 then currentrec := 1;
              if currentrec > dbhead.norecord then currentrec := dbhead.norecord;
              dbreadrec(currentrec);
        until false

end;
begin
end.

                       Dbase III DBF File Structure


Header
------


        
BYTE #                Type                Example           Description
------                ----            -------           -----------
        
0                Byte                   1              DBASE Version
                                                  (83H with DBT file)
                                                  (03H without DBT file)

1                Byte                   2                  Year - Binary

2                Byte                   3                  Month - Binary

3               Byte                   4                  Day - Binary

4-7                32 bit integer     5              Number of records in file

8-9                16 bit integer           6                  Length of header

10-11                16 bit integer     7                  Length of record

12-31                20 Bytes           8              Reserved

32-n                32 Bytes                          Field Descriptor
                                                  (See below)
                                        
n+1                Byte               9              0Dh field terminator

N+2                  Byte              10              00h In some older versions
                                                  (The length of header byte
                                                  reflects this if present)
.pa

Field Descriptor
----------------

BYTE #                Type                Example           Description
------                ----            -------           -----------

0-10                byte                   11             Field name 
                                                  (Zero filled)

11                Byte                   12                  Field Type
                                                  (N D L C M)

12-15                32 bit integer           13                  Field data address
                                                  (Internal use)

16                Byte                   14                  Field length - Binary

17                Byte                   15                  Field decimal count - Binary

18-31                14 bytes           16                  Reserved



Field Types
-----------


N        Numeric - 0 1 2 3 4 5 6 7 8 . -


D        Date - 8 Bytes (YYYYMMDD)


L        Logical - Y y N n T t F f ? (? = Not initialized)


C        Character - Any Ascii Character


M        Memo - 10 digits (DBT block Number)



Data Records
------------


        All data is in Ascii.


        There is no field seperators or record terminators.

        The first byte is a space (20h) if record not deleted and an
        asterick (2AH) if deleted.



DBASE Limitations
-----------------

Fields - 128 Max.

Record - 4000 bytes Max.

Header - 4130 bytes Max.

          (128 Fields * 32 bytes) + 32 bytes + 1 terminator + (1 null)

Number - 19 digits




Example File
------------


         1  2  3  4     5         6     7          8
        || || || || |---------| |---| |---| |---------- 
000000  83 55 0B 0E 31 00 00 00-81 01 89 00 00 00 00 00  .U..1...........

        ----------------------------------------------|
000010  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00  ................

                      11                 12     13
        |------------------------------| || |---------| 
000020  46 49 52 53 54 4E 41 4D-45 00 00 43 13 01 9D 41  FIRSTNAME..C...A

        14 15                     16
        || || |---------------------------------------|
000030  14 00 00 00 01 00 00 00-00 00 00 00 00 00 00 00  ................

000040  4C 41 53 54 4E 41 4D 45-00 00 00 43 27 01 9D 41  LASTNAME...C'..A

000050  14 00 00 00 01 00 00 00-00 00 00 00 00 00 00 00  ................

000060  50 48 4F 4E 45 00 00 00-00 00 00 43 3B 01 9D 41  PHONE......C;..A

000070  0D 00 00 00 01 00 00 00-00 00 00 00 00 00 00 00  ................

000080  54 52 41 56 45 4C 43 4F-44 45 00 43 48 01 9D 41  TRAVELCODE.CH..A

000090  04 00 00 00 01 00 00 00-00 00 00 00 00 00 00 00  ................

0000A0  54 52 41 56 45 4C 50 4C-41 4E 00 43 4C 01 9D 41  TRAVELPLAN.CL..A

0000B0  28 00 00 00 01 00 00 00-00 00 00 00 00 00 00 00  (...............

0000C0  44 45 50 41 52 54 55 52-45 00 00 44 74 01 9D 41  DEPARTURE..Dt..A

0000D0  08 00 00 00 01 00 00 00-00 00 00 00 00 00 00 00  ................

0000E0  43 4F 53 54 00 50 41 49-44 00 00 4E 7C 01 9D 41  COST.PAID..N|..A

0000F0  0A 02 00 00 01 00 00 00-00 00 00 00 00 00 00 00  ................

000100  50 41 49 44 00 4F 54 45-53 00 00 4C 86 01 9D 41  PAID.OTES..L...A

000110  01 00 00 00 01 00 00 00-00 00 00 00 00 00 00 00  ................

000120  41 47 45 4E 54 00 00 00-00 00 00 43 87 01 9D 41  AGENT......C...A

000130  02 00 00 00 01 00 00 00-00 00 00 00 00 00 00 00  ................

000140  52 45 53 45 52 56 44 41-54 45 00 44 89 01 9D 41  RESERVDATE.D...A

000150  08 00 00 00 01 00 00 00-00 00 00 00 00 00 00 00  ................

000160  4E 4F 54 45 53 00 00 00-00 00 00 4D 91 01 9D 41  NOTES......M...A

000170  0A 00 00 00 01 00 00 00-00 00 00 00 00 00 00 00  ................

                Firstname
           || |----------------------------------------
000180  0D 20 43 6C 61 69 72 65-20 20 20 20 20 20 20 20  . Claire        
                           
                            Lastname
        ----------------| |----------------------------
000190  20 20 20 20 20 20 42 75-63 6B 6D 61 6E 20 20 20        Buckman   

                                        Phone
        ----------------------------| |----------------
0001A0  20 20 20 20 20 20 20 20-20 20 28 35 35 35 29 34            (555)4

                               T - code     T - plan
        -------------------| |---------| |-------------
0001B0  35 36 2D 39 30 35 39 43-49 31 30 31 30 2D 6E 69  56-9059CI1010-ni

        -----------------------------------------------
0001C0  67 68 74 20 43 61 72 69-62 62 65 61 6E 20 49 73  ght Caribbean Is

        -----------------------------------------------
0001D0  6C 61 6E 64 20 43 72 75-69 73 65 20 20 20 20 20  land Cruise     

                   Departure Date          Cost
        -------| |---------------------| |-------------                  
0001E0  20 20 20 31 39 38 35 31-30 32 34 20 20 20 31 31     19851024   11

                       PD  Age    Res. Date
        -------------| || |---| |---------------------|
0001F0  39 39 2E 30 30 54 4D 4D-31 39 38 35 30 37 31 35  99.00TMM19850715

.pa
            Notes
        |---------------------------|
000200  20 20 20 20 20 20 20 20-20 31 20 52 69 63 6B 20           1 Rick 

000210  20 20 20 20 20 20 20 20-20 20 20 20 20 20 20 4C                 L

000220  69 73 62 6F 6E 6E 20 20-20 20 20 20 20 20 20 20  isbonn          

000230  20 20 20 28 35 35 35 29-34 35 35 2D 33 33 34 34     (555)455-3344

000240  41 56 31 30 39 2D 6E 69-67 68 74 20 41 6C 61 73  AV109-night Alas

000250  6B 61 2F 56 61 6E 63 6F-75 76 65 72 20 43 72 75  ka/Vancouver Cru

000260  69 73 65 20 20 20 20 20-20 20 20 20 31 39 38 35  ise         1985

000270  30 38 30 35 20 20 20 31-33 37 38 2E 30 30 54 4A  0805   1378.00TJ

000280  54 31 39 38 35 30 37 31-35 20 20 20 20 20 20 20  T19850715       

000290  20 20 32 20 48 61 6E 6B-20 20 20 20 20 20 20 20    2 Hank


