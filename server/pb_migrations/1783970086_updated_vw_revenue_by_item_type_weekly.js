/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3864271485")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  date(s.created, 'localtime', '-' || ((cast(strftime('%w', s.created, 'localtime') as integer) + 6) % 7) || ' days') AS week_start,\n  COALESCE(NULLIF(si.itemType, ''), 'product') AS itemType,\n  s.branch,\n  SUM(si.subtotal) AS total_revenue,\n  SUM(si.quantity) AS total_quantity,\n  COUNT(DISTINCT s.id) AS transaction_count\nFROM saleItems si\nJOIN sales s ON si.sale = s.id\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND (s.status = 'completed' OR s.status = 'paid')\nGROUP BY date(s.created, 'localtime', '-' || ((cast(strftime('%w', s.created, 'localtime') as integer) + 6) % 7) || ' days'), COALESCE(NULLIF(si.itemType, ''), 'product'), s.branch\nORDER BY week_start DESC"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_0O10")

  // add field
  collection.fields.addAt(3, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_jY5A",
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
  const collection = app.findCollectionByNameOrId("pbc_3864271485")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  date(s.created, '-' || ((cast(strftime('%w', s.created) as integer) + 6) % 7) || ' days') AS week_start,\n  COALESCE(NULLIF(si.itemType, ''), 'product') AS itemType,\n  s.branch,\n  SUM(si.subtotal) AS total_revenue,\n  SUM(si.quantity) AS total_quantity,\n  COUNT(DISTINCT s.id) AS transaction_count\nFROM saleItems si\nJOIN sales s ON si.sale = s.id\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND (s.status = 'completed' OR s.status = 'paid')\nGROUP BY date(s.created, '-' || ((cast(strftime('%w', s.created) as integer) + 6) % 7) || ' days'), COALESCE(NULLIF(si.itemType, ''), 'product'), s.branch\nORDER BY week_start DESC"
  }, collection)

  // add field
  collection.fields.addAt(3, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_0O10",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // remove field
  collection.fields.removeById("_clone_jY5A")

  return app.save(collection)
})
