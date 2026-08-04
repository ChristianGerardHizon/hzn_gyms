/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_1960985837")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  strftime('%Y', c.checkInTime, '+8 hours') AS checkin_year,\n  c.branch,\n  c.method,\n  COUNT(*) AS checkin_count,\n  COUNT(DISTINCT c.member) AS unique_members\nFROM checkIns c\nGROUP BY strftime('%Y', c.checkInTime, '+8 hours'), c.branch, c.method\nORDER BY checkin_year DESC"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_BZ6F")

  // remove field
  collection.fields.removeById("_clone_xfIL")

  // add field
  collection.fields.addAt(2, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_owGv",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "help": "",
    "hidden": false,
    "id": "_clone_vGcW",
    "maxSelect": 1,
    "name": "method",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "manual",
      "rfid"
    ]
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_1960985837")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  strftime('%Y', c.checkInTime, 'localtime') AS checkin_year,\n  c.branch,\n  c.method,\n  COUNT(*) AS checkin_count,\n  COUNT(DISTINCT c.member) AS unique_members\nFROM checkIns c\nGROUP BY strftime('%Y', c.checkInTime, 'localtime'), c.branch, c.method\nORDER BY checkin_year DESC"
  }, collection)

  // add field
  collection.fields.addAt(2, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_BZ6F",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "help": "",
    "hidden": false,
    "id": "_clone_xfIL",
    "maxSelect": 1,
    "name": "method",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "manual",
      "rfid"
    ]
  }))

  // remove field
  collection.fields.removeById("_clone_owGv")

  // remove field
  collection.fields.removeById("_clone_vGcW")

  return app.save(collection)
})
