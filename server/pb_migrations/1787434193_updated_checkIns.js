/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_checkins001")

  // add field
  collection.fields.addAt(10, new Field({
    "help": "",
    "hidden": false,
    "id": "bool_ci_isvoided",
    "name": "isVoided",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  // add field
  collection.fields.addAt(11, new Field({
    "help": "",
    "hidden": false,
    "id": "date_ci_voidedat",
    "max": "",
    "min": "",
    "name": "voidedAt",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "date"
  }))

  // add field
  collection.fields.addAt(12, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_3841632486",
    "help": "",
    "hidden": false,
    "id": "rel_ci_voidedby",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "voidedBy",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // add field
  collection.fields.addAt(13, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "text_ci_voidreason",
    "max": 0,
    "min": 0,
    "name": "voidReason",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_checkins001")

  // remove field
  collection.fields.removeById("bool_ci_isvoided")

  // remove field
  collection.fields.removeById("date_ci_voidedat")

  // remove field
  collection.fields.removeById("rel_ci_voidedby")

  // remove field
  collection.fields.removeById("text_ci_voidreason")

  return app.save(collection)
})
