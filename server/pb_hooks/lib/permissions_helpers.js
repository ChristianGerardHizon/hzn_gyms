/// <reference path="../../pb_data/types.d.ts" />

// Shared helpers for reading userRoles.permissions (JSON field).

// `permissions` is a JSON-typed field; `record.get()` on a JSON field
// returns a raw types.JSONRaw (a byte-array wrapper), not a plain JS array,
// so it must be decoded via `.string()` + JSON.parse before use.
function readPermissions(role) {
    const raw = role.get("permissions");
    if (!raw) return [];
    if (Array.isArray(raw) && raw.every((v) => typeof v === "string")) {
        // Already a plain string array (defensive: some JSVM versions may
        // auto-unmarshal JSON fields directly).
        return raw;
    }
    try {
        const jsonString = typeof raw.string === "function" ? raw.string() : String(raw);
        const parsed = JSON.parse(jsonString);
        return Array.isArray(parsed) ? parsed : [];
    } catch (_) {
        return [];
    }
}

function roleHasPermission(app, roleId, permissionKey) {
    if (!roleId) return false;
    try {
        const role = app.findRecordById("userRoles", roleId);
        const permissions = readPermissions(role);
        return permissions.indexOf(permissionKey) !== -1;
    } catch (_) {
        return false;
    }
}

module.exports = {
    readPermissions: readPermissions,
    roleHasPermission: roleHasPermission,
};
