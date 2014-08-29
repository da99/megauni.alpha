
# =====================================================
# Create
# =====================================================

post '/user' do
  return begin
    args = params.dup
    args[:ip] = env['HTTP_X_REAL_IP']
    c = Customer.create(args)
    sign_in(c)
    json(
      true,
      :msg      => "Account created. Please wait as page is re-loaded...",
      :location => c.to_href
    )

  rescue Screen_Name::Dup => err
    json false, err.msg

  rescue Customer::Invalid => err
    json false, err.msg
  end

end # === post Customer


# =====================================================
# Read
# =====================================================















