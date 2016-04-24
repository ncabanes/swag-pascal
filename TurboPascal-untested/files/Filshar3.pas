(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0010.PAS
  Description: FILSHAR3.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:46
*)

FileSHARinG !


When sharing Files concurrently, by means of For example a multitasker or a
network, it is necessary to use the File sharing as provided by the Dos
command SHARE, or as provided by a Network shell (In Novell File sharing is
supported by the network shell on Servers, not locally. Check your network
documentation For more inFormation).

File sharing is simple in TP/BP, since the system Variable FileMode defines
in what mode a certain File is opened in:

Const
   fmReadOnly  = $00;  (* *)
   fmWriteOnly = $01;  (* Only one of these should be used *)
   fmReadWrite = $02;  (* *)

   fmDenyAll   = $10;  (* together With only one of these  *)
   fmDenyWrite = $20;  (* *)
   fmDenyRead  = $30;  (* *)
   fmDenyNone  = $40;  (* *)

   fmNoInherit = $70;  (* Set For "No inheritance"         *)


Construction the FileMode Variable is easy, just add the appropriate values:

FileMode:=fmReadOnly+fmDenyNone;
      (Open File For reading only, allow read and Write.)

FileMode:=fmReadWrite+fmDenyWrite;
      (Open File For both read and Write, deny Write.)

FileMode:=fmReadWrite+fmDenyAll;
      (Open File For both read and Write, deny all.)

Say you open the File in "fmReadWrite+fmDenyWrite". This will let you read
and Write freely in the File, While other processes can freely read the File.
if another process tries to open the File For writing, that process will get
the error "Access denied".

(fmNoInherit is seldom used - it defines if a childprocess spawn from your
process will be able to use the Filehandle provided by your process.)

The FileMode Variable is only used when the File is opened;

 ...
Assign(F,FileName);
FileMode:=fmReadOnly+fmDenyNone;
Reset(F);
FileMode:=<Whatever>    (* Changing FileMode here does not affect the
                           Files already opened *)

By default, FileMode is defined as FileMode:=$02 in TP/BP, this is referred
to as "Compatibility mode" in the TP/BP docs. Two processes accessing the
same File With this Filemode results in the critical error "Sharing
violation".
----------------------------------------------------------------------

