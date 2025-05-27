FROM python:3.12.3-alpine3.18

WORKDIR /app

COPY app.py /app/app.py

COPY requirements.txt /app/requirements.txt

COPY templates /app/templates

RUN pip install --no-cache-dir -r requirements.txt

CMD [ "python", "app.py" ]

EXPOSE 81