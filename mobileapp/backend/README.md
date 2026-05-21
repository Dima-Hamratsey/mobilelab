# MobileLab Backend

Minimal FastAPI backend for the MobileLab app. Uses SQLite file storage.

## Setup

From the `backend` folder:

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

## Run

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The SQLite database is stored in `app.db` next to `main.py`.

## API summary

- `POST /auth/register`
- `POST /auth/login`
- `GET /auth/profile`
- `PUT /auth/stations` (bulk replace)
- `GET /stations`
- `POST /stations`
- `PUT /stations/{station_id}`
- `DELETE /stations/{station_id}`
