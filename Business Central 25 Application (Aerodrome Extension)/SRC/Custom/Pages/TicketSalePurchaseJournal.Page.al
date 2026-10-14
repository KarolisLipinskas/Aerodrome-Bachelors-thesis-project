page 50270 "Ticket Sale/Purchase Journal"
{
    PageType = List;
    SourceTable = "Ticket Sale/Purch Journal Line";
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
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
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
                }
                field(Vendor; Rec.Vendor)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Code';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                }
                field(Customer; Rec.Customer)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Code';
                }
                field("Personal Code"; Rec."Personal Code")
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
                field("Ticket Price"; Rec."Ticket Price")
                {
                    ApplicationArea = All;
                }
                field("Posting DateTime"; Rec."Posting DateTime")
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
            action(Post)
            {
                ApplicationArea = All;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    PostController: Codeunit "Ticket Sale/Purchase Posting";
                begin
                    PostController.CheckJournalData();
                    PostController.JournalToLedger();
                end;
            }
        }
    }

    trigger OnClosePage()
    var
        JournalLine: Record "Ticket Sale/Purch Journal Line";
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

