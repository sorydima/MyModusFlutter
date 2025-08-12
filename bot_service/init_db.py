#!/usr/bin/env python3
from sqlite_utils import Database
db = Database('bot.db')
if 'jobs' not in db.table_names():
    db['jobs'].create({
        "id": int,
        "url": str,
        "status": str,
        "result": str,
        "created_at": str,
        "updated_at": str,
        "attempts": int,
        "connector": str
    }, pk="id")
print('DB initialized: bot.db')
