page 50030 "Flight Page"
{
    PageType = Card;
    SourceTable = Flight;

    layout
    {
        area(content)
        {
            group(General)
            {
                Editable = NOT (isRegistered AND isBoarded);
                field("Flight No."; Rec."Flight No.")
                {
                    ApplicationArea = All;
                    Editable = isEditable;

                    trigger OnValidate()
                    var
                        FlightReference: Record "Flight Reference Table";
                    begin
                        if FlightReference.Get(Rec."Flight No.") then
                            FlightProviderName := FlightReference."Flight Provider Name"
                        else
                            FlightProviderName := '';
                    end;
                }
                field("Flight Date"; Rec."Flight Date")
                {
                    ApplicationArea = All;
                    Editable = isEditable;
                }
                field("Departure Time"; Rec."Departure Time")
                {
                    ApplicationArea = All;
                    Editable = isEditable;
                }
                field("Plane Code"; Rec."Plane Code")
                {
                    ApplicationArea = All;
                    Editable = isEditable;
                    NotBlank = true;

                    trigger OnValidate()
                    begin
                        if Rec."Plane Code" = '' then
                            isPlaneEntered := false
                        else
                            isPlaneEntered := true;
                    end;
                }
                field("Seat Count"; Rec."Seat Count")
                {
                    ApplicationArea = All;
                    Editable = isEditable AND isPlaneEntered AND isSeatCountEditable;
                    NotBlank = true;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Customer; FlightProviderName)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Registration Status"; Rec."Registration Status")
                {
                    ApplicationArea = All;
                    Editable = isManual AND NOT isRegistered;

                    trigger OnValidate()
                    begin
                        if Rec."Registration Status" = 3 then
                            Error('Registration can only be completed through posting');
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
                    end;
                }
            }
            part(Control9; "Passenger List")
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
            action("Edit Seat Count")
            {
                ApplicationArea = All;
                Image = Edit;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    isSeatCountEditable := true;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        FlightProvider: Record Customer;
        Passenger: Record Passenger;
    begin
        if FlightProvider.Get(Rec.Customer) then begin
            FlightProviderName := FlightProvider.Name;
            Passenger.SetRange("Flight No.", Rec."Flight No.");
            Passenger.SetRange("Flight Date", Rec."Flight Date");
            Passenger.SetRange("Flight Time", Rec."Departure Time");
            if Passenger.FindFirst then
                isEditable := false
            else
                isEditable := true;
        end else begin
            FlightProviderName := '';
            isEditable := true;
        end;

        if Rec."Plane Code" = '' then
            isPlaneEntered := false
        else
            isPlaneEntered := true;


        if Rec."Registration Status" = 3 then
            isRegistered := true
        else
            isRegistered := false;

        if Rec."Boarding Status" = 3 then
            isBoarded := true
        else
            isBoarded := false;
    end;

    trigger OnClosePage()
    begin
        AutomationController.SetIsOpenOtherPage(false);
    end;

    trigger OnInit()
    var
        UserController: Codeunit "User Role Controller";
    begin
        if not (UserController.UserHasPermission('FMANAGER') or UserController.UserHasPermission('SUPER')) then
            Error('Access Denied');
    end;

    trigger OnOpenPage()
    begin
        if Rec.IsAutomated then
            isManual := false
        else
            isManual := true;

        isEditable := true;
        isSeatCountEditable := false;

        AutomationController.SetIsOpenOtherPage(true);
    end;

    var
        AutomationController: Codeunit "Automation Controller";
        FlightProviderName: Text[50];
        isManual: Boolean;
        isEditable: Boolean;
        isRegistered: Boolean;
        isBoarded: Boolean;
        isPlaneEntered: Boolean;
        isSeatCountEditable: Boolean;
}

