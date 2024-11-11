DROP VIEW IF EXISTS "software_dev_workflow";
CREATE VIEW "view_complete_workflow" AS
SELECT 
    fg.flexible_graph_id,
    fg.name AS graph_name,
    fg.tenant_id,
    fgn.id AS node_id,
    fgn.body AS node_details,
    COALESCE(fge.source, '') AS source_node,
    COALESCE(fge.target, '') AS target_node,
    fge.elaboration AS edge_details
FROM 
    flexible_graph fg
LEFT JOIN 
    flexible_graph_node fgn ON fg.flexible_graph_id = fgn.flexible_graph_id
LEFT JOIN 
    flexible_graph_edge fge ON fge.flexible_graph_id = fg.flexible_graph_id 
      AND (fge.source = fgn.id OR fge.target = fgn.id)
WHERE 
    fg.name = 'Software Development Workflow';

DROP VIEW IF EXISTS "network_nodes";
CREATE VIEW "network_nodes" AS
SELECT 
    fg.flexible_graph_id,
    fg.name AS graph_name,
    fg.tenant_id,
    fgn.id AS node_id,
    fgn.body AS device_details
FROM 
    flexible_graph_node fgn
JOIN 
    flexible_graph fg ON fgn.flexible_graph_id = fg.flexible_graph_id
WHERE 
    fg.name = 'Corporate IT Network';

DROP VIEW IF EXISTS "network_edges";
CREATE VIEW "network_edges" AS
SELECT 
    fg.flexible_graph_id,
    fg.name AS graph_name,
    fg.tenant_id,
    fge.source,
    fge.target,
    fge.elaboration AS connection_details
FROM 
    flexible_graph_edge fge
JOIN 
    flexible_graph fg ON fge.flexible_graph_id = fg.flexible_graph_id
WHERE 
    fg.name = 'Corporate IT Network';


DROP VIEW IF EXISTS "complete_network_graph";
CREATE VIEW "view_complete_network_graph" AS
SELECT 
    fg.flexible_graph_id,
    fg.name AS graph_name,
    fg.tenant_id,
    fgn.id AS device_id,
    fgn.body AS device_details,
    COALESCE(fge.source, '') AS source_device,
    COALESCE(fge.target, '') AS target_device,
    fge.elaboration AS connection_details
FROM 
    flexible_graph fg
LEFT JOIN 
    flexible_graph_node fgn ON fg.flexible_graph_id = fgn.flexible_graph_id
LEFT JOIN 
    flexible_graph_edge fge ON fge.flexible_graph_id = fg.flexible_graph_id 
      AND (fge.source = fgn.id OR fge.target = fgn.id)
WHERE 
    fg.name = 'Corporate IT Network';
