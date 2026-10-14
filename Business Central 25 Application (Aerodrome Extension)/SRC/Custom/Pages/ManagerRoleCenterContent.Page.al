page 60020 "Manager RoleCenter Content"
{
    PageType = CardPart;
    SourceTable = "Role Center Pages";
    SourceTableView = WHERE("Primary Key" = CONST('TEST'));

    layout
    {
        area(content)
        {
            group("Pages Menu")
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
                field("Posted Ticket Sale List"; PostedTicketSaleList)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        PAGE.Run(50250);
                    end;
                }
                field("Posted Ticket Purchase List"; PoatedTicketPurchaseList)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        PAGE.Run(50260);
                    end;
                }
                field("Ticket Sale/Purchase Journal"; TicketSalePurchaseJournal)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        PAGE.Run(50270);
                    end;
                }
                field("Ticket Sale/Purchase Ledger"; TicketSalePurchaseLedger)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        PAGE.Run(50280);
                    end;
                }
                field("Flight Provider Invoice Journal"; FlightProviderInvoiceJournal)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        PAGE.Run(50290);
                    end;
                }
                field("Flight Provider Invoice Ledger"; FlightProviderInvoiceLedger)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        PAGE.Run(50300);
                    end;
                }
            }
            group(XMLports)
            {
                field("Import Flights"; ImportFlights)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        XMLPORT.Run(50000);
                    end;
                }
                field("Import Passengers"; ImportPassengers)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        XMLPORT.Run(50010);
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
        PostedTicketSaleList: Label 'Posted Ticket Sale List';
        PoatedTicketPurchaseList: Label 'Posted Ticket Purchase List';
        TicketSalePurchaseJournal: Label 'Ticket Sale/Purchase Journal';
        TicketSalePurchaseLedger: Label 'Ticket Sale/Purchase Ledger';
        FlightProviderInvoiceJournal: Label 'Flight Provider Invoice Journal';
        FlightProviderInvoiceLedger: Label 'Flight Provider Invoice Ledger';
        ImportFlights: Label 'Import Flights';
        ImportPassengers: Label 'Import Passengers';
}

