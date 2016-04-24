(*
  Category: SWAG Title: INPUT AND FIELD ENTRY ROUTINES
  Original name: 0025.PAS
  Description: Line Editor
  Author: MARK RAINEY
  Date: 09-04-95  10:45
*)

{
Attached is a very simple single line editor, possibly for inclusion in the
SWAG archive. It is written using Turbo/Borland Pascal object oriented 
extensions so should, in theory, be easy to use and modify :)

It supports the following keystrokes:

        Backspace           : Delete previous character
        Ctrl Backspace      : Delete string upto cursor
        Delete              : Delete next character
        Ctrl Delete         : Delete string after cursor
        Home                : Start of string
        End                 : End of string
        Left arrow          : Left one character
        Right arrow         : Right one character
        Ctrl+Left arrow     : Left one word
        Ctrl+Right arrow    : Right one word

It is setup by passing the coordinates where the field should be
displayed, the maximum length of the field and the character to use
for padding the field.

It is then called, passing in an initial value for the field which is
then amended, returning true if the enter key is pressed and false
if escape key is pressed.
}
UNIT Edit;

INTERFACE

TYPE
	TextLine	= Object
		Details		: String;
		CPos			: Byte;
		XPos			: Byte;
		YPos			: Byte;
		MaxLen		: Byte;
		PaddingChar	: Char;

		{ ********************************************************}
		{ PUBLIC METHODS }

		{
			SetupLimits - Set up initial values to be used:
				X		: X position for the field
				Y		: Y position for the field
				Max		: Max length of the field
				PadChar	: Character to use for padding the line
		}
		CONSTRUCTOR SetupLimits
			(
			X		: Byte;
			Y		: Byte;
			Max		: Byte;
			PadChar	: Char
			);

		{
			EditLine - Edit the line. 
				Supports
					Backspace			: Delete previous character
					Ctrl Backspace		: Delete string upto cursor
					Delete			: Delete next character
					Ctrl Delete		: Delete string after cursor
					Home				: Start of string
					End				: End of string
					Left arrow		: Left one character
					Right arrow		: Right one character
					Ctrl+Left arrow	: Left one word
					Ctrl+Right arrow	: Right one word

				StrEntered	: String to use. Set with start value then
							  returns value entered.
				Function returns true if enter pressed, false if escape
				pressed.
		}
		FUNCTION EditLine (VAR StrEntered	: String)	: Boolean;

		{ ********************************************************}
		{ PRIVATE METHODS - Do not call }

		PROCEDURE DisplayLine;
		FUNCTION AddChar (Ch	: Char)	: Boolean;
		FUNCTION DeletePrevChar	: Boolean;
		FUNCTION DeleteNextChar	: Boolean;

		{ ********************************************************}

	END;	

IMPLEMENTATION

USES
	Crt, Dos;


CONST
	End_Key		= #79;
	Left			= #75;
	Right		= #77;
	HomeKey		= #71;
	Backspace		= #8;
	CtrlBackspace	= #127;
	DeleteKey		= #83;
	CtrlDelete	= #6;
	CarrRet		= #13;
	Escape		= #27;
	CtrlLeft		= #115;
	CtrlRight		= #116;

CONSTRUCTOR TextLine.SetupLimits
	(
	X		: Byte;
	Y		: Byte;
	Max		: Byte;
	PadChar	: Char
	);

BEGIN
	CPos			:= 1;
	XPos			:= X;
	YPos			:= Y;
	MaxLen		:= Max;
	PaddingChar	:= PadChar;
END; { SetupLimits }


PROCEDURE TextLine.DisplayLine;

VAR
	Index	: Byte;

BEGIN
	GotoXY (XPos, YPos);
	Write (Details);
	FOR Index	:= 1 TO MaxLen - Length (Details) DO
		Write (PaddingChar);
	GotoXY (XPos+CPos, YPos);
END; { DisplayLine }


FUNCTION TextLine.AddChar (Ch	: Char)	: Boolean;

VAR
	AddedChar	: Boolean;

BEGIN
	AddedChar	:= TRUE;

	IF (CPos = Length (Details)) THEN
	BEGIN
		IF Length (Details) < MaxLen THEN
		BEGIN
			Details	:= Concat (Details, Ch);
			Inc (CPos);
		END { If }
		ELSE
			AddedChar	:= FALSE;
	END { If }
	ELSE
	BEGIN
		Inc (CPos);
		Insert (Ch, Details, CPos);
		IF Length (Details) > MaxLen THEN
			Delete (Details, Length(Details), 1);
	END; { Else }

	AddChar	:= AddedChar;
END; { AddChar }


FUNCTION TextLine.DeletePrevChar	: Boolean;

VAR
	DeletedChar	: Boolean;

BEGIN
	DeletedChar	:= TRUE;

	IF CPos < 1 THEN
		DeletedChar	:= FALSE
	ELSE

	IF CPos = Length (Details) THEN
	BEGIN
		Delete (Details, CPos, 1);
		Dec (CPos);
	END { If }
	ELSE

	BEGIN
		Delete (Details, CPos, 1);
		Dec (CPos);
	END; { Else }

	DeletePrevChar	:= DeletedChar;
END; { DeletePrevChar }


FUNCTION TextLine.DeleteNextChar	: Boolean;

VAR
	DeletedChar	: Boolean;

BEGIN
	DeletedChar	:= TRUE;

	IF (CPos >= Length (Details)) THEN
		DeletedChar	:= FALSE
	ELSE
		Delete (Details, CPos+1, 1);

	DeleteNextChar	:= DeletedChar;
END; { DeleteNextChar }


FUNCTION Textline.EditLine (VAR StrEntered	: String)	: Boolean;

VAR
	Ch		: Char;
	Changed	: Boolean;
	Accepted	: Boolean;
	Finished	: Boolean;
	
BEGIN
	Accepted		:= TRUE;
	Finished		:= FALSE;
	
	{ If they send in a string that is too large then trim it }
	IF Length (StrEntered) > MaxLen THEN
		Delete (StrEntered, MaxLen+1, Length (StrEntered));

	Details		:= StrEntered;
	CPos			:= Length (Details);

	DisplayLine;

	REPEAT
		Ch		:= Readkey;
		Changed	:= FALSE;

		IF Ch = #0 THEN
		BEGIN
			Ch	:= Readkey;
			CASE Ch OF
		     	End_Key	: BEGIN
					CPos		:= Length (Details);
					Changed	:= TRUE;
				END; { End_Key }

		     	HomeKey	: BEGIN
					CPos		:= 0;
					Changed	:= TRUE;
				END; { HomeKey }

		     	Left	: BEGIN
					IF CPos > 0 THEN
					BEGIN
						Dec (CPos);
						Changed	:= TRUE;
					END; { If }
				END; { Left }

		     	Right	: BEGIN
					IF CPos < Length (Details) THEN
					BEGIN
						Inc (CPos);
						Changed	:= TRUE;
					END; { If }
				END; { Right }

				CtrlLeft	: BEGIN
					IF (CPos > 0) THEN
						Dec (CPos);
					WHILE (CPos > 0) AND (Details [CPos] <> ' ') DO
						Dec (CPos);
					Changed	:= TRUE;
				END; { CtrlLeft }

				CtrlRight	: BEGIN
					IF (CPos < Length(Details)) THEN
						Inc (CPos);
					WHILE (CPos < Length(Details)) AND (Details [CPos] <> ' ') DO
						Inc (CPos);
					Changed	:= TRUE;
				END; { CtrlRight }

				CtrlDelete	: BEGIN
					Delete (Details, CPos+1, Length (Details));
					Changed	:= TRUE;
				END; { CtrlDelete }

				DeleteKey	: BEGIN	
					Changed	:= DeleteNextChar;
				END; { DeleteKey }
			END; { Case }
		END { If }
		ELSE

		BEGIN
			CASE Ch OF
				CtrlBackspace	: BEGIN	
					Delete (Details, 1, CPos);
					CPos		:= 0;
					Changed	:= TRUE;
				END; { CtrlBackspace }

				Backspace	: BEGIN	
					Changed	:= DeletePrevChar;
				END; { Backspace }

		     	CarrRet	: Finished	:= TRUE;

		     	Escape	: BEGIN
							Finished	:= TRUE;
							Accepted	:= FALSE;
				END; { Escape }

				' '..'}'	: BEGIN
					Changed	:= AddChar (Ch);
				END; { Ord (' ') }
			END; { Case }
		END; { Else }

		IF Changed THEN
			DisplayLine;
	UNTIL Finished;

	IF Accepted THEN
		StrEntered	:= Details;
	EditLine	:= Accepted;
END; { EditLine }


BEGIN
END.

