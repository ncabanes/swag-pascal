(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0095.PAS
  Description: Printing a TEditWindow
  Author: BRAD PRENDERGAST
  Date: 05-30-97  18:17
*)

{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

 Program Name : EdPrint.Pas
 Written By   : Brad Prendergast
 E-Mail       : mrealm@ici.net
 Web Page     : http://www.ici.net/cust_pages/mrealm/BANDP.HTM
 Program
 Compilation  : Borland Turbo Pascal 7.0

 Program Description :
  This demonstration shows how to print the contents a TEditWindow. A
  TEditWindow  utilizes a TEditor, the main variables within the TEditor
  are buffer ( array[0..65516] of char; this is where the buffer stores the
  text contents of the window), curptr (word; this is the current position of
  the cursor in the buffer, gaplen (word; gap between the beginning and
  ending of the buffer) and buflen ( word; the number of characters within
  the buffer).  Once executed this demo will open an editor window.  Type
  data into this window and then select print from the menubar.  The output
  will be placed into a text file.  I developed this to print the contents
  of an active editor window to a printer, but for demo purposes it goes to
  a text file. Any comments/questions please e-mail me.

 =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

  {This is the standard set of compiler directives I opt to use}
{$define debug}
{$define error_checking}
  {$ifdef error_checking}
    {$i+}  {l i/o checking            }
    {$q+}  {l overflow checking       }
    {$r+}  {l range checking          }
    {$s+}  {l stack overflow checking }
  {$else}
    {$i-}  {l i/o checking            }
    {$q-}  {l overflow checking       }
    {$r-}  {l range checking          }
    {$s-}  {l stack overflow checking }
  {$endif}
{$undef error_checking}
  {$ifdef debug}
    {$d+}  {g debug information              }
    {$l+}  {g local symbol information       }
    {$y+}  {g symbolic reference information }
  {$else}
    {$d-}  {g debug information              }
    {$l-}  {g local symbol information       }
    {$y-}  {g symbolic reference information }
  {$endif}

{$a+}  {g align data}
{$b-}  {l short circuit boolean evaluation   }
{$e-}  {g disable emulation                  }
{$f+}  {l allow far calls                    }
{$g+}  {g generate 80286 code                }
{$n-}  {g disable numeric processing         }
{$p+}  {g enable open parameters             }
{$o+}  {g overlay                            }
{$t-}  {g type @ operator                    }
{$v+}  {l var string checking                }
{$x+}  {g extended syntax enabled            }

  uses
    App, Editors, Memory, Objects, Menus, Views, Drivers;

{ -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }

  const
    outfile = 'output.txt';
    cmprint = 101;

{ -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }

  type
    TDemoApp = object (TApplication)
             p       :  PEditWindow;
             Constructor Init;
             Procedure   InitMenuBar;Virtual;
             Procedure   HandleEvent ( var event : Tevent);Virtual;
             Procedure   PrintWindow;
               end;

{ -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }

  var
    Demoapp :  TDemoapp;

{ -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }

  Constructor TDemoApp.Init;
    var
      r : Trect;
    Begin
      MaxHeapSize :=  2048;  (* for a  32k buffer for editors *)
      EditorDialog := StdEditorDialog;
      inherited init;
      GetExtent(r);
      p := New(PEditWindow, Init (r, '', 1));
      Insertwindow ( p );
    End;

{ -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }

  Procedure TDemoApp.InitMenuBar;
    var
     r : TRect;
    Begin
      GetExtent ( r );
      r.b.y := r.a.y + 1;
          menubar := new ( PMenuBar, init ( r, newmenu (
      newsubmenu ( '~D~emo', hcnocontext, newmenu (
         newitem ( '~P~rint', '', kbnokey, cmprint, hcnocontext,
                nil)) , nil ) )));
    End;

{ -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }

  Procedure TDemoapp.HandleEvent ( var Event : TEvent);
    Begin
      Inherited HandleEvent ( event );
      if ( event.what = evcommand ) then
        begin
          case ( event.command ) of
            cmprint : PrintWindow;
          end;
        end;
      ClearEvent (event);
    End;

{ -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }
  Procedure TDemoApp.PrintWindow;
    const
      fn = 'outfile.txt';
    var
      t     : text;
      count : longint;
      c : word;
    Begin
      Assign ( t, fn);
      Rewrite (t);
      count := -1;
      c := 0;
      Repeat
        inc (count, 1);
        inc ( c, 1 );
        if ( count = p^.editor^.curptr ) then count := count + p^.editor^.gaplen;
        write ( t, p^.editor^.buffer^[ count ]);
      Until ( c = p^.editor^.buflen );
      close (t);
    End;
{ -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- }

Begin
  DemoApp.Init;
  DemoApp.Run;
  DemoApp.Done;
End.
