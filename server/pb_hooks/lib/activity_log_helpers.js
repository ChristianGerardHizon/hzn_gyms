/// Shared helpers for activity log PocketBase hooks.

/** Collections that should never produce activity log entries. */
const EXCLUDED_COLLECTIONS = new Set([
    "activityLogs",
    "carts",
    "cartItems",
    "_superusers",
    "_authOrigins",
    "_externalAuths",
    "_mfas",
    "_otps",
]);

/** Field names omitted from diffs (sensitive or noisy). */
const EXCLUDED_FIELDS = new Set([
    "id",
    "collectionId",
    "collectionName",
    "created",
    "updated",
    "expand",
    "password",
    "passwordConfirm",
    "oldPassword",
    "tokenKey",
    "emailVisibility",
    "verified",
]);

/** Domain actor fallback fields checked on the record (first match wins). */
const ACTOR_FALLBACK_FIELDS = [
    "voidedBy",
    "cashier",
    "soldBy",
    "addedBy",
    "checkedInBy",
];

/** Human-readable labels for collections. */
const COLLECTION_LABELS = {
    members: "Member",
    memberCards: "Member Card",
    memberships: "Membership Plan",
    memberMemberships: "Member Membership",
    membershipAddOns: "Membership Add-on",
    memberMembershipAddOns: "Member Membership Add-on",
    checkIns: "Check-in",
    products: "Product",
    productCategories: "Product Category",
    productStocks: "Product Stock",
    productLots: "Product Lot",
    productAdjustments: "Stock Adjustment",
    posGroups: "Cashier Group",
    posGroupItems: "Cashier Group Item",
    sales: "Sale",
    saleItems: "Sale Item",
    payments: "Payment",
    users: "User",
    userRoles: "Role",
    branches: "Branch",
    printerConfigs: "Printer",
    quantityUnits: "Quantity Unit",
};

/**
 * @param {string} name
 * @returns {boolean}
 */
function shouldLogCollection(name) {
    if (!name || EXCLUDED_COLLECTIONS.has(name)) {
        return false;
    }
    if (name.startsWith("vw_") || name.startsWith("_")) {
        return false;
    }
    return true;
}

/**
 * @param {*} value
 * @returns {*}
 */
function normalizeValue(value) {
    if (value === undefined) {
        return null;
    }
    if (value === null || value === "") {
        return null;
    }
    if (Array.isArray(value)) {
        if (value.length === 0) {
            return null;
        }
        return value.length === 1 ? value[0] : value;
    }
    return value;
}

/**
 * @param {*} a
 * @param {*} b
 * @returns {boolean}
 */
function valuesEqual(a, b) {
    const left = normalizeValue(a);
    const right = normalizeValue(b);
    if (left === right) {
        return true;
    }
    try {
        return JSON.stringify(left) === JSON.stringify(right);
    } catch (_) {
        return false;
    }
}

/**
 * @param {Record<string, *>} data
 * @param {string} fieldName
 * @returns {*}
 */
function getFieldValueFromExport(data, fieldName) {
    if (fieldName === "avatar" || fieldName === "photo") {
        const raw = data[fieldName];
        return raw ? "[file changed]" : null;
    }
    return normalizeValue(data[fieldName]);
}

/**
 * Builds field diffs for a deleted record (all non-system fields → null).
 *
 * @param {core.Record} record
 * @returns {Record<string, {old: *, new: *}>}
 */
function computeDeleteDiff(record) {
    /** @type {Record<string, {old: *, new: *}>} */
    const changes = {};
    const data = record.publicExport();

    Object.keys(data).forEach((name) => {
        if (EXCLUDED_FIELDS.has(name)) {
            return;
        }
        const oldVal = getFieldValueFromExport(data, name);
        if (oldVal !== null) {
            changes[name] = { old: oldVal, new: null };
        }
    });

    return changes;
}

/**
 * @param {core.Record|null|undefined} original
 * @param {core.Record} current
 * @returns {Record<string, {old: *, new: *}>}
 */
function computeFieldDiff(original, current) {
    /** @type {Record<string, {old: *, new: *}>} */
    const changes = {};

    const currentData = current.publicExport();
    /** @type {Record<string, *>} */
    const originalData = original ? original.publicExport() : {};

    const keys = new Set([
        ...Object.keys(currentData),
        ...Object.keys(originalData),
    ]);

    keys.forEach((name) => {
        if (EXCLUDED_FIELDS.has(name)) {
            return;
        }

        const oldVal = original ? getFieldValueFromExport(originalData, name) : null;
        const newVal = getFieldValueFromExport(currentData, name);

        if (!valuesEqual(oldVal, newVal)) {
            changes[name] = { old: oldVal, new: newVal };
        }
    });

    return changes;
}

/**
 * @param {core.Record} record
 * @returns {string}
 */
function getRecordLabel(record) {
    const collectionName = record.collection().name;

    if (collectionName === "sales") {
        const receipt = record.getString("receiptNumber");
        const descriptor = record.getString("descriptor");
        if (receipt) {
            return descriptor ? `${descriptor} (#${receipt})` : `#${receipt}`;
        }
    }

    const labelFields = [
        "name",
        "descriptor",
        "receiptNumber",
        "email",
        "title",
        "mobileNumber",
    ];
    for (const field of labelFields) {
        const value = record.getString(field);
        if (value) {
            return value;
        }
    }

    return record.id;
}

/**
 * @param {string} collectionName
 * @param {string} action
 * @param {core.Record} record
 * @param {Record<string, {old: *, new: *}>} changes
 * @returns {string}
 */
function buildSummary(collectionName, action, record, changes) {
    const entityLabel = COLLECTION_LABELS[collectionName] || collectionName;
    const recordLabel = getRecordLabel(record);

    const actionPast = {
        create: "created",
        update: "updated",
        delete: "deleted",
    }[action] || action;

    if (collectionName === "sales" && action === "update" && changes.status) {
        const newStatus = changes.status.new;
        if (newStatus === "voided") {
            return `Voided ${entityLabel}: ${recordLabel}`;
        }
        if (newStatus === "refunded") {
            return `Refunded ${entityLabel}: ${recordLabel}`;
        }
    }

    if (
        action === "update" &&
        changes.isDeleted &&
        changes.isDeleted.new === true
    ) {
        return `Deleted ${entityLabel}: ${recordLabel}`;
    }

    return `${actionPast.charAt(0).toUpperCase()}${actionPast.slice(1)} ${entityLabel}: ${recordLabel}`;
}

/**
 * @param {core.Record|null|undefined} authRecord
 * @returns {boolean}
 */
function isAppUserAuth(authRecord) {
    if (!authRecord || !authRecord.id) {
        return false;
    }

    try {
        const collectionName = authRecord.collection().name;
        return collectionName === "users";
    } catch (_) {
        return authRecord.collectionName === "users";
    }
}

/**
 * @param {core.Record} record
 * @param {core.RequestEvent|core.RecordCreateEvent|core.RecordUpdateEvent|core.RecordDeleteEvent|null} event
 * @returns {string}
 */
function resolveActorId(record, event) {
    if (event && isAppUserAuth(event.auth)) {
        return event.auth.id;
    }

    if (event && event.httpContext) {
        try {
            const info = $apis.requestInfo(event.httpContext);
            if (info && isAppUserAuth(info.authRecord)) {
                return info.authRecord.id;
            }
        } catch (_) {
            // ignore
        }
    }

    for (const field of ACTOR_FALLBACK_FIELDS) {
        const value = normalizeValue(record.get(field));
        if (typeof value === "string" && value.length > 0) {
            return value;
        }
    }

    return "";
}

/**
 * @param {core.Record} record
 * @returns {string}
 */
function resolveBranchId(record) {
    const branch = normalizeValue(record.get("branch"));
    if (typeof branch === "string" && branch.length > 0) {
        return branch;
    }
    return "";
}

/**
 * @param {Record<string, {old: *, new: *}>} changes
 * @returns {Record<string, {old: *, new: *}>}
 */
function sanitizeChanges(changes) {
    /** @type {Record<string, {old: *, new: *}>} */
    const sanitized = {};
    Object.keys(changes).forEach((key) => {
        if (EXCLUDED_FIELDS.has(key)) {
            return;
        }
        sanitized[key] = changes[key];
    });
    return sanitized;
}

/**
 * Returns the pre-mutation record state when available.
 *
 * @param {core.Record} record
 * @returns {core.Record|null}
 */
function getOriginalRecord(record) {
    if (typeof record.original === "function") {
        return record.original();
    }
    if (typeof record.originalCopy === "function") {
        return record.originalCopy();
    }

    try {
        return $app.findRecordById(record.collection().name, record.id);
    } catch (_) {
        return null;
    }
}

module.exports = {
    EXCLUDED_COLLECTIONS,
    shouldLogCollection,
    computeFieldDiff,
    computeDeleteDiff,
    buildSummary,
    resolveActorId,
    resolveBranchId,
    sanitizeChanges,
    getRecordLabel,
    getOriginalRecord,
    COLLECTION_LABELS,
};
