# Cloud Computing Final Project

## MongoDB Setup
Follow these steps in order to get your project environment running.

1. Follow instructions on installing local MongoDB server https://docs.mongodb.com/manual/administration/install-community/
2. Ensure that the data directory exists (see mongo install docs for your operating system). Run Mongo as a daemon: `sudo mongod --fork --logpath /var/log/mongodb.log`.
3. Connect to mongo instance by running `mongo` in a terminal window
4. Create project db by running `use cloud` in the mongo shell
5. Test project db by creating a sample blog post by running the following command, replacing value fields as necessary: `db.entries.insert({'user': 'my_name', 'title': 'my_title', 'body': 'my_body'})`

data files are stored on `/data/db`

log is stored at `/var/log/mongodb.log`

## Redis Setup
1. Install Redis
2. Start Redis (default localhost, port 6379)

Can change host and port in `blog/blog/config.json`. Enable/disable Redis here: https://github.com/andrewwong97/cloud-computing/blob/26b602ecf52f4777bc778942969c6e05589b0deb/blog/blog/api.py#L9

## API Setup
Used to receive r/w requests and perform database insertions and updates on a CRUD resource

### Using Python 2.7

1. Make sure you have `virtualenv` installed
2. In directory: `blog/`: run `virtualenv env` to create a virtual environment
3. In directory `blog/`: run `source env/bin/activate` to activate the virtual environment. You can later run `deactivate` to exit the venv.
4. Run `pip install -r requirements.txt` to install project requirements inside the venv.
5. Run `python api.py` inside `blog/blog/api.py` and `curl http://127.0.0.1:5000/api/blog` in another terminal to test response

### Web Technologies

Flask-Restful to parse and return structured requests and responses using REST.
Pymongo as Mongo driver for any db requests

### Hadoop - Chained MapReduce
As a simple initial test, we create 2^10 random samples of key, message pairs as would be found in or database, and pipes it to the mapper and reducer: `./test_mapreduce.sh`