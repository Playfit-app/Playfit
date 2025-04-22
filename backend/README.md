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

## Create a .env file

```bash
touch .env
```

> Make sure to create the .env file in the same directory as the manage.py file

> Add the following environment variables to the .env file

```env
SECRET_KEY=your_secret_key
DEBUG=True
```

> Replace your_secret_key with a secret key.
> Set DEBUG to True for development and False for production.

## Generate a secret key

```bash
python3 manage.py shell -c 'from django.core.management import utils; print(utils.get_random_secret_key())'
```

> Copy the secret key and replace your_secret_key in the .env file

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
export DJANGO_SETTINGS_MODULE=playfit.settings ; daphne -b 0.0.0.0 -p 8000 playfit.asgi:application
```

## Deactivate the virtual environment

```bash
deactivate
```
