table 50070 "Check-In Ledger Entry"
{

    fields
    {
        field(10; "Posted CheckIn No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(20; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(21; "Person Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(22; Name; Text[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(23; Surname; Text[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(30; "Registration No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(70; "Flight No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(80; "Ticket No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(90; "Flight Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(100; "Flight Time"; Time)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(110; "Registration Time"; Time)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(120; "Posted DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(130; Status; Option)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            OptionMembers = "Not Available","In Progress","Checked-In",Missed;
        }
    }

    keys
    {
        key(Key1; "Posted CheckIn No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

