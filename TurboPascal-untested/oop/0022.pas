{
Johan: this code may help you out.  Keep With it, the learning curve
on TV is very steep.  Try the Fidonet TV Forum in Europe, or better
yet, the Compuserve BPascalA Forum.
}
{xcdialog.int}

{$X+}

Unit xcdialog;

Interface

Uses
  Objects,Drivers,Views,Menus,Dialogs,MsgBox,App,Crt,Printer,
  TVXCVars, FmtLine, XCMapL, TVCalcL, TVXCHelp, File_ioL, Dos;

Type
  PAspDialog = ^TAspDialog;
  TAspDialog = Object(TDialog)
  end;

  PExitDialog = ^TExitDialog;
  TExitDialog = Object(TDialog)
  end;

Procedure ExitDialog;  {asks user whether s/he want to quit or not}

Implementation


Procedure ExitDialog;
{■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■}
Var
   Dlg                       : PAspDialog ;
   R                         : TRect ;
   Control, Labl             : PView ;
   Event                     : TEvent;
   iStart                    : Integer;
begin
   R.Assign ( 10 , 2 , 60 , 12 ) ;
   New ( Dlg , Init ( R , 'Exit Confirmation') ) ;

   iStart:= (50 - length('Are you SURE you want to Exit?')) div 2;
   {centre Text}

   R.Assign ( iStart , 3 , 48 , 4 ) ;
   Control := New ( PStaticText , Init ( R , length('Are you SURE'
                    +' you want to Exit?' ) ) ;
   Dlg^.Insert ( Control ) ;

   R.Assign ( 10 , 7 , 21 , 9 ) ;
   Control:= New ( PButton , Init ( R , Words^.get(numYes) ,
                    cmOK , bfDefault ) ) ;
   Control^.HelpCtx          := hcEnter ;
   Dlg^.Insert ( Control ) ;

   R.Assign ( 23 , 7 , 36 , 9 ) ;
   Control := New ( PButton,Init(R , 'Cancel', cmCancel , bfNormal ) ) ;
   Control^.HelpCtx          := hcCancelBtn ;
   Dlg^.Insert ( Control ) ;

   Dlg^.SelectNext ( False ) ;

   if  Desktop^.ExecView (Dlg)  <> cmCancel then
   begin
    Event.What     := evCommand;
    Event.Command  := cmQuit;
    Application^.PutEvent(Event);
   end;
   Dispose(Dlg, Done);
end;
