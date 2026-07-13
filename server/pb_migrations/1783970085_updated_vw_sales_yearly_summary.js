/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3423908810")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  strftime('%Y', s.created, 'localtime') AS sale_year,\n  p.paymentMethod,\n  s.branch,\n  COUNT(DISTINCT s.id) AS transaction_count,\n  SUM(p.amount) AS total_revenue,\n  AVG(p.amount) AS avg_transaction_value\nFROM sales s\nLEFT JOIN payments p ON s.id = p.sale\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND s.status IN ('completed', 'paid')\nGROUP BY strftime('%Y', s.created, 'localtime'), p.paymentMethod, s.branch\nORDER BY sale_year DESC"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_JsWh")

  // remove field
  collection.fields.removeById("_clone_RhRe")

  // add field
  collection.fields.addAt(2, new Field({
    "help": "",
    "hidden": false,
    "id": "_clone_aFnD",
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
    "id": "_clone_Gk46",
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
  const collection = app.findCollectionByNameOrId("pbc_3423908810")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  strftime('%Y', s.created) AS sale_year,\n  p.paymentMethod,\n  s.branch,\n  COUNT(DISTINCT s.id) AS transaction_count,\n  SUM(p.amount) AS total_revenue,\n  AVG(p.amount) AS avg_transaction_value\nFROM sales s\nLEFT JOIN payments p ON s.id = p.sale\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND s.status = 'completed'\nGROUP BY strftime('%Y', s.created), p.paymentMethod, s.branch\nORDER BY sale_year DESC"
  }, collection)

  // add field
  collection.fields.addAt(2, new Field({
    "help": "",
    "hidden": false,
    "id": "_clone_JsWh",
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
    "id": "_clone_RhRe",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // remove field
  collection.fields.removeById("_clone_aFnD")

  // remove field
  collection.fields.removeById("_clone_Gk46")

  return app.save(collection)
})
