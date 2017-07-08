(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0191.PAS
  Description: Very Quick Loan Amortizaton
  Author: GLENN GROTZINGER
  Date: 11-29-96  08:17
*)


program amortization_schedule;

  { smaller than what exists in swag now and doesn't need to know the
payment...just the APR and terms (what you hear at the loan office
anyway)...then determines an amortization schedule }

  var
    loan_left, loan_amount, interest, loan_payment, apr, t: real;
    number_periods, i: integer;
    outfile: text;

  function power(x, y: real):real;
    begin
      power := exp(y*ln(x));
    end;

  begin
    assign(outfile, 'AMORT.TXT');
    rewrite(outfile);
    writeln('Loan Amortization Schedule (assumes entry of yearly interest',
            ' rate and # of months of payment (made at end of month)');
    writeln('Omit all $ signs.');
    write('What is the APR of the loan? ');
    readln(t);
    apr := t/100/12;
    write('What is the # of payments in the loan (made monthly)?');
    readln(number_periods);
    write('How much is the loan for?');
    readln(loan_amount);
    loan_payment := loan_amount/((1-(1/power(1+apr,number_periods)))/apr);
    writeln(outfile, 'Amortization Report':25);
    writeln(outfile, t:0:2, '% interest, ', number_periods,
                   ' monthly payments, Loan of $', loan_amount:0:2);
    writeln(outfile);
    writeln(outfile, 'Your loan payment is $', loan_payment:0:2);
    writeln(outfile);
    writeln(outfile, 'Months, payment a month, interest paid,',
                     ' principal paid, loan amount pending');
    for i := 1 to number_periods do
      begin
        interest := loan_amount * apr;
        loan_left := loan_payment - interest;
        loan_amount := loan_amount - loan_left;
        writeln(outfile, i:4, loan_payment:16:2, interest:16:2,
                loan_left:16:2, loan_amount:16:2);
      end;
    close(outfile);
    writeln('AMORT.TXT report generated.');
  end.
