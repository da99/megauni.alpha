"use strict";

// ================================================================
// ================== Events ======================================
// ================================================================

function canonize_event_name(str) {
  return $.trim(str).replace(ALL_WHITE_SPACE, " ").toUpperCase();
}

function ensure_event_created(raw_name) {
  var name = canonize_event_name(raw_name);
  if (!create_event.names[name])
    throw new Error('Event not created: ' + name);
}

function create_event(raw_name) {
  var name = canonize_event_name(raw_name);

  if (!create_event.names)
    create_event.names = {};
  if (!create_event.names[name])
    create_event.names[name] = [];

  return create_event.names[name];
}

function is_event(raw_name) {
  var name = canonize_event_name(raw_name);
  return !!create_event.names[name];
}

function on(raw_name, func) {
  var name = canonize_event_name(raw_name);
  create_event(name);
  create_event.names[name].push(func);
}

function emit(raw_name, o) {
  if (o.constructor !== Object)
    throw new Error("Argument not an object: " + JSON.stringify(o));

  var cont = true;
  o.flow = {
    stop: function () {
      cont = false;
      return false;
    }
  };
  var name = canonize_event_name(raw_name);
  ensure_event_created(name);
  _.each(create_event.names[name], function (f) {
    f(o);
  });

  return cont;
}

function stopped_emit(name, o) {
  return !emit(name, o);
}

function describe_event(raw_name) {
  var name = canonize_event_name(raw_name);
  ensure_event_created(name);
  return create_event.names[name];
}












