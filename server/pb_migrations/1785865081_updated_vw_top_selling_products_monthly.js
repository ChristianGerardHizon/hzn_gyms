/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_1582693815")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  si.productName,\n  COALESCE(NULLIF(si.itemType, ''), 'product') AS itemType,\n  si.product AS product_id,\n  s.branch,\n  strftime('%Y-%m', s.created, '+8 hours') AS sale_month,\n  SUM(si.quantity) AS total_quantity_sold,\n  SUM(si.subtotal) AS total_revenue,\n  COUNT(DISTINCT s.id) AS transaction_count\nFROM saleItems si\nJOIN sales s ON si.sale = s.id\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND (s.status = 'completed' OR s.status = 'paid')\nGROUP BY si.productName, COALESCE(NULLIF(si.itemType, ''), 'product'), si.product, s.branch, strftime('%Y-%m', s.created, '+8 hours')\nORDER BY total_revenue DESC"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_zbm2")

  // remove field
  collection.fields.removeById("_clone_2wB0")

  // remove field
  collection.fields.removeById("_clone_hhfT")

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "_clone_2N7x",
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
    "id": "_clone_laFD",
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
    "id": "_clone_mFll",
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
  const collection = app.findCollectionByNameOrId("pbc_1582693815")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  si.productName,\n  COALESCE(NULLIF(si.itemType, ''), 'product') AS itemType,\n  si.product AS product_id,\n  s.branch,\n  strftime('%Y-%m', s.created, 'localtime') AS sale_month,\n  SUM(si.quantity) AS total_quantity_sold,\n  SUM(si.subtotal) AS total_revenue,\n  COUNT(DISTINCT s.id) AS transaction_count\nFROM saleItems si\nJOIN sales s ON si.sale = s.id\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND (s.status = 'completed' OR s.status = 'paid')\nGROUP BY si.productName, COALESCE(NULLIF(si.itemType, ''), 'product'), si.product, s.branch, strftime('%Y-%m', s.created, 'localtime')\nORDER BY total_revenue DESC"
  }, collection)

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "_clone_zbm2",
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
    "id": "_clone_2wB0",
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
    "id": "_clone_hhfT",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // remove field
  collection.fields.removeById("_clone_2N7x")

  // remove field
  collection.fields.removeById("_clone_laFD")

  // remove field
  collection.fields.removeById("_clone_mFll")

  return app.save(collection)
})
