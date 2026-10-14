page 50010 "Flight Check-In Page"
{
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
                    Editable = false;
                }
                field("Plane Code"; Rec."Plane Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Seat Count"; Rec."Seat Count")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(FlightProviderName; FlightProviderName)
                {
                    ApplicationArea = All;
                    Caption = 'Customer';
                    Editable = false;
                }
                field("Registration Status"; Rec."Registration Status")
                {
                    ApplicationArea = All;
                    Editable = isManual;

                    trigger OnValidate()
                    var
                        CheckIn: Record "Check-In";
                        Value: Integer;
                    begin
                        if Rec."Registration Status" = 3 then
                            Error('Registration can only be completed by posting');

                        CheckIn.SetRange("Flight No.", Rec."Flight No.");
                        CheckIn.SetRange("Flight Date", Rec."Flight Date");
                        CheckIn.SetRange("Flight Time", Rec."Departure Time");
                        CheckIn.SetFilter(Status, '<> 2');

                        if Rec."Registration Status" = 2 then
                            Value := 3
                        else
                            Value := Rec."Registration Status";

                        CheckIn.ModifyAll(Status, Value);
                    end;
                }
                field("Boarding Status"; Rec."Boarding Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(IsAutomated; Rec.IsAutomated)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if Rec.IsAutomated then
                            isManual := false
                        else
                            isManual := true;

                        Rec.Modify;
                    end;
                }
            }
            part(Control13; "Check-In List")
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
                    if PostController.PostAllCheckIns(Rec) then
                        CurrPage.Close;
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

    trigger OnClosePage()
    begin
        AutomationController.SetIsOpenOtherPage(false);
        AutomationController.SetIsOpenCheckInPage(false);
    end;

    trigger OnOpenPage()
    begin
        if Rec.IsAutomated then
            isManual := false
        else
            isManual := true;

        AutomationController.SetIsOpenOtherPage(true);
        AutomationController.SetIsOpenCheckInPage(true);
    end;

    var
        PostController: Codeunit "Check-In Posting";
        isManual: Boolean;
        AutomationController: Codeunit "Automation Controller";
        FlightProviderName: Text[50];
}

