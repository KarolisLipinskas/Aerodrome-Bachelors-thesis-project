page 60000 "Manager RoleCenter"
{
    PageType = RoleCenter;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(rolecenter)
        {
            group(Control3)
            {
                ShowCaption = false;
                part(Control2; "Manager RoleCenter Content")
                {
                    ApplicationArea = All;
                }
                part(Control6; "Standart Pages Content")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(sections)
        {
            /*action(hmm)
            {
            }*/
        }
    }
}

