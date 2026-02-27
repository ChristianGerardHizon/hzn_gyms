/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_members001")

  // Update photo field to include server-side thumbnail sizes
  const photoField = collection.fields.getById("file347571224")
  photoField.thumbs = ["100x100f", "200x200f"]

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_members001")

  // Revert: remove thumbs
  const photoField = collection.fields.getById("file347571224")
  photoField.thumbs = []

  return app.save(collection)
})
