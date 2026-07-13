/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_4213523444")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  DATE(s.created, 'localtime') AS sale_date,\n  COALESCE(NULLIF(si.itemType, ''), 'product') AS itemType,\n  s.branch,\n  SUM(si.subtotal) AS total_revenue,\n  SUM(si.quantity) AS total_quantity,\n  COUNT(DISTINCT s.id) AS transaction_count\nFROM saleItems si\nJOIN sales s ON si.sale = s.id\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND (s.status = 'completed' OR s.status = 'paid')\nGROUP BY DATE(s.created, 'localtime'), COALESCE(NULLIF(si.itemType, ''), 'product'), s.branch\nORDER BY sale_date DESC"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_Y7WI")

  // add field
  collection.fields.addAt(3, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_FamV",
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
  const collection = app.findCollectionByNameOrId("pbc_4213523444")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  DATE(s.created) AS sale_date,\n  COALESCE(NULLIF(si.itemType, ''), 'product') AS itemType,\n  s.branch,\n  SUM(si.subtotal) AS total_revenue,\n  SUM(si.quantity) AS total_quantity,\n  COUNT(DISTINCT s.id) AS transaction_count\nFROM saleItems si\nJOIN sales s ON si.sale = s.id\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND (s.status = 'completed' OR s.status = 'paid')\nGROUP BY DATE(s.created), COALESCE(NULLIF(si.itemType, ''), 'product'), s.branch\nORDER BY sale_date DESC"
  }, collection)

  // add field
  collection.fields.addAt(3, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_Y7WI",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // remove field
  collection.fields.removeById("_clone_FamV")

  return app.save(collection)
})
