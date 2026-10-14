table 50040 "Posted Check-In"
{

    fields
    {
        field(10; "Posted CheckIn No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(20; "Registration No."; Code[20])
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
        field(40; "Ticket No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50; "Flight Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(55; "Flight Time"; Time)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(60; "Registration Time"; Time)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(70; Name; Text[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(80; Surname; Text[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(90; "Personal Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(100; "Seat Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(107; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(130; Status; Option)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            OptionMembers = "Not Available","In Progress","Checked-In",Missed;
        }
        field(150; SalesHeaderDocType; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(151; SalesHeaderNo; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(152; SalesHeaderLastPostingNo; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Posted CheckIn No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "Posted CheckIn No." = '' then begin
            "No. Series" := 'PREG';
            if NoSeries.AreRelated('PREG', xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "Posted CheckIn No." := NoSeries.GetNextNo("No. Series");
        end;
    end;

    var
        NoSeries: Codeunit "No. Series";
}

