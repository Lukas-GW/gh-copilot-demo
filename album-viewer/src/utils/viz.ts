// generate a plot with D3.js of the selling price of the album by year
// x-axis are the month series and y-axis show the numbers of albums sold
// data from the sales of album are loaded in from an external source and are in json format
import * as d3 from "d3";

export interface AlbumSalesData {
    month: string;
    year: number;
    albumsSold: number;
}

export function generateAlbumSalesPlot(
    data: AlbumSalesData[],
    containerId: string
): void {
    // Set dimensions and margins
    const margin = { top: 20, right: 30, bottom: 40, left: 40 };
    const width = 800 - margin.left - margin.right;
    const height = 400 - margin.top - margin.bottom;

    // Remove existing SVG if any
    d3.select(`#${containerId}`).selectAll("svg").remove();

    // Create SVG container
    const svg = d3
        .select(`#${containerId}`)
        .append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", `translate(${margin.left},${margin.top})`);

    // Parse the month names
    const parseMonth = d3.timeParse("%B");
    const plotData = data.map(d => ({
        ...d,
        date: parseMonth(d.month) || new Date()
    }));

    // Set x and y scales
    const x = d3
        .scaleTime()
        .domain(d3.extent(plotData, d => d.date) as [Date, Date])
        .range([0, width]);

    const y = d3
        .scaleLinear()
        .domain([0, d3.max(plotData, d => d.albumsSold) || 0])
        .nice()
        .range([height, 0]);

    // Add x-axis
    svg
        .append("g")
        .attr("transform", `translate(0,${height})`)
        .call(
            d3.axisBottom(x)
                .ticks(d3.timeMonth.every(1))
                .tickFormat(d3.timeFormat("%b") as any)
        );

    // Add y-axis
    svg.append("g").call(d3.axisLeft(y));

    // Add line path
    const line = d3
        .line<any>()
        .x(d => x(d.date))
        .y(d => y(d.albumsSold));

    svg
        .append("path")
        .datum(plotData)
        .attr("fill", "none")
        .attr("stroke", "steelblue")
        .attr("stroke-width", 1.5)
        .attr("d", line);
}       