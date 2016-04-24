(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0425.PAS
  Description: Save total font setting in Registry
  Author: RAY LISCHNER
  Date: 01-02-98  07:34
*)


Font & Tregistry
From: nojunkmail@tempest-sw.com (Ray Lischner) On 28 Mar 1997 05:57:38 GMT, "Alex" wrote:

does anybody know a way to save a total Font setting of a
form/panel/listbox etc. etc. to the registry, it's not so dificult doing it
line by line, but with the FontStyle it becomes a lot of lines, so is there
and easy/shorter way ?

Secrets of Delphi 2 has some code that recursively saves any object's
published properties to the registry. The example specifically shows how
it works for TFont.


--------------------------------------------------------------------------------

uses TypInfo;

{ Define a set type for accessing an integer's bits. }
const
  BitsPerByte = 8;
type
  TIntegerSet = set of 0..SizeOf(Integer)*BitsPerByte - 1;

{ Save a set property as a subkey. Each element of the enumerated type
  is a separate Boolean value. True means the item is in the set, and
  False means the item is excluded from the set. This lets the user
  modify the configuration easily, with REGEDIT. }
procedure SaveSetToRegistry(const Name: string; Value: Integer;
   TypeInfo: PTypeInfo; Reg: TRegistry);
var
  OldKey: string;
  I: Integer;
begin
  TypeInfo := GetTypeData(TypeInfo)^.CompType;
  OldKey := '\' + Reg.CurrentPath;
  if not Reg.OpenKey(Name, True) then
    raise ERegistryException.CreateFmt('Cannot create key: %s',
[Name]);

  { Loop over all the items in the enumerated type. }
  with GetTypeData(TypeInfo)^ do
    for I := MinValue to MaxValue do
      { Write a Boolean value for each set element. }
      Reg.WriteBool(GetEnumName(TypeInfo, I), I in
TIntegerSet(Value));

  { Return to the parent key. }
  Reg.OpenKey(OldKey, False);
end;

{ Save an object to the registry by saving it as a subkey. }
procedure SaveObjToRegistry(const Name: string; Obj: TPersistent;
   Reg: TRegistry);
var
  OldKey: string;
begin
  OldKey := '\' + Reg.CurrentPath;
  { Open a subkey for the object. }
  if not Reg.OpenKey(Name, True) then
    raise ERegistryException.CreateFmt('Cannot create key: %s',
[Name]);

  { Save the object's properties. }
  SaveToRegistry(Obj, Reg);

  { Return to the parent key. }
  Reg.OpenKey(OldKey, False);
end;

{ Save a method to the registry by saving its name. }
procedure SaveMethodToRegistry(const Name: string; const Method:
TMethod;
   Reg: TRegistry);
var
  MethodName: string;
begin
  { If the method pointer is nil, then store an empty string. }
  if Method.Code = nil then
    MethodName := ''
  else
    { Look up the method name. }
    MethodName := TObject(Method.Data).MethodName(Method.Code);
  Reg.WriteString(Name, MethodName);
end;

{ Save a single property to the registry, as a value of the current
key. }
procedure SavePropToRegistry(Obj: TPersistent; PropInfo: PPropInfo;
Reg: TRegistry);
begin
  with PropInfo^ do
    case PropType^.Kind of
    tkInteger,
    tkChar,
    tkWChar:
      { Store ordinal properties as integer. }
      Reg.WriteInteger(Name, GetOrdProp(Obj, PropInfo));
    tkEnumeration:
      { Store enumerated values by name. }
      Reg.WriteString(Name, GetEnumName(PropType, GetOrdProp(Obj,
PropInfo)));
    tkFloat:
      { Store floating point values as Doubles. }
      Reg.WriteFloat(Name, GetFloatProp(Obj, PropInfo));
    tkString,
    tkLString:
      { Store strings as strings. }
      Reg.WriteString(Name, GetStrProp(Obj, PropInfo));
    tkVariant:
      { Store variant values as strings. }
      Reg.WriteString(Name, GetVariantProp(Obj, PropInfo));      
    tkSet:
      { Store a set as a subkey. }
      SaveSetToRegistry(Name, GetOrdProp(Obj, PropInfo), PropType,
Reg);
    tkClass:
      { Store a class as a subkey, with its properties as values
        of the subkey. }
      SaveObjToRegistry(Name, TPersistent(GetOrdProp(Obj, PropInfo)),
Reg);
    tkMethod:
      { Save a method by name. }
      SaveMethodToRegistry(Name, GetMethodProp(Obj, PropInfo), Reg);
    end;
end;

{ Save an object to the registry by storing its published properties.
}
procedure SaveToRegistry(Obj: TPersistent; Reg: TRegistry);
var
  PropList: PPropList;
  PropCount: Integer;
  I: Integer;
begin
  { Get the list of published properties. }
  PropCount := GetTypeData(Obj.ClassInfo)^.PropCount;
  GetMem(PropList, PropCount*SizeOf(PPropInfo));
  try
    GetPropInfos(Obj.ClassInfo, PropList);
    { Store each property as a value of the current key. }
    for I := 0 to PropCount-1 do
      SavePropToRegistry(Obj, PropList^[I], Reg);
  finally
    FreeMem(PropList, PropCount*SizeOf(PPropInfo));
  end;
end;

{ Save the published properties as values of the given key.
  The key is relative to HKEY_CURRENT_USER. }
procedure SaveToKey(Obj: TPersistent; const KeyPath: string);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    if not Reg.OpenKey(KeyPath, True) then
      raise ERegistryException.CreateFmt('Cannot create key: %s',
[KeyPath]);
    SaveToRegistry(Obj, Reg);
  finally
    Reg.Free;
  end;
end;

