page 50050 "Check-In Form"
{
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Check-In";

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
                    Editable = isEditable;

                    trigger OnValidate()
                    begin
                        //IF "Seat Code" <> '' THEN
                        //  isCheckedIn := TRUE
                        //ELSE
                        //  isCheckedIn := FALSE;
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Post)
            {
                ApplicationArea = All;
                Caption = 'Finish Check-In & Print Boarding Pass';
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    PostController: Codeunit "Check-In Posting";
                    PostedCheckInNo: Code[20];
                    PostedCheckIn: Record "Posted Check-In";
                    CheckIn: Record "Check-In";
                    SaleHeaderRec: Record "Sales Header";
                begin
                    PostController.CheckData(Rec);
                    PostedCheckInNo := PostController.PostCheckIn(Rec);

                    Rec.Init;
                    Rec.TransferFields(xRec);
                    Rec."No." := PostedCheckInNo;
                    Rec.Insert(false);
                    xRec.Delete(true);

                    Message('Passenger Check-In Posted successfully');

                    CurrPage.Close;
                    if PostedCheckIn.Get(PostedCheckInNo) then
                        PAGE.Run(PAGE::"Posted Check-In Form", PostedCheckIn);
                end;
            }
            action("Check-In Passenger")
            {
                ApplicationArea = All;
                Image = Approval;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = NOT isCheckedIn;

                trigger OnAction()
                var
                    //NoSeriesMgt: Codeunit NoSeriesManagement;
                    NoSeries: Codeunit "No. Series";
                begin
                    if Rec."Seat Code" = '' then
                        Error('Seat Code cannot be empty');

                    Rec.Status := 2;
                    //NoSeriesMgt.InitSeries('CI', xRec."No. Series", 0D, Rec."Registration No.", Rec."No. Series");
                    if Rec."Registration No." = '' then begin
                        Rec."No. Series" := 'CI';
                        if NoSeries.AreRelated('CI', xRec."No. Series") then
                            Rec."No. Series" := xRec."No. Series";
                        Rec."Registration No." := NoSeries.GetNextNo(rec."No. Series");
                    end;
                    Rec."Registration Time" := Time;
                    Rec.Modify;

                    isCheckedIn := true;
                end;
            }
            action("UnCheck Passenger")
            {
                ApplicationArea = All;
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = isCheckedIn;

                trigger OnAction()
                begin
                    Rec.Status := 1;
                    Rec."Registration No." := '';
                    Rec."Registration Time" := 0T;
                    Rec."Seat Code" := '';
                    Rec.Modify;

                    isCheckedIn := false;
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
        if Rec.Status <> 0 then
            isEditable := true
        else
            isEditable := false;

        if Rec.Status = 2 then
            isCheckedIn := true
        else
            isCheckedIn := false;

        AutomationController.SetIsOpenSubpage(true);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        //IF (Status = 2) AND (COPYSTR("No.",1,1) <> 'P') THEN
        //  ERROR('Please post before exiting');
    end;

    var
        isEditable: Boolean;
        isCheckedIn: Boolean;
        AutomationController: Codeunit "Automation Controller";
        SaleDocumentIsPosted: Boolean;
        NavigateAfterPost: Option "Posted Document","New Document",Nowhere;
        OpenPostedSalesOrderQst: Label 'The order is posted as number %1 and moved to the Posted Sales Invoices window.\\Do you want to open the posted invoice?';

    local procedure InsertSale(var SaleHeaderRec: Record "Sales Header"; CustomSaleNo: Code[20])
    var
        SaleHeaderxRec: Record "Sales Header";
        SaleLineRec: Record "Sales Line";
        Customer: Record Customer;
        i: Integer;
        LineNumber: Integer;
    begin
        Customer.SetRange(Name, Rec.Name);
        Customer.SetRange(Surname, Rec.Surname);
        Customer.SetRange("Person Code", Rec."Personal Code");
        if not Customer.FindFirst then
            Error('Customer not found');

        SaleHeaderRec.Init;
        SaleHeaderRec.Validate("Document Type", 1);
        SaleHeaderxRec := SaleHeaderRec;
        SaleHeaderRec.Validate("Sell-to Customer No.", Customer."No.");
        SaleHeaderRec.SelltoCustomerNoOnAfterValidate(SaleHeaderRec, SaleHeaderxRec);
        SaleHeaderRec.Validate("Currency Code", 'EUR');
        SaleHeaderRec.Validate("External Document No.", CustomSaleNo);
        SaleHeaderRec.Insert(true);
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

