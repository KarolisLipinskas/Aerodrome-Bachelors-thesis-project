xmlport 50010 "Import Passengers"
{
    Direction = Import;
    FieldDelimiter = '<None>';
    FieldSeparator = ';';
    Format = VariableText;

    schema
    {
        textelement(Root)
        {
            tableelement(Passenger; Passenger)
            {
                XmlName = 'CheckIn';
                fieldelement(FlightNo; Passenger."Flight No.")
                {
                }
                fieldelement(FlightDate; Passenger."Flight Date")
                {
                }
                fieldelement(FlightTime; Passenger."Flight Time")
                {
                }
                fieldelement(PersonCode; Passenger."Personal Code")
                {

                    trigger OnAfterAssignField()
                    var
                        Customer: Record Customer;
                    begin
                        if Passenger."Personal Code" = '' then
                            Error('Person Code cannot be empty');

                        Customer.SetRange(isPerson, true);
                        Customer.SetRange("Person Code", Passenger."Personal Code");
                        if not Customer.FindFirst then begin
                            Customer.Init;
                            Customer."Person Code" := Passenger."Personal Code";
                            Customer.isPerson := true;
                            Customer.Insert(true);
                        end;
                    end;
                }
                fieldelement(Name; Passenger.Name)
                {

                    trigger OnAfterAssignField()
                    var
                        Customer: Record Customer;
                    begin
                        if Passenger.Name = '' then
                            Error('Name cannot be empty');

                        Customer.SetRange(isPerson, true);
                        Customer.SetRange("Person Code", Passenger."Personal Code");
                        Customer.FindFirst;
                        if Customer.Name = '' then begin
                            Customer.Name := Passenger.Name;
                            Customer.Modify;
                        end;
                    end;
                }
                fieldelement(Surname; Passenger.Surname)
                {

                    trigger OnAfterAssignField()
                    var
                        Customer: Record Customer;
                    begin
                        if Passenger.Surname = '' then
                            Error('Surname cannot be empty');

                        Customer.SetRange(isPerson, true);
                        Customer.SetRange("Person Code", Passenger."Personal Code");
                        Customer.FindFirst;
                        if Customer.Surname = '' then begin
                            Customer.Surname := Passenger.Surname;
                            Customer.Modify;
                        end;
                    end;
                }
                fieldelement(TicketNo; Passenger."Ticket No.")
                {
                }
                fieldelement(RegistrationNo; Passenger."Registration No.")
                {

                    trigger OnAfterAssignField()
                    begin
                        if Passenger."Registration No." <> '' then
                            Passenger.Status := 1
                        else
                            Passenger.Status := 0;
                    end;
                }
                fieldelement(Seat; Passenger."Seat Code")
                {

                    trigger OnAfterAssignField()
                    var
                        SeatTable: Record "Seat Table";
                    begin
                        if Passenger."Seat Code" = '' then
                            exit;

                        if not SeatTable.Get(Passenger."Flight No.", Passenger."Flight Date", Passenger."Flight Time", Passenger."Seat Code") then
                            Error('Seat: %1, Does not exist for this flight: %2', Passenger."Seat Code", Passenger."Flight No.");
                        //MESSAGE('Flight %1, %2, %3', "Check-In"."Flight No.", "Check-In"."Flight Date", "Check-In"."Flight Time");
                        SeatTable.Available := false;
                        SeatTable.Modify;
                    end;
                }

                trigger OnAfterInsertRecord()
                var
                    PassengerController: Codeunit "Passenger Logic";
                begin
                    PassengerController.PassengerToCheckIn(Passenger);
                end;
            }
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

    trigger OnInitXmlPort()
    var
        UserController: Codeunit "User Role Controller";
    begin
        if not (UserController.UserHasPermission('FMANAGER') or UserController.UserHasPermission('SUPER')) then
            Error('Access Denied');
    end;

    trigger OnPostXmlPort()
    begin
        Message('Passengers Imported Successfully');
    end;
}

