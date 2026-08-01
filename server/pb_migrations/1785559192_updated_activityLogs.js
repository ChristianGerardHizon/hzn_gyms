/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_947366428")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE INDEX idx_activity_logs_collection_record ON activityLogs (`collection`, recordId)",
      "CREATE INDEX idx_activity_logs_actor ON activityLogs (actor)",
      "CREATE INDEX idx_activity_logs_branch ON activityLogs (branch)",
      "CREATE INDEX idx_activity_logs_created ON activityLogs (created DESC)"
    ]
  }, collection)

  // add field
  collection.fields.addAt(9, new Field({
    "hidden": false,
    "id": "autodate2990389176",
    "name": "created",
    "onCreate": true,
    "onUpdate": false,
    "presentable": false,
    "system": false,
    "type": "autodate"
  }))

  // add field
  collection.fields.addAt(10, new Field({
    "hidden": false,
    "id": "autodate3332085495",
    "name": "updated",
    "onCreate": true,
    "onUpdate": true,
    "presentable": false,
    "system": false,
    "type": "autodate"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_947366428")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE INDEX idx_activity_logs_collection_record ON activityLogs (`collection`, recordId)",
      "CREATE INDEX idx_activity_logs_actor ON activityLogs (actor)",
      "CREATE INDEX idx_activity_logs_branch ON activityLogs (branch)"
    ]
  }, collection)

  // remove field
  collection.fields.removeById("autodate2990389176")

  // remove field
  collection.fields.removeById("autodate3332085495")

  return app.save(collection)
})
