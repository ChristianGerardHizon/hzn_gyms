/// <reference path="../../pb_data/types.d.ts" />

// Helpers for POST /api/ebe/update-created (superuser-only).
// See docs/update_created_endpoint.md

const ALLOWED_COLLECTIONS = {
    members: true,
    sales: true,
}

function normalizeCreated(value) {
    const raw = (value || "").toString().trim()
    if (!raw) {
        throw new BadRequestError("created is required")
    }

    // PocketBase autodates use UTC strings like "2024-01-15 08:00:00.000Z".
    // DateTime also accepts ISO "T" separators.
    const dt = new DateTime(raw)
    if (dt.isZero()) {
        throw new BadRequestError("created must be a valid datetime")
    }

    return dt.string()
}

function applyUpdate(item) {
    const collection = (item.collection || "").toString().trim()
    const id = (item.id || "").toString().trim()
    const created = normalizeCreated(item.created)

    if (!ALLOWED_COLLECTIONS[collection]) {
        throw new BadRequestError(
            "collection must be one of: " + Object.keys(ALLOWED_COLLECTIONS).join(", "),
        )
    }
    if (!id) {
        throw new BadRequestError("id is required")
    }

    const record = $app.findRecordById(collection, id)
    const previous = record.getString("created")

    record.setRaw("created", created)
    $app.save(record)

    return {
        collection: collection,
        id: id,
        previousCreated: previous,
        created: record.getString("created"),
    }
}

module.exports = {
    applyUpdate: applyUpdate,
}
