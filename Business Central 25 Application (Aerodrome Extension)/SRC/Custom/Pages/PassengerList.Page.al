page 50170 "Passenger List"
{
    Editable = false;
    PageType = ListPart;
    SourceTable = Passenger;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Ticket No."; Rec."Ticket No.")
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
                field("Registration No."; Rec."Registration No.")
                {
                    ApplicationArea = All;
                }
                field("Seat Code"; Rec."Seat Code")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
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
        if Rec.Status = 0 then
            Color := 'Standart'
        else
            if Rec.Status = 1 then
                Color := 'StrongAccent'
            else
                if Rec.Status = 2 then
                    Color := 'Favorable'
                else
                    Color := 'Unfavorable';
    end;

    var
        Color: Text[30];
}

