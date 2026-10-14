page 50210 "New Flight Provider Invoice"
{
    PageType = Card;
    SourceTable = "Flight Provider Invoice";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Customer; Rec.Customer)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        PostedInvoice: Record "Posted Flight Provider Invoice";
                        FlightProvider: Record Customer;
                    begin
                        if Rec.Customer = '' then begin
                            isCustomerPresent := false;
                            isStartDatePresent := false;
                            FlightProviderName := '';
                            exit;
                        end;

                        if FlightProvider.Get(Rec.Customer) then begin
                            FlightProviderName := FlightProvider.Name;
                            Rec."Price For CheckedIn" := FlightProvider."Default Price CheckIn";
                            Rec."Price For Boarded" := FlightProvider."Default Price Boarding";
                        end;

                        isCustomerPresent := true;
                        isStartDatePresent := false;
                        isDateEditable := true;
                        PostedInvoice.SetRange(Customer, Rec.Customer);
                        if PostedInvoice.FindLast then begin
                            isStartDatePresent := true;
                            isDateEditable := false;
                        end;
                    end;
                }
                field(CustomersName; FlightProviderName)
                {
                    ApplicationArea = All;
                    Caption = 'Customers Name';
                    Editable = false;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    Editable = isCustomerPresent AND isDateEditable;

                    trigger OnValidate()
                    begin
                        if Rec."Start Date" = 0D then
                            isStartDatePresent := false
                        else
                            isStartDatePresent := true;
                    end;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    Editable = isStartDatePresent;
                }
                field("Flight Count"; Rec."Flight Count")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("CheckedIn Passenger Count"; Rec."CheckedIn Passenger Count")
                {
                    ApplicationArea = All;
                    Caption = 'Checked-In Passenger Count';
                    Editable = false;
                }
                field("Boarded Passenger Count"; Rec."Boarded Passenger Count")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Price For CheckedIn"; Rec."Price For CheckedIn")
                {
                    ApplicationArea = All;
                    Caption = 'Price For One Checked-In Passenger';
                }
                field("Price For Boarded"; Rec."Price For Boarded")
                {
                    ApplicationArea = All;
                    Caption = 'Price For One Boarded Passenger';
                }
                field("Total Price"; Rec."Total Price")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Post & Print Report")
            {
                ApplicationArea = All;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    PostController: Codeunit "Flight Prov. Invoice Posting";
                    PostedInvoiceNo: Code[20];
                    PostedInvoice: Record "Posted Flight Provider Invoice";
                    SaleHeaderRec: Record "Sales Header";
                begin
                    PostedInvoiceNo := PostController.InvoicePosting(Rec);
                    isPosted := true;
                    CurrPage.Close();

                    if Rec."Total Price" > 0 then begin
                        //RUN the InsertSale function to create records in the Sale Header and Sale Lines tables
                        InsertSale(SaleHeaderRec, PostedInvoiceNo);

                        //RUN the Post funtion from the standart (for sale)
                        PostSale(CODEUNIT::"Sales-Post (Yes/No)", NavigateAfterPost::"Posted Document", SaleHeaderRec);

                        if PostedInvoice.Get(PostedInvoiceNo) then begin
                            PostedInvoice.SalesHeaderDocType := SaleHeaderRec."Document Type";
                            PostedInvoice.SalesHeaderNo := SaleHeaderRec."No.";
                            PostedInvoice.SalesHeaderLastPostingNo := SaleHeaderRec."Last Posting No.";
                            PostedInvoice.Modify;
                        end else
                            Error('Unexpected error Posted Check-In No. not found');

                    end else begin
                        if PostedInvoice.Get(PostedInvoiceNo) then begin
                            PostedInvoice.Status := 1;
                            PostedInvoice.Modify;
                        end;
                    end;

                    if PostedInvoice.Get(PostedInvoiceNo) then
                        PAGE.Run(PAGE::"Posted Flight Provider Invoice", PostedInvoice);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        isCustomerPresent := false;
        isStartDatePresent := false;
        isDateEditable := false;
        isPosted := false;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if isPosted then
            exit(true);

        if Confirm('Exiting the page will not save the Invoice\Do you want to exit?', false) then begin
            Rec.Delete(true);
            exit(true);
        end;

        exit(false)
    end;

    var
        isCustomerPresent: Boolean;
        isStartDatePresent: Boolean;
        isDateEditable: Boolean;
        isPosted: Boolean;
        FlightProviderName: Text[50];
        SaleDocumentIsPosted: Boolean;
        NavigateAfterPost: Option "Posted Document","New Document",Nowhere;
        OpenPostedSalesOrderQst: Label 'The order is posted as number %1 and moved to the Posted Sales Invoices window.\\Do you want to open the posted invoice?';

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
        SaleHeaderRec.Insert(true);

        SaleLineRec.Init;
        SaleLineRec.Validate("Document Type", SaleHeaderRec."Document Type");
        SaleLineRec.Validate("Document No.", SaleHeaderRec."No.");
        SaleLineRec.Validate("Line No.", 10000);
        SaleLineRec.Validate(Type, 2);
        SaleLineRec.Validate("No.", 'FPI-0');
        SaleLineRec.Validate(Description, 'Flight Processing Invoice from ' + Format(Rec."Start Date") + ' to ' + Format(Rec."End Date"));
        SaleLineRec.Validate(Quantity, 1);
        SaleLineRec.Validate("Unit Price", Rec."Total Price");
        SaleLineRec.Insert(true);
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
}

