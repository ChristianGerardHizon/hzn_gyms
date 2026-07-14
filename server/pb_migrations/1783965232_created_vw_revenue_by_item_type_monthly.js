/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = new Collection({
    "createRule": null,
    "deleteRule": null,
    "fields": [
      {
        "autogeneratePattern": "",
        "help": "",
        "hidden": false,
        "id": "text3208210256",
        "max": 0,
        "min": 0,
        "name": "id",
        "pattern": "^[a-z0-9]+$",
        "presentable": false,
        "primaryKey": true,
        "required": true,
        "system": true,
        "type": "text"
      },
      {
        "help": "",
        "hidden": false,
        "id": "json1584023685",
        "maxSize": 1,
        "name": "sale_month",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "help": "",
        "hidden": false,
        "id": "json2257754847",
        "maxSize": 1,
        "name": "itemType",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
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
      },
      {
        "help": "",
        "hidden": false,
        "id": "json487443959",
        "maxSize": 1,
        "name": "total_revenue",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "help": "",
        "hidden": false,
        "id": "json554441351",
        "maxSize": 1,
        "name": "total_quantity",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      },
      {
        "help": "",
        "hidden": false,
        "id": "number619353122",
        "max": null,
        "min": null,
        "name": "transaction_count",
        "onlyInt": true,
        "presentable": false,
        "required": false,
        "system": false,
        "type": "number"
      }
    ],
    "id": "pbc_4171933560",
    "indexes": [],
    "listRule": "",
    "name": "vw_revenue_by_item_type_monthly",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  strftime('%Y-%m', s.created) AS sale_month,\n  COALESCE(NULLIF(si.itemType, ''), 'product') AS itemType,\n  s.branch,\n  SUM(si.subtotal) AS total_revenue,\n  SUM(si.quantity) AS total_quantity,\n  COUNT(DISTINCT s.id) AS transaction_count\nFROM saleItems si\nJOIN sales s ON si.sale = s.id\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND (s.status = 'completed' OR s.status = 'paid')\nGROUP BY strftime('%Y-%m', s.created), COALESCE(NULLIF(si.itemType, ''), 'product'), s.branch\nORDER BY sale_month DESC",
    "viewRule": ""
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_4171933560");

  return app.delete(collection);
})
