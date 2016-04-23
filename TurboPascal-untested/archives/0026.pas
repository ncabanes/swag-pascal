{
          ZNDEL version 2.1   -  Public Domain / Freeware

        Exclusive-Delete utility ( originally 'ZIP-NOT-DEL' ? )

              E. de Neve    CompuServe ID: 100121,1070


   Version 2.1  November 1, 1994

   New in version 2.1
     - fixed bug in redirection detection
     - confirmation prompt will now bypass redirection


   Version 2.0  August 17, 1994

   New in version 2.0 :
     - recognizes 12 of the most common archive format extensions
     - full DIR-style wildcard support
     - confirmation asked before deleting
     - no confirmation needed in assigned working directories
     - realistic limits & safety checks for maximum number of files
     - switch to override prompting, useful in batch files


   Version 1.0  (Original)  Written  Sept. 21, 1991  by  G. Palmer

}

{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+,Y-} {* compiler switches *}
Program Zndel2;

Uses Dos, Crt;

Type
  FullNameStr = String [12];

Const
  Assume_Yes: Boolean = False;

  Maxdelete   =  2000;
  Maxsave     =  32;
  Maxworkdirs =  32;

  MetaBufSize =  4000;  { I/O buffer used when patching .exe file }

  ConfigStart: String [5] = '(CFG<'; { mark start of config area }
  Nr_workdirs: Byte =  0;
  Workdirs: Array [1..MaxWorkDirs] Of FullNameStr =
  ('', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
  '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '');
  ConfigEnd: String [5] = '>CFG)'; { end of config area }

  MaxArchExt  =  12;
  ArchExt: Array [1..MaxArchExt] Of String [3] =
  ( 'ZIP', 'ARJ', 'LZH', 'ARC', 'LIM', 'UC2',
  'PAK', 'SQZ', 'HAP', 'SDN', 'ZOO', 'SIT' );


  VaLetSet: Set Of Char = [ '#'..')', '!', '@', '^', '~', '_', '{',
  '}', '-', '0'..'9', 'A'..'Z', 'a'..'z'];
  { set of valid letters that make up an unambiguous file/dir name }


Var
  CH:                     Char;
  I:                      Word;
  Afile:                  File;
  NormOut:                Text;
  Nr_Names_To_Save:       Word;
  Nr_Files_To_Delete:     Word;
  Nr_Files_Found:         Word;
  Nr_Files_to_Protect:    Word;
  TempStr, UpStr:         FullNameStr;
  Files_To_Delete :       Array [1..maxdelete]   Of FullNameStr;
  Names_To_Save:          Array [1..maxsave]     Of FullNameStr;
  Search_Record:          SearchRec;
  MetaBuffer:             Array [0..MetaBufSize] Of Byte;

Procedure Show_Info;
Begin
  WriteLn;
  WriteLn ('Deletes all files in the current directory, except:');
  WriteLn ('        Files listed on the command line, DIR-style wildcards allowed.');
  WriteLn ('        Archived files ( ZIP, LZH, ARC, ARJ, LIM, ZOO etc. )');
  WriteLn ('        Hidden, System and ReadOnly files.');
  WriteLn;
  WriteLn ('Usage:  ZNDEL [/Y] [filespec (filespec) ]  delete all but filespecs & archives');
  WriteLn ('                └──>   assume YES on all prompting');
  WriteLn ('        ZNDEL /S       show current settings');
  WriteLn ('        ZNDEL /?       show this help text');
  WriteLn;
  WriteLn ('        ZNDEL /W  [workdir (workdir) ]   assign working directories ');
  WriteLn;
  WriteLn ('        ZNDEL will always ask for confirmation before deleting files,');
  WriteLn ('        unless the current directory is one of the assigned working dirs.');
  Halt;
End;


Procedure WildExpand (Var inname: String);

Var workname: String [12]; {name}
  Havecard: Boolean;
  S, D, P: Byte;           {counters source,destin,point}
  ic: Char;

Procedure PartExpand;
Begin
  If HaveCard Then IC := '?'
  Else
    If (S > Byte (inname [0] ) ) Or (P > 0) Then IC := ' ' Else
    Begin
      IC := UpCase (inname [S] );
      If IC = '*' Then
      Begin Havecard := True; IC := '?'; End
      Else
        If IC = '.' Then
        Begin P := S; IC := ' '; End;
      Inc (S);
    End; {real ic digest}

  Workname [D] := IC;
  Inc (D);
End;


Begin

  S := 1; { source }
  D := 1; { destin }
  P := 0; { point-pos }

  workname [0] := #12;
  workname [9] := '.';


  HaveCard := (Inname [0] > #0) And (inname [1] = '.');

  While (Byte (inname [0] ) > S) And (Inname [S] = ' ') Do Inc (S);
  { 'remove' front spaces... }

  Repeat {copy into name8}
    PartExpand;
  Until D = 9;

  S := 1; {FIND any point if it exists..}
  While (P = 0) And (S <= Byte (Inname [0] ) ) Do
  Begin
    If inname [S] = '.' Then P := S Else Inc (S);
  End;

  Havecard := ( (P = 0) And (Inname [0] > #0) )  Or (Inname [0] = #1);

  S := P; {on point }
  P := 0;

  Inc (S); {both get over point}
  Inc (D);

  PartExpand; {ext 3 chars}
  PartExpand;
  PartExpand;

  Inname := WorkName;
End;



Function MatchWild (Var WW1, SS2: String): Boolean; {count on BOTH being expanded..}
Var CC: Byte;
Begin

  {loop both strings, if wild has non-? char that doesnt match SS2 char,
  OR SS2 char has ? that doesn't match SPACE, then exit}

  matchwild := False;

  For CC := 1 To 12 Do If WW1 [CC] <> SS2 [CC] Then
  Begin
    If ( (ww1 [cc] = ' ') And (ss2 [cc] <> '?') )
       Or
       ( (WW1 [CC] <> '?') )
    Then Exit;
  End;

  Matchwild := True;
End;


Function SameName (Wild, Sample: String): Boolean;
Begin
  { Note: WILD must be an already expanded 13-character wildcard string}
  Wildexpand (Sample);
  Samename := matchwild (Wild, Sample);
End;

Procedure Show_Config;
Begin
  Write ('Assigned working directories:   ');
  If Nr_Workdirs = 0 Then WriteLn ('None.');
  For I := 1 To Nr_Workdirs Do Write (Workdirs [I], '  ');
  WriteLn;
  Halt;
End;


Function ValidDirName (Var Workstring: String): Boolean;
Var I: Byte;
  NumPoints: Byte;
  PointStart: Byte;
  ExtSize: Byte;
  NameSize: Byte;
Begin
  PointStart := 0;
  For I := 1 To Length (WorkString) Do
  Begin
    If (Workstring [i] = '.') And (Pointstart = 0) Then
    Begin {point digest}
      If I > 1 Then PointStart := I
      Else Begin ValidDirName := False; Exit; End;
      {too many points, or starts with point..}
    End
    {no point - then must be valid filename letter}
    Else
      If Not (Workstring [i] In VaLetSet)
      Then Begin ValidDirName := False; Exit; End;
  End;

  {finally, check if the extension OR filename are not too big: }

  If ( (Pointstart = 0) And (Length (Workstring) > 8) )
     Or ( Pointstart > 9)
     Or ( ( Pointstart > 1) And (Length (WorkString) > (Pointstart + 3) ) )
  Then ValidDirname := False
  Else
    ValidDirName := True;
End;


Procedure UpcaseString (Var Workstring: String);
  Var I: Byte;
  Begin
    For I := 1 To Length (WorkString) Do WorkString [i] := UpCase (WorkString [i] );
  End;


Function FindLocation (Var Infile: File;  Sample: String): LongInt;

 { universal 'binary file' search routine, works with files }
 { of any length, even if much larger than 64Kb             }
 { searches a file for sample string using the 'Metabuffer' }
 { assumes the file INFILE was already open for reading     }

Var I: LongInt;
  J: Word;
  Location: LongInt;
  BytesRead: Word;
  SearchIndex: LongInt;
Begin

  SearchIndex := 0;
  FindLocation := 0;

  If Length (Sample) = 0 Then Exit;

  Repeat
    Seek (InFile, Searchindex);

    BlockRead (InFile, Metabuffer, SizeOf (Metabuffer), BytesRead);

    If BytesRead < Length (Sample) Then Exit; {file or buffer too small..}

    For I := 0 To (BytesRead - Length (Sample) ) Do
      If MetaBuffer [i] = Byte (Sample [1] ) Then
      Begin
        J := 1;

        While (J < Length (Sample) ) And
              ( Metabuffer [I + J] = Byte (Sample [J + 1] ) )
        Do Inc (J);

        If J = Length (Sample)  Then Begin
          FindLocation := SearchIndex + I;
          Exit;
        End;

      End;

    If BytesRead < SizeOf (Metabuffer) Then Exit;    { at end of file}

    SearchIndex := SearchIndex + BytesRead - Length (Sample) + 1;

    { This ensures overlap between consecutive buffer reads; because
    of this overlap, the whole procedure will still work even in
    the extreme case when Sizeof(Metabuffer)=Length(Sample)  !!! }

  Until False;

End;




Procedure Config_Workdirs;
 Var BytesRead, BytesWritten: Word; {dummy args for Blockread/write}
   PatchAddr1, PatchAddr2: Word;
   I, J: Word;
   NewDirs: Word;
   ParamString: String;
 Begin
   { put supplied working dir names into array }

   NewDirs := ParamCount;       { First parameter was /W }

   Nr_Workdirs := 0;            { disregard old settings }

   For i := 2 To NewDirs Do     { expand & add to SAVE specs list }
     If (Nr_workdirs < MaxWorkDirs) Then   { check for max nr of dirs }
     Begin
       ParamString := ParamStr (i);
       UpcaseString (ParamString);
       If ParamString [1] = '/' Then Show_Info; { wrong place for option }

       If ValidDirName (ParamString) Then Begin
         Inc (Nr_Workdirs);
         If Paramstring [Byte (Paramstring [0] ) ] = '.' {get rid of ugly points at end}
         Then Dec (Byte (paramstring [0] ) );
         WorkDirs [Nr_Workdirs] := ParamString;
       End;
     End;

   { Find 'home' directory, find ZNDEL.EXE (or whatever our name was)
   find out where to insert the new workdirs data structure,
   then copy them to it. }

   Assign (Afile, ParamStr (0) ); { it's ME ! }
   FileMode := 2;               { default, read and write possible }
   Reset (Afile, 1);            { open, counting will be done in BYTES }

   If IOResult <> 0 Then Begin
     WriteLn ('Configuration failed - file not found.');
     WriteLn;
     Halt;
   End;

   PatchAddr1 := FindLocation (Afile, Configstart);
   PatchAddr2 := FindLocation (Afile, ConfigEnd);

   If IOResult <> 0 Then Begin
     WriteLn ('Configuration failed - error reading file.');
     WriteLn;
     Halt;
   End;


   If  (PatchAddr1 = 0) Or (PatchAddr2 = 0)
       Or ( (PatchAddr2 - PatchAddr1) <> (Ofs (ConfigEnd) - Ofs (ConfigStart) ) )
   Then Begin
     WriteLn ('Error - incompatible structure in: ', ParamStr (0) );
     WriteLn;
     Halt;
   End;

   { Now seek to config area in file and copy our own data to it.. }
   { The area to patch starts just after 'configstart' at Nr_Workdirs}

   Seek (Afile, PatchAddr1 + Length (ConfigStart) );

   BlockWrite (Afile, Nr_Workdirs, ( SizeOf (Nr_Workdirs) + SizeOf (Workdirs) ),
   BytesWritten);

   Close (Afile);

   If IOResult <> 0 Then WriteLn (' Error trying to update options.')
   Else
   Begin
     WriteLn ('New settings written to ', ParamStr (0) );
     Show_Config;
   End;

   Halt;
 End;



Procedure Get_Command_Line_Args;
Var
  I:   Word;
  ParamString : String;
  Nr_Params, DigestParam: Byte;

Begin
  Nr_Params := ParamCount;
  If Nr_Params = 0  Then Exit;

  DigestParam := 1;

  ParamString := ParamStr (1);
  UpcaseString (ParamString);

  If ParamString = '/W' Then  Config_Workdirs;
  If ParamString = '/S' Then  Show_Config;

  If ParamString = '/Y' Then  Begin
    Assume_Yes := True;
    Inc (DigestParam);
  End;

  If ParamString = '/?' Then  Show_Info;


  { no valid options so interpret the rest as filespecs of files to be saved }

  Nr_Names_to_save := 0;

  For i := DigestParam To Nr_Params Do   { expand & add to SAVE specs list }
    If Nr_Names_to_Save < MaxSave Then         { check for max nr of names }
    Begin
      ParamString := ParamStr (i);
      If ParamString [1] = '/' Then Show_Info;    { wrong place for option }
      WildExpand (ParamString);
      Inc (Nr_Names_to_Save);
      Names_to_Save [Nr_Names_to_save] := ParamString;
    End;

End;




Procedure Check_If_Protected (Curr_file: String);
Var  I: Integer;
Begin
  Inc (Nr_Files_Found);
  Inc (Nr_Files_to_Protect);  { start and assume it's protected }

  If ( (Search_Record.Attr And ReadOnly) = ReadOnly) Then Exit; { Protected }

  For I := 1 To MaxArchExt Do              { does it have a known extension? }
    If Pos ('.' + ArchExt [I] , Curr_file) > 1 Then Exit;

  For I := 1 To Nr_Names_to_Save Do                 { was it on cmd line? }
    If SameName (Names_to_Save [i], Curr_File)  Then Exit;

  Dec (Nr_Files_to_Protect);  { not protected after all }
  Inc (Nr_Files_To_Delete);

  Files_To_Delete [ Nr_Files_to_Delete ] := Curr_File;  { add to delete list }

End;


Function InWorkDir: Boolean;
Var ThisDir: String;
  T: Word;
Begin

  InWorkDir := True;

  { Test if we are in a working dir, or any one of its subdirs.... }

  GetDir (0, thisdir);
  Thisdir := Thisdir + '\';
  For T := 1 To Nr_WorkDirs Do
  Begin
    If Pos ('\' + WorkDirs [T] + '\', Thisdir) > 0 Then Exit;
  End;

  InWorkDir := False;
End;


Procedure SayPrott; { ask for confirmation }
Begin
  WriteLn (NormOut,'! WARNING - this is not a known working directory.');
  Write (NormOut,'Are you sure (Y/N)? ');
  While KeyPressed Do CH := ReadKey;
  CH := ReadKey;
  WriteLn (NormOut,CH);
  If UpCase (CH) <> 'Y' Then Halt;
End;


Procedure Bye;
Begin
  WriteLn;
  WriteLn (NormOut,'ZNDEL 2.1  aborted.  Some files not deleted.');
  Halt;
End;


Function Redirected: Boolean;
 { detect if user wants redirectable output }
Assembler;
Asm
  MOV   AX, 04400h  { query device info }
  MOV   BX, 1       { for device STDOUT }
  INT   021h
  XOR   AX, AX
  TEST  DL, 1 shl 7 { bit 7 clear: redirected to file }
  JZ   @redirred
  TEST  DL, 1 shl 1 { bit 1 set: device is standard output }
  JNZ  @standard
 @redirred:
  INC   AX          { true if redirected }
 @standard:
End;


Begin
  AssignCrt(NormOut); { save default mode of screen output to CRT }
    Rewrite(NormOut); { open for writing }

  If  Redirected Then  Begin
    {  In Borland/Turbo Pascal, using CRT bypasses DOS so the  }
    {  output is not redirectable. Here we reroute the output  }
    {  to the official DOS STDOUT device again, but only when  }
    {  the user wanted to redirect the output.                 }
    Assign  (Output, '');  { Put pascal output back on real STDOUT.. }
    Rewrite (Output);      { Open for writing }
  End;

  While KeyPressed Do CH := ReadKey;

  WriteLn ('ZNDEL 2.1  Exclusive Delete utility by G. Palmer and E. de Neve    Freeware');

  Get_Command_Line_Args;

  If (Not InWorkDir) Then If (Not Assume_Yes) Then SayPrott;

  Nr_Files_Found      := 0;
  Nr_Files_to_Protect := 0;
  Nr_Files_to_Delete  := 0;

  { Reading directory .. }

  FindFirst ('*.*', Archive, Search_Record);
  If (DosError = 0) Then Check_if_protected (Search_Record.Name);

  While (DosError = 0) And (Nr_Files_to_Delete < Maxdelete)
  Do Begin
    FindNext (Search_Record);
    If (DosError = 0) Then Check_if_protected (Search_Record.Name);
    If KeyPressed Then bye;       { chance to cancel }
  End;

  {   Deleting files .. }

  If (Nr_Files_to_Delete > 0 ) Then
  Begin
    If KeyPressed Then bye;       { chance to cancel }

    For I := 1 To Nr_Files_To_Delete Do
    Begin
      If KeyPressed Then bye;     { chance to cancel }
      Assign (Afile, Files_To_Delete [I] );
      Erase (Afile);
    End;

  End;

  WriteLn;
  WriteLn ('    Files found: ', Nr_Files_found);
  WriteLn ('Protected files: ', Nr_Files_to_Protect);
  WriteLn ('  Files deleted: ', Nr_Files_to_Delete);

End.

{ -------------------------------------------------------------------------}

         ZNDEL version 2.1   -  Public Domain / Freeware

     Exclusive-Delete utility ( originally 'Zip-Not-DEL' ? )

     This program deletes all the files in the current directory
     except archives, files specified on the command line, and
     files marked as system, hidden, or read-only.

     Very convenient for cleaning up after de-archiving, e.g in
     working- and download directories.


 Usage:

     ZNDEL [/Y] [filespec (filespec) ]  delete all but filespecs & archives
             └──>   assume YES on all prompting (useful in batch files)

     ZNDEL /S                           show current workdir assignments
     ZNDEL /W  [workdir (workdir) ]     assign working directories

     ZNDEL /?                           show the help text


 Examples:

     delete all but the assembler sources       ZNDEL *.asm
     to keep prog1.pas, prog2.txt etc.          ZNDEL prog?
     combined effect of above examples          ZNDEL prog? *.asm
     the same, without prompting                ZNDEL /Y prog? *.asm


 Configuration:

     You can configure ZNDEL to work automatically without
     prompting for quick cleanups in specific directories.
     Make sure to specify only simple directory names, do not
     include drive ID's or subdirectories, for example:

     ZNDEL /W  download  stuff  temp

     This makes ZNDEL recognize these directories or any of
     their subdirectories as special working directories, in
     which ZNDEL will never ask for confirmation.

     The commands  C:\DOWNLOAD\GAME> ZNDEL

              and  C:\COMMPROG\STUFF\MISC> ZNDEL

     will both work without confirmation because GAME is a
     subdirectory of DOWNLOAD, and MISC is a subdir of STUFF.


 Tech notes & details:

   The included source file ZNDEL.PAS was tested and
   compiled using Borland Pascal 7.0.

   For configuration, the .EXE file itself is modified,
   which will not work when it is compressed by an
   executable compressor like LZEXE or PKLITE.
   Configuration will work OK when ZNDEL.EXE has
   been renamed.

   Because wildcards in ZNDEL are used to specify files
   to save rather than files to delete, the DIR wildcard
   convention, which is much more flexible than the
   DEL wildcard (= internal MS-DOS) convention, is
   simulated with all its details and quirks.
   For example, in DIR style, "." and "*" both mean "*.*",
   and "progname" means "progname.*".

   All output can be suppressed or redirected, e.g. by
   redirecting to the NUL device, as in  ZNDEL /Y  > NUL

   Pascal programmers may find some of the code useful for
   their own programs, especially the redirection routines,
   the self-modification trick including a "binary file search"
   routine (which works on files of unlimited size) and the
   wildcard evaluation. Use the code any way you like.


 Legal stuff:

   There is no warranty of this software's suitability for
   any purpose, nor any acceptance of liability, express or
   implied. By using this free software, you agree to this.


 Version history:

   Version 2.1  November 1, 1994

   New in version 2.1
     - fixed bug in redirection detection
     - confirmation prompt will now bypass redirection


   Version 2.0  August 17, 1994

   New in version 2.0 :
     - recognizes 12 of the most common archive format extensions
     - full DIR-style wildcard support
     - confirmation asked before deleting
     - no confirmation needed in assigned working directories
     - realistic limits & safety checks for maximum number of files
     - switch to override prompting, useful in batch files


   Version 1.0  (Original)  Written  Sept. 21, 1991  by  G. Palmer


   Original:  Written Sept 21, 1991  by  G.Palmer


