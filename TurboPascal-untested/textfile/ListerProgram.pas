(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0004.PAS
  Description: LISTER program
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:58
*)

{     Right now I'm writing an interpreter For a language that I
developed, called "Isaac".  (It's Physics oriented).  I'd be very
interested in you publishing this inFormation regarding Pascal
Compilers, though I would likely not have time to do the excercises
right away.

   Ok, Gavin. I'll post the lister (not Really anything exceptional,
   but it'll get this thing going in Case anyone joins in late.)

   Here's the lister Program:
}
{$I-}
Program Lister;

Uses Dos;

{$I PTypeS.inC}
{Loacted in the SOURCE\MISC Directory.}

Function LeadingZero(w:Word): String;{convert Word to String With 0's}
   Var s :String;
   begin
      Str(w:0,s);
      if Length(s) < 2 then s := '0'+s;
      LeadingZero := s;
      if Length(s) > 2 then Delete(s,1,Length(s)-2);
   end;


Function FormatDate :String; { get system date and pretty it up }
   Const
      months : Array[1..12] of String[9] =
      ('January', 'February', 'March', 'April', 'May', 'June', 'July',
       'August', 'September', 'October', 'November', 'December');
   Var s1,fn : String; y,m,d,dow : Word;
   begin
      GetDate(y,m,d,dow);
      s1 := leadingZero(y);
      fn := LeadingZero(d);
      s1 := fn+' '+s1;
      fn := months[m];
      s1 := fn+' '+s1;
      FormatDate := s1;
   end;

Function FormatTime :String; { get system time and pretty it up }
   Var s1, fn : String; h,m,s,s100 : Word;
   begin
      GetTime(h,m,s,s100);
      fn := LeadingZero(h);
      s1 := fn+':';
      fn := LeadingZero(m);
      FormatTime := s1+fn;
   end;

Procedure Init(name:String);
   Var t,d        :String;
   begin
      line_num := 0; page_num := 0; level := 0;
      line_count := MAX_LinES_PER_PAGE;
      source_name := name;
      Assign(F1, name);      { open sourceFile - terminate if error }
      Reset(F1);
      if Ioresult>0 then
      begin
         Writeln('File error!');
         Halt(1);
      end;
      { set date/time String }
      d := FormatDate;
      t := FormatTime;
      date := d+'  '+t;
   end;

Procedure Print_Header;
   Var s, s1 :String;
   begin
      Writeln(F_FEED);
      Inc(page_num);
      Str(page_num, s1);
      s := 'Page '+s1+'   '+source_name+'  '+date;
      Writeln(s);
   end;

Procedure PrintLine(line :String);
   begin
      Inc(line_count);
      if line_count>MAX_LinES_PER_PAGE then
      begin
         print_header;
         line_count := 1;
      end;
      if ord(line[0])>MAX_PRinTLinE_LEN then
         line[0] := Chr(MAX_PRinTLinE_LEN);
      Writeln(line);
   end;


Function GetSourceLine :Boolean;
   Var print_buffer :String[MAX_SOURCELinE_LEN+9];
       s            :String;
   begin
      if not(Eof(F1)) then begin
         Readln(F1, source_buffer);
         Inc(line_num);
         Str(line_num:4, s);
         print_buffer := s+' ';
         Str(level, s);
         print_buffer := print_buffer+s+': '+source_buffer;
         PrintLine(print_buffer);
         GetSourceLine := True;
      end else GetSourceLine := False;
   end;


begin  { main }
   if ParamCount=0 then begin
      Writeln('Syntax: LISTER <Filename>');
      Halt(2);
   end;
   init(ParamStr(1));
   While GetSourceLine do;
end.

{
   Now that the task of producing a source listing is taken care of,
   we can tackle the scanners main business: scanning. Our next job
   is to produce a scanner that, With minor changes, will serve us
   For the rest of this "course".

   The SCANNER will do the following tasks:

   ° scan Words, numbers, Strings and special Characters.
   ° determine the value of a number.
   ° recognize RESERVED WordS.

   LOOKinG For toKENS

   SCANNinG is reading the sourceFile and breaking up the Text of a
   Program into it's language Components; such as Words, numbers,
   and special symbols. These Components are called toKENS.

   You want to extract each each token, in turn, from the source
   buffer and place it's Characters into an empty Array, eg.
   token_String.

   At the start of a Word token, you fetch it's first Character and
   each subsequent Character from the source buffer, appending each
   Character to the contents of token_String. As soon as you fetch a
   Character that is not a LETTER, you stop. All the letters in
   token_String make up the Word token.

   Similarly, at the start of a NUMBER token, you fetch the first
   digit and each subsequent digit from the source buffer. You
   append each digit to the contents of token_String. As soon as you
   fetch a Character that is not a DIGIT, you stop. All digits
   within token_String make up the number token.

   Once you are done extracting a token, you have the first
   Character after a token. This Character tells you that you have
   finished extracting the token. if the Character is blank, you
   skip it and any subsequent blanks Until you are again looking at
   a nonblank Character. This Character is the start of the next
   token.

   You extract the next token in the same way you extracted the
   previous one. This process continues Until all the tokens have
   been extracted from the source buffer. Between extracting tokens,
   you must reset token_String to null String to prepare it For the
   next token.

   PASCAL toKENS

   A scanner For a pascal Compiler must, of course, recognize Pascal
   tokens. The Pascal language contains several Types of tokens:
   identifiers, reserved Words, numbers, Strings, and special
   symbols.

   This next exercise is a toKENIZER that recognizes a limited
   subset of Pascal tokens. The Program will read a source File and
   list all the tokens it finds. This first version will recognize
   only Words, numbers, and the Pascal "end-of-File" period - but it
   provides the foundation upon which we will build a full Pascal
   scanner in the second version.

   Word: A Pascal Word is made up of a LETTER followed by any number
   of LETTERS and DIGITS (including 0).

   NUMBER: For now, we'll restrict a number token to a Pascal
   unsigned Integer, which is one or more consecutive digits. (We'll
   handle signs, decimals, fractions, and exponents later) and,
   we'll use the rule that an input File *must* have a period as
   it's last token.

   The tokenizer will print it's output in the source listing.

   EXERCISE #2

   Use the following TypeS and ConstANTS to create a SCANNER as
   described above:

-------------------------------------------------------------------

Type
   Char_code    = (LETTER, DIGIT, SPECIAL, Eof_CODE);
   token_code   = (NO_toKEN, Word, NUMBER, PERIOD,
                   end_of_File, ERRor);
   symb_Strings :Array[token_code] of String[13] =
                  ('<no token>','<Word>','<NUMBER>','<PERIOD>',
                   '<end of File>','<ERRor>');

   literal_Type = (Integer_LIT, String_LIT);

   litrec = Record
      l :LITERAL_Type;
      Case l of

         Integer_LIT: value :Integer;
         String_LIT:  value :String;
      end;
   end;

Const
   Eof_Char = #$7F;

Var
   ch             :Char;        {current input Char}
   token          :token_code;  {code of current token}
   literal        :litrec;      {value of current literal}
   digit_count    :Integer;     {number of digits in number}
   count_error    :Boolean;     {too many digits in number?}
   Char_table     :Array[0..255] of Char_code;{ascii Character map}


The following code initializes the Character map table:

For c := 0 to 255 do
   Char_table[c] := SPECIAL;
For c := ord('0') to ord('9') do
   Char_table[c] := DIGIT;
For c := ord('A') to ord('Z') do
   Char_table[c] := LETTER;
For c:= ord('a') ro ord('z') do
   Char_table[c] := LETTER;
Char_table[ord(Eof_Char)] := Eof_CODE;

-------------------------------------------------------------------

   You can (and should) use the code from your source listing
   Program to start your scanner. if you have just arrived, use my
   own code posted just previously.


