/*
# Veldspar EVE Online API Client
# view.js - Reusable view logic
# Copyright © Denis Luchkin-Zhou
*/
Veldspar.UI = {};

/* Base class for all views */
view = Veldspar.UI.view = function () {
  
  /* 
  # DOM Helpers 
  #
  # These functions help with caching of the most frequently
  # used view components: .main and .sidebar
  # These also serve as contexts for the jQuery method.
  #*/
  this.main = function () {
      return $('.main');
  };
  this.side = function () { 
    return $('.sidebar');
  };
  
  /* Sidebar */
  this.Sidebar = {};
  this.Sidebar.resize = function (direction, size, callback) {
    var args = {},
      $main = $('.main'),
      speed = 'fast';
    switch (direction) {
    case 'left':
      args = {
        'margin-left': size,
        'margin-right': '-' + size
      };
      break;
    case 'right':
      args = {
        'margin-left': '-' + size,
        'margin-right': size
      };
      break;
    case 'left-scale':
      args = {
        'margin-left': size
      };
      break;
    case 'right-scale':
      args = {
        'margin-right': size
      };
      break;
    }
    $main.animate(args, speed, function () {
      if (callback) {
        callback();
      }
    });
  };
  this.Sidebar.show = function (direction, size, callback) {
    this.Sidebar.resize(direction, size, callback);
  };
  this.Sidebar.hide = function (direction, callback) {
    this.Sidebar.resize(direction, '0', callback);
  };
  this.Sidebar.reset = function () {
    var $main = $('.main');
    $main.removeAttr('style');
  };
  
  /* Error box */
  this.showError = function (context, html) {
    'use strict';
    var $err = $('.ui-state-error', context);
    if (html) {
      $err.html(html).hide().show('pulsate', {
        times: 2
      });
    } else {
      $err.hide('fade');
    }
  };
  
  /* Textbox forwarding */
  this.forward = function (destination, callback) {
    return _.partial(function (d, c, e) {
      if (e.keyCode === 13 && (!c || c())) {
        $(d).focus();
      }
    }, destination, callback);
  };
  
  /* 
  # Utility function namespace 
  # 
  # Having a util object for all utility methods helps reducing
  # clutter in the code, and makes the distinction between Meteor
  # helper methods and other utility methods very clear.
  */
  this.util = function (helpers) {
    if (helpers) {
    $.extend(this.util, helpers);
    } else return this.util;
  };
  this.util.isEmailAddress = function (str) {
    var rgx = /^\w+(\.\w+|)*@\w+\.\w+$/;
    return str.match(rgx) !== null;
  };
  this.util.getCharPortraitUri = function (id, size) {
    /* Normalize the size to one of the officially supported resolutions */
    size = Math.pow(2, (function (x) {
      var exponent = Math.ceil(Math.LOG2E * Math.log(x));
      if (exponent < 5) { exponent = 5; }
      else if (exponent > 9) { exponent = 9; }
      return exponent;
    })(size));
    /* Construct the uri */
    return _.template('<%= host %>/Character/<%= id %>_<%= size %>.jpg', {
      host: Veldspar.Config.imageHost,
      id: id,
      size: size
    });
  };
  
  /* Step */
  this.Step = {};
  this.Step.init = function (context) {
    var $step = $('.step', context);
    return $step.each(function (i, $e) {
      $(this).addClass('step-' + i)
    });
  };
  this.Step.next = function (context, callback) {
    var $step = $('.step', context);
    $step.animate({ 'left': '-=100%' }, 'fast', callback);
  };
  this.Step.prev = function (context, callback) {
    var $step = $('.step', context);
    $step.animate({ 'left': '+=100%' }, 'fast', callback);
  };
  this.Step.reset = function (context) {
    var $step = $('.step', context);
    $step.removeAttr('style');
  };
};

/* Initialization shorthand */
Veldspar.UI.init = function (template) {
  return $.extend(template, new Veldspar.UI.view());
};
