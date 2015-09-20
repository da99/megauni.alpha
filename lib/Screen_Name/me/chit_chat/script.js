

// ================================================================
// Load chit-chat data
// ================================================================

$(function () {

  post('/Chit_Chat/list', {screen_name: Template.read_content('div.screen_name')}, function (err, result) {
    if (err) {
      log('Error in /Chit_Chat/list: ', err, result);
      return;
    }
    if (_.isEmpty(result.chit_chat_list)) {
      var empty = Template.read('div.empty.chit_chat_list');
      var b = $('#Message_Board div.content');
      b.find('div.please_wait.loading').replaceWith(empty);
    }
  });

}); // ==== jquery on dom ready
