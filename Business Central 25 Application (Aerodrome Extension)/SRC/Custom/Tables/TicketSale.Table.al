table 50150 "Ticket Sale"
{

    fields
    {
        field(10; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Flight No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Flight Reference Table";

            trigger OnValidate()
            var
                FlightRef: Record "Flight Reference Table";
            begin
                if FlightRef.Get("Flight No.") then begin
                    Vendor := FlightRef.FlightProviderVend;
                    "Vendor Name" := FlightRef."Flight Provider Name";
                    "Ticket Price" := FlightRef.Price * (1 + FlightRef."Commision Percentage");
                end else begin
                    Vendor := '';
                    "Vendor Name" := '';
                    "Ticket Price" := 0;
                end;

                Validate("Flight Date", 0D);
            end;
        }
        field(30; "Flight Date"; Date)
        {
            DataClassification = ToBeClassified;
            TableRelation = Flight."Flight Date" WHERE("Flight No." = FIELD("Flight No."),
                                                        "Registration Status" = CONST("Not Available"),
                                                        "Boarding Status" = CONST("Not Available"));

            trigger OnValidate()
            begin
                Validate("Flight Time", 0T);
            end;
        }
        field(40; "Flight Time"; Time)
        {
            DataClassification = ToBeClassified;
            TableRelation = Flight."Departure Time" WHERE("Flight No." = FIELD("Flight No."),
                                                           "Flight Date" = FIELD("Flight Date"),
                                                           "Registration Status" = CONST("Not Available"),
                                                           "Boarding Status" = CONST("Not Available"));

            trigger OnValidate()
            var
                TicketGen: Record "Flight Ticket Generator";
                Passenger: Record Passenger;
                Flight: Record Flight;
            begin
                Passenger.SetRange("Flight No.", "Flight No.");
                Passenger.SetRange("Flight Date", "Flight Date");
                Passenger.SetRange("Flight Time", "Flight Time");
                if Flight.Get("Flight Date", "Flight Time", "Flight No.") then begin
                    if Passenger.Count >= Flight."Seat Count" then
                        Error('This Flight is fully booked');
                end;

                "Ticket No." := GenerateTicketNo("Flight No.", "Flight Date", "Flight Time");
            end;
        }
        field(50; "Ticket No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(60; Vendor; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor WHERE(isFlightProvider = CONST(true));
        }
        field(70; "Vendor Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(80; Customer; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer WHERE(isPerson = CONST(true));
        }
        field(90; "Person Code"; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                CustomerTable: Record Customer;
            begin
                if "Person Code" <> '' then begin
                    CustomerTable.SetRange(isPerson, true);
                    CustomerTable.SetRange("Person Code", "Person Code");
                    if CustomerTable.FindFirst then begin
                        Customer := CustomerTable."No.";
                        if Name = '' then
                            Name := CustomerTable.Name;

                        if Surname = '' then
                            Surname := CustomerTable.Surname;
                    end;
                end;
            end;
        }
        field(100; Name; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(107; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(110; Surname; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(130; "Ticket Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(140; TicketPurchNo; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TicketPurchase.Get(TicketPurchNo);
        TicketPurchase.Delete;
    end;

    trigger OnInsert()
    begin
        if "No." = '' then begin
            "No. Series" := 'T-S';
            if NoSeries.AreRelated('T-S', xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "No." := NoSeries.GetNextNo("No. Series");
        end;

        TicketPurchase.Init;
        TicketPurchase.Insert(true);
        TicketPurchNo := TicketPurchase."No.";
    end;

    trigger OnModify()
    var
        CustomerTable: Record Customer;
    begin
        if ("Person Code" <> '') and (Name <> '') and (Surname <> '') then begin
            if Customer <> '' then begin
                CustomerTable.Get(Customer);
                if CustomerTable.Name <> Name then begin
                    CustomerTable.Validate(Name, Name);
                    CustomerTable.Modify(true);
                end;

                if CustomerTable.Surname <> Surname then begin
                    CustomerTable.Validate(Surname, Surname);
                    CustomerTable.Modify(true);
                end;

            end else begin
                CustomerTable.Init;
                CustomerTable.isPerson := true;
                CustomerTable.Validate("Person Code", "Person Code");
                CustomerTable.Validate(Name, Name);
                CustomerTable.Validate(Surname, Surname);
                CustomerTable.Validate("Customer Posting Group", 'EU');
                CustomerTable.Validate("Gen. Bus. Posting Group", 'EU');
                CustomerTable.Validate("Currency Code", 'EUR');
                CustomerTable.Insert(true);

                Customer := CustomerTable."No.";
            end;
        end;

        TicketPurchase.Get(TicketPurchNo);
        TicketPurchase.Validate("Flight No.", "Flight No.");
        TicketPurchase.Validate("Flight Date", "Flight Date");
        TicketPurchase."Flight Time" := "Flight Time";
        TicketPurchase."Ticket No." := "Ticket No.";
        TicketPurchase.Modify;
    end;

    var
        NoSeries: Codeunit "No. Series";
        TicketPurchase: Record "Ticket Purchase";

    local procedure GenerateTicketNo(FlightNo: Code[20]; FlightDate: Date; FlightTime: Time): Code[20]
    var
        TicketGen: Record "Flight Ticket Generator";
        Passenger: Record Passenger;
        TicketNo: Code[20];
        State: Boolean;
    begin
        if TicketGen.Get(FlightNo, FlightDate, FlightTime) then begin
            State := false;
            repeat
                if TicketGen."Current No." > TicketGen."End No." then
                    Error('This flight is fully booked');
                TicketNo := TicketGen.PrefixLetter + PadLeft(Format(TicketGen."Current No."), 7);
                //MESSAGE('Ticket: %1',TicketNo);
                Passenger.SetRange("Flight No.", FlightNo);
                Passenger.SetRange("Ticket No.", TicketNo);
                if Passenger.FindFirst then begin
                    TicketGen."Current No." += 1;
                    TicketGen.Modify;
                end else
                    State := true;
            until State;
            exit(TicketNo);
        end else
            exit('');
    end;

    local procedure PadLeft(Number: Text[10]; Length: Integer): Text[10]
    var
        PaddingLength: Integer;
    begin
        PaddingLength := Length - StrLen(Number);
        if PaddingLength > 0 then
            exit(PadStr('', PaddingLength, '0') + Number);

        exit(Number);
    end;
}

