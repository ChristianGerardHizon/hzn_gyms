/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_mbrshpaddon1")

  // add field
  collection.fields.addAt(9, new Field({
    "help": "",
    "hidden": false,
    "id": "number3847668048",
    "max": null,
    "min": 0,
    "name": "durationDays",
    "onlyInt": true,
    "presentable": false,
    "required": false,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_mbrshpaddon1")

  // remove field
  collection.fields.removeById("number3847668048")

  return app.save(collection)
})
