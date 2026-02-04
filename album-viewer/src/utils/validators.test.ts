import { describe, expect, it } from "vitest";
import { validateDate, validateIPV6 } from "./validators";

// test the validateDate function
describe("validateDate", () => {
    it("should return a Date object for a valid French date", () => {
        const result = validateDate("25/12/2020");
        expect(result).toBeInstanceOf(Date);
        expect(result?.getFullYear()).toBe(2020);
        expect(result?.getMonth()).toBe(11); // Months are zero-based
        expect(result?.getDate()).toBe(25);
    });

    it("should return null for an invalid date format", () => {
        const result = validateDate("2020-12-25");
        expect(result).toBeNull();
    });

    it("should return null for an invalid date", () => {
        const result = validateDate("31/02/2020");
        expect(result).toBeNull();
    });
});