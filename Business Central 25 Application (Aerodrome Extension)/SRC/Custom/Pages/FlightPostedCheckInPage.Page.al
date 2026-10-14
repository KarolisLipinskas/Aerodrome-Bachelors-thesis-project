page 50070 "Flight Posted Check-In Page"
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
                    Editable = false;
                }
                field("Flight Date"; Rec."Flight Date")
                {
                    ApplicationArea = All;
                    Editable = false;
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
            part(Control13; "Posted Check-In List")
            {
                ApplicationArea = All;
                Editable = false;
                SubPageLink = "Flight No." = FIELD("Flight No."),
                              "Flight Date" = FIELD("Flight Date"),
                              "Flight Time" = FIELD("Departure Time");
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
                Caption = 'Post Flight Check-In';
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Message('Testing Action');
                    PostController.PostAllCheckIns(Rec);
                end;
            }
        }
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
        PostController: Codeunit "Check-In Posting";
        FlightProviderName: Text[50];
}

