(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0031.PAS
  Description: CTL3D And BORDLG mix
  Author: NEIL GORIN
  Date: 08-24-94  13:26
*)

{
Some time back, I asked if it was possible to combine CTL3D with BORDLG,
with the resounding opinion that it wasn't possible to go all the way
and provide a 3d dialog border, although you could have 3d controls
in a bordlg using the CTL3dSubClassDlg command.

After much head scratching and many false starts, you'll find that
the below unit provides just what I'd been trying to do - i.e.
fully combine BORDLG with CTL3D.

Basically, all you have to do is add BWCC3D to the USES clause of
your main source file and add the command KILLBWCCCTL3D just before
your program shuts down - for example before HALT instructions
or before <MYAPP>.DONE seems to work.  You'll then have to run
Resource Workshop, change the class of your dialogues
from BORDLG to BORDLG_CTL3D and make sure you include CTL3D.DLL
with your application.  BORDLG_CTL3D dialogues have the CS_SAVEBITS
flag set, so they save the area beneath them like standard & CTL3D
dialogue boxes.

Comments and suggestions appreciated, and appologies for the way
that this message may have been chopped up.

Neil Gorin
neil.gorin@nildram.com

================== BWCC3D.PAS ====================}

Unit BWCC3d;

{********************************************************************}
{ BWCC3D.TPW - Replaces CTL3D.TPW                                    }
{ Based on CTL3D.PAS by Andreas Furrer                               }
{                                                                    }
{ Created 2nd June 1994, Neil Gorin                                  }
{ Internet: neil.gorin@nildram.com                                   }
{ Post: 4 Rookwood Drive, Stevenage, Herts. SG2 8PJ ENGLAND          }
{ Telephone: (UK) +44 438 362671   (GMT Evenings and Weekends only)  }
{                                                                    }
{ Purpose:                                                           }
{                                                                    }
{ Allows CTL3D frame and effects on BORDLG's                         }
{                                                                    }
{ Use:                                                               }
{                                                                    }
{ 1: If you currently have CTL3D in your "uses" clause, remove it as }
{    BWCC3D contains all the functionality of CTL3D.  Remove any     }
{    references to CTL3DREGISTER, CTL3DUNREGISTER and                }
{    CTL3DAUTOSUBCLASS from your program.                            }
{                                                                    }
{ 2: Add BWCC3D to your "uses" clause.                               }
{                                                                    }
{ 3: Where your program ends, add the command: KILLBWCCCTL3D         }
{    For example, if an ObjectWindows app, before <APPNAME>.DONE     }
{                                                                    }
{ 4: With Resource Workshop, change the class name of all your       }
{    dialogues from BORDLG to BORDLG_CTL3D                           }
{                                                                    }
{********************************************************************}
{                                                                    }
{ Tips:                                                              }
{                                                                    }
{    o  If you have version 2.0 of BWCC.DLL (as supplied with BC++4) }
{       you can change the line reading:                             }
{                                                                    }
{           GetClassInfo(Hinstance,'Bordlg',Gorin);                  }
{       to  GetClassInfo(Hinstance,'Bordlg_gray',Gorin);             }
{                                                                    }
{       This will result in a solid grey background as opposed to    }
{       to the normal stippled BWCC effect.                          }
{                                                                    }
{    o  If you only want the 3D effect frame and not the 3D          }
{       controls, remove the line reading:                           }
{                                                                    }
{           WM_INITDIALOG: CTL3DSUBCLASSDLG(Hwindow,CTL3d_ALL);      }
{                                                                    }
{********************************************************************}
{ Your comments are welcome - No strings are attached to the use or  }
{ distribution of this file.                                         }
{********************************************************************}

Interface
Uses Wintypes,winprocs,bwcc,ctl3d;

const Ctl3d_Buttons      = $0001;
      Ctl3d_Listboxes    = $0002;
      Ctl3d_Edits        = $0004;
      Ctl3d_Combos       = $0008;
      Ctl3d_StaticTexts  = $0010;
      Ctl3d_StaticFrames = $0020;
      Ctl3d_All          = $ffff;

function Ctl3dGetVer : word;
function Ctl3dSubclassDlg(HWindow : HWnd; GrBits : word) : bool;
function Ctl3dSubclassDlgEx(HWindow : HWnd; GrBits : word) : bool;
function Ctl3dSubclassCtl(HWindow : HWnd) : bool;
function Ctl3dCtlColor(DC : HDC; Color : TColorRef) : HBrush;
function Ctl3dEnabled : bool;
function Ctl3dColorChange : bool;
function Ctl3dRegister(Instance : THandle) : bool;
function Ctl3dUnregister(Instance : THandle) : bool;
function Ctl3dAutoSubclass(Instance : THandle) : bool;
function Ctl3dCtlColorEx(Message, wParam : word;
                         lParam : longint) : HBrush;
function Ctl3dDlgFramePaint(Hwindow:Hwnd; Message, wparam:word;
                            Lparam:Longint):Longint;
Procedure KillBwccCtl3d;

Implementation

function Ctl3dGetVer;       external 'Ctl3d' index 1;
function Ctl3dSubclassDlg;  external 'Ctl3d' index 2;
function Ctl3dSubclassCtl;  external 'Ctl3d' index 3;
function Ctl3dCtlColor;     external 'Ctl3d' index 4;
function Ctl3dEnabled;      external 'Ctl3d' index 5;
function Ctl3dColorChange;  external 'Ctl3d' index 6;
function Ctl3dRegister;     external 'Ctl3d' index 12;
function Ctl3dUnregister;   external 'Ctl3d' index 13;
function Ctl3dAutoSubclass; external 'Ctl3d' index 16;
function Ctl3dCtlColorEx;   external 'Ctl3d' index 18;
function Ctl3dDlgFramePaint;external 'Ctl3d' index 20;
function Ctl3dSubclassDlgEx;external 'Ctl3d' index 21;


Procedure KillBwccCtl3d;
{********************************}
{ It is ESSENTIAL that you call  }
{ this before your program ends  }
{ as otherwise your User Heap    }
{ will gradually disappear!      }
{********************************}
begin
     UnRegisterclass('BORDLG_CTL3D',hinstance);
     CTL3DUnregister(Hinstance);
end;

function Ctl3dBWCC(HWindow: hwnd; Message, WParam: word;
                   LParam: longint): longint; export;
{***********************************}
{ Takes control before the          }
{ standard BWCCDEFDLGPROC to        }
{ paint frame and subclass controls }
{ will gradually disappear!         }
{***********************************}
Const WM_PAINTIT=15000;
var tms:tmsg;
begin
    If PeekMessage(tms,Hwindow,WM_Paintit,WM_Paintit,PM_REMOVE) then
                                    Ctl3dDlgFramePaint(Hwindow,0,0,0);
    Case message of
       WM_SETTEXT,
       WM_NCPAINT,
       WM_NCACTIVATE: PostMessage(HWindow,WM_PAINTIT,0,0);
       WM_INITDIALOG: CTL3DSUBCLASSDLG(Hwindow,CTL3d_ALL);
    end;
    Ctl3dBwcc:=BWCCDEFDLGPROC(Hwindow,message,wparam,lparam);
end;

{ This is run automatically *before* your program gets control }

var Gorin:TwndClass;
begin
     CTL3DRegister(Hinstance);
     CTL3DAutoSubclass(Hinstance);
     GetClassInfo(Hinstance,'Bordlg',Gorin);  {See above for BWCC 2.0 note}
     Gorin.Style:=gorin.style or cs_savebits; {Saves bitmap of background}
     Gorin.LPSZCLASSNAME:='BORDLG_CTL3D';
     Gorin.lpfnwndproc:=@CTL3dBWCC;
     Registerclass(gorin);
end.

