/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_memberships01")

  // add field
  collection.fields.addAt(11, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_2358601297",
    "help": "Branches where this plan grants check-in access. Empty = all branches.",
    "hidden": false,
    "id": "rel_msp_valid_branches",
    "maxSelect": 999,
    "minSelect": 0,
    "name": "validBranches",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_memberships01")

  // remove field
  collection.fields.removeById("rel_msp_valid_branches")

  return app.save(collection)
})
