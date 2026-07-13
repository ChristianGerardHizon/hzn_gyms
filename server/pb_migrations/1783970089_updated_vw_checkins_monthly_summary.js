/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3825955198")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  strftime('%Y-%m', c.checkInTime, 'localtime') AS checkin_month,\n  c.branch,\n  c.method,\n  COUNT(*) AS checkin_count,\n  COUNT(DISTINCT c.member) AS unique_members\nFROM checkIns c\nGROUP BY strftime('%Y-%m', c.checkInTime, 'localtime'), c.branch, c.method\nORDER BY checkin_month DESC"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_HSCW")

  // remove field
  collection.fields.removeById("_clone_zVAb")

  // add field
  collection.fields.addAt(2, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_4vQq",
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
    "id": "_clone_XtYk",
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
  const collection = app.findCollectionByNameOrId("pbc_3825955198")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  strftime('%Y-%m', c.checkInTime) AS checkin_month,\n  c.branch,\n  c.method,\n  COUNT(*) AS checkin_count,\n  COUNT(DISTINCT c.member) AS unique_members\nFROM checkIns c\nGROUP BY strftime('%Y-%m', c.checkInTime), c.branch, c.method\nORDER BY checkin_month DESC"
  }, collection)

  // add field
  collection.fields.addAt(2, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_HSCW",
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
    "id": "_clone_zVAb",
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
  collection.fields.removeById("_clone_4vQq")

  // remove field
  collection.fields.removeById("_clone_XtYk")

  return app.save(collection)
})
