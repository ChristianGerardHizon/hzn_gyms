/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_1231561320")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  s.branch,\n  COUNT(*) AS transaction_count,\n  COALESCE(SUM(s.totalAmount), 0) AS total_revenue\nFROM sales s\nWHERE s.created >= datetime('now', 'localtime', 'start of day', 'utc')\n  AND s.created < datetime('now', 'localtime', 'start of day', '+1 day', 'utc')\n  AND s.status IN ('completed', 'paid')\n  AND (s.isDeleted = false OR s.isDeleted IS NULL)\nGROUP BY s.branch"
  }, collection)

  // remove field
  collection.fields.removeById("_clone_PRbt")

  // add field
  collection.fields.addAt(1, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_oNRF",
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
  const collection = app.findCollectionByNameOrId("pbc_1231561320")

  // update collection data
  unmarshal({
    "viewQuery": "SELECT\n  (ROW_NUMBER() OVER()) AS id,\n  s.branch,\n  COUNT(*) AS transaction_count,\n  COALESCE(SUM(s.totalAmount), 0) AS total_revenue\nFROM sales s\nWHERE s.created >= datetime('now', 'localtime', 'start of day', 'utc')\n  AND s.created < datetime('now', 'localtime', 'start of day', '+1 day', 'utc')\n  AND s.status = 'completed'\n  AND (s.isDeleted = false OR s.isDeleted IS NULL)\nGROUP BY s.branch"
  }, collection)

  // add field
  collection.fields.addAt(1, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "",
    "hidden": false,
    "id": "_clone_PRbt",
    "maxSelect": 1,
    "minSelect": 0,
    "name": "branch",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  // remove field
  collection.fields.removeById("_clone_oNRF")

  return app.save(collection)
})
