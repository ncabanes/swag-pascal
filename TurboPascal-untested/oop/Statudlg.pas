(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0017.PAS
  Description: STATUDLG.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:53
*)

 Program StatusDialogDemo;

 Uses
   Crt,Objects,Drivers,Views,Dialogs,App;

 Type
   PDemo = ^TDemo;
   TDemo = Object (TApplication)
     Constructor Init;
     end;

   PStatusDialog = ^TStatusDialog;
   TStatusDialog = Object (TDialog)
     Message,Value: PStaticText;
     Constructor Init;
     Procedure Update (Status: Word; AValue: Word); Virtual;
     end;

 Constructor TDemo.Init;

 Var
   D: PStatusDialog;
   I: Integer;
   E: TEvent;

 begin
 TApplication.Init;
 D := New (PStatusDialog,Init);
 Desktop^.Insert (D);
 For I := 1 to 10 do
   begin
   D^.Update (cmValid,I * 10);
   if CtrlBreakHit then
     begin
     CtrlBreakHit := False;
     GetEvent (E);  { eat the Ctrl-Break }
     D^.Update (cmCancel,I * 10);
     Repeat GetEvent (E) Until (E.What = evKeyDown)
       or (E.What = evMouseDown);
     Desktop^.Delete (D);
     Dispose (D,Done);
     Exit;
     end;
   Delay (1000);  { simulate processing }
   end;
 D^.Update (cmOK,100);
 Repeat GetEvent (E) Until (E.What = evKeyDown)
   or (E.What = evMouseDown);
 Desktop^.Delete (D);
 Dispose (D,Done);
 end;

 Constructor TStatusDialog.Init;

 Var
   R: TRect;

 begin
 R.Assign (20,6,60,12);
 TDialog.Init(R,'Processing...');
 Flags := Flags and not wfClose;
 R.Assign (10,2,30,3);
 Insert (New (PStaticText,Init (R,'Completed Record xxx')));
 R.Assign (27,2,30,3);
 Value := New (PStaticText,Init (R,'  0'));
 Insert (Value);
 R.Assign (2,4,38,5);
 Message := New (PStaticText,Init (R,
   '     Press Ctrl-Break to cancel     '));
 Insert (Message);
 end;

 Procedure TStatusDialog.Update (Status: Word; AValue: Word);

 Var
   ValStr: String[3];

 begin
 Case Status of
   cmCancel: begin
     DisposeStr (Message^.Text);
     Message^.Text := NewStr ('     Cancelled - press any key      ');
     Message^.DrawView;
     end;
   cmOK: begin
     DisposeStr (Message^.Text);
     Message^.Text := NewStr ('     Completed - press any key      ');
     Message^.DrawView;
     end;
   end;
 Str (AValue:3,ValStr);
 DisposeStr (Value^.Text);
 Value^.Text := NewStr (ValStr);
 Value^.DrawView;
 end;

 Var
   Demo: TDemo;

 begin
 Demo.Init;
 Demo.Run;
 Demo.Done;
 end.

 {
GH>        Can someone explain how exactly to display a
GH>parameterized Text field into a dialog Window?  This is what I

Here is a dialog that I hope does what you want.  It comes from Shazam,
a TV dialog editor and code generator.  Also a great learning tool.
YOu can get it as SZ2.zip from Compuserve or from Jonathan Stein
directly at PO Box 346, Perrysburg OH 43552 fax 419-874-4922.

 Function MakeDialog : PDialog ; Var Dlg                       :
   PDialog ; R                         : TRect ; Control , Labl , Histry
   : PView ; begin R.Assign ( 0 , 10 , 37 , 23 ) ; New ( Dlg , Init ( R
   , 'About #2' ) ) ;

   R.Assign ( 10 , 2 , 26 , 3 ) ;
   Control                   := New ( PStaticText , Init ( R ,
   'A Sample Program' ) ) ;
   Dlg^.Insert ( Control ) ;

   R.Assign ( 13 , 4 , 20 , 5 ) ;
   Control                   := New ( PStaticText , Init ( R ,
   'Version' ) ) ;
   Dlg^.Insert ( Control ) ;

   R.Assign ( 21 , 4 , 28 , 5 ) ;
   Control := New ( PParamText , Init ( R , '%-s    ' , 1 ) )
   Dlg^.Insert ( Control ) ;

   R.Assign ( 8 , 6 , 29 , 7 ) ;
   Control                   := New ( PStaticText , Init ( R ,
   '(C) Copyright 19xx by' ) ) ;
   Dlg^.Insert ( Control ) ;

   R.Assign ( 8 , 8 , 29 , 9 ) ;
   Control                   := New ( PStaticText , Init ( R ,
   'Anybody, Incorporated' ) ) ;
   Dlg^.Insert ( Control ) ;

   R.Assign ( 14 , 10 , 24 , 12 ) ;
   Control := New ( PButton , Init ( R , ' O~K~ ' , cmOK , bfDefault));
   Control^.HelpCtx          := hcAbout2 ;
   Dlg^.Insert ( Control ) ;

   Dlg^.SelectNext ( False ) ;
   MakeDialog                   := Dlg ;
end ;

Var
   DataRec                   : Record
   ParamField1               : PString ; { ParamText }
                               end ;

  }
