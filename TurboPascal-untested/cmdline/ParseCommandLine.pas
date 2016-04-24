(*
  Category: SWAG Title: COMMAND LINE ROUTINES
  Original name: 0005.PAS
  Description: Parse Command Line
  Author: KENNETH W. FOX
  Date: 05-28-93  13:34
*)

{*************************************************************************)
            Program name: Command parse sub routines
                  Author: Kenneth W. Fox
                          1449 Maple Rd.
                          KintnersVille Pa. 18930
                          USA
           Date Started : 5 AUG 1992
           Date finished: 10 jan 1993
           date last Rev: 20 JAn 1993
*************************************************************************

Commandline args:
-----------------
NONE

Description of Program:
-----------------------
set of  Procedures to handle all commandline Parameters With or without regard
to Case -- selected by the Boolean Var Nocase -- if True then  everrything
is converted to uppercase prior to testing

all arguments returned from switches are left in whatever Case they were
entered on the commandline unless ConvertArgsToUpper is set to True.

Includes following Procedures:

Procedure NAME          : PURPOSE
------------------------:-------------------------------------------------
 FnameCheck             : to validate Program name
                          stops people from renanming the Program  if you don't
                          want them to -- if you don't care then don't call
                          this routine.

 DispCmdline            : use to display commandline parameters when debugging

 ConvertArgtoNumber     : converts specified arg from a String to a numeric
                          value.

 CheckHelp              : routine to check to see if the Strings designated
                          as commandline help Strings are present or not.
                          the use of this routine requires the File
                          Helpuser.pas. Additionally this routine checks to
                          see if the 'info' switch was present -- conveniaet
                          way to display registration info in share ware..


 CmdParse               : main routine to parse command line-- this Procedure
                          is called With Various arguments to alter the content
                          of the CmdArray data structure.



Additonal mods to be made:
---------------------------
1) add subroutine in cmdline parser to capture delimited Strings (such as
those between quotes)

2) add subroutine to check if any items one the commandline besides the valid
switches and such were present --

to be used For spotting invalid commandline parameters return value should
be Boolean invalid and the paramString(#)...

NOTES: may run into trouble writing the routine when the delimited Strings
Function  is added.. possible errors include capturing elements of the
delimited String as invalid args -- will also check For no closing delimiter..

3) develop a version of the cmd line parser which Uses a linked list instead
of a set of Arrays to save the values in -- will save some memory..

4) convert the whole Procedure to an itelligent macro which merely requires
a list of the command args (doesn't use a fixed Array size -- will
dynamically allocate space based on number of arguments specified in the
arg pickup header File. regrettably , some form of header File will need
to be used in order to specify what will be searched For --

5) a possible solution is a way to make a mini compiler macro which will
read in the switches to be processed from a File along With definitions

eventually convert the whole thing into a Unit // overlay .


Rev History:
------------

notes on errors -- if  the switch Strings are not Varying their length
 when Const SwitchLength is changed, then the $I CmdParse.H File is not
in the correct path

 remember that the commandArray initialization Procedure is in the
CmdParse.h File and the appropriate adjustments to the qty and values of
the switches need to be made there .. if you are experiencing problems
 With the capture of switches, ensure that you ahe init'd you Array values
correctly

 added Boolean present field For argdsw Array

9/5/92 -- moved the call to initCmdArray from the calling routine into the
          initialization section of cmdparse.pas -- because i forgot to add
          it to chkLabel.pas and was going nuts tring to find the error.
          live and learn.

9/5/92 -- added the DispCmdline Procedure as a result of the above session
          of psychosis..

9/6/92 -- re organized cmdparse.pas into more subroutines -- made it easier
          to follow what was going on.. also added removeable code to
          implement a delimited String parser.. this routine will need to
          access the commandline directly instead of using the ParamStr()
(99 min left), (H)elp, More?           Function of turbo.

9/6/92 -- added the ConvertArgtoNumber  routine
          **** NOTE ***** "HelpUser" is a Procedure I add to all Programs
          which use command line args or otherwise -- I normally use an
          $I IncludeFile to implement it.. the Include Staement MUST
          occur BEFORE the include StaTement For CmdParse.pas File..  or
          you can delete the reference to the File from the Program

9/6/92 -- added the standard help codes to the switches Array in cmdParse.H
          ( /? , /h , /H , help , HELP ).

9/6/92 -- added FnameCheck to this File-- FnameCheck requires a Constant or
          String called "ProgName" containing the name of the MAIN Program
          it checks the ParamStr(0) to verify that the Filename of the
          Program has not been renamed -- useful For copyright purposes,
          annoying to users.. use at own peril

9/6/92 -- updated header File to list Procedures avail in cmdparse.pas

1/8/93 -- added the info switch to and DisplayInfo routines to show
          registration / info request address.


end desc.
}

{HEADER File For cmdparse.pas -- include in Calling File   }

{PROGNAME.pas}  {<<<<----- Program using this header File   }
{ 20 Jan 1993} {<<<<----- date this File last changed      }
{ Ken Fox    }  {<<<<----- Person who last updated this File}

(*
Uses Dos,Crt;

Const
  VersionNum = 'V1.0 BETA';
  ProgNameStr = 'NEWPROJ.EXE';
  ProgNameShortStr = 'NP.EXE';
  copyRightStr = ProgNameStr+' ' + VersionNum +
                ', Copyright 1992 - 1993, Ken Fox. All Rights Reserved.';

  DefaultFileName = 'NEWPROJ.DAT';

*)

{--------------------------------------------------------------------------}
{                          procs Available in CmdParse.H                   }
{ Procedure   initCmdArray(Var CmdArray : CommandLineArrayType);           }
{   this proc is included in ths File becuase the args to check For are    }
{ part of the calling routine, not the parser itself. note that the excess }
{ switches are commented out and will there For not compile but it will    }
{ make it easier to add stuff in the future should you so desire           }
{--------------------------------------------------------------------------}
{                          procs Available in CmdParse.Pas                 }
{ additional info on the following procs may be found in the cmdparse.Pas  }
{ File in the ....\tp\include directory..                                  }
{                                                                          }
{ Procedure DispCmdline;                                                   }
{                                                                          }
{ Procedure CmdParse(Var CmdArray : CommandLineArrayType;                  }
{                            NoCase,                                       }
{                            ConvertArgsToUpper   : Boolean );             }
{                                                                          }
{ Procedure ConvertArgtoNumber(ArgNum : Integer;                           }
{                             Var  CmdArray : CommandLineArrayType;        }
{                             Var  ResultNumber: Word);                    }
{                                                                          }
{ Procedure FnameCheck(progname , progname2 :pathStr;                      }
{                      errorlevel : Byte);                                 }
{                                                                          }
{ Procedure CheckHelp;                                                     }
{                                                                          }
{--------------------------------------------------------------------------}

Const
SwitchLength = 4;   {   maxlegth of a switch to be tested for}
ArgLength = 11;     {   max length of an argument from the commandline}
DelimLength = 1;     {   maxlength of delimiter if used}
SwitchNum = 6;      {   the number of switches and hence the size of the Array}
                    {      of switches  without arguments                  }
ArgdSwitchNum = 2;  {   the number of switches and hence the size of the Array}
                    {      of switches  With arguments                 }
DelimNum = 1;       {   number of args With delimited Strings          }


Type
SwitchType = String[Switchlength];
ArgType = String[ArgLength];
DelimType = String[DelimLength];

SwitchesType = Record
         Switch : Array[1..SwitchNum] of SwitchType;
         Present : Array[1..switchNum] of Boolean
         end;

SwitchWithArgType = Record
              Switch  : Array[1..ArgdSwitchNum] Of SwitchType;
              Arg     : Array[1..ArgdSwitchNum] Of ArgType;
              Present : Array[1..ArgdSwitchNum] of Boolean
              end;

SwitchedArgWithEmbeddedSpacesType = Record
              Switch     : Array[1..DelimNum] Of SwitchType;
              StartDelim : Array[1..DelimNum] of DelimType;
              Arg        : Array[1..DelimNum] Of ArgType;
              endDelim   : Array[1..DelimNum] of DelimType;
              Present    : Array[1..DelimNum] of Boolean
              end;


CommandLineArrayType = Record
           Switches : SwitchesType;
           ArgDSw   : SwitchWithArgType;
           {    DelimSw  : SwitchedArgWithEmbeddedSpacesType; }
           NoParams : Boolean           {True if nothing on commandline}
           end;

Var
NoCase,
ConvertArgsToUpper
                  : Boolean;

CmdArray                : CommandLineArrayType;

Procedure   initCmdArray(Var CmdArray : CommandLineArrayType);

begin
   {DEFAULT VALUES SET}
   NoCase := True;
   ConvertArgsToUpper := True;

with CmdArray do
   begin
   Switches.Switch[1] := '/?' ;     {default help String}
   Switches.Switch[2] := '/h' ;     {default help String}
   Switches.Switch[3] := '/H' ;     {default help String}
   Switches.Switch[4] := 'HELP' ;   {default help String}
   Switches.Switch[5] := 'help' ;   {default help String}
   Switches.Switch[6] := 'INFO'     {show author contact Info}

{   Switches.Switch[6] := '  ' ;}   {NOT USED}
{   Switches.Switch[7] := '  ' ;}   {NOT USED}
{   Switches.Switch[8] := '  ' ;}   {NOT USED}
{   Switches.Switch[9] := '  ' ;}   {NOT USED}
{   Switches.Switch[10] := '  ' ;}  {NOT USED}
{   Switches.Switch[11] := '  ' ;}  {NOT USED}
{   Switches.Switch[12] := '  ' ;}  {NOT USED}

{  ArgDSw.Switch[1] := '' ;}       {not used}
{  ArgDSw.Switch[2] := '' ;}       {not used}
{  ArgDSw.Switch[3] := '' ;}       {NOT USED}
{  ArgDSw.Switch[4] := '' ;}       {NOT USED}
{  ArgDSw.Switch[5] := '' ;}       {NOT USED}
{  ArgDSw.Switch[6] := '' ;}       {NOT USED}
{  ArgDSw.Switch[7] := '' ;}       {NOT USED}
{  ArgDSw.Switch[8] := '' ;}       {NOT USED}
{  ArgDSw.Switch[9] := '' ;}       {NOT USED}
{  ArgDSw.Switch[10] := '' ;}      {NOT USED}
{  ArgDSw.Switch[11] := '' ;}      {NOT USED}
{  ArgDSw.Switch[12] := '' ;}      {NOT USED}
{  ArgDSw.Switch[13] := '' ;}      {NOT USED}
(*
With DelimSw Do
{     Switch[1]     := '' ;     }  {NOT USED}
{     StartDelim[1] := '' ;     }  {NOT USED}
{     endDelim[1]   := '' ;     }  {NOT USED}
{     Switch[2] := '' ;         }  {NOT USED}
{     StartDelim[2] := '' ;     }  {NOT USED}
{     endDelim[2]   := '' ;     }  {NOT USED}

{     Switch[3] := '' ;         }  {NOT USED}
{     StartDelim[3] := '' ;     }  {NOT USED}
{     endDelim[3]   := '' ;     }  {NOT USED}

{     Switch[4] := '' ;         }  {NOT USED}
{     StartDelim[4] := '' ;     }  {NOT USED}
{     endDelim[4]   := '' ;     }  {NOT USED}

{     Switch[5] := '' ;         }  {NOT USED}
{     StartDelim[5] := '' ;     }  {NOT USED}
{     endDelim[5]   := '' ;     }  {NOT USED}

{     Switch[6] := '' ;         }  {NOT USED}
{     StartDelim[6] := '' ;     }  {NOT USED}
{     endDelim[6]   := '' ;     }  {NOT USED}

{     Switch[7] := '' ;         }  {NOT USED}
{     StartDelim[7] := '' ;     }  {NOT USED}
{     endDelim[7]   := '' ;     }  {NOT USED}

{     Switch[8] := '' ;         }  {NOT USED}
{     StartDelim[8] := '' ;     }  {NOT USED}
{     endDelim[8]   := '' ;     }  {NOT USED}

{     Switch[9] := '' ;         }  {NOT USED}
{     StartDelim[9] := '' ;     }  {NOT USED}
{     endDelim[9]   := '' ;     }  {NOT USED}

{     Switch[10] := '' ;        }  {NOT USED}
{     StartDelim[10] := '' ;    }  {NOT USED}
{     endDelim[10]   := '' ;    }  {NOT USED}

{     Switch[11] := '' ;        }  {NOT USED}
{     StartDelim[11] := '' ;    }  {NOT USED}
{     endDelim[11]   := '' ;    }  {NOT USED}
(99 min left), (H)elp, More? 
{     Switch[12] := '' ;        }  {NOT USED}
{     StartDelim[12] := '' ;    }  {NOT USED}
{     endDelim[12]   := '' ;    }  {NOT USED}

{     Switch[13] := '' ;        }  {NOT USED}
{     StartDelim[13] := '' ;    }  {NOT USED}
{     endDelim[13]   := '' ;    }  {NOT USED}

{     Switch[14] := '' ;        }  {NOT USED}
{     StartDelim[14] := '' ;    }  {NOT USED}
{     endDelim[14]   := '' ;    }  {NOT USED}
end {with DelimSw }
*)
end; {WITH CmdArray}

end;

Procedure CmdParse(Var CmdArray : CommandLineArrayType;
                             NoCase,
                             ConvertArgsToUpper   : Boolean );

{ Procedure to handle all commandline Parameters With or without regard }
{to Case -- selected by the Boolean Var Nocase -- if True then  everrything}
{is converted to uppercase prior to testing}

{all arguments returned from switches are left in whatever Case they were }
{entered on the commandline unless ConvertArgsToUpper is set to True.}

Const
   Blank = ' ';

Var
   counter                 : Integer;
   Blanks                  : ArgType;

{+++++++++++++++++++++++  Private Procedures to CmdParse Main  +++++++++++++}
Procedure ConvertArgsToUpperCase(Var CmdArray:CommandLineArrayType);
Var
  Counter,
  Counter2   : Integer;
begin   {--------->>>> ConvertArgsToUpperCase <<<<------------}

  For Counter := 1 to ArgDSwitchNum Do
      For Counter2 := 1 to Length(CmdArray.ArgDSw.Arg[counter]) DO
          CmdArray.ArgDSw.Arg[counter,Counter2] :=
                UPCASE(CmdArray.ArgDSw.Arg[counter,Counter2] );

end;    {--------->>>> ConvertArgsToUpperCase <<<<------------}

{----------------------------------------------------------------------}
Procedure ConvertSwitchesToUpperCase(Var CmdArray:CommandLineArrayType);
Var
  Counter,
  Counter2   : Integer;

begin  {--------->>>> ConvertSwitchesToUpperCase  <<<<------------}
   For Counter := 1 to SwitchNum Do
      begin
      For Counter2 := 1 to Length(CmdArray.Switches.Switch[counter]) DO
          CmdArray.Switches.Switch[counter,Counter2] :=
             UPCASE(CmdArray.Switches.Switch[counter,Counter2]);
      end;
   For Counter := 1 to ArgDSwitchNum Do
      For Counter2 := 1 to Length(CmdArray.ArgDSw.Switch[counter]) DO
          CmdArray.ArgDSw.Switch[counter,Counter2] :=
                UPCASE(CmdArray.ArgDSw.Switch[counter,Counter2] );

end;  {--------->>>> ConvertSwitchesToUpperCase  <<<<------------}

{----------------------------------------------------------------------}

Procedure InitializeArrays(Var CmdArray:CommandLineArrayType;
                           Var Nocase : Boolean  );
Var
   Counter
          : Integer;

begin     {--------->>>> InitializeArrays  <<<<------------}

  cmdArray.NoParams := False;
  For Counter := 1 to SwitchNum Do
    CmdArray.Switches.present[counter] := False;
  For Counter := 1 to ArgDSwitchNum Do
    begin
       CmdArray.ArgDSw.present[counter] := False;
       CmdArray.ArgDSw.Arg[counter] := Blanks;
    end;
  if NoCase then                           {convert all Switches in CmdArray}
     ConvertSwitchesToUpperCase(CmdArray); {to uppercaseif nocase is set to }
                                           {True}
end;       {--------->>>> InitializeArrays  <<<<------------}
{----------------------------------------------------------------------}
Procedure ParseNow(Var CmdArray:CommandLineArrayType;
                           Var Nocase : Boolean  );
Var
Counter,Counter2,
Start,
SwitLen,CurrentArgLen   : Integer;
Blanks                  : ArgType;
TestStr                 : SwitchType;
WorkStr                 : String;

Label
   Next_Parameter;

begin   {--------->>>> ParseNow <<<<------------}
  {check For switches without args first}

  For counter := 1 to ParamCount Do
    begin  {number of Parameters Loop}
       TestStr:= ParamStr(counter);

       if Nocase Then    { covert paramStr(counter) to upper Case if NoCase}
          begin          { is set to True}
            WorkStr := TestStr;
            For Counter2 := 1 to SwitchLength DO
                TestStr[counter2]  := UPCASE((WorkStr[counter2]));
          end;

      For Counter2 := 1 to SwitchNum Do
           begin  { Switches without arguments loop }
              SwitLen := Length(CmdArray.Switches.Switch[Counter2]);
              if CmdArray.Switches.Switch[Counter2] =
                    Copy(TestStr,1,SwitLen) then

                    begin
                       CmdArray.Switches.Present[Counter2] := True;
                       Goto Next_Parameter;
                     end;
           end; { Switches without arguments loop }

       For counter2 := 1 to ArgDSwitchNum  Do
           begin     { Switches With arguments test loop }

              SwitLen := Length(CmdArray.ArgDSw.Switch[Counter2]);
              if CmdArray.ArgDSw.Switch[Counter2] =
                    Copy(TestStr,1,SwitLen) then

                 begin
                    CmdArray.ArgDSw.present[Counter2] := True;
                    Start := length(CmdArray.ArgDSw.Switch[Counter2]) + 1;
                    CurrentArgLen := length(paramStr(counter)) - (start-1);
                    CmdArray.ArgDSw.Arg[Counter2] :=
                          Copy(ParamStr(Counter),Start,CurrentArgLen);

                    Goto Next_Parameter; {used inplace of an Exit}
                 end;
           end;     { Switches With arguments test loop }

    next_parameter:; {used to speed up execution -- Exit doesn't work here}

    end;        {number of Parameters Loop}

end;    {--------->>>> ParseNow <<<<------------}

Procedure Parsedelimited(Var CmdArray : CommandLineArrayType;
                             NoCase,
                             ConvertArgsToUpper   : Boolean );

{this Procedure will bag any String on the commandline With embedded spaces}
(*  and is delimited by Characters such as "" , {}, [], (), <>, ^^, etc ...*)


begin    {--------->>>> Parsedelimited <<<<------------}
end;     {--------->>>> Parsedelimited <<<<------------}
{----------------------------------------------------------------------}

{+++++++++++++++++++ end  Private Procedures to CmdParse Main  +++++++++++++}

{==================================== MAIN Procedure ===================}
begin           {+++++++++>>>> Procedure CmdParse  <<<<++++++++++++}
  {Init Arrays}
  For counter := 1 to ArgLength do      {  the String Blanks needs to be }
      Blanks[Counter] := Blank;         {  global because most routines  }
                                        {  are useing it                 }

  InitCmdArray(CmdArray); { this Procedure located in the cmdparse.h File}
                          { assigns values to switches, etc.}

  InitializeArrays(CmdArray,NoCase);



  If ParamCount = 0 then                { check command line For null String}
     begin                              { if nullString then set No Params  }
        cmdArray.NoParams := True;      { and return to the calling routine }
        Exit;
     end;


   ParseNow(CmdArray, Nocase);           { routine parses the commandline   }
                                         { passing through the switches w/o }
                                         { arguments first. When Delimited  }
 { If Not(NoDelimited) then }            { switch parsing is added, it will }
   { Parsedelimited(CmdArray,NoCase);}   { occur after all other parsing    }
                                         { as a seperate routine to follow  }
                                         { PARSENOW -- additionally -- add  }
                                         { Boolean Value "NoDelimited" to   }
                                         { calling routine and Cmdparse.h   }
                                         { to bypass checking For delimited }

  if ConvertArgsToUpper then
       ConvertArgsToUpperCase(CmdArray);


end;     {+++++++++>>>> Procedure CmdParse  <<<<++++++++++++}

{======================  end CmdParse MAIN Procedure ===================}

{ /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\}
{                    Parser Utility routines                            }
{ /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\}

Procedure ConvertArgtoNumber(ArgNum : Integer;
                             Var  CmdArray : CommandLineArrayType;
                             Var  ResultNumber: Word);
Var
  code : Integer;

begin    {----------->>>> ConvertArgtoNumber <<<<---------------}

  Val(CmdArray.ArgDsw.Arg[ArgNum],ResultNumber,code);
    if code <> 0 then
       begin
          WriteLn('Error commandline argument: ',
                       CmdArray.ArgDsw.Switch[ArgNum],'  ',
                       CmdArray.ArgDsw.Arg[ArgNum]);
          Writeln('press enter to continue');
          readln;
          HelpUser;  {see notes}
       end;

end;     {----------->>>> ConvertArgtoNumber <<<<---------------}

{/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\}

Procedure FnameCheck(progname, progname2 :pathStr;
                     errorlevel : Byte);
Var
teststr1,teststr2 :pathStr;

begin    {----------->>>> FnameCheck <<<<---------------}

teststr1 := copy(paramstr(0),(length(paramstr(0)) - (Length(progname)-1) ),
                             Length(progname));
teststr2 := copy(paramstr(0),(length(paramstr(0)) - (Length(progname2)-1) ),
                             Length(progname2));

if ((teststr1 <> ProgName) and (teststr2 <> ProgName2))
   then
     begin
     WriteLn('Unrecoverable Error in ',progname, ', Check FileNAME');
     halt(Errorlevel);
     end;

end;     {----------->>>> FnameCheck <<<<---------------}

{/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\}

Procedure DispCmdline;
     { use For debugging -- displays the command line parameters}
     { readln at end shows screen Until enter is pressed}
VAr Count : Integer;
begin
ClrScr;

For Count := 1 to  SwitchNum do
    if CmdArray.Switches.present[count] then
       WriteLn(CmdArray.Switches.Switch[count],'    Present');

For Count := 1 to ArgdSwitchNum  do
    if CmdArray.ArgDsw.present[count] then
       begin
          WriteLn(CmdArray.ArgDsw.Switch[count],'   Present.');
          WriteLn('Value of:  ',CmdArray.ArgDsw.Arg[count]);
       end;

Writeln;
Write('press ENTER to continue');
ReadLn;
Halt(0);
end;

Procedure CheckHelp;
Var
   COUNT : Byte;
begin
   For count := 1 to 5 do
     if cmdArray.Switches.Present[Count] then
        helpUser;

   if cmdArray.Switches.Present[6] then
     displayinfo;
end;

{---------------------------Helpuser --------------------------}
Procedure HelpUser;
begin
   ClrScr;
   Writeln (CopyRightStr);
   WriteLn;
   WriteLn('USAGE: ');
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   Writeln;
   Writeln('Press Enter to continue.');
   ReadLn;
   Writeln;
   WriteLn('EXAMPLE:...............................');
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   WriteLn;
   Writeln (CopyRightStr);
   halt(0);
 end;
{-------------------------------------------------------------------------}
Procedure DisplayInfo;
   begin
      ClrScr;
      Writeln(copyrightStr);
      Writeln;
      Writeln('Ken Fox');
      WriteLn('1449 Maple Rd.');
      Writeln('Kintnersville Pa. 18930');
      WriteLn('215 672-9713       9 - 5 EST');
      Writeln;
      Writeln('Contact on shareware conference on Internet  -- KEN FOX');
      Writeln;
      halt(0);

   end;
{--------------------------------------------------------------------------}

this info is For all of the PASCAL conference people:

to use the rotuines in this Program you need to do the following

{$I path.......\Progname.h}
{$I Path.......\Helpuser.PAS}
{$I path.......\CMDPARSE.PAS}

 progname.H is a copy of the CMDPARSE.H File which contains the specific
 settings For the Program you are writing .

 HELPUSER.PAS is a Program specific help routine which get called by
 the routie CHECKHELP in CMDPARSE.PAS if the CheckHelp Procedure is
 used in the main Program. crude but effective.

 CMDPARSE.PAS -- this File contains all of the parsing routines. I keep this
 File in my .....\TP\INCLUDE directory .

 I set up a sepearte directory below the tp directory For each Program
 and copy the Files Helpuser.Pas and cmdparse.h into it thusly each
 copy of these two Files is customized For the give application While
 the actual parsing routines are kept in the INCLUDED FileS directory.
 there's no need to modify CMDPARSE.PAS

 using the parser..

       1) in the CMDPARSE.H File there are templates For all of the Array
 initializations. the switches to search For are manually inserted in to
 each Array item. additionally the Array sizes must be set where indicated
 in the CMDPARSE.H File.
{-------------------------------------------------------------------------}
  THE FOLLOWING ARE THE SETTINGS For Array SIZES
{-------------------------------------------------------------------------}

Const
SwitchLength = 4;   {   maxlegth of a switch to be tested for}
ArgLength = 11;     {   max length of an argument from the commandline}
DelimLength = 1;     {   maxlength of delimiter if used}
SwitchNum = 6;      {   the number of switches and hence the size of the Array}
                    {      of switches  without arguments                  }
ArgdSwitchNum = 2;  {   the number of switches and hence the size of the Array}
                    {      of switches  With arguments                 }
DelimNum = 1;       {   number of args With delimited Strings          }

{-------------------------------------------------------------------------}
     THE FOLLOWING SHOW HOW to INIT THE Array SEARCH VarIABLES..
     THESE LINES ARE ALL CONTAINED in  ---->>>> CMDPARSE.H
{-------------------------------------------------------------------------}

   Switches.Switch[1] := '/?' ;     {default help String}
   Switches.Switch[2] := '/h' ;     {default help String}
   Switches.Switch[3] := '/H' ;     {default help String}
   Switches.Switch[4] := 'HELP' ;   {default help String}
   Switches.Switch[5] := 'help' ;   {default help String}
   Switches.Switch[6] := 'INFO'     {show author contact Info}

{   Switches.Switch[6] := '  ' ;}   {NOT USED}

{---------------------------------}
THE FOLLOWING ARE For SWITCHES WHICH WILL CAPTURE A VALUE AS WELL AS
TEST For THE PRESENCE of THE ARGUMENT
{---------------------------------}
{  ArgDSw.Switch[1] := '' ;}       {not used}
{  ArgDSw.Switch[2] := '' ;}       {not used}
{  ArgDSw.Switch[3] := '' ;}       {NOT USED}
{  ArgDSw.Switch[4] := '' ;}       {NOT USED}
{  ArgDSw.Switch[5] := '' ;}       {NOT USED}
{  ArgDSw.Switch[6] := '' ;}       {NOT USED}
{  ArgDSw.Switch[7] := '' ;}       {NOT USED}

{-------------------------------------------------------------------------}

       2) if you intend to use the routines in HELPUSER.PAS or to perform
a Filename validation  -- there is a template at the beginning of CMDPARSE.H
with Certain Constants which must be set.

Uses Dos,Crt;

Const
  VersionNum = 'V1.0 BETA';
  ProgNameStr = 'NEWPROJ.EXE';
  ProgNameShortStr = 'NP.EXE';
  copyRightStr = ProgNameStr+' ' + VersionNum +
                ', Copyright 1992 - 1993, Ken Fox. All Rights Reserved.';

  DefaultFileName = 'NEWPROJ.DAT';

{-------------------------------------------------------------------------}

      3) To call the Various routines in  the CMDPARSE.PAS File there are
Templates which you can cut and paste into you Program from  CMDPARSE.H

{--------------------------------------------------------------------------}
{                          procs Available in CmdParse.Pas                 }
{ additional info on the following procs may be found in the cmdparse.Pas  }
{ File in the ....\tp\include directory..                                  }
{                                                                          }
{ Procedure DispCmdline;                                                   }
{                                                                          }
{ Procedure CmdParse(Var CmdArray : CommandLineArrayType;                  }
{                            NoCase,                                       }
{                            ConvertArgsToUpper   : Boolean );             }
{                                                                          }
{ Procedure ConvertArgtoNumber(ArgNum : Integer;                           }
{                             Var  CmdArray : CommandLineArrayType;        }
{                             Var  ResultNumber: Word);                    }
{                                                                          }
{ Procedure FnameCheck(progname , progname2 :pathStr;                      }
{                      errorlevel : Byte);                                 }
{                                                                          }
{ Procedure CheckHelp;                                                     }
{                                                                          }
{--------------------------------------------------------------------------}

      4) To test whether an ON/OFF switch is present (such as /?) on the
commandline  use the following:

             if CmdArray.Switches.Present[number] then
                begin
                end;

      5) to get the argument from a switch .

            if CmdArray.ArgDsw.Present[number] then
               WhatEverVariable := CmdArray.ArgDsw.Arg[number];

      6) the Procedure ConvertArgtoNumber is avail to convert a
String on the command line to a decimal number.. this is only good for
for whole numbers w/o nnn.0000111 etc.


hope this stuff is useful -- there are other notes and comments sprinkled
throughout so please check those before calling..

finally - in the interest traversing the command tail only once the most
henious of Programming Constructs -- the Goto statement -- has been used.
please forgive me in advance....

questions comments and suggestions are welcome..

see the address in the CMDPASE.DOC File..

