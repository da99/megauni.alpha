

// ================================================================
// ================== Main Stuff ==================================
// ================================================================


function Listenize(html, funcs) {
  var eles = $(html);

  eles.find('input[publish-to]').each(function (i, el) {
    var target = $(el).attr('publish-to');
    var parent = $($(el).parents('div[id]')[0]);
    $(el).on('keyup', function (e) {
      parent.find(target).text($(this).val());
    });
  });

  eles.find('button[on-click]').each(function (i, el) {
    var func = $(el).attr('on-click');
    console.log(func)
    $(el).click(funcs[func]);
    return false;
  });

  eles.find('ul[list], div[list]').each(function (i, el) {
    var list = List.new( funcs[$(el).attr('list')], el, funcs );
  });

  return eles;
}
