{
> Can you show me any version of thew quick sort that you may have? I've
> never seen it and never used it before. I always used an insertion sort
> For anything that I was doing.

Here is one (long) non-recursive version, quite fast.
}

Type
  _Compare  = Function(Var A, B) : Boolean;{ QuickSort Calls This }

{ --------------------------------------------------------------- }
{ QuickSort Algorithm by C.A.R. Hoare.  Non-Recursive adaptation  }
{ from "ALGORITHMS + DATA STRUCTURES = ProgramS" by Niklaus Wirth }
{ Prentice-Hall, 1976. Generalized For unTyped arguments.   }
{ --------------------------------------------------------------- }

Procedure QuickSort(V      : Pointer;   { To Array of Records }
                    Cnt    : Word;      { Record Count        }
                    Len    : Word;      { Record Length       }
                    ALessB : _Compare); { Compare Function    }

Type
  SortRec = Record
    Lt, Rt : Integer
  end;

  SortStak = Array [0..1] of SortRec;

Var
  StkT,
  StkM,
  Ki, Kj,
  M       : Word;
  Rt, Lt,
  I, J    : Integer;
  Ps      : ^SortStak;
  Pw, Px  : Pointer;

  Procedure Push(Left, Right : Integer);
  begin
    Ps^[StkT].Lt := Left;
    Ps^[StkT].Rt := Right;
    Inc(StkT);
  end;

  Procedure Pop(Var Left, Right : Integer);
  begin
    Dec(StkT);
    Left  := Ps^[StkT].Lt;
    Right := Ps^[StkT].Rt;
  end;

begin {QSort}
  if (Cnt > 1) and (V <> Nil) Then
  begin
    StkT := Cnt - 1;    { Record Count - 1 }
    Lt   := 1;          { Safety Valve    }

    { We need a stack of Log2(n-1) entries plus 1 spare For safety }

    Repeat
      StkT := StkT SHR 1;
      Inc(Lt);
    Until StkT = 0; { 1+Log2(n-1) }

    StkM := Lt * SizeOf(SortRec) + Len + Len; { Stack Size + 2 Records }

    GetMem(Ps, StkM);   { Allocate Memory    }

    if Ps = Nil Then
      RunError(215); { Catastrophic Error }

    Pw := @Ps^[Lt];   { Swap Area Pointer  }
    Px := Ptr(Seg(Pw^), Ofs(Pw^) + Len); { Hold Area Pointer  }

    Lt := 0;
    Rt := Cnt - 1;  { Initial Partition  }

    Push(Lt, Rt);   { Push Entire Table  }

    While StkT > 0 Do
    begin  { QuickSort Main Loop }
      Pop(Lt, Rt);   { Get Next Partition  }
      Repeat
        I := Lt; J := Rt;  { Set Work Pointers }

        { Save Record at Partition Mid-Point in Hold Area }
        M := (LongInt(Lt) + Rt) div 2;
        Move(Ptr(Seg(V^), Ofs(V^) + M * Len)^, Px^, Len);

        { Get Useful Offsets to speed loops }
        Ki := I * Len + Ofs(V^);
        Kj := J * Len + Ofs(V^);

        Repeat
          { Find Left-Most Entry >= Mid-Point Entry }
          While ALessB(Ptr(Seg(V^), Ki)^, Px^) Do
          begin
            Inc(Ki, Len);
            Inc(I)
          end;

          { Find Right-Most Entry <= Mid-Point Entry }
          While ALessB(Px^, Ptr(Seg(V^), Kj)^) Do
          begin
            Dec(Kj, Len);
            Dec(J)
          end;

          { if I > J, the partition has been exhausted }
          if I <= J Then
          begin
            if I < J Then  { we have two Records to exchange }
            begin
              Move(Ptr(Seg(V^), Ki)^, Pw^, Len);
              Move(Ptr(Seg(V^), Kj)^, Ptr(Seg(V^), Ki)^, Len);
              Move(Pw^, Ptr(Seg(V^), Kj)^, Len);
            end;

            Inc(I);
            Dec(J);
            Inc(Ki, Len);
            Dec(Kj, Len);
          end; { if I <= J }
        Until I > J;  { Until All Swaps Done }

        { We now have two partitions.  At left are all Records }
        { < X, and at right are all Records > X.  The larger   }
        { partition is stacked and we re-partition the residue }
        { Until time to pop a deferred partition.              }

        if (J - Lt) < (Rt - I) Then { Right-Most Partition is Larger }
        begin
          if I < Rt Then
            Push(I, Rt); { Stack Right Side }
          Rt := J;    { Resume With Left }
        end
        else  {  Left-Most Partition is Larger }
        begin
          if Lt < J Then
            Push(Lt, J); { Stack Left Side   }
          Lt := I;    { Resume With Right }
        end;

      Until Lt >= Rt;  { QuickSort is now Complete }
    end;
    FreeMem(Ps, StkM);   { Free Stack and Work Areas }
  end;
end; {QSort}
