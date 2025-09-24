import { relations } from "drizzle-orm/relations";
import { codeNotebookKernel, codeNotebookCell, codeNotebookState, partyType, party, partyRelationType, partyRelation, sexType, person, genderType, personType, organization, organizationRoleType, organizationRole, devicePartyRelationship, device, assuranceSchema, behavior, urIngestSession, urIngestSessionFsPath, urIngestSessionPlmAcctProject, uniformResource, urIngestSessionImapAcctFolderMessage, uniformResourceTransform, urIngestSessionFsPathEntry, urIngestSessionTask, urIngestSessionImapAccount, urIngestSessionImapAcctFolder, urIngestSessionPlmAccount, urIngestSessionPlmIssueType, urIngestSessionPlmAcctProjectIssue, urIngestSessionPlmUser, urIngestSessionPlmAcctLabel, urIngestSessionPlmMilestone, urIngestSessionPlmAcctRelationship, urIngestSessionPlmComment, urIngestSessionPlmIssueReaction, urIngestSessionPlmReaction, urIngestSessionAttachment, urIngestSessionUdiPgpSql, orchestrationNature, orchestrationSession, orchestrationSessionEntry, orchestrationSessionState, orchestrationSessionExec, orchestrationSessionIssue, orchestrationSessionIssueRelation, orchestrationSessionLog, uniformResourceEdge, uniformResourceGraph, surveilrOsqueryMsNode, urIngestSessionOsqueryMsLog, surveilrOsqueryMsDistributedQuery, surveilrOsqueryMsDistributedResult, surveilrOsqueryMsCarve, surveilrOsqueryMsCarvedExtractedFile } from "./models.ts";

export const codeNotebookCellRelations = relations(codeNotebookCell, ({one, many}) => ({
	codeNotebookKernel: one(codeNotebookKernel, {
		fields: [codeNotebookCell.notebookKernelId],
		references: [codeNotebookKernel.codeNotebookKernelId]
	}),
	codeNotebookStates: many(codeNotebookState),
}));

export const codeNotebookKernelRelations = relations(codeNotebookKernel, ({many}) => ({
	codeNotebookCells: many(codeNotebookCell),
}));

export const codeNotebookStateRelations = relations(codeNotebookState, ({one}) => ({
	codeNotebookCell: one(codeNotebookCell, {
		fields: [codeNotebookState.codeNotebookCellId],
		references: [codeNotebookCell.codeNotebookCellId]
	}),
}));

export const partyRelations = relations(party, ({one, many}) => ({
	partyType: one(partyType, {
		fields: [party.partyTypeId],
		references: [partyType.partyTypeId]
	}),
	partyRelations_relatedPartyId: many(partyRelation, {
		relationName: "partyRelation_relatedPartyId_party_partyId"
	}),
	partyRelations_partyId: many(partyRelation, {
		relationName: "partyRelation_partyId_party_partyId"
	}),
	people: many(person),
	organizations: many(organization),
	organizationRoles_organizationId: many(organizationRole, {
		relationName: "organizationRole_organizationId_party_partyId"
	}),
	organizationRoles_personId: many(organizationRole, {
		relationName: "organizationRole_personId_party_partyId"
	}),
	devicePartyRelationships: many(devicePartyRelationship),
}));

export const partyTypeRelations = relations(partyType, ({many}) => ({
	parties: many(party),
}));

export const partyRelationRelations = relations(partyRelation, ({one}) => ({
	partyRelationType: one(partyRelationType, {
		fields: [partyRelation.relationTypeId],
		references: [partyRelationType.partyRelationTypeId]
	}),
	party_relatedPartyId: one(party, {
		fields: [partyRelation.relatedPartyId],
		references: [party.partyId],
		relationName: "partyRelation_relatedPartyId_party_partyId"
	}),
	party_partyId: one(party, {
		fields: [partyRelation.partyId],
		references: [party.partyId],
		relationName: "partyRelation_partyId_party_partyId"
	}),
}));

export const partyRelationTypeRelations = relations(partyRelationType, ({many}) => ({
	partyRelations: many(partyRelation),
}));

export const personRelations = relations(person, ({one}) => ({
	sexType: one(sexType, {
		fields: [person.sexId],
		references: [sexType.sexTypeId]
	}),
	genderType: one(genderType, {
		fields: [person.genderId],
		references: [genderType.genderTypeId]
	}),
	personType: one(personType, {
		fields: [person.personTypeId],
		references: [personType.personTypeId]
	}),
	party: one(party, {
		fields: [person.partyId],
		references: [party.partyId]
	}),
}));

export const sexTypeRelations = relations(sexType, ({many}) => ({
	people: many(person),
}));

export const genderTypeRelations = relations(genderType, ({many}) => ({
	people: many(person),
}));

export const personTypeRelations = relations(personType, ({many}) => ({
	people: many(person),
}));

export const organizationRelations = relations(organization, ({one}) => ({
	party: one(party, {
		fields: [organization.partyId],
		references: [party.partyId]
	}),
}));

export const organizationRoleRelations = relations(organizationRole, ({one}) => ({
	organizationRoleType: one(organizationRoleType, {
		fields: [organizationRole.organizationRoleTypeId],
		references: [organizationRoleType.organizationRoleTypeId]
	}),
	party_organizationId: one(party, {
		fields: [organizationRole.organizationId],
		references: [party.partyId],
		relationName: "organizationRole_organizationId_party_partyId"
	}),
	party_personId: one(party, {
		fields: [organizationRole.personId],
		references: [party.partyId],
		relationName: "organizationRole_personId_party_partyId"
	}),
}));

export const organizationRoleTypeRelations = relations(organizationRoleType, ({many}) => ({
	organizationRoles: many(organizationRole),
}));

export const devicePartyRelationshipRelations = relations(devicePartyRelationship, ({one}) => ({
	party: one(party, {
		fields: [devicePartyRelationship.partyId],
		references: [party.partyId]
	}),
	device: one(device, {
		fields: [devicePartyRelationship.deviceId],
		references: [device.deviceId]
	}),
}));

export const deviceRelations = relations(device, ({many}) => ({
	devicePartyRelationships: many(devicePartyRelationship),
	behaviors: many(behavior),
	urIngestSessions: many(urIngestSession),
	uniformResources: many(uniformResource),
	orchestrationSessions: many(orchestrationSession),
	surveilrOsqueryMsNodes: many(surveilrOsqueryMsNode),
}));

export const behaviorRelations = relations(behavior, ({one, many}) => ({
	assuranceSchema: one(assuranceSchema, {
		fields: [behavior.assuranceSchemaId],
		references: [assuranceSchema.assuranceSchemaId]
	}),
	device: one(device, {
		fields: [behavior.deviceId],
		references: [device.deviceId]
	}),
	urIngestSessions: many(urIngestSession),
	surveilrOsqueryMsNodes: many(surveilrOsqueryMsNode),
}));

export const assuranceSchemaRelations = relations(assuranceSchema, ({many}) => ({
	behaviors: many(behavior),
}));

export const urIngestSessionRelations = relations(urIngestSession, ({one, many}) => ({
	behavior: one(behavior, {
		fields: [urIngestSession.behaviorId],
		references: [behavior.behaviorId]
	}),
	device: one(device, {
		fields: [urIngestSession.deviceId],
		references: [device.deviceId]
	}),
	urIngestSessionFsPaths: many(urIngestSessionFsPath),
	uniformResources: many(uniformResource),
	urIngestSessionFsPathEntries: many(urIngestSessionFsPathEntry),
	urIngestSessionTasks: many(urIngestSessionTask),
	urIngestSessionImapAccounts: many(urIngestSessionImapAccount),
	urIngestSessionImapAcctFolders: many(urIngestSessionImapAcctFolder),
	urIngestSessionImapAcctFolderMessages: many(urIngestSessionImapAcctFolderMessage),
	urIngestSessionPlmAccounts: many(urIngestSessionPlmAccount),
	urIngestSessionPlmAcctProjects: many(urIngestSessionPlmAcctProject),
	urIngestSessionPlmAcctProjectIssues: many(urIngestSessionPlmAcctProjectIssue),
	urIngestSessionUdiPgpSqls: many(urIngestSessionUdiPgpSql),
}));

export const urIngestSessionFsPathRelations = relations(urIngestSessionFsPath, ({one, many}) => ({
	urIngestSession: one(urIngestSession, {
		fields: [urIngestSessionFsPath.ingestSessionId],
		references: [urIngestSession.urIngestSessionId]
	}),
	uniformResources: many(uniformResource),
	urIngestSessionFsPathEntries: many(urIngestSessionFsPathEntry),
}));

export const uniformResourceRelations = relations(uniformResource, ({one, many}) => ({
	urIngestSessionPlmAcctProject: one(urIngestSessionPlmAcctProject, {
		fields: [uniformResource.ingestIssueAcctProjectId],
		references: [urIngestSessionPlmAcctProject.urIngestSessionPlmAcctProjectId]
	}),
	urIngestSessionImapAcctFolderMessage: one(urIngestSessionImapAcctFolderMessage, {
		fields: [uniformResource.ingestSessionImapAcctFolderMessage],
		references: [urIngestSessionImapAcctFolderMessage.urIngestSessionImapAcctFolderMessageId]
	}),
	urIngestSessionFsPath: one(urIngestSessionFsPath, {
		fields: [uniformResource.ingestFsPathId],
		references: [urIngestSessionFsPath.urIngestSessionFsPathId]
	}),
	urIngestSession: one(urIngestSession, {
		fields: [uniformResource.ingestSessionId],
		references: [urIngestSession.urIngestSessionId]
	}),
	device: one(device, {
		fields: [uniformResource.deviceId],
		references: [device.deviceId]
	}),
	uniformResourceTransforms: many(uniformResourceTransform),
	urIngestSessionFsPathEntries: many(urIngestSessionFsPathEntry),
	urIngestSessionTasks: many(urIngestSessionTask),
	urIngestSessionPlmAcctProjectIssues: many(urIngestSessionPlmAcctProjectIssue),
	urIngestSessionAttachments: many(urIngestSessionAttachment),
	urIngestSessionUdiPgpSqls: many(urIngestSessionUdiPgpSql),
	uniformResourceEdges: many(uniformResourceEdge),
}));

export const urIngestSessionPlmAcctProjectRelations = relations(urIngestSessionPlmAcctProject, ({one, many}) => ({
	uniformResources: many(uniformResource),
	urIngestSessionPlmAccount: one(urIngestSessionPlmAccount, {
		fields: [urIngestSessionPlmAcctProject.ingestAccountId],
		references: [urIngestSessionPlmAccount.urIngestSessionPlmAccountId]
	}),
	urIngestSession: one(urIngestSession, {
		fields: [urIngestSessionPlmAcctProject.ingestSessionId],
		references: [urIngestSession.urIngestSessionId]
	}),
	urIngestSessionPlmAcctProjectIssues: many(urIngestSessionPlmAcctProjectIssue),
	urIngestSessionPlmAcctLabels: many(urIngestSessionPlmAcctLabel),
	urIngestSessionPlmMilestones: many(urIngestSessionPlmMilestone),
	urIngestSessionPlmAcctRelationships: many(urIngestSessionPlmAcctRelationship),
}));

export const urIngestSessionImapAcctFolderMessageRelations = relations(urIngestSessionImapAcctFolderMessage, ({one, many}) => ({
	uniformResources: many(uniformResource),
	urIngestSessionImapAcctFolder: one(urIngestSessionImapAcctFolder, {
		fields: [urIngestSessionImapAcctFolderMessage.ingestImapAcctFolderId],
		references: [urIngestSessionImapAcctFolder.urIngestSessionImapAcctFolderId]
	}),
	urIngestSession: one(urIngestSession, {
		fields: [urIngestSessionImapAcctFolderMessage.ingestSessionId],
		references: [urIngestSession.urIngestSessionId]
	}),
}));

export const uniformResourceTransformRelations = relations(uniformResourceTransform, ({one}) => ({
	uniformResource: one(uniformResource, {
		fields: [uniformResourceTransform.uniformResourceId],
		references: [uniformResource.uniformResourceId]
	}),
}));

export const urIngestSessionFsPathEntryRelations = relations(urIngestSessionFsPathEntry, ({one}) => ({
	uniformResource: one(uniformResource, {
		fields: [urIngestSessionFsPathEntry.uniformResourceId],
		references: [uniformResource.uniformResourceId]
	}),
	urIngestSessionFsPath: one(urIngestSessionFsPath, {
		fields: [urIngestSessionFsPathEntry.ingestFsPathId],
		references: [urIngestSessionFsPath.urIngestSessionFsPathId]
	}),
	urIngestSession: one(urIngestSession, {
		fields: [urIngestSessionFsPathEntry.ingestSessionId],
		references: [urIngestSession.urIngestSessionId]
	}),
}));

export const urIngestSessionTaskRelations = relations(urIngestSessionTask, ({one}) => ({
	uniformResource: one(uniformResource, {
		fields: [urIngestSessionTask.uniformResourceId],
		references: [uniformResource.uniformResourceId]
	}),
	urIngestSession: one(urIngestSession, {
		fields: [urIngestSessionTask.ingestSessionId],
		references: [urIngestSession.urIngestSessionId]
	}),
}));

export const urIngestSessionImapAccountRelations = relations(urIngestSessionImapAccount, ({one, many}) => ({
	urIngestSession: one(urIngestSession, {
		fields: [urIngestSessionImapAccount.ingestSessionId],
		references: [urIngestSession.urIngestSessionId]
	}),
	urIngestSessionImapAcctFolders: many(urIngestSessionImapAcctFolder),
}));

export const urIngestSessionImapAcctFolderRelations = relations(urIngestSessionImapAcctFolder, ({one, many}) => ({
	urIngestSessionImapAccount: one(urIngestSessionImapAccount, {
		fields: [urIngestSessionImapAcctFolder.ingestAccountId],
		references: [urIngestSessionImapAccount.urIngestSessionImapAccountId]
	}),
	urIngestSession: one(urIngestSession, {
		fields: [urIngestSessionImapAcctFolder.ingestSessionId],
		references: [urIngestSession.urIngestSessionId]
	}),
	urIngestSessionImapAcctFolderMessages: many(urIngestSessionImapAcctFolderMessage),
}));

export const urIngestSessionPlmAccountRelations = relations(urIngestSessionPlmAccount, ({one, many}) => ({
	urIngestSession: one(urIngestSession, {
		fields: [urIngestSessionPlmAccount.ingestSessionId],
		references: [urIngestSession.urIngestSessionId]
	}),
	urIngestSessionPlmAcctProjects: many(urIngestSessionPlmAcctProject),
}));

export const urIngestSessionPlmAcctProjectIssueRelations = relations(urIngestSessionPlmAcctProjectIssue, ({one, many}) => ({
	urIngestSessionPlmIssueType: one(urIngestSessionPlmIssueType, {
		fields: [urIngestSessionPlmAcctProjectIssue.issueTypeId],
		references: [urIngestSessionPlmIssueType.urIngestSessionPlmIssueTypeId]
	}),
	urIngestSessionPlmUser: one(urIngestSessionPlmUser, {
		fields: [urIngestSessionPlmAcctProjectIssue.user],
		references: [urIngestSessionPlmUser.urIngestSessionPlmUserId]
	}),
	uniformResource: one(uniformResource, {
		fields: [urIngestSessionPlmAcctProjectIssue.uniformResourceId],
		references: [uniformResource.uniformResourceId]
	}),
	urIngestSessionPlmAcctProject: one(urIngestSessionPlmAcctProject, {
		fields: [urIngestSessionPlmAcctProjectIssue.urIngestSessionPlmAcctProjectId],
		references: [urIngestSessionPlmAcctProject.urIngestSessionPlmAcctProjectId]
	}),
	urIngestSession: one(urIngestSession, {
		fields: [urIngestSessionPlmAcctProjectIssue.ingestSessionId],
		references: [urIngestSession.urIngestSessionId]
	}),
	urIngestSessionPlmAcctLabels: many(urIngestSessionPlmAcctLabel),
	urIngestSessionPlmAcctRelationships: many(urIngestSessionPlmAcctRelationship),
	urIngestSessionPlmComments: many(urIngestSessionPlmComment),
	urIngestSessionPlmIssueReactions: many(urIngestSessionPlmIssueReaction),
}));

export const urIngestSessionPlmIssueTypeRelations = relations(urIngestSessionPlmIssueType, ({many}) => ({
	urIngestSessionPlmAcctProjectIssues: many(urIngestSessionPlmAcctProjectIssue),
}));

export const urIngestSessionPlmUserRelations = relations(urIngestSessionPlmUser, ({many}) => ({
	urIngestSessionPlmAcctProjectIssues: many(urIngestSessionPlmAcctProjectIssue),
	urIngestSessionPlmComments: many(urIngestSessionPlmComment),
}));

export const urIngestSessionPlmAcctLabelRelations = relations(urIngestSessionPlmAcctLabel, ({one}) => ({
	urIngestSessionPlmAcctProjectIssue: one(urIngestSessionPlmAcctProjectIssue, {
		fields: [urIngestSessionPlmAcctLabel.urIngestSessionPlmAcctProjectIssueId],
		references: [urIngestSessionPlmAcctProjectIssue.urIngestSessionPlmAcctProjectIssueId]
	}),
	urIngestSessionPlmAcctProject: one(urIngestSessionPlmAcctProject, {
		fields: [urIngestSessionPlmAcctLabel.urIngestSessionPlmAcctProjectId],
		references: [urIngestSessionPlmAcctProject.urIngestSessionPlmAcctProjectId]
	}),
}));

export const urIngestSessionPlmMilestoneRelations = relations(urIngestSessionPlmMilestone, ({one}) => ({
	urIngestSessionPlmAcctProject: one(urIngestSessionPlmAcctProject, {
		fields: [urIngestSessionPlmMilestone.urIngestSessionPlmAcctProjectId],
		references: [urIngestSessionPlmAcctProject.urIngestSessionPlmAcctProjectId]
	}),
}));

export const urIngestSessionPlmAcctRelationshipRelations = relations(urIngestSessionPlmAcctRelationship, ({one}) => ({
	urIngestSessionPlmAcctProjectIssue: one(urIngestSessionPlmAcctProjectIssue, {
		fields: [urIngestSessionPlmAcctRelationship.urIngestSessionPlmAcctProjectIssueIdPrime],
		references: [urIngestSessionPlmAcctProjectIssue.urIngestSessionPlmAcctProjectIssueId]
	}),
	urIngestSessionPlmAcctProject: one(urIngestSessionPlmAcctProject, {
		fields: [urIngestSessionPlmAcctRelationship.urIngestSessionPlmAcctProjectIdPrime],
		references: [urIngestSessionPlmAcctProject.urIngestSessionPlmAcctProjectId]
	}),
}));

export const urIngestSessionPlmCommentRelations = relations(urIngestSessionPlmComment, ({one}) => ({
	urIngestSessionPlmUser: one(urIngestSessionPlmUser, {
		fields: [urIngestSessionPlmComment.user],
		references: [urIngestSessionPlmUser.urIngestSessionPlmUserId]
	}),
	urIngestSessionPlmAcctProjectIssue: one(urIngestSessionPlmAcctProjectIssue, {
		fields: [urIngestSessionPlmComment.urIngestSessionPlmAcctProjectIssueId],
		references: [urIngestSessionPlmAcctProjectIssue.urIngestSessionPlmAcctProjectIssueId]
	}),
}));

export const urIngestSessionPlmIssueReactionRelations = relations(urIngestSessionPlmIssueReaction, ({one}) => ({
	urIngestSessionPlmAcctProjectIssue: one(urIngestSessionPlmAcctProjectIssue, {
		fields: [urIngestSessionPlmIssueReaction.urIngestPlmIssueId],
		references: [urIngestSessionPlmAcctProjectIssue.urIngestSessionPlmAcctProjectIssueId]
	}),
	urIngestSessionPlmReaction: one(urIngestSessionPlmReaction, {
		fields: [urIngestSessionPlmIssueReaction.urIngestPlmReactionId],
		references: [urIngestSessionPlmReaction.urIngestSessionPlmReactionId]
	}),
}));

export const urIngestSessionPlmReactionRelations = relations(urIngestSessionPlmReaction, ({many}) => ({
	urIngestSessionPlmIssueReactions: many(urIngestSessionPlmIssueReaction),
}));

export const urIngestSessionAttachmentRelations = relations(urIngestSessionAttachment, ({one}) => ({
	uniformResource: one(uniformResource, {
		fields: [urIngestSessionAttachment.uniformResourceId],
		references: [uniformResource.uniformResourceId]
	}),
}));

export const urIngestSessionUdiPgpSqlRelations = relations(urIngestSessionUdiPgpSql, ({one}) => ({
	urIngestSession: one(urIngestSession, {
		fields: [urIngestSessionUdiPgpSql.ingestSessionId],
		references: [urIngestSession.urIngestSessionId]
	}),
	uniformResource: one(uniformResource, {
		fields: [urIngestSessionUdiPgpSql.uniformResourceId],
		references: [uniformResource.uniformResourceId]
	}),
}));

export const orchestrationSessionRelations = relations(orchestrationSession, ({one, many}) => ({
	orchestrationNature: one(orchestrationNature, {
		fields: [orchestrationSession.orchestrationNatureId],
		references: [orchestrationNature.orchestrationNatureId]
	}),
	device: one(device, {
		fields: [orchestrationSession.deviceId],
		references: [device.deviceId]
	}),
	orchestrationSessionEntries: many(orchestrationSessionEntry),
	orchestrationSessionStates: many(orchestrationSessionState),
	orchestrationSessionExecs: many(orchestrationSessionExec),
	orchestrationSessionIssues: many(orchestrationSessionIssue),
}));

export const orchestrationNatureRelations = relations(orchestrationNature, ({many}) => ({
	orchestrationSessions: many(orchestrationSession),
}));

export const orchestrationSessionEntryRelations = relations(orchestrationSessionEntry, ({one, many}) => ({
	orchestrationSession: one(orchestrationSession, {
		fields: [orchestrationSessionEntry.sessionId],
		references: [orchestrationSession.orchestrationSessionId]
	}),
	orchestrationSessionStates: many(orchestrationSessionState),
	orchestrationSessionExecs: many(orchestrationSessionExec),
	orchestrationSessionIssues: many(orchestrationSessionIssue),
}));

export const orchestrationSessionStateRelations = relations(orchestrationSessionState, ({one}) => ({
	orchestrationSessionEntry: one(orchestrationSessionEntry, {
		fields: [orchestrationSessionState.sessionEntryId],
		references: [orchestrationSessionEntry.orchestrationSessionEntryId]
	}),
	orchestrationSession: one(orchestrationSession, {
		fields: [orchestrationSessionState.sessionId],
		references: [orchestrationSession.orchestrationSessionId]
	}),
}));

export const orchestrationSessionExecRelations = relations(orchestrationSessionExec, ({one, many}) => ({
	orchestrationSessionExec: one(orchestrationSessionExec, {
		fields: [orchestrationSessionExec.parentExecId],
		references: [orchestrationSessionExec.orchestrationSessionExecId],
		relationName: "orchestrationSessionExec_parentExecId_orchestrationSessionExec_orchestrationSessionExecId"
	}),
	orchestrationSessionExecs: many(orchestrationSessionExec, {
		relationName: "orchestrationSessionExec_parentExecId_orchestrationSessionExec_orchestrationSessionExecId"
	}),
	orchestrationSessionEntry: one(orchestrationSessionEntry, {
		fields: [orchestrationSessionExec.sessionEntryId],
		references: [orchestrationSessionEntry.orchestrationSessionEntryId]
	}),
	orchestrationSession: one(orchestrationSession, {
		fields: [orchestrationSessionExec.sessionId],
		references: [orchestrationSession.orchestrationSessionId]
	}),
}));

export const orchestrationSessionIssueRelations = relations(orchestrationSessionIssue, ({one, many}) => ({
	orchestrationSessionEntry: one(orchestrationSessionEntry, {
		fields: [orchestrationSessionIssue.sessionEntryId],
		references: [orchestrationSessionEntry.orchestrationSessionEntryId]
	}),
	orchestrationSession: one(orchestrationSession, {
		fields: [orchestrationSessionIssue.sessionId],
		references: [orchestrationSession.orchestrationSessionId]
	}),
	orchestrationSessionIssueRelations: many(orchestrationSessionIssueRelation),
}));

export const orchestrationSessionIssueRelationRelations = relations(orchestrationSessionIssueRelation, ({one}) => ({
	orchestrationSessionIssue: one(orchestrationSessionIssue, {
		fields: [orchestrationSessionIssueRelation.issueIdPrime],
		references: [orchestrationSessionIssue.orchestrationSessionIssueId]
	}),
}));

export const orchestrationSessionLogRelations = relations(orchestrationSessionLog, ({one, many}) => ({
	orchestrationSessionLog: one(orchestrationSessionLog, {
		fields: [orchestrationSessionLog.parentExecId],
		references: [orchestrationSessionLog.orchestrationSessionLogId],
		relationName: "orchestrationSessionLog_parentExecId_orchestrationSessionLog_orchestrationSessionLogId"
	}),
	orchestrationSessionLogs: many(orchestrationSessionLog, {
		relationName: "orchestrationSessionLog_parentExecId_orchestrationSessionLog_orchestrationSessionLogId"
	}),
}));

export const uniformResourceEdgeRelations = relations(uniformResourceEdge, ({one}) => ({
	uniformResource: one(uniformResource, {
		fields: [uniformResourceEdge.uniformResourceId],
		references: [uniformResource.uniformResourceId]
	}),
	uniformResourceGraph: one(uniformResourceGraph, {
		fields: [uniformResourceEdge.graphName],
		references: [uniformResourceGraph.name]
	}),
}));

export const uniformResourceGraphRelations = relations(uniformResourceGraph, ({many}) => ({
	uniformResourceEdges: many(uniformResourceEdge),
}));

export const surveilrOsqueryMsNodeRelations = relations(surveilrOsqueryMsNode, ({one, many}) => ({
	behavior: one(behavior, {
		fields: [surveilrOsqueryMsNode.behaviorId],
		references: [behavior.behaviorId]
	}),
	device: one(device, {
		fields: [surveilrOsqueryMsNode.deviceId],
		references: [device.deviceId]
	}),
	urIngestSessionOsqueryMsLogs: many(urIngestSessionOsqueryMsLog),
	surveilrOsqueryMsDistributedQueries: many(surveilrOsqueryMsDistributedQuery),
	surveilrOsqueryMsDistributedResults: many(surveilrOsqueryMsDistributedResult),
	surveilrOsqueryMsCarves: many(surveilrOsqueryMsCarve),
}));

export const urIngestSessionOsqueryMsLogRelations = relations(urIngestSessionOsqueryMsLog, ({one}) => ({
	surveilrOsqueryMsNode: one(surveilrOsqueryMsNode, {
		fields: [urIngestSessionOsqueryMsLog.nodeKey],
		references: [surveilrOsqueryMsNode.nodeKey]
	}),
}));

export const surveilrOsqueryMsDistributedQueryRelations = relations(surveilrOsqueryMsDistributedQuery, ({one, many}) => ({
	surveilrOsqueryMsNode: one(surveilrOsqueryMsNode, {
		fields: [surveilrOsqueryMsDistributedQuery.nodeKey],
		references: [surveilrOsqueryMsNode.nodeKey]
	}),
	surveilrOsqueryMsDistributedResults: many(surveilrOsqueryMsDistributedResult),
}));

export const surveilrOsqueryMsDistributedResultRelations = relations(surveilrOsqueryMsDistributedResult, ({one}) => ({
	surveilrOsqueryMsNode: one(surveilrOsqueryMsNode, {
		fields: [surveilrOsqueryMsDistributedResult.nodeKey],
		references: [surveilrOsqueryMsNode.nodeKey]
	}),
	surveilrOsqueryMsDistributedQuery: one(surveilrOsqueryMsDistributedQuery, {
		fields: [surveilrOsqueryMsDistributedResult.queryId],
		references: [surveilrOsqueryMsDistributedQuery.queryId]
	}),
}));

export const surveilrOsqueryMsCarveRelations = relations(surveilrOsqueryMsCarve, ({one, many}) => ({
	surveilrOsqueryMsNode: one(surveilrOsqueryMsNode, {
		fields: [surveilrOsqueryMsCarve.nodeKey],
		references: [surveilrOsqueryMsNode.nodeKey]
	}),
	surveilrOsqueryMsCarvedExtractedFiles: many(surveilrOsqueryMsCarvedExtractedFile),
}));

export const surveilrOsqueryMsCarvedExtractedFileRelations = relations(surveilrOsqueryMsCarvedExtractedFile, ({one}) => ({
	surveilrOsqueryMsCarve: one(surveilrOsqueryMsCarve, {
		fields: [surveilrOsqueryMsCarvedExtractedFile.carveGuid],
		references: [surveilrOsqueryMsCarve.carveGuid]
	}),
}));