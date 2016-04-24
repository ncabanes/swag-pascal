(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0402.PAS
  Description: Conversion of the ActiveScript header
  Author: BRIAN DUPRAS
  Date: 01-02-98  07:34
*)

{unti AXScript v.1.0 05/28/97 - converted header file for Microsoft ActiveScript.

Original conversion of the ActiveScript header by David Zajac (dzajac@HiWAAY.net)
for Delphi 2.x.

Modified by Brian Dupras (bdupras@dimensional.com) for Delphi 3.0 using interfaces
instead of classes (which was necessary for D2).

This unit is released to the public.  No warrenty or guarentee of *anything*
is expressed or implied.  Use this code at your own risk - any damage is your
own fault for trusting me.  If you find any error in this code, fix it.  If
you're nice, let me know about the error so I can fix it, too.

This code has to date (May 28, 1997) only been tested for creating a host for
ActiveScript.  I have not tried creating a scripting engine with it (and probably
never will).  But I've been able to host both MS JScript and MS VBScript.

Good luck,
    Brian Dupras  5/28/97

----------------------------------------------------------------------------------

Ahh..updates.  I've updated this unit slilghtly, and created a helper unit called
(and aptly so) AXScriptHelp.  The only major additions were those to support
MS IE4.  The other updates to this unit were minor - a few slight type differences
and some parameter name changes.  Mostly cosmetic stuff.

Again, Good luck,

Brian 7/6/97


By the way, JScript, VBScript and ActiveScript are registered trademarks of
Microsoft Corporation.


----------------------------------------------------------------------------------
More updates still.  Thank you Gary Warren King for noticing that I'm an idiot.

The identifiers : SCRIPTTHREADID_CURRENT, SCRIPTTHREADID_BASE, and
SCRIPTTHREADID_ALL were originally thought to be C++ MACROS.  Upon second look,
however, they're not macros, they're #define constants that typcast the values
-1, -2, and -3 to the #typdef SCRIPTTHREADID.  Looking into another's activescript
conversion confirmed this, so the change has been made and duely noted.

We'll call this version 1.1 of the ActivScp.h conversion.  

Brian Dupras  8/26/97


p.s.  At the time of this writing, a slightly older demo using this header is
available at the Delphi Super Page.  The URL is
http://SunSITE.icm.edu.pl/delphi/, and the file is axscpd1.zip.  It can be
found under Delphi 3, Apps With Sources.  I plan to pust axscpd2.zip real soon
now, so get that one if it's there.
}


unit AXScript;

interface

uses
  Windows, ActiveX;


const
  //Category IDs
  CATID_ActiveScript:TGUID=              '{F0B7A1A1-9847-11cf-8F20-00805F2CD064}';
  CATID_ActiveScriptParse:TGUID=         '{F0B7A1A2-9847-11cf-8F20-00805F2CD064}';

  //Interface IDs
  IID_IActiveScriptSite:TGUID=           '{DB01A1E3-A42B-11cf-8F20-00805F2CD064}';
  IID_IActiveScriptSiteWindow:TGUID=     '{D10F6761-83E9-11cf-8F20-00805F2CD064}';
  IID_IActiveScript:TGUID=               '{BB1A2AE1-A4F9-11cf-8F20-00805F2CD064}';
  IID_IActiveScriptParse:TGUID=          '{BB1A2AE2-A4F9-11cf-8F20-00805F2CD064}';
  IID_IActiveScriptParseProcedure:TGUID= '{1CFF0050-6FDD-11d0-9328-00A0C90DCAA9}';
  IID_IActiveScriptError:TGUID=          '{EAE1BA61-A4ED-11cf-8F20-00805F2CD064}';


   // Constants used by ActiveX Scripting:
   SCRIPTITEM_ISVISIBLE     = $00000002;
   SCRIPTITEM_ISSOURCE      = $00000004;
   SCRIPTITEM_GLOBALMEMBERS = $00000008;
   SCRIPTITEM_ISPERSISTENT  = $00000040;
   SCRIPTITEM_CODEONLY      = $00000200;
   SCRIPTITEM_NOCODE        = $00000400;
   SCRIPTITEM_ALL_FLAGS     = (SCRIPTITEM_ISSOURCE or
                               SCRIPTITEM_ISVISIBLE or
                               SCRIPTITEM_ISPERSISTENT or
                               SCRIPTITEM_GLOBALMEMBERS or
                               SCRIPTITEM_NOCODE or
                               SCRIPTITEM_CODEONLY);

   // IActiveScript::AddTypeLib() input flags

   SCRIPTTYPELIB_ISCONTROL    = $00000010;
   SCRIPTTYPELIB_ISPERSISTENT = $00000040;
   SCRIPTTYPELIB_ALL_FLAGS    = (SCRIPTTYPELIB_ISCONTROL or
                                 SCRIPTTYPELIB_ISPERSISTENT);

// IActiveScriptParse::AddScriptlet() and IActiveScriptParse::ParseScriptText() input flags */

   SCRIPTTEXT_DELAYEXECUTION    = $00000001;
   SCRIPTTEXT_ISVISIBLE         = $00000002;
   SCRIPTTEXT_ISEXPRESSION      = $00000020;
   SCRIPTTEXT_ISPERSISTENT      = $00000040;
   SCRIPTTEXT_HOSTMANAGESSOURCE = $00000080;
   SCRIPTTEXT_ALL_FLAGS         = (SCRIPTTEXT_DELAYEXECUTION or
                                   SCRIPTTEXT_ISVISIBLE or
                                   SCRIPTTEXT_ISEXPRESSION or
                                   SCRIPTTEXT_HOSTMANAGESSOURCE or
                                   SCRIPTTEXT_ISPERSISTENT);


// IActiveScriptParseProcedure::ParseProcedureText() input flags

  SCRIPTPROC_HOSTMANAGESSOURCE  = $00000080;
  SCRIPTPROC_IMPLICIT_THIS      = $00000100;
  SCRIPTPROC_IMPLICIT_PARENTS   = $00000200;
  SCRIPTPROC_ALL_FLAGS          = (SCRIPTPROC_HOSTMANAGESSOURCE or
                                   SCRIPTPROC_IMPLICIT_THIS or
                                   SCRIPTPROC_IMPLICIT_PARENTS);


// IActiveScriptSite::GetItemInfo() input flags */

   SCRIPTINFO_IUNKNOWN  = $00000001;
   SCRIPTINFO_ITYPEINFO = $00000002;
   SCRIPTINFO_ALL_FLAGS = (SCRIPTINFO_IUNKNOWN or
                           SCRIPTINFO_ITYPEINFO);


// IActiveScript::Interrupt() Flags */

   SCRIPTINTERRUPT_DEBUG          = $00000001;
   SCRIPTINTERRUPT_RAISEEXCEPTION = $00000002;
   SCRIPTINTERRUPT_ALL_FLAGS      = (SCRIPTINTERRUPT_DEBUG or
                                     SCRIPTINTERRUPT_RAISEEXCEPTION);



type
  //new IE4 types
  TUserHWND=HWND;
  TUserBSTR=TBStr;
  TUserExcepInfo=TExcepInfo;
  TUserVariant=OleVariant;

  // script state values
  TScriptState = (
    SCRIPTSTATE_UNINITIALIZED,
    SCRIPTSTATE_STARTED,
    SCRIPTSTATE_CONNECTED,
    SCRIPTSTATE_DISCONNECTED,
    SCRIPTSTATE_CLOSED,
    SCRIPTSTATE_INITIALIZED
    );

  // script thread state values */
  TScriptThreadState = (
    SCRIPTTHREADSTATE_NOTINSCRIPT,
    SCRIPTTHREADSTATE_RUNNING
    );


  // Thread IDs */
  TScriptThreadID = DWORD;

const  //Note: these SCRIPTTHREADID constants were originally macros
       //in the first version of this file.  See the note at the top
       //for more information. (Thanks to Gary Warren King.)
  SCRIPTTHREADID_CURRENT        = TScriptThreadId(-1);
  SCRIPTTHREADID_BASE           = TScriptThreadId(-2);
  SCRIPTTHREADID_ALL            = TScriptThreadId(-3);

type
  //Forward declarations
  IActiveScript = interface;
  IActiveScriptParse = interface;
  IActiveScriptParseProcedure = interface;
  IActiveScriptSite = interface;
  IActiveScriptSiteWindow = interface;
  IActiveScriptError = interface;


  IActiveScriptError = interface(IUnknown)
    ['{EAE1BA61-A4ED-11CF-8F20-00805F2CD064}']

    // HRESULT GetExceptionInfo(
    //     [out] EXCEPINFO *pexcepinfo);
    function GetExceptionInfo(out ExcepInfo: TExcepInfo): HRESULT; stdcall;

    // HRESULT GetSourcePosition(
    //     [out] DWORD *pdwSourceCOntext,
    //     [out] ULONG *pulLineNumber,
    //     [out] LONG *plCharacterPosition);
    function GetSourcePosition(out SourceContext: DWORD; out LineNumber: ULONG; out CharacterPosition: LONGINT): HRESULT; stdcall;

    // HRESULT GetSourceLineText(
    //     [out] BSTR *pbstrSourceLine);
    function GetSourceLineText(out SourceLine: LPWSTR): HRESULT; stdcall;
  end; //IActiveScriptError interface


  IActiveScriptSite = Interface(IUnknown)
    ['{DB01A1E3-A42B-11CF-8F20-00805F2CD064}']
    // HRESULT GetLCID(
    //     [out] LCID *plcid);
    // Allows the host application to indicate the local ID for localization
    // of script/user interaction
    function GetLCID(out Lcid: TLCID): HRESULT; stdcall;

    // HRESULT GetItemInfo(
    //     [in] LPCOLESTR pstrName,
    //     [in] DWORD dwReturnMask,
    //     [out] IUnknown **ppiunkItem,
    //     [out] ITypeInfo **ppti);
    // Called by the script engine to look up named items in host application.
    // Used to map unresolved variable names in scripts to automation interface
    // in host application.  The dwReturnMask parameter will indicate whether
    // the actual object (SCRIPTINFO_INKNOWN) or just a coclass type description
    // (SCRIPTINFO_ITYPEINFO)  is desired.
    function GetItemInfo(const pstrName: POleStr; dwReturnMask: DWORD; out ppiunkItem: IUnknown; out Info: ITypeInfo): HRESULT; stdcall;

    // HRESULT GetDocVersionString(
    //     [out] BSTR *pbstrVersion);
    // Called by the script engine to get a text-based version number of the
    // current document.  This string can be used to validate that any cached
    // state that the script engine may have saved is consistent with the
    // current document.
    function GetDocVersionString(out Version: TBSTR): HRESULT; stdcall;

    // HRESULT OnScriptTerminate(
    //     [in] const VARIANT *pvarResult,
    //     [in] const EXCEPINFO *pexcepinfo);
    // Called by the script engine when the script terminates.  In most cases
    // this method is not called, as it is possible that the parsed script may
    // be used to dispatch events from the host application
    function OnScriptTerminate(const pvarResult: OleVariant; const pexcepinfo: TExcepInfo): HRESULT; stdcall;

    // HRESULT OnStateChange(
    //     [in] SCRIPTSTATE ssScriptState);
    // Called by the script engine when state changes either explicitly via
    // SetScriptState or implicitly via other script engine events.
    function OnStateChange(ScriptState: TScriptState): HRESULT; stdcall;

    // HRESULT OnScriptError(
    //     [in] IActiveScriptError *pscripterror);
    // Called when script execution or parsing encounters an error.  The script
    // engine will provide an implementation of IActiveScriptError that
    // describes the runtime error in terms of an EXCEPINFO in addition to
    // indicating the location of the error in the original script text.
    function OnScriptError(const pscripterror: IActiveScriptError): HRESULT; stdcall;

    // HRESULT OnEnterScript(void);
    // Called by the script engine to indicate the beginning of a unit of work.
    function OnEnterScript: HRESULT; stdcall;

    // HRESULT OnLeaveScript(void);
    // Called by the script engine to indicate the completion of a unit of work.
    function OnLeaveScript: HRESULT; stdcall;

  end; //IActiveScriptSite interface


  IActiveScriptSiteWindow = interface(IUnknown)
   ['{D10F6761-83E9-11CF-8F20-00805F2CD064}']
    // HRESULT GetWindow(
    //     [out] HWND *phwnd);
    function GetWindow(out Handle: HWND): HRESULT; stdcall;

    // HRESULT EnableModeless(
    //     [in] BOOL fEnable);
    function EnableModeless(fEnable: BOOL): HRESULT; stdcall;
  end;  //IActiveScriptSiteWindow interface

  IActiveScript = interface(IUnknown)
    ['{BB1A2AE1-A4F9-11CF-8F20-00805F2CD064}']
    // HRESULT SetScriptSite(
    //     [in] IActiveScriptSite *pass);
    // Conects the host's application site object to the engine
    function SetScriptSite(ActiveScriptSite: IActiveScriptSite): HRESULT; stdcall;

    // HRESULT GetScriptSite(
    //     [in] REFIID riid,
    //     [iid_is][out] void **ppvObject);
    // Queries the engine for the connected site
    function GetScriptSite(riid: TGUID; out OleObject: Pointer): HRESULT; stdcall;

    // HRESULT SetScriptState(
    //     [in] SCRIPTSTATE ss);
    // Causes the engine to enter the designate state
    function SetScriptState(State: TScriptState): HRESULT; stdcall;

    // HRESULT GetScriptState(
    //     [out] SCRIPTSTATE *pssState);
    // Queries the engine for its current state
    function GetScriptState(out State: TScriptState): HRESULT; stdcall;

    // HRESULT Close(void);
    // Forces the engine to enter the closed state, resetting any parsed scripts
    // and disconnecting/releasing all of the host's objects.
    function Close: HRESULT; stdcall;

    // HRESULT AddNamedItem(
    //     [in] LPCOLESTR pstrName,
    //     [in] DWORD dwFlags);
    // Adds a variable name to the namespace of the script engine. The engine
    // will call the site's GetItemInfo to resolve the name to an object.
    function AddNamedItem(Name: POleStr; Flags: DWORD): HRESULT; stdcall;

    // HRESULT AddTypeLib(
    //     [in] REFGUID rguidTypeLib,
    //     [in] DWORD dwMajor,
    //     [in] DWORD dwMinor,
    //     [in] DWORD dwFlags);
    // Adds the type and constant defintions contained in the designated type
    // library to the namespace of the scripting engine.
    function AddTypeLib(TypeLib: TGUID; Major: DWORD; Minor: DWORD; Flags: DWORD): HRESULT; stdcall;

    // HRESULT GetScriptDispatch(
    //     [in] LPCOLESTR pstrItemName,
    //     [out] IDispatch **ppdisp);
    // Gets the IDispatch pointer to the scripting engine.
    function GetScriptDispatch(ItemName: POleStr; out Disp: IDispatch): HRESULT; stdcall;

    // HRESULT GetCurrentScriptThreadID(
    //     [out] SCRIPTTHREADID *pstidThread);
    // Gets the script's logical thread ID that corresponds to the current
    // physical thread.  This allows script engines to execute script code on
    // arbitrary threads that may be distinct from the site's thread.
    function GetCurrentScriptThreadID(out Thread: TScriptThreadID): HRESULT; stdcall;

    // HRESULT GetScriptThreadID(
    //     [in] DWORD dwWin32ThreadID,
    //     [out] SCRIPTTHREADID *pstidThread);
    // Gets the logical thread ID that corresponds to the specified physical
    // thread.  This allows script engines to execute script code on arbitrary
    // threads that may be distinct from the sites thread.
    function GetScriptThreadID(Win32ThreadID: DWORD; out Thread: TScriptThreadID): HRESULT; stdcall;

    // HRESULT GetScriptThreadState(
    //     [in] SCRIPTTHREADID stidThread,
    //     [out] SCRIPTTHREADSTATE *pstsState);
    // Gets the logical thread ID running state, which is either
    // SCRIPTTHREADSTATE_NOTINSCRIPT or SCRIPTTHEADSTATE_RUNNING.
    function GetScriptThreadState(Thread: TScriptThreadID; out State: TScriptThreadState): HRESULT; stdcall;

    // HRESULT InterruptScriptThread(
    //     [in] SCRIPTTHREADID stidThread,
    //     [in] const EXCEPINFO *pexcepInfo,
    //     [in] DWORD dwFlags);
    // Similar to Terminatethread, this method stope the execution of a script thread.
    function InterruptScriptThread(Thread: TScriptThreadID; const ExcepInfo: TExcepInfo; Flags: DWORD): HRESULT; stdcall;

    // HRESULT Clone(
    //     [out] IActiveScript **ppscript);
    // Duplicates the current script engine, replicating any parsed script text
    // and named items, but no the actual pointers to the site's objects.
    function Clone(out ActiveScript: IActiveScript): HRESULT; stdcall;
  end;  //IActiveScript interface

  IActiveScriptParse = interface(IUnknown)
    ['{BB1A2AE2-A4F9-11CF-8F20-00805F2CD064}']

    // HRESULT InitNew(void);
    function InitNew: HRESULT; stdcall;

    // HRESULT AddScriptlet(
    //     [in] LPCOLESTR pstrDefaultName,
    //     [in] LPCOLESTR pstrCode,
    //     [in] LPCOLESTR pstrItemName,
    //     [in] LPCOLESTR pstrSubItemName,
    //     [in] LPCOLESTR pstrEventName,
    //     [in] LPCOLESTR pstrDelimiter,
    //     [in] DWORD dwSourceContextCookie,
    //     [in] ULONG ulStartingLineNumber,
    //     [in] DWORD dwFlags,
    //     [out] BSTR *pbstrName,
    //     [out] EXCEPINFO *pexcepinfo);
    function AddScriptlet(
          DefaultName: POleStr;
          Code: POleStr;
          ItemName: POleStr;
          SubItemName: POleStr;
          EventName: POleStr;
          Delimiter: POleStr;
          SourceContextCookie: DWORD;
          StartingLineNnumber: ULONG;
          Flags: DWORD;
      out Name: TBSTR;
      out ExcepInfo: TExcepInfo
    ): HRESULT; stdcall;

    // HRESULT STDMETHODCALLTYPE ParseScriptText(
    //     [in] LPCOLESTR pstrCode,
    //     [in] LPCOLESTR pstrItemName,
    //     [in] IUnknown  *punkContext,
    //     [in] LPCOLESTR pstrDelimiter,
    //     [in] DWORD dwSourceContextCookie,
    //     [in] ULONG ulStartingLineNumber,
    //     [in] DWORD dwFlags,
    //     [out] VARIANT *pvarResult,
    //     [out] EXCEPINFO *pexcepinfo);
    function ParseScriptText(
      const pstrCode: POLESTR;
      const pstrItemName: POLESTR;
      const punkContext: IUnknown;
      const pstrDelimiter: POLESTR;
            dwSourceContextCookie: DWORD;
            ulStartingLineNumber: ULONG;
            dwFlags: DWORD;
      out   pvarResult: OleVariant;
      out   pExcepInfo: TExcepInfo
    ): HRESULT; stdcall;

end;  //IActivScriptParse interface


IActiveScriptParseProcedure=interface(IUnknown)
  ['{1CFF0050-6FDD-11d0-9328-00A0C90DCAA9}']

  function ParseProcedureText(
     const pstrCode: POLESTR;
     const pstrFormalParams: POLESTR;
     const pstrItemName: POLESTR;
           punkContext: IUnknown;
     const pstrDelimiter: POLESTR;
           dwSourceContextCookie: DWord;
           ulStartingLineNumber: ULong;
           dwFlags: DWord;
     out   ppdisp: IDispatch
  ): HResult; stdcall;

end;  //IActivScriptParseProcedure interface


implementation


end.

