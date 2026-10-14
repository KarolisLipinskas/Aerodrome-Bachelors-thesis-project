tableextension 50001 tableextension50001 extends Customer
{
    fields
    {
        field(50000; isFlightProvider; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50001; "Flight Provider Code"; Code[3])
        {
            DataClassification = ToBeClassified;
        }
        field(50002; "Default Price CheckIn"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50003; "Default Price Boarding"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50010; isPerson; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50020; "Person Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50030; Surname; Text[50])
        {
            DataClassification = ToBeClassified;
        }
    }
}

