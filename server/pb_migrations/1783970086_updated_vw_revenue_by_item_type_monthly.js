/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_4171933560")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  strftime('%Y-%m', s.created, 'localtime') AS sale_month,\n  COALESCE(NULLIF(si.itemType, ''), 'product') AS itemType,\n  s.branch,\n  SUM(si.subtotal) AS total_revenue,\n  SUM(si.quantity) AS total_quantity,\n  COUNT(DISTINCT s.id) AS transaction_count\nFROM saleItems si\nJOIN sales s ON si.sale = s.id\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND (s.status = 'completed' OR s.status = 'paid')\nGROUP BY strftime('%Y-%m', s.created, 'localtime'), COALESCE(NULLIF(si.itemType, ''), 'product'), s.branch\nORDER BY sale_month DESC"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_6eAr")

  // add field
  collection.fields.addAt(3, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_dCBI",
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
  const collection = app.findCollectionByNameOrId("pbc_4171933560")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  strftime('%Y-%m', s.created) AS sale_month,\n  COALESCE(NULLIF(si.itemType, ''), 'product') AS itemType,\n  s.branch,\n  SUM(si.subtotal) AS total_revenue,\n  SUM(si.quantity) AS total_quantity,\n  COUNT(DISTINCT s.id) AS transaction_count\nFROM saleItems si\nJOIN sales s ON si.sale = s.id\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND (s.status = 'completed' OR s.status = 'paid')\nGROUP BY strftime('%Y-%m', s.created), COALESCE(NULLIF(si.itemType, ''), 'product'), s.branch\nORDER BY sale_month DESC"
  }, collection)

  // add field
  collection.fields.addAt(3, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_6eAr",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // remove field
  collection.fields.removeById("_clone_dCBI")

  return app.save(collection)
})
