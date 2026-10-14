report 50010 "Flight Provider Invoice"
{
    DefaultLayout = RDLC;
    RDLCLayout = './SRC/Custom/Reports/RdlcLayouts/FlightProviderInvoice.rdlc';

    dataset
    {
        dataitem(Flight; Flight)
        {
            column(PriceForCheckedIn; PriceForCheckedIn)
            {
            }
            column(PriceForBoarded; PriceForBoarded)
            {
            }
            column(TotalPrice; TotalPrice)
            {
            }
            column(CustomerName; CustomerName)
            {
            }
            column(StartDate; StartDate)
            {
            }
            column(EndDate; EndDate)
            {
            }
            column(Customer_Flight; Flight.Customer)
            {
            }
            column(FlightNo_Flight; Flight."Flight No.")
            {
                IncludeCaption = true;
            }
            column(FlightDate_Flight; Flight."Flight Date")
            {
                IncludeCaption = true;
            }
            column(DepartureTime_Flight; Flight."Departure Time")
            {
                IncludeCaption = true;
            }
            dataitem(Passenger; Passenger)
            {
                DataItemLink = "Flight No." = FIELD("Flight No."), "Flight Date" = FIELD("Flight Date"), "Flight Time" = FIELD("Departure Time");
                column(TicketNo_Passenger; Passenger."Ticket No.")
                {
                    IncludeCaption = true;
                }
                column(PersonalCode_Passenger; Passenger."Personal Code")
                {
                    IncludeCaption = true;
                }
                column(Name_Passenger; Passenger.Name)
                {
                    IncludeCaption = true;
                }
                column(Surname_Passenger; Passenger.Surname)
                {
                    IncludeCaption = true;
                }
                column(RegistrationNo_Passenger; Passenger."Registration No.")
                {
                    IncludeCaption = true;
                }
                column(SeatCode_Passenger; Passenger."Seat Code")
                {
                    IncludeCaption = true;
                }
                column(Status_Passenger; Passenger.Status)
                {
                    IncludeCaption = true;
                }
            }
            dataitem("Flight Prov. Inv. Ledger Entry"; "Flight Prov. Inv. Ledger Entry")
            {
                DataItemLink = Customer = FIELD(Customer);
                column(CheckedInPassengerCount_AirlineInvoiceLedgerEntry; "Flight Prov. Inv. Ledger Entry"."CheckedIn Passenger Count")
                {
                }
                column(BoardedPassengerCount_AirlineInvoiceLedgerEntry; "Flight Prov. Inv. Ledger Entry"."Boarded Passenger Count")
                {
                }
                column(PriceForCheckedIn_AirlineInvoiceLedgerEntry; "Flight Prov. Inv. Ledger Entry"."Price For CheckedIn")
                {
                }
                column(PriceForBoarded_AirlineInvoiceLedgerEntry; "Flight Prov. Inv. Ledger Entry"."Price For Boarded")
                {
                }
                column(TotalPrice_AirlineInvoiceLedgerEntry; "Flight Prov. Inv. Ledger Entry"."Total Price")
                {
                }
            }

            trigger OnPreDataItem()
            begin
                Flight.SetRange(Customer, CustomerCode);
                Flight.SetRange("Flight Date", StartDate, EndDate);
                Flight.SetRange("Boarding Status", 3);
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
        MissedDate = 'Missed Passengers:';
        CheckedInDate = 'Checked-In Passengers:';
        BoardedDate = 'Boarded Passengers:';
        TotalDate = 'All Passengers:';
        GrandTotal = 'GrandTotal';
    }

    var
        PriceForCheckedIn: Decimal;
        PriceForBoarded: Decimal;
        TotalPrice: Decimal;
        CustomerCode: Code[20];
        CustomerName: Text[50];
        StartDate: Date;
        EndDate: Date;

    procedure SetParameters(CheckInPrice: Decimal; BoardedPrice: Decimal; Total: Decimal)
    begin
        PriceForCheckedIn := CheckInPrice;
        PriceForBoarded := BoardedPrice;
        TotalPrice := Total;
    end;

    procedure SetFlightFilterFields(CustomerNo: Code[20]; StartD: Date; EndD: Date)
    var
        CustRec: Record Customer;
    begin
        CustomerCode := CustomerNo;
        StartDate := StartD;
        EndDate := EndD;

        if CustRec.Get(CustomerNo) then
            CustomerName := CustRec.Name;
    end;
}

