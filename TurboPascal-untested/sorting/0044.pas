{
---------------------------------------------------------------------------
 >    What I want to do here, is take a textfile with about 1,000-10,000
 > lines in it, go and read a string starting at the XPosition of 13, going
 > until XPosition of 38 on each line of the textfile.  Then, put
 > everything in memory if possible, and then sort all of the strings on
 > the screen by ABC order.  Can somebody help me out with a few hints, or
 > some code?  Either reply here, or send me Netmail @ 1:105/60.77.
This will take some modification by you, but it should not be too much trouble.
 This is a sort based on a file of records, but the necessary modifications
should not be too difficult.}

{$N+,E+}
program DiskSort;
uses
    Crt,
    Dos;
type
    String72 = string[72];
    ElementType = String72;
    ElementFile = file of ElementType;
var
    A : ElementFile;
    Temp : String72;
    I : LongInt;
function Precedes (A, B : ElementType) : boolean;
    begin {Precedes}
        if A < B then
            Precedes := True
        else
            Precedes := False;
    end; {Precedes}
procedure Swap (var A : ElementFile; Index1, Index2 : Integer; Temp1, Temp2 :
ElementType);
    begin {Swap}
        Seek (A, Index1);
        Write (A, Temp2);
        Seek (A, Index2);
        Write (A, Temp1);
    end; {Swap}
procedure ShellSortInsertion (var A : ElementFile; NumVals : Integer);
var
    EleDist : Integer;
    Temp1, Temp2 : ElementType;
    procedure SegmentedInsertion (var A : ElementFile; N, K : Integer);
    var
        J, L : Integer;
    begin {SegmentedInsertion}
        for L := K + 1 to N do
            begin
                J := L - K;
                while J > 0 do
                    begin
                        Seek (A, J+K-1);
                        Read (A, Temp1);
                        Seek (A, J-1);
                        Read (A, Temp2);
                        if Precedes (Temp1, Temp2) then
                            begin
                                Swap (A, J+K-1, J-1, Temp1, Temp2);
                                J := J - K;
                            end
                        else
                            J := 0;
                    end;
            end;
    end; {SegmentedInsertion}
begin {ShellSortInsertion}
    EleDist :=  NumVals div 2;
    while EleDist > 0 do
        begin
            SegmentedInsertion (A, NumVals, EleDist);
            EleDist := EleDist div 2;
        end;
end; {ShellSortInsertion}
begin
    ClrScr;
    Assign (A, 'Strings.dat');
    Reset (A);

    ShellSortInsertion (A, FileSize(A));

end.
