codeunit 70097811 "AWR_XLF_Translation_Azure"
{
    procedure MakeParameters(targetLang: Text): Text
    begin
        exit('https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to=' + targetLang);
    end;

    local procedure DoAPI(url: Text; apiKey: Text; string: Text): Text
    var
        client: HttpClient;
        responseMessage: HttpResponseMessage;
        result: text;
        content: HttpContent;
        headers: HttpHeaders;

        requestArray: JsonArray;
        requestObject: JsonObject;
        requestText: JsonValue;
    begin
        content.GetHeaders(headers);

        requestText.SetValue(string);
        requestObject.Add('Text', requestText);
        requestArray.Add(requestObject);
        requestArray.WriteTo(string);

        content.WriteFrom(string);

        headers.Remove('Content-Type');
        headers.Add('Content-Type', 'application/json');
        headers.Add('Ocp-Apim-Subscription-Key', apiKey);

        if not client.Post(url, content, responseMessage) then
            Error(CantPost_Err, url);

        ResponseMessage.Content().ReadAs(result);

        if not ResponseMessage.IsSuccessStatusCode() then
            error(
                NotSuccessStatus_Err,
                ResponseMessage.HttpStatusCode(),
                result,
                url
            );

        Exit(result);
    end;

    procedure Translate(parameters: Text; azureApiKey: Text; string: Text): Text
    begin
        exit(ParseTranslation(DoAPI(parameters, azureApiKey, string)));
    end;

    local procedure ParseTranslation(jsonText: Text): Text
    var
        jtoken: JsonToken;

        rootArray: JsonArray;
        root: JsonObject;

        translationArray: JsonArray;
        translation: JsonObject;
    begin
        jtoken.ReadFrom(jsonText);

        rootArray := jtoken.AsArray();
        rootArray.Get(0, jtoken);

        root := jtoken.AsObject();
        root.SelectToken('translations', jtoken);

        translationArray := jtoken.AsArray();
        translationArray.Get(0, jtoken);
        translation := jtoken.AsObject();

        translation.SelectToken('text', jtoken);
        exit(jtoken.AsValue().AsText());
    end;

    var
        CantPost_Err: Label 'Error processing POST request! POST: %1';
        NotSuccessStatus_Err: Label 'Error: not success HTTP status code: %1, response text: %2, POST: %3';
}