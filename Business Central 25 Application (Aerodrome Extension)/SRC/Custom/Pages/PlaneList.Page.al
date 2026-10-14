page 50190 "Plane List"
{
    PageType = List;
    SourceTable = Plane;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Plane Code"; Rec."Plane Code")
                {
                    ApplicationArea = All;
                }
                field("Seat Count"; Rec."Seat Count")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

