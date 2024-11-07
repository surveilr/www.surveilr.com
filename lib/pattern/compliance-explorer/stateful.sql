-- Drop the table if it exists, then create the new table with auto-increment primary key
DROP TABLE IF EXISTS "compliance_regime";
CREATE TABLE "compliance_regime" (
    "compliance_regime_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "title" TEXT NOT NULL,
    "geography" TEXT,
    "source" TEXT,
    "description" TEXT,
    "version" TEXT,
    "last_reviewed_date" TIMESTAMPTZ,
    "authoritative_source" TEXT,
    "custom_user_text" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT
);

-- Insert records into the table
INSERT INTO "compliance_regime" (
    "title",
    "geography",
    "source",
    "description",
    "version",
    "last_reviewed_date",
    "authoritative_source",
    "custom_user_text"
)
VALUES
    (
        'US HIPAA',
        'US',
        'Federal',
        'The Health Insurance Portability and Accountability Act (HIPAA) Security Rule sets national standards to protect individuals electronic personal health information (ePHI) that is created, received, used, or maintained by a covered entity. The Security Rule mandates appropriate administrative, physical, and technical safeguards to ensure the confidentiality, integrity, and security of ePHI.' ||
        'security, and integrity of protected health information (PHI), ensuring compliance for healthcare providers, ' ||
        'insurers, and related entities handling electronic and physical health data',
        'N/A',
        '2022-10-20 00:00:00+00',
        'Health Insurance Portability and Accountability Act (HIPAA)',
        'Below, you will find a complete list of all controls applicable to the US HIPAA framework. These controls are designed ' ||
        'to ensure compliance with the Health Insurance Portability and Accountability Act (HIPAA) standards, safeguarding ' ||
        'sensitive patient health information'
    ),
    (
        'NIST',
        'Universal',
        'SCF',
        'The NIST SP 800-53 standard aims to protect operations, assets, individuals, organizations, and the United States from a wide range of cyber threats, including hostile attacks, human error, and natural disasters. The controls are designed to be flexible and customizable to support organizations in their implementation efforts.',
        '2024',
        '2024-04-01 00:00:00+00',
        '800-53 rev4',
        NULL
    );
