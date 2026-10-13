Mao ni ang atong working environment para sa backend.

1. Sulod sa backend directory:
   cd backend

2. I-activate ang virtual environment:
   .\.venv\Scripts\activate

3. I-install ang dependencies (kung bag-o or naay bag-ong package):
   pip install -r requirements.txt

4. Pag-kopya sa environment variables:
   copy .env.example .env
   (I-edit ang .env kung naa kay PostgreSQL credentials or GOOGLE_CLIENT_ID)

5. Pag-run sa database migrations:
   python manage.py migrate

6. Pag-run sa local development server:
   python manage.py runserver

