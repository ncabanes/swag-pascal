{
Duncan Murdoch

>var
>  TextFile: Text;
>  NextChar: Char;
>...
>begin
>...
>  with TextRec(TextFile) do  NextChar:= Buffer[BufPos];

Careful!  This is unreliable, because the Buffer could be empty.  You should
check that there's something there, and fill it if not.

Here's my NextChar routine.  BTW, I don't like the DOS unit's declaration of
TextRec, so I wrote my own.
}

type
  IOFunc = function(var Source:text): Integer;
  TTextBuf = array[0..127] of char;
  PTextBuf = ^TTextBuf;
  TextRec = record
    Handle: Word;
    Mode: Word;
    BufSize: Word;
    Private: Word;
    BufPos: Word;
    BufEnd: Word;
    BufPtr: PTextBuf;
    OpenFunc: IOFunc;
    InOutFunc: IOFunc;
    FlushFunc: IOFunc;
    CloseFunc: IOFunc;
    UserData: array[1..16] of Byte;
    Name: array[0..79] of Char;
    Buffer: TTextBuf;
  end;

function NextChar(var Source: text):char;
begin
  NextChar := chr(0);        { This is the default value in case of
                               error }
  with TextRec(Source) do
  begin
    if BufPos >= BufEnd then
      { Buffer empty; need to fill it }
      InOutRes := InOutFunc(Source);   { This sets the System error
                                         variable InOutRes; other than
                                         that, it ignores errors. }
    NextChar := BufPtr^[BufPos]      { A test here of whether a
                                       a character was available
                                       would be a good idea }
  end;
end;
