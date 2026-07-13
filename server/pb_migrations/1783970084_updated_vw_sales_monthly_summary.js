/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_1102656226")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  strftime('%Y-%m', s.created, 'localtime') AS sale_month,\n  p.paymentMethod,\n  s.branch,\n  COUNT(DISTINCT s.id) AS transaction_count,\n  SUM(p.amount) AS total_revenue,\n  AVG(p.amount) AS avg_transaction_value\nFROM sales s\nLEFT JOIN payments p ON s.id = p.sale\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND s.status IN ('completed', 'paid')\nGROUP BY strftime('%Y-%m', s.created, 'localtime'), p.paymentMethod, s.branch\nORDER BY sale_month DESC"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_xpBs")

  // remove field
  collection.fields.removeById("_clone_JLLG")

  // add field
  collection.fields.addAt(2, new Field({
    "help": "",
    "hidden": false,
    "id": "_clone_zEqt",
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
    "id": "_clone_9ksn",
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
  const collection = app.findCollectionByNameOrId("pbc_1102656226")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  strftime('%Y-%m', s.created) AS sale_month,\n  p.paymentMethod,\n  s.branch,\n  COUNT(DISTINCT s.id) AS transaction_count,\n  SUM(p.amount) AS total_revenue,\n  AVG(p.amount) AS avg_transaction_value\nFROM sales s\nLEFT JOIN payments p ON s.id = p.sale\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND s.status = 'completed'\nGROUP BY strftime('%Y-%m', s.created), p.paymentMethod, s.branch\nORDER BY sale_month DESC"
  }, collection)

  // add field
  collection.fields.addAt(2, new Field({
    "help": "",
    "hidden": false,
    "id": "_clone_xpBs",
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
    "id": "_clone_JLLG",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // remove field
  collection.fields.removeById("_clone_zEqt")

  // remove field
  collection.fields.removeById("_clone_9ksn")

  return app.save(collection)
})
