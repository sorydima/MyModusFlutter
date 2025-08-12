import sqlite_utils, time, os, json
from datetime import datetime
from scraper_requests import scrape_via_requests
from sqlite_utils.db import Table

DB_PATH = os.environ.get('BOT_DB', 'bot.db')
db = sqlite_utils.Database(DB_PATH)

def ensure_tables():
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

def enqueue_job(url, connector='generic'):
    ensure_tables()
    t = db['jobs']
    row = {
        'url': str(url),
        'status': 'pending',
        'result': '',
        'created_at': datetime.utcnow().isoformat(),
        'updated_at': datetime.utcnow().isoformat(),
        'attempts': 0,
        'connector': connector
    }
    rec = t.insert(row)
    return rec['id']

def list_jobs(limit=50):
    ensure_tables()
    rows = list(db['jobs'].rows_where(order_by='-created_at', limit=limit))
    return rows

def get_job(job_id):
    ensure_tables()
    r = db['jobs'].get(job_id)
    return r

def process_job_row(row):
    job_id = row['id']
    url = row['url']
    connector = row.get('connector','generic')
    print(f'Processing job {job_id} url={url} connector={connector}')
    try:
        data = scrape_via_requests(url, connector=connector)
        db['jobs'].update(job_id, {
            'status': 'done',
            'result': json.dumps(data),
            'updated_at': datetime.utcnow().isoformat(),
            'attempts': row['attempts'] + 1
        })
        print('Job done', job_id)
    except Exception as e:
        print('Job failed', job_id, e)
        db['jobs'].update(job_id, {
            'status': 'failed',
            'result': str(e),
            'updated_at': datetime.utcnow().isoformat(),
            'attempts': row['attempts'] + 1
        })

def poll_loop(poll_interval=3):
    ensure_tables()
    while True:
        pending = list(db['jobs'].rows_where("status = ?", ['pending'], order_by='created_at', limit=1))
        if not pending:
            time.sleep(poll_interval)
            continue
        row = pending[0]
        process_job_row(row)

if __name__ == '__main__':
    print('Worker started, polling DB:', DB_PATH)
    poll_loop()
