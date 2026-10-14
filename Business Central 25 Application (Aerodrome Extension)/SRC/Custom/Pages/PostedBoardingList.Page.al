page 50150 "Posted Boarding List"
{
    Editable = false;
    PageType = ListPart;
    SourceTable = "Posted Passenger Boarding";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posted Boarding No."; Rec."Posted Boarding No.")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;
                }
                field("Registration No."; Rec."Registration No.")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;
                }
                field("Seat Code"; Rec."Seat Code")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;
                }
                field("Flight No."; Rec."Flight No.")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;
                }
                field("Flight Date"; Rec."Flight Date")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;
                }
                field("Flight Time"; Rec."Flight Time")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;
                }
                field("Ticket No."; Rec."Ticket No.")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;
                }
                field("Personal Code"; Rec."Personal Code")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    StyleExpr = Color;
                }
                field(Surname; Rec.Surname)
                {
                    ApplicationArea = All;
                    StyleExpr = Color;
                }
                field("Is Present"; Rec."Is Present")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;
                }
                field("Boarding Time"; Rec."Boarding Time")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        Color := LineColor();
    end;

    var
        Color: Text[30];

    local procedure LineColor(): Text[30]
    begin
        if Rec."Is Present" then
            exit('Favorable');

        exit('Unfavorable');
    end;
}

