/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2358601297")

  // update collection data
  unmarshal({
    "listRule": "@request.auth.id != \"\" && (organization = @request.auth.organization || @request.auth.superAdmin = true)",
    "viewRule": "@request.auth.id != \"\" && (organization = @request.auth.organization || @request.auth.superAdmin = true)"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2358601297")

  // update collection data
  unmarshal({
    "listRule": "@request.auth.id != \"\" && (organization = @request.auth.organization || @request.auth.role.permissions ?~ \"organizations.manage\")",
    "viewRule": "@request.auth.id != \"\" && (organization = @request.auth.organization || @request.auth.role.permissions ?~ \"organizations.manage\")"
  }, collection)

  return app.save(collection)
})
