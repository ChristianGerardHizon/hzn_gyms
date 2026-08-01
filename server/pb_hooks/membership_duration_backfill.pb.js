/// <reference path="../pb_data/types.d.ts" />

// Idempotent backfill after memberships durationDays → durationValue/durationUnit.
// We never hand-edit generated pb_migrations; this runs on bootstrap so staging/
// production still get safe defaults and common calendar conversions.
onBootstrap((e) => {
    e.next()

    try {
        const records = $app.findAllRecords("memberships")
        const conversions = {
            7: { value: 1, unit: "weeks" },
            30: { value: 1, unit: "months" },
            90: { value: 3, unit: "months" },
            180: { value: 6, unit: "months" },
            365: { value: 1, unit: "years" },
        }

        let updated = 0
        for (const record of records) {
            let unit = (record.getString("durationUnit") || "").trim()
            let value = Number(record.get("durationValue") || 0)
            let dirty = false

            if (!unit) {
                unit = "days"
                dirty = true
            }

            if (unit === "days" && conversions[value]) {
                const next = conversions[value]
                value = next.value
                unit = next.unit
                dirty = true
            }

            if (!dirty) continue

            record.set("durationUnit", unit)
            record.set("durationValue", value)
            $app.save(record)
            updated++
        }

        if (updated > 0) {
            console.log(`[membership_duration_backfill] updated ${updated} plan(s)`)
        }
    } catch (err) {
        console.log(`[membership_duration_backfill] skipped: ${err}`)
    }
})
