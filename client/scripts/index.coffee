Veldspar = (this ? exports).Veldspar
Kernite = (this ? exports).Kernite

# RT: Root Template
Meteor.startup ->
  ((view) ->
    Kernite.ui view

    # Meteor.js events
    view.events view.attach
      'click #rt-nav-logout': ->
        Meteor.logout()

      # Debugging tools
      'click #rt-nav-drop-cache': ->
        _id = Router.current()?.params?._id
        if not _id then alert 'You need to have a character selected!'
        else Meteor.call 'dev.dropCacheTimeout', _id, (error) ->
          if (error) then alert error.reason
          else alert 'Cache timers have been successfully dropped!'

    # Meteor.js helpers
    view.helpers
      'modal': ->
        switch Session.get('app.modal')
          when 'add-key' then Template['add_key']
          when 'signup' then Template['signup']
          else null

    view.onRender ->
      $('#rt-modal-view').on 'hidden.bs.modal', -> Session.set 'app.modal', null

  )(Template.root)


# LD: Loading View
Meteor.startup ->
  ((view) ->
    Kernite.ui view

    view.onRender ->
      Meteor.setInterval (-> $('.loading').toggleClass 'resonate'), 2000

  )(Template.loading)
