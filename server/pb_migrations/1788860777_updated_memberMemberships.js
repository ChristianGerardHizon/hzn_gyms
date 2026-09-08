/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_mbrmbrshp001")

  // update collection data
  unmarshal({
    "listRule": "@request.auth.id != \"\" && @request.auth.organization != \"\" && branch.organization = @request.auth.organization",
    "viewRule": "@request.auth.id != \"\" && @request.auth.organization != \"\" && branch.organization = @request.auth.organization"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_mbrmbrshp001")

  // update collection data
  unmarshal({
    "listRule": "",
    "viewRule": ""
  }, collection)

  return app.save(collection)
})
