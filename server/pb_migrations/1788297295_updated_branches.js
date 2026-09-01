/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2358601297")

  // update field
  collection.fields.addAt(11, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2873630990",
    "help": "",
    "hidden": false,
    "id": "relation3253625724",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "organization",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2358601297")

  // update field
  collection.fields.addAt(11, new Field({
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
})
