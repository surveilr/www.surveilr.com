// Define the path for the output CSV file
const outputFilePath =
  "./detrended-fluctation-analysis/S1/detrended-fluctation-analysis-csv-dataset/supporting-files/cgm_file_metadata.csv";

// Function to generate CGM metadata
const generateCgmMetadata = async (numRecords: number) => {
  const csvHeader =
    "metadata_id,devicename,device_id,source_platform,patient_id,file_name,file_format,file_upload_date,data_start_date,data_end_date,study_id\n";
  let csvContent = csvHeader;

  for (let i = 1; i <= numRecords; i++) {
    const metadataId = `MD-${String(i).padStart(3, "0")}`; // Format as MD-001, MD-002, ...
    const devicename = `Medtronic MiniMed`;
    const patientId = `${i}`; // Patient ID as 1, 2, ...
    const fileName = `case ${i}`; // File name as case 1, case 2, ...

    // Create a CSV line with the specified structure
    const csvLine =
      `${metadataId},${devicename},,,"${patientId}",${fileName},csv,,,,DFA\n`;
    csvContent += csvLine;
  }

  // Write the CSV content to a file
  await Deno.writeTextFile(outputFilePath, csvContent.trim());
  console.log(`CSV file generated at: ${outputFilePath}`);
};

// Generate 209 records
await generateCgmMetadata(209);
