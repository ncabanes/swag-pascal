(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0321.PAS
  Description: Copy an entire Directory
  Author: ANDRE HEINO ARTUS
  Date: 08-30-97  10:09
*)


>     Does someone know how to copy a entire directory ???

implementation
uses ShellAPI;

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
  FOS :TSHFileOpStruct;
begin
  with FOS do begin
    Wnd := Self.Handle;
    wFunc := FO_COPY;
    pFrom := 'c:\idapi\*.*';
    pTo := 'c:\test';
    fFlags := FOF_NoConfirmMkDir;
  end;
  SHFileOperation(FOS);
end;

Andre H. Artus
andre@oas.co.za

