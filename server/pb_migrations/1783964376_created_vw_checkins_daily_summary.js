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
        "id": "json216405554",
        "maxSize": 1,
        "name": "checkin_date",
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
        "id": "_clone_h4QL",
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
        "id": "_clone_w3GO",
        "maxSelect": 1,
        "name": "method",
        "presentable": false,
        "required": false,
        "system": false,
        "type": "select",
        "values": [
          "manual",
          "rfid"
        ]
      },
      {
        "help": "",
        "hidden": false,
        "id": "number4252562913",
        "max": null,
        "min": null,
        "name": "checkin_count",
        "onlyInt": true,
        "presentable": false,
        "required": false,
        "system": false,
        "type": "number"
      },
      {
        "help": "",
        "hidden": false,
        "id": "number2473316215",
        "max": null,
        "min": null,
        "name": "unique_members",
        "onlyInt": true,
        "presentable": false,
        "required": false,
        "system": false,
        "type": "number"
      }
    ],
    "id": "pbc_2278083390",
    "indexes": [],
    "listRule": null,
    "name": "vw_checkins_daily_summary",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  DATE(c.checkInTime) AS checkin_date,\n  c.branch,\n  c.method,\n  COUNT(*) AS checkin_count,\n  COUNT(DISTINCT c.member) AS unique_members\nFROM checkIns c\nGROUP BY DATE(c.checkInTime), c.branch, c.method\nORDER BY checkin_date DESC",
    "viewRule": null
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2278083390");

  return app.delete(collection);
})
