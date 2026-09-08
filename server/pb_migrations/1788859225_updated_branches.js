/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2358601297")

  // update collection data
  unmarshal({
    "createRule": "@request.auth.id != \"\" && @request.auth.role.permissions ?~ \"branches.create\" && (organization = @request.auth.organization || @request.auth.superAdmin = true)",
    "updateRule": "@request.auth.id != \"\" && @request.auth.role.permissions ?~ \"branches.edit\" && (organization = @request.auth.organization || @request.auth.superAdmin = true)"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2358601297")

  // update collection data
  unmarshal({
    "createRule": "",
    "updateRule": ""
  }, collection)

  return app.save(collection)
})
