(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0060.PAS
  Description: TELIX Phone File
  Author: THOMAS SKOGESTAD
  Date: 08-25-94  09:12
*)

{
│  Post more code so we can see where you're going wrong.

I'm just posting things that are relevant, i.e. no error trapping code
and such. Also I've deleted the original comments, as they are in
Norwegian, and added some new in English.

Also, I use one heck of a stack. The program worked fine on my machine,
I took it a friend and on his machine the default stack was too little.
When I came back the exact same program that I had been using on my
machine also started complaining about the stack size. Could pointers
help in reducing stack?

This is the array I use to read BBS entries into from the text file
}
  TBbsList = Record
    BBSName : Array25;   {All ArrayXX are defined as Array[1..XX] of Char}
    BBSPhone : Array17;
  end;

TBBSArray = Array [1..1000] of TBBSList;


Procedure Write2Fon(bbsnumber : Integer);

{This is the definition for the Telix .fon file format}
TYPE

  tddf_header = record
    id          : LongInt;  (* should be hex 2e2b291a                    *)
    ddf_vers    : Integer;  (* currently 1                               *)
    num_entries : Integer;  (* # of entries in directory, from 1 to 1000 *)
    pencrypted  : Char;     (* currently 0, will be used for encryption  *)
    spare       : Array55;
  end;

  tdd_entry = record
    name       : Array25; (* entry name                                   *)
    number     : Array17; (* phone number                                 *)
    baud       : Byte;    (* baud rate, see below                         *)
    parity     : Byte;    (* parity: 0 = none, 1 = even, 2 = odd          *)
    data       : Byte;    (* number of data bits, 7 or 8                  *)
    stop       : Byte;    (* number of stop bits, 1 or 2                  *)
    script     : Array12; (* linked script file name                      *)
    lastcall   : Array6;  (* last call date, stored in ASCII, w/o slashes *)
    totcalls   : Word;    (* total successful calls to this entry         *)
    terminal   : Byte;    (* terminal type to use, see below              *)
    protocol   : Char;    (* default protocol; first letter               *)
    toggles    : Byte;    (* bit 0: local echo - 0=off, 1=on              *)
                          (* bit 1: add LFs    - 0=off, 1=on              *)
                          (* bit 2: BS trans   - 0=destructive, 1=not     *)
                          (* bit 3: BS key     - 0=sends BS, 1=sends DEL  *)
    filler1    : Char;
    filler2    : Char;
    dprefnum   : Byte;    (* dialing prefix number to use when dialing    *)
    password   : Array14; (* password for this entry                      *)
  end;

VAR
 FonFile : File;
 BBSCount : Integer;
 SPcount : Byte;
 SpareArr : Array55;
 DDF_Header: Tddf_Header;
 DD_Entry : Array[1..500] of Tdd_Entry;
 tname : array25;
 tnumber : array17;
 tscript : array12;
 tlastcall : array6;
 tpassword : array14;
 bname, bnumber, bscript, blastcall, bpassword : String;


BEGIN

Assign(FonFile, 'c:\modem\telix\test.fon'); {Yes it's hard coded right now}
ReWrite(FonFile, 1);

SPcount := 1;
While SPcount < 56 do
  Begin
    SpareArr[SPcount] := #0;
    Inc(SPCount);
  end;


With DDF_Header DO Begin
  ID := $2e2b291a;
  DDF_Vers := 1;
  Num_Entries := BBSNumber;
  Pencrypted := '0';
  Spare := SpareArr;
end;


bscript := 'xxxxxx';    {Just some hard coding to get things to work}
blastcall := '      ';
bpassword := 'xxxxxx';


String2Arr12(bscript, tscript); {I call a simple procedure to convert}
                                {from string to array of char}

String2Arr6(blastcall, tlastcall);
String2Arr14(bpassword, tpassword);

For BBSCount := 1 to BBSNumber do
  Begin
     With DD_entry[BBSCount] DO
     Begin
      name       := BBSArray[BBSCount].BBSName;
      number     := BBSArray[BBSCount].BBSPhone;
      baud       := 5;
      parity     := 0;
      data       := 8;
      stop       := 1;
      script     := tscript;
      lastcall   := tlastcall;
      totcalls   := 0;
      terminal   := 1;
      protocol   := 'Z';
      toggles    := 0000;
      filler1    := 'A';
      filler2    := 'B';
      dprefnum   := 1;
      password   := tpassword;
    end;
  end;

  BlockWrite(FonFile, DDF_Header, SizeOf(DDF_Header));

  For BBSCount := 1 to BBSNumber do
  Begin
    BlockWrite(FonFile, DD_Entry[BBSCount], SizeOf(DD_entry[BBSCount]));
                        {This could be the wrong way of doing it?}
    Inc(BBSCount);
  end;


  Close(Fonfile);

end;


