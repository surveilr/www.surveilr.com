import { Database } from "https://deno.land/x/sqlite3@0.12.0/mod.ts";
import { ulid } from "https://deno.land/x/ulid/mod.ts";

// Initialize database
const db = new Database("resource-surveillance.sqlite.db");

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

// Function to generate study metadata
const generateStudyMetadata = (
  studyName: string,
  days: number,
  tenantId: string,
) => {
  const studyId = studyName
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

const generateCGMFileMetadata = (sid: string, studyId: string) => {
  const deviceList = [
    "Dexcom G6",
    "Dexcom G7",
    "Dexcom Platinum",
    "Freestyle Libre",
    "Libre 2",
    "Libre 3",
  ];

  // Get start and end dates for the participant's CGM data
  const dateRange: { start_date: string; end_date: string } = db.prepare(`
    SELECT MIN(Date_Time) AS start_date, MAX(Date_Time) AS end_date 
    FROM uniform_resource_cgm_tracing WHERE SID = ?;
  `).get(sid);

  if (!dateRange || !dateRange.start_date || !dateRange.end_date) return;

  const metadataId = ulid();
  const deviceName = deviceList[Math.floor(Math.random() * deviceList.length)];
  const fileName = `cgm_tracing_${sid}.csv`;
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
    deviceName,
    ulid(),
    "CGM Platform",
    sid,
    fileName,
    fileFormat,
    fileUploadDate,
    dateRange.start_date,
    dateRange.end_date,
    studyId,
    "default_tenant",
    "Date_Time",
    "CGM_Value",
    "SID",
  );
  console.log(`CGM file metadata generated for SID: ${sid}`);
};

// Function to generate participants
const generateParticipants = (
  studyId: string,
  participants: number,
  tenantId: string,
) => {
  const genders = ["Male", "Female", "Other", "Unknown"];
  const diabetesTypes = ["Type 1", "Type 2", "Gestational", "Other"];
  for (let i = 1; i <= participants; i++) {
    const participantId = `${studyId}-${i}`;
    const gender = genders[Math.floor(Math.random() * genders.length)];
    const age = (18 + Math.floor(Math.random() * 50)).toString();
    const bmi = (18 + Math.random() * 12).toFixed(1);
    const hba1c = (5 + Math.random() * 2).toFixed(1);
    const diabetesType =
      diabetesTypes[Math.floor(Math.random() * diabetesTypes.length)];
    db.prepare(
      `INSERT INTO uniform_resource_participant VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);`,
    )
      .run(
        participantId,
        studyId,
        "",
        "",
        "",
        "",
        gender,
        "",
        age,
        bmi,
        hba1c,
        diabetesType,
        "A",
        tenantId,
      );
  }
  console.log(`Participants generated for studyId: ${studyId}`);
};

// Function to generate a study and related entities
const generateStudy = async () => {
  createTables();

  // Get user inputs
  const studyName = prompt("Enter study name:") || "Default Study";
  const tenantName = prompt("Enter tenant name:") || "Default Tenant";
  const participants = parseInt(
    prompt("Enter number of participants:") || "10",
    10,
  );
  const days = parseInt(
    prompt("Enter CGM data frequency (14, 30, 90 days):") || "14",
    10,
  );
  const tenantId = generateTenantId(tenantName);

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
    //console.log(`Fitness data generated for participantId: ${sid}`);
    generateMealData(sid, days);
    //console.log(`Meal data generated for participantId: ${sid}`);
    generateCGMData(sid, startDate, days);
    //console.log(`CGM data generated for participantId: ${sid}`);
    generateCGMFileMetadata(sid, studyId);
    //console.log(`CGM file metadata generated for participantId: ${sid}`);
  }
};

generateStudy().then(() => {
  db.close();
  console.log("Synthetic study data generated successfully.");
}).catch((error) => {
  console.error("Error generating synthetic study data:", error);
  db.close();
});
