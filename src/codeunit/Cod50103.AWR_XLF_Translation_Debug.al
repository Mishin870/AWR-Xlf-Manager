codeunit 70097809 "AWR_XLF_Translation_Debug"
{
    procedure MakeParameters(targetLang: Text): Text
    begin
        exit('[' + targetLang + '] ');
    end;

    procedure Translate(parameters: Text; string: Text): Text
    begin
        exit(parameters + string);
    end;
}