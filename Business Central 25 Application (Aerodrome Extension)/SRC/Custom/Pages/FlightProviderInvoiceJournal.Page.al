page 50290 "Flight Prov. Invoice Journal"
{
    PageType = List;
    SourceTable = "Flight Prov. Inv. Journal Line";
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
                }
                field(Customer; Rec.Customer)
                {
                    ApplicationArea = All;
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
                    Caption = 'Price For CheckedIn, €';
                }
                field("Price For Boarded"; Rec."Price For Boarded")
                {
                    ApplicationArea = All;
                    Caption = 'Price For Boarded, €';
                }
                field("Total Price"; Rec."Total Price")
                {
                    ApplicationArea = All;
                    Caption = 'Total Price, €';
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
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    PostController: Codeunit "Flight Prov. Invoice Posting";
                begin
                    PostController.CheckJournalData();
                    PostController.JournalToLedger();
                end;
            }
        }
    }

    trigger OnClosePage()
    var
        JournalLine: Record "Flight Prov. Inv. Journal Line";
    begin
        JournalLine.DELETEALL;
    end;

    trigger OnInit()
    var
        UserController: Codeunit "User Role Controller";
    begin
        IF NOT (UserController.UserHasPermission('FMANAGER') OR UserController.UserHasPermission('SUPER')) THEN
            ERROR('Access Denied');
    end;
}

