(*
  Category: SWAG Title: FREQUENTLY ASKED QUESTIONS/TUTORIALS
  Original name: 0038.PAS
  Description: SEC14-BORLAND
  Author: SWAG SUPPORT TEAM
  Date: 02-28-95  10:07
*)

SECTION 14 - Windows API

This document contains information that is most often provided
to users of this section.  There is a listing of common
Technical Information Documents that can be downloaded from the
libraries, and a listing of the five most frequently asked
questions and their answers.

TI607    How to print in windows.  

Q.   "How can I enable or disable a particular control in a
     dialog box?"

A.   Use the EnableWindow(Wnd: Hwnd, Enable: Bool) API function. 
     It takes two parameters, the handle to the window (remember
     a control is a window) to be enabled/disabled and a boolean
     value - True for enable and False for disable.

Q.   "How do I obtain the handle or ID of a control?" 

A.   If you have a pointer to a control object, OWL will give you
     the window handle automatically through the HWindow field; 
     PointerToMyControl^.HWindow is the window handle.

     If you know the handle of a control, you can obtain the ID
     by calling the GetDlgCtrlID() API function:

        ControlID := GetDlgCtrlID(ControlHandle);

     If you don't have a pointer to your control, but know the ID
     of a control, you can obtain the handle by calling the
     GetDlgItem() API function:

        ControlHandle := GetDlgItem(DialogHandle, ControlID);

Q.   "How do I unload an abnormally terminated program's dlls?"

A.   By using GetModuleHandle to return the dll's handle, and
     then call freelibrary until GetModuleHandle returns 0.  If a
     dll has loaded another dll, unload the child dll first.

Q.   "How do I hide a minimized icon without taking the program
     off the task list?"

A.   Move the icon off the display using SetWindowPos or
     MoveWindow and give negative coordinate values beyond the
     screen.

Q.   "How do I change a dll's data segment from fixed to
     movable?"

A.   Call GlobalPageUnloch(DSEG) in the outer block of your dll. 
     This will work providing the dll does not contain code that
     requires a page locked data segment.



