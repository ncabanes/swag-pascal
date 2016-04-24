(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0270.PAS
  Description: Global Message handler
  Author: CHAMI
  Date: 05-30-97  18:17
*)

If you display more than a few [error] messages in your application,
using a simple method such as the following may not be the best approach:
Application.MessageBox(
  'File not found', 'Error', mb_OK );


Above method of displaying errors will make it harder to modify actual
messages since they are distributed all over your application source
code. It may be better to have a "centralized" function that can display
error messages, or better yet, a centralized function that can display
replaceable error messages. Consider the following example:

type
  cnMessageIDs =
    (
      nMsgID_NoError,
      nMsgID_FileNotFound,
      nMsgID_OutOfMemory,
      nMsgID_ExitProgram
      // list your other error
      // IDs here...
    );

const
  csMessages_ShortVersion
    : array [ Low( cnMessageIDs )..
              High( cnMessageIDs ) ]
      of PChar =
    (
      'No error',
      'File not found',
      'Out of memory',
      'Exit program?'
      // other error messages...
    );

  csMessages_DetailedVersion
    : array [ Low( cnMessageIDs )..
              High( cnMessageIDs ) ]
      of PChar =
    (
      'No error; please ignore!',

      'File c:\config.sys not found.'+
      'Contact your sys. admin.',

      'Out of memory. You need '+
      'at least 4M for this function',

      'Exit program? '+
      'Save your data first!'
      // other error messages...
    );


procedure MsgDisplay(
  cnMessageID : cnMessageIDs );
begin
  // set this to False to display
  // short version of the messages
  if( True )then
    Application.MessageBox(
      csMessages_DetailedVersion[
        cnMessageID ],
      'Error',
      mb_OK )
  else
    Application.MessageBox(
      csMessages_ShortVersion[
        cnMessageID ],
      'Error',
      mb_OK );
end;


Now, whenever you want to display an error message, you can call the
MsgDisplay() function with the message ID rather than typing the
message itself:

MsgDisplay( nMsgID_FileNotFound );


MsgDisplay() function will not only let you keep all your error messages
in one place -- inside one unit for example, but it will also let you
keep different sets of error messages -- novice/expert, debug/release,
and even different sets for different languages.
