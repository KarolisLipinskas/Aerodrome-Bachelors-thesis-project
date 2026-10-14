table 50000 "Flight"
{

    fields
    {
        field(10; "Flight No."; Code[20])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
            TableRelation = "Flight Reference Table";

            trigger OnValidate()
            var
                FlightProvider: Record Customer;
                FlightReference: Record "Flight Reference Table";
            begin
                if FlightReference.Get("Flight No.") then begin
                    Customer := FlightReference.FlightProviderCust;
                    Description := FlightReference.Description;
                end;
            end;
        }
        field(20; "Flight Date"; Date)
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(30; "Departure Time"; Time)
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(40; "Plane Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Plane;

            trigger OnValidate()
            var
                Plane: Record Plane;
            begin
                if Plane.Get("Plane Code") then
                    "Seat Count" := Plane."Seat Count"
                else
                    "Seat Count" := 0;
            end;
        }
        field(50; "Seat Count"; Integer)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                Plane: Record Plane;
            begin
                if Plane.Get("Plane Code") then begin
                    if "Seat Count" > Plane."Seat Count" then
                        Error('Maximum seats in this plane are: %1', Plane."Seat Count");

                    if "Seat Count" < 0 then
                        Error('Seat Count cannot be negative');

                    if "Seat Count" = 0 then
                        Error('Seat Count cannot be 0');
                end;
            end;
        }
        field(60; Description; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(70; Customer; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer WHERE(isFlightProvider = CONST(true));
        }
        field(80; "Registration Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Not Available","In Progress","Awaiting Completion",Completed;
        }
        field(90; "Boarding Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Not Available","In Progress","Awaiting Completion",Completed;
        }
        field(100; IsAutomated; Boolean)
        {
            DataClassification = ToBeClassified;
            InitValue = true;
        }
    }

    keys
    {
        key(Key1; "Flight Date", "Departure Time", "Flight No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        Passenger: Record Passenger;
        GeneratorTable: Record "Flight Ticket Generator";
        SeatTable: Record "Seat Table";
        UserController: Codeunit "User Role Controller";
    begin
        if not (UserController.UserHasPermission('FMANAGER') or UserController.UserHasPermission('SUPER')) then
            Error('Access Denied');

        Passenger.SetRange("Flight No.", "Flight No.");
        Passenger.SetRange("Flight Date", "Flight Date");
        Passenger.SetRange("Flight Time", "Departure Time");
        if Passenger.FindFirst then
            Error('cannot delete flghts with passengers');

        if GeneratorTable.Get("Flight No.", "Flight Date", "Departure Time") then
            GeneratorTable.Delete(true);

        SeatTable.SetRange("Flight No.", "Flight No.");
        SeatTable.SetRange("Flight Date", "Flight Date");
        SeatTable.SetRange("Flight Time", "Departure Time");
        SeatTable.DeleteAll(true);
    end;

    trigger OnInsert()
    var
        Letter: Text[1];
    begin
        if CheckMandatoryFields() then begin
            InsertToTicketGen();
            InsertSeats();
        end;
    end;

    trigger OnModify()
    var
        Letter: Text[1];
    begin
        if CheckMandatoryFields() then begin
            InsertToTicketGen();
            InsertSeats();
        end;
    end;

    local procedure CheckMandatoryFields(): Boolean
    begin
        if "Flight No." = '' then
            exit(false);

        if "Flight Date" = 0D then
            exit(false);

        if "Departure Time" = 0T then
            exit(false);

        if "Plane Code" = '' then
            exit(false);

        if "Seat Count" = 0 then
            exit(false);

        if Customer = '' then
            exit(false);

        exit(true);
    end;

    local procedure InsertToTicketGen()
    var
        GeneratorTable: Record "Flight Ticket Generator";
    begin
        //Generated tickets for flight
        if GeneratorTable.Get("Flight No.", "Flight Date", "Departure Time") then
            exit;

        GeneratorTable.Init;
        GeneratorTable."Flight No." := "Flight No.";
        GeneratorTable."Flight Date" := "Flight Date";
        GeneratorTable."Flight Time" := "Departure Time";
        GeneratorTable.Customer := Customer;
        GeneratorTable."Seat Count" := "Seat Count";
        GeneratorTable.Insert(true);
    end;

    local procedure InsertSeats()
    var
        SeatTable: Record "Seat Table";
        Index: Integer;
    begin
        SeatTable.SetRange("Flight No.", "Flight No.");
        SeatTable.SetRange("Flight Date", "Flight Date");
        SeatTable.SetRange("Flight Time", "Departure Time");
        if SeatTable.FindFirst then
            exit;

        Index := 0;
        repeat
            Index += 1;
            SeatTable.Init;
            SeatTable."Flight No." := "Flight No.";
            SeatTable."Flight Date" := "Flight Date";
            SeatTable."Flight Time" := "Departure Time";
            SeatTable."Seat Code" := Format(Index) + CopyStr("Plane Code", 1, 1);
            SeatTable.Available := true;
            SeatTable.Insert(true);
        until Index = "Seat Count";
    end;
}

