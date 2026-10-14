page 50020 "Flight Boarding Page"
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
                    Editable = false;
                }
                field("Boarding Status"; Rec."Boarding Status")
                {
                    ApplicationArea = All;
                    Editable = isManual AND isEditable;

                    trigger OnValidate()
                    begin
                        if Rec."Boarding Status" = 3 then
                            Error('Passenger Boarding can only be completed by posting');

                        if (Rec."Boarding Status" = 1) or (Rec."Boarding Status" = 2) then
                            isEditableList := true
                        else
                            isEditableList := false;
                    end;
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
                    end;
                }
            }
            part(BoardingList; "Boarding List")
            {
                ApplicationArea = All;
                Editable = isEditableList;
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
            action("Post Boarding")
            {
                ApplicationArea = All;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if Rec."Boarding Status" <> 2 then
                        Error('Boarding status needs to be: Awaiting Completion');

                    if PostController.PostBoarding(Rec) then
                        CurrPage.Close;
                end;
            }
            action("Mark Passenger as Boarded")
            {
                ApplicationArea = All;
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = isEditableList;

                trigger OnAction()
                var
                    Boarding: Record "Passenger Boarding";
                begin
                    CurrPage.BoardingList.PAGE.GetRecord(Boarding);
                    if Boarding."Boarding No." = '' then
                        Error('No passenger is selected');

                    if Boarding."Is Present" then
                        exit;

                    Boarding."Is Present" := true;
                    Boarding."Boarding Time" := Time;
                    Boarding.Modify;

                    Message('Passenger marked as Boarded');
                end;
            }
            action("Mark Passenger as Not Boarded")
            {
                ApplicationArea = All;
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = isEditableList;

                trigger OnAction()
                var
                    Boarding: Record "Passenger Boarding";
                begin
                    CurrPage.BoardingList.PAGE.GetRecord(Boarding);
                    if Boarding."Boarding No." = '' then
                        Error('No passenger is selected');

                    if not Boarding."Is Present" then
                        exit;

                    Boarding."Is Present" := false;
                    Boarding."Boarding Time" := 0T;
                    Boarding.Modify;

                    Message('Passenger marked as NOT Boarded');
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
    end;

    trigger OnOpenPage()
    begin
        if Rec.IsAutomated then
            isManual := false
        else
            isManual := true;

        if Rec."Registration Status" <> 3 then
            isEditable := false
        else
            isEditable := true;

        if (Rec."Boarding Status" = 1) or (Rec."Boarding Status" = 2) then
            isEditableList := true
        else
            isEditableList := false;

        AutomationController.SetIsOpenOtherPage(true);
    end;

    var
        isEditableList: Boolean;
        isEditable: Boolean;
        isManual: Boolean;
        AutomationController: Codeunit "Automation Controller";
        PostController: Codeunit "Boarding Posting";
        FlightProviderName: Text[50];
}

