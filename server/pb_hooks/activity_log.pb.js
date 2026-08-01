/// <reference path="../pb_data/types.d.ts" />

onRecordCreateRequest((e) => {
    require(`${__hooks}/lib/activity_log_handlers.js`).onRecordCreateRequest(e);
});

onRecordUpdateRequest((e) => {
    require(`${__hooks}/lib/activity_log_handlers.js`).onRecordUpdateRequest(e);
});

onRecordDeleteRequest((e) => {
    require(`${__hooks}/lib/activity_log_handlers.js`).onRecordDeleteRequest(e);
});
