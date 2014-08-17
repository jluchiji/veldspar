# Veldspar EVE Online API Client
# static-data-import.coffee - Utility methods for updating static data
# Copyright © Denis Luchkin-Zhou
Veldspar = (exports ? this).Veldspar
StaticData = Veldspar.StaticData

# Publish all static data
Meteor.publish 'static.SkillTree', -> StaticData.skillTree.find()
Meteor.publish 'static.SkillCategories', -> StaticData.skillCategories.find()
Meteor.publish 'static.Certificates', -> StaticData.certificates.find()

# Internal: Fetches the skill tree data from EVE API and updates the
# existing 'static_SkillTree' collection.
StaticData.updateSkillTree = () ->
  # Request skill tree from CCP API
  client = new Veldspar.ApiClient '/eve/SkillTree.xml.aspx'
  transform =
    '_currentTime': 'date:eveapi.currentTime'
    '_cachedUntil': 'date:eveapi.cachedUntil'
    'groups':
      '$path': 'eveapi.result.skillGroups'
      'id': 'number:groupID'
      'name': 'groupName'
      'skills':
        '$path': 'skills'
        '_id': 'typeID'
        'name': 'typeName'
        'group.id': 'number:groupID'
        'published': 'bool:published'
        'description': 'description'
        'rank': 'number:rank'
        'attributes.primary': 'requiredAttributes.primaryAttribute'
        'attributes.secondary': 'requiredAttributes.secondaryAttribute'
        'prerequisites':
          '$path': 'requiredSkills'
          'id': 'typeID'
          'level': 'number:skillLevel'
        'bonus':
          '$path': 'skillBonusCollection'
          'name': 'bonusType'
          'value': 'number:bonusValue'
  raw = client.transform(transform).request()
  # Reduce skills to a flat list
  raw.skills = _.reduce _.map(raw.groups, (i) -> i.skills), (mem, o) ->
    return mem.concat o
    ,[]
  # Replace existing skill tree data
  StaticData.skillTree.remove({})
  _.each raw.skills, (i) ->
    i.id = Number(i._id)
    StaticData.skillTree.insert i
  # Insert skill categories
  StaticData.skillCategories.remove({})
  _.each _.uniq(raw.groups, no, (o)->o.id), (i) ->
    cat = _.pick i, 'name'
    cat._id = String(i.id)
    StaticData.skillCategories.insert cat
  # Resolve skill dependencies
  resolveDeps = (skill) ->
      _.each skill.prerequisites, (i)->
        dep = StaticData.skillTree.findOne({_id: i.id}, {fields: {name: 1, prerequisites: 1, rank:1}})
        i.name = dep.name
        i.rank = dep.rank
        i.prerequisites = dep.prerequisites
        resolveDeps(i) if i.id isnt skill.id
  _.each StaticData.skillTree.find().fetch(), (i)->
    resolveDeps(i)
    StaticData.skillTree.update({_id: i._id}, _.omit(i, '_id'))
# Internal: Loads the /private/certificates.yaml and updates the existing
# 'static.Certificates' collection.
StaticData.updateCertificates = ->
  # Read YAML file and parse it into a JSON object
  raw = jsyaml.safeLoad Assets.getText 'certificates.yaml'
  if not raw or raw is 'undefined'
    throw new Meteor.Error 400, 'Failed to deserialize certificates.yaml'
  # Delete all existing data
  Veldspar.StaticData.certificates.remove {}
  # Do some minor transformations
  for id, cert of raw
    # TODO resolve recommendation references
    # Resolve skill references
    cert.skills = [ ] # Convert to array
    for sid, skill of cert.skillTypes
      info = Veldspar.StaticData.skillTree.findOne _id:sid  # sid is already a string
      skill.id = Number(sid)
      skill.name = info?.name ? 'UNKNOWN SKILL (BUG)'
      skill.rank = info?.rank ? 1
      skill.attributes = info?.attributes ? primary:'intelligence', secondary:'memory'
      skill.levels = [ 0, skill.basic, skill.standard, skill.improved, skill.advanced, skill.elite ] # convert into array
      cert.skills.push _.pick skill, 'id', 'name', 'rank', 'attributes', 'levels'
    delete cert.skillTypes
    # Insert into the collection
    cert._id = id
    Veldspar.StaticData.certificates.insert cert

  return raw

# Security policies
StaticData.skillTree.allow {
  insert: (userId) ->
    user = Meteor.users.findOne({_id: userId});
    return (user?.isAdmin)
  update: (userId) ->
    user = Meteor.users.findOne({_id: userId});
    return (user?.isAdmin)
  remove: (userId) ->
    user = Meteor.users.findOne({_id: userId});
    return (user?.isAdmin)
  }
StaticData.skillCategories.allow {
  insert: (userId) ->
    user = Meteor.users.findOne({_id: userId});
    return (user?.isAdmin)
  update: (userId) ->
    user = Meteor.users.findOne({_id: userId});
    return (user?.isAdmin)
  remove: (userId) ->
    user = Meteor.users.findOne({_id: userId});
    return (user?.isAdmin)
  }
