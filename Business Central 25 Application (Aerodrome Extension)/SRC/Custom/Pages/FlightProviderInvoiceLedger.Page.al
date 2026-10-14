page 50300 "Flight Prov. Invoice Ledger"
{
    Editable = false;
    PageType = List;
    SourceTable = "Flight Prov. Inv. Ledger Entry";
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posted No."; Rec."Posted No.")
                {
                    ApplicationArea = All;

                    // trigger OnLookup(var Text: Text): Boolean
                    // begin
                    //     OpenInvoice();
                    // end;

                    trigger OnDrillDown()
                    begin
                        OpenInvoice();
                    end;
                }
                field(Customer; Rec.Customer)
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        OpenInvoice();
                    end;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        OpenInvoice();
                    end;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        OpenInvoice();
                    end;
                }
                field("Flight Count"; Rec."Flight Count")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        OpenInvoice();
                    end;
                }
                field("CheckedIn Passenger Count"; Rec."CheckedIn Passenger Count")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        OpenInvoice();
                    end;
                }
                field("Boarded Passenger Count"; Rec."Boarded Passenger Count")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        OpenInvoice();
                    end;
                }
                field("Price For CheckedIn"; Rec."Price For CheckedIn")
                {
                    ApplicationArea = All;
                    Caption = 'Price For CheckedIn, €';

                    trigger OnDrillDown()
                    begin
                        OpenInvoice();
                    end;
                }
                field("Price For Boarded"; Rec."Price For Boarded")
                {
                    ApplicationArea = All;
                    Caption = 'Price For Boarded, €';

                    trigger OnDrillDown()
                    begin
                        OpenInvoice();
                    end;
                }
                field("Total Price"; Rec."Total Price")
                {
                    ApplicationArea = All;
                    Caption = 'Total Price, €';

                    trigger OnDrillDown()
                    begin
                        OpenInvoice();
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    var
        UserController: Codeunit "User Role Controller";
    begin
        IF NOT (UserController.UserHasPermission('FMANAGER') OR UserController.UserHasPermission('SUPER')) THEN
            ERROR('Access Denied');
    end;

    local procedure OpenInvoice()
    var
        PostedInvoice: Record "Posted Flight Provider Invoice";
    begin
        PostedInvoice.GET(Rec."Posted No.");
        PAGE.RUN(PAGE::"Posted Flight Provider Invoice", PostedInvoice);
    end;
}

