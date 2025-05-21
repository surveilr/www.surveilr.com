import { Database } from "https://deno.land/x/sqlite3@0.12.0/mod.ts";
import { ulid } from "https://deno.land/x/ulid/mod.ts";

// Initialize database with proper error handling
let db: Database;
try {
  db = new Database("resource-surveillance.sqlite.db");
} catch (error) {
  console.error("Failed to initialize database:", error);
  Deno.exit(1);
}

// Function to get user input with validation
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

  // Wrap in try-catch for better error handling
  try {
    // Use a transaction for better performance and atomicity
    db.exec("BEGIN TRANSACTION;");

    db.exec(`
      -- party definition
      CREATE TABLE IF NOT EXISTS "party" (
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
      CREATE TABLE IF NOT EXISTS "party_type" (
          "party_type_id" ULID PRIMARY KEY NOT NULL,
          "code" TEXT NOT NULL,
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
    `);

    // Split long SQL into multiple statements for better readability and memory efficiency
    const tables = [
      `CREATE TABLE IF NOT EXISTS uniform_resource_study (
        study_id TEXT PRIMARY KEY,
        study_name TEXT,
        start_date TEXT,
        end_date TEXT,
        treatment_modalities TEXT,
        funding_source TEXT,
        nct_number TEXT,
        study_description TEXT,
        tenant_id TEXT
      )`,
      `CREATE TABLE IF NOT EXISTS uniform_resource_publication (
        publication_id TEXT PRIMARY KEY,
        publication_title TEXT,
        digital_object_identifier TEXT,
        publication_site TEXT,
        study_id TEXT,
        tenant_id TEXT
      )`,
      `CREATE TABLE IF NOT EXISTS uniform_resource_investigator (
        investigator_id TEXT PRIMARY KEY,
        investigator_name TEXT,
        email TEXT,
        institution_id TEXT,
        study_id TEXT,
        tenant_id TEXT
      )`,
      `CREATE TABLE IF NOT EXISTS uniform_resource_author (
        author_id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        investigator_id TEXT,
        study_id TEXT,
        tenant_id TEXT
      )`,
      `CREATE TABLE IF NOT EXISTS uniform_resource_cgm_tracing (
        SID TEXT,
        Date_Time TEXT,
        CGM_Value REAL
      )`,
      `CREATE TABLE IF NOT EXISTS uniform_resource_cgm_file_metadata (
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
      )`,
      `CREATE TABLE IF NOT EXISTS uniform_resource_institution (
        institution_id TEXT,
        institution_name TEXT,
        city TEXT,
        state TEXT,
        country TEXT,
        tenant_id TEXT
      )`,
      `CREATE TABLE IF NOT EXISTS uniform_resource_lab (
        lab_id TEXT,
        lab_name TEXT,
        lab_pi TEXT,
        institution_id TEXT,
        study_id TEXT,
        tenant_id TEXT
      )`,
      `CREATE TABLE IF NOT EXISTS uniform_resource_participant (
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
      )`,
      `CREATE TABLE IF NOT EXISTS uniform_resource_site (
        study_id TEXT,
        site_id TEXT,
        site_name TEXT,
        site_type TEXT,
        tenant_id TEXT
      )`,
      `CREATE TABLE IF NOT EXISTS uniform_resource_fitness_data (
        fitness_id TEXT PRIMARY KEY,
        participant_id TEXT,
        date TEXT,
        steps INTEGER,
        exercise_minutes INTEGER,
        calories_burned INTEGER,
        distance REAL,
        heart_rate INTEGER        
      )`,
      `CREATE TABLE IF NOT EXISTS uniform_resource_meal_data (
        meal_id TEXT PRIMARY KEY,
        participant_id TEXT,
        meal_time TEXT,
        calories INTEGER,
        meal_type TEXT
      )`,
      `CREATE TABLE uniform_resource_fitness_file_metadata (
        fitness_meta_id TEXT PRIMARY KEY,     -- ULID 
        participant_id TEXT NOT NULL,        -- FK to participant
        file_name      TEXT NOT NULL,        -- e.g. fitness_data_P-001.csv
        source         TEXT NOT NULL,        -- e.g. Fitbit, Apple Watch
        file_format    TEXT NOT NULL         -- e.g. CSV, JSON
     )`,
     `CREATE TABLE uniform_resource_meal_file_metadata (
          meal_meta_id   TEXT PRIMARY KEY,     -- ULID 
          participant_id TEXT NOT NULL,        -- FK to participant
          file_name      TEXT NOT NULL,        -- e.g. meal_data_P-001.csv
          source         TEXT NOT NULL,        -- e.g. MyFitnessPal, Cronometer
          file_format    TEXT NOT NULL         -- e.g. CSV, JSON
      )`,    
    ];

    // Execute each table creation statement
    for (const tableStatement of tables) {
      db.exec(tableStatement);
    }

    // Commit the transaction
    db.exec("COMMIT;");
    console.log("Tables created successfully.");
  } catch (error) {
    // Rollback transaction on error
    db.exec("ROLLBACK;");
    console.error("Error creating tables:", error);
    throw error; // Re-throw to handle at higher level
  }
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

  console.log(
    `Institution inserted: ${institutionName} (Tenant ID: ${tenantId})`,
  );

  // Insert into party table using tenantId as party_id
  db.prepare(`
    INSERT INTO party (party_id, party_type_id, party_name, created_at, created_by)
    VALUES (?, ?, ?, CURRENT_TIMESTAMP, 'SYSTEM')
  `).run(tenantId, "01JP7GCMDK7GVTBQPJJV9G7XRS", tenantName);

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

  const startDate = new Date().toISOString().replace("T", " ").replace("Z", "");
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
      endDate.toISOString().replace("T", " ").replace("Z", ""),
      "Insulin Therapy",
      "NIH",
      nctNumber,
      "Study on diabetes management",
      tenantId,
    );
  console.log(`Study metadata generated for studyId: ${studyId}`);
  return studyId;
};

const fitnessSources = ["Fitbit", "Apple Watch", "Garmin"];
const fitnessFileFormats = ["csv"];

const generateFitnessDataWithMetadata = (
  participantId: string,
  days: number
) => {
  let date = new Date();
  const fitness_meta_id= ulid();

  // Pick random source and file format
  const source = fitnessSources[Math.floor(Math.random() * fitnessSources.length)];
  const fileFormat = fitnessFileFormats[Math.floor(Math.random() * fitnessFileFormats.length)];
  const fileName = `fitness_data_${participantId}_${source.toLowerCase().replace(/\s/g, "_")}.${fileFormat.toLowerCase()}`;

  try {
    db.exec("BEGIN TRANSACTION;");

    // Prepare statement once
    // Prepare statement once
    const stmt = db.prepare(`
      INSERT INTO uniform_resource_fitness_data VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `);

    for (let i = 0; i < days; i++) {
      const fitnessId = ulid();
      const steps = Math.floor(Math.random() * (15000 - 3000) + 3000);
      const exerciseMinutes = Math.floor(Math.random() * 90);
      const caloriesBurned = Math.floor(Math.random() * (700 - 150) + 150);
      const distance = Math.floor(Math.random() * (10 - 1) + 1); // Distance in km
      const heartRate = Math.floor(Math.random() * (180 - 60) + 60); // Heart rate in bpm

      stmt.run(
        fitnessId,
        participantId,
        date.toISOString().split("T")[0],
        steps,
        exerciseMinutes,
        caloriesBurned,
        distance,
        heartRate,
      );

      date.setDate(date.getDate() - 1);
    }

    const insertMetadataStmt = db.prepare(`
      INSERT INTO uniform_resource_fitness_file_metadata
      (fitness_meta_id, participant_id, file_name, source, file_format)
      VALUES (?, ?, ?, ?, ?)
    `);

    insertMetadataStmt.run(
      fitness_meta_id,
      participantId,
      fileName,
      source,
      fileFormat
    );

    db.exec("COMMIT;");
    console.log(`Inserted fitness data + metadata for ${participantId} (source: ${source})`);
  } catch (error) {
    db.exec("ROLLBACK;");
    console.error(`Error for ${participantId}:`, error);
    throw error;
  }
};


const mealSources = ["MyFitnessPal", "Cronometer"];
const mealFileFormats = ["csv"];

const generateMealDataWithMetadata = (participantId: string, days: number) => {
  let date = new Date();
  const mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"];
  const mealfileId = ulid();

  const source = mealSources[Math.floor(Math.random() * mealSources.length)];
  const fileFormat = mealFileFormats[Math.floor(Math.random() * mealFileFormats.length)];
  const fileName = `meal_data_${participantId}_${source.toLowerCase().replace(/\s/g, "_")}.${fileFormat.toLowerCase()}`;

  try {
    db.exec("BEGIN TRANSACTION;");

    // Prepare statement once
    const stmt = db.prepare(`
      INSERT INTO uniform_resource_meal_data VALUES (?, ?, ?, ?, ?)
    `);

    for (let i = 0; i < days; i++) {
      mealTypes.forEach((mealType) => {
        const mealId = ulid();
        const mealTime = new Date(date);
        // Distribute meal times throughout the day based on meal type
        switch (mealType) {
          case "Breakfast":
            mealTime.setHours(
              7 + Math.floor(Math.random() * 3),
              Math.floor(Math.random() * 60),
            );
            break;
          case "Lunch":
            mealTime.setHours(
              11 + Math.floor(Math.random() * 3),
              Math.floor(Math.random() * 60),
            );
            break;
          case "Dinner":
            mealTime.setHours(
              17 + Math.floor(Math.random() * 3),
              Math.floor(Math.random() * 60),
            );
            break;
          case "Snack":
            // Snacks can happen any time
            mealTime.setHours(
              Math.floor(Math.random() * 24),
              Math.floor(Math.random() * 60),
            );
            break;
        }

        // Calories more realistically based on meal type
        let caloriesMin = 200, caloriesMax = 800;
        switch (mealType) {
          case "Breakfast":
            caloriesMin = 300;
            caloriesMax = 700;
            break;
          case "Lunch":
            caloriesMin = 400;
            caloriesMax = 900;
            break;
          case "Dinner":
            caloriesMin = 500;
            caloriesMax = 1200;
            break;
          case "Snack":
            caloriesMin = 100;
            caloriesMax = 400;
            break;
        }
        const calories = Math.floor(
          Math.random() * (caloriesMax - caloriesMin) + caloriesMin,
        );

        stmt.run(
          mealId,
          participantId,
          mealTime.toISOString().replace("T", " ").replace("Z", ""),
          calories,
          mealType,
        );
      });

      date.setDate(date.getDate() - 1);
    }

    const insertMetadataStmt = db.prepare(`
      INSERT INTO uniform_resource_meal_file_metadata
      (meal_meta_id, participant_id, file_name, source, file_format)
      VALUES (?, ?, ?, ?, ?)
    `);

    insertMetadataStmt.run(
      mealfileId,
      participantId,
      fileName,
      source,
      fileFormat
    );

    db.exec("COMMIT;");
    console.log(`Inserted meal data + metadata for ${participantId} (source: ${source})`);
  } catch (error) {
    db.exec("ROLLBACK;");
    console.error(`Error for ${participantId}:`, error);
    throw error;
  }
};


// Generate random fitness data with batch processing
const generateFitnessData = (participantId: string, days: number) => {
  let date = new Date();
  const fitnessData = [];

  try {
    // Begin transaction
    db.exec("BEGIN TRANSACTION;");

    // Prepare statement once
    const stmt = db.prepare(`
      INSERT INTO uniform_resource_fitness_data VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `);

    for (let i = 0; i < days; i++) {
      const fitnessId = ulid();
      const steps = Math.floor(Math.random() * (15000 - 3000) + 3000);
      const exerciseMinutes = Math.floor(Math.random() * 90);
      const caloriesBurned = Math.floor(Math.random() * (700 - 150) + 150);
      const distance = Math.floor(Math.random() * (10 - 1) + 1); // Distance in km
      const heartRate = Math.floor(Math.random() * (180 - 60) + 60); // Heart rate in bpm

      stmt.run(
        fitnessId,
        participantId,
        date.toISOString().split("T")[0],
        steps,
        exerciseMinutes,
        caloriesBurned,
        distance,
        heartRate,
      );

      date.setDate(date.getDate() - 1);
    }

    // Commit the transaction
    db.exec("COMMIT;");
    console.log(
      `Fitness data generated for participantId: ${participantId} (${days} days)`,
    );
  } catch (error) {
    db.exec("ROLLBACK;");
    console.error(
      `Error generating fitness data for participantId: ${participantId}:`,
      error,
    );
    throw error;
  }
};

// Generate random meal data with batch processing
const generateMealData = (participantId: string, days: number) => {
  let date = new Date();
  const mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"];

  try {
    // Begin transaction
    db.exec("BEGIN TRANSACTION;");

    // Prepare statement once
    const stmt = db.prepare(`
      INSERT INTO uniform_resource_meal_data VALUES (?, ?, ?, ?, ?)
    `);

    for (let i = 0; i < days; i++) {
      mealTypes.forEach((mealType) => {
        const mealId = ulid();
        const mealTime = new Date(date);
        // Distribute meal times throughout the day based on meal type
        switch (mealType) {
          case "Breakfast":
            mealTime.setHours(
              7 + Math.floor(Math.random() * 3),
              Math.floor(Math.random() * 60),
            );
            break;
          case "Lunch":
            mealTime.setHours(
              11 + Math.floor(Math.random() * 3),
              Math.floor(Math.random() * 60),
            );
            break;
          case "Dinner":
            mealTime.setHours(
              17 + Math.floor(Math.random() * 3),
              Math.floor(Math.random() * 60),
            );
            break;
          case "Snack":
            // Snacks can happen any time
            mealTime.setHours(
              Math.floor(Math.random() * 24),
              Math.floor(Math.random() * 60),
            );
            break;
        }

        // Calories more realistically based on meal type
        let caloriesMin = 200, caloriesMax = 800;
        switch (mealType) {
          case "Breakfast":
            caloriesMin = 300;
            caloriesMax = 700;
            break;
          case "Lunch":
            caloriesMin = 400;
            caloriesMax = 900;
            break;
          case "Dinner":
            caloriesMin = 500;
            caloriesMax = 1200;
            break;
          case "Snack":
            caloriesMin = 100;
            caloriesMax = 400;
            break;
        }
        const calories = Math.floor(
          Math.random() * (caloriesMax - caloriesMin) + caloriesMin,
        );

        stmt.run(
          mealId,
          participantId,
          mealTime.toISOString().replace("T", " ").replace("Z", ""),
          calories,
          mealType,
        );
      });

      date.setDate(date.getDate() - 1);
    }

    // Commit the transaction
    db.exec("COMMIT;");
    console.log(
      `Meal data generated for participantId: ${participantId} (${
        days * mealTypes.length
      } entries)`,
    );
  } catch (error) {
    db.exec("ROLLBACK;");
    console.error(
      `Error generating meal data for participantId: ${participantId}:`,
      error,
    );
    throw error;
  }
};

// Function to generate synthetic CGM data with batch processing
// Function to generate synthetic CGM data with batch processing
const generateCGMData = (sid: string, startDate: Date, days: number) => {
  let date = new Date(startDate);
  const batchSize = 100; // Process in batches for better performance
  const totalEntries = days * 24 * 12; // 5 min intervals
  let entriesProcessed = 0;

  try {
    // Use a single prepared statement for all inserts
    const stmt = db.prepare(
      "INSERT INTO uniform_resource_cgm_tracing VALUES (?, ?, ?)",
    );

    // Begin transaction for batch processing
    db.exec("BEGIN TRANSACTION;");

    while (entriesProcessed < totalEntries) {
      // Process in batches
      for (let i = 0; i < batchSize && entriesProcessed < totalEntries; i++) {
        // Introduce variability in CGM values
        const cgmValue = (Math.random() * 80) + 70; // Base value
        const variability = Math.random() * 40 - 20; // Variability range [-20, 20]
        const finalCGMValue = Math.max(
          40,
          Math.min(400, cgmValue + variability),
        ); // Ensure values are within realistic range

        stmt.run(
          sid,
          date.toISOString().replace("T", " ").replace("Z", ""),
          finalCGMValue.toFixed(1),
        );

        date.setMinutes(date.getMinutes() + 5);
        entriesProcessed++;
      }

      // Log progress for large datasets
      if (entriesProcessed % 1000 === 0) {
        console.log(
          `CGM data generation progress: ${entriesProcessed}/${totalEntries} entries`,
        );
      }
    }

    // Commit the transaction
    db.exec("COMMIT;");
    console.log(`CGM data generated for SID: ${sid} (${totalEntries} entries)`);
  } catch (error) {
    // Rollback on error
    db.exec("ROLLBACK;");
    console.error(`Error generating CGM data for SID: ${sid}:`, error);
    throw error;
  }
};

// Store assigned devices per study to ensure consistency
const studyDeviceMap: Record<
  string,
  { device_name: string; source_platform: string }
> = {};

// Function to get a random device with better organization
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
    { device_name: "Medtronic Paradigm", source_platform: "Medtronic" },
  ];
  return devices[Math.floor(Math.random() * devices.length)];
}

// Function to get or assign a device for a study
function getStudyDevice(studyId: string) {
  if (!studyDeviceMap[studyId]) {
    studyDeviceMap[studyId] = getRandomDevice(); // Assign a device if not already assigned
  }
  return studyDeviceMap[studyId];
}

// Optimized CGM file metadata generation with better error handling
const generateCGMFileMetadata = (
  sid: string,
  studyId: string,
  tenantId: string,
) => {
  try {
    // Get the assigned device for this study
    const { device_name, source_platform } = getStudyDevice(studyId);

    // Get start and end dates for the participant's CGM data
    const dateRange: { start_date: string; end_date: string } | undefined = db
      .prepare(`
      SELECT MIN(Date_Time) AS start_date, MAX(Date_Time) AS end_date
      FROM uniform_resource_cgm_tracing WHERE SID = ?;
    `).get(sid);

    if (!dateRange || !dateRange.start_date || !dateRange.end_date) {
      console.warn(
        `No CGM data found for SID: ${sid}, skipping metadata generation`,
      );
      return;
    }

    const metadataId = ulid();
    const fileName = `cgm_tracing`; // More specific filename
    const fileFormat = "csv";
    const fileUploadDate = new Date().toISOString();

    db.prepare(`
      INSERT INTO uniform_resource_cgm_file_metadata
      (metadata_id, devicename, device_id, source_platform, patient_id,
       file_name, file_format, file_upload_date, data_start_date, data_end_date,
       study_id, tenant_id, map_field_of_cgm_date, map_field_of_cgm_value, map_field_of_patient_id)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    `).run(
      metadataId,
      device_name,
      "", // Generate a device ID for better data representation
      source_platform,
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

    console.log(
      `CGM file metadata generated for SID: ${sid} (Device: ${device_name}, Source Platform: ${source_platform})`,
    );
  } catch (error) {
    console.error(`Error generating CGM file metadata for SID: ${sid}:`, error);
    // Continue execution rather than crashing the entire process
  }
};

// Function to generate participants with batch processing
const generateParticipants = (
  studyId: string,
  participants: number,
  tenantId: string,
) => {
  try {
    // Begin transaction for batch processing
    db.exec("BEGIN TRANSACTION;");

    const stmt = db.prepare(
      `INSERT INTO uniform_resource_participant
      (participant_id, study_id, site_id, diagnosis_icd, med_rxnorm, treatment_modality, gender,
       race_ethnicity, age, bmi, baseline_hba1c, diabetes_type, study_arm, tenant_id)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);`,
    );

    // Preload options for better performance
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
      { race: "Unknown", ethnicity: "Unknown" },
    ];
    const diagnosisIcdOptions = ["E10", "E11", "O24", "R73", "Z13.1"]; // Example ICD-10 codes
    const medRxnormOptions = ["860975", "860976", "197763", "860977", "197762"]; // Example RxNorm drug codes
    const treatmentModalityOptions = [
      "Insulin",
      "Oral Medication",
      "Lifestyle Changes",
      "Diet & Exercise",
    ];
    const studyArmOptions = [
      "Control",
      "Intervention",
      "Placebo",
      "Experimental",
    ];

    for (let i = 1; i <= participants; i++) {
      const participantId = `${studyId}-${i}`;
      const gender = genders[Math.floor(Math.random() * genders.length)];
      const age = (18 + Math.floor(Math.random() * 50)).toString();
      const bmi = (18 + Math.random() * 12).toFixed(1);
      const hba1c = (5 + Math.random() * 2).toFixed(1);
      const diabetesType =
        diabetesTypes[Math.floor(Math.random() * diabetesTypes.length)];

      const raceEthnicity = raceEthnicityOptions[
        Math.floor(Math.random() * raceEthnicityOptions.length)
      ];
      const raceEthnicityText =
        `${raceEthnicity.race} ${raceEthnicity.ethnicity}`;

      const diagnosisIcd = diagnosisIcdOptions[
        Math.floor(Math.random() * diagnosisIcdOptions.length)
      ];
      const medRxnorm =
        medRxnormOptions[Math.floor(Math.random() * medRxnormOptions.length)];
      const treatmentModality = treatmentModalityOptions[
        Math.floor(Math.random() * treatmentModalityOptions.length)
      ];
      const studyArm =
        studyArmOptions[Math.floor(Math.random() * studyArmOptions.length)];

      0.;

      stmt.run(
        participantId,
        studyId,
        "", // site_id (optional)
        diagnosisIcd,
        medRxnorm,
        treatmentModality,
        gender,
        raceEthnicityText,
        age,
        bmi,
        hba1c,
        diabetesType,
        studyArm,
        tenantId,
      );

      // Log progress for large participant groups
      if (i % 50 === 0) {
        console.log(`Generated ${i}/${participants} participants`);
      }
    }

    // Commit the transaction
    db.exec("COMMIT;");
    console.log(
      `All ${participants} participants generated for studyId: ${studyId}`,
    );
  } catch (error) {
    // Rollback the transaction on error
    db.exec("ROLLBACK;");
    console.error(
      `Error generating participants for studyId ${studyId}:`,
      error,
    );
    throw error;
  }
};

// Function to generate a study and related entities with improved structure
const generateStudy = async () => {
  try {
    // Create tables structure if they don't exist
    createTables();

    // Get user inputs with validation
    const studyName = promptUser("Enter study name:");
    const tenantName = promptUser("Enter tenant name:");
    let participants = parseInt(
      promptUser("Enter number of participants (max 1000):") || "10",
      10,
    );

    // Validate participants count
    if (participants > 1000) {
      console.warn(
        "Warning: Large participant count may affect performance. Limiting to 1000.",
      );
      participants = 1000;
    }

    const days = parseInt(
      promptUser("Enter CGM data frequency (14, 30, 90 days):") || "14",
      10,
    );

    // Validate days
    if (![14, 30, 90].includes(days)) {
      console.warn(
        `Warning: Unusual day count ${days}. Recommended values are 14, 30, or 90 days.`,
      );
    }

    console.log("Generating synthetic data for:");
    console.log(`Study Name: ${studyName}`);
    console.log(`Tenant Name: ${tenantName}`);
    console.log(`Participants: ${participants}`);
    console.log(`Days: ${days}`);

    // Begin transaction for top-level entities
    db.exec("BEGIN TRANSACTION;");

    // Generate tenant and institution
    const tenantId = insertInstitution(tenantName, tenantName);

    // Generate study metadata
    const studyId = generateStudyMetadata(studyName, days, tenantId);

    // Commit transaction for top-level entities
    db.exec("COMMIT;");

    // Begin transaction for investigators and publications
    db.exec("BEGIN TRANSACTION;");

    // Generate investigators (3-4 per study) with improved batch processing
    const selectedInvestigators = [...investigatorNames]
      .sort(() => 0.5 - Math.random()) // Shuffle using spread operator for immutability
      .slice(0, 4);

    const investigatorStmt = db.prepare(
      `INSERT INTO uniform_resource_investigator VALUES (?, ?, ?, ?, ?, ?);`,
    );

    selectedInvestigators.forEach((name, index) => {
      const investigatorId = ulid();
      investigatorStmt.run(
        investigatorId,
        name,
        `investigator${index}@example.com`,
        "INST_1",
        studyId,
        tenantId,
      );
    });

    console.log(`Investigators generated for studyId: ${studyId}`);

    // Generate publication with detailed information
    const publicationId = ulid();
    const doi = generateDOI();
    const publicationDate = new Date();
    publicationDate.setMonth(publicationDate.getMonth() + 6); // Publication 6 months in future

    db.prepare(
      `INSERT INTO uniform_resource_publication VALUES (?, ?, ?, ?, ?, ?);`,
    ).run(
      publicationId,
      `${studyName} Results and Analysis`,
      doi,
      "Journal of Diabetes Research",
      studyId,
      tenantId,
    );

    console.log(
      `Publication generated for studyId: ${studyId} with DOI: ${doi}`,
    );

    // Generate authors from the investigators with more realistic data
    const authorStmt = db.prepare(
      `INSERT INTO uniform_resource_author VALUES (?, ?, ?, ?, ?, ?);`,
    );

    selectedInvestigators.slice(0, 3).forEach((name, index) => {
      const authorId = ulid();
      const email = `${
        name.replace(/Dr\.\s+/, "").toLowerCase().replace(/\s+/g, ".")
      }@example.com`;

      authorStmt.run(
        authorId,
        name,
        email,
        "INV_1",
        studyId,
        tenantId,
      );
    });

    // Commit transaction for investigators and publications
    db.exec("COMMIT;");
    console.log(`Authors generated for studyId: ${studyId}`);

    // Generate participant data
    generateParticipants(studyId, participants, tenantId);

    console.log(`Beginning data generation for ${participants} participants`);
    console.log(`This may take some time for larger datasets...`);

    // Process participants with progress reporting
    const startTime = Date.now();

    for (let i = 1; i <= participants; i++) {
      const sid = `${studyId}-${i}`;
      const startDate = new Date();

      // Generate all participant data
      generateFitnessDataWithMetadata(sid, days);
      generateMealDataWithMetadata(sid, days);
      generateCGMData(sid, startDate, days);
      generateCGMFileMetadata(sid, studyId, tenantId);

      // Report progress at intervals
      if (i % 5 === 0 || i === participants) {
        const percentComplete = Math.round((i / participants) * 100);
        const elapsedSeconds = Math.round((Date.now() - startTime) / 1000);

        console.log(
          `Progress: ${i}/${participants} participants (${percentComplete}%) - ${elapsedSeconds}s elapsed`,
        );

        // Estimate remaining time
        if (i < participants) {
          const estimatedTotalSeconds = (elapsedSeconds / i) * participants;
          const remainingSeconds = Math.round(
            estimatedTotalSeconds - elapsedSeconds,
          );
          console.log(`Estimated time remaining: ${remainingSeconds}s`);
        }
      }
    }

    // Perform final database optimizations
    console.log("Performing database optimizations...");
    db.exec("PRAGMA optimize;");

    console.log(
      `Study generated successfully in ${
        Math.round((Date.now() - startTime) / 1000)
      }s`,
    );
    return { studyId, participants, days };
  } catch (error) {
    console.error("Error in generate study:", error);
    // Attempt to rollback any ongoing transactions
    try {
      db.exec("ROLLBACK;");
    } catch (rollbackError) {
      console.error("Error during rollback:", rollbackError);
    }
    throw error;
  }
};

// Main execution with better error handling
generateStudy()
  .then(({ studyId, participants, days }) => {
    db.close();
    console.log(`
=========================================
 Synthetic study data generation complete
=========================================
Study ID: ${studyId}
Participants: ${participants}
Days of data: ${days}
Total CGM data points: ~${participants * days * 24 * 12}
Total fitness entries: ${participants * days}
Total meal entries: ${participants * days * 4}
=========================================
    `);
  })
  .catch((error) => {
    console.error("Fatal error generating synthetic study data:", error);
    try {
      db.close();
    } catch (closeError) {
      console.error("Error closing database connection:", closeError);
    }
    Deno.exit(1);
  });
