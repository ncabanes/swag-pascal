{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

 Program Name : MyPBDmo2.Pas
 Written By   : Brad Prendergast
 E-Mail       : mrealm@ici.net
 Web Page     : http://www.ici.net/cust_pages/mrealm/BANDP.HTM
 Program
 Compilation  : Borland Turbo Pascal 7.0

 Program Description :
   This sample program displays the creation and usage of a progress box.
   This progress box shows the percentage complete of a certain action.
   This demonstration is a very basic application and is meant to be used as
   an informative tool and built upon.  The process can be terminated at any
   time prior to reaching 100% by pressing ctrl-break.  Please pardon the
   lack of commenting, if you have any questions feel free to email me.

 =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

Program PBDemo2;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
{ These are the standard set of compiler directives I opt to use }

{$DEFINE DEBUG}
{$DEFINE Error_Checking}
  {$IFDEF Error_Checking}
    {$I+}  {L I/O Checking            }
    {$Q+}  {L Overflow Checking       }
    {$R+}  {L Range Checking          }
    {$S+}  {L Stack Overflow Checking }
  {$ELSE}
    {$I-}  {L I/O Checking            }
    {$Q-}  {L Overflow Checking       }
    {$R-}  {L Range Checking          }
    {$S-}  {L Stack Overflow Checking }
  {$ENDIF}
{$UNDEF Error_Checking}

  {$IFDEF DEBUG}
    {$D+}  {G Debug Information              }
    {$L+}  {G Local Symbol Information       }
    {$Y+}  {G Symbolic Reference Information }
  {$ELSE}
    {$D-}  {G Debug Information              }
    {$L-}  {G Local Symbol Information       }
    {$Y-}  {G Symbolic Reference Information }
  {$ENDIF}

{$A+}  {G Align Data}
{$B-}  {L Short Circuit Boolean Evaluation   }
{$E-}  {G Disable Emulation                  }
{$F+}  {L Allow Far Calls                    }
{$G+}  {G Generate 80286 Code                }
{$N-}  {G Disable Numeric Processing         }
{$P+}  {G Enable Open Parameters             }
{$O+}  {G Overlay                            }
{$T-}  {G Type @ Operator                    }
{$V+}  {L Var String Checking                }
{$X+}  {G Extended Syntax Enabled            }

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  uses
    Dialogs, App, Objects, Views, Drivers;

  type
    PMyDialog      = ^TMyDialog;
    TMyDialog      = Object ( TDialog )
                   ondone,
                   onbreak      : boolean;
                   displayline  : PStaticText;
                   progress,
                   percentage,
                   total        : longint;
                   status       : word;
                   Constructor Init ( mdtitle : string; totaltodo : longint );
                   Function Update ( currperc : longint ) : word;
                   Procedure SetHitAnyKeyMode(mode : integer; enable : boolean);
                   Procedure HitAnyKey;
                   Procedure Draw; virtual;
                     end;

    TMyApplication = Object (TApplication)
                   Constructor Init;
                     end;

  var
    mydemo : TMyApplication;

  const
    mdok   = 0;
    mddone = 1;
    mdbreak =2;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  Constructor TMyDialog.Init;
    var
      r : TRect;
      p : PParamText;
    begin
      r.Assign(1,1,41,7);
      Inherited Init ( r, mdtitle );
      options := options + ofcentered;
      GetExtent(R);
      r.A.Y := 2;
      r.B.Y := 3;
      r.Grow(-1,0);
      p := New(PParamText, Init(r,  #3'%3d percent complete.',1));
      p^.ParamList := @percentage;
      displayline := p;
      Insert(p);
      total := totaltodo;
      Update(0);
      Desktop^.Insert(@self);
      TDialog.Draw;
    end;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  Function TMyDialog.Update ( currperc : longint ):word;
    var
      event: TEvent;
      c    : char;

    Begin
      progress := currperc;
      percentage := (progress*100) div total;
      If Progress = Total then Status := mdDone
        else if CtrlBreakHit then
          begin
            status := mdbreak;
            CtrlBreakHit := False;
            GetEvent(event);
          end
        else status := mdok;
     DrawView;
     If (Status = mdDone) and OnDone then HitAnyKey;
     If (Status = mdBreak) and OnBreak then HitAnyKey;
     Update := Status;
   end;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  Procedure TmyDialog.SetHitAnyKeyMode(mode: integer; enable: boolean);
     begin
       case mode of
         mdBreak: OnBreak := enable;
         mdDone : OnDone  := enable;
       end;
     end;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  Procedure TMyDialog.HitAnyKey;
    var
    event : TEvent;
    begin
      If (((Status=mdDone) and OnDone) or ((Status=mdBreak) and OnBreak)) then
      repeat
        GetEvent(Event)
      until (Event.What <> evNothing);
    end;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  Procedure Tmydialog.Draw;
    var
      buf : TDrawBUffer;
      r   : TRect;
    begin
     GetExtent(r);
     r.Grow(-1,-1);
     r.A.Y := r.B.Y - 1;
     Dec(r.B.X);
     If Status = mdDone then MoveCStr(buf, '      Successful: ~Press Any Key~      ',$9F1F)
     else
       if Status = mdBreak then MoveCStr(buf, '      Cancelled: ~Press Any Key~       ',$9F1F)
       else MoveStr(buf, '     Press Ctrl-Break to Cancel       ',$1F);
     displayline^.DrawView;
     WriteLine(R.A.X, R.A.Y, R.B.X, 1, buf);
   end;

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  Constructor TMyApplication.Init;
    var
      md : PMyDialog;
      i  : longint;

    begin
      Inherited Init;
      i := 0;
      md := New ( PMyDialog, Init ( 'Progress Demo', 50000));
      md^.SetHitAnyKeyMode(mdBreak,true);
      md^.SetHitAnyKeyMode(mdDone,true);
     repeat
        inc(i);
        md^.Update(i);
      until (md^.Status = mddone) or (md^.Status=mdBreak);
      Dispose(md, done);
    end;

begin
  mydemo.Init;
  mydemo.Run;
  mydemo.Done;
end.
