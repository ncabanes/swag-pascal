
Delphi employs a number of files for its configuration, some
global to the Delphi environment, some project specific.  Chief
among all the configuration files is DELPHI.INI.  DELPHI.INI
resides in the Windows directory and contains most of the
configurable items to be found within Delphi.  Being the largest
Delphi configuration file, DELPHI.INI contains settings to
control the Delphi speed bar, component palette, component
library, gallery, installed experts, editor, printing, tools menu
and all the environment options found on the Environment Options
dialog.  This document will explore DELPHI.INI in depth.

DELPHI.CBT is a copy of DELPHI.INI (minus the ReportSmith
section) that is installed along with Delphi and may serve as a
sort of backup for restoring the original Delphi setup.  It
resides in the Windows directory along with DELPHI.INI.  Below is
the ReportSmith section and its one entry that should be placed
in a DELPHI.INI created from DELPHI.CBT.

[ReportSmith]
ExePath=C:\RPTSMITH


Delphi also makes use of Desktop (.DSK) files.  Desktop files,
like most Delphi configuration files, are formatted in the same
manner as .INI files, with section headers and individual
settings in each section.  The purpose of desktop files is to
retain the appearance and content of the Delphi desktop between
sessions or between projects.  Each desktop file contains
information regarding the presence and appearance of the Delphi
main window, the Object Inspector, the Alignment Palette, the
Project Manager, and the Watch, Breakpoint, CallStack, and
component list windows.  Also kept in each desktop file is the
number of editor windows open as well as the names, number and
order of files open in each editor window.

If the 'Desktop files' check box (on the Preferences page of the
Environment Options dialog) is checked, Delphi will automatically
create desktop files for each project closed and saved.  Each
desktop file carries the same root name as the saved project
file.  If no project is active when Delphi exits, a default
desktop file, DELPHI.DSK, is created.  The last active project
determines which desktop file Delphi loads at startup.  Again,
if no project was active when Delphi exited last, then DELPHI.DSK
is loaded.  While project specific desktop files reside in the
same directory with the corresponding project, DELPHI.DSK resides
in the \DELPHI\BIN directory.  The PrivateDir setting in the
Globals section of DELPHI.INI may be used to relocate DELPHI.DSK
to a different location.


Option files (.OPT) are another INI-like file in which Delphi
maintains values directly corresponding to those settings on the
Compiler, Linker, and  Directories/Conditionals pages of the
Project Options dialog.  Each of these pages has a corresponding
section in the option file and each setting has a individual
entry in that section.  Each option file also retains the last
parameter string entered via the Run Parameters dialog.  An
option file is created for each project saved.  Like .DSK files,
the root name of the .OPT file is the same as its corresponding
project and reside in the same directory as that project.

A default option file, DEFPROJ.OPT, is created if the Default
check box of the Project Options dialog is checked.  The settings
in DEFPROJ.OPT serve as the default project settings each time a
new project is created.


Additionally, the Delphi command line compiler, DCC.EXE, supports
the use of the configuration file DCC.CFG.  DCC.CFG is a text
file opened when the command line compiler starts and is used in
addition to options entered on the command line.  Command line
options may be placed in DCC.CFG, each on a separate line.  When
DCC starts, it looks for DCC.CFG in the current directory.  If it
is not found there, the directory in which DCC.EXE resides is
then searched.  A sample DCC.CFG follows:

/b
/q
/v
/eC:\DELPHI\WORK

The above settings instruct the command line compiler to build
all units (/b), compile without displaying file names and line
numbers (/q), append debug information to the .EXE (/v), and
place the compiled units and exEcutable in the C:\DELPHI\WORK
directory (/eC:\DELPHI\WORK).  The contents of the installed
DCC.CFG are included below to serve in restoring it should it be
deleted or damaged.

/m
/cw
/rD:\DELPHI\LIB
/uD:\DELPHI\LIB
/iD:\DELPHI\LIB


STDVCS.CFG is a file installed with the Client/Server of Delphi,
but is only used in conjunction with the Version Control manager
DLL.  The contents of the installed STDVCS.CFG are included here
to serve in restoring it should it be deleted or damaged.

NODELETEWORK WRITEPROTECT
NOCASE VCSID

COMMENTPREFIX .PAS = "{ "
COMMENTPREFIX .PRJ = "{ "

NOEXPANDKEYWORDS .FRM
NOEXPANDKEYWORDS .EXE
NOEXPANDKEYWORDS .DLL
NOEXPANDKEYWORDS .DOC
NOEXPANDKEYWORDS .ICO
NOEXPANDKEYWORDS .BMP

Lastly, MULTIHLP.INI is a file Delphi uses to provide
context-sensitive help across multiple help files.  This file
should not be modified; doing so may cause the Delphi Help system
to behave erratically.  The contents of the installed
MULTIHLP.INI are included here to serve in restoring it should it
be deleted or damaged.

[Index Path]
DELPHI.HLP=C:\DELPHI\BIN
WINAPI.HLP=C:\DELPHI\BIN
CWG.HLP=C:\DELPHI\BIN
CWH.HLP=C:\DELPHI\BIN
LOCALSQL.HLP=C:\DELPHI\BIN
VQB.HLP=C:\DELPHI\BIN
SQLREF.HLP=C:\IBLOCAL\BIN
WISQL.HLP=C:\IBLOCAL\BIN
BDECFG.HLP=C:\IDAPI
RPTSMITH.HLP=C:\RPTSMITH
RS_DD.HLP=C:\RPTSMITH
SBL.HLP=C:\RPTSMITH
RS_RUN.HLP=C:\RPTSMITH
DBD.HLP=C:\DBD


Note:

What follows below is a comprehensive dissection of the
DELPHI.INI file.  In order to save space, a few conventions were
observed in the describing possible values for settings.

Where only one of a limited set of values is applicable, a pipe
symbol is used to separate each of the possible value, e.g.:

MapFile=0|1|2|3

allows only the values 0, 1, 2, or 3

Where a single value within a range is applicable, the range of
values is presented inside brackets with the minimum and maximum
values separated by two periods, e.g.:

GridSizeX=[2..128]

permits any value between 2 and 128, inclusively.

=================================================================

Section: [Globals]  -  The Globals section contains settings not
         included in other sections and that have an effect on
         Delphi as a whole.  Items in the Globals section may be
         changed only by editing DELPHI.INI.
-----------------------------------------------------------------

PrivateDir=

  This item controls where Delphi both creates and locates
  the files DELPHI.DSK, DELPHI.DMT, DEFPROJ.OPT and STDVCS.CFG.
  The default location is the \DELPHI\BIN directory.  If Delphi
  is run from a read-only directory (or from a CD-ROM) this item
  should be set to a writeable directory, either on a network or
  local drive.  This item should contain a fully qualified path,
  including the drive letter.  Example:

    PrivateDir=J:\USERS\JSMITH   ; Private network directory


HintColor=

  This item controls the color of the fly-by hint window for the
  Delphi IDE.  The value may be a decimal or hex constant, or one
  of the symbolic color constants defined in VCL (e.g. clCyan).
  Note that the text in the hint window is always painted using
  clWindowText.  The default value is clYellow.

PropValueColor=

  This item controls the color of the text in the right-hand
  (value) pane of the Object Inspector. The value may be a
  decimal or hex constant, or one of the symbolic color constants
  defined in VCL (e.g. clBlue).  The default value is
  clWindowText.



Section: [Library]  -  The Library section contains entries for
         those settings found on the Library page of the
         Environment Options dialog (accessed via
         Options|Environment).  The options in this section take
         effect when the Options|Rebuild Library menu option is
         chosen.
-----------------------------------------------------------------

SearchPath=

  Specifies search paths where the compiler can find the units
  needed to build the component library.  Path names should be
  listed consecutively, separated by a semicolon.  This entry is
  changed via the 'Library Path' combo box.  Example:

    SearchPath=D:\DELPHI\LIB;d:\delphi\rcexpert


ComponentLibrary=

  Specifies the name of the active component library.  This item
  is changed via the Options|Open Library menu option.  It may
  also be changed from the 'Library filename' edit of the Install
  Components dialog (accessed via Options|Install Components).
  Example:

    ComponentLibrary=D:\DELPHI\BIN\REXPERT.DCL

SaveLibrarySource=0|1

  Indicates whether Delphi saves the source code for the
  component library when installing new components or rebuilding
  it via Options|Rebuild Library.  A setting of 1 causes the
  project source to be saved using the library file's root name
  with a .DPR extension.  The default value is 0.  This setting
  is changed via the 'Save library source code' check box.


MapFile=0|1|2|3

  Determines the type of map file produced, if any, when the
  component library is rebuilt. The map file is placed in the
  same directory as the library, and it has a .MAP extension.
  The default value is 0.  This setting is changed via the
  'Map file' radio button group.

  Option        Effect
  ------------  ------
  0 - Off	Does not produce map file.
  1 - Segments	Linker produces a map file that includes a list
                of segments, the program start address, and any
                warning or error messages produced during the
                link.
  2 - Publics	Linker produces a map file that includes a list
                of segments, the program start address, any
                warning or error messages produced during the
                link, and a list of alphabetically sorted public
                symbols.
  3 - Detailed	Linker produces a map file that includes a list
                of segments, the program start address, any
                warning or error messages produced during the
                link, a list of alphabetically sorted public
                symbols, and an additional detailed segment map.
                The detailed segment map includes the address,
                length in bytes, segment name, group, and module

LinkBuffer=0|1

  Specifies the location of the link buffer.  A setting of 1
  causes Delphi to use available disk space for the link buffer;
  0 causes the use of available memory.  The default value is
  0.  This setting is changed via the 'Link Buffer' radio button
  group.


DebugInfo=0|1

  Determines whether the component library file is compiled and
  linked with debug information.  A setting of 1 causes the
  inclusion of debug information.  The default setting is 0.  The
  setting is changed via the 'Compile with debug info' check box.



Section: [Gallery]  -  The Gallery section controls the use and
         base location of the form and project galleries.  It
         contains those settings found in the Gallery: group box
         on the Preferences page of the Environment Options
         dialog.
-----------------------------------------------------------------

BaseDir=

  Points to the directory where Delphi attempts to find Gallery
  files.  To share a gallery directory with other users, set this
  item to point to a shared network directory.  This item
  should contain a fully qualified path, including the drive
  letter.  This entry may be changed only by editing DELPHI.INI.
  Example:

    BaseDir=D:\DELPHI\GALLERY

GalleryProjects=0|1

  Indicates whether Delphi displays the Browse Gallery dialog box
  when the File|New Project menu option is chosen.  A setting of
  1 causes the Browse Gallery dialog box to display.  The default
  setting is 0.  The setting is changed via the 'Use on New
  Project' check box.


GalleryForms=0|1

  Indicates whether Delphi displays the Browse Gallery dialog box
  when the File|New Form menu option is chosen.  A setting of 0
  prevents the Browse Gallery dialog box from displaying.  The
  default setting is 1.  The setting is changed via the 'Use on
  New Form' check box.



Section: [Experts]  -  The Experts section lists the Experts
         which Delphi will attempt to load and initialize upon
         startup.  Any value may be used on the left of the
         equals sign, as the item name is not interpreted.
         Borland recommends using a combination of the vendor
         name and the product name. Example:

  [Experts]
  ComponentWare.CommExpert=c:\delphi\cware\commexpt.dll
  CodeFast.TheExpert=c:\delphi\codefast\codefast.dll



Section: [ReportSmith]  -  The ReportSmith section contains just
         one entry which specifies the directory in which
         ReportSmith is installed.
-----------------------------------------------------------------

ExePath=

  ExePath indicates the location of RPTSMITH.EXE.  This entry is
  placed in DELPHI.INI at install time and may be changed only by
  editing DELPHI.INI.  Example:

    ExePath=D:\RPTSMITH



Section: [Session]  -  The Session section and its one entry
                       identify the active project when Delphi
                       was last closed.
-----------------------------------------------------------------

Project=

  Identifies the active project when Delphi was last closed.
  This setting is only meaningful if the DesktopFile setting in
  the AutoSave section is set to 1.  This setting also serves to
  identify the project's desktop file (using a .DSK extension).
  This setting is updated automatically when Delphi exits.
  Example:

    Project=D:\DELPHI\WORK\MAILAPP.DPR



Section: [MainWindow]  -  The MainWindow section defines
         characteristics of the Delphi main window as they relate
         to the speedbar and component palette.  The SpeedBar
         Layout section details the actual contents of the
         speedbar.  Likewise, the <libraryname>.Palette section
         details the actual contents of the component palette.
-----------------------------------------------------------------

Split=[-1..400]

  Indicates the horizontal position if the vertical bar
  separating the speedbar and component palette.  The default
  value is 183.  This setting is changed by moving the split bar
  with the mouse.


SpeedHints=0|1

  Determines whether hints are displayed as the mouse passes over
  buttons on the speedbar.  A setting of 0 prevents the display
  of speedbar hints.  The default setting is 1.  This setting is
  changed using the Show Hints menu option of the speedbar
  speedmenu.


PaletteHints=0|1

  Determines whether hints are displayed as the mouse passes over
  buttons on the palette.  A setting of 0 prevents the display
  of palette hinsts.  The default setting is 1.  This setting is
  changed using the Show Hints menu option of the palette
  speedmenu.


Speedbar=0|1

  When set to 0, prevents the display of the speedbar.  The
  default setting is 1.  This setting is changed via the
  View|Speedbar menu option or via the Hide option of the
  speedbar speedmenu.


Palette=0|1

  When set to 0, prevents the display of the component palette.
  The default setting is 1.  This setting is changed via the
  View|Component Palette menu option or via the Hide option of
  the component palette speedmenu.



Section: [Speedbar Layout]  -  The Speedbar Layout details the
         specific contents of the speedbar.  The contents of this
         section are changed via the Configure option of the
         speedbar speedmenu.
-----------------------------------------------------------------

Count=[0..52]

  Specifies the number of buttons on the speedbar.  The default
  is 14.


Button[0..51]=n,x,y

  This entry appears once for each button on the speedbar.  Each
  button entry is uniquely numbered, the first being Button0.
  The number n identifies a unique pre-defined id code.  The
  x value is a number specifying the horizontal position of the
  button on the speedbar.  The y value is a number specifying the
  vertical position of the button on the speedbar.  Below is a
  listing of the default speedbutton set and their corresponding
  menu options.

    Button0=30001,4,2        ; File|Open Project...
    Button1=30002,27,2       ; File|Save Project
    Button2=30007,4,25       ; File|Open File...
    Button3=30008,27,25      ; File|Save File
    Button4=30009,50,2       ; File|Add File...
    Button5=30010,50,25      ; File|Remove File...
    Button6=30069,79,2       ; View|Units...
    Button7=30070,102,2      ; View|Forms...
    Button8=30068,79,25      ; View|Toggle Form/Unit
    Button9=30004,102,25     ; File|New Form
    Button10=30090,131,2     ; Run|Run
    Button11=30093,154,2     ; Run|Program Pause
    Button12=30092,131,25    ; Run|Trace Into
    Button13=30091,154,25    ; Run|Step Over

Section: [Desktop]  -  The Desktop section contains a single
         entry that determines which desktop settings are saved
         when Delphi exits.  This section and its one entry is
         only meaningful if the DesktopFile entry in the AutoSave
         section is 1.
-----------------------------------------------------------------

SaveSymbols=0|1

  Determines if browser symbol information is saved along with
  Desktop information when Delphi exits.  This setting is changed
  via the 'Desktop contents:' radio button group box.  The
  default setting is 1.

  Option                   Effect
  ------                   ------
  0 - Desktop only         Saves directory information, open
                           files in the editor, and open windows.
  1 - Desktop and symbols  Saves desktop information and browser
                           symbol information from the last
                           successful compile.


Section: [AutoSave]  -  The Autosave section determines which
         files and options are saved automatically when the
         current project is run or when Delphi exits.  This
         section corresponds to the 'Autosave options:' group box
         of the Preferences page of the Environment Options
         Dialog.
-----------------------------------------------------------------

EditorFiles=0|1

  When set to 1, causes Delphi to save all modified files in the
  Code Editor when Run|Run, Run|Trace Into, Run|Step Over, or
  Run|Run To Cursor are chosen, or when Delphi exits.  The
  default setting is 0.  This setting is changed via the 'Editor
  files' check box on the Preferences page of the Environment
  Options Dialog.


DesktopFile=0|1

  When set to 0, prevents Delphi from saving the arrangement of
  the desktop when a project is closed or when Delphi exits.  The
  default setting is 1.  This setting is changed via the
  'Desktop' check box on the Preferences page of the Environment
  Options Dialog.

  Note: Further discussion regarding desktop files are discussed
  below under Desktop (.DSK) files.

Section: [FormDesign]  -  The FormDesgin section contains those
         settings that control the appearance and behavior of a
         forms grid at design time.  This section corresponds to
         the 'Form designer:' group box of the Preferences page
         of the Environment Options Dialog.
-----------------------------------------------------------------

DisplayGrid=0|1

  Determines the design time visibility of the dots that comprise
  the form grid.  A setting of 0 avoids grid display.  The
  default setting is 1.  This setting is changed via the 'Display
  grid' check box.


SnapToGrid=0|1

  Indicates whether components are automatically aligned with the
  grid when components are moved with the mouse.  A setting of 0
  avoids grid alignment.  The default setting is 1.  This setting
  is changed via the 'Snap to grid' check box.


GridSizeX=[2..128]

  Sets grid spacing in pixels along the x-axis.  The default
  value is 8.  This setting is changed via the 'Grid Size X'
  edit.


GridSizeY=[2..128]

  Sets grid spacing in pixels along the y-axis.  The default
  value is 8.  This setting is changed via the 'Grid Size Y'
  edit.


DefaultFont=

  This item controls the default font for new forms.  The name
  of the font, the font size, and optionally the style of the
  font may be entered, each separated by commas. (Supported font
  styles are "bold" and "italic.")  This setting may be changed
  only by editing DELPHI.INI.  Example:

    DefaultFont=MS Sans Serif, 8, bold, italic



Section: [Debugging]  -  The Debugging section contains those
         settings that control integrated debugging and the
         appearance of Delphi during project execution.  This
         section corresponds to the 'Debugging:' group box of the
         Preferences page of the Environment Options Dialog.

-----------------------------------------------------------------


IntegratedDebugging=0|1

  Allows or prevents the uses of the Delphi Integrated Debugger.
  A setting of 0 prevents integrated debugging.  The default
  setting is 1.  This setting is changed via the 'Integrated
  Debugging' check box.


DebugMainBlock=0|1

  When set to 1, causes the debugger to stop at the first unit
  initialization that contains debug information.  The default
  setting is 0.  This setting is changed via the 'Step program
  block' check box.


BreakOnExceptions=0|1

  When set to 1, stops the application when an exception is
  encountered and displays the following the exception class,
  exception message and the location of the exception.  When
  set to 0, exceptions do not stop the running application.
  The default setting is 1.  This setting is changed via the
  'Break on exception' check box.


MinimizeOnRun=0|1

  When set to 1, minimizes Delphi when the current project is
  executed.  The default is 0.  This setting is changed via the
  'Minimize on run' check box.


HideDesigners=0|1

  When set to 1, hides designer windows, such as the Object
  Inspector and Form window, while the application is running.
  The default setting is 1.  This setting is changed via the
  'Hide designers on run' check box.


NoResetWarning=0|1

  When set to 1, prevents Delphi from presenting a warning
  message when Program Reset is selected.  The default setting is
  0.  This setting may be changed only by editing DELPHI.INI.


Section: [Compiling]  -  The compiling section contains a single
         entry that determines whether the user is presented with
         a dialog that reports compiler progress.  This section
         corresponds to the 'Compiling:' group box of the
         Preferences page of the Environment Options Dialog.
-----------------------------------------------------------------

ShowCompilerProgress=0|1

  Specifies whether compilation progress is reported.  A setting
  of 1 causes Delphi to display a window detailing compilation
  progress.  The default setting is 0.  This setting is changed
  via the 'Show compiler progress' check box.



Section: [Browser]  -  The Browser section contains settings that
         are found on the Browser page of the Environment Options
         dialog.  These settings specify how ObjectBrowser
         functions and what symbol information is displayed.
-----------------------------------------------------------------

Filters=

  This setting determines which filters are active in the Object
  Browser.  The value is the sum of the values listed below for
  each filter desired.

    Value   Filter
    -----   ------
        2   Constants
        4   Types
        8   Variables
       16   Functions and Procedures
       32   Properties
      128   Inherited
      256   Virtuals only
     1024   Private
     2048   Protected
     4096   Public
     8192   Published

  The default setting is 15806, which activates all filters.
  Each filter corresponds to a check box in the 'Symbol filters:'
  group box.  For example, the following setting activates the
  Properties, Public and Published filters:

    Filters=12320  ; 8192 + 4096 + 32 = 12320


InitialView=1|2|3

  InitialView determines the type of information the browser
  displays when first opened.  The default setting is 2.  This
  setting is changed via the 'Initial view:' radio button group
  box.

    Value  Viewed
    -----  ------
        1  Units
        2  Objects
        3  Globals

Sort=0|1

  When set to 1, causes Delphi to display symbols in alphabetical
  order by symbol name.  When set to 0, symbols display in order
  of declaration.  The default setting is 0.  This setting is
  changed via the 'Sort always' check box.


QualifiedSymbols=0|1

  When set to 1, causes Delphi to display the qualified
  identifier for a symbol.  When set to 0, only the symbol name
  is displayed.  The default setting is 0.  This setting is
  changed via the 'Qualified symbols' check box.


CollapsedNodes=

  Specifies which branches of the object tree hierarchy are
  collapsed when the ObjectBrowser is started.  This entry is a
  list of class names, separated by separated by semicolons.
  This setting is changed via the 'Collapse Nodes:' combo box.
  Example:

    CollapsedNodes=Exception;TComponent


ShowHints=0|1

  Determines whether hints are displayed as the mouse passes over
  filter buttons.  A setting of 0 prevents the display of filter
  hints.  The default setting is 1.  This setting is
  changed using the Show Hints menu option of the ObjectBrowser
  speedmenu.

Section: [Custom Colors]  -  The Custom colors section lists up
         to sixteen user defined colors.  Each color is specified
         as a six-digit hexadecimal RGB value.  An unused color
         entry is indicated by the hexadecimal value FFFFFFFF.
         Entries in this section are created and updated via the
         Color dialog of any components Color property (accessed
         by double-clicking the entry area of the Color
         property).
-----------------------------------------------------------------

Color[A..P]=

  Specifies an individual RGB value for a user defined color.

Section: [Print Selection]  -  The Print Selection section
         contains those options that appear when the File|Print
         menu option is chosen.  These settings correspond to the
         options displayed in the 'Options:' group box.
-----------------------------------------------------------------

HeaderPage=0|1

  When set to 1, Delphi includes the name of the file, current
  date, and page number at the top of each page.  The default
  setting is 0.  This setting is changed via the 'Header/page
  number' check box.


LineNumbers=0|1

  When set to 1, Delphi places line numbers in the left margin of
  the printed output.  The default setting is 0.  This setting is
  changed via the 'Line numbers' check box.

SyntaxPrinting=0|1

  When set to 1, Delphi uses bold, italic, and underline
  characters to indicate elements with syntax highlighting.  When
  set to 0, Delphi uses no special formatting when printing.  The
  default value is 1.  This setting is changed via the 'Syntax
  print' check box.


UseColor=0|1

  When set to 1, causes Delphi to print colors that match colors
  on screen.  This option requires that the current printer
  support color.  The default value is 0.  This setting is
  changed via the 'Use Color' check box.


WrapLines=0|1

  When set to 1, causes Delphi to use multiple lines to print
  characters beyond the page width.  When set to 0, code lines
  are truncated and characters beyond the page width do not
  print.   The default value is 0.  This setting is changed via
  the 'wrap lines' check box.


LeftMargin=[0..79]

  Specifies the number of character spaces used as a margin
  between the left edge of the page and the beginning of each
  line.  The default value is 0.  This setting is changed via the
  'Left margin' edit.



Section: [Highlight]  -  The Highlight section contain those
         settings that determine the syntax and context specific
         colors used in the Code Editor.  The settings in this
         section are changed via the Editor Colors page of the
         Environment Options dialog.
-----------------------------------------------------------------

ColorSpeedSetting=0|1|2|3

  Determines which color scheme was last selected.  Changing this
  setting directly does not affect the actual colors used for
  individual elements.  The Color SpeedSetting combo box does not
  save color schemes; it only serves as a quick means of setting
  all color elements at once.  The default setting is 0.  The
  table below shows each value's corresponding speedsetting.

  Value  SpeedSetting
  -----  ------------
      0  Defaults
      1  Classic
      2  Twilight
      3  Ocean


<Element color>=

  All the color entries correspond to a single color element.
  Each color element entry uses the following format:

    <Element name>=fRGB,bRGB,attr,deffore,defback,fcell,bcell

    Value code  Meaning
    ----------  -------
    fRGB        Foreground RGB value
    bRGB        Background RGB value
    attr        Text attribute; zero or more of B, I and U
    deffore     Use default foreground color (1=yes, 0=no)
    defback     Use default background color (1=yes, 0=no)
    fcell       Foreground color grid cell number
    bcell       Background color grid cell number

Section: [Editor]  -  This section describes the appearance and
         behavior of the Delphi Code Editor.  Settings from both
         the Editor options and Editor display pages are detailed
         here.
-----------------------------------------------------------------

DefaultWidth=
DefaultHeight=

  These two items, if present, control the initial width and
  height of the Delphi Code Editor window.  Delphi does not
  update these values, but it does read them each time a Code
  Editor is created.  The default width is 406; the default
  height is 234.  These settings may be changed only by editing
  DELPHI.INI.


FontName=
FontSize=

  These settings specify the name and size, respectively, of a
  mono-spaced font that the Code Editor uses to display text.
  Courier New is the default font, 10 the default size.  These
  entries may be changed via the 'Editor font:' and 'Size:' combo
  boxes on the Editor display page.


BlockIndent=[1..16]

  Specifies the number of spaces to indent a marked block.  The
  default value is 1.  This setting may be changed via the 'Block
  indent' combo box on the Editor display page.


UndoLimit=[0..]

  Specifies the number of keystrokes that can be undone, which is
  limited by available memory.  The default value is 32,767.
  This setting may be changed via the 'Undo limit:' combo box on
  the Editor Options page.


TabRack=

  Determines the columns at which the cursor will move to each
  time the Tab key is pressed.  Each successive tab stop must be
  separated by a space and must be larger than its predecessor.
  If only one number is specified, tab stops are spaced apart
  evenly, using that number.  If two numbers are specified then
  tab stops occur at the specified positions and at positions
  that mark the difference between the two values.  The default
  tab stops are 9 and 17.  This setting may be changed via the
  'Tab stops:' combo box on the Editor Options page.  Note:
  this option has no effect if the smart tabs setting is enabled.


RightMargin=[0..1024]

  Specifies the right margin of the Code Editor.  The default
  value is 80.  The valid range is 0 to 1024.  This setting may
  be changed via the 'Right margin:' combo box on the Editor
  display page.


Extensions=

 Combo Box
  Specifies file masks of those files that will display with
  syntax highlighting.  Typically, only specific extensions are
  included.  The default setting is
  '*.PAS;*.DPR;*.DFM;*.INC;*.INT'.  This setting may be changed
  via the 'Syntax extensions:' combo box on the Editor Options
  page.  Example:

    Extensions=*.PAS;*.DPR;*.SRC


FindTextAtCursor=0|1

  When set to 1, causes Delphi to Place the text at the cursor
  into the 'Text To Find' combo box in the Find Text dialog box
  when the Search|Find menu option is chosen.   When set to 0,
  the default setting, the search text must be typed in.  This
  entry may be changed via the 'Find text at cursor' check box
  on the Editor Options page.


BRIEFRegularExpressions=0|1

  When set to 1, permits the use of Brief-style regular
  expressions when searching for text.  The default setting is 0.
  This entry may be changed via the 'BRIEF regular expressions'
  check box on the Editor Options page.


PreserveLineEnds=0|1

  Determines whether end-of-line characters are changed to
  carriage return/line feed pairs or are preserved.  When
  set to 0, Delphi converts end-of-line characters to carriage
  return/line feed pairs.  The default value is 1.  This
  entry may be changed via the 'Preserve Line Ends' check box
  on the Editor display page.


FullZoom=0|1

  Determines whether the Code Editor fills the entire screen when
  maximized.  When set to 0 (the default), the Code Editor does
  not cover the Delphi main window when maximized.  A setting of
  1 allows the Code Editor window to encompass the entire screen.
  This setting may be changed via the 'Zoom to full screen' check
  box on the Editor Display page.


DoubleClickLine=0|1

  When set to 1, causes Delphi to highlight the whole line when
  the user double-clicks any character in the line.  When set to
  0 (the default), only the selected word is highlighted.  This
  entry may be changed via the 'Double click line' check box on
  the Editor Options page.


BRIEFCursors=0|1

  Determines whether Delphi uses BRIEF-style cursor shapes in the
  Code Editor.  A setting of 1 causes Delphi to use Brief-style
  cursors.  The default setting is 0.  This setting may be
  changed via the 'BRIEF cursor shapes' check box on the Editor
  Display page.


ForceCutCopyEnabled=0|1

  When set to 1, enables the Edit|Cut and Edit|Copy menu options,
  even when no text is selected.  The default setting is 0.  This
  entry may be changed via the 'Force cut and copy enabled' check
  box on the Editor Options page.


KeyBindingSet=0|1|2|3

  Determines which pre-defined key mapping set Delphi recognizes.
  The default setting is 0.  This setting may be changed via the
  'Keystroke mapping:' list box on the Editor Display page.  The
  table below identifies the appropriate mapping for the desired
  value.

    Value  Mapping
    -----  -------
        0  Default
        1  Classic
        2  Brief
        3  Epsilon


Mode=

  This setting determines the state of sixteen of the options
  available on the Editor Options page and two of the options on
  the Editor Display page.  The value is the sum of the values
  listed below for each check box checked.  Unless noted, all
  the options below correspond to a similarly named check box on
  the Editor Options page.

         1  Insert mode - Inserts text at the cursor without
            overwriting existing text.
         2  Auto indent mode - Positions the cursor under the
            first nonblank character of the preceding nonblank
            line when Enter is pressed.
         4  Use tab character - Inserts tab character.  If
            disabled, inserts space characters.  This option and
            the Smart Tabs option are mutually exclusive.
            enabled, this option is off.
        16  Backspace un-indents - Aligns the insertion point to
            the previous indentation level (out-dents it) when
            Backspace is pressed, if the cursor is on the first
            nonblank character of a line.
        32  Keep trailing blanks - Saves trailing spaces and tabs
            present at the end of a line.
        64  Optimal fill - Begins every auto-indented line with
            the minimum number of characters possible, using tabs
            and spaces as necessary.
       128  Cursor through tabs - Enables the arrow keys to move
            the cursor to the beginning of each tab.
       256  Group undo - Undoes the last editing command as well
            as any subsequent editing commands of the same type
            when Alt+Backspace, Ctrl+Z is pressed or the
            Edit|Undo menu option is chosen.
       512  Persistent blocks - Keeps marked blocks selected even
            when the cursor is moved, until a new block is
            selected.
      1024  Overwrite blocks - Replaces a marked block of text
            with whatever is typed next.  If Persistent Blocks is
            also selected, text entered is added to the currently
            selected block.
      4096  Create backup file - Creates a backup file when
            source files are saved.  This item is set via the
            'Create backup file' check box on the Editor Display
            page.
      8192  Use Syntax highlight - Enables syntax highlighting.
     16384  Visible right margin - Enables the display of a line
            at the right margin of the Code Editor.  This item is
            set via the 'Visible right margin' check box on the
            Editor Display page.
     32768  Smart tabs - Tabs to the first non-whitespace
            character in the preceding line.  This option and
            the Smart Tabs option are mutually exclusive.
    131072  Cursor beyond EOF - Allows cursor positioning beyond
            the end-of-file.
    262144  Undo after save - Allows retrieval of changes after a
            save.


EditorSpeedSetting=0|1|2|3

  Determines which editor emulation scheme was last selected.
  Changing this setting directly does not affect the actual
  keystroke mapping or the editor options used.  The Editor
  SpeedSetting combo box does not save emulation schemes; it
  only serves as a quick means of setting many editor options at
  once.  The default setting is 0.  The table below shows each
  value's corresponding speedsetting.

    Value  SpeedSetting
    -----  ------------
        0  Default keymapping
        1  IDE classic
        2  Brief emulation
        3  Epsilon emulation


Section: [<Library name>.Palette]  -  This section describes the
         content of the Component Palette.  Each entry name in
         this section matches a single page name on the component
         palette.  The value for each entry is a list of the
         component type names that appear on that page, each
         separated by a semicolon.  This section appears once for
         each component library configured via the Palette page
         of the Environment Options dialog.



Section: [Transfer]  -  The Transfer section defines those items
         that appear on the Tools menu.  Entries in this section
         are defined when using the Tool Properties dialog.  The
         Tool Properties dialog is itself accessed via the
         Options|Tools menu option.
-----------------------------------------------------------------

Count=

  Specifies the number of items that should appear on the Tools
  menu.  This item is changed by adding or removing programs from
  the Tools Options dialog.

Title#=
Path#=
WorkingDir#=
Params#=

  These entries appear once each for every item on the Tools
  menu.  Each item name is immediately followed by a number
  indicating its position in the Tools menu, zero being the
  first.

    Title#       Specifies the text that actually appears on the
                 Tools menu.
    Path#=       Specifies the full path to the program that the
                 menu option will execute.
    WorkingDir#  Determines the current directory when the
                 program starts.
    Params#      Specifies the parameters to pass to the program
                 at startup.


Section: [Closed Files]  -  The Closed Files section lists the
         full path name of the last three closed project files.
         The files are listed in the order of most recently used
         first.  Each entry takes the form

           File_#=<projectname>.DPR,col1,row1,col2,row2

         where # is either 0, 1 or 2.  Col1 identifies the first
         visible column in the code editor, row1 the first
         visible row.  Col2 is the cursor column, row2 the cursor
         row.


Section: [VBX]  -  The VBX section contains various settings that
         are available when installing a VBX into the Delphi
         Component Library.
-----------------------------------------------------------------

VBXDir=

  Contains the last location from which a VBX was installed.
  This value is saved automatically by Delphi upon installing a
  VBX.

UnitDir=

  Specifies the last location in which Delphi placed a source
  unit for use with the previously installed VBX.  This value is
  saved automatically by Delphi upon installing a VBX.


PalettePage=BVSP

  This entry retains the last specified name of the component
  palette page onto which Delphi placed the most recently
  installed VBX.  This value is saved automatically by Delphi
  upon installing a VBX.



Section: [Version Control]
-----------------------------------------------------------------

VCSManager=

  This item specifies the fully qualified path of a Version
  Control manager DLL.  Delphi Client/Server, which includes team
  support, supplies a Version Control manager by the name
  STDVCS.DLL, located in the \BIN directory.  Example:

    VCSManager=d:\delphi\bin\stdvcs.dll



Section: [Resource Expert]  -  The Resource Expert section
         appears only if the Delphi Resource Expert is installed.
         This section has but one entry.
-----------------------------------------------------------------

RCIncludePath=

  Specifies the list of directories (separated by semicolons)
  that the expert should search to find any include files needed
  for resource file conversion.  Example:

    RCIncludePath=D:\DELPHI\WORK;D:\RESOURCE\INCLUDE


Section: [History_##]  -  A number of history sections, each with
         a unique number following the underscore, reside in
         DELPHI.INI.  Each history section corresponds directly
         to a particular combo box in a Delphi dialog.  Each
         section contains at least one entry; the Count entry,
         indicating the number of history items in the section.
         Each actual history item is named by an H, followed by
         its order in the history list, H0 being first.  The
         table below indicates to which combo box the particular
         section belongs.  Only those histories saved by Delphi
         are listed.

  Section       Combo box location
  -----------   -------------------------------------------------
  [History_0]   'Text to find', Find Text or Replace Text dialog
  [History_1]   'Replace with', Replace Text dialog
  [History_2]   'Output directory', Directory/conditionals page
                of Project Options dialog
  [History_3]   'Search path', Directory/conditionals page of
                Project Options dialog
  [History_7]   'Conditionals', Directory/conditionals page of
                Project Options dialog
  [History_8]   'Undo Limit', Editor options page of Environment
                Options dialog
  [History_9]   'Right margin', Editor display page of
                Environment Options dialog
  [History_10]  'Tab stops', Editor options page of Environment
                Options dialog
  [History_11]  'Syntax extensions', Editor options page of
                Environment Options dialog
  [History_12]  'Enter new line number', Go to Line Number dialog
  [History_18]  'Block indent', Editor options page of
                Environment Options dialog
  [History_20]  'File name', Open Project dialog
  [History_23]  'File name', Install VBX file dialog
  [History_25]  'File name', Unit file name dialog (under
                Install VBX)
  [History_33]  'Collapse nodes', Browser page of Environment
                Options dialog
  [History_34]  'Library path', Library page of Environment
                Options dialog
  [History_35]  'File name', Open Library dialog
  [History_36]  'File name', Save Project1 As  dialog
