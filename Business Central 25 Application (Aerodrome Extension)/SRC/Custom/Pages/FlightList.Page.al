page 50000 "Flight List"
{
    CardPageID = "Flight Page";
    PageType = List;
    SourceTable = Flight;
    SourceTableView = order(descending);
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field("Flight No."; Rec."Flight No.")
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field("Flight Date"; Rec."Flight Date")
                {
                    ApplicationArea = All;
                }
                field("Departure Time"; Rec."Departure Time")
                {
                    ApplicationArea = All;
                }
                field("Plane Code"; Rec."Plane Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Seat Count"; Rec."Seat Count")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(FlightProviderName; FlightProviderName)
                {
                    ApplicationArea = All;
                    Caption = 'Customer';
                }
                field("Registration Status"; Rec."Registration Status")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;
                }
                field("Boarding Status"; Rec."Boarding Status")
                {
                    ApplicationArea = All;
                    StyleExpr = BoardColor;
                }
                field(IsAutomated; Rec.IsAutomated)
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
            action("View Check-In")
            {
                ApplicationArea = All;
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunPageOnRec = true;
                Visible = isAgent OR isSuper;

                trigger OnAction()
                begin
                    IF Rec."Registration Status" < 3 THEN
                        PAGE.RUN(PAGE::"Flight Check-In Page", Rec)
                    ELSE
                        PAGE.RUN(PAGE::"Flight Posted Check-In Page", Rec);
                end;
            }
            action("View Boarding")
            {
                ApplicationArea = All;
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunPageOnRec = true;
                Visible = isAgent OR isSuper;

                trigger OnAction()
                begin
                    IF Rec."Boarding Status" < 3 THEN
                        PAGE.RUN(PAGE::"Flight Boarding Page", Rec)
                    ELSE
                        PAGE.RUN(PAGE::"Flight Posted Boarding Page", Rec);
                end;
            }
            action("Sell New Ticket")
            {
                ApplicationArea = All;
                Image = SetupPayment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = isManager OR isSuper;

                trigger OnAction()
                var
                    TicketSaleRec: Record "Ticket Sale";
                begin
                    TicketSaleRec.INIT;
                    TicketSaleRec.INSERT(TRUE);
                    PAGE.RUN(PAGE::"Ticket Sale Form", TicketSaleRec);
                end;
            }
            action("Sell Ticket for Selected Flight")
            {
                ApplicationArea = All;
                Image = Payment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunPageOnRec = true;
                Visible = isManager OR isSuper;

                trigger OnAction()
                var
                    TicketSaleRec: Record "Ticket Sale";
                begin
                    IF Rec."Registration Status" > 0 THEN
                        ERROR('Flight Registration Status needs to be Not Available');

                    TicketSaleRec.INIT;
                    TicketSaleRec.VALIDATE("Flight No.", Rec."Flight No.");
                    TicketSaleRec.VALIDATE("Flight Date", Rec."Flight Date");
                    TicketSaleRec.VALIDATE("Flight Time", Rec."Departure Time");
                    TicketSaleRec.INSERT(TRUE);
                    PAGE.RUN(PAGE::"Ticket Sale Form", TicketSaleRec);
                end;
            }
            action("New Flight Provider")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = true;
                Visible = isManager OR isSuper;

                trigger OnAction()
                var
                    Customer: Record Customer;
                begin
                    Customer.INIT;
                    Customer.isFlightProvider := TRUE;
                    Customer.INSERT(TRUE);
                    PAGE.RUN(PAGE::"New Flight Provider", Customer);
                end;
            }
            action("Edit Flight Provider")
            {
                ApplicationArea = All;
                Image = EditCustomer;
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = true;
                Visible = isManager OR isSuper;

                trigger OnAction()
                var
                    CustomerRec: Record Customer;
                begin
                    PAGE.RUN(PAGE::"Edit Flight Provider");
                end;
            }
            action("Generate Invoice")
            {
                ApplicationArea = All;
                Image = Invoice;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                Visible = isManager OR isSuper;

                trigger OnAction()
                var
                    FlightProviderInvoice: Record "Flight Provider Invoice";
                begin
                    FlightProviderInvoice.INIT;
                    FlightProviderInvoice.INSERT(TRUE);
                    PAGE.RUN(PAGE::"New Flight Provider Invoice", FlightProviderInvoice);
                end;
            }
            action("Flight Reference List")
            {
                ApplicationArea = All;
                Image = ListPage;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = isManager OR isSuper;

                trigger OnAction()
                begin
                    PAGE.RUN(PAGE::"Flight Reference List");
                end;
            }
            action("Refresh List")
            {
                ApplicationArea = All;
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = isAgent or isManager OR isSuper;
                trigger OnAction()
                begin
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        FlightProvider: Record Customer;
    begin
        Color := RegistrationColor();
        BoardColor := BoardingColor();

        IF FlightProvider.GET(Rec.Customer) THEN
            FlightProviderName := FlightProvider.Name
        ELSE
            FlightProviderName := '';
    end;

    trigger OnOpenPage()
    var
        UserController: Codeunit "User Role Controller";
    begin
        isManager := UserController.UserHasPermission('FMANAGER');
        isAgent := UserController.UserHasPermission('FAGENT');
        isSuper := UserController.UserHasPermission('SUPER');
    end;

    var
        Color: Text[30];
        BoardColor: Text[30];
        FlightProviderName: Text[50];
        isAgent: Boolean;
        isManager: Boolean;
        isSuper: Boolean;

    local procedure RegistrationColor(): Text[30]
    begin
        IF Rec."Registration Status" = 0 THEN
            EXIT('Standart');

        IF Rec."Registration Status" = 1 THEN
            EXIT('Ambiguous');

        IF Rec."Registration Status" = 2 THEN
            EXIT('StrongAccent');

        IF Rec."Registration Status" = 3 THEN
            EXIT('Favorable');
    end;

    local procedure BoardingColor(): Text[30]
    begin
        IF Rec."Boarding Status" = 0 THEN
            EXIT('Standart');

        IF Rec."Boarding Status" = 1 THEN
            EXIT('Ambiguous');

        IF Rec."Boarding Status" = 2 THEN
            EXIT('StrongAccent');

        IF Rec."Boarding Status" = 3 THEN
            EXIT('Favorable');
    end;
}

