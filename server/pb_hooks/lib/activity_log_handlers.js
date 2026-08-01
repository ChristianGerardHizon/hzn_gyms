/// Activity log hook handlers (required from isolated hook callbacks).

const helpers = require(`${__hooks}/lib/activity_log_helpers.js`);

/**
 * @param {string} action
 * @param {core.Record} record
 * @param {core.Record|null} original
 * @param {core.RecordCreateEvent|core.RecordUpdateEvent|core.RecordDeleteEvent} event
 */
function writeActivityLog(action, record, original, event) {
    const collectionName = record.collection().name;
    if (!helpers.shouldLogCollection(collectionName)) {
        return;
    }

    let changes = {};
    if (action === "create") {
        changes = helpers.computeFieldDiff(null, record);
    } else if (action === "update") {
        changes = helpers.computeFieldDiff(original, record);
        if (Object.keys(changes).length === 0) {
            return;
        }
    } else if (action === "delete") {
        changes = helpers.computeDeleteDiff(record);
    }

    changes = helpers.sanitizeChanges(changes);
    if (action !== "delete" && Object.keys(changes).length === 0) {
        return;
    }

    const summary = helpers.buildSummary(collectionName, action, record, changes);
    const actorId = helpers.resolveActorId(record, event);
    const branchId = helpers.resolveBranchId(record);

    const logsCollection = $app.findCollectionByNameOrId("activityLogs");
    const logRecord = new Record(logsCollection);

    logRecord.set("action", action);
    logRecord.set("collection", collectionName);
    logRecord.set("recordId", record.id);
    logRecord.set("summary", summary);
    logRecord.set("changes", changes);

    if (actorId) {
        logRecord.set("actor", actorId);
    }
    if (branchId) {
        logRecord.set("branch", branchId);
    }

    /** @type {Record<string, *>} */
    const metadata = {};
    if (event && event.httpContext) {
        try {
            const info = $apis.requestInfo(event.httpContext);
            if (info && info.realIP) {
                metadata.userIP = info.realIP;
            }
            if (info && info.authRecord && info.authRecord.collection().name === "_superusers") {
                metadata.superuserEmail = info.authRecord.getString("email");
            }
        } catch (_) {
            // ignore
        }
    } else if (event && event.auth && event.auth.collection().name === "_superusers") {
        metadata.superuserEmail = event.auth.getString("email");
    }
    if (Object.keys(metadata).length > 0) {
        logRecord.set("metadata", metadata);
    }

    $app.save(logRecord);
}

/**
 * @param {core.RecordCreateEvent} e
 */
function onRecordCreateRequest(e) {
    e.next();
    try {
        writeActivityLog("create", e.record, null, e);
    } catch (err) {
        console.error("activity_log create hook failed:", err);
    }
}

/**
 * @param {core.RecordUpdateEvent} e
 */
function onRecordUpdateRequest(e) {
    const original = helpers.getOriginalRecord(e.record);
    e.next();
    try {
        writeActivityLog("update", e.record, original, e);
    } catch (err) {
        console.error("activity_log update hook failed:", err);
    }
}

/**
 * @param {core.RecordDeleteEvent} e
 */
function onRecordDeleteRequest(e) {
    const deleted = helpers.getOriginalRecord(e.record) || e.record;
    e.next();
    try {
        writeActivityLog("delete", deleted, null, e);
    } catch (err) {
        console.error("activity_log delete hook failed:", err);
    }
}

module.exports = {
    onRecordCreateRequest,
    onRecordUpdateRequest,
    onRecordDeleteRequest,
};
