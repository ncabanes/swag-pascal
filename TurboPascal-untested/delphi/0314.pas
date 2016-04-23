unit previnst;
{Copyright ⌐ 1997 Simon Carter.  All Rights Reserved.

This component can be used as freeware in any commercial or private application
the only request I make is that if it is modified in any way then I have a copy
of the modifications.  If you do use this product then please drop me an E-Mail
 to sc4vb@geocities.com to let me know.

Originally created by Simon Carter sc4vb@geocities.com
Released to public domain on 18 June 1997
No Warranty or liability can be taken by Simon Carter in respect of the use
or inability to use this component under any circumstances

HISTORY

Date         Name                  Reason
17-6-97      Simon Carter          Created

Additional Information
Properties
AppName      -   Name of the application.  This will be used for the temporary file
DupeMessage  -   Message to be displayed if duplicate found

Usage
Simply drop on the component on the form fill in the above properties
and run program.
}
interface  { dcr for this unit is contained below !! }

uses
  Windows, SysUtils, Classes, Forms;

type
  TPrevInst = class(TComponent)
  private
      FFileHandle: HFile;
      FAppName: String;
      FTempLoc: String;
      FDupeMessage: String;
      MOFS: TOFStruct;  //my open file struct
  protected
      Function AppHasPrevious:Boolean;
      Procedure PrepFile;
  public
      constructor Create(Owner: TComponent); override;
      destructor Destroy; override;
      Function GetAppName: String;
      Procedure SetAppName(NewName: String);
      Function GetDupeMessage:String;
      Procedure SetDupeMessage(NewMessage: String);
 published
      Property AppName: String read GetAppName write SetAppName;
      Property DupeMessage: String read GetDupeMessage write SetDupeMessage;
  end;

procedure Register;

implementation
Procedure TPrevInst.PrepFile;
var
I: Integer;
S: String;
Begin
     S := FTempLoc + FAppName + '.Tmp';
     For I := 1 to Length(FTempLoc + FAppName + '.Tmp') Do
         MOFS.szPathName[I] :=  S[I];
     MOFS.cBytes := SizeOf(MOFS);
End;
Procedure TPrevInst.SetDupeMessage(NewMessage: String);
Begin
     FDupeMessage := NewMessage;
End;

Function TPrevInst.GetDupeMessage:String;
Begin
     Result := FDupeMessage;
End;

Function TPrevInst.AppHasPrevious:Boolean;
Begin
     If FileExists(FTempLoc + FAppName + '.Tmp') Then
         Begin
              If DeleteFile(FTempLoc + FAppName + '.Tmp') Then
                 Begin
                      Result := False;
                      PrepFile;
                      FFileHandle := OpenFile(PChar(FTempLoc + FAppName + '.Tmp'),MOFS,OF_Create or OF_Share_Exclusive);
                 End
              Else
                 Begin
                      Application.MessageBox(PChar(FDupeMessage),Pchar(AppName),mb_OK + mb_IconStop);
                      Application.Terminate;
                      Result := True;
                 End;
         End
     Else
         Begin
              PrepFile;
              FFileHandle := OpenFile(PChar(FTempLoc + FAppName + '.Tmp'),MOFS,OF_Create or OF_Share_Exclusive);
              Result := False;
         End;
End;
constructor TPrevInst.Create(Owner: TComponent);
Begin
     Inherited Create(Owner);
     If Application.Title = '' then
        FAppName := 'New Project'
     Else
        FAppName := Application.Title;
     FTempLoc := ExtractFilePath(ParamStr(0));
     FDupeMessage := 'Only One Instance Of This Program Can Be Run At Any One Time';
End;

destructor TPrevInst.Destroy;
Begin
     CloseHandle(FFileHandle);
     //try and delete file if it won't then don't worry
     try
        DeleteFile(FTempLoc + FAppName + '.Tmp');
     Except
        //CloseFile
     End;
     inherited destroy;
End;

Function TPrevInst.GetAppName: String;
Begin
    Result := FAppName;
End;

Procedure TPrevInst.SetAppName(NewName: String);
Begin
    FAppName := NewName;
    If not (csDesigning in ComponentState) then
       AppHasPrevious;
End;

procedure Register;
begin
  RegisterComponents('Additional', [TPrevInst]);
end;

end.

{ the following contains additional files that should be included with this
  file.  To extract, you need XX3402 available with the SWAG distribution.

  1.     Cut the text below out, and save to a file  ..  filename.xx
  2.     Use XX3402  :   xx3402 d filename.xx
  3.     The decoded file should be created in the same directory.
  4.     If the file is a archive file, use the proper archive program to
         extract the members.

{ ------------------            CUT              ----------------------}


*XX3402-000472-180697--72--85-47113----PREVINST.DCR--1-OF--1
+++++0++++1zzk++zzw+++++++++++++++++++++++06+E++A++++Dzz+U-I+3++IU-3+3M+
GE-C+3A+J++++++++++E2+Y6+++++++++++c++++4++++-U++++-++E++++++0+-++++++++
++++++++++++++++++++++++U+++U++++60++6++++0++6++U6+++60+U+1+kA++++1z++1z
++++zzw+zk+++Dw+zk1zzk++zzzz+6U6W+W6W6W6W6W6W60+U606W6W6W6W6W6U6U6W6W6W6
W6W6W60+U606W6W6W6W6W6U6W+W6W6W6W6W6W6W6W6aNaNaMW6W6W6W6W6aNaNaMW6W6W6W6
W6aNaNaMW6W6WDRrRrRraNRrRrRrRzW6W6W6aNW6W6W6VzW6W6W6aNWDRrRrVzW6W6W6aNWD
U605VzW6W6W6aNWDzzzzVzW6W6W6aNW6W6W6VzW6W6W6aNW6W6W6VzW6W6W6aNW6W6W6VzW6
W6aNaNW6W6W6VzW6W6WNaNW6W6W6VzW6W6W7aNW6W6W6VzW6W6W6W6W6W6W6VzW6W6W6W6W6
W6W6VznAnAnAnAnAnAnAlzzzzzzzzzzzzzzzxsW6W6W6W6W6W6W6W+++
***** END OF BLOCK 1 *****

