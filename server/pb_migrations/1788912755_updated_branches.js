/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2358601297")

  // add field
  collection.fields.addAt(12, new Field({
    "autogeneratePattern": "",
    "help": "URL-safe slug for the branch, unique within its organization",
    "hidden": false,
    "id": "text256641946",
    "max": 63,
    "min": 1,
    "name": "slug",
    "pattern": "^[a-z0-9-]+$",
    "presentable": true,
    "primaryKey": false,
    "required": false,
    "system": false,
    "type": "text"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2358601297")

  // remove field
  collection.fields.removeById("text256641946")

  return app.save(collection)
})
