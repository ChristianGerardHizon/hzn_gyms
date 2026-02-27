/// Migration: Add voidedBy relation field to sales collection.
/// Tracks which user voided a sale (optional, only set when status = "voided").

migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135")

  collection.fields.add(new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_3841632486",
    "hidden": false,
    "id": "relation_voidedBy",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "voidedBy",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135")

  collection.fields.removeById("relation_voidedBy")

  return app.save(collection)
})
