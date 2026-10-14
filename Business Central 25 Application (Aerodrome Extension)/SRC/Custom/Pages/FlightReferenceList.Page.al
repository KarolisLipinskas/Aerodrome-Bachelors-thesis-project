page 50180 "Flight Reference List"
{
    PageType = List;
    SourceTable = "Flight Reference Table";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(FlightProviderCust; Rec.FlightProviderCust)
                {
                    ApplicationArea = All;
                }
                field("Flight No."; Rec."Flight No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Flight Provider Name"; Rec."Flight Provider Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Flight Provider Code"; Rec."Flight Provider Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Price; Rec.Price)
                {
                    ApplicationArea = All;
                    Caption = 'Ticket Price from Vendor, €';
                }
                field("Commision Percentage"; Rec."Commision Percentage")
                {
                    ApplicationArea = All;
                    Caption = 'Added percentage to ticket price';
                    DecimalPlaces = 1 : 2;
                }
            }
        }
    }

    actions
    {
    }
}

