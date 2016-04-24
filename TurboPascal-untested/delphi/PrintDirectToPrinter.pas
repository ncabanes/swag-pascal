(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0309.PAS
  Description: Print direct to printer
  Author: JAVIER CELUCE
  Date: 08-30-97  10:08
*)


A two months ago Gareet Wilson answer this question and I tested that work
fine...

The best way I have found is to do the following, which uses the Windows
printing routines, but sends data directly to the printer (you may have
to changes things around, but this is a good outline}. I figured out a
lot of this from "Three Printing Techniques for Windows 95 Console
Applications," by David Tamashiro in the C/C++ User's Journal, January
1997.

**First, include the following:

var
  PrinterHandle:THandle;  {the handle to the printer}

uses WinSpool, Printers;

type TDocInfo1=packed record {the replacement for DOC_INFO_1}
  lpszDocName: PAnsiChar;
  lpszOutputFile: PAnsiChar;
  lpszDatatype: PAnsiChar;
end;

**Then, open a printer according to its name:

var
  CTitle:array[0..31] of Char;
  CMode:array[0..4] of Char;
  DocInfo:TDocInfo1;
begin
  StrPLopy(CTitle, 'My Title'); {setup our title buffer}
  StrPCopy(CMode, 'RAW'); {put "RAW" in our mode buffer}
  FillChar(DocInfo, SizeOf(DocInfo), 0);  {fill the DocInfo structure
with zero's}
  with DocInfo do
  begin
    lpszDocName:=CTitle;  {set the title of our document}
    lpszOutputFile:=nil;  {specify no output file}
    lpszDatatype:=CMode;  {set the mode, which we have specified as
"RAW"}
  end;
  OpenPrinter('Printer Name Here', PrinterHandle, nil);
  StartDocPrinter(PrinterHandle, 1, @DocInfo);
  StartPagePrinter(PrinterHandle);


**Now, print your text:

var
  Count:DWord; {the number of bytes written}
begin
  WritePrinter(PrinterHandle, PChar(printText), Length(printText),
Count);


**When you are finished printing, tidy things up:

  EndPagePrinter(PrinterHandle);  {end the page}
  EndDocPrinter(PrinterHandle); {end the document}
  if PrinterHandle<>0 then  {if we have a printer handle}
  begin
    ClosePrinter(PrinterHandle);  {close the printer}
    PrinterHandle:=0; {show that we have closed the printer}
  end;


I think that about covers it. Hope this helps.

