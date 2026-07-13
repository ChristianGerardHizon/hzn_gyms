/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_63364096")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  si.productName,\n  COALESCE(NULLIF(si.itemType, ''), 'product') AS itemType,\n  si.product AS product_id,\n  s.branch,\n  strftime('%Y', s.created, 'localtime') AS sale_year,\n  SUM(si.quantity) AS total_quantity_sold,\n  SUM(si.subtotal) AS total_revenue,\n  COUNT(DISTINCT s.id) AS transaction_count\nFROM saleItems si\nJOIN sales s ON si.sale = s.id\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND (s.status = 'completed' OR s.status = 'paid')\nGROUP BY si.productName, COALESCE(NULLIF(si.itemType, ''), 'product'), si.product, s.branch, strftime('%Y', s.created, 'localtime')\nORDER BY total_revenue DESC"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_lDk6")

  // remove field
  collection.fields.removeById("_clone_1Wsj")

  // remove field
  collection.fields.removeById("_clone_VLvJ")

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "_clone_KQtH",
    "max": 0,
    "min": 0,
    "name": "productName",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_4092854851",
    "help": "",
    "hidden": false,
    "id": "_clone_vnk5",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "product_id",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // add field
  collection.fields.addAt(4, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_PKnc",
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
  const collection = app.findCollectionByNameOrId("pbc_63364096")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  si.productName,\n  COALESCE(NULLIF(si.itemType, ''), 'product') AS itemType,\n  si.product AS product_id,\n  s.branch,\n  strftime('%Y', s.created) AS sale_year,\n  SUM(si.quantity) AS total_quantity_sold,\n  SUM(si.subtotal) AS total_revenue,\n  COUNT(DISTINCT s.id) AS transaction_count\nFROM saleItems si\nJOIN sales s ON si.sale = s.id\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND (s.status = 'completed' OR s.status = 'paid')\nGROUP BY si.productName, COALESCE(NULLIF(si.itemType, ''), 'product'), si.product, s.branch, strftime('%Y', s.created)\nORDER BY total_revenue DESC"
  }, collection)

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "_clone_lDk6",
    "max": 0,
    "min": 0,
    "name": "productName",
    "pattern": "",
    "presentable": false,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_4092854851",
    "help": "",
    "hidden": false,
    "id": "_clone_1Wsj",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "product_id",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // add field
  collection.fields.addAt(4, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_VLvJ",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // remove field
  collection.fields.removeById("_clone_KQtH")

  // remove field
  collection.fields.removeById("_clone_vnk5")

  // remove field
  collection.fields.removeById("_clone_PKnc")

  return app.save(collection)
})
