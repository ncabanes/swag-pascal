(*
  Category: SWAG Title: FREQUENTLY ASKED QUESTIONS/TUTORIALS
  Original name: 0046.PAS
  Description: WIN95 API Calls
  Author: BERNHARD ROSENKRAENZER
  Date: 09-04-95  11:55
*)

{
Hello,
since I expect Win95-API questions to become an FAQ in the next few
months, I thought you may be interested in adding a Win95 API list to the
SWAG WIN-OS2.SWG area...

The inofficial guide to Windows 95 API functions (Version 1.5)
(c) 1995 by Bernhard Rosenkraenzer

Changes since last version (1.0):
- Updated to Windows 95, Beta III (Milestone 8)
- Rearranged function descriptions to match function numbers
- Changed "other new functions" list to "list of all new functions"
  to give a better overview
- corrected minor mistakes - Kernel.38 (SetTaskSignalProc) and Kernel.352
  (LStrCatN) were listed as new functions previously, but they an obsolete
  ones.

Warning: All information in this document concerns the Windows 95 beta III,
March 1995. Specified information may be incorrect for the final release.
It contains functions that will most likely be undocumented, as well.

If you know how to use one of the listed and undescribed functions, please let
me know. My Internet address is bero@rage.fido.de, my FIDO-address is
2:2452/307.46.
You can obtain the latest version of this text by sending mail to that address.

==========================================================================
Kernel (krnl386.exe)
==========================================================================

--------------------------------------------------------------------------
bool GetProfileSectionNames(long Buffer, word length)         (kernel.142)
--------------------------------------------------------------------------
Returns the section names of the WIN.INI file. Section names are the ones
given in []-Brackets. GetProfileSectionNames separates the section names
using ASCII-Code 0.

Buffer: points to a buffer to take the section names
length: maximum length of buffer

return: 1 = Successful

--------------------------------------------------------------------------
bool GetPrivateProfileSectionNames(long Buffer, word length, long filename)
                                                              (kernel.143)
--------------------------------------------------------------------------
Returns the section names of any .INI file. See GetProfileSectionNames for a
further description.

Buffer:   points to a buffer to take the section names
length:   maximum length of buffer
filename: name of .INI file to look for.

--------------------------------------------------------------------------
bool CreateDirectory(long Directory, long whatever)           (kernel.144)
--------------------------------------------------------------------------
Creates a new directory, may use long filenames, may use "/" instead of "\"
for directory separation (example:
CreateDirectory("C:/Windows/System/Test CreateDirectory","") will create the
directory "Test CreateDirectory" in c:\Windows\System.)

Directory: specifies the directory name
whatever:  function unknown - must point to a string.

return:    1 = Directory created
           0 = Error

--------------------------------------------------------------------------
bool RemoveDirectory(long Directory)                          (kernel.145)
--------------------------------------------------------------------------
Removes a directory.

Directory: specifies the directory name

return:    1 = successful
           0 = Error

--------------------------------------------------------------------------
bool DeleteFile(long FileName)                                (kernel.146)
--------------------------------------------------------------------------
Deletes a file.

FileName: specifies File name

--------------------------------------------------------------------------
bool GetCurrentDirectory(long length, long buffer)            (kernel.411)
--------------------------------------------------------------------------
Gets the current directory
length: length of buffer to take directory name
buffer: pointer to buffer to take directory name

--------------------------------------------------------------------------
bool SetCurrentDirectory(long dirname)                        (kernel.412)
--------------------------------------------------------------------------
Sets the current directory. Supports change of current drive. (e.g. it is
possible to change from C:\Windows to D:\Star Trek)

dirname: specifies the name of the directory to change to

--------------------------------------------------------------------------
List of all new Kernel functions
--------------------------------------------------------------------------
Kernel.27	GetModuleName
Kernel.142      GetProfileSectionNames
Kernel.143      GetPrivateProfileSectionNames
Kernel.144      CreateDirectory
Kernel.145      RemoveDirectory
Kernel.146      DeleteFile
Kernel.147	SetLastError
Kernel.148	GetLastError
Kernel.149	GetVersionEx
Kernel.208	K208
Kernel.209	K209
Kernel.210	K210
Kernel.211	K211
Kernel.212	K212
Kernel.213	K213
Kernel.214	K214
Kernel.215	K215
Kernel.216	RegEnumKey
Kernel.217	RegOpenKey
Kernel.218	RegCreateKey
Kernel.219	RegDeleteKey
Kernel.220	RegCloseKey
Kernel.221	RegSetValue
Kernel.222	RegDeleteValue
Kernel.223	RegEnumValue
Kernel.224	RegQueryValue
Kernel.225	RegQueryValueEx
Kernel.226	RegSetValueEx
Kernel.227	RegFlushKey
Kernel.228	K228
Kernel.229	K229
Kernel.230	GlobalSmartPageLock
Kernel.231	GlobalSmartPageUnlock
Kernel.232	RegLoadKey
Kernel.233	RegUnloadKey
Kernel.234	RegSaveKey
Kernel.235	InvalidateNLSCache
Kernel.236	GetProductName
Kernel.237      K237
Kernel.360	OpenFileEx
Kernel.361	Piglet_361
Kernel.406	WritePrivateProfileStruct
Kernel.407	GetPrivateProfileStruct
Kernel.411      GetCurrentDirectory
Kernel.412      SetCurrentDirectory
Kernel.413	FindFirstFile
Kernel.414	FindNextFile
Kernel.415	FindClose
Kernel.416	WritePrivateProfileSection
Kernel.417	WriteProfileSection
Kernel.418	GetPrivateProfileSection
Kernel.419	GetProfileSection
Kernel.420	GetFileAttributes
Kernel.421	SetFileAttributes
Kernel.422	GetDiskFreeSpace
Kernel.491	RegisterServiceProccess
Kernel.513	LoadLibraryEx32W
Kernel.514	FreeLibrary32W
Kernel.515	GetProcAddress32W
Kernel.516	GetVDMPointer32W
Kernel.517	CallProc32W
Kernel.518	_CallProcEx32W
Kernel.627	IsBadFlatReadWritePTR

--------------------------------------------------------------------------
Kernel Functions no longer existant in Win95
--------------------------------------------------------------------------
Kernel.38       SetTaskSignalProc
Kernel.77	Reserved1
Kernel.78	Reserved2
Kernel.79	Reserved3
Kernel.80	Reserved4
Kernel.87	Reserved5
Kernel.118	GetTaskQueueDS
Kernel.119	GetTaskQueueES
Kernel.139	DoSignal
Kernel.140	SetSigHandler
Kernel.141	InitTask1
Kernel.151      WinOldApCall
Kernel.160	EmsCopy
Kernel.316      GetFreeMemInfo
Kernel.327	K327
Kernel.329	K329
Kernel.339	DiagQuery
Kernel.340	DiagOutput
Kernel.343      RegisterWinOldApHook
Kernel.344      GetWinOldApHooks
Kernel.352      LStrCatN
Kernel.403	K403
Kernel.404	K404

==========================================================================
User (USER.EXE)
==========================================================================
--------------------------------------------------------------------------
word WindowFromDC(word DC)                                      (User.117)
--------------------------------------------------------------------------
Returns the window handle from the specified DC

DC:     DC

return: window handle for specified DC

--------------------------------------------------------------------------
word GetForegroundWindow()                                      (User.608)
--------------------------------------------------------------------------
Returns the handle of the foreground window

return: handle of foreground window

--------------------------------------------------------------------------
bool SetForegroundWindow(word handle)                           (User.609)
--------------------------------------------------------------------------
Makes the specified window foreground window.
handle: Specifies handle of the window to be put in foreground.

--------------------------------------------------------------------------
bool SetMenuDefaultItem(word Menu, word Item, word Flag)        (User.664)
--------------------------------------------------------------------------
Sets a menu item default, meaning the item will be shown in bold font.
(Like the Close entry in the window system menu).

Menu: specifies the handle of the menu
Item: specifies the item handle
Flag: unknown. 0 seems to be the only working value.

--------------------------------------------------------------------------
List of all new User functions:
--------------------------------------------------------------------------
User.117        WindowFromDC
User.281	GetSysColorBrush
User.300	UnloadInstallableDrivers
User.364        LookupIconIDFromDirectoryEx
User.374	DLLEntryPoint
User.375	DrawTextEx
User.376	SetMessageExtraInfo
User.378	SetPropEx
User.379	GetPropEx
User.380	RemovePropEx
User.381	UsrMpr_ThunkData16
User.382	SetWindowContextHelpID
User.383	GetWindowContextHelpID
User.384	SetMenuContextHelpID
User.385	GetMenuContextHelpID
User.389	LoadImage
User.390	CopyImage
User.391	SignalProc32
User.394	DrawIconEx
User.395	GetIconInfo
User.397	RegisterClassEx
User.398	GetClassInfoEx
User.399	ChildWindowFromPointEx
User.409	InitThreadInput
User.427	FindWindowEx
User.428	TileWindows
User.429	CascadeWindows
User.441	InsertMenuItem
User.443	GetMenuItemInfo
User.446	SetMenuItemInfo
User.448	DrawAnimatedRects
User.449	DrawState
User.450	CreateIconFromResourceEx
User.475	SetScrollInfo
User.476	GetScrollInfo
User.477	GetKeyboardLayoutName
User.478	LoadKeyboardLayout
User.479	MenuItemFromPoint
User.498	Bear498
User.533	WNetInitialize
User.534	WNetLogOn
User.600	GetShellWindow
User.601	DoHotkeyStuff
User.602	SetCheckCursorTimer
User.604	BroadcastSystemMessage
User.605	HackTaskMonitor
User.606	FormatMessage
User.608        GetForegroundWindow
User.609        SetForegroundWindow
User.610	DestroyIcon32
User.620	ChangeDisplaySettings
User.621        EnumDisplaySettings
User.640	MsgWaitForMultipleObjects
User.650	ActivateKeyboardLayout
User.651	GetKeyboardLayout
User.652	GetKeyboardLayoutList
User.654	UnloadKeyboardLayout
User.655	PostPostedMessages
User.656	DrawFrameControl
User.657	DrawCaptionTemp
User.658	DispatchInput
User.659	DrawEdge
User.660	DrawCaption
User.661	SetSysColorsTemp
User.662	DrawMenuBarTemp
User.663	GetMenuDefaultItem
User.664        SetMenuDefaultItem
User.665	GetMenuItemRect
User.666	CheckMenuRadioItem
User.667	TrackPopupMenuEx
User.668	SetWindowRgn
User.669	GetWindowRgn
User.800	ChooseFont_CallBack16
User.801	FindReplace_CallBack16
User.802	OpenFileName_CallBack16
User.803	PrintDlg_CallBack16
User.804	ChooseColor_CallBack16
User.819        PeekMessage32
User.820        GetMessage32
User.821        TranslateMessage32
User.823        CallMsgFilter32
User.824        IsDialogMessage32
User.825	PostMessage32
User.826	PostThreadMessage32
User.827	MessageBoxIndirect
User.850	UsrThkConnectionDataLs
User.851	MsgThkConnectionDataLs
User.853	Ft_UsrThkThkConnectionData
User.854	Ft_UsrF2ThkThkConnectionData
User.855	Usr32ThkConnectionDataSl
User.890	InstallImt
User.891	UnInstallImt

--------------------------------------------------------------------------
User Functions changed in Win95
--------------------------------------------------------------------------
User.8  (WEP)  moved to  User.9  (WEP)

--------------------------------------------------------------------------
User Functions no longer existant in Win95
--------------------------------------------------------------------------
User.314	SignalProc
User.336	LoadCursorIconHandler
User.341	_FFFE_FARFRAME
User.343	GetFilePortName
User.356	LoadDIBCursorHandler
User.357	LoadDIBIconHandler

==========================================================================
GDI
==========================================================================
--------------------------------------------------------------------------
bool PolyBezier(word DC, long points, word numpoints)            (GDI.502)
--------------------------------------------------------------------------
Draws bezier curves.

DC:        handle of DC to paint bezier curves in
points:    pointer to an array of TPOINT structures identifying the
           coordinates
numpoints: number of points stored in points.

--------------------------------------------------------------------------
bool PolyBezierTo(word DC, long points, word numpoints)          (GDI.503)
--------------------------------------------------------------------------
Draws bezier curves. Starting point for the first bezier curve is the
current cursor position.

DC:        handle of DC to paint bezier curves in
points:    pointer to an array of TPOINT structures identifying the
           coordinates
numpoints: number of points stored in points.

--------------------------------------------------------------------------
List of all new GDI functions
--------------------------------------------------------------------------
GDI.188 GetTextExtentEx
GDI.266	OpenPrinterA
GDI.267	StartDocPrinterA
GDI.268	StartPagePrinter
GDI.269	WritePrinter
GDI.270	EndPagePrinter
GDI.271	AbortPrinter
GDI.272	EndDocPrinter
GDI.274	ClosePrinter
GDI.280	GetRealDriverInfo
GDI.281	DrvSetPrinterData
GDI.282	DrvGetPrinterData
GDI.299	EngineGetCharWidthEx
GDI.315	EngineRealizeFontExt
GDI.316	EngineGetCharWidthStr
GDI.404 GetTTGlyphIndexMap
GDI.489	CreateDIBSection
GDI.490	CloseEnhMetaFile
GDI.491	CopyEnhMetaFile
GDI.492	CreateEnhMetaFile
GDI.493	DeleteEnhMetaFile
GDI.495	GDIComment
GDI.496	GetEnhMetaFile
GDI.497	GetEnhMetaFileBits
GDI.498	GetEnhMetaFileDescription
GDI.499	GetEnhMetaFileHeader
GDI.501	GetEnhMetaFilePaletteEntries
GDI.502 PolyBezier
GDI.503 PolyBezierTo
GDI.504	PlayEnhMetaFileRecord
GDI.505	SetEnhMetaFileBits
GDI.506	SetMetaRgn
GDI.508	ExtSelectClipRgn
GDI.511	AbortPath
GDI.512	BeginPath
GDI.513	CloseFigure
GDI.514	EndPath
GDI.515	FillPath
GDI.516	FlattenPath
GDI.517	GetPath
GDI.518	PathToRegion
GDI.519	SelectClipPath
GDI.520	StrokeAndFillPath
GDI.521	StrokePath
GDI.522	WidenPath
GDI.523	ExtCreatePen
GDI.524	GetArcDirection
GDI.525	SetArcDirection
GDI.526	GetMiterLimit
GDI.527	SetMiterLimit
GDI.528	GDIParametersInfo
GDI.529	CreateHalfTonePalette
GDI.602	SetDIBColorTable
GDI.603	GetDIBColorTable
GDI.604	SetSolidBrush
GDI.605	SysDeleteObject
GDI.606	SetMagicColors
GDI.607	GetRegionData
GDI.608	ExtCreateRegion
GDI.609	GDIFreeResources
GDI.610	GDISignalProc32
GDI.611	GetRandomRgn
GDI.612	GetTextCharset
GDI.613	EnumFontFamiliesEx
GDI.614	AddLpkToGDI
GDI.615	GetCharacterPlacement
GDI.616	GetFontLanguageInfo
GDI.650	BuildInverseTableDIB
GDI.701	GDIThkConnectionDataLs
GDI.702	FT_GDIFThkThkConnectionData
GDI.703	FdThkConnectionDataSl
GDI.704	IcmThkConnectionDataSl
GDI.801	SetIcmMode
GDI.804	EnumProfiles
GDI.807	CheckColorSignAmut
GDI.808	GetColorSpace
GDI.809	GetLogColorSpace
GDI.810	CreateColorSpace
GDI.811	SetColorSpace
GDI.812	DeleteColorSpace
GDI.813	GetICMProfile
GDI.814	SetICMProfile
GDI.815	GetDeviceGammaRamp
GDI.816	SetDeviceGammaRamp
GDI.817	ColorMatchToTarget
GDI.820	ICMCreateTransform
GDI.821	ICMDeleteTransform
GDI.822	ICMTranslateRGB
GDI.823	ICMTranslateRGBs
GDI.824	ICMCheckColorSignAmut

--------------------------------------------------------------------------
GDI Functions no longer existant in Win95
--------------------------------------------------------------------------
GDI.213	Brute
GDI.460 GdiTaskTermination

==========================================================================
TOOLHELP (Toolhelp.dll)
==========================================================================
--------------------------------------------------------------------------
new Toolhelp functions in Win95
--------------------------------------------------------------------------
Toolhelp.2	__GP
Toolhelp.3	DLLEntryPoint
Toolhelp.84	Local32Info
Toolhelp.85	Local32First
Toolhelp.86	Local32Next

==========================================================================
MMSYSTEM
==========================================================================
--------------------------------------------------------------------------
word MixerGetNumDevs()                                      (mmsystem.800)
--------------------------------------------------------------------------
returns the number of installed sound mixer devices.

--------------------------------------------------------------------------
new MMSYSTEM functions in Win95
--------------------------------------------------------------------------
Mmsystem.3	PlaySound
Mmsystem.4	DLLEntryPoint
Mmsystem.110	JoyGetPosEx
Mmsystem.111	JoyConfigChanged
Mmsystem.250	MidiStreamProperty
Mmsystem.251	MidiStreamOpen
Mmsystem.252	MidiStreamClose
Mmsystem.253	MidiStreamPosition
Mmsystem.254	MidiStreamOut
Mmsystem.255	MidiStreamPause
Mmsystem.256	MidiStreamRestart
Mmsystem.257	MidiStreamStop
Mmsystem.800    MixerGetNumDevs
Mmsystem.801	MixerGetDevCaps
Mmsystem.802	MixerOpen
Mmsystem.803	MixerClose
Mmsystem.804	MixerMessage
Mmsystem.805	MixerGetLineInfo
Mmsystem.806	MixerGetID
Mmsystem.807	MixerGetLineControls
Mmsystem.808	MixerGetControlDetails
Mmsystem.809	MixerSetControlDetails
Mmsystem.1120	MMThreadCreate
Mmsystem.1121	MMThreadSignal
Mmsystem.1122	MMThreadBlock
Mmsystem.1123	MMThreadIsCurrent
Mmsystem.1124	MMThreadIsValid
Mmsystem.1125	MMThreadGetTask
Mmsystem.1150   MMShowMMCplPropertySheet
Mmsystem.2000	WinMMF_ThunkData16
Mmsystem.2001	Ring3_Devloader
Mmsystem.2002	WinMMTileBuffer
Mmsystem.2003	WinMMUntileBuffer
Mmsystem.2005	MCIGetThunkTable
Mmsystem.2006	WinMMLs_ThunkData16

--------------------------------------------------------------------------
MMSYSTEM Functions no longer existant in Win95:
--------------------------------------------------------------------------
Mmsystem.34	MMDrvInstall
Mmsystem.109	JoySetCalibration

==========================================================================
SHELL.DLL
==========================================================================
--------------------------------------------------------------------------
bool PickIconDlg(long Window, long length, long buffer)        (shell.166)
--------------------------------------------------------------------------
Shows the Icon Selection dialog box and returns filename and index of the
selected icon.

Window: Parent window handle or 0
Length: Maximum length of buffer
Buffer: Buffer to take information on the selected icon

--------------------------------------------------------------------------
word DriveType(word drive)                                     (shell.262)
--------------------------------------------------------------------------
Returns the drive type for a specified drive
drive: 0 = A:
       1 = B:
       ...
return: 1 = not installed
        2 = disk drive (3.5" HD)
        3 = Hard Disk
        4 = Network ??
        5 = CD-ROM

--------------------------------------------------------------------------
word ShFormatDrive(word Window, word Drive, long Param)        (shell.400)
--------------------------------------------------------------------------
Formats, or makes bootable, the specified drive

Window: parent window handle or 0
Drive:  0 = A:, 1 = B:, ...
Param:  0 = QuickFormat; 1 = Full Format; 2 = make bootable
return: -2 = canceled by user
        0 or -3 = drive can't be formatted
        6 = successful format

--------------------------------------------------------------------------
List of all new Shell functions:
--------------------------------------------------------------------------
Shell.40        ExtractIconEx
Shell.98        Shl3216_ThunkData16
Shell.99        Shl1632_ThunkData16
Shell.101       DLLEntryPoint
Shell.157	RestartDialog
Shell.166       PickIconDlg
Shell.262       DriveType
Shell.300	ShGetFileInfo
Shell.400       ShFormatDrive
Shell.401	ShCheckDrive
Shell.402	_RunDLLCheckDrive

--------------------------------------------------------------------------
Functions no longer existant in Win95
--------------------------------------------------------------------------
Shell.32        WCI
Shell.33        AboutDlgProc
Shell.100	HereTharBetYGars
Shell.101       FindExeDlgProc
Shell.103	ShellHookProc

--------------------------------------------------------------------------
Changes from Windows 3.x to Windows 95
--------------------------------------------------------------------------
Shell.101 FindExeDlgProc --> Shell.101 DLLEntryPoint

==========================================================================
COMMDLG
==========================================================================
--------------------------------------------------------------------------
new functions in Win95:
--------------------------------------------------------------------------
Commdlg.40	DlgThkConnectionDataLs

--------------------------------------------------------------------------
functions no longer existant in Win95
--------------------------------------------------------------------------
Commdlg.6	FileOpenDlgProc
Commdlg.7	FileSaveDlgProc
Commdlg.8	ColorDlgProc
Commdlg.13	FindTextDlgProc
Commdlg.14	ReplaceTextDlgProc
Commdlg.18	FontStyleEnumProc
Commdlg.19	FontFamilyEnumProc
Commdlg.21	PrintDlgProc
Commdlg.22	PrintSetupDlgProc
Commdlg.23	EditIntegerOnly
Commdlg.25	WantArrows
Commdlg.29	DwLbSubClass
Commdlg.30	DwUpArrowHack
Commdlg.31	DwOkSubClass

The inofficial guide to Windows 95 API, Appendix 1:

API Changes from Beta II, Oct 1994 (M7) to Beta III, March 1995 (M8):

===
GDI
===
Removed:
GDI.460 GdiTaskTermination

Added:
GDI.188 GetTextExtentEx
GDI.404 GetTTGlyphIndexMap

====
USER
====
Removed:
User.396 LookupIconIDFromDirectory
User.439 CreateIconFromResource
User.870 CreateSegmentedFrtWin
User.871 GetFrtWin
User.872 UpdateFrtWin
User.873 DestroySegmentedFrtWin

Added:
User.621 EnumDisplaySettings
User.819 PeekMessage32
User.820 GetMessage32
User.821 TranslateMessage32
User.823 CallMsgFilter32
User.824 IsDialogMessage

======
KERNEL
======
Removed:
Kernel.34  SetTaskQueue
Kernel.151 WinOldApCall
Kernel.316 GetFreeMemInfo
Kernel.343 RegisterWinOldApHook
Kernel.344 GetWinOldApHooks

Added:
Kernel.237 K237

=======
COMMDLG
=======
The old Windows 3.1 function CommDlg.16 (FormatCharDlgProc) was obsolete
in Beta II, but works again with Beta III.

========
MMSYSTEM
========
Added:
Mmsystem.1150 MMShowMMCplPropertySheet



