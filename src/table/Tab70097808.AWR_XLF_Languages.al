table 70097808 "AWR_XLF_Languages"
{
    DataClassification = ToBeClassified;
    Caption = 'XLF Languages';
    Scope = Cloud;
    DataPerCompany = false;


    fields
    {
        field(1; "Lang"; Text[20])
        {
            Caption = 'Lang';
            DataClassification = CustomerContent;
        }
        field(2; "Lang Type"; Text[10])
        {
            Caption = 'Lang type';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Lang)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Lang, "Lang Type")
        {

        }
    }

}