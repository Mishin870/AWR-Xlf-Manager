codeunit 70097807 "AWR_XLF_Common"
{
    procedure DoGET(url: Text): Text
    var
        client: HttpClient;
        responseMessage: HttpResponseMessage;
        result: text;
    begin
        if not client.Get(url, responseMessage) then
            Error(CantGet_Err, url);

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

    procedure EncodeUri(uri: Text) encodedUri: Text;
    var
        i: Integer;
        b: Char;
        AsciiValue: Integer;
    begin
        // First init encoding table once to save batch processing time
        if HexDigits = '' then
            UriEncodingTableInit();

        encodedUri := '';
        uri := ConvertStr(uri, AsciiStr, AnsiStr);
        for i := 1 to StrLen(uri) do begin
            b := uri[i];
            // Full URI encode :
            //IF (b IN [36,38,43,44,47,58,59,61,63,64,32,34,60,62,35,37,123,125,124,92,94,126,91,93,96]) OR
            // Simple URL encode (within ( ) without \ / : * ? " < > | )
            if (b in [36, 38, 40, 41, 43, 44, 59, 61, 64, 32, 35, 37, 123, 125, 94, 126, 91, 93, 96]) or (b >= 128) then begin
                encodedUri := encodedUri + '%  ';
                Evaluate(AsciiValue, Format(b, 0, '<NUMBER>'));
                encodedUri[StrLen(encodedUri) - 1] := HexDigits[(AsciiValue DIV 16) + 1];
                encodedUri[StrLen(encodedUri)] := HexDigits[(AsciiValue MOD 16) + 1];
            end else
                encodedUri := encodedUri + CopyStr(uri, i, 1);
        end;
    end;

    local procedure UriEncodingTableInit();
    var
        CharVar: array[32] of Char;
    BEGIN
        // Init ascii to ansii encoding table
        HexDigits := '0123456789ABCDEF';
        AsciiStr := 'ЂЃ‚ѓ„…†‡€‰Љ‹ЊЌЋЏђ‘’“”•–—™љ›њќћџ ЎўЈ¤Ґ¦§Ё©Є«¬­®ЇЭЭЭЭЭµ¶·ёЭЭ++Ѕѕ++--+-+ЖЗ++--Э-+';
        AsciiStr := AsciiStr + 'ПРСТУФiЦЧШ++Э_ЭЮоабвгдежзийклмнопрс=уфхцчшщъыьэЭя';

        CharVar[1] := 196;
        CharVar[2] := 197;
        CharVar[3] := 201;
        CharVar[4] := 242;
        CharVar[5] := 220;
        CharVar[6] := 186;
        CharVar[7] := 191;
        CharVar[8] := 188;
        CharVar[9] := 187;
        CharVar[10] := 193;
        CharVar[11] := 194;
        CharVar[12] := 192;
        CharVar[13] := 195;
        CharVar[14] := 202;
        CharVar[15] := 203;
        CharVar[16] := 200;
        CharVar[17] := 205;
        CharVar[18] := 206;
        CharVar[19] := 204;
        CharVar[20] := 175;
        CharVar[21] := 223;
        CharVar[22] := 213;
        CharVar[23] := 254;
        CharVar[24] := 218;
        CharVar[25] := 219;
        CharVar[26] := 217;
        CharVar[27] := 180;
        CharVar[28] := 177;
        CharVar[29] := 176;
        CharVar[30] := 185;
        CharVar[31] := 179;
        CharVar[32] := 178;
        AnsiStr := 'Зьйвдаезклипом' + Format(CharVar[1]) + Format(CharVar[2]) + Format(CharVar[3]) + 'жЖфц' + Format(CharVar[4]);
        AnsiStr := AnsiStr + 'ыщяЦ' + Format(CharVar[5]) + 'шЈШЧѓбнуъсСЄ' + Format(CharVar[6]) + Format(CharVar[7]);
        AnsiStr := AnsiStr + '®¬Ѕ' + Format(CharVar[8]) + 'Ў«' + Format(CharVar[9]) + '___¦¦' + Format(CharVar[10]) + Format(CharVar[11]);
        AnsiStr := AnsiStr + Format(CharVar[12]) + '©¦¦++ўҐ++--+-+г' + Format(CharVar[13]) + '++--¦-+¤рР';
        AnsiStr := AnsiStr + Format(CharVar[14]) + Format(CharVar[15]) + Format(CharVar[16]) + 'i' + Format(CharVar[17]) + Format(CharVar[18]);
        AnsiStr := AnsiStr + 'П++__¦' + Format(CharVar[19]) + Format(CharVar[20]) + 'У' + Format(CharVar[21]) + 'ФТх';
        AnsiStr := AnsiStr + Format(CharVar[22]) + 'µ' + Format(CharVar[23]) + 'Ю' + Format(CharVar[24]) + Format(CharVar[25]);
        AnsiStr := AnsiStr + Format(CharVar[26]) + 'эЭЇ' + Format(CharVar[27]) + '­' + Format(CharVar[28]) + '=ѕ¶§чё' +
            Format(CharVar[29]);
        AnsiStr := AnsiStr + 'Ё·' + Format(CharVar[30]) + Format(CharVar[31]) + Format(CharVar[32]) + '_ ';
    end;

    procedure StrReplace(string: Text; find: Text; replace: Text): Text
    var
        pos: Integer;
    begin
        pos := STRPOS(string, find);

        while pos <> 0 do begin
            string := DelStr(string, pos, StrLen(find));
            string := InsStr(string, replace, pos);
            pos := StrPos(string, find);
        END;
        exit(string);
    end;

    var
        CantGet_Err: Label 'Error processing GET request! GET: %1';
        NotSuccessStatus_Err: Label 'Error: not success HTTP status code: %1, response text: %2, GET: %3';

        // Fast URL encoder
        HexDigits: Text;
        AsciiStr: Text;
        AnsiStr: Text;
}