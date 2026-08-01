/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_checkins001")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE INDEX `idx_checkIns_checkInTime` ON `checkIns` (`checkInTime`)",
      "CREATE INDEX `idx_checkIns_branch_checkInTime` ON `checkIns` (`branch`, `checkInTime`)"
    ]
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_checkins001")

  // update collection data
  unmarshal({
    "indexes": []
  }, collection)

  return app.save(collection)
})
