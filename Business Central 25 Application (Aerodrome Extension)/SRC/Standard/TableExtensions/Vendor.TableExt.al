tableextension 50002 tableextension50002 extends Vendor
{
    fields
    {
        field(50000; isFlightProvider; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50010; "Flight Provider Code"; Code[3])
        {
            DataClassification = ToBeClassified;
        }
    }
}

