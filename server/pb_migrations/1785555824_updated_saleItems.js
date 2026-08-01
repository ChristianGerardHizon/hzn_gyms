/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2128440087")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE INDEX `idx_saleItems_sale` ON `saleItems` (`sale`)"
    ]
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2128440087")

  // update collection data
  unmarshal({
    "indexes": []
  }, collection)

  return app.save(collection)
})
