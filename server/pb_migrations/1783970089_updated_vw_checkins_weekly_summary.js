/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_1774506076")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  date(c.checkInTime, 'localtime', '-' || ((cast(strftime('%w', c.checkInTime, 'localtime') as integer) + 6) % 7) || ' days') AS week_start,\n  c.branch,\n  c.method,\n  COUNT(*) AS checkin_count,\n  COUNT(DISTINCT c.member) AS unique_members\nFROM checkIns c\nGROUP BY date(c.checkInTime, 'localtime', '-' || ((cast(strftime('%w', c.checkInTime, 'localtime') as integer) + 6) % 7) || ' days'), c.branch, c.method\nORDER BY week_start DESC"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_VI9I")

  // remove field
  collection.fields.removeById("_clone_5AIo")

  // add field
  collection.fields.addAt(2, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_ym1D",
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
    "id": "_clone_sEjQ",
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
  const collection = app.findCollectionByNameOrId("pbc_1774506076")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  date(c.checkInTime, '-' || ((cast(strftime('%w', c.checkInTime) as integer) + 6) % 7) || ' days') AS week_start,\n  c.branch,\n  c.method,\n  COUNT(*) AS checkin_count,\n  COUNT(DISTINCT c.member) AS unique_members\nFROM checkIns c\nGROUP BY date(c.checkInTime, '-' || ((cast(strftime('%w', c.checkInTime) as integer) + 6) % 7) || ' days'), c.branch, c.method\nORDER BY week_start DESC"
  }, collection)

  // add field
  collection.fields.addAt(2, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_VI9I",
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
    "id": "_clone_5AIo",
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
  collection.fields.removeById("_clone_ym1D")

  // remove field
  collection.fields.removeById("_clone_sEjQ")

  return app.save(collection)
})
