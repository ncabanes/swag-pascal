(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0085.PAS
  Description: Printing in TPW
  Author: SWAG SUPPORT TEAM
  Date: 02-21-96  21:04
*)

{
Recently I put up a message asking for help so that I could
change the font of the display, Editor, in the application unit
stddlgs.pas (povided with tpw). Now that I have succeeded in doing that,
I want to print out what is displayed on the screen. The printdlg
function appears to be what I should use, according to on-line help. I
have added the method below to my own TDataWindow object (inheriting
the TFileWindow object from stddlgs.pas). It calls PrintDlg successfully
(the result of CommExtendedDlg=0) but nothing is printed. I believe that
either
a) I am failing to initialise PrintDialog incorrectly;
b) calling PrintDlg incorrectly or
c) calling StartDoc and EndDoc incorrectly.

If anyone can put be in the right direction, I would be extremely
grateful.

Fiona Stephen
}

procedure TDataWindow.FilePrint(var Msg: TMessage);
var
    reply:boolean;
    output,output2:integer;
    PrintDialog:TPrintdlg;
    returnvalue:LongInt;
    errorstr:Pchar;
begin
    fillchar(printdialog,sizeof(printdialog),#0);
    printdialog.hdc:=editor^.hwindow;
    printdialog.lstructsize:=sizeof(printdialog);
    printdialog.flags:=printdialog.flags+pd_returndc;
    reply:=printdlg(printdialog);
    returnvalue:=CommDlgExtendedError;
    errorstr:='Not identified';
    CASE RETURNVALUE OF
       CDERR_FINDRESFAILURE	:ERRORSTR:='CDERR_FINDRESFAILURE';
(*     I've deleted the rest of the CASE statement for brevity.
       Basically it tells me the result of commdlgextendederror to
       check the application of printdlg.*)

    END;
    if returnvalue<>0 then
            output:=MessageBox(HWindow, Errorstr, 'Print Data',mb_OK)
    else begin
            output:=startdoc;
            if output=SP_ERROR then
                  output2:=MessageBox(HWindow, 'Job not started', 'Print
                  Data',mb_OK)
            else
                  output2:=MessageBox(HWindow, 'Job started', 'Print
                  Data',mb_OK);
            output:=enddoc;
            if output<0 then
                  output2:=MessageBox(HWindow, errorstr, 'Job Not
                  Finished',mb_OK);
     end;
end;


