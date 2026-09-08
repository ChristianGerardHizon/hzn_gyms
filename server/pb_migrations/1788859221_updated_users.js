/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  // update collection data
  unmarshal({
    "createRule": "@request.auth.id != \"\" && @request.auth.role.permissions ?~ \"users.create\" && (organization = @request.auth.organization || @request.auth.superAdmin = true)",
    "listRule": "@request.auth.id != \"\" && (organization = @request.auth.organization || @request.auth.superAdmin = true)",
    "updateRule": "@request.auth.id != \"\" && @request.auth.role.permissions ?~ \"users.edit\" && (organization = @request.auth.organization || @request.auth.superAdmin = true)",
    "viewRule": "@request.auth.id != \"\" && (organization = @request.auth.organization || @request.auth.superAdmin = true)"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  // update collection data
  unmarshal({
    "createRule": "id = @request.auth.id || @request.auth.role.permissions ?~  \"users.create\"",
    "listRule": "",
    "updateRule": "id = @request.auth.id || @request.auth.role.permissions ?~  \"users.edit\"",
    "viewRule": ""
  }, collection)

  return app.save(collection)
})
