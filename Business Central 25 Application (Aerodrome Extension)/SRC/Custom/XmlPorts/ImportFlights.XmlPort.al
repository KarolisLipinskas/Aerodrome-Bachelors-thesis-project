xmlport 50000 "Import Flights"
{
    Direction = Import;
    FieldDelimiter = '<None>';
    FieldSeparator = ';';
    Format = VariableText;

    schema
    {
        textelement(Root)
        {
            tableelement(Flight; Flight)
            {
                XmlName = 'Flight';
                fieldelement("FlightNo."; Flight."Flight No.")
                {
                }
                fieldelement(FlightDate; Flight."Flight Date")
                {
                }
                fieldelement(DepartureTime; Flight."Departure Time")
                {
                }
                fieldelement(PlaneCode; Flight."Plane Code")
                {

                    trigger OnAfterAssignField()
                    var
                        Plane: Record Plane;
                    begin
                        if not Plane.Get(Flight."Plane Code") then begin
                            Plane.Init;
                            Plane."Plane Code" := Flight."Plane Code";
                            //Plane."Seat Count" := Flight."Seat Count";
                            Plane.Insert;
                        end;
                    end;
                }
                fieldelement(SeatCount; Flight."Seat Count")
                {

                    trigger OnAfterAssignField()
                    var
                        Plane: Record Plane;
                    begin
                        if Plane.Get(Flight."Plane Code") then begin
                            if Plane."Seat Count" = 0 then begin
                                Plane."Seat Count" := Flight."Seat Count";
                                Plane.Modify;
                            end;
                        end;
                    end;
                }

                trigger OnBeforeInsertRecord()
                var
                    FlightReference: Record "Flight Reference Table";
                begin
                    if not FlightReference.Get(Flight."Flight No.") then
                        Error('Flight No.: %1 reference was not found in DataBase', Flight."Flight No.");

                    Flight.Description := FlightReference.Description;
                    Flight.Customer := FlightReference.FlightProviderCust;
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
        Message('Flights imported successfully');
    end;
}

