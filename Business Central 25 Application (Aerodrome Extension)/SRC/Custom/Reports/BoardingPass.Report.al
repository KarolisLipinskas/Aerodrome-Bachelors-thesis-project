report 50000 "Boarding Pass"
{
    DefaultLayout = RDLC;
    RDLCLayout = './SRC/Custom/Reports/RdlcLayouts/BoardingPass.rdlc';

    dataset
    {
        dataitem("Posted Check-In"; "Posted Check-In")
        {
            column(FlightNo_PostedCheckIn; "Posted Check-In"."Flight No.")
            {
            }
            column(FlightDate_PostedCheckIn; "Posted Check-In"."Flight Date")
            {
            }
            column(FlightTime_PostedCheckIn; "Posted Check-In"."Flight Time")
            {
            }
            column(TicketNo_PostedCheckIn; "Posted Check-In"."Ticket No.")
            {
            }
            column(RegistrationNo_PostedCheckIn; "Posted Check-In"."Registration No.")
            {
            }
            column(SeatCode_PostedCheckIn; "Posted Check-In"."Seat Code")
            {
            }
            column(Name_PostedCheckIn; "Posted Check-In".Name)
            {
            }
            column(Surname_PostedCheckIn; "Posted Check-In".Surname)
            {
            }
            column(PersonalCode_PostedCheckIn; "Posted Check-In"."Personal Code")
            {
            }
            column(BarcodeData; BarcodeData)
            {
            }
            dataitem(Flight; Flight)
            {
                DataItemLink = "Flight No." = FIELD("Flight No."), "Flight Date" = FIELD("Flight Date"), "Departure Time" = FIELD("Flight Time");
                column(Description_Flight; Flight.Description)
                {
                }
                dataitem(Customer; Customer)
                {
                    DataItemLink = "No." = FIELD(Customer);
                    column(Name_Customer; Customer.Name)
                    {
                    }
                }
            }

            trigger OnAfterGetRecord()
            begin
                BarcodeData := EncodeToCode128("Posted Check-In"."Registration No.");
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
    }

    trigger OnPostReport()
    begin
        Message('Boarding Pass printed successfully');
    end;

    var
        BarcodeData: Text;

    local procedure EncodeToCode128(input: Code[20]): Text
    var
        Code128: Text;
        i: Integer;
        CharValue: Integer;
        Checksum: Integer;
    begin
        // Initialize with the Start Code B (or A, C depending on your needs)
        Code128 := 'Ì'; // Start Code B in Code 128
        Checksum := 104; // Start Code B's value

        // Encode each character
        for i := 1 to StrLen(input) do begin
            CharValue := input[i] - 32;
            Code128 += GetCode128Char(CharValue);
            Checksum += (i * CharValue);
        end;

        // Add Checksum character
        Code128 += GetCode128Char(Checksum mod 103);

        // Add Stop character
        Code128 += 'Î'; // Stop Code in Code 128

        exit(Code128);
    end;

    local procedure GetCode128Char(Value: Integer): Text
    var
        Char: Byte;
    begin
        // Convert integer value to corresponding Code 128 character
        Char := (Value + 32);
        exit(Format(Char));
    end;
}

