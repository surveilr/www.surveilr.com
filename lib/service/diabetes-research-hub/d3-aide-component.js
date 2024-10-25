async function initializeAgpChart(participant_id) {
    const margin = { top: 20, right: 30, bottom: 40, left: 60 };
    const width = 800 - margin.left - margin.right;
    const height = 500 - margin.top - margin.bottom;
  
    const response = await fetch(
      `/drh/api/ambulatory-glucose-profile/?participant_id=${participant_id}`,
    );
  
    // Check if the request was successful
    if (!response.ok) {
      throw new Error(
        "Network response was not ok " + response.statusText,
      );
    }
    const result = await response.json();
  
    if (
      result.ambulatoryGlucoseProfile &&
      Object.keys(result.ambulatoryGlucoseProfile).length > 0
    ) {
      const data = result.ambulatoryGlucoseProfile;
  
      const chart = new AGPChartD3Aide(
        "svg#agp-chart",
        data,
        width,
        height,
        margin,
      );
    }
  }
  
  async function initializeStackedBarChart(participant_id) {
    const response = await fetch(
      `/drh/api/time_range_stacked_metrics/?participant_id=${participant_id}`,
    );
  
    // Check if the request was successful
    if (!response.ok) {
      throw new Error(
        "Network response was not ok " + response.statusText,
      );
    }
    const result = await response.json();
    const timeMetrics = result.timeMetrics;
  
    const chartHeight = 400;
    const chartWidth = 700;
  
    const chartdata = [
      {
        category: "Very Low",
        value: timeMetrics.timeBelowRangeVeryLow,
        goal: "<1%",
        color: "#A93226",
      },
      {
        category: "Low",
        value: timeMetrics.timeBelowRangeLow,
        goal: "<4%",
        color: "#E74C3C",
      },
      {
        category: "Target",
        value: timeMetrics.timeInRange,
        goal: "≥70%",
        color: "#27AE60",
      },
      {
        category: "High",
        value: timeMetrics.timeAboveRangeHigh,
        goal: "<25%",
        color: "#F39C12",
      },
      {
        category: "Very High",
        value: timeMetrics.timeAboveRangeVeryHigh,
        goal: "<5%",
        color: "#D35400",
      },
    ];
  
    const chart = new StackedBarChartD3Aide(
      ".chartContainer",
      chartdata,
      chartWidth,
      chartHeight,
      false,
      false,
    );
  }
  
  function divideDatesIntoWeeks(startDate, endDate, data) {
    const weeks = [];
    let currentWeekStart = new Date(startDate);
  
    while (currentWeekStart <= endDate) {
      const currentWeekEnd = new Date(currentWeekStart);
      currentWeekEnd.setDate(currentWeekStart.getDate() + 6);
      const weekData = data.filter((entry) => {
        const entryDate = new Date(entry.datetime);
        return (
          entryDate >= currentWeekStart && entryDate <= currentWeekEnd
        );
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
  
  function generateTimeSeries(start, end) {
    const times = [];
    let current = start;
    while (current <= end) {
      times.push(new Date(current));
      current.setHours(current.getHours() + 1);
    }
    return times;
  }
  
  function formatDateToMatch(date) {
    return date.toISOString().slice(0, 19);
  }
  
  async function initializeDgpChart(participant_id) {
    await new Promise((resolve) => setTimeout(resolve, 3000)); // Add a 3-second delay
  
    const response = await fetch(
      `/drh/api/daily-glcuose-profile/?participant_id=${participant_id}`,
    );
  
    // Check if the request was successful
    if (!response.ok) {
      throw new Error(
        "Network response was not ok " + response.statusText,
      );
    }
    const result = await response.json();
  
    if (result.daily_glucose_profile.length > 0) {
        const chart = new DGPChartD3Aide(result);
    }
  }
  
  async function initializeDriChart(participant_id) {
    const response = await fetch(
      `/drh/api/glycemic_risk_indicator/?participant_id=${participant_id}`,
    );
  
    // Check if the request was successful
    if (!response.ok) {
      throw new Error(
        "Network response was not ok " + response.statusText,
      );
    }
    const result = await response.json();
    const griData = result.glycemicRiskIndicator;
    const bgImage = "https://app.devl.drh.diabetestechnology.org/grigrid.png";
  
    const error = false;
    const chart = new GRIChartD3Aide(".gri-chart", griData, error,bgImage);
    chart.render();
  
    assignValues(document.getElementsByClassName("TIR"),griData.time_in_range_percentage);
    assignValues(document.getElementsByClassName("TAR_VH"),griData.time_above_VH_percentage);
    assignValues(document.getElementsByClassName("TAR_H"),griData.time_above_H_percentage);
    assignValues(document.getElementsByClassName("TBR_L"),griData.time_below_low_percentage);
    assignValues(document.getElementsByClassName("TBR_VL"),griData.time_below_VL_percentage);
    assignValues(document.getElementsByClassName("GRI"),griData.GRI);
    
  }
  
  async function initializeAdvanceMetrics(participant_id) {
    const response = await fetch(
      `/drh/api/advanced_metrics/?participant_id=${participant_id}`,
    );
  
    // Check if the request was successful
    if (!response.ok) {
      throw new Error(
        "Network response was not ok " + response.statusText,
      );
    }
    const result = await response.json();
  
    const griData = result.advancedMetrics;
    assignValues(document.getElementsByClassName("timeInTightRangeCdata"),griData.time_in_tight_range_percentage);
  
  }
  
  function assignValues(containers,value){
    for (const container of containers) {
      container.innerHTML = value;    
    }
  }
  
  document.addEventListener("DOMContentLoaded", function () {
    for (const container of document.getElementsByClassName("participant_id")) {
      const participant_id = container.value;
      initializeStackedBarChart(participant_id);
      initializeAgpChart(participant_id);
      initializeDgpChart(participant_id);
      initializeDriChart(participant_id);
      initializeAdvanceMetrics(participant_id);
    }
  });
  