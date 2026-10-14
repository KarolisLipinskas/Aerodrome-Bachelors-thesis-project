page 50200 "New Flight Provider"
{
    PageType = Card;
    SourceTable = Customer;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("Flight Provider Code"; Rec."Flight Provider Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if Rec."Flight Provider Code" <> '' then begin
                            if not (((Rec."Flight Provider Code"[1] >= 'A') and (Rec."Flight Provider Code"[1] <= 'Z')) or ((Rec."Flight Provider Code"[1] >= 'a') and (Rec."Flight Provider Code"[1] <= 'z'))) then
                                Error('First character in Flight Provider Code needs to be a letter');

                            if StrLen(Rec."Flight Provider Code") > 3 then
                                Error('Flight Provider Code cannot be longer than 3 characters');

                            if StrLen(Rec."Flight Provider Code") < 2 then
                                Error('Flight Provider Code cannot be shorter than 2 characters');

                        end;
                    end;
                }
                field("Default Price CheckIn"; Rec."Default Price CheckIn")
                {
                    ApplicationArea = All;
                    Caption = 'Default Price for Check-In, €';

                    trigger OnValidate()
                    begin
                        if Rec."Default Price CheckIn" < 0 then
                            Error('Default Check-In Price cannot be negative');
                    end;
                }
                field("Default Price Boarding"; Rec."Default Price Boarding")
                {
                    ApplicationArea = All;
                    Caption = 'Default Price for Boarding, €';

                    trigger OnValidate()
                    begin
                        if Rec."Default Price Boarding" < 0 then
                            Error('Default Boarding Price cannot be negative');
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnClosePage()
    var
        Vendor: Record Vendor;
    begin
        if (Rec.Name = '') or (Rec."Flight Provider Code" = '') then
            Rec.Delete(true)
        else begin
            Vendor.Init;
            Vendor.Name := Rec.Name;
            Vendor.isFlightProvider := true;
            Vendor."Flight Provider Code" := Rec."Flight Provider Code";
            Vendor.Validate(Vendor."Vendor Posting Group", 'EU');
            Vendor.Validate(Vendor."Gen. Bus. Posting Group", 'EU');
            Vendor.Validate("Currency Code", 'EUR');
            Vendor.Insert(true);

            Rec.Validate("Customer Posting Group", 'EU');
            Rec.Validate("Gen. Bus. Posting Group", 'EU');
            Rec.Validate("Currency Code", 'EUR');
            Rec.Modify(true);
            Message('Added new Flight Provider: %1', Rec.Name);
        end;
    end;
}

