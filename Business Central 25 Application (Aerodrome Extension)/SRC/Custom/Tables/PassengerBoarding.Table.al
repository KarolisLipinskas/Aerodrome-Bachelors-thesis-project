table 50080 "Passenger Boarding"
{

    fields
    {
        field(10; "Boarding No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Registration No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Posted Check-In";
        }
        field(21; "Seat Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Flight No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Flight;
        }
        field(31; "Flight Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(32; "Flight Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(40; "Ticket No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50; Name; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(60; Surname; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(70; "Personal Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(80; "Is Present"; Boolean)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Is Present" <> xRec."Is Present" then begin
                    if "Is Present" then begin
                        if "Is API Call" then
                            "Boarding Time" := DT2Time(CurrentDateTime() + 3 * 3600000)
                        else
                            "Boarding Time" := Time()
                    end else begin
                        "Boarding Time" := 0T;
                        "Is API Call" := false;
                    end;
                end;
            end;
        }
        field(90; "Boarding Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(100; "Is API Call"; Boolean)
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
        key(Key1; "Boarding No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "Boarding No." = '' then begin
            "No. Series" := 'BOARD';
            if NoSeries.AreRelated('BOARD', xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "Boarding No." := NoSeries.GetNextNo("No. Series");
        end;
    end;

    var
        NoSeries: Codeunit "No. Series";
}

