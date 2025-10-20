class StackedBarChartD3Aide {
  constructor(
    containerSelector,
    data,
    chartWidth,
    chartHeight,
    invalidData,
    noDataFound
  ) {
    this.containerSelector = containerSelector;
    this.data = data;
    this.chartWidth = chartWidth;
    this.chartHeight = chartHeight;
    this.invalidData = invalidData;
    this.noDataFound = noDataFound;
    this.margin = { top: 80, right: 0, bottom: 60, left: 0 };

    // Initialize chart creation if data is valid
    if (!this.invalidData) {
      this.initializeChart();
    } else {
      this.handleNoDataError();
    }
  }

  // Initialize the chart
  initializeChart() {
    this.createSVG();
    this.createScales();
    this.drawStackedBars();
    this.drawTextAndLines();
  }

  // Create the SVG container
  createSVG() {
    this.width = this.chartWidth - this.margin.left - this.margin.right;
    this.height = this.chartHeight - this.margin.top - this.margin.bottom;

    this.svg = d3
      .selectAll(this.containerSelector)
      .select("svg#tir-chart")
      .attr("class", "w-full h-auto m-0")
      .attr("preserveAspectRatio", "xMidYMid meet")
      .attr("viewBox", `0 0 ${this.chartWidth} ${this.chartHeight}`)
      .append("g")
      .attr(
        "transform",
        `translate(-${this.margin.left + 200},${this.margin.top})`
      );
  }

  // Create X and Y scales
  createScales() {
    this.x = d3
      .scaleBand()
      .domain(["Goals for Type 1 and Type 2 Diabetes"])
      .range([0, this.chartWidth])
      .padding(0.8);

    this.y = d3
      .scaleLinear()
      .domain([0, 100])
      .range([this.chartHeight - this.margin.top - this.margin.bottom, 0]);
  }

  // Draw stacked bars
  drawStackedBars() {
    let y0 = 0;
    this.data.forEach((d) => {
      const barHeight = d.value > 0 ? d.value + 2 : 2;
      const color = d.value > 0 ? d.color : "#d3d3d3";

      this.svg
        .append("rect")
        .attr("x", this.x("Goals for Type 1 and Type 2 Diabetes"))
        .attr("y", this.y(y0 + barHeight))
        .attr("width", this.x.bandwidth())
        .attr("height", this.y(y0) - this.y(y0 + barHeight))
        .attr("fill", color)
        .attr("stroke", "white");

      y0 += barHeight;
    });
  }

  // Draw labels, text, and connecting lines
  drawTextAndLines() {
    let y1 = 0;
    let highEndPoint, veryHighEndPoint;
    let lowEndPoint, veryLowEndPoint;
    let targetValue = 0;

    this.data.forEach((d) => {
      let barValue = d.value > 0 ? d.value : 2;
      let lineY = y1 + barValue / 2;
      let textY = y1 + barValue / 2 + 5;
      let lineLength = 130;
      targetValue = this.data.find((d) => d.category === "Target").value;

      if (d.category === "Very High") {
        lineY = y1 + barValue / 2 + 7;
        textY = lineY + 4;
        lineLength = 25;
        veryHighEndPoint = {
          x:
            this.x("Goals for Type 1 and Type 2 Diabetes") +
            this.x.bandwidth() +
            120 +
            lineLength,
          y: this.y(lineY),
        };
      }
      if (d.category === "High") {
        lineY = y1 + barValue / 2 + 5;
        textY = lineY - 4;
        lineLength = 25;
        highEndPoint = {
          x:
            this.x("Goals for Type 1 and Type 2 Diabetes") +
            this.x.bandwidth() +
            120 +
            lineLength,
          y: this.y(lineY),
        };
      }
      if (d.category === "Low") {
        lineY = y1 + barValue / 2 + 1;
        textY = lineY + 4;
        lineLength = 25;
        lowEndPoint = {
          x:
            this.x("Goals for Type 1 and Type 2 Diabetes") +
            this.x.bandwidth() +
            120 +
            lineLength,
          y: this.y(lineY),
        };
      }
      if (d.category === "Very Low") {
        lineY = y1 + barValue / 2;
        textY = lineY - 4;
        lineLength = 25;
        veryLowEndPoint = {
          x:
            this.x("Goals for Type 1 and Type 2 Diabetes") +
            this.x.bandwidth() +
            120 +
            lineLength,
          y: this.y(lineY),
        };
      }

      this.svg
        .append("text")
        .attr(
          "x",
          this.x("Goals for Type 1 and Type 2 Diabetes") +
          this.x.bandwidth() +
          10
        )
        .attr("y", this.y(textY))
        .attr("text-anchor", "start")
        .attr("dy", ".50em")
        .style("font-weight", "bold")
        .style("font-size", "12px")
        .append("tspan")
        .attr(
          "x",
          this.x("Goals for Type 1 and Type 2 Diabetes") +
          this.x.bandwidth() +
          10
        )
        .text(d.category)
        .append("tspan")
        .attr("x", () => {
          // Adjust this value to space out the category and value
          return (
            this.x("Goals for Type 1 and Type 2 Diabetes") +
            this.x.bandwidth() +
            10 +
            130
          ); // Adjust the offset as needed
        })
        .attr("text-anchor", "end")
        .text(d.category !== "Target" ? `${d.value}%` : "");

      if (d.category === "Very High") {
        this.svg
          .append("text")
          .attr(
            "x",
            this.x("Goals for Type 1 and Type 2 Diabetes") +
            this.x.bandwidth() +
            10
          )
          .attr("y", this.y(textY + 4))
          .text("Goal: <5%")
          .style("font-size", "12px")
          .style("fill", "#7A7A7B");
      }

      if (d.category === "Very Low") {
        this.svg
          .append("text")
          .attr(
            "x",
            this.x("Goals for Type 1 and Type 2 Diabetes") +
            this.x.bandwidth() +
            10
          )
          .attr("y", this.y(textY - 10))
          .text("Goal: <1%")
          .style("font-size", "12px")
          .style("fill", "#7A7A7B");

        this.svg
          .append("text")
          .attr(
            "x",
            this.x("Goals for Type 1 and Type 2 Diabetes") +
            this.x.bandwidth() +
            90
          )
          .attr("y", this.y(textY - 10))
          .attr("text-anchor", "start")
          .text("Each 1% time in range = about 15 minutes")
          .style("font-size", "12px")
          .style("fill", "#7A7A7B");
      }
      const highValue = this.data.find((d) => d.category === "High").value;
      if (d.category === "Target") {
        this.svg
          .append("text")
          .attr(
            "x",
            this.x("Goals for Type 1 and Type 2 Diabetes") +
            this.x.bandwidth() +
            154
          )
          .attr("y", this.y(textY))
          .attr("text-anchor", "start")
          .attr("dy", ".50em")
          .style("font-size", "15px")
          .style("font-weight", "bold")
          .text(`${d.value}%`);

        this.svg
          .append("text")
          .attr(
            "x",
            this.x("Goals for Type 1 and Type 2 Diabetes") +
            this.x.bandwidth() +
            202
          )
          .attr("y", this.y(textY - 3))
          .text("Goal: ≥70%")
          .style("font-size", "12px")
          .style("fill", "#7A7A7B");

        this.svg
          .append("text")
          .attr(
            "x",
            this.x("Goals for Type 1 and Type 2 Diabetes") +
            this.x.bandwidth() +
            275
          )
          .attr("y", this.y(textY - 12))
          .attr("text-anchor", "start")
          .text("Each 5% increase is clinically beneficial")
          .style("font-size", "12px")
          .style("fill", "#7A7A7B");

        if (highValue > 0) {
          this.svg
            .append("text")
            .attr(
              "x",
              this.x("Goals for Type 1 and Type 2 Diabetes") +
              this.x.bandwidth() -
              100
            )
            .attr("y", this.y(y1 + d.value))
            .attr("text-anchor", "start")
            .text("180")
            .style("font-weight", "bold")
            .style("font-size", "12px");
        }
      }

      if (d.category === "High" && highValue > 0) {
        this.svg
          .append("text")
          .attr(
            "x",
            this.x("Goals for Type 1 and Type 2 Diabetes") +
            this.x.bandwidth() -
            100
          )
          .attr("y", this.y(y1 + d.value))
          .attr("text-anchor", "start")
          .style("font-weight", "bold")
          .text("250")
          .style("font-size", "12px");
      }
      this.svg
        .append("line")
        .attr(
          "x1",
          this.x("Goals for Type 1 and Type 2 Diabetes") +
          this.x.bandwidth() +
          10
        )
        .attr("y1", this.y(lineY))
        .attr(
          "x2",
          this.x("Goals for Type 1 and Type 2 Diabetes") +
          this.x.bandwidth() +
          120 +
          lineLength
        )
        .attr("y2", this.y(lineY))
        .attr("width", 200)
        .attr("stroke", "black")
        .attr("stroke-width", 1)
        .attr("stroke-linecap", "round");

      y1 += barValue;
    });

    // Add the line connecting "High" and "Very High"
    if (highEndPoint && veryHighEndPoint) {
      const midX = (highEndPoint.x + veryHighEndPoint.x) / 2;
      const midY = (highEndPoint.y + veryHighEndPoint.y) / 2;

      // Find values for "High" and "Very High"
      const highValue = this.data.find((d) => d.category === "High").value;
      const veryHighValue = this.data.find(
        (d) => d.category === "Very High"
      ).value;

      // Sum of "High" and "Very High" values
      const sumHighAndVeryHigh = highValue + veryHighValue;

      // Add text above the horizontal line
      this.svg
        .append("text")
        .attr(
          "x",
          (this.x("Goals for Type 1 and Type 2 Diabetes") +
            this.chartWidth -
            this.margin.right) /
          2 +
          50
        )
        .attr("y", midY - 5)
        .style("font-size", "15px")
        .style("font-weight", "bold")
        .text(`${sumHighAndVeryHigh}%`);

      this.svg
        .append("text")
        .attr(
          "x",
          (this.x("Goals for Type 1 and Type 2 Diabetes") +
            this.chartWidth -
            this.margin.right) /
          2 +
          90
        )
        .attr("y", midY - 5)
        .style("font-size", "12px")
        .text("Goal: <25%")
        .style("fill", "#7A7A7B");

      // Draw the line connecting "High" and "Very High"
      this.svg
        .append("line")
        .attr("x1", highEndPoint.x)
        .attr("y1", highEndPoint.y)
        .attr("x2", veryHighEndPoint.x)
        .attr("y2", veryHighEndPoint.y)
        .attr("stroke", "black")
        .attr("stroke-width", 1)
        .attr("stroke-linecap", "round");

      // Draw the horizontal line from the midpoint
      this.svg
        .append("line")
        .attr("x1", highEndPoint.x)
        .attr("y1", midY)
        .attr("x2", this.chartWidth - this.margin.right - 40)
        .attr("y2", midY)
        .attr("stroke", "black")
        .attr("stroke-width", 1)
        .attr("stroke-linecap", "round");
    }

    if (lowEndPoint && veryLowEndPoint) {
      const midX = (lowEndPoint.x + veryLowEndPoint.x) / 2;
      const midY = (lowEndPoint.y + veryLowEndPoint.y) / 2;

      // Find values for "Low" and "Very Low"
      const lowValue = this.data.find((d) => d.category === "Low").value;
      const veryLowValue = this.data.find(
        (d) => d.category === "Very Low"
      ).value;

      // Sum of "Low" and "Very Low" values
      const sumLowAndVeryLow = lowValue + veryLowValue;

      this.svg
        .append("text")
        .attr(
          "x",
          (this.x("Goals for Type 1 and Type 2 Diabetes") +
            this.chartWidth -
            this.margin.right) /
          2 +
          50
        )
        .attr("y", midY - 5)
        .style("font-size", "15px")
        .style("font-weight", "bold")
        .text(`${sumLowAndVeryLow}%`);

      this.svg
        .append("text")
        .attr(
          "x",
          (this.x("Goals for Type 1 and Type 2 Diabetes") +
            this.chartWidth -
            this.margin.right) /
          2 +
          90
        )
        .attr("y", midY - 5)
        .style("font-size", "12px")
        .text("Goal: <4%")
        .style("fill", "#7A7A7B");

      this.svg
        .append("line")
        .attr("x1", lowEndPoint.x)
        .attr("y1", lowEndPoint.y)
        .attr("x2", veryLowEndPoint.x)
        .attr("y2", veryLowEndPoint.y)
        .attr("stroke", "black")
        .attr("stroke-width", 1)
        .attr("stroke-linecap", "round");

      // Draw the horizontal line from the midpoint
      this.svg
        .append("line")
        .attr("x1", lowEndPoint.x)
        .attr("y1", midY)
        .attr("x2", this.chartWidth - this.margin.right - 40)
        .attr("y2", midY)
        .attr("stroke", "black")
        .attr("stroke-width", 1)
        .attr("stroke-linecap", "round");
    }
  }

  // Draw a connecting line between two points
  drawConnectingLine(startY, endY) {
    this.svg
      .append("line")
      .attr("x1", this.x("Goals for Type 1 and Type 2 Diabetes") + 80)
      .attr("x2", this.x("Goals for Type 1 and Type 2 Diabetes") + 100)
      .attr("y1", this.y(startY))
      .attr("y2", this.y(endY))
      .attr("stroke", "black")
      .attr("stroke-width", 1);
  }

  // Handle error state for no data
  handleNoDataError() {
    d3.select(this.containerSelector)
      .append("text")
      .text(this.noDataFound)
      .attr("class", "error-text");
  }
}

class AGPChartD3Aide {
  constructor(container, data, width, height, margin) {
    this.container = container;
    this.data = data;
    this.width = width;
    this.height = height;
    this.margin = margin;

    // Initialize chart
    this.initChart();
  }

  // Initialize the chart
  initChart() {
    this.createSVG();
    this.createScales();
    this.defineLinesAndAreas();
    this.calculateAverages();
    this.formatData();
    this.drawAreas();
    this.drawLines();
    this.addAxes();
    this.addGridlines();
    this.addReferenceAreas();
    this.addReferenceLabels();
  }

  // Create SVG container
  createSVG() {
    this.svg = d3
      .select(this.container)
      .attr(
        "viewBox",
        `0 0 ${this.width + this.margin.left + this.margin.right} ${this.height + this.margin.top + this.margin.bottom
        }`
      )
      .attr("preserveAspectRatio", "xMidYMid meet")
      .append("g")
      .attr("transform", `translate(${this.margin.left},${this.margin.top})`);
  }

  // Create X and Y scales
  createScales() {
    this.x = d3
      .scaleBand()
      .domain([...Array(24).keys()].map((d) => d.toString().padStart(2, "0")))
      .range([0, this.width])
      .padding(0);

    this.y = d3.scaleLinear().range([this.height, 0]).domain([0, 350]);
  }

  // Define lines and areas
  defineLinesAndAreas() {
    this.lineVeryLow = d3
      .line()
      .x((d) => this.x(d.hour) + this.x.bandwidth() / 2)
      .y((d) => this.y(d.avgp5))
      .curve(d3.curveCatmullRom);

    this.lineLow = d3
      .line()
      .x((d) => this.x(d.hour) + this.x.bandwidth() / 2)
      .y((d) => this.y(d.avgp25))
      .curve(d3.curveCatmullRom);

    this.lineNormal = d3
      .line()
      .x((d) => this.x(d.hour) + this.x.bandwidth() / 2)
      .y((d) => this.y(d.avgp50))
      .curve(d3.curveCatmullRom);

    this.lineHigh = d3
      .line()
      .x((d) => this.x(d.hour) + this.x.bandwidth() / 2)
      .y((d) => this.y(d.avgp75))
      .curve(d3.curveCatmullRom);

    this.lineVeryHigh = d3
      .line()
      .x((d) => this.x(d.hour) + this.x.bandwidth() / 2)
      .y((d) => this.y(d.avgp95))
      .curve(d3.curveCatmullRom);

    this.areaLowToHigh = d3
      .area()
      .x((d) => this.x(d.hour) + this.x.bandwidth() / 2)
      .y0((d) => this.y(d.avgp25))
      .y1((d) => this.y(d.avgp75))
      .curve(d3.curveCatmullRom);

    this.areaVeryLowToVeryHigh = d3
      .area()
      .x((d) => this.x(d.hour) + this.x.bandwidth() / 2)
      .y0((d) => this.y(d.avgp5))
      .y1((d) => this.y(d.avgp95))
      .curve(d3.curveCatmullRom);
  }

  calculateAverages() {
    const result = {};

    this.data.forEach((entry) => {
      const { hour, p5, p25, p50, p75, p95 } = entry;

      if (!result[hour]) {
        result[hour] = {
          count: 0,
          totalP5: 0,
          totalP25: 0,
          totalP50: 0,
          totalP75: 0,
          totalP95: 0,
        };
      }

      result[hour].count++;
      result[hour].totalP5 += p5;
      result[hour].totalP25 += p25;
      result[hour].totalP50 += p50;
      result[hour].totalP75 += p75;
      result[hour].totalP95 += p95;
    });

    this.data = Object.keys(result).map((hour) => {
      const { count, totalP5, totalP25, totalP50, totalP75, totalP95 } =
        result[hour];
      return {
        hour,
        avgp5: totalP5 / count,
        avgp25: totalP25 / count,
        avgp50: totalP50 / count,
        avgp75: totalP75 / count,
        avgp95: totalP95 / count,
      };
    });

    this.data.sort((a, b) => d3.ascending(a.hour, b.hour));
  }

  // Format the data
  formatData() {
    this.data.forEach((d) => {
      d.avgp5 = +d.avgp5;
      d.avgp25 = +d.avgp25;
      d.avgp50 = +d.avgp50;
      d.avgp75 = +d.avgp75;
      d.avgp95 = +d.avgp95;
    });
  }

  // Draw areas
  drawAreas() {
    this.svg
      .append("path")
      .data([this.data])
      .attr("class", "area")
      .attr("d", this.areaLowToHigh)
      .style("fill", "rgb(223 173 115 / 92%)");

    this.svg
      .append("path")
      .data([this.data])
      .attr("class", "area")
      .attr("d", this.areaVeryLowToVeryHigh)
      .style("fill", "rgb(240 215 183 / 69%)");
  }

  // Draw lines
  drawLines() {
    this.svg
      .append("path")
      .data([this.data])
      .attr("class", "fill-none stroke-[2px]")
      .attr("d", this.lineNormal)
      .style("stroke", "#ce7a35")
      .style("fill", "none")
      .style("stroke-width", 4);
  }

  // Add X and Y axes
  addAxes() {
    const xAxis = d3
      .axisBottom(this.x)
      .tickValues(["00", "03", "06", "09", "12", "15", "18", "21", "23"])
      .tickFormat((d) => this.formatTick(d))
      .tickSize(-this.height)
      .tickSizeInner(6);

    this.svg
      .append("g")
      .attr("class", "x-axis")
      .attr("transform", `translate(0,${this.height})`)
      .call(xAxis)
      .selectAll(".tick line")
      .attr("stroke", "#ccc")
      .attr("stroke-width", "1px");

    this.svg
      .append("g")
      .attr("class", "y-axis")
      .call(d3.axisLeft(this.y).tickValues([0, 54, 70, 180, 250, 350]));
  }

  // Add X and Y gridlines
  addGridlines() {
    const xGrid = d3
      .axisBottom(this.x)
      .tickValues(["00", "03", "06", "09", "12", "15", "18", "21", "23"])
      .tickSize(-this.height)
      .tickFormat("");

    this.svg
      .append("g")
      .attr("class", "grid")
      .attr("transform", `translate(0,${this.height})`)
      .call(xGrid)
      .selectAll(".tick line")
      .attr("stroke", "#ddd")
      .attr("stroke-width", "1px");

    this.svg
      .append("g")
      .attr("class", "grid")
      .call(d3.axisLeft(this.y).tickSize(-this.width).tickFormat(""));
  }

  // Add reference areas
  addReferenceAreas() {
    const referenceArea = d3
      .area()
      .x((d) => this.x(d.hour) + this.x.bandwidth() / 2)
      .y0((d) => this.y(70))
      .y1((d) => this.y(180))
      .curve(d3.curveCatmullRom);

    const referenceArea2 = d3
      .area()
      .x((d) => this.x(d.hour) + this.x.bandwidth() / 2)
      .y0((d) => this.y(180))
      .y1((d) => this.y(250))
      .curve(d3.curveCatmullRom);

    this.svg
      .append("path")
      .data([this.data])
      .attr("class", "opacity-30")
      .attr("d", referenceArea)
      .style("fill", "#00800085");

    this.svg
      .append("path")
      .data([this.data])
      .attr("class", "opacity-30")
      .attr("d", referenceArea2)
      .style("fill", "#ffa5004f");
  }

  // Add reference labels
  addReferenceLabels() {
    this.svg
      .append("text")
      .attr("x", -30)
      .attr("y", this.y(70) - 70)
      .attr("class", "font-normal text-xs")
      .text("Target")
      .style("font-weight", "bold")
      .style("text-anchor", "middle");

    this.svg
      .append("text")
      .attr("x", -30)
      .attr("y", this.y(70) - 50)
      .attr("class", "font-normal text-xs")
      .text("Range")
      .style("font-weight", "bold")
      .style("text-anchor", "middle");

    const yValues = [5, 25, 50, 75, 95];
    yValues.forEach((val, index) => {
      const yPos = this.y(this.data["23"][`avgp${val}`]);
      const arrowStartX = this.width - 15; // Start at the Y-axis
      const arrowMidX = this.width - 5; // Middle point for the sloped arrow
      const arrowEndX = this.width + 5; // End for horizontal arrow
      const labelX = this.width + 7; // X position for labels
      let slopedYPos;

      // Alternate the direction based on index
      if (index % 5 === 0) {
        slopedYPos = yPos;
      } else if (index % 5 === 1) {
        slopedYPos = yPos + 5;
      } else if (index % 5 === 2) {
        slopedYPos = yPos;
      } else if (index % 5 === 3) {
        slopedYPos = yPos - 15;
      } else if (index % 5 === 4) {
        slopedYPos = yPos - 25;
      }

      // Draw sloped arrow (diagonal part)
      this.svg
        .append("line")
        .attr("x1", arrowStartX)
        .attr("x2", arrowMidX)
        .attr("y1", yPos)
        .attr("y2", slopedYPos)
        .attr("stroke", "#d3d3d3")
        .attr("stroke-width", 2);

      // Draw horizontal arrow (straight line after the slope) without arrowhead
      this.svg
        .append("line")
        .attr("x1", arrowMidX)
        .attr("x2", arrowEndX)
        .attr("y1", slopedYPos)
        .attr("y2", slopedYPos)
        .attr("stroke", "#d3d3d3")
        .attr("stroke-width", 2);

      // Add label at the end of the horizontal arrow
      this.svg
        .append("text")
        .attr("x", labelX)
        .attr("y", slopedYPos + 5)
        .attr("class", "font-normal text-[11px]")
        .text(`${val}%`)
        .style("font-weight", "bold")
        .style("text-anchor", "start");
    });
  }

  // Format tick values
  formatTick(d) {
    if (d === "00") return "12AM";
    if (d === "12") return "12PM";
    return d > "12" ? `${+d - 12}PM` : `${+d}AM`;
  }
}

class DGPChartD3Aide {
  constructor(result, options = {}) {
    this.data;
    this.selector;
    this.index;
    this.result = result;

    // Default configuration options (can be overridden)
    this.margin = options.margin || {
      top: 30,
      right: 30,
      bottom: 35,
      left: 80,
    };
    this.width = options.width || 800;
    this.height = options.height || 150;

    // Set up scales and parsers
    this.parseDate;
    this.formatDayOfWeek;
    this.x = null;
    this.y = null;

    this.referenceGlucoseLevels = [70, 180];

    // Preprocess the data
    this.first12AM;
    this.loadGlucoseData();
  }

  loadGlucoseData() {

    let originalData = this.result.daily_glucose_profile;
    const transformedData = originalData.map((entry) => ({
      datetime: `${entry.date}T${entry.hour.padStart(2, "0")}:00:00`,
      glucose: entry.glucose,
    }));

    const dgpEndDate = new Date(
      transformedData[transformedData.length - 1].datetime
    );
    let dgpStartDate = new Date(dgpEndDate);

    // Subtract 14 days (13 + 1 day) from dgpEndDate to get the start date for the last 14 days
    dgpStartDate.setDate(dgpEndDate.getDate() - 13);

    const timeSeries = this.generateTimeSeries(dgpStartDate, dgpEndDate);
    const dataMap = new Map(
      transformedData.map((d) => [
        this.formatDateToMatch(new Date(d.datetime)),
        d.glucose,
      ])
    );

    const completeData = timeSeries.map((d) => {
      const formattedDate = this.formatDateToMatch(d);
      const glucoseValue = dataMap.get(formattedDate);
      return {
        datetime: formattedDate,
        glucose: glucoseValue === undefined ? null : glucoseValue,
      };
    });

    const weeks = this.divideDatesIntoWeeks(
      completeData[0].datetime,
      dgpEndDate,
      completeData
    );

    this.drawChart(weeks[0].data, "#dgp-wk", 0);
    this.drawChart(weeks[1].data, "#dgp-wk", 1);

  }

  preprocessData() {
    this.data.forEach((d) => {
      d.datetime = this.parseDate(d.datetime);
      d.glucose = +d.glucose;
    });
  }
  formatDateToMatch(date) {
    return date.toISOString().slice(0, 19);
  }
  generateTimeSeries(start, end) {
    const times = [];
    let current = start;
    while (current <= end) {
      times.push(new Date(current));
      current.setHours(current.getHours() + 1);
    }
    return times;
  }

  initializeScales() {
    this.x = d3
      .scaleUtc()
      .domain([this.first12AM, d3.max(this.data, (d) => d.datetime)])
      .range([0, this.width]);

    this.y = d3.scaleLinear().domain([0, 400]).nice().range([this.height, 0]);
  }

  drawSVG() {
    // Remove any existing SVG elements
    d3.select(this.selector).selectAll("svg").remove();

    // Create the SVG container
    const svg = d3
      .select(this.selector + (this.index + 1))
      .attr(
        "viewBox",
        `0 0 ${this.width + this.margin.left + this.margin.right} ${this.height + this.margin.top + this.margin.bottom
        }`
      )
      .attr("preserveAspectRatio", "xMidYMid meet")
      .classed("svg-content-responsive", true)
      .append("g")
      .attr("transform", `translate(${this.margin.left},${this.margin.top})`);

    return svg;
  }

  drawAxes(svg) {
    // Define Y axis with reference glucose levels
    const yAxis = d3
      .axisLeft(this.y)
      .tickValues(this.referenceGlucoseLevels)
      .tickFormat((d) => (this.referenceGlucoseLevels.includes(d) ? d : ""));

    const yAxisGroup = svg.append("g").attr("class", "axis y-axis").call(yAxis);

    yAxisGroup.select(".domain").style("display", "none");

    svg
      .append("text")
      .attr("class", "mg-dl-label")
      .attr("x", this.height / 2 - 65)
      .attr("y", this.margin.left - 10)
      .text("mg/dL");
  }

  drawLines(svg) {
    const twelveAMs = Array.from(
      new Set(
        this.data
          .map((d) =>
            d.datetime ? new Date(d.datetime).toISOString().split("T")[0] : null
          )
          .filter((dateStr) => dateStr !== null)
      )
    ).map((dateStr) => this.parseDate(dateStr + "T00:00:00"));

    const twelvePMs = Array.from(
      new Set(
        this.data.map((d) =>
          d.datetime ? new Date(d.datetime).toISOString().split("T")[0] : null
        )
      )
    ).map((dateStr) => this.parseDate(dateStr + "T12:00:00"));

    svg
      .selectAll(".vertical-line-am")
      .data(twelveAMs)
      .enter()
      .append("line")
      .attr("class", "vertical-line")
      .attr("x1", (d) => this.x(d))
      .attr("x2", (d) => this.x(d))
      .attr("y1", 0)
      .attr("y2", this.height);

    svg
      .selectAll(".vertical-line-pm")
      .data(twelvePMs)
      .enter()
      .append("line")
      .attr("class", "vertical-line")
      .attr("x1", (d) => this.x(d))
      .attr("x2", (d) => this.x(d))
      .attr("y1", 0)
      .attr("y2", this.height);

    svg
      .selectAll(".label-date")
      .data(twelveAMs)
      .enter()
      .append("text")
      .attr("class", "label-date")
      .attr("x", (d) => this.x(d) + 5)
      .attr("y", 10)
      .text((d) => new Date(d).getDate())
      .style("font-size", "10px")
      .style("text-anchor", "start");

    if (this.index == 0) {
      svg
        .selectAll(".label-12pm")
        .data(twelvePMs)
        .enter()
        .append("text")
        .attr("class", "day-label")
        .attr("x", (d) => {
          let xPos = this.x(d);
          const usableWidth = this.width - this.margin.left - this.margin.right;
          const scaledXPos =
            this.margin.left + (xPos / this.width) * usableWidth;
          return scaledXPos;
        })
        .attr("y", this.height + 30)
        .attr("text-anchor", "middle")
        .text("12 pm");

      // Add day labels at the top
      const days = Array.from(
        new Set(
          this.data.map((d) =>
            d.datetime ? new Date(d.datetime).toISOString().split("T")[0] : null
          )
        )
      );
      const dayLabels = days.map((dateStr) => ({
        date: this.parseDate(dateStr + "T12:00:00"),
        label: this.formatDayOfWeek(this.parseDate(dateStr + "T12:00:00")),
      }));

      svg
        .selectAll(".day-label-top")
        .data(dayLabels)
        .enter()
        .append("text")
        .attr("class", "day-label-top")
        .attr("x", (d) => {
          let xPos = this.x(d.date);

          // Calculate the usable width (total width minus left and right margins)
          const usableWidth = this.width - this.margin.left - this.margin.right;

          // Scale the x position relative to the usable width
          const scaledXPos =
            this.margin.left + (xPos / this.width) * usableWidth;

          return scaledXPos;
        })
        .attr("y", -10)
        .text((d) => d.label);
    }
  }
  divideDatesIntoWeeks(startDate, endDate, data) {
    const weeks = [];
    let currentWeekStart = new Date(startDate);

    while (currentWeekStart <= endDate) {
      const currentWeekEnd = new Date(currentWeekStart);
      currentWeekEnd.setDate(currentWeekStart.getDate() + 6);
      const weekData = data.filter((entry) => {
        const entryDate = new Date(entry.datetime);
        return entryDate >= currentWeekStart && entryDate <= currentWeekEnd;
      });

      weeks.push({
        start: new Date(currentWeekStart),
        end: new Date(currentWeekEnd),
        data: weekData,
      });

      currentWeekStart.setDate(currentWeekStart.getDate() + 7);
    }
    return weeks;
  }

  drawGlucoseLines(svg) {
    const line = d3
      .line()
      .x((d) => this.x(new Date(d.datetime)))
      .y((d) => this.y(d.glucose))
      .defined((d) => d.glucose !== 0)
      .curve(d3.curveBasis);

    // Draw the glucose lines
    svg.append("path").datum(this.data).attr("class", "line").attr("d", line);

    svg
      .append("path")
      .datum(this.data)
      .attr("class", "highlight-glucose-l-line")
      .attr("d", line)
      // .style("fill", "rgb(210,131, 107)")
      .style("opacity", 1)
      .attr("clip-path", "url(#clip-below-70)");

    svg
      .append("path")
      .datum(this.data)
      .attr("class", "highlight-line")
      .attr("d", line)
      .attr("clip-path", "url(#clip)");

    svg
      .append("path")
      .datum(this.data)
      .attr("class", "highlight-glucose-h-line")
      .attr("d", line)
      // .style("fill", "rgb(237, 204, 134)")
      .style("opacity", 1)
      .attr("clip-path", "url(#clip-above-180)");

    // Draw horizontal lines
    svg
      .append("line")
      .attr("class", "horizontal-line")
      .attr("x1", 0)
      .attr("x2", this.width)
      .attr("y1", 0)
      .attr("y2", 0);

    svg
      .append("line")
      .attr("class", "horizontal-line")
      .attr("x1", 0)
      .attr("x2", this.width)
      .attr("y1", this.height)
      .attr("y2", this.height);
  }

  drawHighlightAreas(svg) {
    const firstDay = new Date(
      d3
        .min(
          this.data.filter((d) => d.datetime),
          (d) => d.datetime
        )
        ?.toISOString()
        .split("T")[0]
    );
    // const first12AM = new Date(firstDay);
    // first12AM.setUTCHours(0, 0, 0, 0);

    // const referenceGlucoseLevels = [70, 180];

    // Draw highlighted areas
    svg
      .append("rect")
      .attr("class", "highlight-area-below")
      .attr("x", this.x(this.first12AM))
      .attr("y", this.y(this.referenceGlucoseLevels[1]))
      .attr(
        "width",
        this.x(d3.max(this.data, (d) => d.datetime)) - this.x(this.first12AM)
      )
      .attr(
        "height",
        this.y(this.referenceGlucoseLevels[0]) -
        this.y(this.referenceGlucoseLevels[1])
      )
      .style("fill", "rgba(223, 223, 223, 1)")
      .style("opacity", 1);
  }

  drawReferenceLines(svg) {
    // Draw reference lines
    svg
      .selectAll(".reference-line")
      .data(this.referenceGlucoseLevels)
      .enter()
      .append("line")
      .attr("class", "reference-line")
      .attr("x1", 0)
      .attr("x2", this.width)
      .attr("y1", (d) => this.y(d))
      .attr("y2", (d) => this.y(d));
  }

  drawClipPaths(svg) {
    svg
      .append("clipPath")
      .attr("id", "clip")
      .append("rect")
      .attr("x", this.x(this.first12AM))
      .attr("y", this.y(this.referenceGlucoseLevels[1]))
      .attr(
        "width",
        this.x(d3.max(this.data, (d) => d.datetime)) - this.x(this.first12AM)
      )
      .attr(
        "height",
        this.y(this.referenceGlucoseLevels[0]) -
        this.y(this.referenceGlucoseLevels[1])
      );

    svg
      .append("clipPath")
      .attr("id", "clip-above-180")
      .append("rect")
      .attr("x", this.x(this.first12AM))
      .attr("y", 0)
      .attr(
        "width",
        this.x(d3.max(this.data, (d) => d.datetime)) - this.x(this.first12AM)
      )
      .attr("height", this.y(this.referenceGlucoseLevels[1]) - 0);

    svg
      .append("clipPath")
      .attr("id", "clip-below-70")
      .append("rect")
      .attr("x", this.x(this.first12AM))
      .attr("y", this.y(this.referenceGlucoseLevels[0]))
      .attr(
        "width",
        this.x(d3.max(this.data, (d) => d.datetime)) - this.x(this.first12AM)
      )
      .attr("height", this.height - this.y(this.referenceGlucoseLevels[0]));
  }

  drawChart(data, selector, index) {
    this.data = data;
    this.selector = selector;
    this.index = index;
    this.parseDate = d3.utcParse("%Y-%m-%dT%H:%M:%S");
    this.formatDayOfWeek = d3.timeFormat("%A");
    this.preprocessData();
    const firstDay = new Date(
      d3
        .min(
          this.data.filter((d) => d.datetime),
          (d) => d.datetime
        )
        ?.toISOString()
        .split("T")[0]
    );
    this.first12AM = new Date(firstDay);
    this.first12AM.setUTCHours(0, 0, 0, 0);
    this.initializeScales();
    const svg = this.drawSVG();
    this.drawAxes(svg);
    this.drawLines(svg);
    this.drawReferenceLines(svg);
    this.drawHighlightAreas(svg);
    this.drawClipPaths(svg);
    this.drawGlucoseLines(svg);
  }
}

class GRIChartD3Aide {
  constructor(selector, data, error, bgImage = "/grigrid.png") {
    this.selector = selector;
    this.data = data;
    this.error = error;
    this.bgImage = bgImage;
    this.width = 150;
    this.height = 150;
    this.margin = { top: 20, right: 0, bottom: 10, left: 30 };
  }

  createSVG() {
    return d3
      .selectAll(this.selector)
      .attr(
        "viewBox",
        `0 0 ${this.width + this.margin.left} ${this.height + this.margin.bottom + this.margin.top
        }`
      )
      .attr("preserveAspectRatio", "xMidYMid meet")
      .attr("width", "60%")
      .attr("height", "60%")
      .append("g")
      .attr("transform", `translate(${this.margin.left},${this.margin.top})`);
  }

  createScales() {
    this.xScale = d3
      .scaleLinear()
      .domain([0, 30])
      .range([0, this.width / 1.2]);
    this.yScale = d3
      .scaleLinear()
      .domain([0, 60])
      .range([this.height / 1.2, 0]);
  }

  createAxes(svg) {
    const referencex = [0, 5, 10, 15, 20, 25, 30];
    const referencey = [0, 10, 20, 30, 40, 50, 60];
    const xAxis = d3.axisBottom(this.xScale).tickSize(0).tickValues(referencex);
    const yAxis = d3.axisLeft(this.yScale).tickSize(0).tickValues(referencey);

    svg
      .append("image")
      .attr("x", 0)
      .attr("y", 0)
      .attr("height", "125px")
      .attr("width", "125px")
      .attr("xlink:href", this.bgImage);

    svg
      .append("g")
      .attr("transform", `translate(-0.2,${this.height / 1.2 - 0.5})`)
      .attr("class", "axis")
      .call(xAxis)
      .selectAll("text")
      .style("font-size", "3px");

    svg
      .append("g")
      .attr("transform", `translate(-0.2,-0.2)`)
      .call(yAxis)
      .attr("class", "axis")
      .selectAll("text")
      .style("font-size", "3px");

    svg.selectAll(".axis path").attr("stroke-width", 0.5);
  }

  drawLines(svg) {
    svg
      .append("line")
      .attr("x1", 0)
      .attr("y1", 0)
      .attr("x2", this.width / 1.2)
      .attr("y2", 0)
      .attr("stroke", "black")
      .attr("stroke-width", 0.5);

    svg
      .append("line")
      .attr("x1", this.width / 1.2)
      .attr("y1", 0)
      .attr("y2", this.height / 1.2)
      .attr("x2", this.width / 1.2)
      .attr("stroke", "black")
      .attr("stroke-width", 0.5);
  }

  drawZones(svg) {
    const pointsGreen = [
      [0, 0],
      [10, 0],
      [0, 20],
    ];
    const pointsYellow = [
      [0, 20],
      [20, 0],
      [40, 0],
      [0, 40],
    ];
    const pointsOrange = [
      [0, 40],
      [40, 0],
      [60, 0],
      [0, 60],
    ];
    const pointsRed = [
      [0, 60],
      [60, 0],
      [80, 0],
      [0, 80],
    ];
    const pointsDarkred = [
      [0, 80],
      [80, 0],
      [100, 0],
      [0, 100],
    ];

    const zones = [
      { name: "Zone A (0-20)", color: "#79BF7A", points: pointsGreen },
      { name: "Zone B (21-40)", color: "#F6F27E", points: pointsYellow },
      { name: "Zone C (41-60)", color: "#FFD079", points: pointsOrange },
      { name: "Zone D (61-80)", color: "#F2787A", points: pointsRed },
      { name: "Zone E (81-100)", color: "#CF9390", points: pointsDarkred },
    ];

    // Add zone polygons
    zones.forEach((zone) => {
      svg
        .append("polygon")
        .attr(
          "points",
          zone.points
            .map((d) => [this.xScale(d[0]), this.yScale(d[1])].join(","))
            .join(" ")
        )
        .attr("fill", zone.color);
    });
  }

  drawLegend(svg) {
    const zones = [
      { name: "Zone A (0-20)", color: "#79BF7A" },
      { name: "Zone B (21-40)", color: "#F6F27E" },
      { name: "Zone C (41-60)", color: "#FFD079" },
      { name: "Zone D (61-80)", color: "#F2787A" },
      { name: "Zone E (81-100)", color: "#CF9390" },
    ];

    const legend = svg
      .append("g")
      .attr("transform", `translate(${this.width - 65}, 5)`);

    legend
      .append("rect")
      .attr("x", -2.5)
      .attr("y", -1)
      .attr("width", 35)
      .attr("height", zones.length * 5 + 5)
      .attr("fill", "white")
      .attr("stroke", "black")
      .attr("stroke-width", 0.2);

    zones.forEach((zone, i) => {
      const legendRow = legend
        .append("g")
        .attr("transform", `translate(0, ${i * 5 + 2.5})`);

      legendRow
        .append("rect")
        .attr("width", 2.5)
        .attr("height", 2.5)
        .attr("fill", zone.color);

      legendRow
        .append("text")
        .attr("x", 5)
        .attr("y", 2)
        .style("font-size", "3px")
        .text(zone.name);
    });
  }

  drawReferencePoint(svg) {
    svg
      .append("circle")
      .attr("cx", this.xScale(this.data.Hypoglycemia_Component))
      .attr("cy", this.yScale(this.data.Hyperglycemia_Component))
      .attr("r", 1.5)
      .attr("fill", "blue")
      .attr("stroke", "black")
      .attr("stroke-width", 0);
  }

  drawLabels(svg) {
    svg
      .append("text")
      .attr("x", this.width / 2.5)
      .attr("y", this.height / 1.2 + this.margin.bottom + 8)
      .attr("text-anchor", "middle")
      .style("font-size", "4px")
      .text("Hypoglycemia Component (%)");

    svg
      .append("text")
      .attr("x", -this.height / 2)
      .attr("y", -this.margin.left + 15)
      .attr("transform", "rotate(-90)")
      .attr("text-anchor", "middle")
      .style("font-size", "4px")
      .text("Hyperglycemia Component (%)");
  }

  render() {
    const svg = this.createSVG();
    this.createScales();
    this.createAxes(svg);
    this.drawLines(svg);
    //this.drawZones(svg);
    this.drawLegend(svg);
    this.drawReferencePoint(svg);
    this.drawLabels(svg);
  }
}
