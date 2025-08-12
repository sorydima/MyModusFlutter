from fastapi import FastAPI, HTTPException, BackgroundTasks
from pydantic import BaseModel, HttpUrl
import sqlite_utils
import os
from datetime import datetime
from worker import enqueue_job, get_job, list_jobs

DB_PATH = os.environ.get('BOT_DB', 'bot.db')
db = sqlite_utils.Database(DB_PATH)

# ensure tables
if 'jobs' not in db.table_names():
    db["jobs"].create({
        "id": int,
        "url": str,
        "status": str,
        "result": str,
        "created_at": str,
        "updated_at": str,
        "attempts": int,
        "connector": str
    }, pk="id")

app = FastAPI(title='MyModus Bot Service')

class ScrapeRequest(BaseModel):
    url: HttpUrl
    connector: str = 'generic'  # generic | wildberries | ozon | lamoda

@app.post('/enqueue')
def enqueue(req: ScrapeRequest, background_tasks: BackgroundTasks):
    job_id = enqueue_job(req.url, req.connector)
    background_tasks.add_task(lambda jid: None, job_id)  # background hint; worker polls DB
    return {'job_id': job_id, 'status': 'enqueued'}

@app.get('/jobs')
def jobs_list(limit: int = 50):
    return list_jobs(limit=limit)

@app.get('/jobs/{job_id}')
def job_info(job_id: int):
    job = get_job(job_id)
    if not job:
        raise HTTPException(status_code=404, detail='not found')
    return job
