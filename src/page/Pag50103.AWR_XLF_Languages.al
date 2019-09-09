page 70097809 "AWR_XLF_Languages"
{
    PageType = List;
    SourceTable = AWR_XLF_Languages;
    Caption = 'XLF Languages';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                //field(ID; ID)
                //{
                //    ApplicationArea = All;
                //}
                field(Lang; Lang)
                {
                    ApplicationArea = All;
                }
                field("Lang Type"; "Lang Type")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}