(*
  Category: SWAG Title: MAIL/QWK/HUDSON FILE ROUTINES
  Original name: 0014.PAS
  Description: Handle QWK REP Files
  Author: FRANK MCCORMICK
  Date: 11-21-93  09:45
*)

{
From: FRANK MCCORMICK
Subj: qwk code

    Here is some QWK code I pulled from my UNIT which handles QWK REP
    files uploaded to my BBS.

    I have modified it to display the info contained in the REP file
    (which is really just a compressed version of messages.dat)
}

PROCEDURE HandleRep;

Type
    RepFmt =  RECORD
                  totype  :  CHAR;
                  confasc :  ARRAY [1..7] OF CHAR;
                  date    :  ARRAY [1..8] OF CHAR;
                  TIME    :  ARRAY [1..5] OF CHAR;
                  rto     :  ARRAY [1..25] OF CHAR;
                  from    :  ARRAY [1..25] OF CHAR;
                  sbj     :  ARRAY [1..25] OF CHAR;
                  null1   :  ARRAY [1..20] OF CHAR;
                  blks    :  ARRAY [1..6]  OF CHAR;
                  flag    :  CHAR;
                  conf    :  INTEGER;
                  null2   :  ARRAY [1..3]  OF CHAR;
              END;

CONST
    RCDLEN          = 128;
VAR
    RepHdr          : RepFmt;
    Buffer          : ARRAY [1..128] OF CHAR;
    FileRec         : ARRAY [1..RCDLEN] OF CHAR;
    Rcdno,mode      : INTEGER;
    RepFile         : FILE;
    Success         : WORD;
    MsgWriteError   : INTEGER;

PROCEDURE NextReply (VAR Rcdno: INTEGER);

VAR   Nblocks, i, start,err: INTEGER;
    TempStr,filler         : STRING [25];
    LastLine               : STRING [130];
    done, finished, bad    : BOOLEAN;
    myarray                : string[7];
    ch                     : char;
BEGIN
    Bad := FALSE;
    Finished := FALSE;
    BlockRead (RepFile, Buffer, 1, success);      {scrap first block}
    REPEAT
        FillChar(RepHdr,SizeOf(RepHdr),#32);
        {$I-}
        BlockRead (RepFile, RepHdr, 1, Success );  {read header}
        {$I+}
        Err:=IOResult;
        If Err = 0
        THEN
        BEGIN
          MyArray:='';
          FOR i:=1 to 7 DO                           {Build conf #}
            IF RepHdr.confasc[i] <>#32
            THEN
              MyArray:=Myarray+RepHdr.confasc[i];
          Val(MyArray,CurrentBaseNumber,err);       { convert >Integer}
        END
        ELSE
          BEGIN
            Writeln(' ERROR Blockreading file ');
            Halt(err);
          END;

        (** The following DISPLAYs the header information **)

        Writeln('Base #  ',CurrentBaseNumber);
        Writeln('Ref  #  ',ord(RepHdr.Flag);
        Writeln('To      '+rephdr. Rto);
        Writeln('Subj    '+RepHdr. Sbj);     {Get subject of message}
        Writeln('Date    '+Rephdr. Date);    {Set msg date mm-dd-yy}
        Writeln('Time    '+Rephdr. Time);    {Set msg time hh:mm}

        (** Now start work on actual message **)

        Tempstr := '' ;
        FOR i := 1 TO 6 DO IF RepHdr. Blks [i] <> #32  {Get the # of blks }
        THEN                                           {In the message}
          Tempstr := Tempstr + RepHdr. Blks [i];
        VAL (Tempstr, NBlocks, Success);
        Done := FALSE;
        FOR i := 1 TO Nblocks - 1 DO                    {do number of blocks}
        BEGIN
          FillChar (BUFFER, SizeOf (BUFFER), #32);
          LastLine := '';
          BlockRead (RepFile, BUFFER, 1, success);
          LastLine := asc2STR (BUFFER, 128);          {convert from ASCII}
          FOR Start := 1 TO Length (LastLine)         {string to TP string}
          DO
           IF LastLine [start] = #227                 {#227 in QWK paks}
           THEN                                       {Marks eol}
             LastLine [start] := #13;
          Writeln(LastLine);
       END;
    UNTIL Eof(repfile) OR Finished;
    close(repfile);
END;

