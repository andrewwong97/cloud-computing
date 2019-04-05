# coding=utf-8
from flask import Flask, request
from flask_restful import Resource
from bson.objectid import ObjectId
from database import getDB
import json


def _serialize(obj):
    # used to convert object id to string
    new_obj = obj
    for field, value in new_obj.items():
        if field == '_id':
            new_obj['_id'] = str(new_obj['_id'])
    return new_obj


class Entry(Resource):
    # blog post entry

    def __init__(self, **kwargs):
        self.cache = kwargs['cache']

    def get(self, entry_id=None):
        db = getDB()

        if entry_id:
            if self.cache:
                val = self.cache.get(entry_id)
                if val:
                    print('cache hit')  # TODO: enable logging instead of print statements
                    return json.loads(val)
                else:
                    print('cache miss')
                    entry = db.entries.find_one({'_id': ObjectId(entry_id)})
                    val = json.dumps(_serialize(entry))
                    self.cache.set(entry_id, val)
                    print('cache set {}: {}'.format(entry_id, val))
                    return json.loads(val)
            else:
                # do not use cache
                entry = db.entries.find_one({'_id': ObjectId(entry_id)})
                if entry:
                    return _serialize(entry)
                else:
                    return {'reason': 'blog entry does not exist'}, 404
        else:
            if self.cache:
                val = self.cache.get('all_entries')
                if val:
                    print('cache hit')
                    return json.loads(val)
                else:
                    print('cache miss')
                    entries = [_serialize(e) for e in db.entries.find()]
                    self.cache.set('all_entries', json.dumps(entries))
                    return entries
            else:
                return [_serialize(e) for e in db.entries.find()]

    def post(self):
        # create blog post
        db = getDB()
        data = request.get_json(force=True)
        user = data['user'] if 'user' in data else None
        title = data['title'] if 'title' in data else None
        body = data['body'] if 'body' in data else None

        entry = {
            'user': user,
            'title': title,
            'body': body
        }
        if user and title and body:
            created = db.entries.insert_one(entry)
            if created.acknowledged:
                ser = _serialize(entry)
                if self.cache:
                    self.cache.set(ser['_id'], json.dumps(ser))
                    print('cache set {}: {}'.format(ser['_id'], json.dumps(ser)))
                return ser, 200
        return {'reason': 'user or title or body is null'}, 500

    def put(self, entry_id=None):
        # Update with partial or full post information.
        # Changes only the fields that differ between old and new post.
        db = getDB()
        if not entry_id:
            return {'reason': 'entry id required for updates'}, 404
        existing = db.entries.find_one({'_id': ObjectId(entry_id)})
        if not existing:
            return {'reason': 'entry does not exist for id ' + entry_id}, 404

        data = request.get_json(force=True)

        user = data['user'] if 'user' in data else existing['user']
        title = data['title'] if 'title' in data else existing['title']
        body = data['body'] if 'body' in data else existing['body']

        updated = {
            'user': user,
            'title': title,
            'body': body,
        }
        update_result = db.users.update_one({
            '_id': ObjectId(entry_id)
        }, {'$set': updated})

        if update_result.acknowledged:
            updated['_id'] = entry_id
            ser = _serialize(updated)
            if self.cache:
                self.cache.set(entry_id, json.dumps(ser))
                print('cache set {}: {}'.format(entry_id, json.dumps(ser)))
            return ser, 200
        else:
            return {'reason': 'db failed to update entry object'}, 500
