(*
    TURBO PASCAL LIBRARY 2.0
    STRINGS unit: Extended string-handling routines
*)

UNIT STRINGS;

{ THESE FILES ARE XX34 AT THE BOTTOM OF THE LISTING }

{$L SUCASE}
{$L SUTRIM}
{$L SUPAD}
{$L SUTRUNC}
{$L SUCNVRT}
{$L SUMISC}

{$V-}

INTERFACE

TYPE
    FormatConfigRec =   RECORD
                            Fill,               { Symbol for padding }
                            Currency,           { Floating currency sign }
                            Overflow,           { Overflow indicator }
                            FracSep:    CHAR;   { Int/frac seperator }
                        END;


CONST
    UCaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    LCaseLetters = 'abcdefghijklmnopqrstuvwxyz';
    Letters = UCaseLetters+LCaseLetters;
    DecDigits = '0123456789';
    HexDigits = '0123456789ABCDEF';
    OctDigits = '01234567';
    BinDigits = '01';

    { Format symbol record }
    FormatConfig: FormatConfigRec =
            (Fill: '*'; Currency: '$'; Overflow: '?'; FracSep: '-');



FUNCTION LoCase(ch: CHAR): CHAR;
FUNCTION UpperCase(s: STRING): STRING;
FUNCTION LowerCase(s: STRING): STRING;
FUNCTION DuplChar(ch: CHAR; count: BYTE): STRING;
FUNCTION DuplStr(s: STRING; count: BYTE): STRING;
FUNCTION TrimL(s: STRING): STRING;
FUNCTION TrimR(s: STRING): STRING;
FUNCTION PadL(s: STRING; width: BYTE): STRING;
FUNCTION PadR(s: STRING; width: BYTE): STRING;
FUNCTION TruncL(s: STRING; width: BYTE): STRING;
FUNCTION TruncR(s: STRING; width: BYTE): STRING;
FUNCTION JustL(s: STRING; width: BYTE): STRING;
FUNCTION JustR(s: STRING; width: BYTE): STRING;
FUNCTION JustC(s: STRING; width: BYTE): STRING;
FUNCTION Precede(s,target: STRING): STRING;
FUNCTION Follow(s,target: STRING): STRING;
FUNCTION Break(VAR s: STRING; d: STRING): STRING;
FUNCTION Span(VAR s: STRING; d: STRING): STRING;
FUNCTION Replace(s,srch,repl: STRING): STRING;
FUNCTION Remove(s,srch: STRING): STRING;
FUNCTION StripBit7(s: STRING): STRING;
FUNCTION FileSpecDefault(s,path,name,extn: STRING): STRING;
FUNCTION HexStr(n: WORD; count: BYTE): STRING;
FUNCTION OctStr(n: WORD; count: BYTE): STRING;
FUNCTION BinStr(n: WORD; count: BYTE): STRING;
FUNCTION Format(n: REAL; form: STRING): STRING;


IMPLEMENTATION

USES
    DOS;


FUNCTION LoCase(ch: CHAR): CHAR; EXTERNAL;
FUNCTION UpperCase(s: STRING): STRING; EXTERNAL;
FUNCTION LowerCase(s: STRING): STRING; EXTERNAL;
FUNCTION DuplChar(ch: CHAR; count: BYTE): STRING; EXTERNAL;


FUNCTION DuplStr(s: STRING; count: BYTE): STRING;

    VAR
        ds: STRING;
        i:  BYTE;

    BEGIN
        ds:='';
        FOR i:=1 TO count DO
            ds:=CONCAT(ds,s);
        DuplStr:=ds;
    END;


FUNCTION TrimL(s: STRING): STRING; EXTERNAL;
FUNCTION TrimR(s: STRING): STRING; EXTERNAL;
FUNCTION PadL(s: STRING; width: BYTE): STRING; EXTERNAL;
FUNCTION PadR(s: STRING; width: BYTE): STRING; EXTERNAL;
FUNCTION TruncL(s: STRING; width: BYTE): STRING; EXTERNAL;
FUNCTION TruncR(s: STRING; width: BYTE): STRING; EXTERNAL;


FUNCTION JustL(s: STRING; width: BYTE): STRING;

    BEGIN
        JustL:=PadR(TruncR(TrimL(TrimR(s)),width),width);
    END;


FUNCTION JustR(s: STRING; width: BYTE): STRING;

    BEGIN
        JustR:=PadL(TruncL(TrimL(TrimR(s)),width),width);
    END;


FUNCTION JustC(s: STRING; width: BYTE): STRING;

    BEGIN
        s:=TruncR(TrimL(TrimR(s)),width);
        IF LENGTH(s)>=width THEN
            JustC:=s
        ELSE
            JustC:=PadR(CONCAT(DuplChar(#32,(width-LENGTH(s)) DIV 2),s),width);
    END;


FUNCTION Precede(s,target: STRING): STRING;

    VAR
        i:  BYTE;

    BEGIN
        i:=POS(target,s);
        IF i=0 THEN             { Return entire string if target not found }
            Precede:=s
        ELSE
            Precede:=COPY(s,1,i-1);
    END;


FUNCTION Follow(s,target: STRING): STRING;

    VAR
        i:  BYTE;

    BEGIN
        i:=POS(target,s);
        IF i=0 THEN             { Return null string if target not found }
            Follow:=''
        ELSE
            Follow:=COPY(s,i+LENGTH(target),255);
    END;


FUNCTION Break(VAR s: STRING; d: STRING): STRING;

    VAR
        i,j:    BYTE;
        f:      BOOLEAN;

    BEGIN
        i:=0;                                   { Index to input string }
        f:=FALSE;                               { Set when delim. found }
        WHILE (i<LENGTH(s)) AND (NOT(f)) DO     { For each char. in input }
            BEGIN
                INC(i);
                j:=1;                           { Index to delim. string }
                WHILE (j<=LENGTH(d)) AND (NOT(f)) DO { Scan for each delim. }
                    IF s[i]=d[j] THEN
                        f:=TRUE
                    ELSE
                        INC(j);
            END;
        IF NOT(f) THEN
            INC(i);
        Break:=COPY(s,1,i-1);           { Return sub-string up to delimiter }
        s:=COPY(s,i,255);               { and remove from the input string }
    END;


FUNCTION Span(VAR s: STRING; d: STRING): STRING;

    VAR
        i,j:    BYTE;
        f:      BOOLEAN;

    BEGIN
        i:=0;                               { Index to input string }
        f:=FALSE;
        WHILE (i<LENGTH(s)) AND (NOT(f)) DO { For each char. in input }
            BEGIN
                INC(i);
                FOR j:=1 TO LENGTH(d) DO    { Check for specified chars. }
                    IF s[i]=d[j] THEN
                        f:=TRUE;
                f:=NOT(f);
            END;
        IF NOT(f) THEN
            INC(i);
        Span:=COPY(s,1,i-1);                { Return span of specified chrs }
        s:=COPY(s,i,255);                   { and remove from the input }
    END;



FUNCTION Replace(s,srch,repl: STRING): STRING;

    VAR
        i,j:    BYTE;
        f:      BOOLEAN;

    BEGIN
        IF LENGTH(srch)>LENGTH(repl) THEN       { Ignore search chrs. }
            srch[0]:=CHR(LENGTH(repl));         { without replacements }
        FOR i:=1 TO LENGTH(s) DO                { For each char. in input }
            BEGIN
                j:=1;
                f:=FALSE;                       { Scan all search characters }
                WHILE (j<=LENGTH(srch)) AND (NOT(f)) DO
                    IF s[i]=srch[j] THEN
                        BEGIN
                            s[i]:=repl[j];      { Replace if found }
                            f:=TRUE;
                        END
                    ELSE
                        INC(j);
            END;
        Replace:=s;
    END;


FUNCTION Remove(s,srch: STRING): STRING;

    VAR
        i,j:    BYTE;

    BEGIN
        FOR i:=1 TO LENGTH(srch) DO     { For each search character }
            REPEAT
                j:=POS(srch[i],s);      { Repeat search in input string & }
                IF j<>0 THEN            { delete if found until no more }
                    DELETE(s,j,1);
            UNTIL j=0;
        Remove:=s;
    END;


FUNCTION StripBit7(s: STRING): STRING; EXTERNAL;


FUNCTION FileSpecDefault(s,path,name,extn: STRING): STRING;

    VAR
        d:  DirStr;
        n:  NameStr;
        e:  ExtStr;

    BEGIN
        FSplit(s,d,n,e);        { Split file spec. into path, name, & ext. }
        IF LENGTH(d)=0 THEN     { For each field, add default if none }
            d:=path;
        IF LENGTH(n)=0 THEN
            n:=name;
        IF LENGTH(e)=0 THEN
            e:=extn;
        FileSpecDefault:=CONCAT(d,n,e);
    END;


FUNCTION HexStr(n: WORD; count: BYTE): STRING; EXTERNAL;
FUNCTION OctStr(n: WORD; count: BYTE): STRING; EXTERNAL;
FUNCTION BinStr(n: WORD; count: BYTE): STRING; EXTERNAL;


FUNCTION Format(n: REAL; form: STRING): STRING;

    VAR
        s1,s2:                  STRING;
        width,dp,sign,i,j:      BYTE;
        pad,currency:           CHAR;
        blank,zero,left,paren,
        comma,adjust,reduce:    BOOLEAN;
        x:                      INTEGER;


    { Reduce fraction to lowest possible denominator }

    PROCEDURE ReduceFraction(VAR num,denom: BYTE);

        VAR
            i:  BYTE;

        BEGIN
            FOR i:=denom DOWNTO 2 DO
                IF ((num MOD i)=0) AND ((denom MOD i)=0) THEN
                    BEGIN
                        num:=num DIV i;
                        denom:=denom DIV i;
                    END;
        END;  { ReduceFraction }


    BEGIN  { Format }
        form:=UpperCase(form);
        s1:=Break(form,CONCAT(DecDigits,':'));      { Get leading options }
        IF POS('A',s1)<>0 THEN                      { Absolute value, no sign }
            n:=ABS(n);
        blank:=POS('B',s1)<>0;                      { Blank if zero }
        zero:=POS('Z',s1)<>0;                       { Zero-fill/zero-show }
        left:=POS('L',s1)<>0;                       { Left justify }
        comma:=(POS(',',s1)<>0) OR (POS('C',s1)<>0);    { Commas }
        reduce:=POS('R',s1)=0;                      { No reduction }
        paren:=POS('P',s1)<>0;                      { Negative in parenth. }
        IF POS('+',s1)<>0 THEN                      { Check leading + }
            sign:=1
        ELSE
            sign:=0;
        IF POS('*',s1)<>0 THEN                      { Set fill character }
            pad:='*'
        ELSE
            IF POS('F',s1)<>0 THEN
                pad:=FormatConfig.Fill
            ELSE
                pad:=' ';
        IF POS('$',s1)<>0 THEN                      { Set currency symbol }
            currency:=FormatConfig.Currency
        ELSE
            currency:=#0;
        s1:=Break(form,CONCAT('+- ',#9));           { Get width:decimals }
        IF POS('-',form)<>0 THEN                    { Check trailing +/- sign }
            sign:=3;
        IF POS('+',form)<>0 THEN                    
            sign:=2;

        s2:=Follow(s1,':');             { s2 is decimals }
        s1:=Precede(s1,':');            { s1 is width }
        VAL(s1,width,x);
        IF x<>0 THEN                    { Default width 12 }
            width:=12;
        IF COPY(s2,1,1)='/' THEN        { Use vulgar fractions }
            BEGIN
                n:=ABS(n);                          { Force absolute value }
                sign:=0;                            { Disable sign display }
                DELETE(s2,1,1);
                VAL(s2,i,x);
                IF (x<>0) OR (i<2) OR (i>99) THEN   { Default resolution 1/2 }
                    i:=2;
                j:=ROUND(FRAC(n)/(1.0/i));          { Calculate fraction }
                adjust:=(j=i);                      { Allow for rounding }
                IF adjust THEN
                    j:=0;
                IF reduce THEN                      { Reduce fraction }
                    ReduceFraction(j,i);
                STR(j,s1);
                STR(i,s2);
                IF j=0 THEN                         { Format fraction }
                    s2:=DuplChar(pad,6)
                ELSE
                    BEGIN
                        s2:=CONCAT(s1,'/',s2);
                        IF (INT(n)=0) AND NOT(zero) THEN
                            s2:=CONCAT(pad,s2)
                        ELSE
                            s2:=CONCAT(FormatConfig.FracSep,s2);
                        s2:=CONCAT(s2,DuplChar(pad,6-LENGTH(s2)));
                    END;
                IF (INT(n)=0) AND NOT(zero) AND (j<>0) THEN
                    s1:=s2
                ELSE
                    BEGIN                           { Format integral part }
                        IF adjust THEN
                            STR(INT(n)+1:0:0,s1)
                        ELSE
                            STR(INT(n):0:0,s1);
                        s1:=CONCAT(s1,s2);
                    END;
                zero:=FALSE;                        { Disable zero-fill }
            END
        ELSE
            BEGIN                       { Use decimal fractions }
                VAL(s2,dp,x);               { Get number of decimal places }
                IF x<>0 THEN                { Default to zero decimals }
                    dp:=0;
                STR(ABS(n):0:dp,s1);
            END;

        IF comma THEN                   { Insert commas if necessary }
            BEGIN
                s2:=Span(s1,DecDigits);
                i:=(LENGTH(s2)-1) DIV 3;    { i is no. of commas to insert }
                FOR j:=1 TO i DO
                    INSERT(',',s2,LENGTH(s2)-(j-1)-(j*3-1));
                s1:=CONCAT(s2,s1);
            END;
        IF currency<>#0 THEN            { Add floating currency symbol }
            s1:=CONCAT(currency,s1);
        IF paren THEN                   { Add signs as required }
            BEGIN
                IF n<0 THEN
                    s1:=CONCAT('(',s1,')')
                ELSE
                    IF NOT(left) THEN
                        s1:=CONCAT(s1,' ');
            END
        ELSE
            CASE sign OF
                0:  IF n<0 THEN                 { Leading - }
                        s1:=CONCAT('-',s1);
                1:  IF n<0 THEN                 { Leading + }
                        s1:=CONCAT('-', s1)
                    ELSE
                        s1:=CONCAT('+',s1);
                2:  IF n<0 THEN                 { Trailing + }
                        s1:=CONCAT(s1,'-')
                    ELSE
                        s1:=CONCAT(s1,'+');
                3:  IF n<0 THEN                 { Trailing - }
                        s1:=CONCAT(s1,'-')
                    ELSE
                        IF NOT(left) THEN
                            s1:=CONCAT(s1,' ');
            END;
        WITH FormatConfig DO
            IF LENGTH(s1)>width THEN            { Check for field overflow }
                Format:=DuplChar(Overflow,width)
            ELSE
                IF blank AND
                (LENGTH(Remove(s1,CONCAT('0. ()+-*',Fill,Currency)))=0) THEN
                    Format:=DuplChar(#32,width) { Blank if rounded=zero }
                ELSE
                    IF zero THEN                { Pad field to width }
                        BEGIN
                            s2:=Break(s1,DecDigits);
                            Format:=CONCAT(s2,DuplChar('0',
                                        width-(LENGTH(s2)+LENGTH(s1))),s1);
                        END
                    ELSE
                        IF left THEN
                            Format:=CONCAT(s1,DuplChar(pad,width-LENGTH(s1)))
                        ELSE
                            Format:=CONCAT(DuplChar(pad,width-LENGTH(s1)),s1);
    END;  { Format }


END.

(*

The following contains the ASM and OBJ files needed for this unit.

Do the following :

1.  Cut the code out to another file.  Call it STRASM.XX
2.  Execute -> XX3401 D STRASM.XX.  The file STRASM.ZIP will be created.
3.  Unzip to have OBJ and ASM files needed.

------------------    CUT HERE --------------------------

*XX3401-007122-160793--68--85-58879------STRASM.ZIP--1-OF--2
I2g1--E++U+6+BRwjVcn7M7VxU6++1wC+++8++++IpJ1EJB39Y3HHSpLHLCPA-0xSwPz
MGyRh3CGgRpC1gsZTAKa6kC1QCAaYkBpZ6G46+cWbTHL3m360EXWBeRqcggmW5qvSfjv
N-z-oyKjDQo-JwKuWU-NaeRuLq-qA-aDqZzeEINUGyBvYaMVXS4CLiMF4Mz46qVXKXsm
0viq9Fykvpbq+gxvzRjSfffUnb-se2kzn9fvPnH9tbMusv3pln0PixVQf2nPVpD5Avey
8gPfJT4xXiTQgTg-QUcSg0GdhMMgLSlXIs4puteSS2HCeLXYuLFdCpbPiawtBW-OAj-q
SpBkgJGxRw76W0stMf0x0R7UmoU8X272Tt-oTwgFmDQwj+wW2XASHqHImBFnx16iVysQ
kr39eqp+ictUEFWYVCJd1A5ZNIem18tGSUQN0vOrzM1udbxD5EnqytFV10fekiWf0UMd
SyeS1AOaFOvTwcl-S+Il9H0174F-pALud+ZvT6makt5CxWHSud0rso5hDNggNLbKVQqH
d33Is2IRXnXcz2b5sOJUhcwxXqGAdeFJ9Zbj0WFBIWDDx9ghNBe48thfDdbDBDaO5oro
SHOjNjxRzR1TuVZ9kzWOIm8s2NGAFsxXhZBnpyRoirgftvBcT3T-fdFBH5VVF7z1JFfQ
2IVc41CGxYQm72e-10m2m36A9Y9UyVuQOyvvksgeYghV0xwthjW7knX7OkMYQ8O+Axdk
owZ32wv2QuC2cnYPkhCFoQyCXdFnP3roH4eNu5tJecX2pym4nulgx1TJACV9FJx8sq2B
yVQTZSGVCgBy3Sff+tDQ3dzonJYpYlzYIDUqH00WB0bJ6MyWFqvO6sQQstaoOg2u286s
L9eab+Gv0JRH2+OoOnMQvCSkRYawJRicjGT4mL7+ioG4fI5Zc2oWgSxUHLOtWVh-u0Sj
q3lmLJHnAmVspq54G7cBL50iJCh8yv4f8mxEDAE7SMbWBKjChTXoJT3S3SzTJvkRTucp
NSHj3SzgXlJjxpxfzsTWhLKZJfnqzuTWDNMdMT4Sjzs3I2g1--E++U+6+BNwjVfCAxyp
EUA++0cC+++8++++IpJIIYZB9Y3HHSpLHKzPC-0x-z-za2i-LOkGl5MGcD6Z2eZBJB0G
EAehqw+5BOMP6PPYZSGUuOwjeExLAGYtKTGoK3pcYC9AawTVSz62LXvVXBcy--N13U5W
qhGWbq3oRXssIRvAsUpwLIT7MkuPR9ZPww57s+ECrr71scVltfYVg70urUonhLgDRkPK
XRk6JpT4Q1lGpxzNfWT5sIXaFHtqqejAiNYuLUWTT6fJjFNXguZs5n3HPZFT69ucbqZ+
nKnW6Z2KROT28+Qeoujoz1rnICXuLZYfUHxmgmvznyN5-uJf5WrXt3h1nmd9Bt+LaNWG
OQf2PI1IFqIuWyfEgZgtqc4uBjIzEfJag+1INk8A3v1PWhnFzOC+2KosPBAs8LXKbEZf
C0CMJITW4ZUS-kEVVHgvyCheIKQ8N3WlpqEi30b2mLNLv4hKkXZJC5kMPbWyO6Rna6b9
QCaiu6i50CtVNqu661dqF5VvLV4Ghv8gST8hS60jnkLLRFJaBbEz2vUFb7TZbpNkarVl
+aXS1FAFkm9ewhmbpT8hUKvJNRR1BNBRQBVXj8ofCyqhf+40WM46BVF8hwyEfif1zJIK
pi1yUCNTt5VxHGtuUAIfG5PfRIBJ4LZk6XMBnHSHbj1j-RkzF3ZofqpkB8oiWIKAwIVT
s+CLxmHBedifeOcK8+3kp7jUjKOjtnFvlqK7crO7q8YDYbGJu8seJ+MgyTrNmqPJxOYT
pBa45NGZgiSDYTOVfcbRyXEgHvD2DatXNu3zt5U2xWEh4jltYKNQBYtJUteo6EBd4cgu
UKnJncEH09AcmJQwUsljcXVNWZzdOewRgUFHozMCAyzgyQ6sD6+7g-9iOwEVe1XLGaWn
dVBmucHZS84OUyDVE4T8oZdTsJfo1OtJN34wvfQh0jzPpiyn9FPWLXysMys0SUnaW9AQ
gMuKEczVe26TcQP0i42OnPL-diYHVsfZRNGzo7nzihlTe57zL7tPQeyex820hoIAikj3
k-gFyw4nh3z039qzv7TAjamjYQna+sNpTg1g9ySyPQsUszzgsckjilgFRnPWzbP842yF
E3T+BgrX6YuHTqArtJTFzanmYet9wzSv+hKski3T7X5DR4sVtiLoHp-9+kEI++6+0+1J
T9sOCDOSb+E1++-g1E++0E+++3BJI2329Y3HHSpLLKyPA-FxfxHzQ3waPFe9aYme7f77
-NiZP+sUaumdeXnEs9Gc8KFweBizbloUHMAVKPjhOHn2kiOSSyu5vp44wDHl7xFokHAM
AUUEquE4jMF-vyHsODR99kUVmxAcjc5v70mKzDXcy+VqsKmTK48RC9MDn8SqAq8umbHL
o1B4oUtCHvLyyo5nz7JdCr9h1uFPt47fytFNcv5Zy51VIhmoBFWPXALrWCbGgDY-QILo
H23eMV6PGL8MOD8LGiTBp5mSCAWrLIQ4Gi-pdZSV1y2V0jBP5Ql9rrdHvrOaxW58Pq57
Up0yL0y1y0u1D63glSTF6i7VWGV7G37DE8W9paEAece2bQjJx7dbMzQPZ4QOwu1t165l
56eJc-XAvq0F-jQQJYYItnlhxsEJyGGMZSKmBGl9-NtDsQforbuMJNsw0GhgRKP9g8Bs
JSFJOVFkJUa5Ry5uUxYqbAJoj6N9Wfk9fos2aacGtLHKGAF6709ZrkiStLId-2RVo+GP
ifE2CxTESITGdtfUdYfuJwtLA2xKDm3NpAm1A2ltZXLV2A4ehgPAP4snrqIah1x1wBAU
nVMwVGKDPoG6axGpls47Nd1qC9M9KO2eUVVvJH+0erbwlGnjzBYNuOhtgvh6i3f62YYb
5nyJPhjwpRkhdZyNota4G+AkHp7Sko4EpLIEPnp3MWTa6rwZEFEgtnq6YtuguSDh3aJh
NqQEPL0Wu0-eSNqZfBZLPe7shzpZ5bJJylABYnoBrHcao5FnPxzh8PQAEDXg041HVqIR
CxfEQwjKeEOA+cjmP7qC6+t3ETAWXRhFJ3CGKjtuDKpCLgj-bYcAdOPh3knu-kEXHsBc
SMVWIDWj45x1AMVqlSnNQmuBZ7HhARKa7th-CxLER9xUR2wyqo4JoXpPaFsbcGHxSw7o
qAozuC9zGwrSoWTw6bq82y+zwXGcfij9Z8aAu6YqRIcHJYiHIxlTWsHjuh8yRbmyCZqY
IQurbCpFdwAbTAdj6Z5fB5j7U8Se+PzvhoDgAxLU3zhmylREGkA23++0++U+ormy4jzr
Jb1n+U++GEk+++g+++-HJJFGJIt19Y3HHSpKoKfPA-Fx1yETvghUMqtNAUX14Omqv0Ii
WaoYNohLwa+GdHJfvAmK4RjLHsdgG0AtvI9rBfw6R8JnnvauCj6M5bz7b9UFl+t31UMQ
iAEVBn0wTBTjOGj9CZyZb253mmmzUqqlfVxMjxTjkT586A4y4CRVY+-BG--CeBqtzrVr
v2nYNVWBfA5vcFtztEOV5+R1aFh3bbwMdTtYtcQ7T6q6dyxp87rDl5d2PPZFLs+XIERe
61JrQM02B16D2PPq+t5txHdx3e2YW26Z4ADfmau8A6OTqNfTqy1S7DuPRjPdGaz8MUgD
PAC-3p1hq0fPN4mhk0E1FSe+96bEbcZ1H2fcJ6tifARaoFREAMj4c5xXc6l1jFD2ohJr
kGjRAhUJKQtNqNr7AxEHSpERJq1Rij5P1oghImlVlJuP-Z7qZixerVH2+CQfC2z-1MN9
AtlDPKwDJxHw33tP04Sllljdx0OW20LvIPC8hoQVC681RP-3F-HMp58arPYEhatdg1EI
LSPOuvxc4i8-tLQe5pdotoBH0lbm-G3eGez521NQ4XFHjS-U0lbYLPhej9f0+n+qnLKx
rI4q+OvuCWjmTSamYepDZVshX51--j80Kv+eRfzO8t7KY6YWJENu1LguXIUWGEvvDIbJ
DXGBiR8+3dNXnVYKZp-gM5KTZia8gv8GHRHcALWMsrZhSrS6IDqcSbhEQM3Q5VF3obl2
A6ac0xrT40UjGhOqhSeD2urq57rJdR8MthL4R9qjoS7PQyvjxGXlMtaiYzIMY1kyzGd8
i2DdQOHCnyEWPQnYNQFDxiB6xoQzx49HimJTbiRsCbYdHmyniziHdYvUjuaza8YPnEp5
rVArusHvCcjnrTtjLtMnb9spPcEh-lipYQRtDec1IE6zbKDpfHTL3MB1A2WfYmxT-vwX
DnjqvFP+dzOh3mkhVAymlTN3x68H9XQoGov8R+SzKJZQB37JapHbS49GiCqV4kvzVFgG
rEqDzuH3D1Ktd7WLorw+I2g1--E++U+6+B7wjVfA7sv1RkA++3QG+++9++++IpJ1HZNG
J0t-IorhK3pjqnMITEyEzr-T0amMKjUXG+fZdF8ZK-dYGF1ZnJqF-wKaMu2C4J-IajHL
ZlGJn7Pcf5KlPYCa3xcGRLXisPrbGXe5rGCTNKs0eMCF2o2IidaHjMTFaw5lILRaLBxQ
2TtOgBSJs0KxVUKXRsFL7OBkktPpVVkT5Fx-3nzA6pyCgnXA+SRN42ykzJJMLOHIaGUU
C1qpViBFzzcfBsnJC-kd5WXlzCqfq7xAzHW5rtDAuxzfM1mPmjY6qyf4zcEcYTdU+uaN
4sI66D1bAXUfEPYO7-AtaCFEEOXnTLYjNX58kmG4UBlXkS2bOXRYnuIqBFIqiCxnzqSv
pP-zToN2nGagmToPsCGKYsdEIEWZ83g-VN70evLwqo10MZrkMW4YvceE1a49OdOUVdWH
aS94UFfRh5xhajk4yde3IyUTts07UDdKwWYK5q53Wlg0humYYgZyB1GrDfXd9uSLzGbn
FBB4UMI0ss6HiO0CKQe+tjhLwTEePmyB27wMLs7UPPMqM7s-9D8l-UgPgC5UgUiKeaX-
lvML8XlKWxhOhDinbtmQzw299moIxEEJX7BR4BUESWrKTPFToTkDBPtv3soBZS-tXxnF
r8WZteu7Psde8sruO1XrbgaDm-eQ-APwK7Qf+LT3dWOkMbn95MuD7CqVPI-ntdNd9tlM
lyD6lGuAWoq9uaAH0mbid6OIk98w9cLwhLbcsvKddj14+mASOdB1EXcMVS3nye-dycHa
aB5KFBK6384dP+T2ahRkMRVKJsxGbx5yPJImb+KBWWBvNuAGvA9ysn534V7ObmR1AFEY
0WPB1gwhIv5V65gghasevmE+eoKvJZhkNDbBOoJ7YfOm1Aq-HFUg4J-mjtD7eXeq-Icp
XB5kAXxjldCyWTelZlvM-t83y6syk-OWq-nK05EHyvwFj8-4ADf54w5sFnO0grxR6zVO
zxJZzI6AS5G++LTBungAq0rdLljkyJs5jWddkFyA3ZlLydqbvvrunS43SixzlWtDziOy
wKFZSvp34wdbkhYDQSuipqsNm7uWpUNmJHPqhmUsTqUAL7-848GBoRCnelYiLA5EIXHd
BN4mzCadX-cy3MEhbVARzeHPyBunJATaqnANcU8E9AgJI96UJJJkEkTlz-qKCsyPryGO
JsecGgg1z97fC6xyqTpy6gxXYsz8wyfo3p-9+kEI++6+0+1MT9sOuigk5cM0+++a0E++
0U+++3BJHIZHEmt-IorBJh3ian+ITMyITvUjYneBHIoq7FBt8FWOA1a+A8ndeXtEuUOo
***** END OF XX-BLOCK *****


*XX3401-007122-160793--68--85-04457------STRASM.ZIP--2-OF--2
106kojPrgu328HN7JKbGz56Zv5hwvj2xBpb+mlJ4USa-Pl-YMA0C4FX-9IkzLMt5zNDf
f2fcPVTbh8Uf86iONHahs3TlKCzcS1ESEFzO0P5BMyEu6N+kQBkZoQz-x23wMmYkM1PH
7dybwjsvor33b2k3-SFNxj2igNRfqkrVlUggCRQU73fnwsXc6Z2yU1qi0Z4EWYng6++f
wX3O4M5KZCSPHXUL94HhfWALVMvbUZLjRmWBGvV6IVp2vU8GcguN1iNhO9zLbsKG6IFa
ZgGAEg9nssHFIhnIIHVE0nnIr4U28htY7O9dmrhfvnioSlflEJs967F-jMS8lQZDS0fX
LlHqFNMrF0HZPB8mRfEvozwkiPnjczYW3KmWKkuk+ceOvKj4kQggrkunAnMBrilSMfTY
v-cZ6Qj-k162kccK6835H-VSj4dKZ-HWeaCsczaKdT1kVx3VaUVf-ZP0VKKQJoyoTCP8
8oQP4KTXhEy8JVdOmRjToCO5W3RLS57Keuw1KbJRB8FLMDgbtSaYCKd5kIQzvXTDVu3y
0ymkWJzY5fNRmpQB3129njW9g19PalaPkoLJSSa2eR0ClWKYqHPxK7GDL6i5X25l-1FC
odQ8RMot5Vqgzbwtffj7IgkfP9Ji7AuESpcrKYEbXFinz7ENztKt2RPiW5Cj226oP7jR
yMwzmFiActk-zDcnAy-UqdDaDr9ZJDM0xeknhsUWQzeP5Hh8ygZmfHNWPLuxIe4cKjch
Qyyan-VxlSBVfnKte5SUfU8qWh82H8dVcKfUJkuGjXKvER9zKw0z2xK+sRzPyT6LI2g1
--E++U+6++ZxjVeTUjEtok++++U-+++8++++IpJ1EJB39Yx0GajUMS+81bJq15PJQknq
bRuVkA1+237OZ7Gjs3VQb7ePZ7BOd8+EZZdIb7aTdq0cNq1MoG52sD1mSgoy8GFxdVrA
E24TOIkA1-bHq-VMbDpRL3pbg1AsF12kAH6SbW1+kA16uSATvVc2oa58k3+nUFQclCPX
1y61fJk8IF6O2+-F+iHBuq-VQ3X2C53-5+AX+oBoN6GBMl4PHJEt2sx0MD1doCsrQYT9
q6vIQTrdsX3uiyElrlePF8-wJHaHmjpJXnv7lttWMQ0a04s6H33h3x1J7E-EGkA23++0
++U+15qy4XV5qhLL++++yE++++c+++-HJJFGGIoiHo78Oy-Vs+cC1EbmxBJn1DMhvp-U
M4+68Gp8mZRk90tCnIr8GGpGI+V99GfCnAxHABEnACnc247kS5ahNdwIYXul1aOUcAwo
7UO4X4Zg10nCzWuifXDM4FmG4NUM4LRBs43UM4E38TM-4bwBkEomNa0Mqw50s906QS80
R+N4-cPEvXRmFwjMXhFlzSayjuPfVB3Pxuu9XoLKq0WIgBVkZf9xCzLcwqjKJTxCTZuW
pW2i5ri8-Ib9rmsScvSDSNYzkdGnDzeepg5vaUB6i15zz9k2fDt03x0N7E-EGkA23++0
++U+1rqy4ifHluP7++++vE++++Y+++-HJJ--F0tDEYdfs4PU1+sBQ5HFQknqTR0VkA1+
237OZ7Gjs3VQb7ePZ7BOd8+EZZdIb7aTdq0cNq1MoG56sD1mOgoy8MGqVUtac7XDB0M4
VcldP+kgnjsifesnq-YQcVaM4-YDHS-aM4-Y+Ofp+Fdi1yQ3uH2kQ5SkA1UgMdms67u-
YM2VhDiBrB2mXWBpDBpyP2NjiyzzKPCeus9JWH7ChEtyfFAP31ujuXdZxDPn2jbMIql6
efhsU6cjCU9JTps0paZp0e9Z32U9KD579e1XGU-EGkA23++0++U+2bqy4ibgE-T8++++
vE++++g+++-HJJFGJIt19Yx0GajUNS+C1Uo70jJnpbAAxZLhI4-UM+Ud9If8Jr+g9YvB
HQd79J7E02gh8gvAnpAkp1AkvCUENb-sSPZablGmliARn2-FbqZA1+kNoxUMK7nxLJlR
Nv+nC+EnA12mbdf+mw1+m+NKvECoc+K75uH9k-1MkQ9Ug6Vlsc7k-YM4Vh1iBr75mnWC
pD3oiv2NDSbWALffxgTeM-39xw5L9Bcba1yiuXvlaCbn2jbMIql6WjygALfGvQRaxBPe
F-3Hpkap1Ztri8eC9e11GU-EGkA23++0++U+3Lqy4i0NFEo5+E++9k2+++g+++-HJIBC
JZ7I9Yx0GaqDAIX1M--4jnw7GR24-rLdx+z3AGGCsd+O+kcpVGMB1fcI+Ude6R3BWcjo
pmmuZ6vWq2Zk3l3-QJCbfbKmuW-C1cdLeh1-tS+Rvr5QbctFjy7sMHYk0jtGLb++kItQ
fT30YYGPpMoctXmAsaGxhgIhkvG246Txz9-vYFgCPsFAqq7H+hOO8VGbBCyu9ErqDWH4
KYQukBGtFQwDmWi+AS+3RtaM1hM5L560MUgc0ULq8HgyCE+18iZfuebHPqaMiOuDH+bx
8GRzTdofuJJy94jCngGGcfIPbQRScxBxKPpHzUYayc3AUNMpzxHrMTLLauHYn0HtjdR6
rtRh4fTRXvuMCOHLhbw+I2g1--E++U+6+-ZxjVfyc8wEm++++BE++++8++++IpJBGJB1
9Yx0GajUMS+81jLp15PKQknqPSxEM4-U00YhGgdLQ0kiHgpBmYYhIZ+6GmoengnDIn1I
An1gu--WQ5VtcqOT376yZEtac81DB0M4VcldP+kgnjsifesnq-YQn-aM4-aTHF-UM41Y
1+s7wUlkwUklZq7Ua18-5mX2sF6OsCDgsFU2h7GpUsL-MF5Xl+LK16kA185RPsvIQLKv
gTpNpLL0uCpXpasrXgyfMYylU4HYXdOl+KKvS6nSzZbma4qBGjqeFvzYEN65is+i8+2+
I2g-+VE+3++0++U+prmy4XAZUa5q+U++Dks+++c++++++++++E+U+++++++++3BJEo3H
FGt-IopEGk203++I++6+0+1KT9sOnXDThI61+++e1U++0U+++++++++-+0+++++S+k++
IpJIIYZB9Y3HHJ-9+E6I+-E++U+6+BJwjVcsxduQ-+A++4kB+++7++++++++++2+6+++
+6U4++-HJJ--F0t-IopEGk203++I++6+0+1HT9sOzzRKQDA0++-71+++0k+++++++++-
+0++++0n0E++IpJIIZJCEmt-IopEGk203++I++6+0+1GT9sOn0SCkrQ1++-L2U++0k++
+++++++-+0++++1D1+++IpJ1HZNGJ0t-IopEGk203++I++6+0+1MT9sOuigk5cM0+++a
0E++0U+++++++++-+0++++-j2+++IpJBGJB19Y3HHJ-9+E6I+-E++U+6++ZxjVeTUjEt
ok++++U-+++8++++++++++2+6++++-oH++-HJIB-IoIiHo78I2g-+VE+3++0++U+15qy
4XV5qhLL++++yE++++c++++++++++E+U++++4-E++3BJJ377HGtDEYdEGk203++I++6+
0++DTPsOuhD5dgY+++1h++++0E+++++++++-+0+++++L3E++IpJEEIEiHo78I2g-+VE+
3++0++U+2bqy4ibgE-T8++++vE++++g++++++++++E+U++++-lM++3BJJ37JHYAiHo78
I2g-+VE+3++0++U+3Lqy4i0NFEo5+E++9k2+++g++++++++++E+U++++yVM++3BJEotK
IZEiHo78I2g-+VE+3++0++U+4Lqy4juUfl16++++p+++++c++++++++++E+U++++8VU+
+3BJHIZHEmtDEYdEGkI4++++++k+1+0W+U++4VY+++++
***** END OF XX-BLOCK *****


