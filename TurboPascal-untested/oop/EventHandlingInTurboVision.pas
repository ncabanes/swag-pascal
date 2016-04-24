(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0046.PAS
  Description: Event Handling in Turbo Vision
  Author: KEN BURROWS
  Date: 11-26-94  05:04
*)

{
> I got a problem here. This procedure below ,derived from Tapplication, is
> just idling. It won't do the command assigned to Pbutton. There's something
> missing (I'm new with programming in Turbo Vision). The only things it does
> it's to show my button and close my window back. The commands are defined
> in > the HandleEvent of the Tapplication. My objective is to be able to
> open a new > PDialog on top of this one by the command selected.

Your problem is the way you are implementing your dialog. There is no
handleevent method to handle the events of the buttons. Create a tdialog
and fully define and flesh it out, and then execute it from the application.
}

Program ButtonTester; {Tested}
Uses App,Objects,Drivers,Views,Dialogs,msgbox;
Type
   SelDialog = Object(TDialog)
                 Constructor Init(var bounds:TRect;ATitle:TTitleStr);
                 Procedure HandleEvent(var Event:TEvent); virtual;
               end;
   SelDialogPtr = ^SelDialog;
Const
  cmCD_Roms      = 100;
  cmDiskets      = 101;
  cmHard_drive   = 102;
  cmMemory       = 103;

Constructor SelDialog.Init(var bounds:TRect;ATitle:TTitleStr);
   var r : trect;
   Begin
     inherited init(Bounds,ATitle);
     getextent(r); r.grow(-2,-2); r.b.y := r.a.y + 2;
     insert(new(PButton,init(r,'~C~D Roms',cmCD_Roms,bfnormal)));
     inc(r.a.y,2); inc(r.b.y,2);
     insert(new(PButton,init(r,'~D~iskettes',cmDiskets,bfnormal)));
     inc(r.a.y,2); inc(r.b.y,2);
     insert(new(PButton,init(r,'~H~ard Drives',cmHard_Drive,bfnormal)));
     inc(r.a.y,2); inc(r.b.y,2);
     insert(new(PButton,init(r,'~M~emory',cmMemory,bfnormal)));
  End;
Procedure SelDialog.HandleEvent(var Event:TEvent);
   Begin
     inherited HandleEvent(Event);
     if   (event.what = evcommand) and
          (event.command in [cmCD_Roms,cmDiskets,cmHard_Drive,cmMemory])
     then EndModal(event.command);
   End;

Type
  MyApp = Object(TApplication)
            procedure run; virtual;
            function GetSelection:word;
          end;

Function MyApp.GetSelection:Word;
   var p:SelDialogPtr;
       r:Trect;
   Begin
     r.assign(0,0,30,11);
     new(p,init(r,'Select [esc to quit]'));
     p^.options := p^.options or ofCentered;
     if   p <> nil
     then begin
            GetSelection := ExecView(p);
            dispose(p,done);
          end
     else GetSelection := 0;
   End;

Procedure MyApp.Run;
   var w   :word;
       stop:boolean;
   Begin
     stop := false;
     Repeat
       w := GetSelection;
       case w of
       cmCD_Roms    : messagebox(#3'Selected CD Roms',nil,mfokbutton);
       cmDiskets    : messagebox(#3'Selected Diskettes',nil,mfokbutton);
       cmHard_drive : messagebox(#3'Selected Hard Drives',nil,mfokbutton);
       cmMemory     : messagebox(#3'Selected Memory',nil,mfokbutton);
       else stop := true;
      end;
    Until Stop;
  End;

Var mApp : MyApp;
    m   : Longint;
Begin
  m := memavail;
  with mApp do begin init; run; done; end;
  if m <> memavail then writeln('heap ''a trouble');
End.

