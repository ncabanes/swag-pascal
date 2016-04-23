{
> I need help with the turbo vision handleevent procedure...I can't get a
> dialog box to handle any events of its own...I got Tapplications
> handlevent to work for me, but it just won't work in a dialog box.  Please
> help.

Normally a dialog can handle some 4 types of events - that is END the dialog
with the return code of your event - I'm guessing that you want a dialog with
some ten buttons or something like that ?
I've designed a dialog decendor that will take up to 16k buttons

Extract from peldialogs - Copyright 1994 PEL-Data Borås Sweden
Released for public domain on term that origin of code is mentioned in
credits part of your program !
}

unit peldialogs;

interface

uses
 Objects,
 Drivers,
 dialogs,
 views,
 pelRegtypes,
 pelobjects,
 msgbox;

Type
 Ppeldialog = ^Tpeldialog;
 Tpeldialog = object(tdialog)
  endcmds:Ppelwordcollection;
  constructor Init(var Bounds: TRect; ATitle: TTitleStr);
  destructor done;virtual;
  procedure addcmd(cmd:word);virtual;
  procedure HandleEvent(var Event: TEvent); virtual;
 end;

implementation
uses
 Dos,    Memory,
 StdDlg,  app,
 peltextlang,
 pelfile, validate, pelvalidate,pelstrings;


constructor Tpeldialog.Init(var Bounds: TRect; ATitle: TTitleStr);
begin
 inherited Init(Bounds,ATitle);
 endcmds:=new(Ppelwordcollection,init(5,5));
end;

destructor Tpeldialog.done;
begin
 dispose(endcmds,done);
 inherited done;
end;

procedure Tpeldialog.addcmd(cmd:word);
var
 p:pword;
begin
 new(p);
    p^:=cmd;
 endcmds^.insert(p);
end;

procedure Tpeldialog.HandleEvent(var Event: TEvent);
var Index: Integer;
begin
 inherited HandleEvent(event);
 if Event.What = evCommand then begin
  if endcmds^.search(@Event.Command,index) then begin
   if State and sfModal <> 0 then begin
    EndModal(Event.Command);
    ClearEvent(Event);
   end;
  end;
 end;
end;

end.
{
Use the ppeldialog instead of the pdialog

Add a call to addcmd() for every command you want the dialog to exit with
normally a dialog will end for cmok,cmcancel,cmyes and cmno - those dont need
to be added !
}
