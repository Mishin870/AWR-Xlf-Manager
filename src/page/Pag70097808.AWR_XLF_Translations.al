page 70097808 "AWR_XLF_Translations"
{
    PageType = List;
    SourceTable = AWR_XLF_Translations;
    Caption = 'XLF Translations';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(ID; ID)
                {
                    ApplicationArea = All;
                }
                field(Source; Source)
                {
                    ApplicationArea = All;
                }
                field(Target; Target)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}