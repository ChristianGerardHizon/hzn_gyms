/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_payments001")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE INDEX `idx_payments_sale` ON `payments` (`sale`)",
      "CREATE UNIQUE INDEX `idx_payments_idempotencyKey` ON `payments` (`idempotencyKey`) WHERE `idempotencyKey` != ''"
    ]
  }, collection)

  // add field
  collection.fields.addAt(10, new Field({
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
  const collection = app.findCollectionByNameOrId("pbc_payments001")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE INDEX `idx_payments_sale` ON `payments` (`sale`)"
    ]
  }, collection)

  // remove field
  collection.fields.removeById("text_idempotency_key")

  return app.save(collection)
})
