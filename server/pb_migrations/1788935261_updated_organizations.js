/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2873630990")

  // update collection data
  unmarshal({
    "listRule": "@request.auth.superAdmin = true || id = @request.auth.organization || (@collection.organizationMemberships.user ?= @request.auth.id && @collection.organizationMemberships.organization ?= id)",
    "viewRule": "@request.auth.superAdmin = true || id = @request.auth.organization || (@collection.organizationMemberships.user ?= @request.auth.id && @collection.organizationMemberships.organization ?= id)"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2873630990")

  // update collection data
  unmarshal({
    "listRule": "@request.auth.superAdmin = true",
    "viewRule": "@request.auth.superAdmin = true"
  }, collection)

  return app.save(collection)
})
