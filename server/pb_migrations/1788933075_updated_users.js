/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  // update collection data
  unmarshal({
    "createRule": "@request.auth.superAdmin = true || (@request.auth.id != \"\" && @request.auth.role.permissions ?~ \"users.create\" && organization = @request.auth.organization)",
    "updateRule": "@request.auth.superAdmin = true || (@request.auth.id != \"\" && @request.auth.role.permissions ?~ \"users.edit\" && organization = @request.auth.organization)"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  // update collection data
  unmarshal({
    "createRule": "@request.auth.id != \"\" && @request.auth.role.permissions ?~ \"users.create\" && (organization = @request.auth.organization || @request.auth.superAdmin = true)",
    "updateRule": "@request.auth.id != \"\" && @request.auth.role.permissions ?~ \"users.edit\" && (organization = @request.auth.organization || @request.auth.superAdmin = true)"
  }, collection)

  return app.save(collection)
})
