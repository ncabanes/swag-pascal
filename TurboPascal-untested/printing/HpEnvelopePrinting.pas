(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0001.PAS
  Description: HP Envelope Printing
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:55
*)

{In a following message, the Complete Turbo Pascal source code For DJENV.PAS
is presented For all who may be interested in what it does, or illustrates.

The Program prints the "return" and "to:" addresses on a long ("#10")
business sized envelope in a HP DeskJet series Printer.

Along the way it illustrates:

  1) How to test For existence of a specific File

  2) How to Read from a structured-Type File

  3) How to Write to a structured-Type File

  4) How to do Text-Type output to any of: LPT1...LPT3, NUL, or a disk File
     With the same code.

  5) How to change fonts in PCL 3 (although this is not explained, it is
     done to give small print For the return address and larger print
     For the to: address.)

  6) How to use TechnoJock's Turbo toolkit For "full-screen I/O".  There are
     three Procedures in the Program which REQUIRE the toolkit to Compile.
     These routines could be modified For non-Full-Screen action which
     would allow you to not use the TT toolkit.  if you don't want to make
     the modifications, and don't have the TT toolkit, you may File request

     DJENV.ZIP

     from my system at 1:106/100.  It has both the source code presented here
     and a Compiled .EXE File, ready to roll.

  if you'd like to play With it, but don't have a DJ or LASERJET-Compatible
Printer, then you may tell the Program to print to a disk File or even NUL
instead of LPT1, etc.

  Whatever addresses you enter, plus the name of the "print device" you
use, will be saved in the File DJENV.CFG .  With a little work, DJENV.CFG
could easily become a mini-database and allow you to retrieve from any
number of previous envelope setups, instead of just the last one you used.
I may eventually do this, but no time frame is currently anticipated For
it's Completion.

  You may print 1 to many copies of the setup after you have entered it's
info. The Program paUses beFore each envelope and gently nudges you to
prepare an envelope For printing and then to hit Return.  (Any key
returning a key code will do as well as Return.)

  Loading the envelopes is a Complete MANUAL operation.  While the DJ
has a software command to load envelopes, you must still manually
position the envelope For loading.  if the envelope doesn't load cleanly
(and in my experience, about 1 in every 10 or 15 will go in crooked...), I
felt it would be better to deal With that BEForE attempting to print.  After
the envelope is in position to load, then it is necessary to hit two of the
panel buttons together to have the DJ500 to pull the envelope into
position.  When that is acComplished correctly, then hit Return to print to
the envelope.

Hope some of you find this useful/interesting/maybe even helpful!
}

Program DJ_Envelopes;

{  This Program illustrates how to Program For envelope printing
   With the HP DeskJet series of Printer.  It would possibly work
   For any PCL 3 (or better) Printer which can load envelopes.

   note:  Loading envelopes on the DJ Printers *IS* a bit tricky
          and requires cooperative envelopes.  Be sure to read the
          part in your manual about use of envelopes, selecting good
          Printer-use envelopes, and especially about LOADinG them
          manually.  I have used the following inexpensive envelopes
          With some degree of success.  They were purchased at a
          discount business/office supply store, BIZMART, but as the
          brand is national, you can probably find them most anywhere:

             MEAD Management Series, no. 75604
             Number 10 size, 4-1/8" x 9-1/2"
             BARCODE#   43100 75064

             (100 of them cost about $2.00)


   This Program is PUBLIC doMAin and may be freely distributed, modified,
   even SOLD. (if you can find somebody stupid enough to pay For a PD
   Program, MorE POWER to YOU! I would ask that you at least send me
   their names....)

   The author is: Justin Marquez FidoNet 1:106/100  Houston, TX  USA
}

Uses
   FASTTTT5, {Requires TechnoJock's Turbo toolkit Ver 5 or higher }
   WinTTT5,  {Requires TechnoJock's Turbo toolkit Ver 5 or higher }
   IOTTT5,   {Requires TechnoJock's Turbo toolkit Ver 5 or higher }
   Crt,      { Crt Unit For ClrScr }
   Dos;      { Req'd to be able to use the EXIST Procedure as I wrote it }

Const
    Return_Size   = #27+'&l0O'+ #27+'(10U' +#27+'(s1p6v0s41010bt2Q';
    Addressee_Size = #27+'&l0O'+ #27+'(10U' +#27+'(s1p12v0s4103b1t2Q';
    Config_File = 'DJENV.CFG';

Type
    Add_Strg = String[60];

    Address_Data = Record { this is the Format of the "config File" }
      Who_from: Array[1..5] of Add_Strg;
      Last_to : Array[1..5] of Add_Strg;
      PRN_DEV : String;
    end;

Var
    Return_Address,
    Address : Array[1..5] of Add_Strg;

    lst     : Text;

    Last_Data : Address_Data;
    CF_Data   : File of Address_Data; { going to be the config File }

    Print_to: String;

    n,
    Counter,
    How_Many : Integer;

Function EXIST(Filename :String): Boolean;
{  Determines if a File exists or not.  NO WILDCARDS!
   Main Program or Unit MUST have "Uses Dos;" in it!
}
Var
   Attr : Word;
   f    : File;
begin
  Assign(f,Filename);
  GetFAttr(f,Attr);
  if Attr = 0 then
    Exist := False else
    Exist := True;
end; { of exist Function }

Procedure DrawScreen1;
  {Requires TechnoJock's toolkit, Used to set up For the full-screen I/O}
begin
  ClrScr;
  WriteCenter(1,Blue,White,' Enter Address Info, and hit F10 when done ...');
  WriteCenter(2,Blue,White,' (Use CURSor keys For up & dn, RETURN For left &
right) ');
  WriteAt( 1, 5, White,Blue,'RETURN ADDRESS inFO...');
  WriteAt( 3, 6, White,Blue,'             Line #1 :');
  WriteAt( 3, 7, White,Blue,'             Line #2 :');
  WriteAt( 3, 8, White,Blue,'             Line #3 :');
  WriteAt( 3, 9, White,Blue,'             Line #4 :');
  WriteAt( 3,10, White,Blue,'             Line #5 :');
  WriteAt( 1,13, White,Blue,'ADDRESSEE inFO ....   ');
  WriteAt( 3,14, White,Blue,'             Line #1 :');
  WriteAt( 3,15, White,Blue,'             Line #2 :');
  WriteAt( 3,16, White,Blue,'             Line #3 :');
  WriteAt( 3,17, White,Blue,'             Line #4 :');
  WriteAt( 3,18, White,Blue,'             Line #5 :');
  WriteAt( 3,20, White,Blue,'Send Output to :');
  WriteAt( 3,21, White,Blue,'[ Ex: LPT1  or  LPT2 or NUL (For testing) ]');
  WriteAt( 3,23, White,Blue,'Print How Many?:');
end; { of pvt Procedure drawscreen1 }

Procedure FS_IO;
{ Requires TechnoJock's Turbo toolkit }
Var
  counter : Integer;
begin
  Create_Fields(12);
  {          #  U  D  L  R  x  y   }
  Add_Field( 1,12, 2,12, 2,27, 6);
  Add_Field( 2, 1, 3, 1, 3,27, 7);
  Add_Field( 3, 2, 4, 2, 4,27, 8);
  Add_Field( 4, 3, 5, 3, 5,27, 9);
  Add_Field( 5, 4, 6, 4, 6,27,10);
  Add_Field( 6, 5, 7, 5, 7,27,14);
  Add_Field( 7, 6, 8, 6, 8,27,15);
  Add_Field( 8, 7, 9, 6, 9,27,16);
  Add_Field( 9, 8,10, 8,10,27,17);
  Add_Field(10, 9,11, 9,11,27,18);
  Add_Field(11,10,12,10,12,27,20);
  Add_Field(12,11, 1,11, 1,27,23);

  For n := 1 to 5 Do

String_Field(n,Return_Address[n],'**********************************************
****');
  For n := 1 to 5 Do

String_Field(n+5,Address[n],'**************************************************'
);

String_Field(11,Print_to,'**************************************************');
  Integer_Field(12,How_Many,'',0,0);
  PROCESS_inPUT(1);
  Dispose_Fields;
end; { of Procedure FS_IO }

Procedure Init;
begin
  if ParamCount < 1
  then
    Print_to := 'LPT1'
  else
    Print_to := ParamStr(1);
  if Exist(config_File)
  then
    begin
      Assign(CF_Data,ConFig_File);  { How to READ a Record from a File }
      ReSet(CF_Data);
      Seek(CF_Data,0);
      Read(CF_DATA,Last_Data);
      Close(CF_Data);
      With Last_Data do
      begin
        For n := 1 to 5 do
        begin
          Return_Address[n] := Who_From[n] ;
          Address[n]        := Last_to[n];
        end;
        Print_to := PRN_DEV;
      end;
    end
  else
    begin
      Return_Address[1] :='';
      Return_Address[2] :='';
      Return_Address[3] :='';
      Return_Address[4] :='';
      Return_Address[5] :='';
      Address[1] := '';
      Address[2] := '';
      Address[3] := '';
      Address[4] := '';
      Address[5] := '';
    end;
  How_Many := 1;
end;

Procedure OutPut_to_DJ500;
begin
  Assign(lst,Print_to);
  ReWrite(lst);
  Write(Lst,#27+'&l8D');
  Write(lst,Return_Size);
  For n := 1 to 5 Do
    WriteLn(lst,Return_Address[n]);
  Write(Lst,#27+'&l5D');
  Write(lst,Addressee_Size);
  For n := 1 to 3 Do Writeln(lst);
  For n := 1 to 5 Do
    WriteLn(lst,'
        ',Address[n]);
  WriteLn(lst,#12);
  WriteLn(lst,#27+'E');
  close(lst)
end;

Procedure Save_Config_File;
begin
  Assign(CF_Data,ConFig_File);      { How to Write a Record to a File }
  ReWrite(CF_Data);
  With Last_Data do
  begin
    For n := 1 to 5 do
    begin
      Who_From[n] := Return_Address[n];
      Last_to[n]  := Address[n];
    end;
    PRN_DEV := Print_to;
  end;
  Seek(CF_Data,0);
  Write(CF_DATA,Last_Data);
  Close(CF_Data);
end;

Procedure Pause;
{ Requires TechnoJock's Turbo toolkit }
begin
  TempMessageBOX(20,10,Green,Blue,2,'Load an envelope (manually) and Hit
RETURN.');
end;

Procedure PRinT_ENVELOPES;
begin
  ClrScr;
  GotoXY(2,1);
  Write('Printing Envelope #:');
  Counter := 1;
  if How_Many > 1
  then
    begin
    For Counter := 1 to How_Many Do
      begin
        WriteLn('  ',Counter);
        Pause;
        OutPut_to_DJ500;
      end;
    end
  else
    begin
      WriteLn('  ',Counter,' ( and only 1 ...)');
      Pause;
      OutPut_to_DJ500;
    end;
end;

begin
  Init;
  DrawScreen1;
  FS_IO;
  PRinT_ENVELOPES;
  Save_Config_File;
end.

