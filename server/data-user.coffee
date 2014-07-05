# Veldspar EVE Online API Client
# data-user.coffee - User related data
# Copyright © Denis Luchkin-Zhou
Veldspar = (exports ? this).Veldspar
UserData = Veldspar.UserData

# Publish Character Data
Meteor.publish 'user_Characters', ->
  if this.userId
    return UserData.characters.find({owner: this.userId})
  else
    this.ready()