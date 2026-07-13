/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3432702729")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  DATE(s.created, 'localtime') AS sale_date,\n  p.paymentMethod,\n  s.branch,\n  COUNT(DISTINCT s.id) AS transaction_count,\n  SUM(p.amount) AS total_revenue,\n  AVG(p.amount) AS avg_transaction_value\nFROM sales s\nLEFT JOIN payments p ON s.id = p.sale\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND s.status IN ('completed', 'paid')\nGROUP BY DATE(s.created, 'localtime'), p.paymentMethod, s.branch\nORDER BY sale_date DESC"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_nqtz")

  // remove field
  collection.fields.removeById("_clone_W8CR")

  // add field
  collection.fields.addAt(2, new Field({
    "help": "",
    "hidden": false,
    "id": "_clone_VfuN",
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
    "id": "_clone_FW4p",
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
  const collection = app.findCollectionByNameOrId("pbc_3432702729")

  // update collection data
  unmarshal({
    "viewQuery": "\n    SELECT\n      (ROW_NUMBER() OVER()) AS id,\n      DATE(s.created) AS sale_date,\n      p.paymentMethod,\n      s.branch,\n      COUNT(DISTINCT s.id) AS transaction_count,\n      SUM(p.amount) AS total_revenue,\n      AVG(p.amount) AS avg_transaction_value\n    FROM sales s\n    LEFT JOIN payments p ON s.id = p.sale\n    WHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n      AND s.status IN ('completed', 'paid')\n    GROUP BY DATE(s.created), p.paymentMethod, s.branch\n    ORDER BY sale_date DESC\n  "
  }, collection)

  // add field
  collection.fields.addAt(2, new Field({
    "help": "",
    "hidden": false,
    "id": "_clone_nqtz",
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
    "id": "_clone_W8CR",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // remove field
  collection.fields.removeById("_clone_VfuN")

  // remove field
  collection.fields.removeById("_clone_FW4p")

  return app.save(collection)
})
