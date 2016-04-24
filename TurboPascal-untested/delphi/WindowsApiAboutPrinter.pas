(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0421.PAS
  Description: Windows API about Printer
  Author: RHONDA CROWDER
  Date: 01-02-98  07:34
*)

From: David and Rhonda Crowder <dcrowder@bridge.net>

>> I want to obtain the values (left, right, top, bottom) of "unprintable area" from the printer. 

In August Delphi Developer "Take Control of your printer with a custom Delphi Class": 

To get the Left and Top Printer Margins use the Windows Escape Function with the parameter GETPRINTINGOFFSET.


--------------------------------------------------------------------------------

var
  pntMargins : TPoint;
begin
  { @ means " the address of the variable" }
  Escape(Printer.Handle, GETPRINTINGOFFSET,0,nil,@prntMargins);
end;

--------------------------------------------------------------------------------

Getting the Right and Bottom Margins aren't quite so straightforward. There isn't an equivalent Escape call. You obtain these values by getting the physical width (physWidth) and height (physHeight) of the page, the printable width (PrintWidth) and height (PrintHeight) of the page, and then carrying out the following sums:

RightMargin    := physWidth  - PrintWidth  - LeftMargin
BottomMargin := physHeight - PrintHeight - TopMargin
The physical page size is found using Escape, this time with the GETPHYSPAGESIZE parameter. The point pntPageSize contains the page width in pntPageSize.x and page height in pntPageSize.y


--------------------------------------------------------------------------------

var
  pntPageSize : TPoint;
begin
   Escape(Printer.Handle, GETPHYSPAGESIZE,o,nil,@pntPageSize);
end;

