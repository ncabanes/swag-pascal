program amort;

{ This program does a good job of loan amortization. The original
  author is unknown. I added a procedure to exit the program without
  showing all years for amortization. Richard Odom..VA Beach        }

const
  MonthTab = 8; {month column}
  PayTab = 14;  {payment column}
  PrinTab = 28; {principle column}
  IntTab = 41;  {interest column}
  BalTab = 53;  {balance column}


var
  balance, payment, interest, rate, years,
  i1, i2, CurrInt, CurrPrin, ypay, yint, yprin,
  GTPay, GTInt, GTPrin:                            real;
  year, month, line:                            integer;
  borrower:                                  string[32];
  response:                                        char;




begin
  repeat

    ClrScr;
    write ('Name of borrower: ');
    readln (borrower);
    write ('Amount of loan: ');
    readln (balance);
    write ('Interest rate: ');
    readln (interest);
    i1 := interest/1200 {monthly interest};
    write ('Do you know the monthly payments? ');
    readln (response);

    if UpCase(response) = 'Y'
      then begin
        write ('Payment amount: ');
        readln (payment);
      end
      else begin
        write ('Number of years: ');
        readln (years);
        i2 := exp(ln(i1 + 1) * (12 * years));
        payment := balance * i1 * i2 / (i2 - 1);
        payment := int(payment * 100 + 0.5) / 100;
        writeln ('The monthly payment is $',payment:4:2,'.')
      end;

    write ('Starting year for loan: ');
    readln (year);
    write ('Starting month for loan: ');
    readln (month);
    write ('Press <RETURN> to see monthly totals.');
    readln (response);
    ClrScr; line := 6;
    writeln ('Loan for ',borrower);
    writeln (' Loan of $',balance:4:2,' at ',interest:4:2,'% interest.');
    writeln (' Fixed monthly payments of $',payment:4:2,'.');
    writeln;
    writeln (year:4,'  Month     Payment     Principle     Interest       Balance');
    ypay := 0; yprin := 0; yint := 0;
    GTPay := 0; GTInt := 0; GTPrin := 0; {initialize totals}

    while balance>0 do begin
      CurrInt := int(100 * i1 * balance +0.5) / 100;
      CurrPrin := payment - CurrInt;

      if CurrPrin>balance then begin
        CurrPrin := balance;
        payment := CurrInt + CurrPrin;
      end;

      balance := balance - CurrPrin;
      ypay := ypay + payment; yint := yint + CurrInt; yprin := yprin + CurrPrin;
      GTPay := GTPay + payment; GTInt := GTInt + CurrInt; GTPrin := GTPrin + CurrPrin;
      line := line + 1; GotoXY(MonthTab,line);
      write (month:2); GotoXY(PayTab,line);
      write (payment:10:2); GotoXY(PrinTab,line);
      write (CurrPrin:10:2); GotoXY(IntTab,line);
      write (CurrInt:10:2); GotoXY(BalTab,line);
      writeln (balance:12:2);
      month := month + 1;

      if (month>12) or (balance=0.0) then begin
        writeln; line := line + 2;
        write (year:4,' Total'); GotoXY(PayTab,line);
        write (ypay:10:2); GotoXY(PrinTab,line);
        write (yprin:10:2); GotoXY(IntTab,line);
        write (yint:10:2); GotoXY(BalTab,line);
        writeln (balance:12:2);
        year := year + 1;
        month := 1;
        ypay := 0; yprin := 0; yint := 0;

        if balance>0 then begin
          writeln;
          writeln ('Press <RETURN> to see ',year:4,'.');
          write('Enter Q to end program  ');
          readln (response);
          If upcase(response)='Q' then
           halt;
          ClrScr; line := 2; writeln (year:4,'  Month     Payment     Principle     Interest       Balance');
        end;

      end;

    end; {while}

    writeln; line := line + 2;
    write ('Grand Total'); GotoXY(PayTab,line);
    write (GTPay:10:2); GotoXY(PrinTab,line);
    write (GTPrin:10:2); GotoXY(IntTab,line);
    write (GTInt:10:2); GotoXY(BalTab,line);
    writeln (balance:12:2);
    writeln;
    write ('Do you wish to start over? ');
    readln (response);

  until UpCase(response)='N';

end.