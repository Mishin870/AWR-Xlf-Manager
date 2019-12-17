codeunit 70097810 "AWR_XLF_Translation_Yandex"
{
    procedure MakeParameters(yandexApiKey: Text; targetLang: Text): Text
    begin
        exit('https://translate.yandex.net/api/v1.5/tr.json/translate'
            + '?key=' + yandexApiKey + '&lang=en' + '-' + targetLang + '&text=');
    end;

    procedure Translate(parameters: Text; string: Text): Text
    begin
        if DelChr(string, '<>', ' ') = '' then
            exit(string);

        exit(ParseTranslation(common.DoGET(parameters + common.EncodeUri(string))));
    end;

    local procedure ParseTranslation(jsonText: Text): Text
    var
        jtoken: JsonToken;
        jobject: JsonObject;
        jarray: JsonArray;
    begin
        jtoken.ReadFrom(jsonText);
        jobject := jtoken.AsObject();

        jobject.SelectToken('text', jtoken);
        jarray := jtoken.AsArray();
        jarray.Get(0, jtoken);

        Exit(jtoken.AsValue().AsText());
    end;

    var
        common: Codeunit AWR_XLF_Common;
}