{
  Here's the demo Program I promised. You'll have to add the missing
  Type definitions before you will be able to run this Program.
}

Program Demo_Read_User_Files;

Type

  (* NOTE: Missing Type definitions need to go here, before this      *)
  (*       Program will compile.                                      *)
  (*                                                                  *)
  (*   ie: uflags, suflags, acrq, mhireadr, mzscanr, fzscanr,         *)
  (*       colors.                                                    *)
  (*                                                                  *)

  (* USERS.IDX : Sorted names listing                     *)
  UserIdxRec = Record
    Name     : String[36];   (* Name (Real or handle) *)
    Number   : Integer;      (* User number           *)
    RealName : Boolean;      (* User's Real name?     *)
    Deleted  : Boolean;      (* Deleted or not        *)
    Left     : Integer;      (* Record or -1          *)
    Right    : Integer;      (* Record or -1          *)
  end;

  (* USERS.DAT : User Records                             *)
  UserRec = Record
    Name           : String[36];     (* System name      *)
    RealName       : String[36];     (* Real name        *)
    PW             : String[20];     (* PassWord         *)
    Ph             : String[12];     (* Phone #          *)
    BDay           : String[8];      (* Birthdate        *)
    FirstOn        : String[8];      (* First on date    *)
    LastOn         : String[8];      (* Last on date     *)
    Street         : String[30];     (* Street address   *)
    CityState      : String[30];     (* City, State      *)
    ZipCode        : String[10];     (* Zipcode          *)

                                     (* Type of computer *)
    UsrDefStr      : Array[1..3] of String[35];

    (* Occupation                                           *)

    (* BBS reference                                        *)
    Note           : String[35];     (* SysOp note       *)
    UserStartMenu  : String[8];      (* Menu to start at *)
    LockedFile     : String[8];      (* Print lockout msg*)
    Flags          : set of uflags;  (* Flags            *)
    SFlags         : set of suflags; (* Status flags     *)
    AR             : set of acrq;    (* AR flags         *)

                                     (* Voting data      *)
    Vote           : Array[1..25] of Byte;

    Sex            : Char;           (* Gender           *)
    TTimeOn,                         (* Total time on    *)
    UK,                              (* UL k             *)
    DK             : LongInt;        (* DL k             *)
    TLToday,                         (* # Min left today *)
    ForUsr,                          (* Forward mail to  *)
    FilePoints     : Integer;        (* # Of File points *)

    UpLoads, DownLoads,              (* # Of ULs/# of DLs*)
    LoggedOn,                        (* # Times on       *)
    MsgPost,                         (* # Message posts  *)
    EmailSent,                       (* # Email sent     *)
    Feedback,                        (* # Feedback sent  *)
    Timebank,                        (* # Mins in bank   *)
    TimebankAdd,                     (* # Added today    *)
    DlKToday,                        (* # KBytes dl today*)
    DlToday        : Word;           (* # Files dl today *)

    Waiting,                         (* Mail waiting     *)
    LineLen,                         (* Line length      *)
    PageLen,                         (* Page length      *)
    OnToday,                         (* # Times on today *)
    Illegal,                         (* # Illegal logons *)
    Barf,
    LastMBase,                       (* # Last msg base  *)
    LastFBase,                       (* # Last File base *)
    SL, DSL        : Byte;           (* SL / DSL         *)

    (* Message last read date ptrs      *)
    MHiRead         : mhireadr;
    (* Which message bases to scan      *)
    MzScan          : mzscanr;
    (* Which File bases to scan         *)
    FzScan          : fzscanr;

    (* User colors                      *)
    Cols            : colors;

    Garbage         : Byte;

    (* Amount of time Withdrawn today   *)
    TimebankWith    : Word;
    (* Last day PassWord changed        *)
    PassWordChanged : Word;
    (* Default QWK archive Type         *)
    DefArcType      : Byte;
    (* Last conference they were in     *)
    LastConf        : Char;
    (* Date/time of last qwk packet     *)
    LastQwk         : LongInt;
    (* Add own messages to qwk packet?  *)
    GetOwnQwk       : Boolean;
    (* Scan File bases For qwk packets? *)
    ScanFilesQwk    : Boolean;
    (* Get private mail in qwk packets? *)
    PrivateQwk      : Boolean;
    (* Amount of credit a User has      *)
    Credit          : LongInt;
    (* Amount of debit a User has       *)
    Debit           : LongInt;
    (* Expiration date of this User     *)
    Expiration      : LongInt;
    (* Subscription level to expire to  *)
    ExpireTo        : Char;
    (* User's color scheme #            *)
    ColorScheme     : Byte;
    (* Echo Teleconf lines?             *)
    TeleConfEcho    : Boolean;
    (* Interrupt during typing?         *)
    TeleConfInt     : Boolean;
  end;


(***** Check For IO error, and take some sort of action?            *)
(*                                                                  *)
Procedure CheckForIOerror;
Var
  in_Error : Integer;
begin
  in_Error := ioresult;
  if (in_Error <> 0) then
    begin
      Writeln(' I/O Error = ', in_Error);

      (* Take some sort of action to correct error, or halt Program *)

    end
end;        (* CheckForIOerror.                                     *)


Var
  rc_TempUI   : UserIdxRec;
  rc_TempUR   : UserRec;

  fi_UsersIdx : File of UserIdxRec;
  fi_UsersDat : File of UserRec;

begin
              (* Open USERS.IDX File.                                 *)
  assign(fi_UsersIdx, 'USERS.IDX');
  {$I-}
  reset(fi_UsersIdx);
  {$I+}
  CheckForIOerror;

              (* Read first Record from File.                         *)
  read(fi_UsersIdx, rc_TempUI);
  CheckForIOerror;

              (* Display data from the first Record.                  *)
  With rc_TempUI do
  begin
    Writeln('Name      = ', Name);
    Writeln('Number    = ', Number);
    Writeln('Real Name = ', RealName);
    Writeln('Deleted   = ', Deleted);
    Writeln('Left      = ', Left);
    Writeln('Right     = ', Right)
  end;

              (* Read 10th Record from File.                          *)
  seek(fi_UsersIdx, pred(10));
  read(fi_UsersIdx, rc_TempUI);
  CheckForIOerror;

              (* Display data from the 10th Record.                   *)
  With rc_TempUI do
  begin
    Writeln('Name      = ', Name);
    Writeln('Number    = ', Number);
    Writeln('Real Name = ', RealName);
    Writeln('Deleted   = ', Deleted);
    Writeln('Left      = ', Left);
    Writeln('Right     = ', Right)
  end;

              (* Close USERS.IDX File.                                *)
  close(fi_UsersIdx);
  CheckForIOerror;

              (* Open USERS.DAT File.                                 *)
  assign(fi_UsersDat, 'USERS.DAT');
  {$I-}
  reset(fi_UsersDat);
  {$I+}
  CheckForIOerror;

              (* Read first Record from File.                         *)
  read(fi_UsersDat, rc_TempUR);
  CheckForIOerror;

              (* Display data from the first Record.                  *)
  With rc_TempUR do
    begin
      Writeln('Name      = ', Name);
      Writeln('Real Name = ', RealName);
      Writeln('Street    = ', Street);
      Writeln('CityState = ', CityState);
      Writeln('ZipCode   = ', ZipCode);
      Writeln('Sex       = ', Sex)
    end;

              (* Read 10th Record from File.                          *)
  seek(fi_UsersDat, pred(10));
  read(fi_UsersDat, rc_TempUR);
  CheckForIOerror;

              (* Display data from the 10th Record.                   *)
  With rc_TempUR do
    begin
      Writeln('Name      = ', Name);
      Writeln('Real Name = ', RealName);
      Writeln('Street    = ', Street);
      Writeln('CityState = ', CityState);
      Writeln('ZipCode   = ', ZipCode);
      Writeln('Sex       = ', Sex)
    end;

              (* Close USERS.DAT File.                                *)
  close(fi_UsersDat);
  CheckForIOerror;

end.

