/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE INDEX idx_sales_created ON sales (created)",
      "CREATE INDEX idx_sales_branch_created ON sales (branch, created)",
      "CREATE INDEX idx_sales_receiptNumber ON sales (receiptNumber)",
      "CREATE INDEX idx_sales_member_created ON sales (member, created)",
      "CREATE INDEX `idx_sales_status` ON `sales` (`status`)",
      "CREATE UNIQUE INDEX `idx_sales_idempotencyKey` ON `sales` (`idempotencyKey`) WHERE `idempotencyKey` != ''"
    ]
  }, collection)

  // add field
  collection.fields.addAt(15, new Field({
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
  const collection = app.findCollectionByNameOrId("pbc_2697449135")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE INDEX idx_sales_created ON sales (created)",
      "CREATE INDEX idx_sales_branch_created ON sales (branch, created)",
      "CREATE INDEX idx_sales_receiptNumber ON sales (receiptNumber)",
      "CREATE INDEX idx_sales_member_created ON sales (member, created)",
      "CREATE INDEX `idx_sales_status` ON `sales` (`status`)"
    ]
  }, collection)

  // remove field
  collection.fields.removeById("text_idempotency_key")

  return app.save(collection)
})
