table 50200 "Seat Table"
{

    fields
    {
        field(10; "Flight No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Flight Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Flight Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(40; "Seat Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50; Available; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Flight No.", "Flight Date", "Flight Time", "Seat Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Seat Code")
        {
        }
    }
}

