/// <reference path="../pb_data/types.d.ts" />

// Backdate system `created` on members and sales.
//
// REQUIRES SUPERUSER AUTH — $apis.requireSuperuserAuth() rejects
// guests and normal `users` tokens (app admins included). Authenticate
// against `_superusers` and send Authorization: <token>.
//
// Docs: docs/update_created_endpoint.md
//
// POST /api/ebe/update-created
//
// Single:
//   { "collection": "members"|"sales", "id": "...", "created": "2024-01-15 08:00:00.000Z" }
//
// Batch:
//   { "updates": [ { "collection": "...", "id": "...", "created": "..." }, ... ] }

routerAdd(
    "POST",
    "/api/ebe/update-created",
    (e) => {
        const { applyUpdate } = require(`${__hooks}/lib/update_created_helpers.js`)

        const body = e.requestInfo().body || {}
        const updates = Array.isArray(body.updates) ? body.updates : [body]

        if (updates.length === 0) {
            throw new BadRequestError("no updates provided")
        }

        const results = []
        for (let i = 0; i < updates.length; i++) {
            results.push(applyUpdate(updates[i] || {}))
        }

        return e.json(200, {
            success: true,
            count: results.length,
            results: results,
        })
    },
    // Superuser (_superusers) token required — see docs/update_created_endpoint.md
    $apis.requireSuperuserAuth(),
)
