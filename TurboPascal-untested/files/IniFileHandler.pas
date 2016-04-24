(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0051.PAS
  Description: INI File Handler
  Author: DIRK PAESSLER
  Date: 02-18-94  06:59
*)


{**********************************************************************
 ** UNIT SETUP2                                                      **
 ** Handles an *.INI-File similiar to Windows                        **
 **********************************************************************
 ** The Setup-variables all have a unique name an can be retrieved   **
 ** by using the name. A default-value must be given when retrieving **
 ** a value, so that the returned value is always valid!             **
 ** There are different functions for different data types           **
 ** A BAK-file is created when touching the INI-file                 **
 ** For added speed a copy of the INI file is held in variable SETUP **
 **********************************************************************
 ** This is untested stuff, it runs flawlessly here in my programs   **
 ** (c) 1994 by Dirk Paessler, given to the public domain            **
 ** if you change anything please note; leave my name in here!!      **
 ** if you have questions or suggestions, please contact me          **
┌───────────────────┬─────────────┬───────────────────────────────────┐
│ Dirk Paessler     │             │ E-Mail:       FIDO 2:2490/1145.15 │
│ Laerchenweg 8     │Fax          │ CIS 100114,42      2:2490/2091.5  │
│ D-91058 Erlangen  │+499131601169│ internet 100114.42@compuserve.com │
└───────────────────┴─────────────┴───────────────────────────────────┘

 usage:

 USES setup2;
 VAR MyData:string;
 BEGIN
   Mydata:=GetStrProfile('MyData','nothing yet');
   WriteLn(mydata);
   PutStrProfile('MyData','New stuff');
   Mydata:=GetStrProfile('MyData','nothing yet');
   WriteLn(mydata);
 END.


 }

UNIT Setup2;
INTERFACE
  
FUNCTION GetIntProfile(name:STRING; default:INTEGER):INTEGER;
PROCEDURE PutRealProfile(name:STRING; wert:REAL);
FUNCTION GetRealProfile(name:STRING; default:REAL):REAL;
PROCEDURE PutStrProfile(name,wert:STRING);
PROCEDURE PutBoolProfile(name:STRING; wert:BOOLEAN);
FUNCTION GetStrProfile(name,default:STRING):STRING;
FUNCTION GetNumProfile(name:STRING):REAL;
FUNCTION GetBoolProfile(name:STRING; default:BOOLEAN):BOOLEAN;
  
TYPE PSetup = ^Setuptype;
SetupType = ARRAY [1 .. 70] OF STRING[140];
  
VAR   Setup          : PSetup;
IMPLEMENTATION
  
VAR     q:INTEGER;
CONST anzsetups:INTEGER=0;
  newsetup:BOOLEAN=TRUE;
  
  
FUNCTION ReadALine(VAR Fil:TEXT):STRING;
  VAR a:CHAR; b:STRING;
BEGIN
  b:='';
  a:=#13;
  
  WHILE (a<>#10) AND NOT (EOF(FIL)) DO
  BEGIN
    IF a<>#13 THEN b:=b+a;
    Read(fil,a);
  END;
  ReadAline:=b;
END;
  
PROCEDURE Zerleg(a:STRING; VAR b,c:STRING);
  VAR i:INTEGER;
BEGIN
  i:=0;
  REPEAT
    i:=i+1;
  UNTIL (a[i]='=') OR (i>length(a));

  IF i>length(a) THEN i:=length(a);
  b:=copy(a,1,i-1);
  c:=copy(a,i+1,length(a)-i);
END;

FUNCTION FileExist(Fname:string):BOOLEAN;
VAR f:file;
BEGIN
{$I-}
  Assign(f,fname);
  Reset(f);
  Close(f);
{$I+}
  FileExist := (IOResult=0) and (fname<>'');
END;


PROCEDURE ReadSetup;
  VAR MyFil:TEXT;a,myname,wert:STRING;
BEGIN
  IF NOT Fileexist('astro5.ini') THEN
  BEGIN
    Assign(MyFil,'astro5.ini');
    Rewrite(MyFil);
    WriteLn(MyFil,';  ***                    PSCS-Astro V5 INI                       ***');
    Close(MyFil);
  END;
  IF Setup=NIL THEN
  BEGIN
    New(setup);
  END;
  Assign(MyFil,'astro5.ini');
  Reset(MyFil);
  q:=1;
  REPEAT
    REPEAT
      a:=ReadALine(MyFil);
    UNTIL (a[1]<>';') OR (eof(myfil));
    setup^[q]:=a;
    q:=q+1;
  UNTIL (EOF(MyFil));
  anzsetups:=q-1;
  Close(MyFil);
  NewSetup:=FALSE;
END;
  
  
FUNCTION GetStrProfile(name,default:STRING):STRING;
  VAR MyFil:TEXT;a,myname,wert:STRING;
BEGIN
  GetStrProfile:=default;
  
  IF Fileexist('astro5.ini') THEN
  BEGIN
    IF Setup=NIL THEN
    BEGIN
      New(setup);
    END;
    IF NewSetup THEN ReadSetup;
    q:=1;
    REPEAT
      Zerleg(setup^[q],MyName,wert);
      q:=q+1;
    UNTIL (name=MyName) OR (q>anzsetups);
    IF name=MyName THEN GetStrProfile:=wert;
  END;
END;
  
FUNCTION GetBoolProfile(name:STRING; default:BOOLEAN):BOOLEAN;
  VAR hlpstrg:STRING;
BEGIN
  hlpstrg:=GetStrProfile(name,'t');
  GetBoolProfile := default;
  IF hlpstrg='TRUE' THEN GetBoolProfile := TRUE;
  IF hlpstrg='FALSE' THEN GetBoolProfile := FALSE;
END;
  
PROCEDURE PutBoolProfile(name:STRING; wert:BOOLEAN);
  VAR hlpstrg:STRING;
BEGIN
  hlpstrg:='FALSE';
  IF wert THEN hlpstrg:='TRUE';
  PutStrProfile(name,hlpstrg);
END;
  
FUNCTION GetIntProfile(name:STRING; default:INTEGER):INTEGER;
BEGIN
  GetIntProfile:=Round(GetRealProfile(name,default*1.0));
END;
  
FUNCTION GetRealProfile(name:STRING; default:REAL):REAL;
  VAR hlpstrg:STRING; i:INTEGER; a:REAL;
BEGIN
  str(default,hlpstrg);
  hlpstrg:=GetStrProfile(name,hlpstrg);
  val(hlpstrg,a,i);
  GetRealProfile:=a;
END;
  
PROCEDURE PutRealProfile(name:STRING; wert:REAL);
  VAR hlpstrg:STRING;
BEGIN
  Str(wert:1:10,hlpstrg);
  PutStrProfile(name,hlpstrg);
END;
  
  
PROCEDURE PutStrProfile(name,wert:STRING);
  VAR MyFil,my2fil,my3fil:TEXT;a,myname,altwert,Mywert:STRING; WasIt:BOOLEAN;
BEGIN
  altwert:=getStrProfile(name,'#*äöü');
  IF altwert=wert THEN exit;
  
  IF NOT Fileexist('astro5.ini') THEN
  BEGIN
    Assign(MyFil,'astro5.ini');
    Rewrite(MyFil);
    WriteLn(MyFil,';  ***                    PSCS-Astro V5 INI                       ***');
    Close(MyFil);
  END;
  Assign(MyFil,'astro5ini.tmp');
  Rewrite(MyFil);
  Assign(My2Fil,'astro5.ini');
  ReSet(My2Fil);
  WasIt:=FALSE;
  REPEAT
    a:=ReadALine(My2fil);
    Zerleg(a,myname,mywert);
    IF myname=name THEN BEGIN
      WriteLn(myfil,name,'=',wert);
      WasIt:=TRUE;
    END
    ELSE WriteLn(myfil,a)
  UNTIL EOF(my2fil);
  IF NOT WasIt THEN WriteLn(myfil,name,'=',wert);
  Close(MyFil);
  Close(My2Fil);
  IF Fileexist('astro5.bak') THEN
  BEGIN
    Assign (my3fil,'astro5.bak');
    erase(my3fil);
  END;
  Rename(My2Fil,'astro5.bak');
  Rename(MyFil,'astro5.ini');
  ReadSetup;
END;
  
FUNCTION GetNumProfile(name:STRING):REAL;
BEGIN
END;
  
BEGIN
  
  
END.
  
{be sure to insert the following line into your exit-code!!!}

IF setup<>NIL THEN Dispose(setup);

