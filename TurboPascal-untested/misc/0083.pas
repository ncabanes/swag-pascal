{
From: WAYNE MOSES
Subj: Spell a Number
---------------------------------------------------------------------------
 *> Quoting Chris Serino to All on 01-04-94  17:28
 *> Re: Help Looking for a Number

 Hello Chris:

 CS> I'm in the process of writing a Checkbook program for my Job and I
 CS> was  wondering if anyone out there has a routine to convert a check
 CS> amount written  in numerical to text.  Here's an example of what I
 CS> need. Input Variable :  142.50
 CS> Needed Output  : One Hundred Foury Two 50/100--------------------

 Weeeelllll ... since I am not really interested in releasing my personal
 check writing program to the world, I'll upload what I wrote last month.

 ------- 8< ------------[ CUT LINE ]-------------- >8 -------
}
Function Translate(var DollarAmt : real) : string;

(*
   This is a module that converts the numerical dollar amount to a string,
   for example it converts $156.15 to :

               'One Hundred and Fifty Six dollars ------------15/xx'.

   The field length of the translated amount is limited to 53 characters.

   Amounts up to and including $99,999.99 are supported.  I rarely write
   cheques larger than that, so they can be written by hand. ;-)

   ======================================================================
   Dedicated to the PUBLIC DOMAIN, this software code has been tested and
   used under TP 6.0/DOS and MS-DOS 6.2.
   ======================================================================
*)

const
     SingleSpelled : array[1..9] of string = ('One ','Two ','Three ','Four ',
                                              'Five ','Six ','Seven ','Eight ',
                                              'Nine ');

     TeenSpelled : array[1..9] of string = ('Eleven ','Twelve ','Thirteen ',
                                            'Fourteen ','Fifteen ','Sixteen ',
                                            'Seventeen ','Eighteen ','Nineteen');

     TenSpelled : array[1..9] of string = ('Ten ','Twenty ','Thirty ','Forty ',
                                           'Fifty ','Sixty ','Seventy ','Eighty',
                                           'Ninety ');

var
   Dollars, Cents,
   SingleStr, TenStr, HundredStr, ThousandStr   : string;
   Singles, Tens, Hundreds, Thousands, k, l     : integer;

begin
     if DollarAmt = 0 then         (* The amount to be translated is 0.00 *)
     begin                         (* so the Dollars and Cents must be    *)
          Dollars := 'Zero ';      (* to reflect this.                    *)
          Cents   := '00';
     end

     else
     begin                         (* Non trivial value for DollarAmt     *)

     SingleStr := ''; TenStr := ''; HundredStr := ''; ThousandStr := '';

     { Parse the Cents out of DollarAmt }

     Str(frac(DollarAmt):0:2, Cents);
     if frac(DollarAmt) > 0 then
        Cents := copy(Cents,pos('.',Cents)+1,2)
     else
         Cents := '00';

     { Next parse the Dollars out of DollarAmt }

     Str(int(DollarAmt):1:0, Dollars);

     { Now, define the number of Singles, Tens, Hundreds, and Thousands }

     Thousands   := trunc(DollarAmt/1000);

     Hundreds    := trunc(DollarAmt/100)-Thousands*10;
     HundredStr  := SingleSpelled[Hundreds];

     Tens        := trunc(DollarAmt/10)-(Thousands*100+Hundreds*10);

     Singles     := trunc(DollarAmt)-(Thousands*1000+Hundreds*100+Tens*10);
     SingleStr   := SingleSpelled[Singles];

     case Tens of
     1    : begin
                 TenStr := TeenSpelled[Singles];
                 SingleStr := '';
            end;
     2..9 : TenStr := TenSpelled[Tens];
     end;

     case Thousands of
     10,20,
     30,50,
     60,70,
     80,90  : ThousandStr := TenSpelled[trunc(Thousands/10)];
     1..9   : ThousandStr := SingleSpelled[Thousands];
     11..19 : ThousandStr := TeenSpelled[Thousands-10];

     21..29 : ThousandStr := TenSpelled[trunc(Thousands/10)]+
                             SingleSpelled[Thousands-20];
     31..39 : ThousandStr := TenSpelled[trunc(Thousands/10)]+
                             SingleSpelled[Thousands-30];
     41..49 : ThousandStr := TenSpelled[trunc(Thousands/10)]+
                             SingleSpelled[Thousands-40];
     51..59 : ThousandStr := TenSpelled[trunc(Thousands/10)]+
                             SingleSpelled[Thousands-50];
     61..69 : ThousandStr := TenSpelled[trunc(Thousands/10)]+
                             SingleSpelled[Thousands-60];
     71..79 : ThousandStr := TenSpelled[trunc(Thousands/10)]+
                             SingleSpelled[Thousands-70];
     81..89 : ThousandStr := TenSpelled[trunc(Thousands/10)]+
                             SingleSpelled[Thousands-80];
     91..99 : ThousandStr := TenSpelled[trunc(Thousands/10)]+
                             SingleSpelled[Thousands-90];
     end;

     if Thousands > 0 then
        Dollars := ThousandStr+'Thousand '+HundredStr+'Hundred & '
                   + TenStr + SingleStr
     else
     if (Hundreds > 0) and (Thousands = 0) then
        Dollars := HundredStr+'Hundred and '+ TenStr + SingleStr
     else
         Dollars := TenStr + SingleStr;

     end;                              (* End of block for non-trivial    *)
                                       (* value for DollarAmt             *)
     l := length(Dollars);

     for k := 1 to 60-(10+l+length(Cents)) do
         Dollars := Dollars+'-';

     If Thousands < 100 then
        Translate := Dollars+Cents+'/xx'
     else
         begin
         TextColor(Yellow+Blink);
         Translate := '******** INVALID!  THIS AMOUNT NOT SUPPORTED ********';
         end;
end;
