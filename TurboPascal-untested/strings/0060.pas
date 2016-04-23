Unit BoolPos;

{        Version 1.3.3.P.

        Requires Borland Turbo Pascal version 6.0 or later to compile.

        Author:  Bruce J. Lackore.  Created Friday, July 23, 1993.
        Copyright (c) 1993 Bruce J. Lackore.  ALL RIGHTS RESERVED.
}

{$IFDEF Test}
        {$A+,B-,D+,F-,G-,I+,L+,O-,R+,S+,V-,X+}
{$ELSE}
        {$A+,B-,D-,F-,G-,I-,L-,O-,R-,S-,V-,X+}
{$ENDIF}

{        This unit comprises a function capable of searching a string for multiple
        occurences of substrings using Boolean operators.  In the search string,
        Boolean operators And and Or are defined as follows:

                & - And
                | - Or

        Parentheses are supported for doing multiple searches.  Search strings are
        submitted as follows:

                i.e. In the source string "The quick brown fox jumped over the lazy dog"
                                        and the search is for the word blue and the words quick or fox,
                                        the search string is entered as follows:

                                                (blue&(quick|fox))

        The way the function is currently written, And (&) and Or (|) have the same
        precedence level hence the above search string without parentheses would be
        interpretted to be (blue&quick|fox):

                blue And quick would be searched for first, the result Or'd with the
                results of the search for fox.

        Notice the difference in that (blue&(quick|fox)) is a False statement whilst
        (blue&quick|fox) is True.

        The function will automatically scan for () pairs, adding the necessary )
        at the end of the search string or ( at the beginning if required.

        The function will also search for (|, |), (& and &) symbols, these being
        illegal.

}

{        Bug fixes:

                10/04/1993:        Noticed that length of Src_str in function Next_CPos was
                                                                incorrectly calculated because of positioning of INC DI.
                                                                INC DI precedes the MOV CL,[ES:DI] causing the function to
                                                                consider the first character of Src_str to represent the
                                                                length rather than the actual length byte.  Fix is to move
                                                                the INC DI to the line following the MOV CL,[ES:DI].
}

Interface

Function BPos(Srch_str, Src_str:  String;  Ignore_case:  Boolean):  Boolean;

{        This function accepts a source string and a search string as described above
        and returns a Boolean value based on whether or not the parsed search
        string was found.
}

{ ************************************************************************** }

Implementation

Const
        Lt_pn:                                                                                Char = '(';
        Rt_pn:                                                                                Char = ')';

Function Cnt_ch(Scan_char:  Char;  In_str:  String):  Byte;  Assembler;

{        This function will scan a string for occurences of a particular character.
        The function will return the number of occurences.
}

        Asm  { Function Cnt_ch }
                                                        XOR                AX,AX                                        {        0 AX }
                                                        MOV                BL,Scan_char  {        Put char to count in BL }
                                                        LES                SI,In_str     {        Set ES:SI to point to start of string }
                                                        XOR                CX,CX         {        0 CX }
                                                        MOV                CL,[ES:SI]    {        Move string length to CX }
                                                        ADD                SI,CX         {        Set ES:SI to point to END of string }
                @LOOK:                CMP                BL,[ES:SI]    {        Start Loop, compare current char and BL }
                                                        JNE                @NEXT         {        If not equal, jump to end of loop }
                                                        INC                AX            { If equal, Inc char cnt (AX) }
                @NEXT:                DEC                SI            {        Set ES:SI back one character }
                                                        LOOP        @LOOK         {        Decrement CX and jump to start of loop }
        End;  { Function Cnt_ch }

Function Fill_str(Dupe_ch:  Char;  How_many:  Byte):  String;  Assembler;

{        This function returns How_many of Dupe_char.
}

        Asm  { Function Fill_str }
                                                        LES                DI, @Result                {        Set ES:DI to function result area }
                                                        CLD                 {        Clear direction flag }
                                                        XOR         CH,CH         {        0 CH }
                                                        MOV         CL,How_many          { Length in CX }
                                                        MOV         AX,CX                { and in AX }
                                                        STOSB                     { Store length byte }
                                                        MOV         AL,Dupe_ch    {        Put char to dupe in AL }
                                                        REP         STOSB         { Fill string with char }
        End;  { Function Fill_str }

Function PosC(Srch_ch:  Char;  Src_str:  String):  Boolean;  Assembler;

{        This function is similar to the Pos function of Pascal except that it
        accepts only a single character to search for.  This function returns a
        True if a Srch_ch is encountered, a False if not.
}

        Asm  { Function PosC }
                                                        XOR                BX,BX                                        {        0 BX }
                                                        MOV                AL,Srch_ch    {        Put char to look for in AL }
                                                        LES                DI,Src_str    {        Set ES:DI to start of Src_str }
                                                        XOR                CX,CX         {        0 CX }
                                                        MOV                CL,[ES:DI]    {        Store length of Src_str in CL }
                                                        ADD                DI,CX         {        Set ES:DI to end of string }
                                                        STD                 {        Set direction flag }
                @LOOK:                REPNZ        SCASB         {        Look for AL in Src_str }
                                                        JNZ                @DONE         {        If not found, jump to end (BX = 0) }
                                                        INC                BX            {        If Found, Inc Bx  to 1 = Pascal True }
                @DONE:                MOV                AX,BX         {        Move BX to AX (return result) }
        End;  { Function PosC }

Function Last_Cpos(Srch_ch:  Char;  Src_str:  String):  Byte;  Assembler;

{        This function performs the same function as the Pascal POS function except
        that it works only with a single character and rather than returning the
        first position the character is found in, it returns the LAST position that
        the search character is found in.
}

        Asm { Function Last_Cpos }
                                                        MOV                AL,Srch_ch                {        Put char to look for in AL }
                                                        LES                DI,Src_str    {        Set ES:DI to start of Src_str }
                                                        XOR                CX,CX         {        0 CX }
                                                        MOV                CL,[ES:DI]    {        Move length of Src_str to CL }
                                                        ADD                DI,CX         {        Set ES:DI to end of Src_str }
                                                        INC                CX            { Add one to CX (correct for string length }
                                                        STD                 {        Set direction flag }
                                                        REPNZ        SCASB         {        Look for character in string }
                                                        MOV                AX,CX         { If found CX indicates position, else 0 }
        End;  { Function Last_Cpos }

Function Next_CPos
        (Srch_ch:  Char;  Src_str:  String;  Strt_at:  Byte):  Byte;  Assembler;

{        This function searches for the next occurence of Srch_ch in Src_str AFTER
        position Strt_at.  The function returns the offset from the beginning of
        the string, NOT the offset from Strt_at.
}

        Asm  { Function Next_CPos }
                                                        XOR                AX,AX         {        0 AX }
                                                        MOV                AL,Strt_at    {        Move position to start at to AL }
                                                        LES                DI,Src_str    {        Set ES:DI to start of Src_str }
                                                        XOR                CX,CX         {        0 CX }
                                                        MOV                CL,[ES:DI]    {        Store length of Src_str in CL }
                                                        INC                DI            {        Set ES:DI to first char of Src_str }
                                                        MOV                BX,CX         {        Move CX to BX }
                                                        SUB                CX,AX         {        Set CX to length of string after Strt_at }
                                                        ADD                DI,AX         {        Set ES:DI to char at Strt_at in Src_str }
                                                        MOV                AL,Srch_ch    {        Move Srch_ch to AL }
                                                        CLD                 {        Clear direction flag }
                                                        REPNZ        SCASB         {        Look for character following Strt_at }
                                                        JNZ                @NOTFND       {        If not found, jump to end of procedure }
                                                        SUB                BX,CX         {        Set BX to position char found in }
                                                        JMP                @DONE         {        Jump to end of procedure }
                @NOTFND:        XOR                BX,BX         {        Srch_ch not found, set BX to 0 }
                @DONE:                MOV                AX,BX         {        Move position found at (BX) to AX }
        End;  { Function Next_CPos }

Function Up_cs(In_str:  String):  String;

{        This function converts In_str to all upper case characters.
}

        Begin  { Function Up_cs }
                Inline(
                        $1E/                                                                {                                        PUSH DS  }
                        $C4/$7E/$0A/                                {                                        LES         DI,[BP+$0A]  }
                        $C5/$76/$06/                                {                                        LDS         SI,[BP+$06]  }
                        $30/$E4/                                                {                                        XOR         AH,AH  }
                        $AC/                                                                {                                        LODSB  }
                        $AA/                                                                {                                        STOSB  }
                        $89/$C1/                                                {                                        MOV         CX,AX  }
                        $E3/$0F/                                                {                                        JCXZ DONE  }
                        $FC/                                                                {                                        CLD  }
                        $AC/                                                                {DOCHAR:        LODSB  }
                        $3C/$61/                                                {                                        CMP         AL,'a'  }
                        $72/$06/                                                {                                        JB         NEXTCH  }
                        $3C/$7A/                                                {                                        CMP         AL,'z'  }
                        $77/$02/                                                {                                        JA         NEXTCH  }
                        $24/$DF/                                                {                                        AND         AL,$DF  }
                        $AA/                                                                {NEXTCH:        STOSB  }
                        $E2/$F2/                                                {                                        LOOP DOCHAR  }
                        $1F)                                                                {DONE:                POP         DS  }
        End;  { Function Up_cs }

Function Fixup_srch_str(Srch_str:  String):  String;

{        This functions sole purpose in life is to count the number of parantheses
        pairs and correct for a deficient number of either by adding the appropriate
        character either at the beginning or the end of the search string.  This
        may not yield the correct result as the searcher intended but is a
        requirement of the algorithm (it searches for paran pairs).  Note that the
        function will add one set of parantheses if none are found.  This function
        also looks for illegal character pairs (&, &), (| and |), these pairs
        indicate an illegal Boolean search.  The function returns the corrected
        Srch_str if all is well, an empty string if not.
}

        Var
                Left_para,
                Right_para,
                How_many:                                                                Integer;

        Begin  { Function Fixup_srch_str }
                Left_para         := Cnt_ch(Lt_pn, Srch_str);                                        {        Count the parens }
                Right_para         := Cnt_ch(Rt_pn, Srch_str);
                How_many                 := Abs(Left_para - Right_para);     { Get the difference }
                If How_many > 0 Then
                        If Right_para < Left_para Then
                                Srch_str := Srch_str + Fill_str(Rt_pn, How_many)
                        Else
                                Srch_str := Fill_str(Lt_pn, How_many) + Srch_str
                Else
                        If (Srch_str[1] <> Lt_pn) Or                                                                        { No parens?  Add 'em }
                                (Srch_str[Ord(Srch_str[0])] <> Rt_pn) Then
                                        Srch_str := Lt_pn + Srch_str + Rt_pn;
                If (Pos(Lt_pn + '&', Srch_str) <> 0) Or         { Illegal call? }
                        (Pos('&' + Rt_pn, Srch_str) <> 0) Or
                        (Pos(Lt_pn + '|', Srch_str) <> 0) Or
                        (Pos('|' + Rt_pn, Srch_str) <> 0) Then
                                Fixup_srch_str := ''
                Else
                        Fixup_srch_str := Srch_str                    { All is well }
        End;  { Function Fixup_srch_str }

Function Parse_srch_str(Srch_str, Src_str:  String):  String;

{        This function simply extracts each string to search for, tests to see if
        it exists in the original string and replaces the extracted substring with
        the appropriate token.  It should be noted that each substring is determined
        solely by the characters used for parantheses.  Any other characters are
        assumed to be part of the search string (except the & and | operators).

        Each substring is searched for in the original Search_str and its presense
        or absense noted with a T or F respectively.
}

        Var
                Rtn_str,
                Token_str:                                                        String;
                End_token:                                                        Boolean;

        Begin  { Function Parse_srch_str }
                Token_str         := '';
                Rtn_str                        := '';
                While Srch_str <> '' Do
                        Begin
                                If (Srch_str[1] In [Lt_pn, Rt_pn, '&', '|']) Then { Token starts? }
                                        Begin
                                                End_token := (Token_str <> '');       { End of token?  If not }
                                                If Not(End_token) Then                { then start one.       }
                                                        Rtn_str := Rtn_str + Srch_str[1]
                                        End
                                Else
                                        Begin
                                                Token_str := Token_str + Srch_str[1]; { Add a char to substring }
                                                End_token        := False
                                        End;
                                If End_token Then                         { If complete token, look }
                                        Begin                                   { for it in the source str }
                                                If Pos(Token_str, Src_str) <> 0 Then
                                                        Rtn_str := Rtn_str + 'T'            { If found, return T }
                                                Else
                                                        Rtn_str := Rtn_str + 'F';           { If not, return F   }
                                                Rtn_str         := Rtn_str + Srch_str[1];
                                                Token_str := '';                      { Reset to look for more }
                                                End_token        := False
                                        End;  { If End_token }
                                Delete(Srch_str, 1, 1)                    { Delete the char just
                                                                                                                                                                                                                processed and start again
                                                                                                                                                                                                        }
                        End;  { While Srch_str <> '' }
                Parse_srch_str := Rtn_str
        End;  { Function Parse_srch_str }

Function Process_token_str(Token_str:  String):  Char;

        Var
                One_token:                                                        String;
                One_token_len,
                Left_para:                                                        Byte;

        Function Process_one_token_str(The_token:  String):  Char;

                Var
                        Lcv:                                                                        Byte;
                        Curr_answer,
                        Do_and:                                                                Boolean;

                Begin  { Function Process_one_token_str }
                        Curr_answer := (The_token[1] = 'T');      { Establish current answer
                                                                                                                                                                                                        by checking first token.
                                                                                                                                                                                                }
                        For Lcv := 2 to Length(The_token) Do      { Look at the rest of the
                                                                                                                                                                                                        token str.
                                                                                                                                                                                                }
                                Case The_token[Lcv] of                  { Boolean op is And }
                                        '&':        Do_and := True;                 { Boolean op is Or }
                                        '|':        Do_and := False;
                                        'T':        If Do_and Then
                                                                        Curr_answer := Curr_answer And True  { If And }
                                                                Else
                                                                        Curr_answer := True;                 { If Or }
                                        'F':        If Do_and Then                         { If And (Or stays T) }
                                                                        Curr_answer := False;
                                End;  { Case }
                        If Curr_answer Then                      { Final result }
                                Process_one_token_str := 'T'
                        Else
                                Process_one_token_str        := 'F'
                End;  { Function Process_one_token_str }

        Begin  { Function Process_token_str }

                { Are parens present?  If so process as tokenized phrase, if not, final
                        result has been received.
                }

                If PosC(Lt_pn, Token_str) Then
                        Begin
                                While Length(Token_str) > 1 Do
                                        Begin

                                                { Find leftmost left paren }

                                                Left_para                 := Last_Cpos(Lt_pn, Token_str);

                                                { Find first right paren after leftmost left paren }

                                                One_token_len :=
                                                        Succ(Next_CPos(Rt_pn, Token_str, Left_para) - Left_para);

                                                { Copy everything between the two }

                                                One_token := Copy(Token_str, Left_para, One_token_len);

                                                { Remove the parens }

                                                Delete(One_token, 1, 1);
                                                Dec(One_token[0]);

                                                { Remove the original substring from the phrase }

                                                Delete(Token_str, Left_para, One_token_len);

                                                { Insert the resultant single character in place of the old
                                                        substring.
                                                }

                                                Insert(Process_one_token_str(One_token), Token_str, Left_para)
                                        End;  { While Length(Token_str) > 1 }
                                Process_token_str := Token_str[1]
                        End
                Else
                        Process_token_str := Process_one_token_str(One_token)
        End;  { Function Process_token_str }

Function BPos;

        Begin  { Function BPos }
                If Ignore_case Then
                        Begin
                                Srch_str         := Up_cs(Srch_str);
                                Src_str   := Up_cs(Src_str)
                        End;  { If Ignore_case }

                {        Is this a Boolean expression?  If so process with this function, else
                        process with Pascal POS function.
                }

                If PosC('|', Srch_str) Or PosC('&', Srch_str) Then
                        Begin
                                Srch_str := Parse_srch_str(Fixup_srch_str(Srch_str), Src_str);
                                If Srch_str <> '' Then
                                        BPos := (Process_token_str(Srch_str) = 'T')
                        End
                Else
                        BPos := Pos(Srch_str, Src_str) <> 0
        End;  { Function BPos }

End.  { Unit BoolPos }