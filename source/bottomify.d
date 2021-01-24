module bottomify;

import std.array;
import std.string;
import std.encoding;
import std.regex;
import std.format;

private struct CharacterValue
{
    int character;
    string value;
}

private CharacterValue[6] character_values;

private int[string] character_values_reversed;

private string[256] byte_to_scv_group;
private int[string] scv_group_to_byte;

private string line_ending = "👉👈";

static this()
{
    character_values = [
        CharacterValue(200, "🫂"), CharacterValue(50, "💖"),
        CharacterValue(10, "✨"), CharacterValue(5, "🥺"),
        CharacterValue(1, ","), CharacterValue(0, "❤️"),
    ];

    byte_to_scv_group = mapByteToSCVGroup();
    scv_group_to_byte = mapSCVGroupToByte();
}

private string byteToSCVGroup(int value)
{
    auto strBuilder = appender!string;

    do
    {
        foreach (mapping; character_values)
        {
            if (value >= mapping.character)
            {
                strBuilder.put(mapping.value);
                value -= mapping.character;
                break;
            }
        }
    }
    while (value > 0);

    return strBuilder[];
}

private string[256] mapByteToSCVGroup()
{
    string[256] mapping;

    int i = 0;
    do
    {
        mapping[i] = byteToSCVGroup(i);
        i++;
    }
    while (i <= 255);

    return mapping;
}

string encodeByte(int value)
{
    return byte_to_scv_group[value] ~ line_ending;
}

string encode(string value)
{
    auto encodedValue = appender!string;
    foreach (character; codePoints(value))
    {
        encodedValue ~= encodeByte(character);
    }
    return encodedValue[];
}

private int[string] mapSCVGroupToByte()
{
    int[string] mapping;

    int i = 0;
    do
    {
        mapping[byte_to_scv_group[i]] = i;
        i ++;
    } while (i <= 255);

    return mapping;
}

private string[] getSCVGroups(string value)
{
    return split(strip(value), regex(format("%s|\u200B", line_ending)))[0 .. $-1];
}

private bool isSCVGroup(string input) {
    bool found = true;
    foreach (s; split(input)) {
        bool isSCV = false;
        foreach (mapping; character_values) {
            if (mapping.value == s) {
                isSCV = true;
                break;
            }
        }
        if (!isSCV) {
            found = false;
        }
    }
    return true;
}

private int SCVGroupToByte(string input) {
    int value = 0;

    foreach (cv; split(input)) {
        value += scv_group_to_byte[cv];
    }

    scv_group_to_byte[input] = value;
    return value;
}

private int decodeSCVGroup(string input)
{
    auto character = scv_group_to_byte.get(input, -1);
    if (character != -1) {
        return character;
    } else if (isSCVGroup(input)) {
        return SCVGroupToByte(input);
    }
    throw new Error(format("Cannot decode value character %s", input));
}

string decode(string value)
{
    char[] decodedValue;
    foreach (character; getSCVGroups(value))
    {
        decodedValue ~= decodeSCVGroup(character);
    }
    return decodedValue[].idup;
}
