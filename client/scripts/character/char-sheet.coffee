Veldspar = (this ? exports).Veldspar
Kernite = (this ? exports).Kernite

# Character Sheet
Meteor.startup ->
  ((view) ->

    # Utility Variables
    maxAttrValue = 32

    view.helpers
      'skills': ->
        _.values @skills
      'dob': ->
        @dob.toLocaleDateString()

      'attrWidth': (attr) ->
        base: @attributes[attr].value / maxAttrValue * 100
        bonus: @attributes[attr].bonus / maxAttrValue * 100


      'timeInCorp': ->
        dt = Veldspar.Timing.diff @date
      'joinDate': ->
        @date.toLocaleString()

      'standingStyleSuffix':  ->
        if -10.0 <= @standing <= -5.0 then 'danger'
        else if -5.0 < @standing <= -3.0 then 'warning'
        else if -3.0 < @standing < 3.0 then 'default'
        else if 3.0 <= @standing < 5.0 then 'success'
        else if 5.0 <= @standing <= 10.0 then 'primary'

      'agentStandings': ->
        return Veldspar.UserData.npcStandings.find type:'agent', {sort: {standing: -1}}
      'corpStandings': ->
        return Veldspar.UserData.npcStandings.find type:'corp', {sort: {standing: -1}}
      'factionStandings': ->
        return Veldspar.UserData.npcStandings.find type:'faction', {sort: {standing: -1}}


  )(Template['char-sheet'])
