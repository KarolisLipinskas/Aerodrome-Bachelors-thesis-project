page 50090 "Posted Check-In Form"
{
    Editable = false;
    PageType = Card;
    SourceTable = "Posted Check-In";

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = false;
                field("Posted CheckIn No."; Rec."Posted CheckIn No.")
                {
                    ApplicationArea = All;
                }
                field("Flight No."; Rec."Flight No.")
                {
                    ApplicationArea = All;
                }
                field("Ticket No."; Rec."Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Flight Date"; Rec."Flight Date")
                {
                    ApplicationArea = All;
                }
                field("Flight Time"; Rec."Flight Time")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
            }
            group("Customer Info")
            {
                Editable = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Surname; Rec.Surname)
                {
                    ApplicationArea = All;
                }
                field("Personal Code"; Rec."Personal Code")
                {
                    ApplicationArea = All;
                }
            }
            group("Check-In Info")
            {
                field("Registration No."; Rec."Registration No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Registration Time"; Rec."Registration Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Seat Code"; Rec."Seat Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Print Boarding Pass")
            {
                ApplicationArea = All;
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                var
                    PostedCheckInTable: Record "Posted Check-In";
                    FlightPage: Page "Flight List";
                    CheckInPage: Page "Flight Check-In Page";
                begin
                    if Rec."Posted CheckIn No." <> '' then begin
                        PostedCheckInTable.SetRange("Posted CheckIn No.", Rec."Posted CheckIn No.");
                        REPORT.RunModal(REPORT::"Boarding Pass", true, false, PostedCheckInTable);
                    end;
                end;
            }
        }
    }

    trigger OnClosePage()
    begin
        AutomationController.SetIsOpenSubpage(false);
    end;

    trigger OnOpenPage()
    begin
        AutomationController.SetIsOpenSubpage(true);
    end;

    var
        AutomationController: Codeunit "Automation Controller";

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
        GenJournalLineRec.Validate("Payment Method Code", 'CARD');
        GenJournalLineRec.Validate(Description, 'Payment for Baggage Fees. PostedCheck-InNo.: ' + Format(Rec."Posted CheckIn No."));
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

