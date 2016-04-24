(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0439.PAS
  Description: Path/directory name for 'My Computer'
  Author: CHRISTIAN PIENE GUNDERSEN
  Date: 01-02-98  07:34
*)


Christian Piene Gundersen <j.c.p.gundersen@jusstud.uio.no>

This is a rather complicated matter, so if it isn't vital to your application, I suggest that you spend your time better than digging into it. However, I'll try to point you in the right direction. 
The windows 32 operating system is based on a shell which uses virtual folders, like 'my computer', 'desktop' and 'recycle bin'. Some of these folders are part of the physical file system. That is they have a corresponding directory in the file system. This is the case with 'desktop' and 'recycle bin'. These directories can be used as InitialDir for the TOpenDialog, but first you have to get their physical location, which can be different on different computers. To get the physical location of these folders, you have to use some special API calls (see example below). Other folders, like 'my computer' and 'printers' are not part of the file system - they are only virtual. I've noticed that you can browse to these folders using the TOpenDialog, but I don't think they can be used as InitialDir. 

Virtual folders are (a bit simplified) of the type SHITEMID (item identifier). They are normally accessed using pointers to item identifiers list (PIDL). To get the PIDL of a special folder, you can use the SHGetSpecialFolder function. The physical location of the corresponding directory can then be obtained by passing the PIDL to the GetPathFromIDList function. If the folder is part of the file system, the function will return the path as a string (which can be used as InitialDir). But if you want the OpenDialog to start in a folder that is only virtual (like 'my computer'), you'll have to make it accept a PIDL as InitialDir, which I don't think it will. My guess is that the TOpenDialog uses PIDLs when browsing, but only accepts physical directories as InitialDir.

Here is an example that shows how to get the 'recent documents' path and use it as InitialDir:



--------------------------------------------------------------------------------

procedure TForm1.Button1Click(Sender: TObject);
var
PIDL: Pointer;
Path: LPSTR;
const
CSIDL_RECENT = $0008;
begin
Path := StrAlloc(MAX_PATH);
SHGetSpecialFolderLocation(Handle, CSIDL_RECENT, @PIDL);
if SHGetPathFromIDList(PIDL, Path) then // returns false if folder isn't
part of file system
  begin
  OpenDialog1.InitialDir := Path;
  OpenDialog1.Execute;
  end;
StrDispose(Path);
end;

--------------------------------------------------------------------------------
I think you'll have to write a wrapper for these API calls. They are found in shell32.dll. The best advice I can give you if you want to dig into this is to study the ShlObj.h file. I don't program in C myself, but I found it very useful.
Some constants you may need:



--------------------------------------------------------------------------------

  CSIDL_DESKTOP            = $0000;
  CSIDL_PROGRAMS           = $0002;
  CSIDL_CONTROLS           = $0003;
  CSIDL_PRINTERS           = $0004;
  CSIDL_PERSONAL           = $0005;
  CSIDL_STARTUP            = $0007;
  CSIDL_RECENT             = $0008;
  CSIDL_SENDTO             = $0009;
  CSIDL_BITBUCKET          = $000a;
  CSIDL_STARTMENU          = $000b;
  CSIDL_DESKTOPDIRECTORY   = $0010;
  CSIDL_DRIVES             = $0011;  // My Computer
  CSIDL_NETWORK            = $0012;
  CSIDL_NETHOOD            = $0013;
  CSIDL_FONTS              = $0014;
  CSIDL_TEMPLATES          = $0015;

