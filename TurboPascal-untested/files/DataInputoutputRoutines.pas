(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0072.PAS
  Description: Data Input/Output Routines
  Author: BOJAN LANDEKIC
  Date: 05-26-95  23:01
*)

{
I am posting these because I feel they have been "optimized' beyond my
abilities.  If you find a way to further optimize it, by speed, memory
requirements, and other things, please SEND ME THE VERSION!

I have a favour to ask all pascalians.  These routines seem to lock up
sometimes during the Retrieve_Function when I'm in a tight memory situation.
I say tight as I have less then 500k free in one of my programs.  If
someone could rewrite the part which copies (ie. BufSize parts), I would
gladly appreciate it.  Thanks!
}

UNIT DATAIO;
{                        DATA Input/Output Routines

                      Given to the People as FreeWare
                          Includable into SWAG and
                         made expecialy for SWAG :)
                           AUTHOR: BOJAN LANDEKIC
                           SUBJECT: FILE DATA STORAGE (DATAIO)

 These routines allow you to take any number of files (max 255 as I used BYTE
 but you can change the limit to 65535 by using WORD instead).  As I said, it
 allows you to take that many files (or less) and include them into a single
 file (ie. ALLFILES.DAT).  Then you can retrieve/add/delete/view this file.
 I am testing out DATAIO v2.0 with encryption and compression routines, and
 that will be released into the Freeware as well.

 The three sub-units I use are STRIO (string handlers), FILEIO (file in/out
 routines) and VARS (a global declaration unit that is included everywhere).

 Each routine is a FUNCTION and returns an error code (0 if okay).  The
 error codes are examplained under the name of each of the functions.

 Even though this is made freeware I BEG everybody not to make changes and
 distribute them as their own work <grin>.  If you make changes, LET ME KNOW
 as I plan to make a compression program competitive to ZIP/ARJ and others.

 The routines which use the constant BufSize are taken from either FILES.SWG,
 COPYMOVE.SWG, or DOS.SWG from SWAG archives.  I cannot remember who the
 original author is, but I will check and when I find out, you will be
 credited.

}

INTERFACE

Uses Vars,
     StrIo,
     FileIO,
     Crt,
     Dos;

     FUNCTION Retrieve_File(DataFilename, Filename: String; Display: Boolean): Byte;
     FUNCTION Add_File(DataFilename, Filename: String; Display: Boolean): Byte;
     FUNCTION Remove_File(DataFilename, Filename: String; Display: Boolean): Byte;
     FUNCTION Show_File(DataFilename, Filename: String): Byte;

IMPLEMENTATION

FUNCTION Retrieve_File(DataFilename, Filename: String; Display: Boolean): Byte;
{
     This function returns the following:

     0 - [filename] has been retrieved successfully from [DataFilename]
     1 - [DataFilename] was not found/does not exist/was not specified
     2 - Header is incorrect (wrong file maybe?)
     3 - [Filename] was not found in [datafilename]
     4 - Not enough memory for FileBuf (decrese FileBuf)
     5 - Not enough disk space for the to-be-extracted file

     Datafile is formed like this

     XXXXXXXXXX   - The header
     ----------   - Individual file header #1  (information)
     CCCCCCCCCC   - File #1 itself (data/code segment)
     CCCCCCCCCC
     CCCCCCCCCC
     ----------   - Individual file header #2  (information)
     CCCCCCCCCC   - file #2 itself (data/code segment)
     CCCCCCCCCC
     CCCCCCCCCC
     CCCCCCCCCC
     CCCCCCCCCC
     ...          - ... you get the general idea
}
         Const
              BufSize = 16384;

         {for the copy part}
         Type
             FBuf = array[1..BufSize] Of Char;
             Fbf  = ^FBuf;

          Var
             y,                         {date function}
             m,
             d,
             dow,
             h,                         {time function}
             min,
             s,
             hund        : Word;
             CurrentFile : Byte;        {for searching through files}
             DataFile,
             ExtractFile : File;        {file that's to be extracted}
             Difference  : Longint;     {could be a WORD: diff betwen now-real}
             OldPos,                    {used for updating the ORIGINAL header}
             ExtractPos  : LongInt;     {current size of extractfile}

             Bread,                      {for fast/error-free copying}
             Bwrite   :    word;
             FileBuf  :    ^fbf;

             OldX,
             OldY        : Byte;        {for display purposes only}

          Begin
               {Check for enough available memory}
               If (MemAvail > BufSize) then
                  New(FileBuf)
               Else
                   begin
                        Retrieve_File := 4;
                        Exit;
                   End;

               {check if file exists, or if a filename has been specified}
               If (DataFilename = '') OR
                  (Filename = '') OR
                  NOT FileExists(DataFilename) Then
                      Begin
                           Retrieve_File := 1;
                           Dispose(FileBuf);
                           Exit;
                      End;

               {open the file}
               Assign(DataFile, DataFilename);
               Filemode := 2;
               Reset(DataFile, 1);

               {open the file to be extracted/made}
               Assign(ExtractFile, Filename);
               Filemode := 2;
               Rewrite(ExtractFile, 1);

               {check for the header id}
               BlockRead(DataFile, Header, SizeOf(Header));
               If NOT (Header.Identification = Id_Check) Then
                  Begin
                       {if the header not the same then it's not one of ours}
                       Retrieve_File := 2;
                       Dispose(FileBuf);
                       Exit;
                  End;

               {Go to the beginning of the first individual file header}
               Seek(DataFile, SizeOf(Header));

               If Display Then
                  Begin
                       Write('Searching...');
                  End;
               {loop through all the entries until [filename] is found}
               For CurrentFile := 1 To Header.NumberOfFiles Do
                   Begin
                        {read the header}
                        FillChar(FileHeader, SizeOf(FileHeader), #0);
                        BlockRead(DataFile, FileHeader, SizeOf(FileHeader));

                        {so the user doesn't think we're lazy :)}
                        {Writeln('Processing...');
                        Writeln('Filename : ', FileHeader.Filename);
                        Writeln('Size     : ', FileHeader.RealSize);}

                        {compare this file to the one the user wants}
                        If (FileHeader.Filename = Filename) Then
                           Begin
                                {A-Ha, it is the file, extract it!}
                                {check for disk space}
                                If (DiskFree(0) < FileHeader.RealSize) Then
                                   Begin
                                        Retrieve_File := 5;
                                        Dispose(FileBuf);
                                        Close(DataFile);
                                        Close(ExtractFile);
                                        Exit;
                                   End;
                                ExtractPos := 0;
                                If Display Then
                                   Begin
                                        TextBackground(0);
                                        TextColor(7);
                                        GotoXY(1, WhereY);
                                        ClrEol;
                                        Write('Extracting ' + Filename + ': ');
                                        OldX := WhereY;
                                        OldY := WhereY;
                                   End;
                                {make sure we update the header, since the
                                 file is being "updated" as you might see}
                                OldPos := FilePos(DataFile);
                                GetDate(y, m, d, dow);
                                GetTime(h, min, s, hund);
                                Header.UpdatedOn := Leading_Zero(ITOA(m), 2) + '-' +
                                                    Leading_Zero(ITOA(d), 2) + '-' +
                                                    Leading_Zero(ITOA(y), 4) +
                                                    Leading_Zero(ITOA(h), 2) + ':' +
                                                    Leading_Zero(ITOA(min), 2);
                                Seek(DataFile, 0);
                                BlockWrite(DataFile, Header, SizeOf(Header));
                                Seek(DataFile, OldPos);
                                Repeat
                                      BlockRead(DataFile, FileBuf^, BufSize, Bread);
                                      BlockWrite(ExtractFile, FileBuf^, Bread, Bwrite);
                                      Inc(ExtractPos, Bread);
                                      If Display Then
                                         Begin
                                              GotoXY(OldX, OldY);
                                              If (ExtractPos <= FileHeader.RealSize) Then
                                                 Write(StatusBar(FileHeader.RealSize, ExtractPos, 42))
                                              Else
                                                  Write(StatusBar(1, 1, 42)); {100% effect :)}
                                         End;
                                Until (Bread = 0) OR (Bread <> Bwrite) OR
                                      (ExtractPos > FileHeader.RealSize);

                                {To compensate for the over-write}
                                If (ExtractPos > FileHeader.RealSize) Then
                                   Begin
                                        Difference := (ExtractPos - FileHeader.RealSize);
                                        {Seek to the part where THIS file is supposed to end}
                                        Seek(ExtractFile, FilePos(ExtractFile) - Difference);
                                        {Erase the extra garbage}
                                        Truncate(Extractfile);
                                        {Unneccesery, but just to be sure for multiple extractions}
                                        Seek(DataFile, FilePos(DataFile) - Difference);
                                   End;
                                {extracted, now we quit}
                                Retrieve_File := 0;
                                Dispose(FileBuf);
                                Close(DataFile);
                                Close(ExtractFile);
                                If Display Then
                                   Begin
                                        GotoXY(OldX, OldY);
                                        ClrEol;
                                        Writeln('Done!');
                                   End;
                                Exit;
                           End
                        Else
                            Begin
                                 {Go to next record, right}
                                 Seek(DataFile, FilePos(DataFile) + FileHeader.RealSize);
                            End;

                   End;

               {If we get to here, means the file was not in the datafile}
               Retrieve_File := 3;
               Dispose(FileBuf);
               Close(DataFile);
               Close(ExtractFile);
          End;


FUNCTION Add_File(DataFilename, Filename: String; Display: Boolean): Byte;
{ - The part that "copyies" the file was gotten from SWAG, the original
    author of the "copying" part was Floor A.C. Naaijkens
}

{
     This function can possibly return the following values:

     0 - [filename] has been successfully added to [datafilename]
     1 - [datafilename] and/or [filename] have not be specified/don't exist
     2 - Could not create/open [datafilename]
     3 - [datafilename] is not one of our files, wrong file type maybe??
     4 - [filename] opening error
     5 - Not enough memory (on the stack, 16386 needed)..  Decrease BufSize
     6 - Error during copy
     7 - No more files allowed (254 file limit reached
}

         {for the copy part}
         Const
              BufSize = 16384;

         {for the copy part}
         Type
             FBuf = array[1..BufSize] Of Char;
             Fbf  = ^FBuf;

         Var
            y,
            m,
            d,
            dow,                        {for the date}
            h,
            min,
            s,
            hund    : Word;             {for the time}

            DataFile,
            AddFile : File;             {file to be added}
            NewFile : Boolean;          {specifies wheter [datafile] is new}

            Bread,                      {for fast/error-free copying}
            Bwrite   :    word;
            FileBuf  :    ^fbf;

            OldX,
            OldY     : Byte;
            StartAt  : LongInt;         {for display purposes only}

            DirInfo     : SearchRec;

         Begin
              {Check for enough available memory}
              If (MemAvail > BufSize) then
                 New(FileBuf)
              else
                  begin
                       Add_File := 5;
                       Exit
                  End;

               {check if file exists, or if a filename has been specified}
               If (DataFilename = '') OR (Filename = '') Then
                  Begin
                       Add_File := 1;
                       Exit;
                  End;

               {check if the datafile exists}
               Assign(DataFile, DataFilename);
               IF NOT FileExists(Datafilename) Then
                  Begin
                       {$I-}
                       FileMode := 2;
                       Rewrite(DataFile, 1);
                       IF (IOResult <> 0) Then
                          Begin
                               Add_File := 2;
                               Dispose(FileBuf);
                               Exit;
                          End;
                       {$I+}
                       NewFile := True;
                  End
               Else
                   Begin
                        FileMode := 2;
                        {$I-}
                        Reset(DataFile, 1);
                        {$I+}
                        IF (IOResult <> 0) Then
                           Begin
                                Add_File := 2;
                                Dispose(FileBuf);
                                Exit;
                           End;
                        NewFile := False;
                   End;

               If NewFile Then
                  {New file initialization}
                  Begin
                       Getdate(y, m, d, dow);
                       GetTime(h, min, s, hund);
                       FillChar(Header, SizeOf(Header), #0);
                       Header.Identification := Id_Check;
                       Header.CreatedOn := Leading_Zero(ITOA(m), 2) + '-' +
                                           Leading_Zero(ITOA(d), 2) + '-' +
                                           Leading_Zero(ITOA(y), 4) +
                                           Leading_Zero(ITOA(h), 2) + ':' +
                                           Leading_Zero(ITOA(min), 2);
                       Header.UpdatedOn := Header.CreatedOn;
                       Header.NumberOfFiles := 0;
                       BlockWrite(DataFile, Header, SizeOf(Header));
                       Seek(DataFile, 0);
                  End;

               {Already existing file initialization}
               BlockRead(Datafile, Header, SizeOf(Header));

                    {check for the ID string}
               If NOT (Header.Identification = Id_Check) Then
                  Begin
                       Add_File := 3;
                       Dispose(FileBuf);
                       Close(DataFile);
                       Exit;
                  End;

               {Go to the appropriate place in the datafile where
                the writing will start}
               Filename := Strip_Path(UCase(Filename));
               FindFirst(Filename, Archive, DirInfo);
               While (DosError = 0) Do
                     Begin
                          Assign(AddFile, DirInfo.Name);
                          Filemode := 2;
                          {$I-}
                          Reset(AddFile, 1);
                          {$I+}
                          IF (IOResult <> 0) Then
                             Begin
                                  Add_File := 4;
                                  Close(DataFile);
                                  Dispose(FileBuf);
                                  Exit;
                             End;

                          If (Header.NumberOffiles > 254) Then
                             Begin
                                  Add_File := 8;
                                  Dispose(FileBuf);
                                  Close(DataFile);
                                  Exit;
                             End
                          Else
                              Inc(Header.NumberOfFiles);

                          Header.UpdatedOn := Leading_Zero(ITOA(m), 2) + '-' +
                                              Leading_Zero(ITOA(d), 2) + '-' +
                                              Leading_Zero(ITOA(y), 4) +
                                              Leading_Zero(ITOA(h), 2) + ':' +
                                              Leading_Zero(ITOA(min), 2);
                          Seek(DataFile, 0);
                          BlockWrite(DataFile, Header, SizeOf(Header));
                          Seek(DataFile, FileSize(DataFile));

                          {Here we set the individual file header to the appropriate
                          information}
                          FillChar(FileHeader, SizeOf(FileHeader), #0);

                          FileHeader.Attribute := 0;
                          FileHeader.Filename := Dirinfo.Name;
                          FileHeader.CompType := 0;
                          FileHeader.RealSize := FileSize(AddFile);
                          FileHeader.CompSize := FileHeader.RealSize;
                          FileHeader.Crc := 0;

                          {check for disk space}
                          If (DiskFree(0) < FileHeader.RealSize) Then
                             Begin
                                  Add_File := 5;
                                  Dispose(FileBuf);
                                  Close(DataFile);
                                  Exit;
                             End;
                          BlockWrite(DataFile, FileHeader, SizeOf(FileHeader));

                          {copy the file}
                          If Display Then
                             Begin
                                  TextBackground(0);
                                  TextColor(7);
                                  Write('Adding ' + Dirinfo.Name + ': ');
                                  OldX := WhereX;
                                  OldY := WhereY;
                             End;

                          StartAt := FilePos(DataFile);
                          Repeat
                                BlockRead(AddFile, FileBuf^, BufSize, Bread);
                                BlockWrite(DataFile, FileBuf^, Bread, Bwrite);
                                If Display Then
                                   Begin
                                        GotoXY(OldX, OldY);
                                        Write(StatusBar(FileHeader.RealSize, (FilePos(DataFile) - StartAt), 50));
                                   End;
                          Until (Bread = 0) OR (Bread <> Bwrite);

                          Close(AddFile);
                          If Display Then
                             Begin
                                  GotoXY(OldX, Oldy);
                                  ClrEol;
                             End;
                          If (Bread <> Bwrite) then
                             Begin
                                  If Display Then
                                     Writeln('Error occured while adding!');
                                  Add_File := 6
                             End
                          Else
                              Begin
                                   If Display Then
                                      Writeln('Done!');
                                   Add_File := 0;
                              End;
                          FindNext(DirInfo);
                     End; {while loop}
               Dispose(FileBuf);
               Close(DataFile);
         End;


FUNCTION Remove_File(DataFilename, Filename: String; Display: Boolean): Byte;
{  This function returns the following:

   0 - [filename] has been succcessfully deleted from Datafilename
   1 - [filename] or [datafilename] are empty or [datafilename] does not exist
   2 - Not enough disk space (minimum = file size of [datafilename])
   3 - [datafilename] is not of our type.  Maybe not the right format? Hmm..:)
}
         Const
              tFilename    :    String[12] = 'DATA.!!!'; {temporary file}

         Var
            OldX,
            OldY,                          {for display}
            TotalFiles,                    {just for the heck of it}
            CurrentFile    : Byte;         {the for-end loop}
            eFileHeader    : tFileHeader;  {Empty file header}
            tDataFile,                     {only used by the Rename function}
            DataFile       : File;         {file being worked on}
            OldPos         : Longint;      {to be sure pointer is always there}

            Cur_File,                   {for multiple file additions}
            Search_File : String[8];
            Cur_Ext,
            Search_Ext  : String[3];

         Begin
              Assign(DataFile, DataFilename);
              Assign(tDataFile, tFilename);

              {check if file exists, or if a filename has been specified}
              If (DataFilename = '') OR
                  (Filename = '') OR
                  (NOT FileExists(DataFilename)) Then
                       Begin
                            Remove_File := 1;
                            Exit;
                       End
                  Else
                      Reset(DataFile, 1);

              {check for disk space}
              If (DiskFree(0) < FileSize(DataFile)) Then
                 Begin
                      Remove_File := 2;
                      Close(DataFile);
                      Exit;
                 End;

              {check for the header id}
              BlockRead(DataFile, Header, SizeOf(Header));
              If NOT (Header.Identification = Id_Check) Then
                 Begin
                      {if the header is not the same then it's not one of ours}
                      Remove_File := 3;
                      Exit;
                 End;

               {Go to the beginning of the first individual file header}
               Seek(DataFile, SizeOf(Header));

               Filename := UCase(Filename);
               TotalFiles := Header.NumberOfFiles;
               If Display Then
                  Begin
                       Writeln;
                       Write('Removing: ' + Filename);
                       OldX := WhereX + 1;
                       OldY := WhereY;
                  End;
               {loop through all the entries until [filename] is found}
{BUG!          Header.NumberOfFiles seems to change for some reason here!!}
               Search_File := Copy(Filename, 1, Pos('.', Filename) - 1);
               Search_Ext := Copy(Filename, Pos('.', Filename) + 1, Length(Filename));
               For CurrentFile := 1 To TotalFiles Do
                   Begin
                        {read the header}
                        FillChar(eFileHeader, SizeOf(eFileHeader), #0);
                        BlockRead(DataFile, eFileHeader, SizeOf(eFileHeader));
                        OldPos := FilePos(DataFile);

                        If Display Then
                           Begin
                                GotoXy(OldX, OldY);
                                Write(StatusBar(TotalFiles, CurrentFile, 48));
                           End;

                        {compare this file to the one the user wants}
                        Cur_File := Copy(eFileHeader.Filename, 1, Pos('.', eFileHeader.Filename) - 1);
                        Cur_Ext:=Copy(eFileHeader.Filename, Pos('.', eFileHeader.Filename) + 1, Length(eFileHeader.Filename));
                        If (NOT Compare_Filenames(Search_File, Cur_File)) OR
                           (NOT Compare_Filenames(Search_Ext, Cur_Ext)) Then
                                Begin
                                     {remove it from the original archive}
                                     Retrieve_File(DataFilename, eFileHeader.Filename, False);
                                     {add it to the temporary archive}
                                     Add_File(tFilename, eFileHeader.Filename, False);
                                     {go to the next file}
                                End;
                        Seek(DataFile, OldPos + eFileHeader.RealSize);
                   End;
               Close(DataFile);
               Erase(DataFile);
               Rename(tDataFile, DataFilename);
         End;


FUNCTION Show_File(DataFilename, Filename: String): Byte;
{ This functions returns the following:

   0 - Displayed
   1 - [datafilename] is blank or does not exist!
   2 - File is of wrong type, meaning it's not one made by this program.
}

         Var
            OldY           : Byte;
            DataFile       : File;
            CurrentFile    : Byte;

            Cur_File,                        {current file name without extension}
            Search_File    : String[8];      {file name without the extension}
            Cur_Ext,                         {current file extension only, no name}
            Search_Ext     : String[3];      {file extension only, no name}
            TotalFiles     : Byte;           {counter for displayed files}
            TotalBytes     : Longint;        {counter for displayed bytes}

         Begin
               {check if file exists, or if a filename has been specified}
               If (DataFilename = '') OR
                  {(Filename = '') OR}       {not implemented yet}
                  NOT FileExists(DataFilename) Then
                      Begin
                           Show_File := 1;
                           Exit;
                      End;

               {open the file}
               Assign(DataFile, DataFilename);
               Reset(DataFile, 1);

               {check for the header id}
               BlockRead(DataFile, Header, SizeOf(Header));
               If NOT (Header.Identification = Id_Check) Then
                  Begin
                       {if the header is not the same then it's not one of ours}
                       Show_File := 2;
                       Exit;
                  End;

               {Go to the beginning of the first individual file header!
                This is done already by BlockRead, but just to be on the
                safe side :)}
               Seek(DataFile, SizeOf(Header));

               {loop through all the entries until [filename] is found}
               Writeln;
               Writeln;
               Write('Listing of ' + DataFilename);
               GotoXY(26, WhereY);
               Write(FileSize(DataFile));
               Write(' (');
               Write(FileSize(DataFile) DIV 1024);
               Write('k)');
               Writeln;
               GotoXY(1, WhereY);
               Write('Created On: ');
               Write(Copy(Header.CreatedOn, 1, 10));
               Write(' at ');
               Write(Copy(Header.CreatedOn, 11, 5));
               GotoXY(35, WhereY);
               Write('Last updated On: ');
               Write(Copy(Header.UpdatedOn, 1, 10));
               Write(' at ');
               Write(Copy(Header.UpdatedOn, 11, 5));
               GotoXY(71, WhereY);
               Write(' Files: ');
               Write(Header.NumberOffiles);
               Writeln;
               Writeln;
               Writeln('FILENAME.EXT  SIZE                ');
               Writeln('------------  --------------------');


               TotalBytes := 0;
               TotalFiles := 0;
               Search_File := Copy(Filename, 1, Pos('.', Filename) - 1);
               Search_Ext := Copy(Filename, Pos('.', Filename) + 1, Length(Filename));

               For CurrentFile := 1 To Header.NumberOfFiles Do
                   Begin
                        {read the header}
                        FillChar(FileHeader, SizeOf(FileHeader), #0);
                        BlockRead(DataFile, FileHeader, SizeOf(FileHeader));

                        {so the user doesn't think we're lazy :)}

                        Cur_File := Copy(FileHeader.Filename, 1, Pos('.', FileHeader.Filename) - 1);
                        Cur_Ext := Copy(FileHeader.Filename, Pos('.', FileHeader.Filename) + 1, Length(FileHeader.Filename));
                        If Compare_Filenames(Search_File, Cur_File) Then
                           If Compare_Filenames(Search_Ext, Cur_Ext) Then
                              Begin
                                   OldY := WhereY;
                                   Write(FileHeader.Filename);
                                   GotoXY(24, OldY);
                                   Write(' ' :(11 - Length(ITOA(FileHeader.RealSize))));
                                   Write(FileHeader.RealSize);
                                   Writeln;
                                   Inc(TotalBytes, FileHeader.RealSize);
                                   Inc(TotalFiles);
                              End;

                        {go to the next record}
                        Seek(DataFile, FilePos(DataFile) + FileHeader.RealSize);
                   End;

               Writeln('------------  --------------------');
               OldY := WhereY;
               If (TotalBytes = 0) Then
                  Writeln('No files')
               Else
                   If (TotalFiles = 1) Then
                      Write('1 file')
                   Else
                       Write(ITOA(TotalFiles), ' files');
               GotoXY(24, OldY);
               Write(' ' :(11 - Length(ITOA(TotalBytes))));
               Write(TotalBytes);
               Writeln;
               {If we get to here, means everything's cool}
               Close(DataFile);
               Show_File := 0;
         End;
BEGIN
END.

{
 ****************************************************************************
 **** UNIT: VARS.PAS ********************************************************
 ****************************************************************************
}
UNIT VARS;

INTERFACE

TYPE
    {You can always use these :)}
    St20   = String[20];
    St40   = String[40];
    St60   = String[60];
    St80   = String[80];

    tHeader = Record
            Identification: String[20];      {The id string, See ID_Check}
            {CreatedOn/UpdatedOn are like this MM-DD-YYYYHH:MM}
            CreatedOn     : String[15];      {creation date, shouldn't change}
            UpdatedOn     : String[15];      {last modification date}
            NumberOfFiles : Byte;            {number of files in this file}
    End;

    tFileHeader = Record
                Attribute : Byte;            {Attributes:  
                                              0 - None
                                              1 - Hidden (N/A)
                                              2 - System (N/A)
                                              3 - Read Only (N/A)
                                              4 - Archive (N/A)
                                              5 - Directory (N/A)
                                              6 - Label (N/A)
                                             }
                Filename  : String[12];      {Filename as: FILENAME.EXT}
                CompType  : Byte;            {compression type:
                                              0 - None/Store
                                              1 - LZH (N/A)
                                             }
                EncrType  : Byte;            {encryption type:
                                              0 - None/Store
                                              1 - XOR (N/A)
                                              2 - RSA (N/A)
                                             }
                RealSize  : Longint;         {actual size}
                CompSize  : Longint;         {compressed size} {N/A}
                Crc       : Longint;         {Circular Redundancy Check} {N/A}
    End;

VAR
   Header      : tHeader;               {the MAIN header}
   FileHeader  : tFileHeader;           {each file's header}

CONST
     {Please modify the ID_Check to a unique value used in your programs!
      I use the below one, as there's virtually no chance of anyone using the
      one below.  It just makes sure that incase a .DAT file loses the ID it
      can't be read!  Sometimes I lower the String[20] to String[2] and make
      it 'PK', <grin>}
     Id_Check          : String[20]  = #5#255'DATAIO File';  {for checking!}


IMPLEMENTATION

BEGIN
END.

{
 ****************************************************************************
 **** UNIT: FILEIO.PAS ******************************************************
 ****************************************************************************
}
UNIT FILEIO;


INTERFACE

Uses Vars,
     Dos;

     {This is from the Borland Pascal's HELP files.  I'm not sure if it's
     legel to post this one, but if it's not, people in SWAG, please
     replace FileExists function with anyone of the ones you guys have in
     FILES.SWG :)}
     FUNCTION FileExists(FileName: String): Boolean;
     {Author is from SWAG archives' FILES.SWG, whoever you are, let me know
     and I will credit you}
     FUNCTION Compare_FileNames(SearchStr,NameStr:string): boolean;
     {Author is from SWAG archives' FILES.SWG, whoever you are, let me know
     and I will credit you}
     PROCEDURE WipeFile(fn: string);


IMPLEMENTATION

FUNCTION FileExists(FileName: String): Boolean;
{
 *** Boolean function that returns True if the file exists;otherwise,
     it returns False. Closes the file if it exists.
 ***
}
         Var
            F: file;
         Begin
              {$I-}
              Assign(F, FileName);
              FileMode := 0;  { Set file access to read only }
              Reset(F);
              Close(F);
              {$I+}
              FileExists := (IOResult = 0) and (FileName <> '');
         End;  { FileExists }

FUNCTION Compare_FileNames(SearchStr,NameStr:string): boolean; assembler;
{
 Compare SearchStr with NameStr, and allow wildcards in SearchStr.
 The following wildcards are allowed:
 *ABC*        matches everything which contains ABC
 [A-C]*       matches everything that starts with either A,B or C
 [ADEF-JW-Z]  matches A,D,E,F,G,H,I,J,W,V,X,Y or Z
 ABC?         matches ABC, ABC1, ABC2, ABCA, ABCB etc.
 ABC[?]       matches ABC1, ABC2, ABCA, ABCB etc. (but not ABC)
 ABC*         matches everything starting with ABC
 (for using with DOS filenames like DOS (and 4DOS), you must split the
  filename in the extention and the filename, and compare them seperately)
}

var
 LastW:word;
asm
 cld
 push ds
 lds si,SearchStr
 les di,NameStr
 xor ah,ah
 lodsb
 mov cx,ax
 mov al,es:[di]
 inc di
 mov bx,ax
 or cx,cx
 jnz @ChkChr
 or bx,bx
 jz @ChrAOk
 jmp @ChrNOk
 xor dh,dh
@ChkChr:
 lodsb
 cmp al,'*'
 jne @ChkQues
 dec cx
 jz @ChrAOk
 mov dh,1
 mov LastW,cx
 jmp @ChkChr
@ChkQues:
 cmp al,'?'
 jnz @NormChr
 inc di
 or bx,bx
 je @ChrOk
 dec bx
 jmp @ChrOk
@NormChr:
 or bx,bx
 je @ChrNOk
{From here to @No4DosChr is used for [0-9]/[?]/[!0-9] 4DOS wildcards...}
 cmp al,'['
 jne @No4DosChr
 cmp word ptr [si],']?'
 je @SkipRange
 mov ah,byte ptr es:[di]
 xor dl,dl
 cmp byte ptr [si],'!'
 jnz @ChkRange
 inc si
 dec cx
 jz @ChrNOk
 inc dx
@ChkRange:
 lodsb
 dec cx
 jz @ChrNOk
 cmp al,']'
 je @NChrNOk
 cmp ah,al
 je @NChrOk
 cmp byte ptr [si],'-'
 jne @ChkRange
 inc si
 dec cx
 jz @ChrNOk
 cmp ah,al
 jae @ChkR2
 inc si              {Throw a-Z < away}
 dec cx
 jz @ChrNOk
 jmp @ChkRange
@ChkR2:
 lodsb
 dec cx
 jz @ChrNOk
 cmp ah,al
 ja @ChkRange        {= jbe @NChrOk; jmp @ChkRange}
@NChrOk:
 or dl,dl
 jnz @ChrNOk
 inc dx
@NChrNOk:
 or dl,dl
 jz @ChrNOk
@NNChrOk:
 cmp al,']'
 je @NNNChrOk
@SkipRange:
 lodsb
 cmp al,']'
 loopne @SkipRange
 jne @ChrNOk
@NNNChrOk:
 dec bx
 inc di
 jmp @ChrOk
@No4DosChr:
 cmp es:[di],al
 jne @ChrNOk
 inc di
 dec bx
@ChrOk:
 xor dh,dh
 dec cx
 jnz @ChkChr        { Can't use loop, distance >128 bytes }
 or bx,bx
 jnz @ChrNOk
@ChrAOk:
 mov al,1
 jmp @EndR
@ChrNOk:
 or dh,dh
 jz @IChrNOk
 jcxz @IChrNOk
 or bx,bx
 jz @IChrNOk
 inc di
 dec bx
 jz @IChrNOk
 mov ax,[LastW]
 sub ax,cx
 add cx,ax
 sub si,ax
 dec si
 jmp @ChkChr
@IChrNOk:
 mov al,0
@EndR:
 pop ds
end;


PROCEDURE WipeFile(fn: string);
          Var
             size,
             total: longint;
             loop,
             towrite,
             numwritten: word;
             f: file;
             buffer: array[1..1024] of byte;

          begin
               assign(f,fn);
               filemode := 2;
               setfattr(f,0);
               if doserror = 0 then
                  begin
                       rename(f,'~~~~~~~~.~~~');
                       rename(f,'~');
                       for loop := 1 to sizeof(buffer) do
                           buffer[loop] := random(256);

                       reset(f,1);
                       size := filesize(f);
                       total := 0;
                       repeat
                             {Figure out how much to write }
                             towrite := sizeof(buffer);
                             if towrite+total > size then
                                towrite := size - total;

                             blockwrite(f,buffer,towrite,numwritten);
                             inc(total,numwritten);
                       until (total = size);

                       Seek(f,0);
                       Truncate(f);

                       close(f);
                       erase(f);
                  end;
          end;



BEGIN
END.

{
 ****************************************************************************
 **** UNIT: STRIO.PAS *******************************************************
 ****************************************************************************
}
{ *** Handles string in/output and various conversion routines
  ***
}

Unit StrIO;

INTERFACE

Uses Vars;

     {From SWAG's CRT, modified to allow for Barlength}
     FUNCTION StatusBar(total, amt, barlength: longint): St80;
     FUNCTION ITOA(i: longint): St40;
     FUNCTION ATOI(s: St40): LongInt;
     {From SWAG}
     FUNCTION UpCase(c: Char): Char;
     FUNCTION UCase(s: String): String;
     FUNCTION RepStr(Times: Byte; Which: Char): String;
     FUNCTION Strip_Path(Fullfilename: String): String;
     FUNCTION Leading_Zero(Number: String; Digits: Byte): String;
     FUNCTION Read_Str(StrLen     : Byte;
                       InputFg,
                       InputBg    : Integer;
                       Hidden,
                       Spaces     : Char;
                       SpinWanted,
                       Display,
                       Upper,
                       OnlyNumbers,
                       AutoReturn : Boolean;
                       Default    : String): String;
     PROCEDURE Flush_Keyboard_Buffer;
     FUNCTION Right_Pad(s: String; MaxLength: Word): String;
     FUNCTION Right_Strip(s: String): String;
     FUNCTION Right_Justify(s: String; sl: Byte): String;

IMPLEMENTATION

Uses Crt;

FUNCTION CharStr(HowMuch: Byte; WithWhatChar: Char): String;
{
 *** fills charStr with withwhatchar to the howmuch
 ***
}
         Var
            j       : Integer;
            TempStr : St80;

         Begin
              TempStr := '';
              For J := 1 To HowMuch Do
                  Insert(WithWhatChar, TempStr, J);
              CharStr := TempStr;
         End;




FUNCTION StatusBar(total, amt, barlength: longint): St80;
{         Const
              BarLength = 30;}

         Var
            a,
            b,
            c,
            d       : longint;
            sD      : String; {for conversion}
            percent : real;
            st      : string;

         Begin
              If (total = 0) OR (amt = 0) Then
                 Begin
                      StatusBar := '';
                      Exit;
                 End;
              If (Amt > Total) Then
                 amt := total;
              Percent := Amt / Total * (Barlength * 10);
              a := trunc(percent);
              b := a div 10;
              c := 1;
              percent := amt / total * 100;
              d := trunc(percent);
              Str(d, sD);
              st := ' (' + sD + '%)';
              StatusBar := CharStr(b * c, #219) + CharStr(Barlength - (b * c), #176) + st;
         End;




FUNCTION ITOA(i: longint): St40;
{
 *** Converts integers into alphanumericals or strings
 ***
}
         Var
            stTemp: St20;

         Begin
              Str(i, stTemp);
              ITOA := stTemp;
         End;


FUNCTION ATOI(s: St40): LongInt;
{
 *** Converts a string into a integer/real
 ***
}
         Var
            Code: Integer;
            lTemp: LongInt;
            rTemp: Real;

         Begin
              Val(s, rTemp, Code);
              If (Code <> 0) Then
                 rTemp := 0;
              lTemp := Trunc(rTemp);
              ATOI := lTemp;
         End;

FUNCTION UpCase(C: Char): Char; Assembler; { will replace TP's built-in upcase }
         ASM
            MOV DL, C
            MOV AX, $6520
            INT $21
            MOV AL, DL           { function result in AL                 }
         END;


FUNCTION UCase(s: String): String;
{
 *** Converts any string(s) into upper case letters
 ***
}
         Var
            J : Integer;

         Begin
              For J := 1 to Length(s) Do
                  s[J] := StrIo.UpCase(s[J]);
              UCase := S;
         End;


FUNCTION RepStr(Times: Byte; Which: Char): String;
         Var
            J        : Byte;
            tString  : String;

         Begin
              tString := '';
              For J := 1 To Times Do
                  tString := tString + Which;
              RepStr := tString;
         End;


FUNCTION Strip_Path(Fullfilename: String): String;
         Var
            tString: String;

         Begin
              tString := FullFilename;
              While (Pos('\', tString) <> 0) Do
                    Delete(tString, 1, Pos('\', tString));
              Strip_Path := tString;
         End;


{
 Makes sure that NUMBER is DIGITS digits.  Ie if DIGITS = 10 and NUMBER = 29
 the result is 0000000029, 10 DIGITS :) Simple hugh?
}
FUNCTION Leading_Zero(Number: String; Digits: Byte): String;
         Var
            tString   : String;             {temporary zero holding spot}
            NeedZeros : Integer;            {Number of zeros needed}
            J         : Byte;               {for the FOR-LOOP}

         Begin
              tString := '';
              NeedZeros := Digits - Length(Number);
              If (NeedZeros > 0) Then
                 Begin
                      for J := 1 TO NeedZeros Do
                          tString := tString + '0';
                      tString := tString + Number;
                 End
              Else
                  tString := Number;

              Leading_Zero := tString;
         End;


FUNCTION Read_Str(StrLen     : Byte;
                  InputFg,
                  InputBg    : Integer;
                  Hidden,
                  Spaces     : Char;
                  SpinWanted,
                  Display,
                  Upper,
                  OnlyNumbers,
                  AutoReturn : Boolean;
                  Default    : String): String;
{
 *** Gets string from local/remote
     StrLen - String length
     InputFg - Foreground for input
     InputBg - Background for input
     Hidden - character to display instead of entered characters or #0
     Spaces - Character to display where nothing is written.
     Display - Display output
     Upper - force upper case
     OnlyNumbers - Characters between 0-9 are allowed, nothing else
     AutoReturn - Wheter to hig enter automatically after STRLENth character
     SpinWanted - Wheter or not to spin a character
     Default - Text displayed as if user/modem typed it in.
 ***
}
         Var
            ChIn    : Char;         {character read in}
            StrCount: Integer;      {current location in string}
            J       : Integer;      {used in For-loop combo}
            TempStr : String;       {temporary string}
            OldX,
            OldY,
            OldFg,
            OldBg    : Word;         {save coordinates}
            SpinCount: Byte;

         Const
              Spin   : Array [1..4] Of Char = ('|', '/', '-', '\');

         Begin
              TempStr := '';
              ChIn := #0;
              StrCount := 0;
              SpinCount := 0;

              if Default <> #0 Then
                 Begin
                      TempStr := Default;
                      StrCount := Length(TempStr);
                 End;

              If Display Then
                Begin
                     OldX := WhereX;
                     OldY := WhereY;
                     OldFg := TextAttr MOD 16;
                     OldBg := TextAttr SHR 4;
                     TextColor(InputFg);  TextBackground(InputBg);
                     if (Spaces < #32) Then
                        Spaces := #32;
                     For J := 1 to StrLen Do
                         Write(Spaces);
                     GotoXY(OldX, OldY);
                     If (Default <> #0) Then
                        Begin
                             For J := 1 to Length(Default) Do
                                 If (Hidden <> #0) Then
                                    Write(Hidden)
                                 Else
                                     Write(Default[J]);
                        End
                End;
              Repeat
                    Repeat
                          If SpinWanted Then
                             Begin
                                  Inc(SpinCount);
                                  If (SpinCount > 4) Then
                                     SpinCount := 1;
                                  Write(Spin[SpinCount]);
                                  GotoXY(WhereX - 1, WhereY);
                                  Delay(30);
                                  Write(' ');
                                  GotoXY(WhereX - 1, WhereY);
                             End;
                    Until Keypressed;
                    ChIn := Readkey;

                    If (ChIn = #0) Then
                       Exit;

                    If Upper then
                       ChIn := Upcase(ChIn);

                    Case UpCase(ChIn) Of
                        #19: Begin {left arrow}
                                   If (StrCount > 1) Then
                                      Begin
                                           Dec(StrCount, 1);
                                           If Display Then
                                              GotoXY(WhereX - 1, WhereY);
                                      End;

                             End;
                         #4: Begin {right arrow}
                                   If (StrCount < StrLen) Then
                                      Begin
                                           Inc(StrCount, 1);
                                           Insert(#32, TempStr, StrCount);
                                           If Display Then
                                              GotoXY(WhereX + 1, WhereY);
                                      End;
                             End;
                         #8: Begin
                                  If (StrCount > 0) Then
                                     Begin
                                          Dec(StrCount, 1);
                                          If Display Then
                                            Begin
                                                 GotoXY(WhereX - 1, WhereY);
                                                 Write(Spaces);
                                                 GotoXY(WhereX - 1, WhereY);
                                            End;
                                          Delete(TempStr, Length(TempStr), 1);
                                     End;
                                  ChIn := #0;
                             End;
                         #13: Begin
                                   If Display Then
                                      GotoXY(1, WhereY + 1);
                              End;
                       #32..#255: Begin
                                       If (StrCount < StrLen) Then
                                          Begin
                                               If OnlyNumbers Then
                                                  Begin
                                                       Case ChIn Of
                                                       '0'..'9', '.': Begin
                                                                           Inc(StrCount);
                                                                           Insert(ChIn, TempStr, StrCount);
                                                                      End;
                                                       Else {anything except numbers}
                                                           ChIn := #0;
                                                       End;
                                                  End {if onlynumbers then}
                                               Else
                                                   Begin
                                                       Inc(StrCount);
                                                       Insert(ChIn, TempStr, StrCount);
                                                   End;
                                          End
                                       Else
                                           ChIn := #0;
                                  End;
                        Else
                            ChIn := #0;
                         End; {case}

                         If (StrCount = StrLen) Then
                            Begin
                                 If AutoReturn Then
                                    Begin
                                         ChIn := #13;
                                         GotoXY(1, WhereY + 1);
                                    End;
                            End;

                         If Display AND (ChIn <> #0) Then
                            if (Hidden > #32) Then {space or no pw}
                               Write(Hidden)
                            Else
                                Write(ChIn);
              Until (ChIn = #13) OR (ChIn = #27);

              If Display Then
                 Begin
                      TextColor(OldFg);
                      TextBackground(OldBg);
                 End;

              Read_Str := TempStr;
         End;



PROCEDURE Flush_Keyboard_Buffer;
          Var
             ChIn        : Char;        {for clearing the keyboard buffer}

          Begin
               While Keypressed Do
                     ChIn := ReadKey;
          End;


FUNCTION Right_Pad(s: String; MaxLength: Word): String;
         Const
              tString : String = '';
              HowMany : Byte = 0;
              J       : Byte = 0;

         Begin
              J := 0;
              HowMany := 0;
              tString := '';

              {check for greater then number strings}
              If (Length(s) > MaxLength) Then
                 Begin
                      tString := Copy(s, 1, MaxLength);
                      Exit;
                 End
              Else
                  Begin
                       HowMany := (MaxLength - Length(s));
                       Repeat
                             Inc(J);
                             tString := tString + #32;
                       Until J >= HowMany;
                       tString := s + tString;
                  End;

              Right_Pad := tString;
         End;

FUNCTION Right_Strip(s: String): String;
         Var
            StrLen,
            Count        : Byte;

         Begin
              StrLen := Length(s);
              Count  := StrLen + 1;
              Repeat
                    Dec(Count);
              Until (s[Count] <> #32);
              Delete(s, Count + 1, StrLen - Count);
              Right_Strip := S;
         End;

FUNCTION Right_Justify(s: String; sl: Byte): String;
         Var
            tString2,
            tString: String;
            Where,
            HowMuch: Byte;

         Begin
              tString := '';
              tString2 := '';
              tString := s;
              If Length(tString) > Sl Then
                 Begin
                      tString2 := Copy(tString, 1, Sl);
                      Right_Justify := tString2;
                      Exit;
                 End;

              Where := 1;
              Where := sl - Length(tString);

              FillChar(tString2, Where, #32);
              Insert(tString, tString2, Where);
              Delete(tString2, Where + Length(tString), Length(tString2) - (Where + Length(tString)) + 1);
              Right_Justify := tString2;
         End;




BEGIN
END.

{
PLEASE!  Anybody who can optimize this so it doesn't require as much
stack/heap space as it does now, I'd really appreciate it.  Also, if you
find a way to replace ANYTHING in here with ASM (or in any of the sub-units)
PLEASE MAIL ME THE MODIFICATIONS!  Mail to miki.landekic@canrem.com or leave
mail in the pascal echo you saw this in to Miki Landekic.  Thanks in advance

(written by Bojan Landekic)
}


