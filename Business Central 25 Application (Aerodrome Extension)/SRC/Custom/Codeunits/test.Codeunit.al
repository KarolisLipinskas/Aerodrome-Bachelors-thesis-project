codeunit 60000 test
{

    trigger OnRun()
    var
        string: Text;
        char: Byte;
        int: Integer;
    begin
        //string := FORMAT(65, 0, '<Char>');
        //char := FORMAT(65, 0, '<Char>');
        char := 209;
        string := 'start' + Format(char) + 'end';
        Message('Char: %1, String: %2', char, string);

        string := Format(55);
        Message('S: %1', string);

        Evaluate(int, string);
        Message('int: %1', int);

        Message('%1', EncodeToCode128('CI000062'));
    end;

    local procedure EncodeToCode128(input: Code[20]): Text
    var
        code128: Text;
        i: Integer;
        CharValue: Integer;
        Checksum: Integer;
    begin
        // Initialize with the Start Code B (or A, C depending on your needs)
        code128 := 'Ì'; // Start Code B in Code 128
        Checksum := 104; // Start Code B's value

        // Encode each character
        for i := 1 to StrLen(input) do begin
            CharValue := input[i] - 32;
            code128 += GetCode128Char(CharValue);
            Checksum += (i * CharValue);
        end;

        // Add Checksum character
        code128 += GetCode128Char(Checksum mod 103);

        // Add Stop character
        code128 += 'Î'; // Stop Code in Code 128

        exit(code128);
    end;

    local procedure GetCode128Char(Value: Integer): Text
    var
        char: Byte;
    begin
        // Convert integer value to corresponding Code 128 character
        char := (Value + 32);
        exit(Format(char));
    end;
}

