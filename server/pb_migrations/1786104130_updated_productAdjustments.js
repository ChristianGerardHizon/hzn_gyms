/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3839869033")

  // add field
  collection.fields.addAt(11, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2697449135",
    "help": "",
    "hidden": false,
    "id": "relation3846946821",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "sale",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // add field
  collection.fields.addAt(12, new Field({
    "help": "",
    "hidden": false,
    "id": "bool3977659631",
    "name": "isVoided",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  // add field
  collection.fields.addAt(13, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_3839869033",
    "help": "",
    "hidden": false,
    "id": "relation3386939109",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "voidsAdjustment",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // add field
  collection.fields.addAt(14, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_3841632486",
    "help": "",
    "hidden": false,
    "id": "relation2568647871",
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
  const collection = app.findCollectionByNameOrId("pbc_3839869033")

  // remove field
  collection.fields.removeById("relation3846946821")

  // remove field
  collection.fields.removeById("bool3977659631")

  // remove field
  collection.fields.removeById("relation3386939109")

  // remove field
  collection.fields.removeById("relation2568647871")

  return app.save(collection)
})
