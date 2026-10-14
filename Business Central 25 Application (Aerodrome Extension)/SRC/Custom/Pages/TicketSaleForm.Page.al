page 50160 "Ticket Sale Form"
{
    PageType = Card;
    SourceTable = "Ticket Sale";

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
            }
            group("Flight Info")
            {
                field("Flight No."; Rec."Flight No.")
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
                field("Ticket No."; Rec."Ticket No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Ticket Price"; Rec."Ticket Price")
                {
                    ApplicationArea = All;
                }
            }
            group("Customer Info")
            {
                field("Person Code"; Rec."Person Code")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Surname; Rec.Surname)
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
            action("Confirm and Post")
            {
                ApplicationArea = All;
                Caption = 'Sell Ticket & Post';
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    TicketPurchase: Record "Ticket Purchase";
                    PostController: Codeunit "Ticket Sale/Purchase Posting";
                    PostedPurchaseNo: Code[20];
                    PostedSaleNo: Code[20];
                    PassengerController: Codeunit "Passenger Logic";
                    PostedSale: Record "Posted Ticket Sale";
                    PurchaseHeaderRec: Record "Purchase Header";
                    SaleHeaderRec: Record "Sales Header";
                    GenJournalLineRec: Record "Gen. Journal Line";
                begin
                    // Custom posting
                    if not TicketPurchase.Get(Rec.TicketPurchNo) then
                        Error('There was an error with generating Ticket Purchase order from Vendor');

                    PostController.CheckSaleData(Rec);
                    if not Confirm('Data Check Successfull\Do you want to post Ticket Sale?', true) then
                        exit;

                    PriceFromVendor := TicketPurchase."Ticket Price";
                    PostedPurchaseNo := PostController.PurchasePosting(TicketPurchase);
                    PostedSaleNo := PostController.SalePosting(Rec);
                    PostController.JournalToLedger();

                    if not PostedSale.Get(PostedSaleNo) then
                        Error('Something went wrong\Could not find Posted Ticket Sale with No.: %1', PostedSaleNo);

                    PassengerController.CustomerToPassenger(PostedSale);

                    Message('*CUSTOM*\Posting Completed Successfully\ Posted Ticket Purchase from Vendor No.: %1\ Posted Ticket Sale to Customer No.: %2\\Flight: %3 - %4 - %5\ Customer with Ticket No.: %6, added to Passenger List\ Passenger with Ticket No.: %6, added to Check-In List', PostedPurchaseNo, PostedSaleNo, PostedSale."Flight No.", PostedSale."Flight Date", PostedSale."Flight Time", PostedSale."Ticket No.");

                    isPosted := true;

                    //RUN the InsertPurchase function to create a records in the Purchase Header and Purchase Lines tables.
                    InsertPurchase(PurchaseHeaderRec, PostedPurchaseNo);

                    //RUN the Post function form the standart (for purchase)
                    PostPurchase(CODEUNIT::"Purch.-Post (Yes/No)", PurchaseHeaderRec);

                    //Run the InsertPurchasePayment to create record in the Gen. Journal Line table
                    InsertPurchasePayment(GenJournalLineRec, GetPostedPuchNo(PurchaseHeaderRec), GetPostedPurchDate(PurchaseHeaderRec));

                    //RUN the Post function from the standart (for payment)
                    CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post", GenJournalLineRec);

                    //RUN the InsertSale function to create records in the Sale Header and Sale Lines tables
                    InsertSale(SaleHeaderRec, PostedSaleNo);

                    //RUN the Post funtion from the standart (for sale)
                    PostSale(CODEUNIT::"Sales-Post (Yes/No)", NavigateAfterPost::"Posted Document", SaleHeaderRec);

                    //Run the InsertSalePayment to create record in the Gen. Journal Line table
                    InsertSalePayment(GenJournalLineRec, GetPostedSaleNo(SaleHeaderRec), GetPostedSaleDate(SaleHeaderRec));

                    //RUN the Post function from the standart (for payment)
                    CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post", GenJournalLineRec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        isPosted := false;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if isPosted then
            exit(true);

        if Confirm('Exiting the page will not save the ticket sale\Do you want to exit?', false) then begin
            Rec.Delete(true);
            exit(true);
        end;

        exit(false);
    end;

    var
        isPosted: Boolean;
        PurchaseDocumentIsPosted: Boolean;
        OpenPostedPurchaseOrderQst: Label 'The order is posted as number %1 and moved to the Posted Purchase Invoices window.\\Do you want to open the posted invoice?';
        OpenPostedSalesOrderQst: Label 'The order is posted as number %1 and moved to the Posted Sales Invoices window.\\Do you want to open the posted invoice?';
        SaleDocumentIsPosted: Boolean;
        NavigateAfterPost: Option "Posted Document","New Document",Nowhere;
        PriceFromVendor: Decimal;

    local procedure PostPurchase(PostingCodeunitID: Integer; var PurchaseHeaderRec: Record "Purchase Header")
    var
        PurchaseHeader: Record "Purchase Header";
        InstructionMgt: Codeunit "Instruction Mgt.";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
        IsScheduledPosting: Boolean;
    begin
        if ApplicationAreaMgmtFacade.IsFoundationEnabled then
            LinesInstructionMgt.PurchaseCheckAllLinesHaveQuantityAssigned(PurchaseHeaderRec);

        PurchaseHeaderRec.SendToPosting(PostingCodeunitID);

        IsScheduledPosting := PurchaseHeaderRec."Job Queue Status" = PurchaseHeaderRec."Job Queue Status"::"Scheduled for Posting";
        PurchaseDocumentIsPosted := (not PurchaseHeader.Get(PurchaseHeaderRec."Document Type", PurchaseHeaderRec."No.")) or IsScheduledPosting;

        if IsScheduledPosting then
            CurrPage.Close;
        CurrPage.Update(false);

        if PostingCodeunitID <> CODEUNIT::"Purch.-Post (Yes/No)" then
            exit;

        if InstructionMgt.IsEnabled(InstructionMgt.ShowPostedConfirmationMessageCode) then
            PURCHASEShowPostedConfirmationMessage(PurchaseHeaderRec);
    end;

    local procedure PURCHASEShowPostedConfirmationMessage(var PurchaseHeaderRec: Record "Purchase Header")
    var
        OrderPurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        InstructionMgt: Codeunit "Instruction Mgt.";
    begin
        if not OrderPurchaseHeader.Get(PurchaseHeaderRec."Document Type", PurchaseHeaderRec."No.") then begin
            PurchInvHeader.SetRange("No.", PurchaseHeaderRec."Last Posting No.");
            if PurchInvHeader.FindFirst then
                if InstructionMgt.ShowConfirm(StrSubstNo(OpenPostedPurchaseOrderQst, PurchInvHeader."No."),
                     InstructionMgt.ShowPostedConfirmationMessageCode)
                then
                    PAGE.Run(PAGE::"Posted Purchase Invoice", PurchInvHeader);
        end;
    end;

    local procedure GetPostedPuchNo(PurchaseHeaderRec: Record "Purchase Header"): Code[20]
    var
        OrderPurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        if not OrderPurchaseHeader.Get(PurchaseHeaderRec."Document Type", PurchaseHeaderRec."No.") then begin
            PurchInvHeader.SetRange("No.", PurchaseHeaderRec."Last Posting No.");
            if PurchInvHeader.FindFirst then
                exit(PurchInvHeader."No.")
            else
                Error('Posted Purchase No. not found');
        end;
    end;

    local procedure GetPostedPurchDate(PurchaseHeaderRec: Record "Purchase Header"): Date
    var
        OrderPurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        if not OrderPurchaseHeader.Get(PurchaseHeaderRec."Document Type", PurchaseHeaderRec."No.") then begin
            PurchInvHeader.SetRange("No.", PurchaseHeaderRec."Last Posting No.");
            if PurchInvHeader.FindFirst then
                exit(PurchInvHeader."Posting Date")
            else
                Error('Posted Purchase Date not found');
        end;
    end;

    local procedure InsertPurchase(var PurchaseHeaderRec: Record "Purchase Header"; CustomPurchNo: Code[20])
    var
        PurchaseHeaderxRec: Record "Purchase Header";
        PurchaseLineRec: Record "Purchase Line";
    begin
        PurchaseHeaderRec.Init;
        PurchaseHeaderRec.Validate("Document Type", 1);
        PurchaseHeaderxRec := PurchaseHeaderRec;
        PurchaseHeaderRec.Validate("Buy-from Vendor Name", Rec."Vendor Name");
        PurchaseHeaderRec.OnAfterValidateBuyFromVendorNo(PurchaseHeaderRec, PurchaseHeaderxRec);
        PurchaseHeaderRec.Validate("Vendor Invoice No.", CustomPurchNo);
        PurchaseHeaderRec.Validate("Currency Code", 'EUR');
        PurchaseHeaderRec.Validate("Posting Date", Rec."Flight Date");
        PurchaseHeaderRec.Insert(true);

        PurchaseLineRec.Init;
        PurchaseLineRec.Validate("Document Type", PurchaseHeaderRec."Document Type");
        PurchaseLineRec.Validate("Document No.", PurchaseHeaderRec."No.");
        PurchaseLineRec.Validate("Line No.", 10000);
        PurchaseLineRec.Validate(Type, 2);
        PurchaseLineRec.Validate("No.", 'PT-0');
        PurchaseLineRec.Validate(Description, 'Plane Ticket No.: ' + Format(Rec."Ticket No."));
        PurchaseLineRec.Validate(Quantity, 1);
        PurchaseLineRec.Validate("Direct Unit Cost", PriceFromVendor);
        //PurchaseLineRec.VALIDATE("Unit Cost (LCY)", "Ticket Price");
        //PurchaseLineRec.VALIDATE("Unit Price (LCY)", "Ticket Price");
        PurchaseLineRec.Insert(true);
    end;

    local procedure PostSale(PostingCodeunitID: Integer; Navigate: Option; var SaleHeaderRec: Record "Sales Header")
    var
        SalesHeader: Record "Sales Header";
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
        InstructionMgt: Codeunit "Instruction Mgt.";
        IsScheduledPosting: Boolean;
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if ApplicationAreaMgmtFacade.IsFoundationEnabled then
            LinesInstructionMgt.SalesCheckAllLinesHaveQuantityAssigned(SaleHeaderRec);

        SaleHeaderRec.SendToPosting(PostingCodeunitID);

        IsScheduledPosting := SaleHeaderRec."Job Queue Status" = SaleHeaderRec."Job Queue Status"::"Scheduled for Posting";
        SaleDocumentIsPosted := (not SalesHeader.Get(SaleHeaderRec."Document Type", SaleHeaderRec."No.")) or IsScheduledPosting;
        OnPostOnAfterSetDocumentIsPosted(SalesHeader, IsScheduledPosting, SaleDocumentIsPosted);

        if IsScheduledPosting then
            CurrPage.Close;
        CurrPage.Update(false);

        if PostingCodeunitID <> CODEUNIT::"Sales-Post (Yes/No)" then
            exit;

        case Navigate of
            NavigateAfterPost::"Posted Document":
                begin
                    if InstructionMgt.IsEnabled(InstructionMgt.ShowPostedConfirmationMessageCode) then
                        SALEShowPostedConfirmationMessage(SaleHeaderRec);

                    if SaleDocumentIsPosted then
                        CurrPage.Close;
                end;
            NavigateAfterPost::"New Document":
                if SaleDocumentIsPosted then begin
                    SalesHeader.Init;
                    SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Order);
                    OnPostOnBeforeSalesHeaderInsert(SalesHeader);
                    SalesHeader.Insert(true);
                    PAGE.Run(PAGE::"Sales Order", SalesHeader);
                end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostOnAfterSetDocumentIsPosted(SalesHeader: Record "Sales Header"; var IsScheduledPosting: Boolean; var DocumentIsPosted: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostOnBeforeSalesHeaderInsert(var SalesHeader: Record "Sales Header")
    begin
    end;

    local procedure SALEShowPostedConfirmationMessage(var SaleHeaderRec: Record "Sales Header")
    var
        OrderSalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        InstructionMgt: Codeunit "Instruction Mgt.";
    begin
        if not OrderSalesHeader.Get(SaleHeaderRec."Document Type", SaleHeaderRec."No.") then begin
            SalesInvoiceHeader.SetRange("No.", SaleHeaderRec."Last Posting No.");
            if SalesInvoiceHeader.FindFirst then
                if InstructionMgt.ShowConfirm(StrSubstNo(OpenPostedSalesOrderQst, SalesInvoiceHeader."No."),
                     InstructionMgt.ShowPostedConfirmationMessageCode)
                then
                    PAGE.Run(PAGE::"Posted Sales Invoice", SalesInvoiceHeader);
        end;
    end;

    local procedure GetPostedSaleNo(SaleHeaderRec: Record "Sales Header"): Code[20]
    var
        OrderSalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if not OrderSalesHeader.Get(SaleHeaderRec."Document Type", SaleHeaderRec."No.") then begin
            SalesInvoiceHeader.SetRange("No.", SaleHeaderRec."Last Posting No.");
            if SalesInvoiceHeader.FindFirst then
                exit(SalesInvoiceHeader."No.")
            else
                Error('Posted Sale No. not found');
        end;
    end;

    local procedure GetPostedSaleDate(SaleHeaderRec: Record "Sales Header"): Date
    var
        OrderSalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if not OrderSalesHeader.Get(SaleHeaderRec."Document Type", SaleHeaderRec."No.") then begin
            SalesInvoiceHeader.SetRange("No.", SaleHeaderRec."Last Posting No.");
            if SalesInvoiceHeader.FindFirst then
                exit(SalesInvoiceHeader."Posting Date")
            else
                Error('Posted Sale Date not found');
        end;
    end;

    local procedure InsertSale(var SaleHeaderRec: Record "Sales Header"; CustomSaleNo: Code[20])
    var
        SaleHeaderxRec: Record "Sales Header";
        SaleLineRec: Record "Sales Line";
    begin
        SaleHeaderRec.Init;
        SaleHeaderRec.Validate("Document Type", 1);
        SaleHeaderxRec := SaleHeaderRec;
        SaleHeaderRec.Validate("Sell-to Customer No.", Rec.Customer);
        SaleHeaderRec.SelltoCustomerNoOnAfterValidate(SaleHeaderRec, SaleHeaderxRec);
        SaleHeaderRec.Validate("Currency Code", 'EUR');
        SaleHeaderRec.Validate("External Document No.", CustomSaleNo);
        SaleHeaderRec.Validate("Posting Date", Rec."Flight Date");
        SaleHeaderRec.Insert(true);

        SaleLineRec.Init;
        SaleLineRec.Validate("Document Type", SaleHeaderRec."Document Type");
        SaleLineRec.Validate("Document No.", SaleHeaderRec."No.");
        SaleLineRec.Validate("Line No.", 10000);
        SaleLineRec.Validate(Type, 2);
        SaleLineRec.Validate("No.", 'PT-0');
        SaleLineRec.Validate(Description, 'Plane Ticket No.: ' + Format(Rec."Ticket No."));
        SaleLineRec.Validate(Quantity, 1);
        SaleLineRec.Validate("Unit Price", Rec."Ticket Price");
        SaleLineRec.Insert(true);
    end;

    local procedure InsertPurchasePayment(var GenJournalLineRec: Record "Gen. Journal Line"; PurchNo: Code[20]; PurchPostedDate: Date)
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
        GenJournalLineRec.Validate("Posting Date", PurchPostedDate);
        GenJournalLineRec.Validate("Document Type", 1);
        GenJournalLineRec.Validate("Document No.", PurchNo);
        GenJournalLineRec.Validate("Account Type", 2);
        GenJournalLineRec.Validate("Applies-to Doc. Type", 2);
        GenJournalLineRec.Validate("Applies-to Doc. No.", PurchNo);
        GenJournalLineRec.Validate("Payment Method Code", 'BANK');
        GenJournalLineRec.Validate(Description, 'Payment for purchase of ticket No.: ' + Format(Rec."Ticket No."));
        GenJournalLineRec.Insert(true);
    end;

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
        GenJournalLineRec.Validate(Description, 'Payment for sale of ticket No.: ' + Format(Rec."Ticket No."));
        GenJournalLineRec.Insert(true);
    end;
}

