table 50210 "Flight Provider Invoice"
{

    fields
    {
        field(10; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; Customer; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer WHERE(isFlightProvider = CONST(true));

            trigger OnValidate()
            var
                PostedInvoice: Record "Posted Flight Provider Invoice";
                CustomerRec: Record Customer;
            begin
                PostedInvoice.SetRange(Customer, Customer);
                if PostedInvoice.FindLast then
                    "Start Date" := PostedInvoice."End Date" + 1
                else
                    "Start Date" := 0D;

                "End Date" := 0D;
                "Flight Count" := 0;
                "CheckedIn Passenger Count" := 0;
                "Boarded Passenger Count" := 0;
                "Total Price" := 0;

                if CustomerRec.Get(Flight.Customer) then begin
                    "Price For CheckedIn" := CustomerRec."Default Price CheckIn";
                    "Price For Boarded" := CustomerRec."Default Price Boarding";
                end else begin
                    "Price For CheckedIn" := 0;
                    "Price For Boarded" := 0;
                end;
            end;
        }
        field(30; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Start Date" > Today then
                    Error('Start Date cannot be later that today');

                if ("End Date" <> 0D) and ("Start Date" <> 0D) then
                    if ("End Date" - "Start Date") <= 0 then
                        Error('End date cannot be earlier than Start Date');

                if "Start Date" = 0D then begin
                    "Flight Count" := 0;
                    "CheckedIn Passenger Count" := 0;
                    "Boarded Passenger Count" := 0;
                    "Total Price" := 0;
                end else
                    if "End Date" <> 0D then begin
                        CalculateData();
                        if ("Price For CheckedIn" > 0) and ("Price For Boarded" > 0) then
                            "Total Price" := ("CheckedIn Passenger Count" * "Price For CheckedIn") + ("Boarded Passenger Count" * "Price For Boarded");
                    end;
            end;
        }
        field(40; "End Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "End Date" > Today then
                    Error('End Date cannot be later that today');

                if ("End Date" - "Start Date") <= 0 then
                    Error('End date cannot be earlier than Start Date');

                if "End Date" = 0D then begin
                    "Flight Count" := 0;
                    "CheckedIn Passenger Count" := 0;
                    "Boarded Passenger Count" := 0;
                    "Total Price" := 0;
                end else begin
                    CalculateData();
                    if ("Price For CheckedIn" > 0) and ("Price For Boarded" > 0) then
                        "Total Price" := ("CheckedIn Passenger Count" * "Price For CheckedIn") + ("Boarded Passenger Count" * "Price For Boarded");
                end;
            end;
        }
        field(50; "Flight Count"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(60; "CheckedIn Passenger Count"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(70; "Boarded Passenger Count"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(80; "Price For CheckedIn"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Price For CheckedIn" < 0 then
                    Error('Price for One Check-In Customer cannot be negative');

                if ("Price For CheckedIn" >= 0) and ("Price For Boarded" >= 0) then
                    "Total Price" := ("CheckedIn Passenger Count" * "Price For CheckedIn") + ("Boarded Passenger Count" * "Price For Boarded")
                else
                    "Total Price" := 0;
            end;
        }
        field(90; "Price For Boarded"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Price For Boarded" < 0 then
                    Error('Price for One Boarded Customer cannot be negative');

                if ("Price For CheckedIn" >= 0) and ("Price For Boarded" >= 0) then
                    "Total Price" := ("CheckedIn Passenger Count" * "Price For CheckedIn") + ("Boarded Passenger Count" * "Price For Boarded")
                else
                    "Total Price" := 0;
            end;
        }
        field(100; "Total Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(107; "No. Series"; Code[20])
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

    trigger OnInsert()
    var
        //NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeries: Codeunit "No. Series";
    begin
        //if "No." = '' then begin
        //    NoSeriesMgt.InitSeries('I', xRec."No. Series", 0D, "No.", "No. Series");
        //end;

        if "No." = '' then begin
            "No. Series" := 'I';
            if NoSeries.AreRelated('I', xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "No." := NoSeries.GetNextNo("No. Series");
        end;
    end;

    var
        Flight: Record Flight;
        Passenger: Record Passenger;

    local procedure CalculateData()
    begin
        Flight.SetRange(Customer, Customer);
        Flight.SetRange("Flight Date", "Start Date", "End Date");
        Flight.SetRange("Boarding Status", 3);
        "CheckedIn Passenger Count" := 0;
        "Boarded Passenger Count" := 0;
        "Flight Count" := 0;
        if Flight.FindFirst then begin
            repeat
                Passenger.Reset;
                Passenger.SetRange("Flight No.", Flight."Flight No.");
                Passenger.SetRange("Flight Date", Flight."Flight Date");
                Passenger.SetRange("Flight Time", Flight."Departure Time");
                Passenger.SetFilter(Status, '<> 3');
                if Passenger.FindFirst then begin
                    repeat
                        if Passenger.Status = 1 then
                            "CheckedIn Passenger Count" += 1
                        else
                            if Passenger.Status = 2 then
                                "Boarded Passenger Count" += 1;
                    until Passenger.Next = 0;
                end;
                "Flight Count" += 1;
            //MESSAGE('Flight: %1, checked-in: %2, boarded: %3', "Flight Count", "CheckedIn Passenger Count", "Boarded Passenger Count");
            until Flight.Next = 0;
        end;
    end;
}

