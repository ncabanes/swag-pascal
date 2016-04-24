(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0209.PAS
  Description: TP6-7 example of Eliza
  Author: SWAG SUPPORT TEAM
  Date: 01-02-98  07:34
*)

Program Eliza;

{ Command line:  Eliza_tp [path of Eliza.dat]

  The one command line parameter (optional) is the path where the file
  Eliza.dat can be found if not that file is not in the directory where
  Eliza_tp.exe is found.  }

{$IFDEF Print}
	Uses CRT, Printer;
{$ELSE}
	Uses CRT;
{$ENDIF}

Const
	Key_Rec_headr_len = 12;
	Reply_rec_headr_len = 5;

Type
	Key_Ptr   = ^Key_rec;							{Pointer to key record }
	Reply_Ptr = ^Reply_rec;

	Key_rec   = record                        { Key record stores the key phrase }
					 Next_key_rec : Key_Ptr; 		{ 4 bytes }
					 P_flag : byte;               { 1 byte  }
					 Numb_Reply : integer;        { 2 bytes }
					 Reply_list : Reply_Ptr;  	   { 4 bytes }
					 Key_Str : String[16];	  	   { 1 byte (length) }
				  end;                       		{ 12 bytes in header }

	Reply_rec  = record                       { Reply record stores a response to the key phrase }
						Next_reply_rec : Reply_Ptr; 	{ 4 bytes }
						Reply_Str : String[120]; 		{ 1 byte (length) }
					 end;                       		{ 5 bytes in header }

	MaxStr = String[80];
	Max_Dat_Len = String[120];

Const
	Top_Key : Key_Ptr = Nil; 						{ Initialize Pointer }
	First_Key : Key_Ptr = Nil;						{ Initialize Pointer }
	Curr_Key : Key_Ptr = Nil;						{ Initialize Pointer }
	First_Reply : Reply_Ptr = Nil;				{ Initialize Pointer }
	Curr_Reply : Reply_Ptr = Nil;					{ Initialize Pointer }
	Number_Replies : Integer = 0;					{ Initialize count	}
	P_Flag : Byte = 1;								{ Initialize }
	FileName : String = 'Eliza.dat';				{ Name of data file  }

Var
	s	: Max_Dat_Len;
	Input_String : MaxStr;
	Rest_of_Input : MaxStr;
	Old_Inp_Str : MaxStr;
	Pronouns : Array[1..19,1..2] of String[12];
	K_Last : Boolean;

(*************************************************************************)

Procedure Store_Key_Record(var Curr_Key : Key_ptr);

{ Store a key phrase into the threaded list of key phrases, to conserve memory
  the length of the key phrase is determined and only enough memory to store
  the phrase is obtained.              }

Var
	PktLen, Strlen : Integer;
	Prev_Key : Key_ptr;

Begin
	Strlen := ord(s[0]);								{ Get Length of string}
	PktLen := StrLen + Key_rec_headr_len;		{ Calculate size of packet }
	Prev_Key := Curr_Key;							{ Save Pointer to previous }
	GetMem(Curr_Key,PktLen);						{ Get Memory of PktLen Size }

	If Top_Key = Nil then
		begin
			Top_Key := Curr_Key;						{ Base of threaded list }
			First_Key := Curr_key;					{ First of this set of keys}
			Prev_Key := Nil;							{ Initialize Prev_Key pointer }
		end else
			begin
				if First_key = Nil then First_Key := Curr_key;	{ Start New Set of Keys}
			end;

	Curr_Key^.Key_Str := Copy(s,1,StrLen); { Copy string to packet }
	Prev_Key^.Next_key_Rec := Curr_Key;
	Curr_Key^.Next_key_Rec := Nil;
	Curr_key^.Numb_Reply := 0;
	Curr_key^.P_Flag := 1;
	Curr_Key^.Reply_list := Nil;

End;														{ End Store_Key_Record }

(*************************************************************************)

Procedure Store_Reply_Record(var Curr_Reply : Reply_ptr);

{ Key phrases are grouped together followed by replies to those phrases.
  For each group of key phrase there is one or more replies.  The possible
  replies to a key phrase are threaded to the packet on the threaded list of
  key phrases.

  key1
	|
  \ /
  key2 ----> reply_a
	|         |
	|        \ /
	|         reply_b
	|         |
	|        \ /
	|         reply_c
	|         |
	|			\ /
	|         etc.; thread of all replies to key1
  \ /
	key3  ----> reply_d
	|           |
	|          \ /
	|           etc.; thread of all replies to key2
  \ /
	etc.; thread of all key phrase groups                    }

Var
	PktLen, Strlen : Integer;
	Prev_Reply : Reply_ptr;

Begin
	Strlen := ord(s[0]);								{ Get Length of string}
	PktLen := StrLen + Reply_rec_headr_len;	{ Calculate size of packet }
	Prev_Reply := Curr_Reply;						{ Save Pointer to previous }
	GetMem(Curr_Reply,PktLen);						{ Get Memory of PktLen Size }

	If (Top_Key = Nil) or (First_Key = Nil) then
		begin
		Writeln('* * * E R R O R * * * Reply found before first key')
		end else
			begin
				if First_Reply = Nil then First_Reply := Curr_Reply;	{ Start New Set of Keys}
			end;

	Curr_Reply^.Reply_Str := Copy(s,1,StrLen); { Copy string to packet }
	Prev_Reply^.Next_Reply_Rec := Curr_Reply;
	Curr_Reply^.Next_Reply_Rec := Nil;
	Number_Replies := Number_Replies + 1;

End;                                { End of Store_Reply_Record }

(*************************************************************************)

Procedure Thread_Reply;					{ Thread Replies to Keys }

Var
	Curr_Ptr : Key_Ptr;

Begin
	Curr_Ptr := First_Key;			{ Point to First Key }

	While Curr_Ptr <> Nil do
		Begin
			Curr_Ptr^.Numb_Reply := Number_Replies;
			Curr_Ptr^.Reply_list := First_Reply;
			Curr_Ptr := Curr_Ptr^.Next_key_rec;
			Curr_Ptr^.P_Flag := P_Flag;
		End;

	First_Reply := Nil;
	Number_Replies := 0;
	First_Key := Nil;

End;

(*************************************************************************)

Procedure Input_data;

{ Reads the file Eliza.dat which contains the key phrases and the replies
  to those key phrases.  This file is an ASCII file.  Each key phrase must
  be immediately followed by all possible replies to the phrase. The field ID
  identies the "type" of the record. There four types, see case statement
  below, (note that an cross-hatch allows you to put whitespace and comments in
  the file.	}

Var
	InputFile : Text;
	ID : char;
	b : char;                        { Char to skip blank when reading }
	IOCode, Len : Integer;
	Path : String;

Begin;
	Path := ParamStr(1);					{ 1 parameter is expected: the path where
												  Eliza.dat will be found }
	FileName := Path + FileName;		{ Concatenate Path and File Name }

{$IFDEF Test}
	Writeln('Path = ',Path, '  File Name = ',FileName);
{$ENDIF}

	Assign(InputFile,FileName);	   { Assign input file name }
	Reset(InputFile);						{ Prepare InputFile to be read }
	IOCode := IOresult;					{ Save the return code }

	if IOCode = 0 then
	begin
		While Not EOF(Inputfile) do		{ Read Until End of File }
			begin
				Readln(InputFile,s);			{ Read Data };
				If IOResult <> 0 then Writeln('I/O Error, code = ',IOResult);
				ID := s[1];
				Len := Length(s);
				If Len > 2 then s := Copy(s, 3, Len-2);
				If s[1] <> ' ' Then s := ' ' + s;		{ add a leading blank }
				If s[Length(s)] <> ' ' Then s := s + ' '; { add a trailing blank }
				case ID of
					'K' :  begin
								If First_Reply <> Nil Then Thread_Reply;
								Store_Key_Record(Curr_Key);		{ Call Procedure to store key }
							 end;
					'R' : Store_Reply_Record(Curr_Reply);	{ Call procedure to store reply }
					'P' : P_Flag := 0;
					'#' :
				else
					Writeln('Error reading Eliza.dat, invalid record ID');
					Writeln('RECORD: ',s);
				end;
			end;   			{ End of while }

		If IOResult <> 0 then Writeln('I/O Error, code = ',IOResult);
		If First_Reply <> Nil Then Thread_Reply;
	end;
end;

(*************************************************************************)

Function UpCaseStr(s : MaxStr) : MaxStr;		{ Convert String to all uppper Case }
Var
	i,j : Integer;
Begin
	j := Ord(s[0]);
	For i := 1 to j Do
		s[i] := Upcase(s[i]);
	UpCaseStr := s;
End;

(*************************************************************************)
Procedure Replace_Pronouns(var Rest_of_Input : MaxStr);

Const
	Init : Boolean = True;

Var
	i, l, L1 ,Len : integer;
	Str : MaxStr;

Begin
	If Init then
		Begin
			{ all pronouns in column 1 must     all pronouns in column 2 must
					be UPPER CASE                      be lower case
					-------------							  -------------
					column 1 pronouns are replace by the column 2 entry    }

			Pronouns[1,1] := 'MY SELF';  		Pronouns[1,2] := 'your self';
			Pronouns[2,1] := 'YOURSELF';		Pronouns[2,2] := 'my self';
			Pronouns[3,1] := 'YOURSELVES';	Pronouns[3,2] := 'ourselves';
			Pronouns[4,1] := 'OURSELVES';		Pronouns[4,2] := 'yourselves';
			Pronouns[5,1] := ' YOU ARE ';		Pronouns[5,2] := ' i am ';
			Pronouns[6,1] := ' I AM ';			Pronouns[6,2] := ' you are ';
			Pronouns[7,1] := ' WERE ';			Pronouns[7,2] := ' was ';
			Pronouns[8,1] := ' WAS ';			Pronouns[8,2] := ' were ';
			Pronouns[9,1] := ' YOUR ';			Pronouns[9,2] := ' my ';
			Pronouns[10,1] := ' I''VE ';		Pronouns[10,2] := ' you''ve ';
			Pronouns[11,1] := ' YOU''VE ';	Pronouns[11,2] := ' i''ve ';
			Pronouns[12,1] := ' I''M';			Pronouns[12,2] := ' you''re ';
			Pronouns[13,1] := ' YOU''RE ';	Pronouns[13,2] := ' i''m ';
			Pronouns[14,1] := ' AM ';			Pronouns[14,2] := ' are ';
			Pronouns[15,1] := ' ARE ';			Pronouns[15,2] := ' am ';
			Pronouns[16,1] := ' I ';			Pronouns[16,2] := ' you ';
			Pronouns[17,1] := ' YOU ';			Pronouns[17,2] := ' i ';
			Pronouns[18,1] := ' ME ';			Pronouns[18,2] := ' you ';
			Pronouns[19,1] := ' MY ';			Pronouns[19,2] := ' your ';

		Init := False;
	End;

	For i := 1 to 19 Do
	Begin
		Len := Length(Pronouns[i,1]);
		L := Pos(Pronouns[i,1],Rest_of_Input);

		While L <> 0 Do
			Begin
					Delete(Rest_of_Input,L,Len);						{ Delete the Pronouns}
					Insert(Pronouns[i,2],Rest_of_Input,L);
					L := Pos(Pronouns[i,1],Rest_of_Input);
			End;

	 End;
    Delete(Str,1,1);
	 Rest_of_Input := UpCaseStr(Rest_of_Input);
End;

(*************************************************************************)

Procedure Find_key( Input_String : MaxStr;var Curr_Ptr : Key_Ptr; var K_Last : Boolean);	{ Find Keys }

Var
	Prev_Ptr : Key_Ptr;
	L,Start,Len : Integer;

Begin
	L := 0;
	Prev_Ptr := Nil;
	Curr_Ptr := Top_Key;						{ Point to First Reply }

	While (Curr_Ptr <> Nil) and (L = 0) do
		Begin
			L := Pos(Curr_Ptr^.Key_str,Input_String);
			If L <> 0 then
				Begin
					Len := Length(Input_String) - L - 1;
					Start := L + Length(Curr_Ptr^.Key_str); { copy rest of string, but not space }
					Rest_of_Input := Copy(Input_String,Start,Len);
					Prev_Ptr := Curr_Ptr;
					Curr_Ptr := Nil;		 				{ Force exit from loop }
				End else
					Begin
						Prev_Ptr := Curr_Ptr;
						Curr_Ptr := Curr_Ptr^.Next_key_rec;
					End;
			End;			{ end of while }

	If Curr_Ptr = Nil then Curr_Ptr := Prev_Ptr;
	K_Last := False;
	If (Pos(Curr_Ptr^.Key_Str,'Klast') <> 0) then K_Last := True;
End;

(*************************************************************************)

Procedure Build_Reply(Input_String : MaxStr; var Numb_Replies : Integer; var P_Flag : Byte);

Const
	Ast : String[1] = '*';
	Blank : String[1] = ' ';

Var
	I, Rand, L : Integer;
	RRand : Real;
	Curr_Reply_Ptr : Reply_Ptr;
	Curr_Ptr : Key_Ptr;

Begin
	Rest_of_Input := Input_String;
	RRand := Random;												{ Generate a Random number }

	If P_Flag = 82 then Find_Key('KY', Curr_Ptr, K_Last)
		Else If (RRand < 0.03) then Find_Key('KZ', Curr_Ptr, K_Last) 	{ 3% of the time pick KZ key }
			Else Find_Key(Input_String, Curr_Ptr, K_Last);

	Rand := Random(Curr_Ptr^.Numb_Reply);
	Numb_Replies := Curr_Ptr^.Numb_Reply;
	Curr_Reply_Ptr := Curr_Ptr^.Reply_list;

{ Loop to reply selected by random number }

	If Rand <> 0 then
		Begin
			For I := 1 to Rand Do
					Curr_Reply_Ptr := Curr_Reply_Ptr^.Next_Reply_Rec;
		End;

	s := Curr_Reply_Ptr^.Reply_str;	{ Save Reply }
	If P_Flag = 82 then Rest_of_Input := Input_String;
	L := Length(Rest_of_Input);
	If L > 0 then
		if (Rest_of_Input[L-1] = '?') or (Rest_of_Input[L-1] = '.') then
			Delete(Rest_of_Input,L-1,1);               { Delete the punctuation }

	{ Does the reply contain an asterisk? }
	L := Pos(Ast,s);
	If L <> 0 Then
		Begin
			Delete(s,L-1,2);				{ Delete the  * }
			L := L - 1;						{ Adjust for deletions }
			If ((Length(s) - L) >= 0) then
				Begin
					if (Rest_of_Input[1] <> ' ') then Rest_of_Input := ' ' + Rest_of_Input;
					if (s[L] = ' ') then Delete(s,L,1);
					Replace_Pronouns(Rest_of_Input);
					if Rest_of_Input[Ord(Rest_of_Input[0])] = ' ' then
							Delete(Rest_of_Input,Ord(Rest_of_Input[0]),1);
					Insert(Rest_of_Input,s,L);
					if (s[L+Length(Rest_of_Input)] <> '?') and
						(s[L+Length(Rest_of_Input)] <> '.') and
						(s[L+Length(Rest_of_Input)] <> '!') and
						(s[L+Length(Rest_of_Input)] <> ' ') then
					Insert(blank,s,L+Length(Rest_of_Input));      { if not punctuation then insert a blank }
				End;
		End;

	P_Flag := Curr_ptr^.P_Flag;

{$IFDEF Test}
	Writeln(s);
	Writeln('Found key ',Curr_Ptr^.Key_str,' in string ');
	Writeln(Input_String,' at byte ',L);
{$ENDIF}

End;

(*************************************************************************)
{		MAIN Routine																		  }

Const
	P1 : Boolean = False;

Var
	Numb_Replies : Integer;
	Old_s : MaxStr;
	Save_Input_String : MaxStr;

Begin
	ClrScr;
	Randomize;								{ Initialize Seed }

{$IFDEF Test}
	WriteLn(MemAvail, ' bytes available at start');
	WriteLn('Largest Free Block ', MaxAvail, ' bytes at start');
{$ENDIF}

	Input_data;								{ Read Data and InitializeKey and Reply lists }
	WriteLn('Hello, I''m your computerized psychiatrist. What is your problem?');

	Repeat
			Old_Inp_Str := Input_String;
			Readln(Input_String);
			Input_String := ' ' + UpCaseStr(Input_String) + ' ';
			If Old_Inp_Str = Input_String then WriteLn('DON''T REPEAT YOURSELF')
				else If (Pos('BYE',Input_String) = 0) and (Pos('GOODBY',Input_String) = 0) Then
						  Begin
							 Old_s := s;
							 Build_Reply(Input_String, Numb_Replies, P_Flag);
							 If (Numb_Replies > 1) and (s = Old_s) then
                        Build_Reply(Input_String, Numb_Replies, P_Flag);
							 If (Random < 0.25) and (P_Flag <> 0) then
								Begin
									P1 := True;
									Save_Input_String := Input_String;
								End
							 Else if (K_Last and P1) Then
								Begin
									P1 := False;
									P_Flag := 82;
									Build_Reply(Save_Input_String, Numb_Replies, P_Flag);
								End;
							 WriteLn(s);

							 {$IFDEF Print}
								Writeln(Lst,Input_String);
								Writeln(Lst,s);
							 {$ENDIF}

						  End;
	Until (Pos('BYE',Input_String) <> 0) or (Pos('GOODBY',Input_String) <> 0);

	Writeln('Its been good talking with you. Whenver you feel a need to talk stop by again.');
	Delay(1500);

{$IFDEF Test}
	WriteLn(MemAvail, ' bytes available at end');
	WriteLn('Largest Free Block ', MaxAvail, ' bytes at end');
{$ENDIF}

End.
