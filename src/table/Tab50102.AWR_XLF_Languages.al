table 70097808 "AWR_XLF_Languages"
{
    DataClassification = ToBeClassified;
    Caption = 'XLF Languages';
    Scope = Extension;
    DataPerCompany = false;


    fields
    {
        //        field(1; "ID"; Integer)
        //        {
        //            Caption = 'ID';
        //            AutoIncrement = true;
        //            DataClassification = CustomerContent;
        //        }
        field(2; "Lang"; Text[20])
        {
            Caption = 'Lang';
            DataClassification = CustomerContent;
        }
        field(3; "Lang Type"; Text[10])
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