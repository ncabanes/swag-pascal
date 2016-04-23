{-----------------------------------------------------------------------------}
{ Design-time testing of TCommonDialog component descendants.                 }
{ Copyright 1996, Brad Stowers.  All Rights Reserved.                         }
{ This component can be freely used and distributed in commercial and private }
{ environments, provied this notice is not modified in any way and there is   }
{ no charge for it other than nomial handling fees.  Contact me directly for  }
{ modifications to this agreement.                                            }
{-----------------------------------------------------------------------------}
{ Feel free to contact me if you have any questions, comments or suggestions  }
{ at bstowers@pobox.com or 72733,3374 on CompuServe.                          }
{ The lateset version will always be available on the web at:                 }
{   http://www.pobox.com/~bstowers/delphi/                                    }
{-----------------------------------------------------------------------------}
{ Date last modified:  May 17, 1997                                           }
{-----------------------------------------------------------------------------}

{ ----------------------------------------------------------------------------}
{ TBrowseDirectory v1.02                                                      }
{ ----------------------------------------------------------------------------}
{ Description:                                                                }
{   A component editor that allows testing of the TCommonDialog descendants   }
{   at design time.  This allows you to set the varios options and then view  }
{   the results without having to compile and run your application.  The name }
{   "Component Editor" is a bit of a misnomer for this, but that's what it's  }
{   called.  We add a menu item, 'Test Dialog', to the context menu (right    }
{   click) the displays the dialog, and add the same functionality for double }
{   clicking on the component.  If the TCommonDialog class had a pure virtual }
{   method "Execute" that each descendant overrode like it should, this would }
{   be much easier.  Because Execute is not defined in the ancestor, we have  }
{   register for each component type we want to add this to instead of just   }
{   registering it for TCommonDialog.  Beginning object oriented programmers  }
{   learn from this:  Just because you can't see a need for it, doesn't mean  }
{   that there isn't one.                                                     }
{ ----------------------------------------------------------------------------}
{ Revision History:                                                           }
{ 1.00:  + Initial release                                                    }
{ 1.01:  + Changed 'AnsiString' to 'String'.  Will now compile with no        }
{          changes under Delphi 1.x.                                          }
{ 1.02:  + Updated for Delphi 3 compatibility.  If using with Delphi 3, the   }
{          "Test" item will now show up on all TCommonDialog descendant       }
{          components because Borland finally added an abstract Execute       }
{          method to it.                                                      }
{ ----------------------------------------------------------------------------}

unit DlgTest;

interface

uses DsgnIntf, Dialogs;

type
  TCommonDialogEditor = class(TDefaultEditor)
  public
    procedure ExecuteVerb(Index : Integer); override;
    function GetVerb(Index : Integer): string; override;
    function GetVerbCount : Integer; override;
    procedure Edit; override;
  end;

{$IFDEF VER100}
  { Just redeclare it so we can get at the Execute method, which is protected. }
  TMyCommonDialog = class(TCommonDialog)
  end;
{$ENDIF}

procedure Register;

implementation

{$IFDEF VER100}
uses
  ExtDlgs;
{$ENDIF}


procedure TCommonDialogEditor.ExecuteVerb(Index: Integer);
begin
  if Index <> 0 then Exit; { We only have one verb, so exit if this ain't it }
  Edit;  { Invoke the Edit function the same as if double click had happened }
end;

function TCommonDialogEditor.GetVerb(Index: Integer): String;
begin
  Result := 'Test Dialog';  { Menu item caption for context menu }
end;

function TCommonDialogEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

procedure TCommonDialogEditor.Edit;
begin
{$IFDEF VER100}
  if Component is TCommonDialog then
    TMyCommonDialog(Component).Execute
{$ELSE}
  if Component is TColorDialog then
    TColorDialog(Component).Execute
  else if Component is TFindDialog then
    TFindDialog(Component).Execute
  else if Component is TReplaceDialog then
    TReplaceDialog(Component).Execute
  else if Component is TFontDialog then
    TFontDialog(Component).Execute
  else if Component is TOpenDialog then
    TOpenDialog(Component).Execute
  else if Component is TSaveDialog then
    TSaveDialog(Component).Execute
  else if Component is TPrintDialog then
    TPrintDialog(Component).Execute
  else if Component is TPrinterSetupDialog then
    TPrinterSetupDialog(Component).Execute;
{$ENDIF}
end;

procedure Register;
begin
  RegisterComponentEditor(TCommonDialog, TCommonDialogEditor);
end;


end.
