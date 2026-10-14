page 50130 "Boarding List"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Passenger Boarding";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Boarding No."; Rec."Boarding No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;
                }
                field("Registration No."; Rec."Registration No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;
                }
                field("Seat Code"; Rec."Seat Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;
                }
                field("Flight No."; Rec."Flight No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;
                }
                field("Flight Date"; Rec."Flight Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;
                }
                field("Flight Time"; Rec."Flight Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;
                }
                field("Ticket No."; Rec."Ticket No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;
                }
                field("Personal Code"; Rec."Personal Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;
                }
                field(Surname; Rec.Surname)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;
                }
                field("Is Present"; Rec."Is Present")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;

                    trigger OnValidate()
                    begin
                        Color := LineColor();
                    end;
                }
                field("Boarding Time"; Rec."Boarding Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;
                }
                field("Is API Call"; Rec."Is API Call")
                {
                    ApplicationArea = ALL;
                    Visible = false;
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

