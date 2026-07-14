/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2278083390")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  DATE(c.checkInTime, 'localtime') AS checkin_date,\n  c.branch,\n  c.method,\n  COUNT(*) AS checkin_count,\n  COUNT(DISTINCT c.member) AS unique_members\nFROM checkIns c\nGROUP BY DATE(c.checkInTime, 'localtime'), c.branch, c.method\nORDER BY checkin_date DESC"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_ehR1")

  // remove field
  collection.fields.removeById("_clone_zgjO")

  // add field
  collection.fields.addAt(2, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_z2qo",
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
    "id": "_clone_fkeO",
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
  const collection = app.findCollectionByNameOrId("pbc_2278083390")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  DATE(c.checkInTime) AS checkin_date,\n  c.branch,\n  c.method,\n  COUNT(*) AS checkin_count,\n  COUNT(DISTINCT c.member) AS unique_members\nFROM checkIns c\nGROUP BY DATE(c.checkInTime), c.branch, c.method\nORDER BY checkin_date DESC"
  }, collection)

  // add field
  collection.fields.addAt(2, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_ehR1",
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
    "id": "_clone_zgjO",
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
  collection.fields.removeById("_clone_z2qo")

  // remove field
  collection.fields.removeById("_clone_fkeO")

  return app.save(collection)
})
