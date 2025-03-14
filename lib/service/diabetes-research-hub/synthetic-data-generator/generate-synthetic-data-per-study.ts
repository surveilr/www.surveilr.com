import { Database } from "https://deno.land/x/sqlite3@0.12.0/mod.ts";
import { ulid } from "https://deno.land/x/ulid/mod.ts";

// Initialize database
const db = new Database("resource-surveillance.sqlite.db");

// Function to get user input
const promptUser = (question: string): string => {
  const input = prompt(question);
  if (!input) {
    console.error("Input cannot be empty.");
    return promptUser(question); // Keep asking until a valid input is provided
  }
  return input;
};


// List of valid investigator names
const investigatorNames = [
  "Dr. John Smith",
  "Dr. Emily Johnson",
  "Dr. Michael Brown",
  "Dr. Sarah Davis",
  "Dr. William Miller",
  "Dr. Olivia Wilson",
  "Dr. James Moore",
  "Dr. Sophia Taylor",
];

// Function to create tables if they do not exist
const createTables = () => {
  console.log("Creating tables if they do not exist...");
  db.exec(`

    -- party definition

    CREATE TABLE "party" (
        "party_id" VARCHAR PRIMARY KEY NOT NULL,
        "party_type_id" ULID NOT NULL,
        "party_name" TEXT NOT NULL,
        "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
        "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        "created_by" TEXT DEFAULT 'UNKNOWN',
        "updated_at" TIMESTAMPTZ,
        "updated_by" TEXT,
        "deleted_at" TIMESTAMPTZ,
        "deleted_by" TEXT,
        "activity_log" TEXT
    );

    -- party_type definition

    CREATE TABLE "party_type" (
        "party_type_id" ULID PRIMARY KEY NOT NULL,
        "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
        "value" TEXT NOT NULL,
        "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        "created_by" TEXT DEFAULT 'UNKNOWN',
        "updated_at" TIMESTAMPTZ,
        "updated_by" TEXT,
        "deleted_at" TIMESTAMPTZ,
        "deleted_by" TEXT,
        "activity_log" TEXT,
        UNIQUE("code")
    );

      INSERT INTO party_type 
      (party_type_id, code, value, created_at, created_by, updated_at, updated_by, deleted_at, deleted_by, activity_log) 
      VALUES 
      ('01JP7GCMDK7GVTBQPJJV9G7XRS', 'ORGANIZATION', 'Organization', CURRENT_TIMESTAMP, 'UNKNOWN', NULL, NULL, NULL, NULL, ''),
      ('01JP7GCMDK9E63DJA6P56TY519', 'PERSON', 'Person', CURRENT_TIMESTAMP, 'UNKNOWN', NULL, NULL, NULL, NULL, '')
      ON CONFLICT (party_type_id) DO NOTHING;



    CREATE TABLE IF NOT EXISTS uniform_resource_study (
      study_id TEXT PRIMARY KEY,
      study_name TEXT,
      start_date TEXT,
      end_date TEXT,
      treatment_modalities TEXT,
      funding_source TEXT,
      nct_number TEXT,
      study_description TEXT,
      tenant_id TEXT
    );
    
    CREATE TABLE IF NOT EXISTS uniform_resource_publication (
      publication_id TEXT PRIMARY KEY,
      publication_title TEXT,
      digital_object_identifier TEXT,
      publication_site TEXT,
      study_id TEXT,
      tenant_id TEXT
    );
    
    CREATE TABLE IF NOT EXISTS uniform_resource_investigator (
      investigator_id TEXT PRIMARY KEY,
      investigator_name TEXT,
      email TEXT,
      institution_id TEXT,
      study_id TEXT,
      tenant_id TEXT
    );
    
    CREATE TABLE IF NOT EXISTS uniform_resource_author (
      author_id TEXT PRIMARY KEY,
      name TEXT,
      email TEXT,
      investigator_id TEXT,
      study_id TEXT,
      tenant_id TEXT
    );
    
    CREATE TABLE IF NOT EXISTS uniform_resource_cgm_tracing (
      SID TEXT,
      Date_Time TEXT,
      CGM_Value REAL
    );
    
    CREATE TABLE IF NOT EXISTS uniform_resource_cgm_file_metadata (
      metadata_id TEXT,
      devicename TEXT,
      device_id TEXT,
      source_platform TEXT,
      patient_id TEXT,
      file_name TEXT,
      file_format TEXT,
      file_upload_date TEXT,
      data_start_date TEXT,
      data_end_date TEXT,
      study_id TEXT,
      tenant_id TEXT,
      map_field_of_cgm_date TEXT,
      map_field_of_cgm_value TEXT,
      map_field_of_patient_id TEXT
    );

    CREATE TABLE IF NOT EXISTS uniform_resource_institution (
      institution_id TEXT,
      institution_name TEXT,
      city TEXT,
      state TEXT,
      country TEXT,
      tenant_id TEXT
    );

    CREATE TABLE IF NOT EXISTS uniform_resource_lab (
      lab_id TEXT,
      lab_name TEXT,
      lab_pi TEXT,
      institution_id TEXT,
      study_id TEXT,
      tenant_id TEXT
    );

    CREATE TABLE IF NOT EXISTS uniform_resource_participant (
      participant_id TEXT,
      study_id TEXT,
      site_id TEXT,
      diagnosis_icd TEXT,
      med_rxnorm TEXT,
      treatment_modality TEXT,
      gender TEXT,
      race_ethnicity TEXT,
      age TEXT,
      bmi TEXT,
      baseline_hba1c TEXT,
      diabetes_type TEXT,
      study_arm TEXT,
      tenant_id TEXT
    );

    CREATE TABLE IF NOT EXISTS uniform_resource_site (
      study_id TEXT,
      site_id TEXT,
      site_name TEXT,
      site_type TEXT,
      tenant_id TEXT
    );

    CREATE TABLE IF NOT EXISTS uniform_resource_fitness_data (
      fitness_id TEXT PRIMARY KEY,
      participant_id TEXT,
      date TEXT,
      steps INTEGER,
      exercise_minutes INTEGER,
      calories_burned INTEGER
    );

    CREATE TABLE IF NOT EXISTS uniform_resource_meal_data (
      meal_id TEXT PRIMARY KEY,
      participant_id TEXT,
      meal_time TEXT,
      calories INTEGER,
      meal_type TEXT
    );
  `);
  console.log("Tables created successfully.");
};

// Function to generate a tenant_id from the tenant name
const generateTenantId = (tenantName: string) => {
  //return tenantName.replace(/\s+/g, "_").toUpperCase().substring(0, 10);
  return tenantName  
  .replace(/[^a-zA-Z0-9\s]/g, "") // Remove special characters
  .split(/\s+/) // Split by spaces
  .map((word) => word[0]) // Take the first letter of each word
  .join("") // Join them together
  .toUpperCase() // Convert to uppercase
  .substring(0, 4); // Ensure it's only 4 letters
};



// Function to generate a valid DOI
const generateDOI = () => {
  return `10.${Math.floor(Math.random() * 9999)}/study${
    ulid().substring(0, 8)
  }`;
};



// Function to insert an institution and create a corresponding party
const insertInstitution = (institutionName: string, tenantName: string) => {
  const institutionId = ulid(); // Generate a unique institution ID
  const tenantId = generateTenantId(tenantName); // Generate tenant ID from tenant name
  
  // Prompt user for city, state, and country
  const city = promptUser("Enter city:");
  const state = promptUser("Enter state:");
  const country = promptUser("Enter country:");

  // Insert institution into uniform_resource_institution table
  db.prepare(`
    INSERT INTO uniform_resource_institution (institution_id, institution_name, city, state, country, tenant_id)
    VALUES (?, ?, ?, ?, ?, ?)
  `).run(institutionId, institutionName, city, state, country, tenantId);

  console.log(`Institution inserted: ${institutionName} (Tenant ID: ${tenantId})`);

  // Insert into party table using tenantId as party_id
  db.prepare(`
    INSERT INTO party (party_id, party_type_id, party_name, created_at, created_by)
    VALUES (?, ?, ?, CURRENT_TIMESTAMP, 'SYSTEM')
  `).run(tenantId, '01JP7GCMDK7GVTBQPJJV9G7XRS', tenantName);

  console.log(`Party inserted for Tenant ID: ${tenantId}`);

  return tenantId; // Return the generated tenant ID
};


// Function to generate study metadata
const generateStudyMetadata = (
  studyName: string,
  days: number,
  tenantId: string,
) => { 

  const studyId = studyName
  .replace(/[^a-zA-Z0-9\s]/g, "") // Remove special characters
  .split(/\s+/) // Split by spaces
  .map((word) => word[0]) // Take the first letter of each word
  .join("") // Join them together
  .toUpperCase() // Convert to uppercase
  .substring(0, 4); // Ensure it's only 4 letters
  

  console.log(studyId);

  const startDate = new Date().toISOString();
  const endDate = new Date();
  endDate.setDate(endDate.getDate() + days);
  const nctNumber = `NCT${Math.floor(100000 + Math.random() * 900000)}`;
  db.prepare(
    `INSERT INTO uniform_resource_study VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);`,
  )
    .run(
      studyId,
      studyName,
      startDate,
      endDate.toISOString(),
      "Insulin Therapy",
      "NIH",
      nctNumber,
      "Study on diabetes management",
      tenantId,
    );
  console.log(`Study metadata generated for studyId: ${studyId}`);
  return studyId;
};

// Generate random fitness data
const generateFitnessData = (participantId: string, days: number) => {
  let date = new Date();
  for (let i = 0; i < days; i++) {
    const fitnessId = ulid();
    const steps = Math.floor(Math.random() * (15000 - 3000) + 3000);
    const exerciseMinutes = Math.floor(Math.random() * 90);
    const caloriesBurned = Math.floor(Math.random() * (700 - 150) + 150);

    db.prepare(`
      INSERT INTO uniform_resource_fitness_data VALUES (?, ?, ?, ?, ?, ?)
    `).run(
      fitnessId,
      participantId,
      date.toISOString().split("T")[0],
      steps,
      exerciseMinutes,
      caloriesBurned,
    );

    date.setDate(date.getDate() - 1);
  }
  console.log(`Fitness data generated for participantId: ${participantId}`);
};

// Generate random meal data
const generateMealData = (participantId: string, days: number) => {
  let date = new Date();
  const mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"];

  for (let i = 0; i < days; i++) {
    mealTypes.forEach((mealType) => {
      const mealId = ulid();
      const mealTime = new Date(date);
      mealTime.setHours(
        7 + Math.floor(Math.random() * 10),
        Math.floor(Math.random() * 60),
      );
      const calories = Math.floor(Math.random() * (800 - 200) + 200);

      db.prepare(`
        INSERT INTO uniform_resource_meal_data VALUES (?, ?, ?, ?, ?)
      `).run(mealId, participantId, mealTime.toISOString(), calories, mealType);
    });

    date.setDate(date.getDate() - 1);
  }
  console.log(`Meal data generated for participantId: ${participantId}`);
};


// Function to generate synthetic CGM data
const generateCGMData = (sid: string, startDate: Date, days: number) => {
  let date = new Date(startDate);
  for (let i = 0; i < days * 24 * 12; i++) { // 5 min intervals
    const cgmValue = (Math.random() * 80) + 70;

    db.prepare("INSERT INTO uniform_resource_cgm_tracing VALUES (?, ?, ?)")
      .run(sid, date.toISOString(), cgmValue.toFixed(1));
    date.setMinutes(date.getMinutes() + 5);
  }
  console.log(`CGM data generated for SID: ${sid}`);
};

function getRandomDevice() {
  const devices = [
      { device_name: "Freestyle Libre", source_platform: "Abbott" },
      { device_name: "Clarity", source_platform: "Dexcom" },
      { device_name: "Carelink", source_platform: "Medtronic" },
      { device_name: "Tidepool", source_platform: "Tidepool" },
      { device_name: "Dexcom G4", source_platform: "Dexcom" },
      { device_name: "Dexcom G5", source_platform: "Dexcom" },
      { device_name: "Dexcom G6", source_platform: "Dexcom" },
      { device_name: "Dexcom G7", source_platform: "Dexcom" },
      { device_name: "Stelo", source_platform: "Dexcom" },
      { device_name: "FreeStyle Libre 2", source_platform: "Abbott" },
      { device_name: "FreeStyle Libre 3", source_platform: "Abbott" },
      { device_name: "FreeStyle Libre Pro", source_platform: "Abbott" },
      { device_name: "Guardian Connect", source_platform: "Medtronic" },
      { device_name: "Simplera CGM System", source_platform: "Medtronic" },
      { device_name: "Eversense", source_platform: "Senseonics" },
      { device_name: "Eversense XL", source_platform: "Senseonics" },
      { device_name: "Eversense E3", source_platform: "Senseonics" },
      { device_name: "Eversense 365", source_platform: "Senseonics" },
      { device_name: "FreeStyle Navigator", source_platform: "Abbott" },
      { device_name: "Medtronic Paradigm", source_platform: "Medtronic" }
  ];
  return devices[Math.floor(Math.random() * devices.length)];
}


// Store assigned devices per study to ensure consistency
const studyDeviceMap: Record<string, { device_name: string; source_platform: string }> = {};

// Function to get or assign a device for a study
function getStudyDevice(studyId: string) {
  if (!studyDeviceMap[studyId]) {
    studyDeviceMap[studyId] = getRandomDevice(); // Assign a device if not already assigned
  }
  return studyDeviceMap[studyId];
}

const generateCGMFileMetadata = (sid: string, studyId: string,tenantId:string) => {
  // Get the assigned device for this study
  const { device_name, source_platform } = getStudyDevice(studyId);

  // Get start and end dates for the participant's CGM data
  const dateRange: { start_date: string; end_date: string } = db.prepare(`
    SELECT MIN(Date_Time) AS start_date, MAX(Date_Time) AS end_date 
    FROM uniform_resource_cgm_tracing WHERE SID = ?;
  `).get(sid);

  if (!dateRange || !dateRange.start_date || !dateRange.end_date) return;

  const metadataId = ulid();
  const fileName = `cgm_tracing`;
  const fileFormat = "CSV";
  const fileUploadDate = new Date().toISOString();

  db.prepare(`
    INSERT INTO uniform_resource_cgm_file_metadata 
    (metadata_id, devicename, device_id, source_platform, patient_id, 
     file_name, file_format, file_upload_date, data_start_date, data_end_date, 
     study_id, tenant_id, map_field_of_cgm_date, map_field_of_cgm_value, map_field_of_patient_id) 
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
  `).run(
    metadataId,
    device_name,       // Use the assigned device name
    "",
    source_platform,   // Use the assigned source platform
    sid,
    fileName,
    fileFormat,
    fileUploadDate,
    dateRange.start_date,
    dateRange.end_date,
    studyId,
    tenantId,
    "Date_Time",
    "CGM_Value",
    "SID",
  );
  console.log(`CGM file metadata generated for SID: ${sid} (Device: ${device_name}, Source Platform: ${source_platform})`);
};



// Function to generate participants
const generateParticipants = (
  studyId: string,
  participants: number,
  tenantId: string,
) => {
  const genders = ["Male", "Female", "Other", "Unknown"];
  const diabetesTypes = ["Type 1", "Type 2", "Gestational", "Other"];

  const raceEthnicityOptions = [
    { race: "Asian", ethnicity: "Hispanic or Latino" },
    { race: "Asian", ethnicity: "Not Hispanic or Latino" },
    { race: "Black", ethnicity: "Hispanic or Latino" },
    { race: "Black", ethnicity: "Not Hispanic or Latino" },
    { race: "White", ethnicity: "Hispanic or Latino" },
    { race: "White", ethnicity: "Not Hispanic or Latino" },
    { race: "Native Hawaiian", ethnicity: "Hispanic or Latino" },
    { race: "Native Hawaiian", ethnicity: "Not Hispanic or Latino" },
    { race: "American Indian", ethnicity: "Hispanic or Latino" },
    { race: "American Indian", ethnicity: "Not Hispanic or Latino" },
    { race: "Unknown", ethnicity: "Asked but unknown" },
    { race: "Unknown", ethnicity: "Unknown" }
  ];

  const diagnosisIcdOptions = ["E10", "E11", "O24", "R73", "Z13.1"]; // Example ICD-10 codes
  const medRxnormOptions = ["860975", "860976", "197763", "860977", "197762"]; // Example RxNorm drug codes
  const treatmentModalityOptions = ["Insulin", "Oral Medication", "Lifestyle Changes", "Diet & Exercise"];
  const studyArmOptions = ["Control", "Intervention", "Placebo", "Experimental"];

  for (let i = 1; i <= participants; i++) {
    const participantId = `${studyId}-${i}`;
    const gender = genders[Math.floor(Math.random() * genders.length)];
    const age = (18 + Math.floor(Math.random() * 50)).toString();
    const bmi = (18 + Math.random() * 12).toFixed(1);
    const hba1c = (5 + Math.random() * 2).toFixed(1);
    const diabetesType = diabetesTypes[Math.floor(Math.random() * diabetesTypes.length)];
    const raceEthnicity = raceEthnicityOptions[Math.floor(Math.random() * raceEthnicityOptions.length)];
    const raceEthnicityText = [raceEthnicity.race, raceEthnicity.ethnicity].filter(Boolean).join(" ");

    const diagnosisIcd = diagnosisIcdOptions[Math.floor(Math.random() * diagnosisIcdOptions.length)];
    const medRxnorm = medRxnormOptions[Math.floor(Math.random() * medRxnormOptions.length)];
    const treatmentModality = treatmentModalityOptions[Math.floor(Math.random() * treatmentModalityOptions.length)];
    const studyArm = studyArmOptions[Math.floor(Math.random() * studyArmOptions.length)]; // Random study arm

    db.prepare(
      `INSERT INTO uniform_resource_participant 
      (participant_id, study_id, site_id, diagnosis_icd, med_rxnorm, treatment_modality, gender, 
       race_ethnicity, age, bmi, baseline_hba1c, diabetes_type, study_arm, tenant_id) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);`
    ).run(
      participantId,
      studyId,
      "", // site_id (optional)
      diagnosisIcd,
      medRxnorm,
      treatmentModality,
      gender,
      raceEthnicityText, // Now properly concatenated
      age,
      bmi,
      hba1c,
      diabetesType,
      studyArm, // Dynamically assigned
      tenantId
    );
  }
  console.log(`Participants generated for studyId: ${studyId}`);
};


// Function to generate a study and related entities
const generateStudy = async () => {
  createTables();

  //Get user inputs
  const studyName = promptUser("Enter study name:") ;
  const tenantName = promptUser("Enter tenant name:");
  const participants = parseInt(
    promptUser("Enter number of participants:") || "10",
    10,
  );
  const days = parseInt(
    promptUser("Enter CGM data frequency (14, 30, 90 days):") || "14",
    10,
  );

  //const [studyName, tenantName, participants, days] = Deno.args;

  console.log("Generating synthetic data for:");
  console.log(`Study Name: ${studyName}`);
  console.log(`Tenant Name: ${tenantName}`);
  console.log(`Participants: ${participants}`);
  console.log(`Days: ${days}`);

  const tenantId = insertInstitution(tenantName,tenantName);

  const studyId = generateStudyMetadata(studyName, days, tenantId);

  // Generate investigators (3-4 per study)
  const selectedInvestigators = investigatorNames.sort(() =>
    0.5 - Math.random()
  ).slice(0, 4);
  selectedInvestigators.forEach((name, index) => {
    const investigatorId = ulid();
    db.prepare(
      `INSERT INTO uniform_resource_investigator VALUES (?, ?, ?, ?, ?, ?);`,
    )
      .run(
        investigatorId,
        name,
        `investigator${index}@example.com`,
        "INST_1",
        studyId,
        tenantId,
      );
  });
  console.log(`Investigators generated for studyId: ${studyId}`);

  // Generate publication
  const publicationId = ulid();
  db.prepare(
    `INSERT INTO uniform_resource_publication VALUES (?, ?, ?, ?, ?, ?);`,
  )
    .run(
      publicationId,
      `${studyName} Results`,
      generateDOI(),
      "Journal of Diabetes Research",
      studyId,
      tenantId,
    );
  console.log(`Publication generated for studyId: ${studyId}`);

  // Generate authors from the investigators (at least 2-3 authors per study)
  selectedInvestigators.slice(0, 3).forEach((name, index) => {
    const authorId = ulid();
    db.prepare(`INSERT INTO uniform_resource_author VALUES (?, ?, ?, ?, ?, ?);`)
      .run(
        authorId,
        name,
        `author${index}@example.com`,
        "INV_1",
        studyId,
        tenantId,
      );
  });
  console.log(`Authors generated for studyId: ${studyId}`);

  generateParticipants(studyId, participants, tenantId);
  console.log(`Participants generated for studyId: ${studyId}`);

  for (let i = 1; i <= participants; i++) {
    const sid = `${studyId}-${i}`;
    const startDate = new Date();
    generateFitnessData(sid, days);    
    generateMealData(sid, days);    
    generateCGMData(sid, startDate, days);    
    generateCGMFileMetadata(sid, studyId,tenantId);
    
  }
};

generateStudy().then(() => {
  db.close();
  console.log("Synthetic study data generated successfully.");
}).catch((error) => {
  console.error("Error generating synthetic study data:", error);
  db.close();
});
