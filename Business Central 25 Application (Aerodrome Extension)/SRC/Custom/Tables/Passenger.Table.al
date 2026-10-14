table 50010 "Passenger"
{

    fields
    {
        field(10; "Flight No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Flight."Flight No." WHERE("Flight No." = FIELD("Flight No."));
        }
        field(20; "Flight Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Flight Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Ticket No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(40; "Personal Code"; Code[20])
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
        field(70; "Registration No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(80; "Seat Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(95; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Not Available","Checked-In",Boarded,Missing;
        }
    }

    keys
    {
        key(Key1; "Flight No.", "Flight Date", "Flight Time", "Ticket No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

