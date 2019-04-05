# Cloud Computing Final Project

## MongoDB Setup

1. Follow instructions on installing local MongoDB server https://docs.mongodb.com/manual/administration/install-community/
2. Run Mongo as a daemon: `sudo mongod --fork --logpath /var/log/mongodb.log`
3. Connect to mongo instance by running `mongo` in a terminal window

data is stored on `/data/db`

## Redis Setup
1. Install Redis
2. Start Redis (default localhost, port 6379)
Can change host and port in `blog/blog/config.json`

## Frontend Web Server Setup
Used to receive r/w requests and perform database insertions and updates on a CRUD resource

Using Python 2.7

1. Make sure you have `virtualenv` installed
2. In directory: `blog/`: run `virtualenv env` to create a virtual environment
3. In directory `blog/`: run `source env/bin/activate` to activate the virtual environment. You can later run `deactivate` to exit the venv.
4. Run `pip install -r requirements.txt` to install project requirements inside the venv.
5. Run `python api.py` inside `blog/blog/api.py` and `curl http://127.0.0.1:5000/api/entries` to test response

Web Technologies

Flask-Restful to parse and return structured requests and responses using REST.
Pymongo as Mongo driver for any db requests
