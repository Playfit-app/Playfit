# Server

## Install Python 3

```bash
sudo apt-get update
sudo apt-get install python3
sudo apt-get install python3-pip
sudo apt-get install python3-venv
```

## Create a virtual environment

```bash
python3 -m venv venv
```

## Activate the virtual environment

```bash
source venv/bin/activate
```

## Install the dependencies

```bash
pip install -r requirements.txt
```

> Make sure to install the dependencies in the virtual environment

## Create the database

```bash
python3 manage.py migrate
```

## Create a superuser

```bash
python3 manage.py createsuperuser
```

> Follow the instructions to create a superuser

## Run the server

```bash
python3 manage.py runserver 0.0.0.0:8000
```

## Deactivate the virtual environment

```bash
deactivate
```
