/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE UNIQUE INDEX `idx_tokenKey_pbc_3841632486` ON `users` (`tokenKey`)",
      "CREATE UNIQUE INDEX `idx_username_pbc_3841632486` ON `users` (`username`) WHERE `username` != ''",
      "CREATE UNIQUE INDEX `idx_email_pbc_3841632486` ON `users` (`email`) WHERE `email` != ''"
    ],
    "passwordAuth": {
      "identityFields": [
        "username"
      ]
    }
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_3841632486")

  // update collection data
  unmarshal({
    "indexes": [
      "CREATE UNIQUE INDEX `idx_tokenKey_pbc_3841632486` ON `users` (`tokenKey`)",
      "CREATE UNIQUE INDEX `idx_email_pbc_3841632486` ON `users` (`email`) WHERE `email` != ''"
    ],
    "passwordAuth": {
      "identityFields": [
        "email"
      ]
    }
  }, collection)

  return app.save(collection)
})
