(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0330.PAS
  Description: [D2]-Single Instance of Application
  Author: MARC BATCHELOR
  Date: 08-30-97  10:09
*)

{
> after a bit of thought I created the attached component (4.54K) for
> making sure only one instance of an app
> is run.
>
> I have tested this in several apps with absolutely no reocurence.  It
> just drops on the main form has two properties
>
> let me know what you think of it.
>

I had a look at the source code, and had a few comments. I sincerely
hope you were looking for constructive criticism :-)

If you use a temporary disk file, you run the risk of encountering a
situation where you can't start up any instances of the program at all.
For example, if the program crashes, the temporary file will remain on
the hard disk. Nothing short of deleting the file will allow an instance
of the program to run.

I suggest you use Semaphores or Mutexes. Here is an example using
Mutexes:

--------------------------------Cut Here-------------------------------


  Unit Name: AppInit
  Purpose: The purpose of this unit is to indicate whether a previous
           instance of an application is running.

  Author: Marc Batchelor
  Date: 06/19/97

  Usage: Simply include this unit in your Delphi 16/32 project. From the
         Project's Initialization, check the variable
         AppInit.IsFirstInstance. If IsFirstInstance is false, then
         the application can bring the previous instance in focus and
         terminate.
}

unit AppInit;

interface

var
{$IFDEF WIN32}
  InstanceMutexHandle: THandle = 0;
  UniqueApplicationString: String;
{$ENDIF}
  IsFirstInstance: Boolean;

implementation

uses
  SysUtils, WinProcs, WinTypes, Classes, Forms,  dialogs;

{$IFDEF WIN32}
procedure SetUniqueAppString;
var
  times: Integer;
begin
  { Setup Unique String for the Mutex }
  UniqueApplicationString := 'APPLICATION-' + Application.ExeName;
  for times := 1 to Length(UniqueApplicationString) do
  begin
    { Mutex names can't have '\' in them, so perform replacement }
    if UniqueApplicationString[times] = '\' then
      UniqueApplicationString[times] := '_';
  end;
  { Uppercase the string to prevent case sensitivity problems }
  UniqueApplicationString := AnsiUppercase(UniqueApplicationString);
end;

procedure InitInstance;
begin
  { Check to see if the mutex is already there }
  InstanceMutexHandle := OpenMutex(MUTEX_ALL_ACCESS, false,
    pchar(UniqueApplicationString));
  if InstanceMutexHandle = 0 then
  begin
    { This is the first instance }
    InstanceMutexHandle := CreateMutex(nil, false,
      pchar(UniqueApplicationString));
    { Error checking to see if anyone beat us... }
    if InstanceMutexHandle = 0 then
      IsFirstInstance := false
    else
      IsFirstInstance := true;
  end
  else
    IsFirstInstance := false;
end;
{$ENDIF}

initialization
{$IFDEF WIN32}
  IsFirstInstance := false;
  SetUniqueAppString;
  InitInstance;
finalization
  if IsFirstInstance then
  begin
    CloseHandle(InstanceMutexHandle);
    InstanceMutexHandle := 0;
  end;
  UniqueApplicationString := '';
{$ELSE}
  IsFirstInstance = (hPrevInst = 0);
{$ENDIF}
end.

--------------------------------Cut Here-------------------------------


--
Marc Batchelor
AppSource Corporation
http://www.appsource.com

