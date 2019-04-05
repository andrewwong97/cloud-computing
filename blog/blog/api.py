from flask import Flask
from flask_restful import Api
import resources
from database import getCache

app = Flask(__name__)
api = Api(app)

cache = getCache()  # set this to none if not using cache
api.add_resource(resources.Entry, '/api/blog', '/api/blog/<string:entry_id>', resource_class_kwargs={ 'cache': cache })

if __name__ == '__main__':
    app.run(debug=True)
