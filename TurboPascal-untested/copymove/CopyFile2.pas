(*
  Category: SWAG Title: FILE COPY/MOVE ROUTINES
  Original name: 0002.PAS
  Description: Copy File #2
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:35
*)

{I've been trying to figure out how to do a fairly fast copy
 in pascal.  It doesn't have to be faster then Dos copy, but
 I definatly DON'T want to shell out to Dos to do it!
 I've got the following working... in the IDE of Turbo 6.0!
 If I compile it, it wont work at all.  ALSO... If you COMP
 the Files to check For errors, They are there.  (UGH!)
 (ie, it isn't a perfect copy!)
 The thing is I want to get as much as I can in each pass!
 (But turbo has limits!)
 Heres my code... Just rough, so no Real comments.
}

Program Copy (InFile, OutFile);

Uses Dos;

Var
   I, Count, BytesGot : Integer;
   BP : Pointer;
   InFile,OutFile:File;

   FI,FO : Word;

   Path,
   FileName : String[80];

   DirInfo : SearchRec;
   BaseRec, RecSize : longInt;

begin
   FileName := ParamStr(1);             {Set the SOURCE as the first ParamSTR}
   Path := ParamStr(2);                 {Set the Dest.  as the 2nd paramSTR}

   If paramCount = 0 Then
      begin
           Writeln('FastCopy (C) 1993 - Steven Shimatzki');
           Writeln('Version : 3.0   Usage: FastCopy <Source> <Destination>');
           Halt(1);
      end;

   FindFirst(FileName,Archive,DirInfo);

   If DirInfo.Name <> '' Then
   begin

       RecSize := MaxAvail - 1024;  {Get the most memory but leave some}
       BaseRec := RecSize;

       If RecSize > DirInfo.Size Then      {If a "SMALL" File, gobble it up}
           RecSize := DirInfo.Size;        {In one pass!  Size = Recordsize}

       Count := DirInfo.Size Div RecSize;  {Find out how many Passes!}

       GetMem (Bp, RecSize);   {Allocate memory to the dynamic Variable}

       Assign (InFile,FileName);       {Assign the File}
       Assign (OutFile,Path);          {Assign the File}

       Filemode := 0;     {Open the INFile as READONLY}

       Reset(InFile,RecSize);      {open the input}
       ReWrite(OutFile,RecSize);   {make the output}


       For I := 1 to Count do    {Do it For COUNT passes!}
       begin

            {$I-}
            Blockread(InFile,BP^,1,BytesGot);   {Read 1 BLOCK}
            {$I+}

            BlockWrite(outFile,BP^,1,BytesGot);   {Write 1 BLOCK}

            If BytesGot <> 1 Then
               Writeln('Error!  Disk Full!');

       end;

{If not all read in, then I have to get the rest seperatly!  partial Record!}

       If Not ((Count * RecSize) = DirInfo.Size) Then
       begin
            RecSize := (DirInfo.Size - (Count * RecSize)) ;
                       {^^^ How much is left to read? get it in one pass!}


            FreeMem(Bp, BaseRec);      {Dump the mem back}
            GetMem(Bp, RecSize);       {Get the new memory}

            FileMode := 0;         {Set input For readonly}

            Reset (InFile,1);

            Filemode := 2;         {Set output For Read/Write}

            Reset (OutFile,1);

            Seek(InFile, (Count * BaseRec));   {Move to old location}
            Seek(OutFile, (Count * BaseRec));{ same }

            FI := FilePos(InFile);    {Just used to see where I am in the File}
            FO := FilePos(OutFile);   {Under the Watch Window... Remove later}

            {$I-}
            BlockRead(InFile,Bp^,RecSize,BytesGot);    {REad the File}
            {$I+}

            BlockWrite(OutFile,Bp^,RecSize,BytesGot);  {Write the File}

       end;

       Close(OutFile);
       Close(InFile);

       FreeMem (Bp,RecSize);

   end;

end.

{
You don't close the input- and output File when your finished With the
first count passes. Maybe your last block will not be written to disk,
when you reopen the outputFile For writing. I can't see another problem
right now.
