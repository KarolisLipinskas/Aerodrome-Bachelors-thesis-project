table 50151 "Ticket Purchase"
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
                    "Ticket Price" := FlightRef.Price;
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
            TableRelation = Flight."Flight Date" WHERE("Flight No." = FIELD("Flight No."));

            trigger OnValidate()
            begin
                Validate("Flight Time", 0T);
            end;
        }
        field(40; "Flight Time"; Time)
        {
            DataClassification = ToBeClassified;
            TableRelation = Flight."Departure Time" WHERE("Flight No." = FIELD("Flight No."),
                                                           "Flight Date" = FIELD("Flight Date"));
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
        field(80; "Ticket Price"; Decimal)
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
    begin
        if "No." = '' then begin
            "No. Series" := 'T-P';
            if NoSeries.AreRelated('T-P', xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "No." := NoSeries.GetNextNo("No. Series");
        end;
    end;

    var
        NoSeries: Codeunit "No. Series";
}

