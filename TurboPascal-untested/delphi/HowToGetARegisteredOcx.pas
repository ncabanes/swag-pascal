(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0443.PAS
  Description: How to get a registered OCX?
  Author: SWAG SUPPORT TEAM
  Date: 01-02-98  07:34
*)


Before an OCX can be used, it must be registered with the
System Registry.

Suppose the OCX you want to use is called "test.ocx".

Try this code:


--------------------------------------------------------------------------------

var
  OCXHand: THandle;
  RegFunc: TDllRegisterServer;   //add OLECtl to the uses clause
begin
  OCXHand:= LoadLibrary('c:\windows\system\test.ocx');
  RegFunc:= GetProcAddress(OCXHand, 'DllRegisterServer');  //case
sensitive?
  if RegFunc <> 0 then ShowMessage('Error!');
  FreeLibrary(OCXHand);
end;

--------------------------------------------------------------------------------

You can the same way unregister the OCX: all you have to do is to
replace 'DllRegisterServer' by 'DllUnregisterServer'.

You should add some validation code: "Does the file exist", "Was the call
to LoadLibrary successful?", ...

Some explanations:

An OCX is a special form of dll, so you can load it in memory with a call
to the LoadLibrary() API function. An OCX exports two functions to register
and unregister the control. You then use GetProcAddress to obtain the
address of these functions. You just have then to call the appropriate
function. And that's it! You can explore the Registry (with regedit.exe)
to verify that the OCX is registered.

