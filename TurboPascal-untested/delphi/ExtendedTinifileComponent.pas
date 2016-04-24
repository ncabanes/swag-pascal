(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0152.PAS
  Description: Extended TIniFile Component
  Author: FERDINAND SOETHE
  Date: 08-30-96  09:35
*)

{****************************************************************
 * 	TExtIniF class																							*
 *	created and copyright by Ferdinand Soethe 1996  						*
 *	(email: f.soethe@oln.comlink.apc.org)												*
 *																															*
 *	You may use this source code in your applications           *
 *	(a word of credit would be nice) but you must not 					*
 *	resell it as part of a library or publish it in paper-			*
 *	or electronic form without asking my permission.						*
 *																															*
 *	TExtIniF extends Delphi's TIniFile to simplify saving a 		*
 *	components state to an INI-File. After creation you can 		*
 *	register any number of components and	save and retrieve     *
 *  their settings with just one call to StoreObjectStates.			*
 *																															*
 ****************************************************************}

unit extINIF;

interface

uses
	{unfortunately we need to include a units of classes
 	 that we want to be able to store}
  IniFiles, Files, Classes, Forms, StdCtrls, FileCtrl, Menus,
  sysUtils, TabNotBK;

type
	EExtIniFError = class(Exception);
	TExtIniF = class(TIniFile)
  private
    { Private-Deklarationen }
		FAutoStore: boolean;    {store all objects states before TExtIniF is destroyed}
		FRegObjects: TStringList; {list of all registered objects}
		FIniSection: String;    {Name of [section] where values are stored}
  protected
    { Protected-Deklarationen }
  public
    { Public-Deklarationen }
		constructor create(IniFName: TFileName);
		destructor destroy; override;
		{find the ini section for a registered object}
		function GetIniSection(obj: TObject): string;
		{Add a component to the list of objects}
		procedure RegisterObject(obj: TObject; INISection: string);
		{Remove a component to the list of objects}
    procedure UnRegisterObject(obj: TObject; INISection: string);
		{Retrieve the setting of a single Object}
    procedure ReStoreObjectState(obj: TObject; INISection: string);
		{Restore states of all registered objects}
		procedure RestoreObjectStates;
		{Restore states of all registered objects}
		procedure StoreObjectState(obj: TObject; INISection: string);
		{Store state of a single object}
		procedure StoreObjectStates;
		{Store states of all registered objects}
  published
    { Published-Deklarationen }
		property AutoStore: boolean read FAutoStore write FAutoStore;
		property IniSection: string read FIniSection write FIniSection;
  end;

implementation

{ find the section string to a registered object
   if not registered or section string is empty
   return default value}
function TExtIniF.GetIniSection(obj: TObject): string;
var
	index: integer;
begin
	index:= FRegObjects.indexOfObject(obj);
	if ( index > -1 ) then begin
		result:= FRegObjects.strings[index];
		if result = '' then
			result:= FIniSection;
	end else
		result:= FIniSection;
end; {GetIniSection}

{}
constructor TExtIniF.create(IniFName: TFileName);
begin
	{if you don't pass your own name for the ini-File, it will be the name
	 of your exe-file with the extension '*.INI'}
	if ( IniFName = '' ) then IniFName:= ExtraxtFileBaseName(application.exename)+'.ini';
	inherited create(IniFName);
  FRegObjects:= TStringList.Create;
	FIniSection:= 'Options';
end;

{}
destructor TExtIniF.Destroy;
begin
	{If AutoStore is set, values are stored
	 before TExtIniF-Object is destroyed}
	if FAutoStore then StoreObjectStates;
	FRegObjects.destroy;
	inherited destroy;
end;

{ Add an object to the list of monitored objects. If you pass an empty string
   for INISection, the default value will apply and no name will be stored}
procedure TExtIniF.RegisterObject(obj: TObject; INISection: string);
begin
	{check if object is already registered}
	if ( FRegObjects.indexOfObject(obj) = -1 ) then
		FRegObjects.addObject(INISection,obj);
end;

{ Remove an object from the list of monitored objects.}
procedure TExtIniF.UnRegisterObject(obj: TObject; INISection: string);
var
	index: integer;
begin
	index:= FRegObjects.indexOfObject(obj);
	if ( index > -1 ) then
		FRegObjects.delete(index);
end;


{ Restores the name of an object from the INI-File
   Note: When there is no entry in the INI-File, the object's value
 				 is not changed.}
procedure TExtIniF.ReStoreObjectState(obj: TObject; INISection: string);
var
	strBuf: string;
begin
	if ( INISection = '' ) then INISection:= FIniSection;
	{the next lines check for the type of object and
	 restore whatever property we would like to store of that object
	 if you make changes here you will need to make changes in
	 StoreObjectState as well!!!}
  if (obj.classInfo <> nil ) then begin
    if (obj is TCheckBox) then begin
      with (obj as TCheckBox) do begin
				{Checkboxes: restore checked state}
        checked:= readBool(INISection,Name,checked);
      end;
    end else
    if (obj is TEdit) then begin
      with (obj as TEdit) do begin
				{Editfield: restore text}
        text:= readString(INISection,Name,text);
      end;
    end else
    if (obj is TMenuItem) then begin
      with (obj as TMenuItem) do begin
				{Menuitem: restore checked state}
        checked:= readBool(INISection,Name,checked);
      end;
    end else
		if (obj is TTabbedNoteBook) then begin
        with (obj as TTabbedNoteBook) do begin
					{Notebook: restore open Tab}
          pageIndex:= readInteger(INISection,Name,pageIndex);
        end;
    end else
    if (obj is TDriveComboBox) then begin
      with (obj as TDriveComboBox) do begin
				{DriveCombo: restore selected drive}
				strBuf:= readString(INISection,Name,Drive);
        Drive:= strBuf[1];
      end;
    end else
    if (obj is TDirectoryListBox) then begin
      with (obj as TDirectoryListBox) do begin
				{DirectoryList: restore current directory}
        Directory:= readString(INISection,Name,Directory);
      end;
    end else
    	raise EExtIniFError.create('This object is not supported!');
	end;
end;

{ Restores the state of all registered objects
   from the INI-File}
procedure TExtIniF.RestoreObjectStates;
var
	objNo: integer;
begin
	{iterate through all registered objects}
	for objNo:= 0 to FRegObjects.count - 1 do
    ReStoreObjectState(FRegObjects.objects[objNo],FRegObjects.strings[objNo]);
end;

{ Stores the state of an object to the INI-File}
procedure TExtIniF.StoreObjectState(obj: TObject; INISection: string);
var
		strBuf: string;
begin
	if ( INISection = '' ) then INISection:= FIniSection;

	{the next lines check for the type of object and
	 store whatever property we would like to store of that object
	 if you make changes here you will need to make changes in
	 ReStoreObjectState as well!!!}

  if (obj.classInfo <> nil ) then begin
      if (obj is TCheckBox) then begin
				{Checkboxes: store checked state}
        with (obj as TCheckBox) do begin
          writeBool(INISection,Name,checked);
        end;
      end else
      if (obj is TEdit) then begin
				{Editfield: store text}
        with (obj as TEdit) do begin
          writeString(INISection,Name,text);
        end;
      end else
      if (obj is TMenuItem) then begin
				{Menuitem: restore checked state}
        with (obj as TMenuItem) do begin
          writeBool(INISection,Name,checked);
        end;
      end else
			if (obj is TTabbedNoteBook) then begin
        with (obj as TTabbedNoteBook) do begin
					{Notebook: restore open Tab}
          writeInteger(INISection,Name,pageIndex);
        end;
  	  end else
			if (obj is TDriveComboBox) then begin
      	with (obj as TDriveComboBox) do begin
					{DriveCombo: restore selected drive}
					writeString(INISection,Name,Drive);
      	end;
    	end else
			if (obj is TDirectoryListBox) then begin
				{DirectoryList: restore current directory}
        with (obj as TDirectoryListBox) do begin
          writeString(INISection,Name,Directory);
        end;
	    end else
  	  	raise EExtIniFError.create('This object is not supported!');
		end;
end;

{ Stores the state of all registered objects
   to the INI-File}
procedure TExtIniF.StoreObjectStates;
var
	objNo: integer;
begin
	for objNo:= 0 to FRegObjects.count - 1 do
    StoreObjectState(FRegObjects.objects[objNo],FRegObjects.strings[objNo]);
end;


end.
