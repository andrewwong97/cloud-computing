# coding=utf-8
from flask import Flask, request
from flask_restful import Resource
from bson.objectid import ObjectId
from database import getDB


def _serialize(obj):
    # serialize in a rea
    new_obj = obj
    for field, value in new_obj.items():
        if field == '_id':
            new_obj['_id'] = str(new_obj['_id'])
    return new_obj


class Entry(Resource):
    # blog post entry

    def get(self, entry_id=None):
        db = getDB()
        if entry_id:
            entry = db.entries.find_one({'_id': ObjectId(entry_id)})
            if entry:
                return _serialize(entry)
            else:
                return {'reason': 'blog entry does not exist'}, 404
        else:
            entries = [_serialize(e) for e in db.entries.find()]
            return entries, 200

    def post(self):
        # create blog post
        db = getDB()
        data = request.get_json(force=True)
        user = data['user'] if 'user' in data else None
        title = data['title'] if 'title' in data else None
        body = data['body'] if 'body' in data else None
        if user and title and body:
            created = db.entries.insert_one({'user': user, 'title': title, 'body': body})
            if created.acknowledged:
                return _serialize(created), 200
        return {'reason': 'user or title or body is null'}, 500

    def put(self, entry_id=None):
        # Update with partial or full post information. Changes only the fields that differ between old and new post.
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
        updated = db.users.update_one({
            '_id': ObjectId(entry_id)
        }, {'$set': updated})

        if updated.acknowledged:
            return _serialize(db.users.find_one({'_id': ObjectId(entry_id)}))
        else:
            return {'reason': 'db failed to update entry object'}, 500
