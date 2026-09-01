/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  // add field
  collection.fields.addAt(15, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2873630990",
    "help": "",
    "hidden": false,
    "id": "relation3253625724",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "organization",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  // remove field
  collection.fields.removeById("relation3253625724")

  return app.save(collection)
})
