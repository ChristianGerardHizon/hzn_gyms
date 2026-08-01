/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_947366428")

  // update collection data
  unmarshal({
    "listRule": "@request.auth.id != \"\" && @request.auth.role.permissions ?~ \"system.admin\"",
    "viewRule": "@request.auth.id != \"\" && @request.auth.role.permissions ?~ \"system.admin\""
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_947366428")

  // update collection data
  unmarshal({
    "listRule": "@request.auth.id != \"\" && (@request.auth.role.permissions ?~ \"activityLog.view\" || @request.auth.role.permissions ?~ \"system.admin\")",
    "viewRule": "@request.auth.id != \"\" && (@request.auth.role.permissions ?~ \"activityLog.view\" || @request.auth.role.permissions ?~ \"system.admin\")"
  }, collection)

  return app.save(collection)
})
