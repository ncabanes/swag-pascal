
>How can I register OCX component (NetManage HTML) to use it with
>my application on a "clean" pc (Delphi not installed).
>        Run regsvr32 filename.ocx(dll)

  Another way to do it is this:
---------- Application's Project Source ----------
 ...
var
  i     : TCLSID;
  hOCX  :integer;
  pReg  : procedure;
begin
  { Check ocx registration. }
  try
    i :=3D StringToClassID('SoftwareFX.ChartFX.20');
  except
    hOCX :=3D LoadLibrary( 'CFX32.OCX' );
    if (hOCX  >=3D HINSTANCE_ERROR) then begin
      try
        pReg :=3D GetProcAddress(hOCX,'DllRegisterServer');
        if (@pReg <> nil) then
          pReg  { Call the registration function }
        else
          MessageDlg('Error in registering OCX control.', mtError, [mbok]=
,0);
      finally
        FreeLibrary(hOCX);
      end;
    end else
      MessageDlg('Error in loading OCX control.', mtError, [mbok],0);
  end;

  Application.Initialize;
...
------------------------------

  This source checks that the OCX is registered with StringToClassID meth=
od.
If not registered, it raises an error. If error occured, just load the OC=
X
and call  DllRegisterServer method to register it.

  This source is used to register ChartFX OCX but you can change it to
register any OCX by changing 'SoftwareFX.ChartFX.20' and 'CFX32.OCX' to
whatever...

  Hope it helps.

  Veikko V=E4=E4t=E4j=E4
  veikko.vaataja@abo.fi

