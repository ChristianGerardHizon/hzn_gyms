/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_memberships01")

  // add field
  collection.fields.addAt(13, new Field({
    "help": "",
    "hidden": false,
    "id": "select3523817829",
    "maxSelect": 1,
    "name": "durationUnit",
    "presentable": false,
    "required": true,
    "system": false,
    "type": "select",
    "values": [
      "days",
      "weeks",
      "months",
      "years"
    ]
  }))

  // update field
  collection.fields.addAt(3, new Field({
    "help": "",
    "hidden": false,
    "id": "num_msp_duration",
    "max": null,
    "min": 1,
    "name": "durationValue",
    "onlyInt": true,
    "presentable": false,
    "required": true,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_memberships01")

  // remove field
  collection.fields.removeById("select3523817829")

  // update field
  collection.fields.addAt(3, new Field({
    "help": "",
    "hidden": false,
    "id": "num_msp_duration",
    "max": null,
    "min": 1,
    "name": "durationDays",
    "onlyInt": true,
    "presentable": false,
    "required": true,
    "system": false,
    "type": "number"
  }))

  return app.save(collection)
})
