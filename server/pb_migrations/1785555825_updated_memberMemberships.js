/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_mbrmbrshp001")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE INDEX idx_mm_member_enddate ON memberMemberships (member, endDate)",
      "CREATE INDEX `idx_memberMemberships_created` ON `memberMemberships` (`created`)",
      "CREATE INDEX `idx_memberMemberships_branch_created` ON `memberMemberships` (`branch`, `created`)",
      "CREATE INDEX `idx_memberMemberships_status_endDate` ON `memberMemberships` (`status`, `endDate`)"
    ]
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_mbrmbrshp001")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE INDEX idx_mm_member_enddate ON memberMemberships (member, endDate)"
    ]
  }, collection)

  return app.save(collection)
})
