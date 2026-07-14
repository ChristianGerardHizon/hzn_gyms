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
      },
      {
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
        "id": "json3227388031",
        "maxSize": 1,
        "name": "avg_transaction_value",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "json"
      }
    ],
    "id": "pbc_1102656226",
    "indexes": [],
    "listRule": "",
    "name": "vw_sales_monthly_summary",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  strftime('%Y-%m', s.created) AS sale_month,\n  p.paymentMethod,\n  s.branch,\n  COUNT(DISTINCT s.id) AS transaction_count,\n  SUM(p.amount) AS total_revenue,\n  AVG(p.amount) AS avg_transaction_value\nFROM sales s\nLEFT JOIN payments p ON s.id = p.sale\nWHERE (s.isDeleted = false OR s.isDeleted IS NULL)\n  AND s.status = 'completed'\nGROUP BY strftime('%Y-%m', s.created), p.paymentMethod, s.branch\nORDER BY sale_month DESC",
    "viewRule": ""
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_1102656226");

  return app.delete(collection);
})
