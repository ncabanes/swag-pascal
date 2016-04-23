{
Q:  How can I get the Windows or DOS version numbers?

A:  The API call GetVersion will do it, but the information is
encrypted into a longint.  Here is how to get and decrypt the information:
}

  Type
    TGetVer = record
      WinVer,
      WinRev,
      DosRev,
      DosVer: Byte;
    end;

  const
    VerStr = '%d.%d';

  procedure TForm1.Button1Click(Sender: TObject);
  var
    AllVersions: TGetVer;
  begin
    AllVersions := TGetVer(GetVersion);
    Edit1.Text := Format(VerStr, [AllVersions.WinVer, AllVersions.WinRev]);
    Edit2.Text := Format(VerStr, [AllVersions.DOSVer, AllVersions.DOSRev]);
  end;

Note1:  The values that windows displays for the versions and the values
that it returns through its API call are not always the same.  e.g.  The
workgroup version displays as 3.10 rather than 3.11.

Note2: Win32 applications should call GetVersionEx rather than GetVersion.
