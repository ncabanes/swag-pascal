(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0018.PAS
  Description: Xor Encryption/Decryption
  Author: JOHN FREESE
  Date: 05-25-94  08:18
*)

(* $Header:   A:/vcs/mash.pav   1.0   15 Jul 1991  7:21:38   K_McCoy  $ *)
(****************************************************************************)
 
UNIT MASH;
 
{$IFDEF DOCUMENTATION}
 
(****************************************************************************)
 *  
 *  $Log:   A:/vcs/mash.pav  $
 * 
 *    Rev 1.0   15 Jul 1991  7:21:38   K_McCoy
 *    Added encryption unit, cleaned up.
 * 
 *  
(****************************************************************************)
 
{$V-}
 
 
                  Mash - The McCoy & Associates File Mangler
 
    Purpose:


    General purpose text file encrypter.  Keeps the honest people honest.
    Does simple XOR of text characters with user settable key.  Creates
    a binary file with the extension .CRP containing the encrypted text.
    Binary files will be a little shorter than their ascii counterparts
    as there will be no CR/LF delimiters: only a length byte preceeding
    each "line" of binary characters.  There is a 255 character limit on
    the text files, but no limit on the number of lines (up to the capacity
    of the disk).
 
    Drawbacks:  This is nowhere near as secure as DES algorithm, although
    it is much faster.  This unit won't keep the CIA / KGB out of your
    financial records for long, but it might work on your ex-wife
    and her laywer.
 
    Note:  This unit uses the TPSTRING unit from Turbo Power.  You could
    easily change this to use the OPSTRING unit or write your own
    Trim [trailing blanks] function.
 
    I wrote this for an automated test program to keep unauthorized people
    from changing the test specifications out on the assembly line.
    (You wouldn't want airplanes falling on your head, would you?)
 
    Suggested improvements:

    Allow other file extensions for input and output files.
    Modify this to work with binary input files.
    Modify the Mangle routine to not reset to the beginning of the key on each
    line of text.
 
    Public Domain, but be nice and give me credit if you use it in your
    own stuff.
 
    _Use at your own risk_  If the KGB de-encrypts your Mangled bowling
    scores, tough!

    Do an IO redirect of complaints to NUL.  Questions may be sent to:
 
    Kevin McCoy - CompuServe ID# [72470,1233]
    2217 Aspenpark Ct.
    Thousand Oaks, CA 91362-1731
 
 
                                Sample Usage:
USES
    DOS,
    CRT,
    MASH;
VAR
    Strg,
    InName         : STRING;
    M              : Mangler;
BEGIN                             {main}
    ClrScr;
 
    WRITE('Enter name of .CFG file: ');
    READLN(InName);
 
    {I think this came from an old "Man from U.N.C.L.E." episode}
    M.SetSequence('OuR CaRs On IcE');

    {open the two files}
    IF NOT M.Init(InName, MASHMODE) THEN BEGIN
        WRITELN(M.MashError);
        HALT(1);
    END;
 
    {encrypt the .CFG file}
    IF NOT M.MashFile THEN BEGIN
        WRITELN(M.MashError);
        HALT(1);
    END;

    {close the files}
    M.Done;
 
    {Open just the encrypted file}
    IF NOT M.Init(InName, UNMASHMODE) THEN BEGIN
        WRITELN(M.MashError);
        HALT(1);
    END;
 
    {read and decrypt each line until EOF}
    WHILE M.Getline(Strg) DO
        WRITELN(Strg);
 
    {close the .CRP file}
    M.Done;
 
END; {of sample program}
 
 
{$ENDIF}
{ The real stuff starts here... }
 
INTERFACE

TYPE
    MMType         = (MASHMODE, UNMASHMODE, SOURMASH);
 
    Mangler        = OBJECT
                         TFile          : TEXT;
                         BFile          : FILE;
                         LastError      : WORD;
                         FileName       : STRING;
                         InitMode       : MMType;
                         FUNCTION Init(Fname : STRING; Mode : MMType) :
BOOLEAN;
                         FUNCTION Getline(VAR Line : STRING) : BOOLEAN;
                         FUNCTION MashFile : BOOLEAN;
                         FUNCTION  MashError(VAR S : STRING) : BOOLEAN;
                         PROCEDURE SetSequence(Seq : STRING);
                         PROCEDURE Done;
                     END;
 
   
(****************************************************************************)
 
IMPLEMENTATION

USES
    {.U-}
    TPSTRING
    {.U+}
    ;
 
CONST
    {Default key.  May be reset with the SetSequence method}
    Id             : STRING =
'^%12hY7eujEDZ|R9a341~~#2DBC3fn7mSDVvUY@hbFD`6093fdk79*7a-|-  Q`';
 
    {error number constants}
    INVINAM = 500;
    INVINIT = INVINAM + 1;
    CORRUPT = INVINIT + 1;
 
 
   
(****************************************************************************)
 
    FUNCTION Mangle(L : STRING) : STRING;
        { Low budget encryption / decryption of Line}
    VAR
        I              : INTEGER;
    BEGIN
        FOR I := 1 TO LENGTH(L) DO
            L[I] := CHR(ORD(L[I]) XOR NOT(ORD(Id[I MOD LENGTH(Id) + 1])));
        Mangle := L;
    END;
 
   
(****************************************************************************)
 
    FUNCTION Mangler.Init(Fname : STRING; Mode : MMType) : BOOLEAN;
        {- Gozintas:  Fname = Name (no extension) of the input/output files}
        {             Mode  = MASHMODE / UNMASHMODE (encrypt / decrypt)    }
        {  Gozoutas:  TRUE if everything was OK, FALSE if not              }
    VAR
        InName,
        OutName        : STRING;
    BEGIN
        InitMode := Mode;
        FileName := Fname;
        Init := TRUE;
        IF LENGTH(Trim(Fname)) = 0 THEN BEGIN
            LastError := INVINAM;
            Init := FALSE;
            EXIT;
        END;
        InName := Fname + '.CFG';
        OutName := Fname + '.CRP';
 
        { Open the appropriate file(s) }
 
        IF Mode = MASHMODE THEN BEGIN
            ASSIGN(TFile, InName); {open data files}
            {$I-}
            RESET(TFile);
            {$I+}
            LastError := IORESULT;
            IF LastError <> 0 THEN BEGIN
                {crash if file error}
                Init := FALSE;
                EXIT;
            END;
            ASSIGN(BFile, OutName);
            {$I-}
            REWRITE(BFile, 1);
            {$I+}
            LastError := IORESULT;
            IF LastError <> 0 THEN BEGIN
                {crash if file error}
                Init := FALSE;
                EXIT;
            END;
            Init := TRUE;
        END
        ELSE BEGIN
            ASSIGN(BFile, OutName); {open data files}
            {$I-}
            RESET(BFile, 1);
            {$I+}
            LastError := IORESULT;
            IF LastError <> 0 THEN BEGIN
                {crash if file error}
                Init := FALSE;
                EXIT;
            END;
        END;
    END;
 
   
(****************************************************************************)
 
    FUNCTION Mangler.Getline(VAR Line : STRING) : BOOLEAN;
        {- Read a single line of binary gunk from the MSH file and decrypt it}
        {  Gozintas = Nothing                                                }
        {  Gozoutas:  Line = Decrypted ASCII string                          }
        {             Returns TRUE if everything was OK, FALSE if not        }
    VAR
        Result         : WORD;
    BEGIN
 
        Line := '';
        Getline := FALSE;
 
        IF InitMode <> UNMASHMODE THEN BEGIN
            LastError := INVINIT;
            EXIT;
        END;
 
        BLOCKREAD(BFile, Line[0], 1, Result);
        IF Result <> 1 THEN BEGIN
            LastError := CORRUPT;
            EXIT;
        END;
 
        BLOCKREAD(BFile, Line[1], ORD(Line[0]), Result);
        IF Result = ORD(Line[0]) THEN BEGIN
            Line := Mangle(Line);
            Getline := TRUE;
        END
    END;
 
   
(****************************************************************************)
 
    FUNCTION WTOA(N : WORD; W : INTEGER) : STRING;
    VAR
        Strg           : STRING;
    BEGIN
        STR(N:W, Strg);
        WTOA := Strg;
    END;
 
   
(******************************************************************************)
 
    FUNCTION Mangler.MashError(VAR S : STRING) : BOOLEAN;
        {- return the last error string }
    BEGIN
        {most of these messages are unlikely to occur.  You may remove most }
        {of them to save memory }

        MashError := TRUE;
        CASE LastError OF
            000 : BEGIN {no error}
                      S := '';
                      MashError := FALSE; 
                  END;
            002 : S := 'File not found';
            003 : S := 'Path not found';
            004 : S := 'Too many open files';
            005 : S := 'File access denied';
            006 : S := 'Invalid file handle';
            012 : S := 'Invalid file access code';
            015 : S := 'Invalid drive number';
            016 : S := 'Cannot remove current directory';
            017 : S := 'Cannot rename across drives';
            100 : S := 'Disk read error';
            101 : S := 'Disk write error';
            102 : S := 'File not assigned';
            103 : S := 'File not open';
            104 : S := 'File not open for input';
            105 : S := 'File not open for output';
            150 : S := 'Disk is write-protected';
            151 : S := 'Unknown unit';
            152 : S := 'Drive not ready';
            154 : S := 'CRC error in data';
            156 : S := 'Disk seek error';
            157 : S := 'Unknown media type';
            158 : S := 'Sector not found';
            160 : S := 'Device write fault';
            161 : S := 'Device read fault';
            162 : S := 'Hardware failure';
            203 : S := 'Insufficient memory';
            INVINAM :S := 'Invalid filename';
            INVINIT :S := 'Invalid Mash unit init';
            CORRUPT : S := 'Invalid or corrupt MSH file';
            ELSE
                S := 'Turbo runtime error ' + WTOA(LastError, 4);
        END;
    END;
 
   
(****************************************************************************)
 
    PROCEDURE Mangler.SetSequence(Seq : STRING);
        {- Set the encryption sequence (key) to be something other than the
default   }
        {  Gozintas: A string (the longer the better) containing any characters
in    }
        {  the range of (0-255)  Try to avoid using strings that will be
duplicated   }
        {  in the text to be encrypted.  A match between the key and the text
results }
        {  in strings of $FF characters in the MSH file that make the key
easier to   }
        {  crack by determined hackers                                         
      }
 
    BEGIN
        Id := Seq;
    END;

   
(****************************************************************************)
 
    FUNCTION Mangler.MashFile : BOOLEAN;
        {- File conversion method.  Encrypts text file specified in Init method
call }
        {  and places encrypted binary junk into the .MSH file                 
     }
        {  Returns TRUE if success, FALSE if not                               
     }
    VAR
        Strg           : STRING;
        Result         : WORD;
    BEGIN
        WHILE (NOT EOF(TFile)) DO BEGIN
            READLN(TFile, Strg);
            WRITELN(Strg);
            Strg := Mangle(Strg);
            BLOCKWRITE(BFile, Strg, ORD(Strg[0]) + 1, Result);
            IF Result <> LENGTH(Strg) + 1 THEN BEGIN
                WRITELN('Problem writing ' + FileName + '.MSH');
                HALT(1);
            END;
        END;                      {while}
 
    END;
 
   
(****************************************************************************)
 
    PROCEDURE Mangler.Done;
        {- Close up shop and boogie method}
    BEGIN
        CLOSE(BFile);
        IF InitMode = MASHMODE THEN
            CLOSE(TFile);
 
        InitMode := SOURMASH;
    END;
 
   
(****************************************************************************)
    {unit initialization}
END.                              {of unit mash}
(****************************************************************************)
(****************************************************************************)

