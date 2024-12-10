async function initializeAgpChart(participant_id, start_date, end_date) {
  const margin = { top: 20, right: 30, bottom: 40, left: 60 };
  const width = 800 - margin.left - margin.right;
  const height = 500 - margin.top - margin.bottom;

  const response = await fetch(
    `/drh/api/ambulatory-glucose-profile/?participant_id=${participant_id}&start_date=${start_date}&end_date=${end_date}`,
  );

  // Check if the request was successful
  if (!response.ok) {
    throw new Error(
      "Network response was not ok " + response.statusText,
    );
  }
  const result = await response.json();
  const agpChart = document.querySelector('agp-chart');
  if (
    result.ambulatoryGlucoseProfile &&
    Object.keys(result.ambulatoryGlucoseProfile).length > 0
  ) {
    const data = result.ambulatoryGlucoseProfile;

    agpChart.data = data;
    agpChart.width = width;
    agpChart.height = height;
  } else {
    agpChart.noDataFound = true;
  }
}

async function initializeStackedBarChart(participant_id, start_date, end_date) {
  const response = await fetch(
    `/drh/api/time_range_stacked_metrics/?participant_id=${participant_id}&start_date=${start_date}&end_date=${end_date}`,
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

  const barChart = document.querySelector('stacked-bar-chart');
  if(timeMetrics.participant_id) {
    barChart.data = chartdata;
    barChart.chartWidth = chartWidth;
    barChart.chartHeight = chartHeight;
  } else {
    barChart.noDataFound = true;
  }
  
}



async function initializeDgpChart(participant_id, start_date, end_date) {
  await new Promise((resolve) => setTimeout(resolve, 3000)); // Add a 3-second delay

  const response = await fetch(
    `/drh/api/daily-glcuose-profile/?participant_id=${participant_id}&start_date=${start_date}&end_date=${end_date}`,
  );

  // Check if the request was successful
  if (!response.ok) {
    throw new Error(
      "Network response was not ok " + response.statusText,
    );
  }
  const result = await response.json();
  const dgpChart = document.querySelector('dgp-chart');

  if (result.daily_glucose_profile.length > 0) {
    dgpChart.result = result.daily_glucose_profile;
  } else {
    dgpChart.noDataFound = true;
  }
}

async function initializeDriChart(participant_id, start_date, end_date) {
  const response = await fetch(
    `/drh/api/glycemic_risk_indicator/?participant_id=${participant_id}&start_date=${start_date}&end_date=${end_date}`,
  );

  // Check if the request was successful
  if (!response.ok) {
    throw new Error(
      "Network response was not ok " + response.statusText,
    );
  }
  const result = await response.json();
  const griData = result.glycemicRiskIndicator;


  const griChart = document.querySelector('gri-chart');
  if(griData.GRI) {
    griChart.data = griData;
  } else {
    griChart.noDataFound = true;
  }
  

  assignValues(document.getElementsByClassName("TIR"), griData.time_in_range_percentage);
  assignValues(document.getElementsByClassName("TAR_VH"), griData.time_above_VH_percentage);
  assignValues(document.getElementsByClassName("TAR_H"), griData.time_above_H_percentage);
  assignValues(document.getElementsByClassName("TBR_L"), griData.time_below_low_percentage);
  assignValues(document.getElementsByClassName("TBR_VL"), griData.time_below_VL_percentage);
  assignValues(document.getElementsByClassName("GRI"), griData.GRI);

}

async function initializeAdvanceMetrics(participant_id, start_date, end_date) {
  const response = await fetch(
    `/drh/api/advanced_metrics/?participant_id=${participant_id}&start_date=${start_date}&end_date=${end_date}`,
  );

  // Check if the request was successful
  if (!response.ok) {
    throw new Error(
      "Network response was not ok " + response.statusText,
    );
  }
  const result = await response.json();

  const griData = result.advancedMetrics;
  assignValues(document.getElementsByClassName("timeInTightRangeCdata"), griData.time_in_tight_range_percentage);

}

function assignValues(containers, value) {
  for (const container of containers) {
    container.innerHTML = value;
  }
}

function getValue(containers) {
  for (const container of containers) {
    return container.value;
  }
}

document.addEventListener("DOMContentLoaded", function () {
  for (const container of document.getElementsByClassName("participant_id")) {
    const participant_id = container.value;
    const start_date = getValue(document.getElementsByClassName("start_date"));
    const end_date = getValue(document.getElementsByClassName("end_date"));
    initializeStackedBarChart(participant_id, start_date, end_date);
    initializeAgpChart(participant_id, start_date, end_date);
    initializeDgpChart(participant_id, start_date, end_date);
    initializeDriChart(participant_id, start_date, end_date);
    initializeAdvanceMetrics(participant_id, start_date, end_date);
  }
});
