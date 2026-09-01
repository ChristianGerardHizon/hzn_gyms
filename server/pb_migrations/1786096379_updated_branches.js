/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2358601297")

  // add field
  collection.fields.addAt(9, new Field({
    "autogeneratePattern": "",
    "help": "Short pill label (max 5), e.g. BCD, TAL",
    "hidden": false,
    "id": "text1997877400",
    "max": 5,
    "min": 1,
    "name": "code",
    "pattern": "^[A-Za-z0-9]+$",
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
  collection.fields.removeById("text1997877400")

  return app.save(collection)
})
