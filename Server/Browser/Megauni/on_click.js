
function on_click(data) {
  var ARGS = data.args.slice(1);

  var FUNC = describe_reduce(
    "Getting function for on_click",
    window[data.args[0]],
    be(is_function)
  );

  $('#' + data.dom_id).on('click', function _on_click_(e) {
    e.stopPropagation();
    FUNC(combine(data, {args: ARGS}));
  });

} // === function
