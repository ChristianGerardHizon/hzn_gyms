/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2873630990")

  // update collection data
  unmarshal({
    "createRule": "@request.auth.superAdmin = true",
    "deleteRule": "@request.auth.superAdmin = true",
    "listRule": "@request.auth.superAdmin = true",
    "updateRule": "@request.auth.superAdmin = true"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2873630990")

  // update collection data
  unmarshal({
    "createRule": "@request.auth.role.permissions ?~ \"organizations.manage\"",
    "deleteRule": "@request.auth.role.permissions ?~ \"organizations.manage\"",
    "listRule": "@request.auth.role.permissions ?~ \"organizations.manage\"",
    "updateRule": "@request.auth.role.permissions ?~ \"organizations.manage\""
  }, collection)

  return app.save(collection)
})
