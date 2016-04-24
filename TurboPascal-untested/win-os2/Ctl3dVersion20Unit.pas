(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0047.PAS
  Description: CTL3D Version 2.0 Unit
  Author: ANDREAS FURRER
  Date: 11-26-94  04:56
*)

(**************************************************)
(*                                                *)
(*   Unit CTL3D - Version 2.0                     *)
(*                                                *)
(*   for use with CTL3D.DLL from Microsoft        *)
(*                                                *)
(*   Supplied by Andreas Furrer                   *)
(*                                                *)
(**************************************************)

unit Ctl3D;

interface

uses WinTypes;

(* Ctl3dSubclassDlg3d flags *)
const Ctl3d_Buttons      = $0001;
      Ctl3d_Listboxes    = $0002;
      Ctl3d_Edits        = $0004;
      Ctl3d_Combos       = $0008;
      Ctl3d_StaticTexts  = $0010;
      Ctl3d_StaticFrames = $0020;
      Ctl3d_NoDlgWindow  = $00010000;

      Ctl3d_All          = $ffff;


const wm_DlgBorder       = wm_User+3567;
      (* WM_DLGBORDER PInteger(lParam)/\ return codes *)
      Ctl3d_NoBorder     = 0;
      Ctl3d_Border       = 1;

      wm_DlgSubclass     = wm_User+3568;
      (* WM_DLGSUBCLASS PInteger(lParam)/\ return codes *)
      Ctl3d_NoSubclass   = 0;
      Ctl3d_Subclass     = 1;


function Ctl3dSubclassDlg(HWindow : HWnd; GrBits : word) : bool;
function Ctl3dSubclassDlgEx(HWindow : HWnd; GrBits : longint) : bool;
function Ctl3dGetVer : word;
function Ctl3dEnabled : bool;
function Ctl3dCtlColor(DC : HDC; Color : TColorRef) : HBrush;
{ARCHAIC, use Ctl3dCtlColorEx}
function Ctl3dCtlColorEx(Message, wParam : word; lParam : longint) : HBrush;
function Ctl3dColorChange : bool;
function Ctl3dSubclassCtl(HWindow : HWnd) : bool;
function Ctl3dDlgFramePaint(HWindow : HWnd; Message, wParam : word;lParam :
longint) : longint;
function Ctl3dAutoSubclass(Instance : THandle) : bool;
function Ctl3dRegister(Instance : THandle) : bool;
function Ctl3dUnregister(Instance : THandle) : bool;
(* begin DBCS: far east short cut key support *)
procedure Ctl3dWinIniChange;
(* end DBCS *)


implementation

function  Ctl3dGetVer;       external 'Ctl3d' index 1;
function  Ctl3dSubclassDlg;  external 'Ctl3d' index 2;
function  Ctl3dSubclassCtl;  external 'Ctl3d' index 3;
function  Ctl3dCtlColor;     external 'Ctl3d' index 4;
function  Ctl3dEnabled;      external 'Ctl3d' index 5;
function  Ctl3dColorChange;  external 'Ctl3d' index 6;
function  Ctl3dRegister;     external 'Ctl3d' index 12;
function  Ctl3dUnregister;   external 'Ctl3d' index 13;
function  Ctl3dAutoSubclass; external 'Ctl3d' index 16;
function  Ctl3dCtlColorEx;   external 'Ctl3d' index 18;
function  Ctl3dDlgFramePaint;external 'Ctl3d' index 20;
function  Ctl3dSubclassDlgEx;external 'Ctl3d' index 21;
procedure Ctl3dWinIniChange ;external 'Ctl3d' index 22;

end.


