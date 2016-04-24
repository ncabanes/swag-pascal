(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0103.PAS
  Description: DBase III Routines
  Author: WIM VAN DER VEGT
  Date: 08-24-94  13:30
*)

{---------------------------------------------------------}
{  Unit    : Dbase III Access Routines                    }
{  Auteur  : Ir. G.W. van der Vegt                        }
{            Hondsbroek 57                                }
{            6121 XB Born                                 }
{---------------------------------------------------------}
{  Datum .tijd  Revisie                                   }
{  910701.2130  Creatie.                                  }
{  910702.1000  Minor Errors Corrected                    }
{               Replace, Append & Pack Added              }
{  910706.2400  dbrec on the Heap (recsize max 64kB-16)   }
{               Uppercase Conversion in Bd3_fileno        }
{               Optional Halt on (fatal) Errors           }
{  910710.1500  Memo Field Support                        }
{  910715.2330  Field2num bug fixed (leading sp. removed) }
{  910960.1130  Fieldno Out of range detection            }
{  920116.1000  Two minor bugs fixed                      }
{  920124.2200  Header updated when file is closed,       }
{               Db3_Seekbof & Db3_Seekeof added           }
{               Db3_Findfirst & Db3_Findnext implemented  }
{               for wildcard search of records            }
{               Db3_soudex & Db3_field2soundex for Soundex}
{               code (sound alike) operations             }
{               Db3_firstsoudex & Db3_nextsoundex for     }
{               soundex search on a field                 }
{  920127.1300  Dbase Slack Filespace Detection &         }
{               Correction                                }
{  920129.2115  Trailing spaces remover in Db3_field2str  }
{               Seek after truncate in Db3_open           }
{  920130.2145  Slack filespace bug removed               }
{               Db3_sort implemented (based on shakersort)}
{               Bug in Db3_date2field removed             }
{  920716.2130  Empty file pack fixed in Db3_pack         }
{  920928.2200  Obscure bug in Db3_fieldname. Fieldnames  }
{               seem to be are ASCIZ in stead of fixed    }
{               length strings.                           }
{  930927.2000  Freemem bug in db3_findnext corrected.    }
{---------------------------------------------------------}
{  To Do        Full Documentation                        }
{               Write Memo Support                        }
{               Extend Db3_pack with MemoFile Packing     }
{               Sort *.DBF in place                       }
{               Insert record in *.DBF file               }
{               Date format not always yy-mm-dd           }
{---------------------------------------------------------}

UNIT Db3_01;

INTERFACE

USES
  DOS;

{---------------------------------------------------------}
{----Error Handling : Returns First Error Which Occured   }
{---------------------------------------------------------}

VAR
  db3_ernr     : INTEGER;                    {----DB3 Module Error Code}
  db3_fatal    : BOOLEAN;                    {----IF True
                                                    THEN Halt(db3_ernr)
                                                  on an error}

  db3_memotext : TEXT;                       {----Memo File}

{---------------------------------------------------------}

FUNCTION  Db3_ermsg(nr : INTEGER) : STRING;

{---------------------------------------------------------}
{----Initialize/Exit : Must both be Called for every file }
{---------------------------------------------------------}

PROCEDURE Db3_open(fn : STRING);             {----Opens fn.DBF file &
                                                  Inits Internals}
PROCEDURE Db3_close;                         {----Closes fn.DBF file}

{---------------------------------------------------------}
{----Header Function : Get .DBF header info               }
{---------------------------------------------------------}

FUNCTION  Db3_memo : BOOLEAN;

FUNCTION  Db3_update : STRING;

FUNCTION  Db3_norecs : LONGINT;

FUNCTION  Db3_nofields : INTEGER;

FUNCTION  Db3_reclen : INTEGER;

{---------------------------------------------------------}
{----File I/O : Dbase III Alike (pos etc. in records)     }
{---------------------------------------------------------}

PROCEDURE Db3_seek(pos : LONGINT);

FUNCTION  Db3_filesize : LONGINT;

FUNCTION  Db3_filepos : LONGINT;

PROCEDURE Db3_readnext;

PROCEDURE Db3_read(pos : LONGINT);

PROCEDURE Db3_seekeof;

PROCEDURE Db3_seekbof;

FUNCTION  Db3_eof : BOOLEAN;

FUNCTION  Db3_bof : BOOLEAN;

PROCEDURE Db3_replace(no : LONGINT);         {----First Read record &
                                                  Fill all fields}
PROCEDURE Db3_append;                        {----First Fill all Fields}

PROCEDURE Db3_delete(no : LONGINT);

PROCEDURE Db3_undelete(no : LONGINT);

PROCEDURE Db3_pack;                          {----Packs File IN-PLACE}

PROCEDURE Db3_blankrec;

{---------------------------------------------------------}
{----Field Operations : no is .DBF field number           }
{---------------------------------------------------------}

FUNCTION  Db3_fieldname(no : INTEGER) : STRING;

FUNCTION  Db3_fieldlen(no : INTEGER) : INTEGER;

FUNCTION  Db3_fielddec(no : INTEGER) : INTEGER;

FUNCTION  Db3_fieldno(name : STRING) : INTEGER; {----Searches Fieldnumber for
                                                     Uppercase fieldname}
FUNCTION  Db3_fieldtype(no : INTEGER) : CHAR;

FUNCTION  Db3_deleted : BOOLEAN;

{---------------------------------------------------------}
{----Field Conversions : date format 'dd-mm-19yy'         }
{---------------------------------------------------------}

FUNCTION  Db3_field2str(no :INTEGER) : STRING;

FUNCTION  Db3_field2char(no :INTEGER) : CHAR;

FUNCTION  Db3_field2logic(no : INTEGER) : BOOLEAN;

FUNCTION  Db3_field2num(no : INTEGER) : REAL;

FUNCTION  Db3_field2date(no :INTEGER) : STRING;

PROCEDURE Db3_field2memo(no : INTEGER);

FUNCTION  Db3_field2soundex(no : INTEGER) : STRING;

PROCEDURE Db3_str2field(no :INTEGER;s : STRING);

PROCEDURE Db3_char2field(no :INTEGER;s : CHAR);

PROCEDURE Db3_logic2field(no : INTEGER;l : BOOLEAN);

PROCEDURE Db3_num2field(no : INTEGER;n : REAL);

PROCEDURE Db3_date2field(no :INTEGER;d : STRING);

{---------------------------------------------------------}
{----Database Search, spaces are used as wildcards.       }
{    Db3_blankrec can be used for creating a wildcard     }
{    record. Then if Findfirst is true the use Findnext   }
{    until Findnext becomes false. After each succesfull  }
{    call the internal readbuffer will contain the        }
{    matching record. Use casesense=true for a case       }
{    sensitive search.                                    }
{---------------------------------------------------------}

FUNCTION Db3_findfirst(cs : BOOLEAN) : BOOLEAN;

FUNCTION Db3_findnext(cs : BOOLEAN) : BOOLEAN;

{---------------------------------------------------------}
{----Soundex Code Function (sound alike)                  }
{---------------------------------------------------------}

FUNCTION  Db3_soundex(name : STRING) : STRING;

FUNCTION  Db3_firstsoundex(no : INTEGER; s : STRING) : BOOLEAN;

FUNCTION  Db3_nextsoundex(no : INTEGER; s : STRING) : BOOLEAN;

{---------------------------------------------------------}
{----Shaker Sort Almost Sorted *.DBF Files                }
{---------------------------------------------------------}

PROCEDURE Db3_sort(no : INTEGER);

IMPLEMENTATION

{---------------------------------------------------------}
{----Error Handling                                       }
{---------------------------------------------------------}

PROCEDURE Seternr(e : INTEGER);

BEGIN
  IF (db3_ernr=0) THEN db3_ernr:=e;
  IF db3_fatal
    THEN
      BEGIN
        Writeln;
        Writeln('Db3_01 [Error : ',db3_ernr:0,' = '+Db3_ermsg(db3_ernr)+']');
        Writeln;
        IF (db3_ernr<>1) THEN Db3_close;
        Halt(e);
      END;
END; {of Seternr}

{---------------------------------------------------------}

FUNCTION  Db3_ermsg(nr : INTEGER) : STRING;

BEGIN
  CASE nr OF
    0 : Db3_ermsg:='No Error';
    1 : Db3_ermsg:='Error Opening File';
    2 : Db3_ermsg:='Seek Past EOF';
    3 : Db3_ermsg:='Seek Before BOF';
    4 : Db3_ermsg:='Read Past EOF';
    5 : Db3_ermsg:='Invalid Numeric Field';
    6 : Db3_ermsg:='Field Name NOT Found';
    7 : Db3_ermsg:='Invalid Header';
    8 : Db3_ermsg:='Incorrect Filesize';
    9 : Db3_ermsg:='Records to Large';
   10 : Db3_ermsg:='To many Fields';
   11 : Db3_ermsg:='Invalid Date Format';
   12 : Db3_ermsg:='Cannot Format Real';
   13 : Db3_ermsg:='Record was already deleted';
   14 : Db3_ermsg:='Record was not deleted';
   15 : Db3_ermsg:='NOT a Dbase III File';
   16 : Db3_ermsg:='Field Number NOT Found';
   17 : Db3_ermsg:='No Memofields in this file';
   18 : Db3_ermsg:='All matching records already found';
   19 : Db3_ermsg:='No *.DBF file open';
   20 : Db3_ermsg:='*.DBF already file open';
   99 : Db3_ermsg:='NOT Yet Implemented';
  ELSE Db3_ermsg:='Unkown Error';
  END;

  db3_ernr:=0;
END; {of Db3_ermsg}

{---------------------------------------------------------}
{----Types/Vars & Constants                               }
{---------------------------------------------------------}

TYPE
  dbheader = RECORD
               dbvers : BYTE;
               dbupdy,
               dbupdm,
               dbupdd : BYTE;
               dbnorec: LONGINT;
               dbheadl,
               dbrecl : INTEGER;
               dbres  : ARRAY[1..20] OF BYTE;
             END;

  dbfield  = RECORD                          {----Definition of Field Header}
               dbname : ARRAY[1..11] OF CHAR;
               dbtype : CHAR;
               dbadr  : LONGINT;
               dblen,
               dbdec  : BYTE;
               dbres  : ARRAY[1..14] OF CHAR;
             END;

  fptr     = RECORD                          {----Definition of Readbuf Index}
               fppos   : WORD;
               fplen   : BYTE;
             END;

CONST
  maxfield =    60;                          {----Max number of Fields}
  maxsize  = 65000;                          {----Maximum Record Size}

TYPE
  rectyp   = ARRAY[0..maxsize] OF CHAR;      {----Record Readbuffer Type}

VAR
  f        : file;                           {----.DBF File}

  header   : dbheader;                       {----Space for Header}
  nofields : INTEGER;                        {----Number of Fields}

  fields   : ARRAY[1..maxfield] OF dbfield;  {----Field Definitions}
  fieldptr : ARRAY[1..maxfield] OF fptr;     {----Index into Readbuffer}
  recstart : LONGINT;                        {----Start of Record Area}

  dbrec    : ^rectyp;                        {----Record Buffer}
  reclen   : WORD;                           {----Record Length}

  memo     : FILE;                           {----Memo File}
  memopos  : LONGINT;                        {----Location of Memo Record}
  memobuf  : ARRAY[1..512] OF CHAR;          {----Memo Text File buffer}

  dbsearch : ^rectyp;                        {----Search Record Buffer}

{---------------------------------------------------------}
{----Initialize                                           }
{---------------------------------------------------------}

PROCEDURE Db3_open(fn : STRING);

VAR
  i   : INTEGER;
  j   : WORD;
  ch  : CHAR;

BEGIN
  IF (dbrec<>NIL)
    THEN Seternr(20)
    ELSE
      BEGIN
        Assign(f,fn+'.DBF');
        {$I-} Reset(f,1); {$I+}
        IF (Ioresult<>0)
          THEN Seternr(1)
          ELSE
            BEGIN
            {----Dump Header}
              Blockread(f,header,32);

              Getmem(dbrec,header.dbrecl+1);

            {---Scan for Fieldnames & Recordlength}
              reclen  :=1;
              nofields:=0;
              Blockread(f,ch,1);
              WHILE (nofields<maxfield) AND (ch<>#13) DO
                BEGIN
                  Inc(nofields);
                  WITH fields[nofields] DO
                    BEGIN
                      dbname[1]:=ch;
                      Blockread(f,dbname[2],Sizeof(dbfield)-1);
                      Inc(reclen,dblen);
                      Blockread(f,ch,1);
                    END;
                END;

              IF (ch<>#13) THEN Seternr(10);

            {----Zapped file contains only a EOF}
              recstart:=Filepos(f);

            {----Set fieldptr}
              j:=1;
              FOR i:=1 TO nofields DO
                WITH fieldptr[i],fields[i] DO
                  BEGIN
                    fplen:=dblen;
                    fppos:=j;
                    Inc(j,dblen);
                  END;

            {----Header Integrity Checks}
              IF NOT(header.dbvers IN [$03,$83]) THEN Seternr(15);

              IF ((header.dbheadl DIV 32)-1<>nofields) OR
                  (header.dbrecl<>reclen)
                THEN Seternr(7);

            {----File Size Check}
              IF (header.dbnorec*reclen<>(Filesize(f)-recstart-1))
                THEN
                  BEGIN
                  {----Truncate DBASE Slack Filespace}
                  { Writeln('Truncating'); }
                    Db3_Seek(header.dbnorec+1);
                    {$I-} Seek(f,Filepos(f)+1); {$I+}
                    IF (IOresult=0)
                      THEN Truncate(f)
                      ELSE Seternr(8);
                  END;

              IF (reclen>Sizeof(rectyp)) THEN Seternr(9);

              IF Db3_memo
                THEN
                  BEGIN
                    Assign(memo,fn+'.DBT');
                    {$I-} Reset(memo,1); {$I+}
                    IF (IOresult<>0) THEN Seternr(17);
                  END;

              IF (db3_ernr<>0) THEN Freemem(dbrec,header.dbrecl+1);
            END;

        IF (db3_ernr<>0)
          THEN dbrec:=NIL
          ELSE Db3_Seekbof

      END;
END; {of Db3_open}

{---------------------------------------------------------}

PROCEDURE Db3_close;

VAR
  y,m,d,dow : WORD;

BEGIN
  IF (dbrec<>NIL)
    THEN
      BEGIN
      {----Update *.DBF File Header}
        Getdate(y,m,d,dow);
        WITH header DO
          BEGIN
            dbupdy :=y MOD 100;
            dbupdm :=m;
            dbupdd :=d;
            dbnorec:=Db3_filesize;
          END;
        Reset(f,1);
        Blockwrite(f,header,32);
        Close(f);

      {----Cleanup Memory}
        Freemem(dbrec,header.dbrecl+1);
        IF dbsearch<>NIL THEN Freemem(dbsearch,header.dbrecl+1);

        dbrec    :=NIL;
        dbsearch :=NIL;
      END
    ELSE Seternr(19);
END; {of DB3_close}

{---------------------------------------------------------}
{----Header Operations                                    }
{---------------------------------------------------------}

FUNCTION  Db3_memo : BOOLEAN;

BEGIN
  Db3_memo:=header.dbvers=$83;
END; {of Db3_memo}

{---------------------------------------------------------}

FUNCTION  Db3_update : STRING;

VAR
  s : STRING;

BEGIN
  s:='dd-mm-19yy';
  s[ 1]:=Chr(Ord('0')+header.dbupdd DIV 10);
  s[ 2]:=Chr(Ord('0')+header.dbupdd MOD 10);
  s[ 4]:=Chr(Ord('0')+header.dbupdm DIV 10);
  s[ 5]:=Chr(Ord('0')+header.dbupdm MOD 10);
  s[ 9]:=Chr(Ord('0')+header.dbupdy DIV 10);
  s[10]:=Chr(Ord('0')+header.dbupdy MOD 10);

  Db3_update:=s;
END; {of Db3_update}

{---------------------------------------------------------}

FUNCTION  Db3_norecs : LONGINT;

BEGIN
  Db3_norecs:=header.dbnorec;
END; {of Db3_norecs}

{---------------------------------------------------------}

FUNCTION  Db3_nofields : INTEGER;

BEGIN
  Db3_nofields:=nofields;
END; {of Db3_nofields}

{---------------------------------------------------------}

FUNCTION  Db3_reclen : INTEGER;

BEGIN
  Db3_reclen:=reclen;
END; {of Db3_reclen}

{---------------------------------------------------------}
{----File I/O                                             }
{---------------------------------------------------------}

PROCEDURE Db3_seek(pos : LONGINT);

BEGIN
  {$I-} Seek(f,recstart+(pos-1)*reclen); {$I+}
  IF (Ioresult<>0) OR (pos<1) OR (pos>Db3_filesize+1)
    THEN
      BEGIN
        IF (pos>0)
          THEN Seternr(2)
          ELSE Seternr(3);
      END;
END; {of Db3_seek}

{---------------------------------------------------------}

FUNCTION  Db3_filesize : LONGINT;

BEGIN
  Db3_filesize:=(Filesize(f)-recstart) DIV reclen;
END; {of Db3_filesize}

{---------------------------------------------------------}

FUNCTION  Db3_filepos : LONGINT;

BEGIN
  Db3_filepos:=((Filepos(f)-recstart) DIV reclen)+1;
END; {of Db3_filepos}

{---------------------------------------------------------}

PROCEDURE Db3_readnext;

BEGIN
  IF EOF(f) OR Db3_Eof
    THEN Seternr(4)
    ELSE Blockread(f,dbrec^,reclen);
END; {of Db3_readnext}

{---------------------------------------------------------}

PROCEDURE Db3_read(pos : LONGINT);

BEGIN
  Db3_seek(pos);
  Db3_readnext;
END; {of Db3_read}

{---------------------------------------------------------}

PROCEDURE Db3_seekeof;

BEGIN
  Db3_Seek(Db3_filesize+1);
END; {of Db3_seekeof}

{---------------------------------------------------------}

PROCEDURE Db3_seekbof;

BEGIN
  Seek(f,recstart);
END; {of Db3_seekeof}

{---------------------------------------------------------}

FUNCTION  Db3_eof : BOOLEAN;

BEGIN
  Db3_eof:=(Filepos(f)>=Filesize(f)-1);
END; {of Db3_eof}

{---------------------------------------------------------}

FUNCTION  Db3_bof : BOOLEAN;

BEGIN
  Db3_bof:=Filepos(f)=recstart;
END; {of Db3_bof}

{---------------------------------------------------------}

PROCEDURE Db3_replace(no : LONGINT);

BEGIN
  Db3_seek(no);
  IF (db3_ernr=0) THEN Blockwrite(f,dbrec^[0],reclen)
END; {of Db3_append}

{---------------------------------------------------------}

PROCEDURE Db3_append;

VAR
  ch : CHAR;

BEGIN
  Db3_seek(Db3_filesize+1);
  Blockwrite(f,dbrec^[0],reclen);
  ch:=^Z;
  Blockwrite(f,ch,1);
  Db3_seek(Db3_filesize+1);
END; {of Db3_append}

{---------------------------------------------------------}

PROCEDURE Db3_delete(no : LONGINT);

BEGIN
  Db3_read(no);
  IF dbrec^[0]='*'
    THEN Seternr(13)
    ELSE dbrec^[0]:='*';
  Db3_replace(no)
END; {of Db3_delete}

{---------------------------------------------------------}

PROCEDURE Db3_undelete(no : LONGINT);

BEGIN
  Db3_read(no);
  IF dbrec^[0]=' '
    THEN Seternr(14)
    ELSE dbrec^[0]:=' ';
  Db3_replace(no)
END; {of Db3_undelete}

{---------------------------------------------------------}

PROCEDURE Db3_pack;

VAR
  i,j : LONGINT;
  ch  : CHAR;

BEGIN
  j:=0;
  FOR i:=1 TO Db3_filesize DO
    BEGIN
      Db3_read(i);
      IF NOT(Db3_deleted)
        THEN
          BEGIN
            Inc(j);
            Db3_replace(j)
          END
    END;

{----New EOF Marker}
  IF (j=0)
    THEN db3_SeekBof
    ELSE Db3_read(j);
  ch:=^Z;
  Blockwrite(f,ch,1);
  Truncate(f);

  Db3_seek(1);
END; {of Db3_pack}

{---------------------------------------------------------}

PROCEDURE Db3_blankrec;

VAR
  i : INTEGER;

BEGIN
  FOR i:=0 TO reclen-1 DO dbrec^[i]:=#32;
END; {of Db3_blankrec}

{---------------------------------------------------------}
{----Field Operations                                     }
{---------------------------------------------------------}

FUNCTION  Db3_fieldname(no : INTEGER) : STRING;

VAR
  s : STRING;
  i : WORD;

BEGIN
  s:='';
  i:=1;
  IF no IN [1..nofields]
    THEN
      BEGIN
        WITH fields[no] DO
          WHILE (i<=Sizeof(dbname)) AND (dbname[i]<>#0) DO
            BEGIN
              s:=s+dbname[i];
              Inc(i);
            END;
      END
    ELSE Seternr(16);
  Db3_fieldname:=s;
END; {of Db3_fieldname}

{---------------------------------------------------------}

FUNCTION  Db3_fieldlen(no : INTEGER) : INTEGER;

BEGIN
  Db3_fieldlen:=0;
  IF no IN [1..nofields]
    THEN Db3_fieldlen:=fields[no].dblen
    ELSE Seternr(16);
END; {of Db3_fieldlen}

{---------------------------------------------------------}

FUNCTION  Db3_fielddec(no : INTEGER) : INTEGER;

BEGIN
  Db3_fielddec:=0;
  IF no IN [1..nofields]
    THEN Db3_fielddec:=fields[no].dbdec
    ELSE Seternr(16)
END; {of Db3_fielddec}

{---------------------------------------------------------}

FUNCTION  Db3_fieldno(name : STRING) : INTEGER;

VAR
  i,j : INTEGER;
  s   : STRING;

BEGIN
  Db3_fieldno:=0;

  s:=name;
  FOR i:=1 TO Length(s) DO s[i]:=Upcase(s[i]);

  i:=1;
  WHILE (i<=nofields) AND (s<>Db3_fieldname(i)) DO
    Inc(i);

  IF (i>nofields)
    THEN Seternr(6)
    ELSE Db3_fieldno:=i;
END; {of Db3_fieldno}

{---------------------------------------------------------}

FUNCTION  Db3_fieldtype(no : INTEGER) : CHAR;

BEGIN
  Db3_fieldtype:=#00;
  IF no IN [1..nofields]
    THEN Db3_fieldtype:=fields[no].dbtype
    ELSE Seternr(16);
END; {of Db3_fieldtype}

{---------------------------------------------------------}

FUNCTION  Db3_deleted : BOOLEAN;

BEGIN
  Db3_deleted:=dbrec^[0]<>#32;
END; {of Db3_deleted}

{---------------------------------------------------------}
{----Field Conversions                                    }
{---------------------------------------------------------}

FUNCTION  Db3_field2str(no :INTEGER) : STRING;

VAR
  s : STRING;
  i : WORD;

BEGIN
  s:='';
  IF (no IN [1..nofields])
    THEN
      BEGIN
        s[0]:=Chr(fieldptr[no].fplen);
        Move(dbrec^[fieldptr[no].fppos],s[1],fieldptr[no].fplen);
      END
    ELSE Seternr(16);
{----Strip Trailing Spaces}
  WHILE (Length(s)>0) AND (s[Length(s)]=#32) DO Dec(s[0]);
  Db3_field2str:=s;
END; {of Db3_field2str}

{---------------------------------------------------------}

FUNCTION Db3_field2char(no :INTEGER) : CHAR;

VAR
  s : STRING;

BEGIN
  IF (Db3_fieldlen(no)=1)
    THEN s:=Db3_field2str(no)
    ELSE s:=#00;

  IF (Length(s)=0)
    THEN Db3_field2char:=#32
    ELSE Db3_field2char:=s[1];
END; {of Db3_field2char}

{---------------------------------------------------------}

FUNCTION Db3_field2logic(no : INTEGER) : BOOLEAN;

BEGIN
  Db3_field2logic:=(Db3_field2char(no)='T');
END; {of Db3_field2logic}

{---------------------------------------------------------}

FUNCTION  Db3_field2num(no : INTEGER) : REAL;

VAR
  r : REAL;
  s : STRING;
  e : INTEGER;

BEGIN
  s:=Db3_field2str(no);
  WHILE (Length(s)>0) AND (s[1]=#32) DO Delete(s,1,1);
  Val(s,r,e);
  IF (e<>0)
    THEN Seternr(5);
  Db3_field2num:=r;
END; {of Db3_field2num}

{---------------------------------------------------------}

FUNCTION  Db3_field2date(no :INTEGER) : STRING;

VAR
  s : STRING;

BEGIN
  s:='dd-mm-yyyy';
  IF (no IN [1..nofields])
    THEN
      BEGIN
        Move(dbrec^[fieldptr[no].fppos+6],s[1],2);
        Move(dbrec^[fieldptr[no].fppos+4],s[4],2);
        Move(dbrec^[fieldptr[no].fppos+0],s[7],4);
      END
    ELSE Seternr(16);

  Db3_field2date:=s;
END; {of Db3_field2date}

{---------------------------------------------------------}

FUNCTION Db3_field2soundex(no : INTEGER) : STRING;

BEGIN
  Db3_field2soundex:=Db3_soundex(Db3_field2str(no));
END; {of Db3_field2soundex}

{---------------------------------------------------------}

PROCEDURE Db3_str2field(no :INTEGER;s : STRING);

BEGIN
  IF (no IN [1..nofields])
    THEN
      BEGIN
        Fillchar(dbrec^[fieldptr[no].fppos],fieldptr[no].fplen,#32);
        WITH fields[no] DO
          IF (Length(s)>dblen)
            THEN Move(s[1],dbrec^[fieldptr[no].fppos],dblen)
            ELSE Move(s[1],dbrec^[fieldptr[no].fppos],Length(s));
      END
    ELSE Seternr(16)
END; {of Db3_str2field}

{---------------------------------------------------------}

PROCEDURE Db3_char2field(no :INTEGER;s : CHAR);

BEGIN
  Db3_str2field(no,s);
END; {of Db3_char2field}

{---------------------------------------------------------}

PROCEDURE Db3_logic2field(no : INTEGER;l : BOOLEAN);

BEGIN
  IF l
    THEN Db3_char2field(no,'T')
    ELSE Db3_char2field(no,'F')
END; {of Db3_logic2field}

{---------------------------------------------------------}

PROCEDURE Db3_num2field(no : INTEGER;n: REAL);

VAR
  s : STRING;

BEGIN
  IF (no IN [1..nofields])
    THEN
      BEGIN
        Str(n:fields[no].dblen:fields[no].dbdec,s);
        IF (Length(s)>fields[no].dblen)
          THEN Seternr(12)
          ELSE Db3_str2field(no,s);
      END
    ELSE Seternr(16)
END; {of Db3_num2field}

{---------------------------------------------------------}

PROCEDURE Db3_date2field(no :INTEGER;d : STRING);

VAR
  s : STRING;

BEGIN
  IF (Length(d)<>10) OR
     (d[3]<>'-') OR
     (d[6]<>'-')
    THEN Seternr(11)
    ELSE
      BEGIN
      {----dd-mm-yyyy}
        s[1]:=d[ 7];
        s[2]:=d[ 8];
        s[3]:=d[ 9];
        s[4]:=d[10];
        s[5]:=d[ 4];
        s[6]:=d[ 5];
        s[7]:=d[ 1];
        s[8]:=d[ 2];
        Db3_str2field(no,s);
      END;
END; {of Db3_date2field}

{---------------------------------------------------------}
{----Memo text field support                              }
{---------------------------------------------------------}

{$F+}

FUNCTION memoignore(VAR f : textrec) : INTEGER;

BEGIN
  memoignore:=0;
END; {of memoignore}

{---------------------------------------------------------}

FUNCTION memoinput(VAR f : textrec) : INTEGER;

VAR
  chread : WORD;

BEGIN
  WITH Textrec(f) DO
    BEGIN
      Blockread(memo,memobuf[1],Sizeof(memobuf),chread);
      bufpos   :=0;
      bufend   :=chread;
    END;
  memoinput:=0;
END; {of memoinput}

{$F-}

{---------------------------------------------------------}

PROCEDURE Assignmemo(VAR f : TEXT);

VAR
  chread : WORD;

CONST
  fminput =$D7B1;

BEGIN
  WITH Textrec(f) DO
    BEGIN
      handle   :=$ffff;
      mode     :=fminput;
      bufsize  :=SIZEOF(memobuf);
      bufpos   :=0;
      bufptr   :=@memobuf;

      Blockread(memo,memobuf[1],Sizeof(memobuf),chread);
      bufpos   :=0;
      bufend   :=chread;

      openfunc :=@memoignore;
      inoutfunc:=@memoinput;
      flushfunc:=@memoignore;
      closefunc:=@memoignore;
      name[0]  :=#00;
    END;
END; {of Assignmemo}

{---------------------------------------------------------}

PROCEDURE Db3_field2memo(no : INTEGER);

VAR
  e  : INTEGER;
  s  : STRING;

BEGIN
  IF Db3_memo
    THEN
      BEGIN
        s:=Db3_field2str(no);
        WHILE (Length(s)>0) AND (s[1]=#32) DO Delete(s,1,1);
        Val(s,memopos,e);
        IF (e<>0)
          THEN Seternr(5)
          ELSE
            BEGIN
              Seek(memo,memopos*Sizeof(memobuf));
              Assignmemo(db3_memotext);
            END;
      END
    ELSE Seternr(17);
END; {of Db3_field2memo}

{---------------------------------------------------------}

FUNCTION Db3_findfirst(cs : BOOLEAN) : BOOLEAN;

VAR
  match,
  found : BOOLEAN;
  i     : INTEGER;

BEGIN
  Getmem(dbsearch,Db3_reclen+1);
  Move(dbrec^,dbsearch^,Db3_reclen);

  Db3_Seekbof;

  found:=False;
  WHILE NOT(found OR Db3_eof OR (Db3_ernr<>0)) DO
    BEGIN
      Db3_readnext;

      i:=0;
      match:=true;
      WHILE (i<Db3_reclen) AND match DO
        BEGIN
          IF (dbsearch^[i]<>#32)
            THEN
              CASE cs OF
                TRUE  : match:=(       dbsearch^[i] =       dbrec^[i]);
                FALSE : match:=(Upcase(dbsearch^[i])=Upcase(dbrec^[i]));
              END;
          INC(i);
        END;
      found:=match;
    END;

  Db3_findfirst:=found;

  IF (found=False)
    THEN
      BEGIN
        Freemem(dbsearch,Db3_reclen+1);
        dbsearch:=NIL;
      END;
END; {of Db3_findfirst}

{---------------------------------------------------------}

FUNCTION Db3_findnext(cs : BOOLEAN) : BOOLEAN;

VAR
  match,
  found : BOOLEAN;
  i     : INTEGER;

BEGIN
  IF (dbsearch=NIL)
    THEN Seternr(18);

  found:=False;
  WHILE NOT(found OR Db3_eof OR (Db3_ernr<>0)) DO
    BEGIN
      Db3_readnext;

      i:=0;
      match:=true;
      WHILE (i<Db3_reclen) AND match DO
        BEGIN
          IF (dbsearch^[i]<>#32)
            THEN
              CASE cs OF
                TRUE  : match:=(       dbsearch^[i] =       dbrec^[i]);
                FALSE : match:=(Upcase(dbsearch^[i])=Upcase(dbrec^[i]));
              END;
          INC(i);
        END;
      found:=match;
    END;

  Db3_findnext:=found;

  If (found=False) AND (dbsearch<>NIL)
    Then
      BEGIN
        Freemem(dbsearch,Db3_reclen+1);
        dbsearch:=NIL;
      END;
END; {of Db3_findnext}

{---------------------------------------------------------}

FUNCTION  Db3_soundex(name : STRING) : STRING;

VAR
  work : STRING;
  code : CHAR;
  i,j  : INTEGER;

  {---------------------------------------------------------}

  FUNCTION Encode(VAR c: CHAR): CHAR;

  BEGIN
    CASE Upcase(c) OF
      'B','F','P','V':                 encode:='1';
      'C','G','J','K','Q','S','X','Z': encode:='2';
      'D','T':                         encode:='3';
      'L':                             encode:='4';
      'M','N':                         encode:='5';
      'R':                             encode:='6';
      'A','E','I','O','U','Y':         encode:='7';
      'H','W':                         encode:='8';
    ELSE                               encode:=' ';
    END;
  END; {of Encode}

  {---------------------------------------------------------}

BEGIN
{----If we can't calculate, this is the answer}
  work:='';

{----Skip all non alpha codes in front}
  i:=1;
  WHILE (i<=Length(name)) AND (Encode(name[i])=' ') DO Inc(i);

{----If any alpha characters left, start calculating the SOUNDEX code}
  IF (i<=Length(name))
    THEN
      BEGIN
      {----The first alpha letter of string is the first letter of the code}
        work:=Upcase(name[i]);
        Inc(i);

      {----Be sure while loop precondition is correct}
        j:=1;
        code:=#00;

      {----Calculate the numeric part of the code,    }
      {    with a maximum of 3 digits, stop if a non  }
      {    alpha character is encountered             }
        WHILE (i<=Length(name)) AND (j<=3) AND (code<>' ') DO
          BEGIN
            code:=Encode(name[i]);

          {----If new code group then add the goup number}
            IF (code IN ['1'..'6']) AND (work[j]<>code)
              THEN
                BEGIN
                  Inc(j);
                  work:=work+code;
                END;
            Inc(i);
          END;
      END;

{----Return the resulting SOUNDEX code}
  Db3_soundex:=work;

END; {of Db3_soundex}

{---------------------------------------------------------}

FUNCTION Db3_firstsoundex(no : INTEGER;s : STRING) : BOOLEAN;

VAR
  found : BOOLEAN;
  sdx   : STRING;

BEGIN
  Db3_Seekbof;

  sdx:=Db3_soundex(s);

  found:=False;
  WHILE NOT(found OR Db3_eof OR (Db3_ernr<>0)) DO
    BEGIN
      Db3_readnext;
      found:=(Pos(sdx,Db3_field2soundex(no))=1);
    END;

  Db3_firstsoundex:=found;
END; {of Db3_firstsoundex}

{---------------------------------------------------------}

FUNCTION Db3_nextsoundex(no : INTEGER; s : STRING) : BOOLEAN;

VAR
  found : BOOLEAN;
  sdx   : STRING;

BEGIN
  sdx:=Db3_soundex(s);

  found:=False;
  WHILE NOT(found OR Db3_eof OR (Db3_ernr<>0)) DO
    BEGIN
      Db3_readnext;
      found:=(Pos(sdx,Db3_field2soundex(no))=1);
    END;

  Db3_nextsoundex:=found;
END; {of Db3_nextsoundex}

{---------------------------------------------------------}

PROCEDURE Db3_sort(no : INTEGER);

VAR
  dbsort    : ^rectyp;
  swapped   : BOOLEAN;
  i,j,l,r   : LONGINT;
  s1,s2     : STRING;
  typ       : CHAR;

  {---------------------------------------------------------}

  PROCEDURE Swap(r1,r2 : LONGINT);

  BEGIN
  {----Side Effects}
    i:=j;
    swapped:=True;

  {----the Swapping itself}
    Db3_replace(r1);
    Move(dbsort^,dbrec^,Db3_reclen);
    Db3_replace(r2);
  END; {of Swapped}

  {---------------------------------------------------------}

  FUNCTION Compare(VAR c1,c2 : STRING) : BOOLEAN;

  VAR
    i : INTEGER;
    s : STRING;

  BEGIN
    CASE typ OF
      'M',
      'N'  : BEGIN
             {----Insert spaces for correct numeric compare}
               FOR i:=1 TO Db3_fieldlen(no)-Length(c1) DO Insert(#32,c1,i);
               FOR i:=1 TO Db3_fieldlen(no)-Length(c2) DO Insert(#32,c2,i);
             END;
      'L',
      'S',
      'C'  : BEGIN
             {----Convert to Uppercase for correct alpha compare}
               FOR i:=1 TO Length(c1) Do c1[i]:=Upcase(c1[i]);
               FOR i:=1 TO Length(c2) Do c2[i]:=Upcase(c2[i]);
             END;
      'D'  : ;
    END;

  {----Return TRUE if c2>c1}
    Compare:=(c2>c1);
  END; {of Compare}

  {---------------------------------------------------------}

BEGIN
{----Use ShakerSort on almost sorted *.DBF file}
  Getmem(dbsort,Db3_reclen+1);
  Move(dbrec^,dbsort^,Db3_reclen);

  l:=2;
  r:=Db3_filesize;
  i:=r-1;

  swapped:=TRUE;
  typ    :=Db3_fieldtype(no);

  WHILE (l<=r) AND swapped DO
    BEGIN
      swapped:=False;

    {----Bubble Up}
      FOR j:=r DOWNTO l DO
        BEGIN
        {----Fetch record j-1 & save it}
          Db3_read(j-1);
          s2:=Db3_field2str(no);
          Move(dbrec^,dbsort^,Db3_reclen);

        {----Fetch record j}
          Db3_read(j);
          s1:=Db3_field2str(no);

        {----Bubble}
          IF Compare(s1,s2)
            THEN Swap(j-1,j);
        END;
      l:=i+1;

    {----Bubble Down}
      IF swapped
        THEN
          BEGIN
            FOR j:=l TO r DO
              BEGIN
              {----Fetch record j-1 & save it}
                Db3_read(j-1);
                s2:=Db3_field2str(no);
                Move(dbrec^,dbsort^,Db3_reclen);

              {----Fetch record j}
                Db3_read(j);
                s1:=Db3_field2str(no);

              {----Bubble}
                IF Compare(s1,s2)
                  THEN Swap(j-1,j);
              END;
            r:=i-1;
          END;
    END;

  Freemem(dbsort,Db3_reclen+1);

  Db3_seekbof;
END; {of Db3_sort}

{---------------------------------------------------------}

BEGIN
  db3_ernr :=0;
  db3_fatal:=False;
  dbsearch :=NIL;
  dbrec    :=NIL;
END.


{ DOCUMENTATION }

Db3_01.PAS is written by

                Ir. G.W. van der Vegt
                Hondbroek 57
                6121 XB Born (L)

and uploaded as public domain software because the author likes to
share it with other Turbo Pascal Users. Please keep the source the
way it is and write extentions as separate units.

This unit provides read/write access to Dbase III (Plus) *.DBF files. The
unit is uploaded as it is, the author is not responsible for any damgage
by programs using this module. The unit is, of course, tested.

Before using any of the Db3 routine a program shall call Db3_open to
initialize the file internal buffers & info. When finishing the program
should call Db3_close to close the file & cleanup the internal buffer.

All routines are documented so there's not much to say about them. Access
to the DBF file is only allowed through this unit, so the file record
isn't exported.

Records must be read by Db3_read or Db3_readnext, and written by Db3_append
or Db3_replace. All record functions use LONGINTs as parameter for addressing
records in the file.

When a record is read, one can read the field in the record by using the
record number as parameter of the Db3_field2 procedures. This record
number lies between 1 and maxfield. If one 's to be independend of the
location of the record the Db3_fieldno can be used to convert a field
name to the field number.

When writing records fill all field with Db3_2field routines and don't
forget to use Db3_undelete to initialize the deleted marker. It's of
course also possible to read a record, modify some field and replace it.

The Db3_pack routine packs the file in-place, so no temp file is created.

This unit can't create DBase III *.DBF files as it can't write the file
header & fieldefinitions. It's also impossble to change the structure of
a DBase III *.DBF database with it. This is done to keep the unit simple.
Creating & modifing databases is much easier in Dbase III Language.

This unit uses a special naming convention to be sure there's no
confict with procedures from other units. All exported names have
a three letter prefix Db3_. The 01 in the Unit name is a unique
version number.

