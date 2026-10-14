page 50080 "Posted Check-In List"
{
    CardPageID = "Posted Check-In Form";
    Editable = false;
    PageType = ListPart;
    SourceTable = "Posted Check-In";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posted CheckIn No."; Rec."Posted CheckIn No.")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field("Flight No."; Rec."Flight No.")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field("Ticket No."; Rec."Ticket No.")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field("Flight Date"; Rec."Flight Date")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field("Flight Time"; Rec."Flight Time")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field(Surname; Rec.Surname)
                {
                    ApplicationArea = All;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field("Personal Code"; Rec."Personal Code")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field("Registration No."; Rec."Registration No.")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field("Registration Time"; Rec."Registration Time")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field("Seat Code"; Rec."Seat Code")
                {
                    ApplicationArea = All;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
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
        CheckInLogic: Codeunit "Auto Update Logic";
        Color: Text[30];

    local procedure LineColor(): Text[30]
    begin
        if Rec.Status = 0 then
            exit('Standart');

        if Rec.Status = 1 then
            exit('Ambiguous');

        if Rec.Status = 2 then
            exit('Favorable');

        exit('Unfavorable');
    end;

    local procedure OpenPage()
    var
        PostedCheckIn: Record "Posted Check-In";
    begin
        if CopyStr(Rec."Posted CheckIn No.", 1, 1) = 'P' then begin
            PostedCheckIn.Get(Rec."Posted CheckIn No.");
            PAGE.Run(PAGE::"Posted Check-In Form", PostedCheckIn);
        end else
            PAGE.Run(PAGE::"Check-In Form", Rec);
    end;
}

