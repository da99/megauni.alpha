
require './Server/Consume/model'

# ============ CREATE ===============================================

put '/Consume' do

  begin
    bot = params['bot_screen_name']
    sn  = user.screen_name
    is_on = params['is_on']

    o   = Consume.upsert(bot, user.id, is_on)

    if is_on
      json true, "You are now using, #{bot}, as #{sn}."
    else
      json true, "You are no longer using, #{bot}, as #{sn}."
    end
  rescue Consume::Invalid => e
    json false, e.msg
  end

end # === post /Bot/Use

# ============ READ =================================================

get "/Consume/:id" do

  begin
    Consume.read(params)
    render 'Consume/show_one', :title=> "Consume ##{req.params.id}"
  rescue Consume::Not_Found =>e
    json false, e.msg
  end

end # === get /Consume/:id



# ============ UPDATE ===============================================



# ============ TRASH ================================================



# ============ UNTRASH ==============================================




