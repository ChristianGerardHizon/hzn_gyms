/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3509725051")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  date(s.created, 'localtime', '-' || ((cast(strftime('%w', s.created, 'localtime') as integer) + 6) % 7) || ' days') AS week_start,\n  p.paymentMethod,\n  s.branch,\n  COUNT(DISTINCT s.id) AS transaction_count,\n  SUM(p.amount) AS total_revenue,\n  AVG(p.amount) AS avg_transaction_value\nFROM sales s\nLEFT JOIN payments p ON s.id = p.sale\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND s.status IN ('completed', 'paid')\nGROUP BY date(s.created, 'localtime', '-' || ((cast(strftime('%w', s.created, 'localtime') as integer) + 6) % 7) || ' days'), p.paymentMethod, s.branch\nORDER BY week_start DESC"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_CIDg")

  // remove field
  collection.fields.removeById("_clone_dZwV")

  // add field
  collection.fields.addAt(2, new Field({
    "help": "",
    "hidden": false,
    "id": "_clone_DgYL",
    "maxSelect": 1,
    "name": "paymentMethod",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "select",
    "values": [
      "cash",
      "card",
      "bankTransfer",
      "check"
    ]
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_6Nw1",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3509725051")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  date(s.created, '-' || ((cast(strftime('%w', s.created) as integer) + 6) % 7) || ' days') AS week_start,\n  p.paymentMethod,\n  s.branch,\n  COUNT(DISTINCT s.id) AS transaction_count,\n  SUM(p.amount) AS total_revenue,\n  AVG(p.amount) AS avg_transaction_value\nFROM sales s\nLEFT JOIN payments p ON s.id = p.sale\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND s.status = 'completed'\nGROUP BY date(s.created, '-' || ((cast(strftime('%w', s.created) as integer) + 6) % 7) || ' days'), p.paymentMethod, s.branch\nORDER BY week_start DESC"
  }, collection)

  // add field
  collection.fields.addAt(2, new Field({
    "help": "",
    "hidden": false,
    "id": "_clone_CIDg",
    "maxSelect": 1,
    "name": "paymentMethod",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "select",
    "values": [
      "cash",
      "card",
      "bankTransfer",
      "check"
    ]
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_dZwV",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // remove field
  collection.fields.removeById("_clone_DgYL")

  // remove field
  collection.fields.removeById("_clone_6Nw1")

  return app.save(collection)
})
