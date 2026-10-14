page 60030 "Agent RoleCenter Content"
{
    PageType = CardPart;
    SourceTable = "Role Center Pages";

    layout
    {
        area(content)
        {
            group("Page Menu")
            {
                field("Flight List"; FlightList)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        PAGE.Run(50000);
                    end;
                }
                field("Check-In Journal"; CheckInJournal)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        PAGE.Run(50110);
                    end;
                }
                field("Check-In Ledger"; CheckInLedger)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        PAGE.Run(50120);
                    end;
                }
                field("Boarding Journal"; BoardingJournal)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        PAGE.Run(50230);
                    end;
                }
                field("Boarding Ledger"; BoardingLedger)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        PAGE.Run(50240);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    var
        FlightList: Label 'Flight List';
        CheckInJournal: Label 'Check-In Journal';
        CheckInLedger: Label 'Check-In Ledger';
        BoardingJournal: Label 'Boarding Journal';
        BoardingLedger: Label 'Boarding Ledger';
}

