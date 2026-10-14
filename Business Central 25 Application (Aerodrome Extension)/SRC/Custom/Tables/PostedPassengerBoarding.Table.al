table 50090 "Posted Passenger Boarding"
{

    fields
    {
        field(10; "Posted Boarding No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(20; "Registration No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "Posted Check-In";
        }
        field(21; "Seat Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(30; "Flight No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = Flight;
        }
        field(31; "Flight Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(32; "Flight Time"; Time)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(40; "Ticket No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50; Name; Text[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(60; Surname; Text[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(70; "Personal Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(80; "Is Present"; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(90; "Boarding Time"; Time)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(107; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Posted Boarding No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "Posted Boarding No." = '' then begin
            "No. Series" := 'PBOARD';
            if NoSeries.AreRelated('PBOARD', xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "Posted Boarding No." := NoSeries.GetNextNo("No. Series");
        end;
    end;

    var
        NoSeries: Codeunit "No. Series";
}

