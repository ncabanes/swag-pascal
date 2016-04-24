(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0118.PAS
  Description: Resource Expert: What It Is and How to I
  Author: SWAG SUPPORT TEAM
  Date: 02-21-96  21:04
*)


Resource Expert: what it is and how to install and use it.


What is the Resource Expert

The Resource Expert is a Delphi expert add-on that is available
as a part of the Delphi Rad Pack.  The expert assists the
programmer in porting existing projects to Delphi by converting
dialog and menu resource scripts intended for use in traditional
Windows applications.  Dialog resources and their contents are
converted to Delphi forms with the analogous controls converted
to Delphi components.


How to install the Resource Expert

The Resource Expert is installed via the Delphi Rad Pack's
Resource Workshop 4.5 install procedure.  Once installed, it is
incorporated into the Delphi component library and is available
as an option on the Delphi Help Menu or via the Experts page of
the Forms Gallery dialog.  Installation of the Resource Expert
files may be installed from within the Windows environment or
from the command line under Windows 95 or Windows NT.


To install the Resource Expert files from within Windows,

  1) Begin the installation procedure for Borland Resource
     Workshop.
  2) On the third dialog, entitled 'Resource Workshop - Resource
     Expert Options', ensure that the 'Install Resource Expert'
     check box is checked.
  3) The 'Install to:' entry indicates the destination directory
     for the Resource Expert files, indicating C:\DELPHI\RCEXPERT
     by default.  Change this entry as needed.
  4) Proceed with the rest of the Resource Workshop installation
     process as normal.

To install the Resource Expert files from the command line, type
the following commands,

  1) MD C:\DELPHI\RCEXPERT
  2) CD C:\DELPHI\RCEXPERT
  3) E:\INSTALL\RW\UNPAQ -X E:\INSTALL\RW\RESEXP.PAK

Note: The last command above assumes that the E: drive is a
CD-ROM drive containing the Rad Pack Installation CD.


Once the installation of the Resource Expert files is completed,
the Delphi Component Library must be recompiled.  To do this,

  1) Load Delphi.
  2) Select Options|Install Components.
  3) Click the Add... button.
  4) When the Add Module dialog appears, enter the full path name
     of the rcexpert.pas file or find the file via the Browse...
     button.
  5) Finally, choose the OK button on the Install Components
     Dialog.



How to use the Resource Expert

To convert a resource script, all source files normally required
to compile the script must be present.  This would include .RC,
.MNU, or .DLG file(s) and any .H or .PAS include files they refer
to.  Resource scripts typically use WINDOWS.H and BWCC.H.  These
files are usually located in directories such as \BC4\INCLUDE or
\BP7\UNITS.  The Resource Expert supports the RC language
extensions defined by Resource Workshop.

Again, the Resource Expert may be invoked via the Help|Resource
Expert menu option or via the Experts page of the Forms Gallery
dialog.  The latter will appear if the 'Use on new form' check
box is checked on the Preferences page of the Environment Options
dialog.

Once the Resource Expert has been invoked, click the 'Next'
button to bypass the page that introduces the expert to the user.
The second page of the expert allows the user to select the
resource scripts to convert.  A number of scripts may be chosen
provided that they all reside in the same directory.  The
particular type of script to view (.RC, .DLG or .MNU) can be
selected via the 'List Files of Type' combo box.  After selecting
the scripts to convert, click the 'Next' button again.  The third
page presents a single 'Include Path' edit box.  Enter the list
of directories containing .H, .INC, or .PAS include files used by
the resource scripts, (if any).  Each directory name should be
separated by a semicolon.  Again, click the 'Next' button to
continue.  On the fourth and final page of the expert, the
'Convert' button appears.  Clicking it begins the actual
conversion process.  If the resources script contain many
dialogs, the 'Show all forms' check box may be un-checked in
order to speed the conversion process and to minimize impact on
Windows system resources.

If a syntax error is encountered during the conversion process,
the erroneous statement will be discarded and conversion will
resume at the next statement or block.  Errors will be noted in
the log file ERRLOG.TXT and displayed in a Delphi editor window.

Once the conversion process is complete, separate forms for each
dialog resource will have been created.  For menu resources, a
simple form containing the converted menu component will have
been created.  If a project was active before the conversion
began, the converted forms are added to the project.  Each form
may now be used and modified as would any Delphi form.

