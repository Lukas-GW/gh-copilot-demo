// function named `validateDate` which validates a date from text input in a french format and converts it to a date object.
export function validateDate(dateString: string): Date | null {
    // Regular expression to match French date format (DD/MM/YYYY)
    const frenchDateRegex = /^(\d{2})\/(\d{2})\/(\d{4})$/;
    const match = dateString.match(frenchDateRegex);

    if (!match) {
        return null; // Invalid format
    }

    const day = parseInt(match[1]!, 10);
    const month = parseInt(match[2]!, 10) - 1; // Months are zero-based in JS Date
    const year = parseInt(match[3]!, 10);

    const date = new Date(year, month, day);

    // Check if the date is valid
    if (date.getFullYear() !== year || date.getMonth() !== month || date.getDate() !== day) {
        return null; // Invalid date
    }

    return date;
}

// function that validates the format of a GUID string.
export function validateGUID(guid: string): boolean {
    const guidRegex = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/;
    return guidRegex.test(guid);
}

// function that validates the format of a IPV6 address string and is named `validateIPV6`.
export function validateIPV6(ipv6: string): boolean {
    const ipv6Regex = /^(?:[a-fA-F0-9]{1,4}:){7}[a-fA-F0-9]{1,4}$|^(?:[a-fA-F0-9]{1,4}:){1,7}:$|^(?:[a-fA-F0-9]{1,4}:){1,6}:[a-fA-F0-9]{1,4}$|^(?:[a-fA-F0-9]{1,4}:){1,5}(?::[a-fA-F0-9]{1,4}){1,2}$|^(?:[a-fA-F0-9]{1,4}:){1,4}(?::[a-fA-F0-9]{1,4}){1,3}$|^(?:[a-fA-F0-9]{1,4}:){1,3}(?::[a-fA-F0-9]{1,4}){1,4}$|^(?:[a-fA-F0-9]{1,4}:){1,2}(?::[a-fA-F0-9]{1,4}){1,5}$|^[a-fA-F0-9]{1,4}:(?::[a-fA-F0-9]{1,4}){1,6}$|^:(?::[a-fA-F0-9]{1,4}){1,7}|::$/;
    return ipv6Regex.test(ipv6);
}   
