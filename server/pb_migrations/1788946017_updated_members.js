/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_members001")

  // add field
  collection.fields.addAt(4, new Field({
    "help": "",
    "hidden": false,
    "id": "date_mbr_regdate",
    "max": "",
    "min": "",
    "name": "registrationDate",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "date"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_members001")

  // remove field
  collection.fields.removeById("date_mbr_regdate")

  return app.save(collection)
})
