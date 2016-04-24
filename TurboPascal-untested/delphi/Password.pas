(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0306.PAS
  Description: Password
  Author: APOGEE INFORMATION SYSTEMS
  Date: 08-30-97  10:08
*)

(*******************************************************************
AISQuickPassword - Backdoor Password generating Component for Delphi

Created on : September 25, 1996
Created by : Dennis P. Butler

Purpose :
  The purpose of this component is to allow a programmer to use password
  security in a project, but not be restricted by having to come up with
  a scheme to handle forgotten passwords.  This component allows the
  programmer to make his projects generate temporary passwords for the
  users of the project.

Description  :
  A perpetual problem with passwords is that users often forget their
  password, leading to many adminsitrative problems.  These problems are
  especially severe if an application is using local tables and being
  run on a laptop, where an administrator may not easily be able to help
  the user if they are not at the same location.  This component allows
  the administrator to generate a temporary password based on the login
  criteria of the user. This password can be good for the entire day or
  the specific hour, based on the use in the program.  The component also
  allows passwords to be generated for users in a different time zone.
  For example, if a user in a different time zone than the administrator
  calls up wanting a backdoor password for themselves, especially if the
  hourly password option is chosen, then the hour offset in the
  TimeZoneHours field can accomodate this and produce a correct password
  for the users machine.

Using the Component :
  Use of this component assumes that there are at least two types of people
  who will be using the system, ordinary users and administrators.  Only
  administrators have the ability to generate backdoor passwords for users.
  In a typical application, there is a login screen to enter the system.
  Using the AISQuickPassword component, the application would fill in the
  information for the UserName property based on the login, the Sortmethod
  property, and the LengthPassword property.  The programmer would include
  in the login screen a call to validatepassword with the password entered
  as a parameter.  If the password entered is the temporary password, the
  program can allow them to enter the system or take whatever steps is then
  appropriate for the application.  On the administrator end, they would have
  access to a form where only they would be able to make calls to the
  createmethod method.

Key Properties :
    UserName (string) - This is the string criteria unique to each user.  It can be
                        a user name, user id, etc., but generally should be the same
                        string that is used to log into the system, so that the strings
                        will be the same on the user and administrator machines.
    SortMethod (stDateOnly, stDateHour) - Defines whether the password generated will
                                          be valid for an entire day or the current hour.
    LengthPassword (integer) - Length of the resulting password.
    TimeZoneHours (integer) - Number of hours away from the administrator that the user is at.
                              Default is zero.  For time zones with an earlier time than the
                              administrator, use a negative number.

** Note that the first three properties must be identical
        on the user and administrative programs **

Methods :
  CreatePassword - Based on the UserName, SortMethod, & PasswordLength, a unique password
                   is returned.
  ValidatePassword - Based on the password passed to the function, a boolean value of
                     True or False will be returned on whether the password is correct
                     for the UserName, SortMethod, & PasswordLength.

Any feedback, comments, etc. are welcome.  Please reply to dbutler@apogeeis.com

Copyright 1996 Apogee Information Systems
*********************************************************************)

unit Quickpw;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

  {
  stDateOnly - Password is comprised of date only - good for entire day
  stDateHour - Password is comprised of date & hour - good for current hour only }

type
  TSortType = (stDateOnly,stDateHour);

  TAISQuickPW = class(TComponent)
  private
    FUserName : string;
    FSortMethod : TSortType;
    FLengthPassword : integer;
    FTimeZoneHours : integer;
    function ReturnPW(CreatingPassword: Boolean) : String;
    function IsValidSelections : Boolean;
    { Private declarations }
  protected
    { Protected declarations }
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    function CreatePassword : String;
    function ValidatePassword(PWord: String) : boolean;
    { Public declarations }
  published
    { Username must be identical on user & administrator ends }
    property UserName : string read FUserName write FUserName;
    property SortMethod : TSortType read FSortMethod write FSortMethod;
    { The longer the LengthPassword property is, the more secure the password }
    property LengthPassword : integer read FLengthPassword write FLengthPassword;
    { The number of hours away, + or -, of the users timezone.  0 is default }
    property TimeZoneHours : integer read FTimeZoneHours write FTimeZoneHours;
    { Published declarations }
  end;

procedure Register;

implementation


Constructor TAISQuickPW.Create(AOwner:TComponent);
begin
  Inherited Create(AOwner);
end;

Destructor TAISQuickPW.Destroy;
begin
  Inherited Destroy;
end;

procedure Register;
begin
  RegisterComponents('Apogee', [TAISQuickPW]);
end;

{ This function generates the password. }
function TAISQuickPW.ReturnPW(CreatingPassword: Boolean) : String;
var
  Password : String;
  PassBasis : Real;
  NameMultiplier,
  CurrentHour,
  DayAdjustment : integer;
  ThisDate : TDateTime;
const
  multiplier = 0.092292080396;  { Random Multiplier - This ensures that a fraction will result }
begin
  DayAdjustment := 0;
  ThisDate := Date;
  CurrentHour := StrToInt(FormatDateTime('h',ThisDate));

  if Length(FUserName) > 3 then
    NameMultiplier := Ord(FUserName[1]) + Ord(FUserName[2]) + Ord(FUserName[3])
  else
    NameMultiplier := 13; { If UserName is less than three digits, use temp number }

  if CreatingPassword then { Only adjust time based on time zone difference if
                             creating password.  Validifying passwords is done
                             at user end, where time zone difference is basis
                             for creation of password on Administrator end. In
                             this case no time adjustment is needed. }
    begin
      if (CurrentHour + TimeZoneHours) > 23 then
        begin
          CurrentHour := CurrentHour - 24;
          DayAdjustment := 1;
        end
      else
        if (CurrentHour + TimeZoneHours) < 0 then
          begin
            CurrentHour := 24 + CurrentHour;
            DayAdjustment := -1;
          end;

      ThisDate := ThisDate + DayAdjustment;
    end;

  if FSortMethod = stDateHour then
    NameMultiplier := NameMultiplier + CurrentHour;

  { Multiply name dependent number by date dependent number to get a unique value for
    every day of the year for each user.  Multiply this by a random multiplier (const value)
    to ensure that a fraction always results.  Take FLengthPassword digits of fraction as
    the final password.  Note that if the fractional portion works out to less digits than
    FLengthPassword, a password with less digits than FLengthPassword will result.  Program
    will still create/validate passwords normally. }
  PassBasis := NameMultiplier *
               StrToInt(FormatDateTime('yyyy',ThisDate)) /
               (StrToInt(FormatDateTime('d',ThisDate)) * StrToInt(FormatDateTime('m',ThisDate))) *
               multiplier;
  Password := copy(FloatToStr(PassBasis - Trunc(PassBasis)),3,FLengthPassword);
  Result := Password;
end;

function TAISQuickPW.IsValidSelections : Boolean;
begin
  Result := False;
  if ((FUserName <> '') and
     ((FSortMethod = stDateHour) or (FSortMethod = stDateOnly)) and
     (FLengthPassword > 0)) then
        Result := True;
end;

function TAISQuickPW.CreatePassword : String;
var
  NewPW : String;
begin
  Result := ''; { Default if error }
  if IsValidSelections then
    begin
      NewPW := ReturnPW(True);
      Result := NewPW;
    end;
end;

function TAISQuickPW.ValidatePassword(PWord : String) : boolean;
begin
  Result := False; { Default if error }
  if IsValidSelections then
    if  ReturnPW(False) = PWord then
      Result := True
    else
      Result := False;
end;

end.

