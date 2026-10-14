page 50140 "Flight Posted Boarding Page"
{
    Editable = false;
    PageType = Card;
    SourceTable = Flight;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Flight No."; Rec."Flight No.")
                {
                    ApplicationArea = All;
                }
                field("Flight Date"; Rec."Flight Date")
                {
                    ApplicationArea = All;
                }
                field("Departure Time"; Rec."Departure Time")
                {
                    ApplicationArea = All;
                }
                field("Plane Code"; Rec."Plane Code")
                {
                    ApplicationArea = All;
                }
                field("Seat Count"; Rec."Seat Count")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(FlightProviderName; FlightProviderName)
                {
                    ApplicationArea = All;
                    Caption = 'Customer';
                }
                field("Registration Status"; Rec."Registration Status")
                {
                    ApplicationArea = All;
                }
                field("Boarding Status"; Rec."Boarding Status")
                {
                    ApplicationArea = All;
                }
                field(IsAutomated; Rec.IsAutomated)
                {
                    ApplicationArea = All;
                }
            }
            part(Control13; "Posted Boarding List")
            {
                ApplicationArea = All;
                SubPageLink = "Flight No." = FIELD("Flight No."),
                              "Flight Date" = FIELD("Flight Date"),
                              "Flight Time" = FIELD("Departure Time");
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        FlightProvider: Record Customer;
    begin
        if FlightProvider.Get(Rec.Customer) then
            FlightProviderName := FlightProvider.Name
        else
            FlightProviderName := '';
    end;

    var
        FlightProviderName: Text[50];
}

