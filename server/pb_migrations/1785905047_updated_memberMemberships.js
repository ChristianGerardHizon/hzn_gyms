/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_mbrmbrshp001")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE INDEX idx_mm_member_enddate ON memberMemberships (member, endDate)",
      "CREATE INDEX `idx_memberMemberships_created` ON `memberMemberships` (`created`)",
      "CREATE INDEX `idx_memberMemberships_branch_created` ON `memberMemberships` (`branch`, `created`)",
      "CREATE INDEX `idx_memberMemberships_status_endDate` ON `memberMemberships` (`status`, `endDate`)",
      "CREATE UNIQUE INDEX `idx_memberMemberships_idempotencyKey` ON `memberMemberships` (`idempotencyKey`) WHERE `idempotencyKey` != ''"
    ]
  }, collection)

  // add field
  collection.fields.addAt(12, new Field({
    "autogeneratePattern": "",
    "help": "Client-generated UUID to make creates idempotent on retry",
    "hidden": false,
    "id": "text_idempotency_key",
    "max": 64,
    "min": 0,
    "name": "idempotencyKey",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  return app.save(collection)
}, (app) => {
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

  // remove field
  collection.fields.removeById("text_idempotency_key")

  return app.save(collection)
})
