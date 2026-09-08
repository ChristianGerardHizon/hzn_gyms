/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_4092854851")

  // update collection data
  unmarshal({
    "listRule": "@request.auth.id != \"\" && @request.auth.organization != \"\" && branch.organization = @request.auth.organization && (@request.auth.branch.id = branch.id || @request.auth.allowedBranches.id ?= branch.id || @request.auth.superAdmin = true)",
    "viewRule": "@request.auth.id != \"\" && @request.auth.organization != \"\" && branch.organization = @request.auth.organization && (@request.auth.branch.id = branch.id || @request.auth.allowedBranches.id ?= branch.id || @request.auth.superAdmin = true)"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_4092854851")

  // update collection data
  unmarshal({
    "listRule": "@request.auth.id != \"\" && (@request.auth.branch.id = branch.id || @request.auth.allowedBranches.id ?= branch.id)",
    "viewRule": ""
  }, collection)

  return app.save(collection)
})
