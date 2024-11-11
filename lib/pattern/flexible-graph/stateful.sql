DROP TABLE IF EXISTS "flexible_graph";
CREATE TABLE IF NOT EXISTS "flexible_graph" (
    "flexible_graph_id" VARCHAR PRIMARY KEY NOT NULL,
    "name" TEXT NOT NULL,
    "tenant_id" TEXT,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL)
);

DROP TABLE IF EXISTS "flexible_graph_node";
CREATE TABLE IF NOT EXISTS "flexible_graph_node" (
    "id" VARCHAR PRIMARY KEY NOT NULL,
    "flexible_graph_id" VARCHAR NOT NULL,
    "body" TEXT CHECK(json_valid(body) OR body IS NULL),
    FOREIGN KEY("flexible_graph_id") REFERENCES "flexible_graph"("flexible_graph_id")
);

DROP TABLE IF EXISTS "flexible_graph_edge";
CREATE TABLE IF NOT EXISTS "flexible_graph_edge" (
    "flexible_graph_id" VARCHAR NOT NULL,
    "source" VARCHAR,
    "target" VARCHAR,
    "elaboration" TEXT CHECK(json_valid(elaboration) OR elaboration IS NULL),
    FOREIGN KEY("flexible_graph_id") REFERENCES "flexible_graph"("flexible_graph_id"),
    FOREIGN KEY("source") REFERENCES "flexible_graph_node"("id"),
    FOREIGN KEY("target") REFERENCES "flexible_graph_node"("id"),
    UNIQUE("source", "target")
);

CREATE INDEX IF NOT EXISTS "idx_flexible_graph__flexible_graph_id" ON "flexible_graph"("flexible_graph_id");
CREATE INDEX IF NOT EXISTS "idx_flexible_graph_node__id" ON "flexible_graph_node"("id");
CREATE INDEX IF NOT EXISTS "idx_flexible_graph_edge__flexible_graph_id" ON "flexible_graph_edge"("flexible_graph_id");

INSERT INTO "flexible_graph" ("flexible_graph_id", "name", "tenant_id", "elaboration")
VALUES 
('workflow1', 'Software Development Workflow', 'project_team1', '{"type": "workflow", "description": "Software development process from start to finish"}');

INSERT INTO "flexible_graph_node" ("id", "flexible_graph_id", "body")
VALUES 
('node_req', 'workflow1', '{"stage": "Requirements Gathering", "details": "Initial phase to gather project requirements"}'),
('node_design', 'workflow1', '{"stage": "Design", "details": "Create design documents and system architecture"}'),
('node_dev', 'workflow1', '{"stage": "Development", "details": "Actual coding and implementation of features"}'),
('node_test', 'workflow1', '{"stage": "Testing", "details": "Quality assurance testing and bug fixing"}'),
('node_deploy', 'workflow1', '{"stage": "Deployment", "details": "Deployment of the final product to production"}');

INSERT INTO "flexible_graph_edge" ("flexible_graph_id", "source", "target", "elaboration")
VALUES 
('workflow1', 'node_req', 'node_design', '{"type": "workflow_step", "details": "Transition from requirements to design"}'),
('workflow1', 'node_design', 'node_dev', '{"type": "workflow_step", "details": "Transition from design to development"}'),
('workflow1', 'node_dev', 'node_test', '{"type": "workflow_step", "details": "Transition from development to testing"}'),
('workflow1', 'node_test', 'node_deploy', '{"type": "workflow_step", "details": "Transition from testing to deployment"}');


-- represent a corporate IT network
INSERT INTO "flexible_graph" ("flexible_graph_id", "name", "tenant_id", "elaboration")
VALUES 
('network1', 'Corporate IT Network', 'corp_network_team', '{"type": "network", "description": "An IT network for a corporate environment"}');

-- represent network devices
INSERT INTO "flexible_graph_node" ("id", "flexible_graph_id", "body")
VALUES 
('node_server1', 'network1', '{"device_type": "Application Server", "ip_address": "192.168.1.10", "location": "Data Center 1"}'),
('node_server2', 'network1', '{"device_type": "Database Server", "ip_address": "192.168.1.11", "location": "Data Center 1"}'),
('node_workstation1', 'network1', '{"device_type": "Workstation", "ip_address": "192.168.1.101", "user": "Alice", "location": "Office 1"}'),
('node_workstation2', 'network1', '{"device_type": "Workstation", "ip_address": "192.168.1.102", "user": "Bob", "location": "Office 1"}'),
('node_router', 'network1', '{"device_type": "Router", "ip_address": "192.168.1.1", "location": "Main Data Center"}'),
('node_firewall', 'network1', '{"device_type": "Firewall", "ip_address": "192.168.1.254", "location": "Perimeter"}');

-- connections between devices
INSERT INTO "flexible_graph_edge" ("flexible_graph_id", "source", "target", "elaboration")
VALUES 
('network1', 'node_router', 'node_server1', '{"connection_type": "ethernet", "bandwidth": "1Gbps", "details": "Router to Application Server"}'),
('network1', 'node_router', 'node_server2', '{"connection_type": "ethernet", "bandwidth": "1Gbps", "details": "Router to Database Server"}'),
('network1', 'node_router', 'node_firewall', '{"connection_type": "firewall link", "bandwidth": "10Gbps", "details": "Router to Firewall"}'),
('network1', 'node_firewall', 'node_router', '{"connection_type": "firewall link", "bandwidth": "10Gbps", "details": "Firewall to Router"}'),
('network1', 'node_workstation1', 'node_router', '{"connection_type": "wifi", "bandwidth": "100Mbps", "details": "Workstation (Alice) to Router"}'),
('network1', 'node_workstation2', 'node_router', '{"connection_type": "wifi", "bandwidth": "100Mbps", "details": "Workstation (Bob) to Router"}');
