table 50140 "Plane"
{
    LookupPageID = "Plane List";

    fields
    {
        field(10; "Plane Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Seat Count"; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Plane Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Plane Code", "Seat Count")
        {
        }
    }
}

