page 50260 "Posted Ticket Purchase List"
{
    Editable = false;
    PageType = List;
    SourceTable = "Posted Ticket Purchase";
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
                field("Ticket Price"; Rec."Ticket Price")
                {
                    ApplicationArea = All;
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
}

