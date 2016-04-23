(*
   For reference...  Here are the microsoft C and my borland Pascal versions
of the Excel "xloper" structures.  Thanks for the help!
Notes:  1) For each variant of the union in the C version of the xloper
type there is a single comment starting "xlType...", "xlFlow...", ...
these are actually integers from #define statements in the .H file.  I've
used these as selectors in my "record case ..." statements (and declared
them as "const" in my pascal source) and eliminated them from the comments.
2) A nice compare and contrast:  Had microsoft put the xltype word (which is
at the end of the structure "xloper") first, I could have used it in my case
selector as in "record case xltype:word of...",  the two bytes that xltype
occupies would become somewhat of a runtime type selector (a definite pascal
advantage) but on the other hand, by putting it at the end, the same address
of this data item can directly typecast to one of the union's member types
once xltype has been examined (you do it by hand...) a C advantage (unless
you are using Borland Pascal :).  3) Since Pascal does not allow "unions
within unions" or "variants of variants" I've declared each sub-union
(variant) as a separate type, which is legal pascal.  Same effect.  4) I've
taken liberties in renaming some fields to make them more readable for me :}
5) The C version is 88 lines long, the Pascal one is 85.  /*could it be the
three lines I deleted from the comments???*/

*******************c version*****************************************

/*
** XLREF structure
**
** Describes a single rectangular reference
*/

typedef struct xlref
{
    WORD rwFirst;
    WORD rwLast;
    BYTE colFirst;
    BYTE colLast;
} XLREF, FAR *LPXLREF;


/*
** XLMREF structure
**
** Describes multiple rectangular references.
** This is a variable size structure, default
** size is 1 reference.
*/

typedef struct xlmref
{
    WORD count;
    XLREF reftbl[1];                        /* actually reftbl[count] */
} XLMREF, FAR *LPXLMREF;


/*
** XLOPER structure
**
** Excel's fundamental data type: can hold data
** of any type. Use "R" as the argument type in the
** REGISTER function.
**/

typedef struct xloper
{
    union
    {
        double num;                     /* xltypeNum */
        LPSTR str;                      /* xltypeStr */
        WORD bool;                      /* xltypeBool */
        WORD err;                       /* xltypeErr */
        short int w;                    /* xltypeInt */
        struct
        {
            WORD count;                 /* always = 1 */
            XLREF ref;
        } sref;                         /* xltypeSRef */
        struct
        {
            XLMREF far *lpmref;
            DWORD idSheet;
        } mref;                         /* xltypeRef */
        struct
        {
            struct xloper far *lparray;
            WORD rows;
            WORD columns;
        } array;                        /* xltypeMulti */
        struct
        {
            union
            {
                short int level;        /* xlflowRestart */
                short int tbctrl;       /* xlflowPause */
                DWORD idSheet;          /* xlflowGoto */
            } valflow;
            WORD rw;                    /* xlflowGoto */
            BYTE col;                   /* xlflowGoto */
            BYTE xlflow;
        } flow;                         /* xltypeFlow */
        struct
        {
            union
            {
                BYTE far *lpbData;      /* data passed to XL */
                HANDLE hdata;           /* data returned from XL */
            } h;
            long cbData;
        } bigdata;                      /* xltypeBigData */
    } val;
    WORD xltype;
} XLOPER, FAR *LPXLOPER;


*******************pascal version************************************
*)

{*
** XLREF structure
** Describes a single rectangular reference
*}
type
    xlref_ptr  = ^xlref_type;
    xlref_type = record
        FirstRow    : word;
        LastRow     : word;
        FirstCol    : byte;
        LastCol     : byte;
    end;

{*
** XLMREF structure
** Describes multiple rectangular references.
** This is a variable size structure, default
** size is 1 reference.
*}
type
    xlmref_ptr   = ^xlmref_type;
    xlmref_type  = record
        count   : word; {count will never be more than 30 according to doc}
        xlrefs  : array[1..32] of xlref_type;
    end;

{*
** XLOPER structure
** Excel's fundamental data type: can hold data
** of any type. Use "R" as the argument type in the
** REGISTER function.
**}
type
    flowarg_type = record case integer of
        xlFlowRestart   : ( level   : integer; );
        xlFlowPause     : ( tbctrl  : integer; );
        xlFlowGoto      : ( SheetId : longint; );
    end;

type
    handle_type = record case integer of
        1 : ( buff : pointer );  {*data passed to XL*}
        2 : ( hand : record      {*data returned from XL*}
                offset   : word;
                selector : word;
              end; );
    end;

type
    xloper_ptr  = ^xloper_type;
    xloper_type = record
        val : record case word of
            xlTypeNum     : ( num  : double;  );
            xlTypestr     : ( str  : ^string; );
            xlTypeBool    : ( bool : word;    );
            xlTypeErr     : ( err  : word;    );
            xlTypeInt     : ( int  : integer; );
            xlTypeSref    : ( sref : record
                                count   : word; {*always=1*}
                                xlref   : xlref_type;
                              end; );
            xlTypeRef     : ( mref : record
                                xlmref  : xlmref_ptr;
                                SheetId : longint;
                              end; );
            xlTypeMulti   : ( xlarray : record
                                xloper  : xloper_ptr;
                                rows    : word;
                                cols    : word;
                              end; );
            xlTypeFlow    : ( flow : record
                                flowarg : flowarg_type;
                                row     : word;
                                col     : byte;
                                xlflow  : byte;
                              end; );
            xlTypeBigdata : ( bigdata : record
                                handle  : handle_type;
                                len     : longint;
                              end; );
        end;
        xltype : word;
    end;




