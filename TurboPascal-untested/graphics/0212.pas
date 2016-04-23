{
=============================================================

BLARF! A ** FAST ** GIF EXTRACT UTILITY BY SCOTT "CLEVER BOY"
TUNSTALL (C) 1995.

-------------------------------------------------------------

What a lot of time I took to remove the swearing!! ;)


This util will extract all of the files from the list in THING.DEF
to a GIF which can then be edited.

Make sure you've got PLENTY of hard disk space, preferably
8 Mb or so, because there are obviously a lot of .GIF files that
are going to be extracted. (Sorry, but I can't make them PCX)

HOW IT WORKS
------------
First of all you gotta have :

(a) A file listing ALL of the graphic entries you want to rip out;
    I've already made such a list for ya (THING.DEF);
    Make a backup of it and load the backup into EDIT (Or somethin)
    then place an asterisk before the entries ya don't want to make
    into a GIF file. (Only those in between the *START and *END)
    Make sure that no "white space" (tabs, spaces etc) between text
    lines are left tho' (Carriage returns are OK between entries) !

    At the end of Thing.DEF note that there is *ENDFILE, this tells
    this util that there is no more GIFS to extract. You MUST have
    this here or you're shit outa luck!

(B) DMGRAPH handy! Yes, all this program does is repeatedly SHELL
    to DMGRAPH! It's v. handy mind you.

(C) A GIF directory !


Now:
If you want to INSERT the graphic files listed in your own THING.DEF
file, ya type :

BLARF -i <Name of text file [THING.DEF]> <Directory where gifs are>



So let's say you had a file called MONSTERS.TXT in C:\POONTANG dir,
and that contained all of the names of the shit you wanted to rip out,
and the directory where you wanted to read your gifs from is
C:\GRAPHICS\GIF.

Ya type: BLARF -i C:\POONTANG\MONSTERS.TXT C:\GRAPHICS\GIF

Easy eh? (Mind and make a backup of your DOOM.WAD file !)


On the other hand, if you wanted to EXTRACT some graphics
you use:

BLARF -e <Name of text file listing monster pics to copy> <Directory where
gifs go to>


Piece of piss eh?


Example:


*START
TROOPA1
...
*SARGA1
...
PAINA1
*END
ENDFILE


Means that all objects from TROOPA1 to PAINA1 shall be extracted, 
with the exception of SARGA1.
ENDFILE means "Stop scanning"
                   


Oh yeah, if you ever use this program I'd like some kind of feedback
pleeze.   (Bear with my slang, I'm trying to make an impression
that I can kick ass  :^)  )
}


Program Blarf;

Uses Dos, Crt;


{$M 4000,0,0}

Var TheTextFile: text;
    FirstParam: String[2];
    SecondParam: PathStr;
    GifDirectoryName: PathStr;
    Entry: string[8];
    Extract: boolean;

Procedure ShellDMGraph(Parameters:string);
Begin
     SwapVectors;
     Exec('DMGRAPH.EXE',Parameters);
     SwapVectors;
End;




Procedure OpenTheTextFile;
Begin
     Assign(TheTextFile,SecondParam);
     {$I-}
     Reset(TheTextFile);
     {$I+}
     If IoResult <> 0 Then
        Begin
        Writeln;
        Writeln('Could not find the text file required !');
        Halt(0);
     End;
End;




Function GetNextEntry: String;
Var CharacterName: string;
Begin
     If Not Eof(TheTextFile) Then
        Begin
        ReadLn(TheTextFile,CharacterName);
        While CharacterName[Length(CharacterName)]=' ' do
              CharacterName:=Copy(CharActerName,1,Length(CharacterName)-1);
        End
     Else
         CharacterName:='*ENDFILE';

     GetNextEntry:=CharacterName;
End;




Procedure CloseTheTextFile;
Begin
     Close(TheTextFile);
     Writeln;
     Writeln('Operation complete.');
End;




Procedure InsertGifs;
Begin
     OpenTheTextFile;

     Entry:=GetNextEntry;

     While Entry <> '*ENDFILE' do
     Begin
          If Entry[1] <> '*' Then
             Begin
             Writeln('Inserting ',Entry,'.GIF ..');
             ShellDMGraph(Entry + ' ' + '-i ' + GIFDirectoryName+ Entry+'.GIF');
          End;
          Entry:=GetNextEntry;
     End;

     CloseTheTextFile;
End;




Procedure ExtractGifs;
Begin
     OpenTheTextFile;
     Extract:=False;

     Entry := GetNextEntry;

     While Entry <> '*ENDFILE' do
     Begin
          If (Entry[1] <> '*') And (Extract = True) Then
             Begin
             Writeln('Extracting ',Entry,'to ',GIFDirectoryName+Entry+'.GIF ..');
             ShellDMGraph(Entry + ' ' + '-e ' + GIFDirectoryName+ Entry+'.GIF');
             End
          Else
              If Entry='*START' Then
                 Extract:=True
              Else
                  If Entry = '*END' Then
                     Extract:=False;

          Entry:=GetNextEntry;
     End;

     CloseTheTextFile;
End;




Procedure FuckedUp;
Begin
     Writeln;
     Writeln('BLARF v1.1 Multiple GIF extractor/insertor for DOOM.');
     Writeln('(C) Scott Tunstall 1995. So don''t mess with it!');
     Writeln;
     Writeln('Usage :');
     Writeln;
     Writeln('BLARF < -i/-e > <Text File> <Gif Directory>');
     Writeln;
     Writeln('-i will INSERT the GIFS into DOOM.WAD .');
     Writeln('-e will EXTRACT the GIFS from DOOM.WAD .');
     Writeln;
     Writeln('Text file is standard EDIT created list of the graphics you');
     Writeln('want extracted from DOOM.WAD for example SKY1 or TROOPA1 etc.');
     Writeln('You can create the text file needed by DMGRAPH. (Thank f**k)');
     Writeln('To make THING.DEF you type:');
     Writeln;
     Writeln('DMGRAPH >THING.DEF -c   (Make sure DMGRAPH is in yer DOOM dir!)');
     Writeln;
     Writeln('Mind and delete all of the ExMx stuff, SSectors, Nodes etc ''cos');
     Writeln('they''ll screw up this program.');
     Writeln;
     Writeln('GIF directory is the source/destination of/for yer GIFS.');
     Writeln;
End;





Procedure YeDontSweatMuch;
Begin
     Writeln;
     Writeln('Invalid parameter passed, -i or -e expected');
     Writeln('Give me any more gyp and I''ll format yer hard disk !');
     Writeln;
End;



Begin
     If ParamCount<>3 Then FuckedUp;
     FirstParam:=ParamStr(1);       { switch }
     SecondParam:=ParamStr(2);      { name of text file }
     GIFDirectoryName:=ParamStr(3)+'\';       { name of GIF dir. }

     If (FirstParam = '-i') or (FirstParam = '-I') Then
        InsertGifs
     Else
         If (FirstParam = '-e') or (FirstParam ='-E') Then
            ExtractGifs
         Else
             YeDontSweatMuch;
End.
