/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2128440087")

  // Add itemType field to distinguish between product, membership, and addon items
  collection.fields.addAt(collection.fields.length, new Field({
    "hidden": false,
    "id": "select_itemtype",
    "maxSelect": 1,
    "name": "itemType",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": ["product", "membership", "addon"]
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2128440087")

  // Remove itemType field
  collection.fields.removeById("select_itemtype")

  return app.save(collection)
})
