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
        "id": "json1423088652",
        "maxSize": 1,
        "name": "week_start",
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
        "id": "_clone_VI9I",
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
        "id": "_clone_5AIo",
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
    "id": "pbc_1774506076",
    "indexes": [],
    "listRule": "",
    "name": "vw_checkins_weekly_summary",
    "system": false,
    "type": "view",
    "updateRule": null,
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  date(c.checkInTime, '-' || ((cast(strftime('%w', c.checkInTime) as integer) + 6) % 7) || ' days') AS week_start,\n  c.branch,\n  c.method,\n  COUNT(*) AS checkin_count,\n  COUNT(DISTINCT c.member) AS unique_members\nFROM checkIns c\nGROUP BY date(c.checkInTime, '-' || ((cast(strftime('%w', c.checkInTime) as integer) + 6) % 7) || ' days'), c.branch, c.method\nORDER BY week_start DESC",
    "viewRule": ""
  });

  return app.save(collection);
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_1774506076");

  return app.delete(collection);
})
