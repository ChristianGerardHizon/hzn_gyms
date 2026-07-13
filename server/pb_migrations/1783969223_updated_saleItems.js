/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2128440087")

  // update field
  collection.fields.addAt(11, new Field({
    "help": "",
    "hidden": false,
    "id": "select_itemtype",
    "maxSelect": 1,
    "name": "itemType",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "product",
      "membership",
      "addon",
      "walkIn"
    ]
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2128440087")

  // update field
  collection.fields.addAt(11, new Field({
    "help": "",
    "hidden": false,
    "id": "select_itemtype",
    "maxSelect": 1,
    "name": "itemType",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "product",
      "membership",
      "addon"
    ]
  }))

  return app.save(collection)
})
