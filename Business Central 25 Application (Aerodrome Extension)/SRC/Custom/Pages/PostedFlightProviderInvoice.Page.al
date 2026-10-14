page 50220 "Posted Flight Provider Invoice"
{
    Editable = false;
    PageType = Card;
    SourceTable = "Posted Flight Provider Invoice";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Posted No."; Rec."Posted No.")
                {
                    ApplicationArea = All;
                }
                field(Customer; Rec.Customer)
                {
                    ApplicationArea = All;
                }
                field(CustomersName; FlightProviderName)
                {
                    ApplicationArea = All;
                    Caption = 'Customers Name';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                }
                field("Flight Count"; Rec."Flight Count")
                {
                    ApplicationArea = All;
                }
                field("CheckedIn Passenger Count"; Rec."CheckedIn Passenger Count")
                {
                    ApplicationArea = All;
                }
                field("Boarded Passenger Count"; Rec."Boarded Passenger Count")
                {
                    ApplicationArea = All;
                }
                field("Price For CheckedIn"; Rec."Price For CheckedIn")
                {
                    ApplicationArea = All;
                }
                field("Price For Boarded"; Rec."Price For Boarded")
                {
                    ApplicationArea = All;
                }
                field("Total Price"; Rec."Total Price")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Payment Status';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Print Invoice")
            {
                ApplicationArea = All;
                Image = Invoice;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                var
                    InvReport: Report "Flight Provider Invoice";
                begin
                    InvReport.SetParameters(Rec."Price For CheckedIn", Rec."Price For Boarded", Rec."Total Price");
                    InvReport.SetFlightFilterFields(Rec.Customer, Rec."Start Date", Rec."End Date");
                    InvReport.RunModal;

                    //REPORT.RUNMODAL(REPORT::"Flight Provider Invoice", FALSE, FALSE, Flight);

                    Message('Invoice is Printed Successfully');
                end;
            }
            action(Pay)
            {
                ApplicationArea = All;
                Image = Payment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    GenJournalLineRec: Record "Gen. Journal Line";
                begin
                    if Rec.Status = 1 then
                        Error('Baggage is already paid for');

                    //Run the InsertSalePayment to create record in the Gen. Journal Line table
                    InsertSalePayment(GenJournalLineRec, GetPostedSaleNo(), GetPostedSaleDate());

                    //RUN the Post function from the standart (for payment)
                    CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post", GenJournalLineRec);

                    Rec.Status := 1;
                    Rec.Modify;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        FlightProvider: Record Customer;
    begin
        if FlightProvider.Get(Rec.Customer) then
            FlightProviderName := FlightProvider.Name;
    end;

    var
        FlightProviderName: Text[50];

    local procedure InsertSalePayment(var GenJournalLineRec: Record "Gen. Journal Line"; SaleNo: Code[20]; SalePostedDate: Date)
    var
        GenJournalLine: Record "Gen. Journal Line";
        LineNumber: Integer;
    begin
        // Get last Payment in order to set line number
        GenJournalLine.SetRange("Journal Template Name", 'PAYMENT');
        GenJournalLine.SetCurrentKey("Line No.");
        if GenJournalLine.FindLast then
            LineNumber := GenJournalLine."Line No."
        else
            LineNumber := 0;

        GenJournalLineRec.Init;
        GenJournalLineRec.Validate("Journal Template Name", 'PAYMENT');
        GenJournalLineRec.Validate("Line No.", LineNumber + 10000);
        GenJournalLineRec.Validate("Journal Batch Name", 'BANK');
        GenJournalLineRec.Validate("Posting Date", SalePostedDate);
        GenJournalLineRec.Validate("Document Type", 1);
        GenJournalLineRec.Validate("Document No.", SaleNo);
        GenJournalLineRec.Validate("Account Type", 1);
        GenJournalLineRec.Validate("Applies-to Doc. Type", 2);
        GenJournalLineRec.Validate("Applies-to Doc. No.", SaleNo);
        GenJournalLineRec.Validate("Payment Method Code", 'BANK');
        GenJournalLineRec.Validate(Description, 'Payment for Proccessed Passenger Invoice. PostedInvoiceNo.: ' + Format(Rec."Posted No."));
        GenJournalLineRec.Insert(true);
    end;

    local procedure GetPostedSaleNo(): Code[20]
    var
        OrderSalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if not OrderSalesHeader.Get(Rec.SalesHeaderDocType, Rec.SalesHeaderNo) then begin
            SalesInvoiceHeader.SetRange("No.", Rec.SalesHeaderLastPostingNo);
            if SalesInvoiceHeader.FindFirst then
                exit(SalesInvoiceHeader."No.")
            else
                Error('Posted Sale No. not found');
        end;
    end;

    local procedure GetPostedSaleDate(): Date
    var
        OrderSalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if not OrderSalesHeader.Get(Rec.SalesHeaderDocType, Rec.SalesHeaderNo) then begin
            SalesInvoiceHeader.SetRange("No.", Rec.SalesHeaderLastPostingNo);
            if SalesInvoiceHeader.FindFirst then
                exit(SalesInvoiceHeader."Posting Date")
            else
                Error('Posted Sale Date not found');
        end;
    end;
}

