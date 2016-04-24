(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0058.PAS
  Description: Roots
  Author: MARC HEYVAERT
  Date: 01-27-94  12:20
*)

{
> I am trying to write a program that will find the cube root of the
> numbers 1 to 50.

OK. You will have to use the EXP and LN functions as follows (full explanation
of mathematics involved, to give you the general background)

       X=log Y means Y = a^X    (1)
            a

       and  log X = LN(X) ; e^X = EXP(X) and EXP(LN(X))=X   (2)
               e

Your problem is e.g.  10 = a^3 and you want to find a solution for a

 now from (1)

             10 = a^3 so 3=log 10
                              a
                                        log k
We lose the a by using the rule log k = --------  (the base is not important)
                                   a    log a

         log 10
 so  3 = ------
         log a

                                LN(10)
 or using base e, in Pascal 3 = ------
                                LN(a)

                                LN(10)
                        LN(a) = ------ = 0.76752836433
                                  3

 to find a we have to raise e to this power and EXP(....)= 2.15443469003

 which is the 3rd root of 10

This works for all root calculations so


 ROOT(X,Y):=EXP(LN(Y)/X)

}

