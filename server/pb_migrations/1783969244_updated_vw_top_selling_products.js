/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3971230533")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  si.productName,\n  COALESCE(NULLIF(si.itemType, ''), 'product') AS itemType,\n  si.product AS product_id,\n  s.branch,\n  DATE(s.created) AS sale_date,\n  SUM(si.quantity) AS total_quantity_sold,\n  SUM(si.subtotal) AS total_revenue,\n  COUNT(DISTINCT s.id) AS transaction_count\nFROM saleItems si\nJOIN sales s ON si.sale = s.id\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND (s.status = 'completed' OR s.status = 'paid')\nGROUP BY si.productName, COALESCE(NULLIF(si.itemType, ''), 'product'), si.product, s.branch, DATE(s.created)\nORDER BY total_revenue DESC"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_fsk7")

  // remove field
  collection.fields.removeById("_clone_Xv5Y")

  // remove field
  collection.fields.removeById("_clone_vJbw")

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "_clone_LQwd",
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
  collection.fields.addAt(2, new Field({
    "help": "",
    "hidden": false,
    "id": "json2257754847",
    "maxSize": 1,
    "name": "itemType",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "json"
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_4092854851",
    "help": "",
    "hidden": false,
    "id": "_clone_WyZQ",
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
    "id": "_clone_bedg",
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
  const collection = app.findCollectionByNameOrId("pbc_3971230533")

  // update collection data
  unmarshal({
    "viewQuery": "\n    SELECT\n      (ROW_NUMBER() OVER()) AS id,\n      si.productName,\n      si.product AS product_id,\n      s.branch,\n      DATE(s.created) AS sale_date,\n      SUM(si.quantity) AS total_quantity_sold,\n      SUM(si.subtotal) AS total_revenue,\n      COUNT(DISTINCT s.id) AS transaction_count\n    FROM saleItems si\n    JOIN sales s ON si.sale = s.id\n    WHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n      AND s.status IN ('completed', 'paid')\n    GROUP BY si.productName, si.product, s.branch, DATE(s.created)\n    ORDER BY total_revenue DESC\n  "
  }, collection)

  // add field
  collection.fields.addAt(1, new Field({
    "autogeneratePattern": "",
    "help": "",
    "hidden": false,
    "id": "_clone_fsk7",
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
  collection.fields.addAt(2, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_4092854851",
    "help": "",
    "hidden": false,
    "id": "_clone_Xv5Y",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "product_id",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // add field
  collection.fields.addAt(3, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_vJbw",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // remove field
  collection.fields.removeById("_clone_LQwd")

  // remove field
  collection.fields.removeById("json2257754847")

  // remove field
  collection.fields.removeById("_clone_WyZQ")

  // remove field
  collection.fields.removeById("_clone_bedg")

  return app.save(collection)
})
