page 50040 "Check-In List"
{
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Check-In";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;

                    // trigger OnLookup(var Text: Text): Boolean
                    // begin
                    //     OpenPage();
                    // end;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field("Flight No."; Rec."Flight No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field("Ticket No."; Rec."Ticket No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field("Flight Date"; Rec."Flight Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field("Flight Time"; Rec."Flight Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field(Surname; Rec.Surname)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field("Personal Code"; Rec."Personal Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field("Registration No."; Rec."Registration No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field("Registration Time"; Rec."Registration Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field("Seat Code"; Rec."Seat Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Color;

                    trigger OnDrillDown()
                    begin
                        OpenPage();
                    end;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
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
        UpdateLogic: Codeunit "Auto Update Logic";
        Color: Text[30];

    local procedure LineColor(): Text[30]
    begin
        if Rec.Status = 0 then
            exit('Standart');

        if Rec.Status = 1 then
            exit('Ambiguous');

        if Rec.Status = 2 then begin
            if CopyStr(Rec."No.", 1, 1) = 'P' then
                exit('Favorable')
            else
                exit('StrongAccent');
        end;

        exit('Unfavorable');
    end;

    local procedure OpenPage()
    var
        PostedCheckIn: Record "Posted Check-In";
    begin
        if CopyStr(Rec."No.", 1, 1) = 'P' then begin
            PostedCheckIn.Get(Rec."No.");
            PAGE.Run(PAGE::"Posted Check-In Form", PostedCheckIn);
        end else
            PAGE.Run(PAGE::"Check-In Form", Rec);
    end;
}

