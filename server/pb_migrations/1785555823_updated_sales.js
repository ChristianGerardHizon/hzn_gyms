/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE INDEX idx_sales_created ON sales (created)",
      "CREATE INDEX idx_sales_branch_created ON sales (branch, created)",
      "CREATE INDEX idx_sales_receiptNumber ON sales (receiptNumber)",
      "CREATE INDEX idx_sales_member_created ON sales (member, created)",
      "CREATE INDEX `idx_sales_status` ON `sales` (`status`)"
    ]
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2697449135")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE INDEX idx_sales_created ON sales (created)",
      "CREATE INDEX idx_sales_branch_created ON sales (branch, created)",
      "CREATE INDEX idx_sales_receiptNumber ON sales (receiptNumber)",
      "CREATE INDEX idx_sales_member_created ON sales (member, created)"
    ]
  }, collection)

  return app.save(collection)
})
