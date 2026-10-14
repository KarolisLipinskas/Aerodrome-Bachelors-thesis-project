codeunit 50060 "User Role Controller"
{

    trigger OnRun()
    begin
    end;

    procedure UserHasPermission(PermissionSetCode: Code[20]): Boolean
    var
        UserAccess: Record "Access Control";
    begin
        UserAccess.SetRange("User Name", UserId);
        UserAccess.SetRange("Role ID", PermissionSetCode);
        if UserAccess.FindFirst then
            exit(true);

        exit(false);
    end;
}

